#!/bin/bash

# Regression test: the full installer must make Corepack's pnpm shim usable
# before installing global CLIs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/../../cli/install.sh"

grep -Fq 'export PATH="$PNPM_HOME/bin:$PATH"' "$INSTALLER"
grep -Fq 'corepack enable' "$INSTALLER"
grep -Fq 'prepare_pnpm || exit 1' "$INSTALLER"
! grep -Fq 'PNPM_HOME="/usr/local/share/pnpm"' "$INSTALLER"
! grep -Fq 'export PATH="$PNPM_HOME:$PATH"' "$INSTALLER"

echo "PNPM bootstrap regression passed"
