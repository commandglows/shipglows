#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shipglows-termux-tunnel-test.XXXXXX")"
trap 'test -f "$TEST_ROOT/autossh.pid" && kill "$(<"$TEST_ROOT/autossh.pid")" 2>/dev/null || true; rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/home"
printf '%s\n' \
    '#!/bin/sh' \
    'printf '\''%s\n'\'' "$@" > "$SHIPGLOWS_AUTOSSH_CAPTURE"' \
    'printf '\''%s\n'\'' "$$" > "$SHIPGLOWS_AUTOSSH_PID"' \
    'sleep 30' > "$TEST_ROOT/bin/autossh"
chmod 700 "$TEST_ROOT/bin/autossh"

HOME="$TEST_ROOT/home"
TERMUX_VERSION="0.118"
PREFIX="/data/data/com.termux/files/usr"
PATH="$TEST_ROOT/bin:$PATH"
export HOME TERMUX_VERSION PREFIX PATH
export SHIPGLOWS_AUTOSSH_CAPTURE="$TEST_ROOT/autossh.args"
export SHIPGLOWS_AUTOSSH_PID="$TEST_ROOT/autossh.pid"

# shellcheck source=../../local/local.sh
source "$REPO_ROOT/local/local.sh"

REMOTE_HOST="root@127.0.0.1"
SSH_AUTH_METHOD="key"
SSH_IDENTITY_FILE=""
local_screen_header() { :; }
get_tunnel_pids() { :; }
get_active_ports() { printf '%s\n' '48322:termux-proof'; }
ensure_reusable_ssh_session() { return 0; }
ssh_tunnel_args() { :; }
verify_tunnels_ready() { :; }
print_remote_app_warmup_hint() { :; }

start_tunnels >/dev/null
test -s "$SHIPGLOWS_AUTOSSH_PID"
test -s "$SHIPGLOWS_AUTOSSH_CAPTURE"
if grep -qx -- '-f' "$SHIPGLOWS_AUTOSSH_CAPTURE"; then
    echo 'FAIL: Termux autossh must not receive -f' >&2
    exit 1
fi
grep -qx -- '-M' "$SHIPGLOWS_AUTOSSH_CAPTURE"
grep -qx -- '0' "$SHIPGLOWS_AUTOSSH_CAPTURE"
grep -qx -- '-N' "$SHIPGLOWS_AUTOSSH_CAPTURE"
echo 'Termux autossh launch test passed'
