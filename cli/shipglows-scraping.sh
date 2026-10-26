#!/usr/bin/env bash
set -euo pipefail

SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$(dirname "${BASH_SOURCE[0]}")/python-runtime.sh"
if ! shipglows_python3_ready; then
    shipglows_python3_diagnose "shipglows-scraping"
    exit 2
fi
exec python3 "$SHIPGLOWS_ROOT/tools/shipglows_scraping.py" "$@"
