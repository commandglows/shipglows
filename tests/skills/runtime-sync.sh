#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$ROOT_DIR/../.." && pwd)"
HELPER="$REPO_ROOT/tools/shipglows_sync_skills.sh"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

make_skill() {
    local root="$1"
    local name="$2"
    mkdir -p "$root/skills/$name"
    printf -- '---\nname: %s\ndescription: test\n---\n' "$name" > "$root/skills/$name/SKILL.md"
}

assert_link() {
    local path="$1"
    local target="$2"
    test -L "$path"
    test "$(readlink -f "$path")" = "$(readlink -f "$target")"
    test -f "$path/SKILL.md"
}

run_helper() {
    "$HELPER" --shipglows-root "$SHIPGLOWS_ROOT_TEST" --target-home "$TARGET_HOME_TEST" "$@"
}

SHIPGLOWS_ROOT_TEST="$TMP_DIR/shipglows"
TARGET_HOME_TEST="$TMP_DIR/home"
mkdir -p "$SHIPGLOWS_ROOT_TEST/skills" "$TARGET_HOME_TEST"
make_skill "$SHIPGLOWS_ROOT_TEST" "001-sg-alpha"
make_skill "$SHIPGLOWS_ROOT_TEST" "002-sg-beta"
make_skill "$SHIPGLOWS_ROOT_TEST" "003-sg-gamma"

if run_helper --check --skill 001-sg-alpha >/tmp/shipglows-sync-check.out 2>&1; then
    echo "expected missing check to fail" >&2
    exit 1
fi
grep -q "missing runtime=claude skill=001-sg-alpha" /tmp/shipglows-sync-check.out
grep -q "missing runtime=codex skill=001-sg-alpha" /tmp/shipglows-sync-check.out
test ! -e "$TARGET_HOME_TEST/.claude/skills/001-sg-alpha"

run_helper --repair --skill 001-sg-alpha >/tmp/shipglows-sync-repair.out
assert_link "$TARGET_HOME_TEST/.claude/skills/001-sg-alpha" "$SHIPGLOWS_ROOT_TEST/skills/001-sg-alpha"
assert_link "$TARGET_HOME_TEST/.codex/skills/001-sg-alpha" "$SHIPGLOWS_ROOT_TEST/skills/001-sg-alpha"
grep -q "summary mode=repair" /tmp/shipglows-sync-repair.out

run_helper --check --skill 001-sg-alpha >/tmp/shipglows-sync-ok.out
grep -q "ok runtime=claude skill=001-sg-alpha" /tmp/shipglows-sync-ok.out
grep -q "ok runtime=codex skill=001-sg-alpha" /tmp/shipglows-sync-ok.out

ln -sfn "$SHIPGLOWS_ROOT_TEST/skills/001-sg-alpha" "$TARGET_HOME_TEST/.codex/skills/002-sg-beta"
if run_helper --check --skill 002-sg-beta --runtime codex >/tmp/shipglows-sync-stale.out 2>&1; then
    echo "expected stale symlink check to fail" >&2
    exit 1
fi
grep -q "stale-or-broken-symlink" /tmp/shipglows-sync-stale.out
run_helper --repair --skill 002-sg-beta --runtime codex >/tmp/shipglows-sync-stale-repair.out
assert_link "$TARGET_HOME_TEST/.codex/skills/002-sg-beta" "$SHIPGLOWS_ROOT_TEST/skills/002-sg-beta"
test ! -e "$TARGET_HOME_TEST/.claude/skills/002-sg-beta"

mkdir -p "$TARGET_HOME_TEST/.claude/skills/003-sg-gamma"
if run_helper --repair --skill 003-sg-gamma --runtime claude >/tmp/shipglows-sync-collision.out 2>&1; then
    echo "expected non-symlink collision to fail" >&2
    exit 1
fi
grep -q "non-symlink-existing" /tmp/shipglows-sync-collision.out
test -d "$TARGET_HOME_TEST/.claude/skills/003-sg-gamma"
test ! -L "$TARGET_HOME_TEST/.claude/skills/003-sg-gamma"

run_helper --repair --skill 003-sg-gamma --runtime claude --backup-existing >/tmp/shipglows-sync-backup.out
assert_link "$TARGET_HOME_TEST/.claude/skills/003-sg-gamma" "$SHIPGLOWS_ROOT_TEST/skills/003-sg-gamma"
grep -q "backed-up-existing" /tmp/shipglows-sync-backup.out

if run_helper --check --skill ../bad >/tmp/shipglows-sync-invalid.out 2>&1; then
    echo "expected invalid skill name to fail" >&2
    exit 1
fi
grep -q "invalid skill name" /tmp/shipglows-sync-invalid.out

if run_helper --check --skill sf--bad >/tmp/shipglows-sync-invalid2.out 2>&1; then
    echo "expected invalid double hyphen skill name to fail" >&2
    exit 1
fi
grep -q "invalid skill name" /tmp/shipglows-sync-invalid2.out

run_helper --repair --all --runtime codex >/tmp/shipglows-sync-all-codex.out
assert_link "$TARGET_HOME_TEST/.codex/skills/001-sg-alpha" "$SHIPGLOWS_ROOT_TEST/skills/001-sg-alpha"
assert_link "$TARGET_HOME_TEST/.codex/skills/002-sg-beta" "$SHIPGLOWS_ROOT_TEST/skills/002-sg-beta"
assert_link "$TARGET_HOME_TEST/.codex/skills/003-sg-gamma" "$SHIPGLOWS_ROOT_TEST/skills/003-sg-gamma"

if find "$HOME/.codex/skills" -maxdepth 0 >/dev/null 2>&1; then
    test ! -e "$HOME/.codex/skills/001-sg-alpha-test-should-not-exist"
fi

echo "test_skill_runtime_sync: passed"
