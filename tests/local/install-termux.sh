#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shipglows-termux-install-test.XXXXXX")"
trap 'rm -rf "$TEST_ROOT"' EXIT

BIN_DIR="$TEST_ROOT/bin"
HOME_DIR="$TEST_ROOT/home"
mkdir -p "$BIN_DIR" "$HOME_DIR"

for command_name in dirname grep mkdir chmod cat; do
    command_path="$(command -v "$command_name")"
    ln -s "$command_path" "$BIN_DIR/$command_name"
done

test_count=0
pass_count=0

check() {
    local name="$1"
    shift
    test_count=$((test_count + 1))
    printf 'Test %d: %s ... ' "$test_count" "$name"
    if "$@"; then
        echo "pass"
        pass_count=$((pass_count + 1))
    else
        echo "FAIL"
    fi
}

MISSING_OUTPUT="$TEST_ROOT/missing-autossh.out"
HOME="$HOME_DIR" \
TERMUX_VERSION="0.118" \
PREFIX="/data/data/com.termux/files/usr" \
OSTYPE="linux-android" \
PATH="$BIN_DIR" \
"$BASH" "$REPO_ROOT/local/install.sh" > "$MISSING_OUTPUT" 2>&1
missing_status=$?

check "missing autossh stops installation" test "$missing_status" -ne 0
check "Termux is detected explicitly" grep -q "Système détecté: Android / Termux" "$MISSING_OUTPUT"
check "Termux dependency command uses pkg" grep -q "pkg install openssh autossh" "$MISSING_OUTPUT"
check "Termux does not recommend sudo apt" test "$(grep -c "sudo apt" "$MISSING_OUTPUT")" -eq 0

printf '#!/bin/sh\nexit 0\n' > "$BIN_DIR/autossh"
chmod 700 "$BIN_DIR/autossh"
SUCCESS_OUTPUT="$TEST_ROOT/success.out"
HOME="$HOME_DIR" \
TERMUX_VERSION="0.118" \
PREFIX="/data/data/com.termux/files/usr" \
OSTYPE="linux-android" \
PATH="$BIN_DIR" \
SHIPGLOWS_LOCAL_CONFIG_DIR="$HOME_DIR/.shipglows" \
"$BASH" "$REPO_ROOT/local/install.sh" > "$SUCCESS_OUTPUT" 2>&1
success_status=$?

check "Termux installation completes with dependencies" test "$success_status" -eq 0
check "Termux installation reports completion" grep -q "Installation terminée" "$SUCCESS_OUTPUT"
check "urls alias is installed" grep -q "alias urls=" "$HOME_DIR/.bashrc"
check "tunnel alias is installed" grep -q "alias tunnel=" "$HOME_DIR/.bashrc"

echo ""
echo "$pass_count/$test_count tests passed"
[ "$pass_count" -eq "$test_count" ]
