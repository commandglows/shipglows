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

CODEX_PAYLOAD="$HOME/.local/share/pnpm/global/v11/test/node_modules/@openai/codex/bin/codex.js"
CODEX_WRAPPER="$HOME/.local/share/pnpm/codex"
mkdir -p "$HOME/.local/share/pnpm/store/v3" "$(dirname "$CODEX_PAYLOAD")" "$PNPM_HOME" \
    "$HOME/.cache/custom-pnpm-store/v3" "$HOME/.cache/throwaway"
printf 'keep' > "$HOME/.local/share/pnpm/store/v3/package"
printf 'keep' > "$CODEX_PAYLOAD"
ln -s "${CODEX_PAYLOAD#"$HOME/.local/share/pnpm/"}" "$CODEX_WRAPPER"
printf 'keep' > "$PNPM_HOME/global-bin"
printf 'keep' > "$HOME/.cache/custom-pnpm-store/v3/package"
printf 'remove' > "$HOME/.cache/throwaway/cache-file"

cleanup_disk_aggressive >/dev/null

test -f "$HOME/.local/share/pnpm/store/v3/package"
test -L "$CODEX_WRAPPER"
test -f "$CODEX_PAYLOAD"
test -f "$PNPM_HOME/global-bin"
test -f "$HOME/.cache/custom-pnpm-store/v3/package"
test ! -e "$HOME/.cache/throwaway/cache-file"

cat > "$HOME/bin/ps" <<'EOF'
#!/bin/bash
printf '%s\n' \
    "100 1 42 $USER 10 100 tmux: tmux: server" \
    "101 1 42 $USER 10 100 node node /opt/codex" \
    "102 1 43 $USER 10 100 ranger ranger"
EOF
chmod +x "$HOME/bin/ps"
cleanup_groups="$(aggressive_user_process_groups)"
[[ "$cleanup_groups" == 43\|* ]]
[[ "$cleanup_groups" != *"42|"* ]]

echo "PNPM store protection passed"
