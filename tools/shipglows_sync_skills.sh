#!/usr/bin/env bash
set -u

MODE="check"
SCOPE=""
RUNTIME="all"
TARGET_HOME="${HOME:-}"
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-${SHIPGLOWS_ROOT:-${HOME:-}/shipglows}}"
BACKUP_EXISTING=0
SKILL_NAME=""
CLEAN_STALE=0

checked=0
ok=0
repaired=0
skipped=0
blocked=0

usage() {
    cat <<'USAGE'
Usage: tools/shipglows_sync_skills.sh [--check|--repair] (--all|--skill <name>) [options]

Options:
  --runtime claude|codex|all      Runtime directory to check or repair (default: all)
  --target-home <path>            Home directory containing .claude/.codex (default: $HOME)
  --shipglows-root <path>         ShipGlows repository root (default: $SHIPGLOWS_ROOT or $HOME/shipglows)
  --shipglows-root <path>          Legacy alias for --shipglows-root
  --backup-existing               Move non-symlink targets aside before repair
  --clean-stale                   Remove stale symlinks in runtime skill dirs that point into ShipGlows skills
  -h, --help                      Show this help
USAGE
}

log() {
    printf '%s\n' "$*"
}

fail() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 2
}

valid_skill_name() {
    local name="$1"
    [[ "$name" =~ ^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$ ]] || return 1
    [[ "$name" != *--* ]]
}

runtime_dir() {
    case "$1" in
        claude) printf '%s/.claude/skills' "$TARGET_HOME" ;;
        codex) printf '%s/.codex/skills' "$TARGET_HOME" ;;
        *) return 1 ;;
    esac
}

backup_path_for() {
    local target_path="$1"
    local base
    local stamp
    base="$(dirname "$target_path")/.$(basename "$target_path").backup"
    stamp="$(date '+%Y%m%d-%H%M%S')"
    printf '%s-%s-%s' "$base" "$stamp" "$$"
}

source_skill_dir() {
    local name="$1"
    printf '%s/skills/%s' "$SHIPGLOWS_ROOT" "$name"
}

resolve_path() {
    readlink -f "$1" 2>/dev/null || true
}

validate_source() {
    local name="$1"
    local source_dir
    local resolved_source
    local resolved_skills

    valid_skill_name "$name" || fail "invalid skill name: $name"
    source_dir="$(source_skill_dir "$name")"
    [ -d "$source_dir" ] || fail "missing source skill directory: $source_dir"
    [ -f "$source_dir/SKILL.md" ] || fail "missing source SKILL.md: $source_dir/SKILL.md"

    resolved_source="$(resolve_path "$source_dir")"
    resolved_skills="$(resolve_path "$SHIPGLOWS_ROOT/skills")"
    [ -n "$resolved_source" ] || fail "cannot resolve source skill: $source_dir"
    [ -n "$resolved_skills" ] || fail "cannot resolve skills root: $SHIPGLOWS_ROOT/skills"
    case "$resolved_source" in
        "$resolved_skills"/*) ;;
        *) fail "source resolves outside skills root: $source_dir -> $resolved_source" ;;
    esac
}

list_skills() {
    local found=0
    local skill_dir
    local name

    [ -d "$SHIPGLOWS_ROOT/skills" ] || fail "missing skills directory: $SHIPGLOWS_ROOT/skills"
    for skill_dir in "$SHIPGLOWS_ROOT"/skills/*; do
        [ -d "$skill_dir" ] || continue
        [ -f "$skill_dir/SKILL.md" ] || continue
        name="$(basename "$skill_dir")"
        valid_skill_name "$name" || continue
        printf '%s\n' "$name"
        found=1
    done
    [ "$found" -eq 1 ] || fail "no valid source skills found in $SHIPGLOWS_ROOT/skills"
}

clean_stale_runtime_links() {
    local runtime="$1"
    local target_dir
    local link_path
    local resolved_target
    local resolved_skills
    local base

    [ "$MODE" = "repair" ] || return 0
    [ "$CLEAN_STALE" -eq 1 ] || return 0

    target_dir="$(runtime_dir "$runtime")" || fail "invalid runtime: $runtime"
    [ -d "$target_dir" ] || return 0
    resolved_skills="$(resolve_path "$SHIPGLOWS_ROOT/skills")"
    [ -n "$resolved_skills" ] || fail "cannot resolve skills root: $SHIPGLOWS_ROOT/skills"

    for link_path in "$target_dir"/*; do
        [ -L "$link_path" ] || continue
        base="$(basename "$link_path")"
        case "$base" in
            [0-9][0-9][0-9]-*) continue ;;
        esac
        resolved_target="$(resolve_path "$link_path")"
        if [ -z "$resolved_target" ] || [ ! -e "$resolved_target" ]; then
            rm -f "$link_path" || {
                blocked=$((blocked + 1))
                log "blocked runtime=$runtime skill=$base target=$link_path reason=cannot-remove-stale-symlink"
                continue
            }
            repaired=$((repaired + 1))
            log "repaired runtime=$runtime skill=$base target=$link_path reason=removed-stale-symlink"
            continue
        fi
        case "$resolved_target" in
            "$resolved_skills"/*)
                if [ ! -f "$resolved_target/SKILL.md" ]; then
                    rm -f "$link_path" || {
                        blocked=$((blocked + 1))
                        log "blocked runtime=$runtime skill=$base target=$link_path reason=cannot-remove-invalid-shipglows-symlink"
                        continue
                    }
                    repaired=$((repaired + 1))
                    log "repaired runtime=$runtime skill=$base target=$link_path reason=removed-invalid-shipglows-symlink"
                fi
                ;;
        esac
    done
}

check_one() {
    local runtime="$1"
    local name="$2"
    local source_dir
    local target_dir
    local target_path
    local resolved_source
    local resolved_target
    local backup_path

    validate_source "$name"
    source_dir="$(source_skill_dir "$name")"
    target_dir="$(runtime_dir "$runtime")" || fail "invalid runtime: $runtime"
    target_path="$target_dir/$name"
    resolved_source="$(resolve_path "$source_dir")"
    checked=$((checked + 1))

    if [ -L "$target_path" ]; then
        resolved_target="$(resolve_path "$target_path")"
        if [ -n "$resolved_target" ] && [ "$resolved_target" = "$resolved_source" ] && [ -f "$target_path/SKILL.md" ]; then
            ok=$((ok + 1))
            log "ok runtime=$runtime skill=$name target=$target_path"
            return 0
        fi
        if [ "$MODE" = "check" ]; then
            blocked=$((blocked + 1))
            log "drift runtime=$runtime skill=$name target=$target_path reason=stale-or-broken-symlink"
            return 1
        fi
        rm -f "$target_path" || {
            blocked=$((blocked + 1))
            log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-remove-stale-symlink"
            return 1
        }
        mkdir -p "$target_dir" || {
            blocked=$((blocked + 1))
            log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-runtime-dir"
            return 1
        }
        ln -s "$source_dir" "$target_path" || {
            blocked=$((blocked + 1))
            log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-symlink"
            return 1
        }
        repaired=$((repaired + 1))
        log "repaired runtime=$runtime skill=$name target=$target_path reason=stale-or-broken-symlink"
        return 0
    fi

    if [ -e "$target_path" ]; then
        if [ "$MODE" = "repair" ] && [ "$BACKUP_EXISTING" -eq 1 ]; then
            mkdir -p "$target_dir" || {
                blocked=$((blocked + 1))
                log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-runtime-dir"
                return 1
            }
            backup_path="$(backup_path_for "$target_path")"
            mv "$target_path" "$backup_path" || {
                blocked=$((blocked + 1))
                log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-backup-existing"
                return 1
            }
            ln -s "$source_dir" "$target_path" || {
                blocked=$((blocked + 1))
                log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-symlink backup=$backup_path"
                return 1
            }
            repaired=$((repaired + 1))
            log "repaired runtime=$runtime skill=$name target=$target_path reason=backed-up-existing backup=$backup_path"
            return 0
        fi
        blocked=$((blocked + 1))
        log "blocked runtime=$runtime skill=$name target=$target_path reason=non-symlink-existing next=remove-or-rerun-with---backup-existing"
        return 1
    fi

    if [ "$MODE" = "check" ]; then
        blocked=$((blocked + 1))
        log "missing runtime=$runtime skill=$name target=$target_path"
        return 1
    fi

    mkdir -p "$target_dir" || {
        blocked=$((blocked + 1))
        log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-runtime-dir"
        return 1
    }
    ln -s "$source_dir" "$target_path" || {
        blocked=$((blocked + 1))
        log "blocked runtime=$runtime skill=$name target=$target_path reason=cannot-create-symlink"
        return 1
    }
    if [ ! -f "$target_path/SKILL.md" ]; then
        blocked=$((blocked + 1))
        log "blocked runtime=$runtime skill=$name target=$target_path reason=skill-md-not-reachable"
        return 1
    fi
    repaired=$((repaired + 1))
    log "repaired runtime=$runtime skill=$name target=$target_path reason=missing"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --check) MODE="check"; shift ;;
        --repair) MODE="repair"; shift ;;
        --all) SCOPE="all"; shift ;;
        --skill)
            [ "$#" -ge 2 ] || fail "--skill requires a name"
            SCOPE="skill"
            SKILL_NAME="$2"
            shift 2
            ;;
        --runtime)
            [ "$#" -ge 2 ] || fail "--runtime requires claude, codex, or all"
            RUNTIME="$2"
            shift 2
            ;;
        --target-home)
            [ "$#" -ge 2 ] || fail "--target-home requires a path"
            TARGET_HOME="$2"
            shift 2
            ;;
        --shipglows-root|--shipglows-root)
            [ "$#" -ge 2 ] || fail "$1 requires a path"
            SHIPGLOWS_ROOT="$2"
            shift 2
            ;;
        --backup-existing) BACKUP_EXISTING=1; shift ;;
        --clean-stale) CLEAN_STALE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) fail "unknown argument: $1" ;;
    esac
done

[ -n "$TARGET_HOME" ] || fail "HOME is unavailable; use --target-home"
[ -n "$SHIPGLOWS_ROOT" ] || fail "SHIPGLOWS_ROOT is unavailable; use --shipglows-root"
case "$RUNTIME" in claude|codex|all) ;; *) fail "invalid runtime: $RUNTIME" ;; esac
[ -n "$SCOPE" ] || SCOPE="all"

if [ "$SCOPE" = "skill" ]; then
    validate_source "$SKILL_NAME"
    skills="$SKILL_NAME"
else
    skills="$(list_skills)"
fi

case "$RUNTIME" in
    claude|codex) runtimes="$RUNTIME" ;;
    all) runtimes="claude codex" ;;
esac

status=0
for runtime in $runtimes; do
    clean_stale_runtime_links "$runtime" || status=1
done
for skill in $skills; do
    for runtime in $runtimes; do
        check_one "$runtime" "$skill" || status=1
    done
done

log "summary mode=$MODE runtime=$RUNTIME scope=$SCOPE checked=$checked ok=$ok repaired=$repaired skipped=$skipped blocked=$blocked"
if [ "$MODE" = "repair" ]; then
    log "note: already-running Claude or Codex sessions may need a reload or new session before repaired skills appear in the skill list."
fi

exit "$status"
