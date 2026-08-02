#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false

source "$REPO_ROOT/cli/config.sh"
source "$REPO_ROOT/cli/lib.sh"

trap - ERR 2>/dev/null || true

test_count=0
pass_count=0

assert_ok() {
    local test_name=$1
    shift
    ((test_count++))
    if "$@" >/dev/null 2>&1; then
        echo "✓ $test_name"
        ((pass_count++))
        return 0
    fi
    echo "✗ $test_name"
    return 1
}

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

project_dir="$tmp_root/stale_symlink_project"
real_tasks_project_dir="$tmp_root/real_tasks_project"
clean_project_dir="$tmp_root/clean_project"
external_symlink_project_dir="$tmp_root/external_symlink_project"
external_target="$tmp_root/external-tasks.md"
mkdir -p "$project_dir" "$real_tasks_project_dir" "$clean_project_dir" "$external_symlink_project_dir"

ln -s "/home/claude/shipglows_data/projects/old-project/TASKS.md" "$project_dir/TASKS.md"
echo "# App-owned tasks" > "$real_tasks_project_dir/TASKS.md"
echo "# External tasks" > "$external_target"
ln -s "$external_target" "$external_symlink_project_dir/TASKS.md"

assert_ok "fixture has a broken TASKS.md symlink" test -L "$project_dir/TASKS.md"
assert_ok "fixture symlink target is missing" bash -lc "test ! -e '$project_dir/TASKS.md'"
assert_ok "shipglows_init_project removes stale ShipGlows TASKS.md symlink" shipglows_init_project "stale-symlink-project" "$project_dir"
assert_ok "stale project TASKS.md symlink was removed" test ! -L "$project_dir/TASKS.md"
assert_ok "shipglows_init_project does not create central tracking root" test ! -e "$tmp_root/shipglows_data"
assert_ok "shipglows_init_project does not create project TASKS.md symlink" shipglows_init_project "clean-project" "$clean_project_dir"
assert_ok "clean project has no local TASKS.md" test ! -e "$clean_project_dir/TASKS.md"
assert_ok "clean project still has no central tracking root" test ! -e "$tmp_root/shipglows_data"
assert_ok "shipglows_init_project leaves real project TASKS.md untouched" shipglows_init_project "real-tasks-project" "$real_tasks_project_dir"
assert_ok "real project TASKS.md remains a regular file" test -f "$real_tasks_project_dir/TASKS.md"
assert_ok "real project TASKS.md content is preserved" grep -q "App-owned tasks" "$real_tasks_project_dir/TASKS.md"
assert_ok "shipglows_init_project leaves non-ShipGlows TASKS.md symlink untouched" shipglows_init_project "external-symlink-project" "$external_symlink_project_dir"
assert_ok "external project TASKS.md remains a symlink" test -L "$external_symlink_project_dir/TASKS.md"
assert_ok "external project TASKS.md symlink target is preserved" test "$(readlink "$external_symlink_project_dir/TASKS.md")" = "$external_target"
assert_ok "shipglows_init_project is idempotent" shipglows_init_project "clean-project" "$clean_project_dir"

echo ""
echo "Tests passed: $pass_count/$test_count"
[ "$pass_count" -eq "$test_count" ]
