#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
COMMAND="$REPO_ROOT/cli/shipglows_skills.py"
CLI="$REPO_ROOT/cli/shipglows.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

HOME_FIXTURE="$TEST_ROOT/home"
BIN_FIXTURE="$TEST_ROOT/bin"
STATE_FIXTURE="$TEST_ROOT/state"
CALLS_FIXTURE="$TEST_ROOT/calls"
mkdir -p "$HOME_FIXTURE" "$BIN_FIXTURE" "$STATE_FIXTURE"
: > "$CALLS_FIXTURE"
printf '%s\n' '# fixture bashrc' > "$HOME_FIXTURE/.bashrc"

cat > "$BIN_FIXTURE/codex" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${FAKE_CODEX_CALLS:?}"
case "$*" in
    "plugin marketplace list --json")
        if [ -f "${FAKE_CODEX_STATE:?}/marketplace" ]; then
            printf '%s\n' '{"marketplaces":[{"name":"shipglows","marketplaceSource":{"source":"https://github.com/commandglows/shipglows.git"}}]}'
        else
            printf '%s\n' '{"marketplaces":[]}'
        fi
        ;;
    "plugin marketplace add "*)
        touch "${FAKE_CODEX_STATE:?}/marketplace"
        printf '%s\n' '{"ok":true}'
        ;;
    "plugin add shipglows@shipglows --json")
        mkdir -p "$HOME/.codex"
        printf '%s\n' '[plugins."shipglows@shipglows"]' 'enabled = true' > "$HOME/.codex/config.toml"
        printf '%s\n' '{"ok":true}'
        ;;
    "plugin remove shipglows@shipglows --json")
        mkdir -p "$HOME/.codex"
        printf '%s\n' '[plugins."shipglows@shipglows"]' 'enabled = false' > "$HOME/.codex/config.toml"
        printf '%s\n' '{"ok":true}'
        ;;
    *)
        printf 'unexpected fake codex call: %s\n' "$*" >&2
        exit 2
        ;;
esac
SH
chmod +x "$BIN_FIXTURE/codex"

run_skills() {
    HOME="$HOME_FIXTURE" \
    SHIPGLOWS_TARGET_HOME="$HOME_FIXTURE" \
    SHIPGLOWS_CODEX_BIN="$BIN_FIXTURE/codex" \
    FAKE_CODEX_STATE="$STATE_FIXTURE" \
    FAKE_CODEX_CALLS="$CALLS_FIXTURE" \
    python3 "$COMMAND" "$@"
}

state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "none"

run_skills plugin-install --yes >/dev/null
state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "plugin"
test "$(grep -c '^plugin marketplace add ' "$CALLS_FIXTURE")" -eq 1
test "$(grep -c '^plugin add shipglows@shipglows --json$' "$CALLS_FIXTURE")" -eq 1

run_skills plugin-install --yes >/dev/null
test "$(grep -c '^plugin add shipglows@shipglows --json$' "$CALLS_FIXTURE")" -eq 1

if run_skills link --root "$REPO_ROOT" >"$TEST_ROOT/confirmation.out" 2>&1; then
    echo "expected non-interactive link confirmation to fail" >&2
    exit 1
fi
grep -q 'Relancez avec --yes' "$TEST_ROOT/confirmation.out"
state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "plugin"

run_skills link --root "$REPO_ROOT" --yes >/dev/null
state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "linked"
test -L "$HOME_FIXTURE/.agents/skills/shipglows"
test -L "$HOME_FIXTURE/.claude/skills/shipglows"
test "$(readlink -f "$HOME_FIXTURE/.local/bin/shipglows")" = "$REPO_ROOT/cli/shipglows.sh"
test "$(readlink -f "$HOME_FIXTURE/.local/bin/sg")" = "$REPO_ROOT/cli/shipglows.sh"
HOME="$HOME_FIXTURE" \
SHIPGLOWS_TARGET_HOME="$HOME_FIXTURE" \
SHIPGLOWS_CODEX_BIN="$BIN_FIXTURE/codex" \
FAKE_CODEX_STATE="$STATE_FIXTURE" \
FAKE_CODEX_CALLS="$CALLS_FIXTURE" \
"$HOME_FIXTURE/.local/bin/shipglows" skills status --json | grep -q '"state": "linked"'
grep -Fq "export SHIPGLOWS_ROOT='$REPO_ROOT'" "$HOME_FIXTURE/.bashrc" || \
    grep -Fq "export SHIPGLOWS_ROOT=$REPO_ROOT" "$HOME_FIXTURE/.bashrc"
python3 - "$HOME_FIXTURE/.config/shipglows/linked-skill-root.json" "$REPO_ROOT" <<'PY'
import json, pathlib, sys
payload = json.loads(pathlib.Path(sys.argv[1]).read_text())
assert payload == {"managed_by": "shipglows-skills-link", "root": sys.argv[2]}
PY
grep -q '^plugin remove shipglows@shipglows --json$' "$CALLS_FIXTURE"

mkdir -p "$HOME_FIXTURE/.agents/skills/personal-skill"
printf '%s\n' 'preserve me' > "$HOME_FIXTURE/.agents/skills/personal-skill/SKILL.md"
run_skills unlink --yes >/dev/null
state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "none"
test -f "$HOME_FIXTURE/.agents/skills/personal-skill/SKILL.md"
test ! -e "$HOME_FIXTURE/.config/shipglows/linked-skill-root.json"
! grep -Fq 'ShipGlows linked skill root' "$HOME_FIXTURE/.bashrc"
test ! -e "$HOME_FIXTURE/.local/bin/shipglows"
test ! -e "$HOME_FIXTURE/.local/bin/sg"

run_skills unlink --yes --install-plugin >/dev/null
state="$(run_skills status --json | python3 -c 'import json,sys; print(json.load(sys.stdin)["state"])')"
test "$state" = "plugin"

run_skills plugin-remove --yes >/dev/null
OTHER_ROOT="$TEST_ROOT/other-shipglows"
git init -q "$OTHER_ROOT"
mkdir -p "$OTHER_ROOT/skills/shipglows" "$OTHER_ROOT/skills/references"
cp "$REPO_ROOT/skills/shipglows/SKILL.md" "$OTHER_ROOT/skills/shipglows/SKILL.md"
cp "$REPO_ROOT/skills/references/skill-invocation-registry.json" "$OTHER_ROOT/skills/references/skill-invocation-registry.json"
mkdir -p "$HOME_FIXTURE/.agents/skills"
ln -s "$OTHER_ROOT/skills/shipglows" "$HOME_FIXTURE/.agents/skills/shipglows"
if run_skills link --root "$REPO_ROOT" --yes >"$TEST_ROOT/conflict.out" 2>&1; then
    echo "expected another-clone conflict" >&2
    exit 1
fi
grep -q 'autre clone ShipGlows' "$TEST_ROOT/conflict.out"
test "$(readlink -f "$HOME_FIXTURE/.agents/skills/shipglows")" = "$(readlink -f "$OTHER_ROOT/skills/shipglows")"

HOME="$HOME_FIXTURE" \
SHIPGLOWS_TARGET_HOME="$HOME_FIXTURE" \
SHIPGLOWS_CODEX_BIN="$BIN_FIXTURE/codex" \
FAKE_CODEX_STATE="$STATE_FIXTURE" \
FAKE_CODEX_CALLS="$CALLS_FIXTURE" \
bash "$CLI" skills status --json | grep -q '"state": "conflict"'

LOCKED_HOME="$TEST_ROOT/locked-home"
mkdir -p "$LOCKED_HOME/.agents/skills" "$LOCKED_HOME/.claude/skills"
chmod 0555 "$LOCKED_HOME/.agents/skills"
if HOME="$LOCKED_HOME" SHIPGLOWS_TARGET_HOME="$LOCKED_HOME" \
    SHIPGLOWS_CODEX_BIN="$BIN_FIXTURE/codex" \
    FAKE_CODEX_STATE="$STATE_FIXTURE" FAKE_CODEX_CALLS="$CALLS_FIXTURE" \
    python3 "$COMMAND" link --root "$REPO_ROOT" --yes >"$TEST_ROOT/permission.out" 2>&1; then
    echo "expected unwritable runtime directory to fail" >&2
    exit 1
fi
grep -q "n'est pas modifiable" "$TEST_ROOT/permission.out"
test -z "$(find "$LOCKED_HOME/.claude/skills" -mindepth 1 -maxdepth 1 -print -quit)"
chmod 0755 "$LOCKED_HOME/.agents/skills"

echo "test_shipglows_skills_channel: passed"
