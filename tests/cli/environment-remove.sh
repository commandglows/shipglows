#!/bin/bash

# Regression coverage for complete environment removal and runtime cleanup.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWZ_STATE_DIR="$HOME/.shipglowz"
export SHIPFLOW_STATE_DIR="$SHIPGLOWZ_STATE_DIR"
export SHIPGLOWZ_PROJECTS_DIR="$HOME/projects"
export SHIPFLOW_PROJECTS_DIR="$SHIPGLOWZ_PROJECTS_DIR"
export SHIPGLOWZ_REGISTRY="$SHIPGLOWZ_STATE_DIR/envs.reg"
export SHIPFLOW_REGISTRY="$SHIPGLOWZ_REGISTRY"
export SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE="$SHIPGLOWZ_STATE_DIR/flutter-web-sessions.tsv"
export SHIPFLOW_ERROR_TRAPS=false
export SHIPFLOW_STRICT_MODE=false
export SHIPGLOWZ_LOGGING_ENABLED=false
export SHIPFLOW_LOGGING_ENABLED=false
export SHIPGLOWZ_USER_CADDY_ENABLED=false

PROJECT_DIR="$SHIPGLOWZ_PROJECTS_DIR/delete-me"
TMUX_STATE="$TEST_ROOT/tmux-state"
PM2_EVENTS="$TEST_ROOT/pm2-events"
CADDY_EVENTS="$TEST_ROOT/caddy-events"
FLOX_EVENTS="$TEST_ROOT/flox-events"
FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$PROJECT_DIR/.flox" "$FAKE_BIN" "$TMUX_STATE"

cat > "$FAKE_BIN/pm2" <<'EOF'
#!/bin/bash
case "${1:-}" in
    jlist)
        printf '%s\n' '[{"name":"delete-me","pid":123,"pm2_env":{"status":"online","pm_cwd":"'"$SHIPGLOWZ_PROJECTS_DIR"'/delete-me","env":{"PORT":"3011"}}}]'
        ;;
    delete|save)
        printf '%s\n' "$*" >> "$PM2_EVENTS"
        ;;
esac
EOF

cat > "$FAKE_BIN/tmux" <<'EOF'
#!/bin/bash
case "${1:-}" in
    has-session)
        test -f "$TMUX_STATE/${3:-}"
        ;;
    kill-session)
        rm -f "$TMUX_STATE/${3:-}"
        printf 'kill-session %s\n' "${3:-}" >> "$PM2_EVENTS"
        ;;
esac
EOF

cat > "$FAKE_BIN/flox" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >> "$FLOX_EVENTS"
EOF

chmod +x "$FAKE_BIN/pm2" "$FAKE_BIN/tmux" "$FAKE_BIN/flox"
export FLOX_EVENTS PM2_EVENTS TMUX_STATE
export PATH="$FAKE_BIN:$PATH"

source "$REPO_ROOT/cli/config.sh"
source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

sync_caddy_after_pm2_change() {
    printf 'sync\n' >> "$CADDY_EVENTS"
}

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

printf '%s|%s|%s|%s\n' "delete-me" "3011" "$PROJECT_DIR" "shipglowz-flutter-delete-me" > "$SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE"
touch "$TMUX_STATE/shipglowz-flutter-delete-me"

resolve_project_path_into resolved "$PROJECT_DIR" || fail "absolute project path should resolve"
[ "$resolved" = "$PROJECT_DIR" ] || fail "resolved path mismatch"

mkdir -p "$HOME/plain-folder"
if resolve_project_path_into _resolved "$HOME/plain-folder"; then
    fail "absolute non-project directory must not resolve"
fi

env_remove "delete-me" || fail "environment removal should succeed"
[ ! -e "$PROJECT_DIR" ] || fail "project directory remains"
[ ! -e "$TMUX_STATE/shipglowz-flutter-delete-me" ] || fail "Flutter tmux session remains"
[ ! -s "$SHIPGLOWZ_FLUTTER_WEB_SESSIONS_FILE" ] || fail "Flutter session registry remains"
[ ! -e "$SHIPGLOWZ_REGISTRY.invalidated" ] || fail "registry invalidation marker remains"
if grep -q '^delete-me|' "$SHIPGLOWZ_REGISTRY" 2>/dev/null; then
    fail "deleted environment remains in ShipGlowz registry"
fi
grep -q '^delete delete-me$' "$PM2_EVENTS" || fail "PM2 delete was not called"
grep -q '^kill-session shipglowz-flutter-delete-me$' "$PM2_EVENTS" || fail "tmux session was not killed"
[ "$(wc -l < "$CADDY_EVENTS")" -eq 1 ] || fail "Caddy sync was not called exactly once"
grep -q '^delete --force --dir=' "$FLOX_EVENTS" || fail "Flox environment was not deleted"

printf 'PASS: environment removal cleans project, PM2, Flutter Web, Caddy sync, and registry state\n'
