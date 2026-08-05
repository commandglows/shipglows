#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

run_config() {
    env -i HOME="$1/home" XDG_CONFIG_HOME="$1/config" PATH="$PATH" SHIPGLOWS_ERROR_TRAPS=false SHIPGLOWS_STRICT_MODE=false bash -c 'source "$1/cli/config.sh" || exit $?; printf "%s|%s|%s\n" "$SHIPGLOWS_PRIVATE_DATA_DIR" "${SHIPGLOWS_PRIVATE_DATA_REPO:-}" "$SHIPGLOWS_PRIVATE_ROOT"' bash "$REPO_ROOT"
}

mkdir -p "$TEST_ROOT/default/home"
default_result="$(run_config "$TEST_ROOT/default")"
[ "$default_result" = "$TEST_ROOT/default/home/.shipglows/private/data||$TEST_ROOT/default/home/.shipglows/private/data" ] || fail "default private path"

mkdir -p "$TEST_ROOT/config/home" "$TEST_ROOT/config/config/shipglows"
CONFIG_FILE="$TEST_ROOT/config/config/shipglows/private-data.env"
printf '%s\n' 'SHIPGLOWS_PRIVATE_DATA_REPO=https://example.invalid/operator/private.git' 'SHIPGLOWS_PRIVATE_DATA_DIR=/srv/operator-private' > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
configured_result="$(run_config "$TEST_ROOT/config")"
[ "$configured_result" = '/srv/operator-private|https://example.invalid/operator/private.git|/srv/operator-private' ] || fail "valid local config"

override_result="$(env -i HOME="$TEST_ROOT/config/home" XDG_CONFIG_HOME="$TEST_ROOT/config/config" PATH="$PATH" SHIPGLOWS_ERROR_TRAPS=false SHIPGLOWS_STRICT_MODE=false SHIPGLOWS_PRIVATE_DATA_REPO='ssh://override/private.git' SHIPGLOWS_PRIVATE_DATA_DIR='/tmp/override-private' bash -c 'source "$1/cli/config.sh" || exit $?; printf "%s|%s\n" "$SHIPGLOWS_PRIVATE_DATA_DIR" "$SHIPGLOWS_PRIVATE_DATA_REPO"' bash "$REPO_ROOT")"
[ "$override_result" = '/tmp/override-private|ssh://override/private.git' ] || fail "environment precedence"

printf '%s\n' 'UNSUPPORTED=$(touch should-not-exist)' > "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"
if run_config "$TEST_ROOT/config" >/dev/null 2>&1; then
    fail "unknown config key accepted"
fi
[ ! -e "$TEST_ROOT/config/home/should-not-exist" ] || fail "config was executed as shell"

printf '%s\n' 'SHIPGLOWS_PRIVATE_DATA_REPO=https://example.invalid/private.git' > "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"
if run_config "$TEST_ROOT/config" >/dev/null 2>&1; then
    fail "insecure permissions accepted"
fi

legacy_result="$(env -i HOME="$TEST_ROOT/default/home" PATH="$PATH" SHIPGLOWS_ERROR_TRAPS=false SHIPGLOWS_STRICT_MODE=false SHIPGLOWS_PRIVATE_ROOT='/tmp/legacy-private' bash -c 'source "$1/cli/config.sh" || exit $?; printf "%s|%s\n" "$SHIPGLOWS_PRIVATE_DATA_DIR" "$SHIPGLOWS_PRIVATE_ROOT"' bash "$REPO_ROOT")"
[ "$legacy_result" = '/tmp/legacy-private|/tmp/legacy-private' ] || fail "legacy compatibility"

printf 'Private-data configuration tests passed.\n'
