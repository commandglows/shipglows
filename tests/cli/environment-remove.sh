#!/bin/bash

# Regression coverage for complete environment removal and runtime cleanup.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
LISTENER_PID=""
NON_LISTENER_PID=""
OUTSIDE_LISTENER_PID=""
RESPAWN_SUPERVISOR_PID=""
RESPAWN_CHILD_PID=""
cleanup() {
    [ -z "$LISTENER_PID" ] || kill "$LISTENER_PID" 2>/dev/null || true
    [ -z "$NON_LISTENER_PID" ] || kill "$NON_LISTENER_PID" 2>/dev/null || true
    [ -z "$OUTSIDE_LISTENER_PID" ] || kill "$OUTSIDE_LISTENER_PID" 2>/dev/null || true
    [ -z "$RESPAWN_SUPERVISOR_PID" ] || kill "$RESPAWN_SUPERVISOR_PID" 2>/dev/null || true
    [ -z "$RESPAWN_CHILD_PID" ] || kill "$RESPAWN_CHILD_PID" 2>/dev/null || true
    rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWS_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_STATE_DIR="$SHIPGLOWS_STATE_DIR"
export SHIPGLOWS_PROJECTS_DIR="$HOME/projects"
export SHIPGLOWS_PROJECTS_DIR="$SHIPGLOWS_PROJECTS_DIR"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_STATE_DIR/envs.reg"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_REGISTRY"
export SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE="$SHIPGLOWS_STATE_DIR/flutter-web-sessions.tsv"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_USER_CADDY_ENABLED=false

PROJECT_DIR="$SHIPGLOWS_PROJECTS_DIR/delete-me"
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
        printf '%s\n' '[{"name":"delete-me","pid":123,"pm2_env":{"status":"online","pm_cwd":"'"$SHIPGLOWS_PROJECTS_DIR"'/delete-me","env":{"PORT":"3011"}}}]'
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

printf '%s|%s|%s|%s\n' "delete-me" "3011" "$PROJECT_DIR" "shipglows-flutter-delete-me" > "$SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE"
touch "$TMUX_STATE/shipglows-flutter-delete-me"

resolve_project_path_into resolved "$PROJECT_DIR" || fail "absolute project path should resolve"
[ "$resolved" = "$PROJECT_DIR" ] || fail "resolved path mismatch"

mkdir -p "$HOME/plain-folder"
if resolve_project_path_into _resolved "$HOME/plain-folder"; then
    fail "absolute non-project directory must not resolve"
fi

env_remove "delete-me" || fail "environment removal should succeed"
[ ! -e "$PROJECT_DIR" ] || fail "project directory remains"
[ ! -e "$TMUX_STATE/shipglows-flutter-delete-me" ] || fail "Flutter tmux session remains"
[ ! -s "$SHIPGLOWS_FLUTTER_WEB_SESSIONS_FILE" ] || fail "Flutter session registry remains"
[ ! -e "$SHIPGLOWS_REGISTRY.invalidated" ] || fail "registry invalidation marker remains"
if grep -q '^delete-me|' "$SHIPGLOWS_REGISTRY" 2>/dev/null; then
    fail "deleted environment remains in ShipGlows registry"
fi
grep -q '^delete delete-me$' "$PM2_EVENTS" || fail "PM2 delete was not called"
grep -q '^kill-session shipglows-flutter-delete-me$' "$PM2_EVENTS" || fail "tmux session was not killed"
[ "$(wc -l < "$CADDY_EVENTS")" -eq 1 ] || fail "Caddy sync was not called exactly once"
grep -q '^delete --force --dir=' "$FLOX_EVENTS" || fail "Flox environment was not deleted"

PROJECT_DIR="$SHIPGLOWS_PROJECTS_DIR/manual-server"
mkdir -p "$PROJECT_DIR/.flox" "$PROJECT_DIR/nested"

(
    cd "$PROJECT_DIR/nested"
    exec python3 -m http.server 0 --bind 127.0.0.1
) >"$TEST_ROOT/manual-server.log" 2>&1 &
LISTENER_PID=$!

(
    cd "$PROJECT_DIR"
    exec sleep 60
) &
NON_LISTENER_PID=$!

(
    cd "$TEST_ROOT"
    exec python3 -m http.server 0 --bind 127.0.0.1
) >"$TEST_ROOT/outside-server.log" 2>&1 &
OUTSIDE_LISTENER_PID=$!

for _attempt in $(seq 1 50); do
    if ss -ltnp 2>/dev/null | grep -q "pid=$LISTENER_PID,"; then
        break
    fi
    sleep 0.1
done
ss -ltnp 2>/dev/null | grep -q "pid=$LISTENER_PID," || fail "manual test server did not start listening"
for _attempt in $(seq 1 50); do
    ss -ltnp 2>/dev/null | grep -q "pid=$OUTSIDE_LISTENER_PID," && break
    sleep 0.1
done
ss -ltnp 2>/dev/null | grep -q "pid=$OUTSIDE_LISTENER_PID," || fail "out-of-scope listener did not start"
printf '%s|%s|%s|%s\n' "manual-server" "unknown" "" "$PROJECT_DIR" >> "$SHIPGLOWS_REGISTRY"

env_remove "manual-server" || fail "environment removal with manual server should succeed"
if kill -0 "$LISTENER_PID" 2>/dev/null; then
    fail "manual TCP listener remains after environment removal"
fi
kill -0 "$NON_LISTENER_PID" 2>/dev/null || fail "non-listening process was stopped"
kill -0 "$OUTSIDE_LISTENER_PID" 2>/dev/null || fail "out-of-scope TCP listener was stopped"
[ ! -e "$PROJECT_DIR" ] || fail "manual-server project directory remains"
builtin kill "$NON_LISTENER_PID" 2>/dev/null || true
wait "$NON_LISTENER_PID" 2>/dev/null || true
NON_LISTENER_PID=""

PROJECT_DIR="$SHIPGLOWS_PROJECTS_DIR/blocked-server"
mkdir -p "$PROJECT_DIR/.flox"
printf '%s|%s|%s|%s\n' "blocked-server" "unknown" "" "$PROJECT_DIR" >> "$SHIPGLOWS_REGISTRY"
(
    cd "$PROJECT_DIR"
    trap 'exit 0' TERM INT
    while :; do
        python3 -m http.server 0 --bind 127.0.0.1 >/dev/null 2>&1 &
        wait $! || true
    done
) >"$TEST_ROOT/respawn-supervisor.log" 2>&1 &
RESPAWN_SUPERVISOR_PID=$!
for _attempt in $(seq 1 50); do
    RESPAWN_CHILD_PID=$(pgrep -P "$RESPAWN_SUPERVISOR_PID" | head -1 || true)
    [ -n "$RESPAWN_CHILD_PID" ] && ss -ltnp 2>/dev/null | grep -q "pid=$RESPAWN_CHILD_PID," && break
    sleep 0.1
done
if env_remove "blocked-server"; then
    fail "environment removal should fail while a supervisor respawns project listeners"
fi
[ -d "$PROJECT_DIR" ] || fail "project was deleted after listener shutdown failure"
RESPAWN_CHILD_PID=$(pgrep -P "$RESPAWN_SUPERVISOR_PID" | head -1 || true)
builtin kill "$RESPAWN_SUPERVISOR_PID" 2>/dev/null || true
wait "$RESPAWN_SUPERVISOR_PID" 2>/dev/null || true
RESPAWN_SUPERVISOR_PID=""
[ -z "$RESPAWN_CHILD_PID" ] || builtin kill "$RESPAWN_CHILD_PID" 2>/dev/null || true
RESPAWN_CHILD_PID=""
builtin kill "$OUTSIDE_LISTENER_PID" 2>/dev/null || true
wait "$OUTSIDE_LISTENER_PID" 2>/dev/null || true
OUTSIDE_LISTENER_PID=""

printf 'PASS: environment removal cleans managed runtimes and project-scoped manual TCP listeners only\n'
