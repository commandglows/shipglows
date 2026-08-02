#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BOOTSTRAP="$REPO_ROOT/install-shipglows.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

passed=0
failed=0

pass() {
  printf 'PASS: %s\n' "$1"
  passed=$((passed + 1))
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  failed=$((failed + 1))
}

assert_contains() {
  local file="$1"
  local expected="$2"
  local label="$3"
  if grep -Fq -- "$expected" "$file"; then
    pass "$label"
  else
    fail "$label (missing: $expected)"
  fi
}

assert_not_contains() {
  local file="$1"
  local rejected="$2"
  local label="$3"
  if grep -Fq -- "$rejected" "$file"; then
    fail "$label (unexpected: $rejected)"
  else
    pass "$label"
  fi
}

make_fixture() {
  local name="$1"
  local fixture="$TEST_ROOT/$name"
  mkdir -p "$fixture/bin" "$fixture/home/shipglows/.git"

  cat > "$fixture/bin/id" <<'SH'
#!/usr/bin/env sh
case "${1:-}" in
  -u) printf '%s\n' "${TEST_UID:-2000}" ;;
  -un) printf '%s\n' "${TEST_USER:-tester}" ;;
  *) printf '%s\n' "${TEST_UID:-2000}" ;;
esac
SH

  cat > "$fixture/bin/git" <<'SH'
#!/usr/bin/env sh
if [ "${TEST_GIT_FAIL_CLONE:-0}" = "1" ]; then
  case " $* " in
    *" clone "*) printf '%s\n' "fatal: Authentication failed" >&2; exit 128 ;;
  esac
fi
exit 0
SH

  cat > "$fixture/bin/curl" <<'SH'
#!/usr/bin/env sh
exit 0
SH

  cat > "$fixture/bin/bash" <<'SH'
#!/usr/bin/env sh
printf 'bash:%s\n' "$*" >> "${TEST_CALLS:?}"
exit 0
SH

  chmod +x "$fixture/bin/id" "$fixture/bin/git" "$fixture/bin/curl" "$fixture/bin/bash"
  printf '%s\n' "$fixture"
}

run_case() {
  local fixture="$1"
  shift
  local output="$fixture/output"
  local calls="$fixture/calls"
  : > "$calls"

  set +e
  env -i \
    PATH="$fixture/bin:/usr/bin:/bin" \
    HOME="$fixture/home" \
    USER="tester" \
    TEST_USER="tester" \
    TEST_CALLS="$calls" \
    SHIPGLOWS_DIR="$fixture/home/shipglows" \
    "$@" \
    /bin/sh "$BOOTSTRAP" > "$output" 2>&1
  CASE_STATUS=$?
  set -e
  CASE_OUTPUT="$output"
  CASE_CALLS="$calls"
}

termux_fixture="$(make_fixture termux)"
run_case "$termux_fixture" TEST_UID=2000 TERMUX_VERSION=0.118 PREFIX=/data/data/com.termux/files/usr
if [ "$CASE_STATUS" -eq 0 ]; then pass "Termux bootstrap exits successfully"; else fail "Termux bootstrap exits successfully"; fi
assert_contains "$CASE_OUTPUT" "Mode d'installation: local" "Termux auto-selects local mode"
assert_contains "$CASE_CALLS" "/local/install.sh" "Termux delegates to local installer"
assert_not_contains "$CASE_OUTPUT" "sudo" "Termux never recommends sudo"

root_fixture="$(make_fixture root)"
run_case "$root_fixture" TEST_UID=0 USER=root TEST_USER=root
if [ "$CASE_STATUS" -eq 0 ]; then pass "Root bootstrap exits successfully"; else fail "Root bootstrap exits successfully"; fi
assert_contains "$CASE_OUTPUT" "Mode d'installation: full" "Root auto-selects full mode"
assert_contains "$CASE_CALLS" "/cli/install.sh" "Root delegates to full installer"

local_fixture="$(make_fixture explicit-local)"
run_case "$local_fixture" TEST_UID=2000 SHIPGLOWS_INSTALL_MODE=local
if [ "$CASE_STATUS" -eq 0 ]; then pass "Explicit local mode works without a TTY"; else fail "Explicit local mode works without a TTY"; fi
assert_contains "$CASE_CALLS" "/local/install.sh" "Explicit local mode delegates correctly"

invalid_fixture="$(make_fixture invalid)"
run_case "$invalid_fixture" TEST_UID=2000 SHIPGLOWS_INSTALL_MODE=unexpected
if [ "$CASE_STATUS" -ne 0 ]; then pass "Invalid mode fails"; else fail "Invalid mode fails"; fi
assert_contains "$CASE_OUTPUT" "local ou full" "Invalid mode lists accepted values"
assert_not_contains "$CASE_CALLS" "install.sh" "Invalid mode performs no delegation"

noninteractive_fixture="$(make_fixture noninteractive)"
run_case "$noninteractive_fixture" TEST_UID=2000 SHIPGLOWS_DISABLE_TTY=1
if [ "$CASE_STATUS" -ne 0 ]; then pass "Ambiguous non-interactive run fails"; else fail "Ambiguous non-interactive run fails"; fi
assert_contains "$CASE_OUTPUT" "SHIPGLOWS_INSTALL_MODE=local sh" "Non-interactive error gives the local command"
assert_contains "$CASE_OUTPUT" "SHIPGLOWS_INSTALL_MODE=full sh" "Non-interactive error gives the full command"

interactive_fixture="$(make_fixture interactive)"
if command -v script >/dev/null 2>&1; then
  interactive_output="$interactive_fixture/output"
  interactive_calls="$interactive_fixture/calls"
  : > "$interactive_calls"
  set +e
  printf '1\n' | script -qec "env -i PATH='$interactive_fixture/bin:/usr/bin:/bin' HOME='$interactive_fixture/home' USER=tester TEST_USER=tester TEST_UID=2000 TEST_CALLS='$interactive_calls' SHIPGLOWS_DIR='$interactive_fixture/home/shipglows' /bin/sh '$BOOTSTRAP'" /dev/null > "$interactive_output" 2>&1
  interactive_status=$?
  set -e
  if [ "$interactive_status" -eq 0 ]; then pass "Interactive local choice exits successfully"; else fail "Interactive local choice exits successfully"; fi
  assert_contains "$interactive_output" "Votre choix [1/2]" "Interactive ambiguity prompts on the terminal"
  assert_contains "$interactive_calls" "/local/install.sh" "Interactive local choice delegates correctly"
else
  pass "Interactive pseudo-terminal test skipped because script(1) is unavailable"
fi

termux_full_fixture="$(make_fixture termux-full)"
run_case "$termux_full_fixture" TEST_UID=2000 TERMUX_VERSION=0.118 PREFIX=/data/data/com.termux/files/usr SHIPGLOWS_INSTALL_MODE=full
if [ "$CASE_STATUS" -ne 0 ]; then pass "Termux rejects full mode"; else fail "Termux rejects full mode"; fi
assert_contains "$CASE_OUTPUT" "Termux" "Termux full-mode error names the platform"
assert_not_contains "$CASE_CALLS" "install.sh" "Rejected Termux full mode performs no delegation"

clone_fixture="$(make_fixture public-clone)"
rm -rf "$clone_fixture/home/shipglows"
run_case "$clone_fixture" TEST_UID=2000 SHIPGLOWS_INSTALL_MODE=local TEST_GIT_FAIL_CLONE=1
if [ "$CASE_STATUS" -ne 0 ]; then pass "Public clone failure propagates"; else fail "Public clone failure propagates"; fi
assert_contains "$CASE_OUTPUT" "dépôt public" "Clone failure explains public repository download failure"
assert_not_contains "$CASE_OUTPUT" "token=" "Clone failure does not print token syntax"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
test "$failed" -eq 0
