#!/bin/bash

# Regression test: the full installer must make Corepack's pnpm shim usable
# before installing global CLIs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/../../cli/install.sh"

grep -Fq 'export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH"' "$INSTALLER"
grep -Fq 'corepack enable' "$INSTALLER"
grep -Fq 'prepare_pnpm || exit 1' "$INSTALLER"
grep -Fq 'SHIPGLOWS_SYSTEM_PNPM_HOME="${SHIPGLOWS_SYSTEM_PNPM_HOME:-/usr/local/lib/shipglows/pnpm}"' "$INSTALLER"
grep -Fq 'expose_pnpm_global_cli pm2 || exit 1' "$INSTALLER"
grep -Fq 'exec "$cli_path" "\$@"' "$INSTALLER"
! grep -Fq 'PNPM_HOME="/usr/local/share/pnpm"' "$INSTALLER"
grep -Fq 'cli_command_works pm2 --version' "$INSTALLER"
grep -Fq 'cli_command_works vercel --version' "$INSTALLER"
grep -Fq 'pnpm add -g --allow-build=@anthropic-ai/claude-code @anthropic-ai/claude-code' "$INSTALLER"
grep -Fq 'pnpm add -g --allow-build=opencode-ai opencode-ai' "$INSTALLER"
grep -Fq 'pnpm add -g --allow-build=@kilocode/cli @kilocode/cli' "$INSTALLER"

echo "PNPM bootstrap regression passed"
