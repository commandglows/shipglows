#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
INSTALLER="$ROOT_DIR/cli/install.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

extract_function() {
    local function_name="$1"
    awk -v function_name="$function_name" '
        $0 ~ "^" function_name "\\(\\)" { capture=1 }
        capture { print }
        capture && /^}$/ { exit }
    ' "$INSTALLER"
}

grep -Fq 'SHIPGLOWS_INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"' "$INSTALLER"
grep -Fq "alias shipglows='/usr/local/bin/shipglows'" "$INSTALLER"
grep -Fq "alias sg='/usr/local/bin/sg'" "$INSTALLER"
grep -Fq 'write_shipglows_command_wrapper shipglows "$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh"' "$INSTALLER"
grep -Fq 'write_shipglows_command_wrapper sg "$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh"' "$INSTALLER"
grep -Fq 'require_supported_linux_distribution || exit 1' "$INSTALLER"
grep -Fq 'Installation incomplète' "$INSTALLER"

if grep -Fq 'ln -sf "$shipglows_target" "$bin_dir/shipglows"' "$INSTALLER"; then
    echo "shipglows must be a real wrapper, not a symlink" >&2
    exit 1
fi

if [ "$(grep -Fc "export SHIPGLOWS_ROOT='\$SHIPGLOWS_INSTALL_ROOT'" "$INSTALLER")" -ne 1 ]; then
    echo "SHIPGLOWS_ROOT must be written exactly once" >&2
    exit 1
fi

eval "$(extract_function write_shipglows_command_wrapper)"
SHIPGLOWS_SYSTEM_BIN_DIR="$TEST_ROOT/bin"
mkdir -p "$SHIPGLOWS_SYSTEM_BIN_DIR"
printf '%s\n' 'legacy-content-must-survive' > "$TEST_ROOT/legacy-target"
ln -s "$TEST_ROOT/legacy-target" "$SHIPGLOWS_SYSTEM_BIN_DIR/sg"
write_shipglows_command_wrapper sg /opt/shipglows/cli/shipglows.sh

if [ -L "$SHIPGLOWS_SYSTEM_BIN_DIR/sg" ] || [ ! -x "$SHIPGLOWS_SYSTEM_BIN_DIR/sg" ]; then
    echo "sg wrapper must atomically replace a legacy symlink" >&2
    exit 1
fi
grep -Fq 'exec "/opt/shipglows/cli/shipglows.sh" "$@"' "$SHIPGLOWS_SYSTEM_BIN_DIR/sg"
grep -Fxq 'legacy-content-must-survive' "$TEST_ROOT/legacy-target"

eval "$(extract_function require_supported_linux_distribution)"
info() { :; }
error() { :; }

printf '%s\n' 'ID=ubuntu' > "$TEST_ROOT/os-release"
SHIPGLOWS_OS_RELEASE_FILE="$TEST_ROOT/os-release"
require_supported_linux_distribution

printf '%s\n' 'ID=linuxmint' 'ID_LIKE="ubuntu debian"' > "$TEST_ROOT/os-release"
require_supported_linux_distribution

printf '%s\n' 'ID=fedora' 'ID_LIKE="rhel fedora"' > "$TEST_ROOT/os-release"
if require_supported_linux_distribution; then
    echo "Unsupported Linux distributions must be rejected" >&2
    exit 1
fi

echo "Full installer path regression passed"
