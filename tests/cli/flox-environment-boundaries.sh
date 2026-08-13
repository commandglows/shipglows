#!/bin/bash

# Regression coverage for separating Linux Flox environment roots from native
# application launch paths.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

export HOME="$TEST_ROOT/home"
export SHIPGLOWS_STATE_DIR="$HOME/.shipglows"
export SHIPGLOWS_PROJECTS_DIR="$HOME/projects"
export SHIPGLOWS_REGISTRY="$SHIPGLOWS_STATE_DIR/envs.reg"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export SHIPGLOWS_LOGGING_ENABLED=false
export SHIPGLOWS_REGISTRY_CACHE_TTL=0
export SHIPGLOWS_REGISTRY_LOCK_ATTEMPTS=2
export SHIPGLOWS_REGISTRY_LOCK_INTERVAL=0.01

FAKE_BIN="$TEST_ROOT/bin"
mkdir -p "$FAKE_BIN" "$SHIPGLOWS_STATE_DIR" \
    "$SHIPGLOWS_PROJECTS_DIR/direct/.flox" \
    "$SHIPGLOWS_PROJECTS_DIR/gocharbon/.flox" \
    "$SHIPGLOWS_PROJECTS_DIR/gocharbon/site" \
    "$SHIPGLOWS_PROJECTS_DIR/gocharbon/app_quiz/.flox" \
    "$SHIPGLOWS_PROJECTS_DIR/ambiguous/.flox" \
    "$SHIPGLOWS_PROJECTS_DIR/ambiguous/site" \
    "$SHIPGLOWS_PROJECTS_DIR/ambiguous/worker"

cat > "$FAKE_BIN/pm2" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$FAKE_BIN/pm2"
export PATH="$FAKE_BIN:$PATH"

for app in \
    "$SHIPGLOWS_PROJECTS_DIR/direct" \
    "$SHIPGLOWS_PROJECTS_DIR/gocharbon/site" \
    "$SHIPGLOWS_PROJECTS_DIR/gocharbon/app_quiz" \
    "$SHIPGLOWS_PROJECTS_DIR/ambiguous/site" \
    "$SHIPGLOWS_PROJECTS_DIR/ambiguous/worker"; do
    cat > "$app/package.json" <<'EOF'
{"scripts":{"dev":"vite"},"devDependencies":{"vite":"latest"}}
EOF
done

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

direct_root="$SHIPGLOWS_PROJECTS_DIR/direct"
gocharbon_root="$SHIPGLOWS_PROJECTS_DIR/gocharbon"
gocharbon_site="$gocharbon_root/site"
quiz_root="$gocharbon_root/app_quiz"
ambiguous_root="$SHIPGLOWS_PROJECTS_DIR/ambiguous"

launch_path=""
resolve_flox_launch_path_into launch_path "$direct_root"
assert_eq "$direct_root" "$launch_path" "direct Flox application"

launch_path=""
resolve_flox_launch_path_into launch_path "$gocharbon_root"
assert_eq "$gocharbon_site" "$launch_path" "nested application under parent Flox root"

launch_path=""
resolve_flox_launch_path_into launch_path "$quiz_root"
assert_eq "$quiz_root" "$launch_path" "nested Flox environment remains independent"

set +e
resolve_flox_launch_path_into launch_path "$ambiguous_root" >/dev/null 2>&1
ambiguous_rc=$?
set -e
assert_eq "2" "$ambiguous_rc" "ambiguous environment is rejected"

scan_output="$(scan_flox_projects)"
assert_eq "3" "$(printf '%s\n' "$scan_output" | grep -c .)" "only unambiguous environments are discovered"
printf '%s\n' "$scan_output" | grep -Fqx "direct|$direct_root|$direct_root" \
    || fail "direct environment record missing"
printf '%s\n' "$scan_output" | grep -Fqx "gocharbon_site|$gocharbon_root|$gocharbon_site" \
    || fail "GoCharbon environment/launch mapping missing"
printf '%s\n' "$scan_output" | grep -Fqx "app_quiz|$quiz_root|$quiz_root" \
    || fail "nested Flox boundary record missing"
! printf '%s\n' "$scan_output" | grep -Fq "$ambiguous_root" \
    || fail "ambiguous environment must not enter discovery"

# A legacy four-field registry is valid as last-known-good state but is forced
# through one migration to the five-field environment/launch schema.
printf '%s\n' "gocharbon|online|3002|$gocharbon_root" > "$SHIPGLOWS_REGISTRY"
chmod 600 "$SHIPGLOWS_REGISTRY"
registry_is_valid "$SHIPGLOWS_REGISTRY" || fail "legacy registry should remain readable"
if registry_is_current "$SHIPGLOWS_REGISTRY"; then
    fail "legacy registry must require migration"
fi

registry_sync || fail "legacy registry migration"
grep -Fqx "gocharbon_site|online|3002|$gocharbon_root|$gocharbon_site" "$SHIPGLOWS_REGISTRY" \
    || fail "migration must preserve status and port by environment root"
registry_is_current "$SHIPGLOWS_REGISTRY" || fail "migrated registry uses current schema"

migrated_once="$(cat "$SHIPGLOWS_REGISTRY")"
registry_sync || fail "idempotent registry refresh"
assert_eq "$migrated_once" "$(cat "$SHIPGLOWS_REGISTRY")" "registry migration is idempotent"

resolved_root=""
resolved_launch=""
resolve_project_paths_into resolved_root resolved_launch "gocharbon_site"
assert_eq "$gocharbon_root" "$resolved_root" "name resolves environment root"
assert_eq "$gocharbon_site" "$resolved_launch" "name resolves launch path"
resolve_project_paths_into resolved_root resolved_launch "$gocharbon_site"
assert_eq "$gocharbon_root" "$resolved_root" "launch path is a supported identifier"

# A root-derived PM2 identity is accepted only when its recorded cwd is the
# exact Flox environment root. This provides a bounded live-process migration.
pm2_app_exists_by_name() { [ "$1" = "gocharbon" ]; }
pm2_app_data_load() {
    if [ "$2" = "gocharbon" ] && [ "$3" = "cwd" ]; then
        printf -v "$1" '%s' "$gocharbon_root"
    else
        printf -v "$1" '%s' ''
    fi
}
resolved_pm2_name=""
resolve_environment_pm2_name_into resolved_pm2_name "$gocharbon_root" "$gocharbon_site"
assert_eq "gocharbon" "$resolved_pm2_name" "legacy PM2 identity matches exact environment cwd"

pm2_app_data_load() { printf -v "$1" '%s' "$SHIPGLOWS_PROJECTS_DIR/unrelated"; }
resolved_pm2_name=""
resolve_environment_pm2_name_into resolved_pm2_name "$gocharbon_root" "$gocharbon_site"
assert_eq "gocharbon_site" "$resolved_pm2_name" "unrelated PM2 cwd is never migrated"

echo "Flox environment boundary regressions passed"
