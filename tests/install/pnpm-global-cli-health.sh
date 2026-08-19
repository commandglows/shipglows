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
eval "$(extract_function managed_pnpm_cli_path)"
eval "$(extract_function managed_pnpm_cli_works)"
eval "$(extract_function install_managed_pnpm_cli)"
eval "$(extract_function expose_pnpm_global_cli)"

error() {
    printf '%s\n' "$*" >&2
}

SHIPGLOWS_SYSTEM_PNPM_HOME="$TEST_ROOT/system-pnpm"
SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR="$SHIPGLOWS_SYSTEM_PNPM_HOME/global"
SHIPGLOWS_SYSTEM_BIN_DIR="$TEST_ROOT/bin"
PNPM_HOME="$SHIPGLOWS_SYSTEM_PNPM_HOME"
mkdir -p "$SHIPGLOWS_SYSTEM_PNPM_HOME" "$SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR" \
    "$SHIPGLOWS_SYSTEM_BIN_DIR" "$TEST_ROOT/legacy-bin"

cat > "$TEST_ROOT/broken" <<'BROKEN'
#!/bin/sh
exit 23
BROKEN
chmod 755 "$TEST_ROOT/broken"

if cli_command_works "$TEST_ROOT/broken" --version; then
    echo "A present but failing CLI must not pass the health check" >&2
    exit 1
fi

cat > "$TEST_ROOT/legacy-bin/demo" <<'LEGACY'
#!/bin/sh
[ "${1:-}" = "--version" ] || exit 24
printf '%s\n' '9.9.9-legacy'
LEGACY
chmod 755 "$TEST_ROOT/legacy-bin/demo"
PATH="$TEST_ROOT/legacy-bin:$PATH"

cli_command_works demo --version
if managed_pnpm_cli_works demo --version; then
    echo "A legacy CLI outside the managed prefix must not suppress migration" >&2
    exit 1
fi

pnpm() {
    printf '%s\n' "$*" > "$TEST_ROOT/pnpm-args"
    cat > "$SHIPGLOWS_SYSTEM_PNPM_HOME/demo" <<'DEMO'
#!/bin/sh
[ "${1:-}" = "--version" ] || exit 24
printf '%s\n' '1.0.0'
DEMO
    chmod 700 "$SHIPGLOWS_SYSTEM_PNPM_HOME/demo"
}

install_managed_pnpm_cli demo
managed_pnpm_cli_works demo --version

grep -Fq -- "--global-dir $SHIPGLOWS_SYSTEM_PNPM_GLOBAL_DIR" "$TEST_ROOT/pnpm-args"
grep -Fq -- "--global-bin-dir $SHIPGLOWS_SYSTEM_PNPM_HOME" "$TEST_ROOT/pnpm-args"

expose_pnpm_global_cli demo

test -x "$SHIPGLOWS_SYSTEM_BIN_DIR/demo"
test "$("$SHIPGLOWS_SYSTEM_BIN_DIR/demo" --version)" = "1.0.0"
test "$(stat -c '%a' "$SHIPGLOWS_SYSTEM_PNPM_HOME/demo")" = "755"

grep -Fq "exec \"$SHIPGLOWS_SYSTEM_PNPM_HOME/demo\" \"\$@\"" "$SHIPGLOWS_SYSTEM_BIN_DIR/demo"

echo "PNPM global CLI health regression passed"
