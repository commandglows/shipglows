#!/bin/bash
echo "Compatibility launcher: use ./cli/shipglows.sh directly." >&2
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/cli/shipglows.sh" "$@"
