#!/bin/bash

# Regression test: aggressive cleanup must keep PNPM data intact.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_HOME="$(mktemp -d)"

cleanup() {
    rm -rf -- "$TEST_HOME"
}
trap cleanup EXIT

export HOME="$TEST_HOME"
export SHIPGLOWS_ERROR_TRAPS=false
export SHIPGLOWS_STRICT_MODE=false
export PNPM_HOME="$HOME/custom-pnpm-home"
mkdir -p "$HOME/bin"
cat > "$HOME/bin/pnpm" <<'EOF'
#!/bin/bash
if [ "$1" = "store" ] && [ "$2" = "path" ]; then
    printf '%s\n' "$HOME/.cache/custom-pnpm-store"
fi
EOF
chmod +x "$HOME/bin/pnpm"
export PATH="$HOME/bin:$PATH"
source "$REPO_ROOT/cli/lib.sh"

# A completed cleanup can explicitly leave a grouped submenu for the root menu.
ui_return_to_main_menu
ui_should_return_to_main_menu
! ui_should_return_to_main_menu

mkdir -p "$HOME/.local/share/pnpm/store/v3" "$PNPM_HOME" \
    "$HOME/.cache/custom-pnpm-store/v3" "$HOME/.cache/throwaway"
printf 'keep' > "$HOME/.local/share/pnpm/store/v3/package"
printf 'keep' > "$PNPM_HOME/global-bin"
printf 'keep' > "$HOME/.cache/custom-pnpm-store/v3/package"
printf 'remove' > "$HOME/.cache/throwaway/cache-file"

cleanup_disk_aggressive >/dev/null

test -f "$HOME/.local/share/pnpm/store/v3/package"
test -f "$PNPM_HOME/global-bin"
test -f "$HOME/.cache/custom-pnpm-store/v3/package"
test ! -e "$HOME/.cache/throwaway/cache-file"

echo "PNPM store protection passed"
