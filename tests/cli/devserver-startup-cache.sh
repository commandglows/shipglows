#!/bin/bash

# Focused regression tests for lazy DevServer discovery and cache ownership.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWS_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_STATE_DIR="$SHIPGLOWS_STATE_DIR"
export SHIPGLOWS_LEGACY_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_LEGACY_STATE_DIR="$SHIPGLOWS_LEGACY_STATE_DIR"
export SHIPGLOWS_PROJECTS_DIR="$HOME/projects"
export SHIPGLOWS_PROJECTS_DIR="$SHIPGLOWS_PROJECTS_DIR"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_STATE_DIR/envs.reg"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_REGISTRY"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_REGISTRY_LOCK_ATTEMPTS=2
export SHIPGLOWS_REGISTRY_LOCK_INTERVAL=0.01
export SHIPGLOWS_REGISTRY_EMPTY_LOCK_GRACE_SECONDS=1

mkdir -p "$SHIPGLOWS_PROJECTS_DIR/app-one/.flox/deep/internal/.flox" \
    "$SHIPGLOWS_PROJECTS_DIR/group/app/.flox/cache"
cat > "$SHIPGLOWS_PROJECTS_DIR/app-one/package.json" <<'EOF'
{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}
EOF
cat > "$SHIPGLOWS_PROJECTS_DIR/group/app/package.json" <<'EOF'
{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}
EOF

FAKE_BIN="$TEST_ROOT/bin"
PM2_COUNT_FILE="$TEST_ROOT/pm2-count"
mkdir -p "$FAKE_BIN"
printf '0\n' > "$PM2_COUNT_FILE"
cat > "$FAKE_BIN/pm2" <<'EOF'
#!/bin/bash
count=$(cat "$PM2_COUNT_FILE")
printf '%s\n' "$((count + 1))" > "$PM2_COUNT_FILE"
if [ "${1:-}" = "jlist" ]; then
    printf '%s\n' '[{"name":"group_app","pm2_env":{"status":"online","env":{"PORT":"3042"},"pm_cwd":"'"$SHIPGLOWS_PROJECTS_DIR"'/group/app"}}]'
fi
EOF
cat > "$FAKE_BIN/jq" <<'EOF'
#!/bin/bash
node -e '
let body = "";
process.stdin.on("data", chunk => body += chunk);
process.stdin.on("end", () => {
  for (const app of JSON.parse(body)) {
    const env = app.pm2_env || {};
    process.stdout.write(`${app.name}|${env.status || "unknown"}|${(env.env || {}).PORT || ""}|${env.pm_cwd || ""}\n`);
  }
});
'
EOF
chmod +x "$FAKE_BIN/pm2" "$FAKE_BIN/jq"
export PM2_COUNT_FILE
export PATH="$FAKE_BIN:$PATH"

source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_eq() {
    local expected="$1" actual="$2" label="$3"
    [ "$expected" = "$actual" ] || fail "$label (expected '$expected', got '$actual')"
}

# Sourcing must stay lazy: no PM2 fetch and no registry creation/discovery.
assert_eq "0" "$(cat "$PM2_COUNT_FILE")" "lib source does not fetch PM2"
[ ! -e "$SHIPGLOWS_REGISTRY" ] || fail "lib source does not create the registry"

# A discovered .flox is emitted once with separate environment and launch
# paths, and its internal descendants are pruned.
scan_output="$(scan_flox_projects)"
assert_eq "2" "$(printf '%s\n' "$scan_output" | grep -c .)" "scanner returns two projects"
assert_eq "1" "$(printf '%s\n' "$scan_output" | grep -c '^app-one|')" "scanner prunes nested .flox"
printf '%s\n' "$scan_output" | grep -q '^group_app|' || fail "scanner preserves derived PM2 names"
printf '%s\n' "$scan_output" | grep -q "^group_app|$SHIPGLOWS_PROJECTS_DIR/group/app|$SHIPGLOWS_PROJECTS_DIR/group/app$" \
    || fail "direct Flox projects record identical environment and launch paths"

# Destination-variable PM2 reads share one parent-shell snapshot.
invalidate_pm2_cache
printf '0\n' > "$PM2_COUNT_FILE"
pm2_data_load first_pm2
pm2_data_load second_pm2
assert_eq "1" "$(cat "$PM2_COUNT_FILE")" "PM2 snapshot is fetched once"
assert_eq "$first_pm2" "$second_pm2" "PM2 snapshot values match"
pm2_status_load group_status "group_app"
pm2_port_load group_port "group_app"
pm2_app_data_load group_cwd "group_app" "cwd"
assert_eq "online" "$group_status" "status destination API"
assert_eq "3042" "$group_port" "port destination API"
assert_eq "$SHIPGLOWS_PROJECTS_DIR/group/app" "$group_cwd" "cwd destination API"
assert_eq "1" "$(cat "$PM2_COUNT_FILE")" "nested PM2 consumers reuse the parent snapshot"

# Destination-variable APIs must survive Bash dynamic scope when production
# callers use the same common names as internal fields.
target=""
value=""
_shipglows_assign target "assigned-target"
_shipglows_assign value "assigned-value"
assert_eq "assigned-target" "$target" "assign helper supports target destination"
assert_eq "assigned-value" "$value" "assign helper supports value destination"

data=""
status=""
port=""
cwd=""
routes=""
pm2_data_load data
pm2_status_load status "group_app"
pm2_port_load port "group_app"
pm2_app_data_load cwd "group_app" "cwd"
refresh_cli_project_catalog
user_caddy_routes_load routes
assert_eq "$first_pm2" "$data" "data production destination"
assert_eq "online" "$status" "status production destination"
assert_eq "3042" "$port" "port production destination"
assert_eq "$SHIPGLOWS_PROJECTS_DIR/group/app" "$cwd" "cwd production destination"
[[ "$routes" =~ ^group-app-[a-f0-9]{8}\.preview\.shipglows\.com\|3042$ ]] || fail "catalog routes use a stable exact host"

assert_eq "$first_pm2" "$(get_pm2_data_cached)" "PM2 data compatibility wrapper"
assert_eq "online" "$(get_pm2_status group_app)" "PM2 status compatibility wrapper"
assert_eq "3042" "$(get_port_from_pm2 group_app)" "PM2 port compatibility wrapper"
assert_eq "$SHIPGLOWS_PROJECTS_DIR/group/app" "$(get_pm2_app_data group_app cwd)" "PM2 cwd compatibility wrapper"
assert_eq "$routes" "$(user_caddy_routes_from_pm2)" "Caddy routes compatibility wrapper"

# A known mutation invalidates the session snapshot before the next read.
invalidate_after_pm2_mutation
pm2_data_load third_pm2
assert_eq "2" "$(cat "$PM2_COUNT_FILE")" "PM2 mutation invalidates the snapshot"

# Registry creation is atomic and becomes the shared name/path index.
registry_sync
[ -f "$SHIPGLOWS_REGISTRY" ] || fail "registry_sync creates a registry"
case "$(uname -s)" in
    MINGW*|MSYS*) ;;
    *) assert_eq "600" "$(stat -c '%a' "$SHIPGLOWS_REGISTRY")" "registry permissions" ;;
esac
environment_names_load names_one
environment_names_load names_two
assert_eq "$names_one" "$names_two" "environment snapshot is reused"
resolve_project_path_into resolved "group_app"
assert_eq "$SHIPGLOWS_PROJECTS_DIR/group/app" "$resolved" "path lookup uses registry"

index=""
names=""
identifiers=""
path=""
folders=""
all_envs=""
mkdir -p "$HOME/plain-folder"
environment_index_load index
environment_names_load names
environment_identifiers_load identifiers
resolve_project_path_into path "group_app"
home_folders_load folders "$HOME"
stop_targets_load all_envs
printf '%s\n' "$index" | grep -q '^group_app|online|3042|' || fail "index production destination"
printf '%s\n' "$names" | grep -qx 'group_app' || fail "names production destination"
printf '%s\n' "$identifiers" | grep -qx "$SHIPGLOWS_PROJECTS_DIR/group/app" || fail "identifiers production destination"
assert_eq "$SHIPGLOWS_PROJECTS_DIR/group/app" "$path" "path production destination"
printf '%s\n' "$folders" | grep -qx "$HOME/plain-folder" || fail "folders production destination"
printf '%s\n' "$all_envs" | grep -qx 'group_app' || fail "all_envs production destination"

assert_eq "$names" "$(list_all_environments)" "environment names compatibility wrapper"
assert_eq "$identifiers" "$(list_all_environment_identifiers)" "environment identifiers compatibility wrapper"
assert_eq "$path" "$(resolve_project_path group_app)" "path compatibility wrapper"
assert_eq "$folders" "$(list_home_folders "$HOME")" "home folders compatibility wrapper"
assert_eq "$all_envs" "$(list_all_stop_targets)" "stop targets compatibility wrapper"

# An atomic update from another process invalidates the in-memory index through
# its inode fingerprint even after the short-lived invalidation marker is gone.
mkdir -p "$SHIPGLOWS_PROJECTS_DIR/external/.flox"
external_registry="$SHIPGLOWS_STATE_DIR/external.reg"
cp "$SHIPGLOWS_REGISTRY" "$external_registry"
cat > "$SHIPGLOWS_PROJECTS_DIR/external/package.json" <<'EOF'
{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}
EOF
printf '%s\n' "external|stopped||$SHIPGLOWS_PROJECTS_DIR/external|$SHIPGLOWS_PROJECTS_DIR/external" >> "$external_registry"
chmod 600 "$external_registry"
mv "$external_registry" "$SHIPGLOWS_REGISTRY"
environment_names_load names_after_external_update
printf '%s\n' "$names_after_external_update" | grep -qx 'external' || fail "external registry replacement refreshes the parent index"

# A failed rebuild preserves the last complete snapshot.
registry_before="$(cat "$SHIPGLOWS_REGISTRY")"
scan_flox_projects() { return 1; }
if registry_sync; then
    fail "failed discovery must fail registry_sync"
fi
assert_eq "$registry_before" "$(cat "$SHIPGLOWS_REGISTRY")" "failed refresh preserves registry"
unset -f scan_flox_projects
source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

# A held lock is bounded; a valid previous snapshot remains usable.
mkdir -p "${SHIPGLOWS_REGISTRY}.lock"
printf '%s\n' "$$" > "${SHIPGLOWS_REGISTRY}.lock/pid"
touch "${SHIPGLOWS_REGISTRY}.invalidated"
start_ns=$(date +%s%N)
ensure_registry || fail "valid last-known registry should survive a busy refresh"
elapsed_ms=$(( ($(date +%s%N) - start_ns) / 1000000 ))
[ "$elapsed_ms" -lt 500 ] || fail "registry lock wait is bounded (${elapsed_ms}ms)"
rm -f "${SHIPGLOWS_REGISTRY}.lock/pid"
rmdir "${SHIPGLOWS_REGISTRY}.lock" 2>/dev/null || true
rm -f "${SHIPGLOWS_REGISTRY}.invalidated"

# An empty lock is busy during its creation grace window, but a lock left
# empty by a crashed writer is recovered once that bounded window expires.
SHIPGLOWS_REGISTRY_EMPTY_LOCK_GRACE_SECONDS=60
mkdir -p "${SHIPGLOWS_REGISTRY}.lock"
if _registry_acquire_lock; then
    _registry_release_lock
    fail "recent empty registry lock must remain busy"
fi
[ -d "${SHIPGLOWS_REGISTRY}.lock" ] || fail "recent empty registry lock is preserved"
rmdir "${SHIPGLOWS_REGISTRY}.lock"

SHIPGLOWS_REGISTRY_EMPTY_LOCK_GRACE_SECONDS=1
mkdir -p "${SHIPGLOWS_REGISTRY}.lock"
touch -d '5 seconds ago' "${SHIPGLOWS_REGISTRY}.lock"
_registry_acquire_lock || fail "old empty registry lock should be recovered"
assert_eq "$BASHPID" "$(cat "${SHIPGLOWS_REGISTRY}.lock/pid")" "recovered empty lock has current owner"
_registry_release_lock
[ ! -d "${SHIPGLOWS_REGISTRY}.lock" ] || fail "recovered empty registry lock is releasable"

# PID-bearing locks preserve a live owner and recover a dead owner.
mkdir -p "${SHIPGLOWS_REGISTRY}.lock"
printf '%s\n' "$BASHPID" > "${SHIPGLOWS_REGISTRY}.lock/pid"
touch -d '5 seconds ago' "${SHIPGLOWS_REGISTRY}.lock"
if _registry_acquire_lock; then
    _registry_release_lock
    fail "live registry lock owner must never be removed"
fi
assert_eq "$BASHPID" "$(cat "${SHIPGLOWS_REGISTRY}.lock/pid")" "live registry lock owner is preserved"
rm -f "${SHIPGLOWS_REGISTRY}.lock/pid"
rmdir "${SHIPGLOWS_REGISTRY}.lock"

mkdir -p "${SHIPGLOWS_REGISTRY}.lock"
printf '%s\n' '99999999' > "${SHIPGLOWS_REGISTRY}.lock/pid"
_registry_acquire_lock || fail "dead registry lock owner should be recovered"
assert_eq "$BASHPID" "$(cat "${SHIPGLOWS_REGISTRY}.lock/pid")" "recovered dead lock has current owner"
_registry_release_lock

# A shortcut harness must replace the terminal action as well as the picker;
# otherwise m -> r continues into a real restart and its stabilization wait.
picker_seen=false
ui_choose() {
    picker_seen=true
    printf '%s\n' "🟢 group_app"
}
action_restart() {
    local selected=""
    selected=$(select_environment "Select environment to restart") || return 1
    assert_eq "group_app" "$selected" "m r picker selection"
}
run_menu_shortcut m r

# Idle pending-input protection must return immediately without a fixed 120ms.
start_ns=$(date +%s%N)
ui_flush_pending_input </dev/null
elapsed_ms=$(( ($(date +%s%N) - start_ns) / 1000000 ))
[ "$elapsed_ms" -lt 50 ] || fail "idle input flush is adaptive (${elapsed_ms}ms)"

# The pure-Bash filter reserves only a sole x/q (plus Esc/Backspace) for
# cancellation; x remains searchable as part of a longer query.
filter_stdout="$TEST_ROOT/filter-stdout"
filter_stderr="$TEST_ROOT/filter-stderr"
set +e
printf 'x\n' | (export HAS_GUM=false PATH=/usr/bin:/bin; ui_filter_choose "Search" "xylophone" "alpha") >"$filter_stdout" 2>"$filter_stderr"
filter_rc=$?
set -e
assert_eq "1" "$filter_rc" "fallback x query cancels"
[ ! -s "$filter_stdout" ] || fail "fallback x cancellation has no selection output"
! grep -q 'No match' "$filter_stderr" || fail "fallback x cancellation must not filter first"
assert_eq "q" "$(_ui_normalize_filter_query ' Q ')" "fallback q query normalization"
assert_eq "x" "$(_ui_normalize_filter_query $'\e')" "fallback Esc query normalization"
assert_eq "x" "$(_ui_normalize_filter_query $'\177')" "fallback Backspace query normalization"
assert_eq "x ray" "$(_ui_normalize_filter_query ' X Ray ')" "filter query keeps text containing x"

set +e
printf 'xylophone\n' | (export HAS_GUM=false PATH=/usr/bin:/bin; ui_filter_choose "Search" "xylophone" "alpha") >"$filter_stdout" 2>"$filter_stderr"
filter_rc=$?
set -e
assert_eq "0" "$filter_rc" "fallback query containing x remains searchable"
assert_eq "xylophone" "$(cat "$filter_stdout")" "fallback x-containing query selection"

# gum/fzf own their interactive cancellation. Mocks verify that their real
# return code is preserved and the displayed help advertises supported keys.
UI_MOCK_BIN="$TEST_ROOT/ui-mock-bin"
UI_MOCK_ARGS="$TEST_ROOT/ui-mock-args"
mkdir -p "$UI_MOCK_BIN"
cat > "$UI_MOCK_BIN/gum" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" > "$UI_MOCK_ARGS"
exit 130
EOF
cat > "$UI_MOCK_BIN/fzf" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" > "$UI_MOCK_ARGS"
exit 130
EOF
chmod +x "$UI_MOCK_BIN/gum" "$UI_MOCK_BIN/fzf"

set +e
(export HAS_GUM=true UI_MOCK_ARGS PATH="$UI_MOCK_BIN:/usr/bin:/bin"; ui_filter_choose "Search" "alpha" "beta") >"$filter_stdout" 2>"$filter_stderr"
filter_rc=$?
set -e
assert_eq "130" "$filter_rc" "gum cancellation return code"
grep -Eq 'Esc|Ctrl-C' "$UI_MOCK_ARGS" || fail "gum filter exposes honest cancellation help"

rm -f "$UI_MOCK_BIN/gum"
set +e
(export HAS_GUM=false UI_MOCK_ARGS PATH="$UI_MOCK_BIN:/usr/bin:/bin"; ui_filter_choose "Search" "alpha" "beta") >"$filter_stdout" 2>"$filter_stderr"
filter_rc=$?
set -e
assert_eq "130" "$filter_rc" "fzf cancellation return code"
grep -Eq 'Esc|Ctrl-C' "$UI_MOCK_ARGS" || fail "fzf exposes honest cancellation help"

echo "DevServer startup/cache regressions passed"
