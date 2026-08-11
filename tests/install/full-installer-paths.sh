#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
INSTALLER="$ROOT_DIR/cli/install.sh"

grep -Fq 'SHIPGLOWS_INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"' "$INSTALLER"
grep -Fq "alias shipglows='/usr/local/bin/shipglows'" "$INSTALLER"
grep -Fq "alias sg='/usr/local/bin/sg'" "$INSTALLER"
grep -Fq 'exec "$SHIPGLOWS_INSTALL_ROOT/cli/shipglows.sh" "\$@"' "$INSTALLER"

if grep -Fq 'ln -sf "$shipglows_target" "$bin_dir/shipglows"' "$INSTALLER"; then
    echo "shipglows must be a real wrapper, not a symlink" >&2
    exit 1
fi

if [ "$(grep -Fc "export SHIPGLOWS_ROOT='\$SHIPGLOWS_INSTALL_ROOT'" "$INSTALLER")" -ne 1 ]; then
    echo "SHIPGLOWS_ROOT must be written exactly once" >&2
    exit 1
fi

echo "Full installer path regression passed"
