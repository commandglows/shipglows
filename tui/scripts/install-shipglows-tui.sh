#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TUI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="${HOME}/.local/bin"
COMMAND_PATH="$BIN_DIR/shipglows-tui"

if [ ! -f "$TUI_DIR/package.json" ]; then
  echo "ShipGlows TUI package not found at: $TUI_DIR" >&2
  exit 1
fi

mkdir -p "$BIN_DIR"

find_bun() {
  if command -v bun >/dev/null 2>&1; then
    command -v bun
    return 0
  fi
  if [ -x "$HOME/.bun/bin/bun" ]; then
    printf '%s\n' "$HOME/.bun/bin/bun"
    return 0
  fi
  return 1
}

bun_bin="$(find_bun || true)"
if [ -z "$bun_bin" ]; then
  echo "Bun not found. Installing Bun for the current user..." >&2
  curl -fsSL https://bun.sh/install | bash
  bun_bin="$(find_bun || true)"
fi

if [ -z "$bun_bin" ] || [ ! -x "$bun_bin" ]; then
  echo "Bun install did not expose an executable. Open a new shell or check ~/.bun/bin/bun." >&2
  exit 127
fi

cd "$TUI_DIR"
"$bun_bin" install --frozen-lockfile
mkdir -p node_modules
touch node_modules/.shipglows-tui-install-stamp

cat > "$COMMAND_PATH" <<LAUNCHER
#!/usr/bin/env bash
set -euo pipefail

TUI_DIR="${TUI_DIR}"

if [ -n "\${BUN_BIN:-}" ] && [ -x "\$BUN_BIN" ]; then
  bun_bin="\$BUN_BIN"
elif command -v bun >/dev/null 2>&1; then
  bun_bin="\$(command -v bun)"
elif [ -x "\$HOME/.bun/bin/bun" ]; then
  bun_bin="\$HOME/.bun/bin/bun"
else
  echo "Bun is required. Re-run: ${TUI_DIR}/scripts/install-shipglows-tui.sh" >&2
  exit 127
fi

cd "\$TUI_DIR"
stamp="node_modules/.shipglows-tui-install-stamp"
if [ ! -d node_modules ] || [ ! -f "\$stamp" ] || [ package.json -nt "\$stamp" ] || { [ -f bun.lock ] && [ bun.lock -nt "\$stamp" ]; }; then
  echo "Installing ShipGlows TUI dependencies..." >&2
  "\$bun_bin" install --frozen-lockfile
  mkdir -p node_modules
  touch "\$stamp"
fi

export PATH="\$(dirname "\$bun_bin"):\$PATH"
exec "\$bun_bin" run src/main.ts
LAUNCHER

chmod +x "$COMMAND_PATH"
ln -sf "$COMMAND_PATH" "$BIN_DIR/tui"
ln -sf "$COMMAND_PATH" "$BIN_DIR/shipglows-tui"
ln -sf "$COMMAND_PATH" "$BIN_DIR/sftui"
ln -sf "$COMMAND_PATH" "$BIN_DIR/sg-tui"
ln -sf "$COMMAND_PATH" "$BIN_DIR/sf-tui"
ln -sf "$COMMAND_PATH" "$BIN_DIR/shipglows-tui"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "Note: $BIN_DIR is not in PATH for this shell." >&2
    echo "Add this to your shell profile: export PATH=\"$BIN_DIR:\$PATH\"" >&2
    ;;
esac

echo "ShipGlows TUI command installed:"
echo "  tui"
echo "  shipglows-tui"
echo "  sg-tui"
echo "  sftui"
echo "  sf-tui"
echo "  shipglows-tui"
