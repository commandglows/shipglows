#!/bin/bash

# Regression tests for framework-aware Node dev command detection.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "$TMP_ROOT"' EXIT

export SHIPFLOW_ERROR_TRAPS=false
export SHIPFLOW_STRICT_MODE=false

source "$REPO_ROOT/cli/config.sh"
source "$REPO_ROOT/cli/lib.sh"
trap - ERR 2>/dev/null || true

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

assert_eq() {
    local expected=$1
    local actual=$2
    local label=$3
    [ "$expected" = "$actual" ] || fail "$label (expected '$expected', got '$actual')"
}

write_package_json() {
    local project_dir=$1
    local contents=$2

    mkdir -p "$project_dir"
    printf '%s\n' "$contents" > "$project_dir/package.json"
}

vue_cli_dir="$TMP_ROOT/vue-cli"
write_package_json "$vue_cli_dir" '{"scripts":{"dev":"vue-cli-service serve"},"dependencies":{"vue":"3.5.0"},"devDependencies":{"@vue/cli-service":"5.0.8"}}'
touch "$vue_cli_dir/pnpm-lock.yaml"
assert_eq 'pnpm exec vue-cli-service serve --port $PORT --host 0.0.0.0' "$(detect_dev_command "$vue_cli_dir" 3010)" "pnpm Vue CLI uses its local binary with port and host"

vue_vite_dir="$TMP_ROOT/vue-vite"
write_package_json "$vue_vite_dir" '{"scripts":{"dev":"vite"},"dependencies":{"vue":"3.5.0"},"devDependencies":{"vite":"6.0.0"}}'
touch "$vue_vite_dir/pnpm-lock.yaml"
assert_eq 'pnpm exec vite --port $PORT --host' "$(detect_dev_command "$vue_vite_dir" 3011)" "Vue on Vite keeps the Vite command"

nuxt_dir="$TMP_ROOT/nuxt"
write_package_json "$nuxt_dir" '{"scripts":{"dev":"nuxt dev"},"dependencies":{"nuxt":"4.0.0","vite":"6.0.0"}}'
touch "$nuxt_dir/pnpm-lock.yaml"
assert_eq 'pnpm exec nuxt dev --port $PORT' "$(detect_dev_command "$nuxt_dir" 3012)" "Nuxt takes precedence over its Vite dependency"

generic_dir="$TMP_ROOT/generic"
write_package_json "$generic_dir" '{"scripts":{"dev":"vite --host 0.0.0.0"}}'
touch "$generic_dir/pnpm-lock.yaml"
assert_eq 'pnpm dev' "$(detect_dev_command "$generic_dir" 3013)" "script text does not impersonate a framework dependency"

echo "Project command detection passed"
