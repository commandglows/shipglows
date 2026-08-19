#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
INSTALLER="$ROOT_DIR/cli/install.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

extract_function() {
    local function_name="$1"
    awk -v signature="${function_name}() {" '
        $0 == signature { copying = 1 }
        copying { print }
        copying && /^}$/ { exit }
    ' "$INSTALLER"
}

eval "$(extract_function cli_command_works)"
eval "$(extract_function expose_pnpm_global_cli)"

error() {
    printf '%s\n' "$*" >&2
}

PNPM_HOME="$TEST_ROOT/system-pnpm"
SHIPGLOWS_SYSTEM_BIN_DIR="$TEST_ROOT/bin"
mkdir -p "$PNPM_HOME" "$SHIPGLOWS_SYSTEM_BIN_DIR"

cat > "$TEST_ROOT/broken" <<'BROKEN'
#!/bin/sh
exit 23
BROKEN
chmod 755 "$TEST_ROOT/broken"

if cli_command_works "$TEST_ROOT/broken" --version; then
    echo "A present but failing CLI must not pass the health check" >&2
    exit 1
fi

cat > "$PNPM_HOME/demo" <<'DEMO'
#!/bin/sh
[ "${1:-}" = "--version" ] || exit 24
printf '%s\n' '1.0.0'
DEMO
chmod 700 "$PNPM_HOME/demo"

expose_pnpm_global_cli demo

test -x "$SHIPGLOWS_SYSTEM_BIN_DIR/demo"
test "$("$SHIPGLOWS_SYSTEM_BIN_DIR/demo" --version)" = "1.0.0"
test "$(stat -c '%a' "$PNPM_HOME/demo")" = "755"

grep -Fq "exec \"$PNPM_HOME/demo\" \"\$@\"" "$SHIPGLOWS_SYSTEM_BIN_DIR/demo"

echo "PNPM global CLI health regression passed"
