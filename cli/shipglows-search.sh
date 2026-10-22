#!/usr/bin/env bash
set -euo pipefail

SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
exec python3 "$SHIPGLOWS_ROOT/tools/shipglows_search.py" "$@"
