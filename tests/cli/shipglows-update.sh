#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENTRY="$ROOT/cli/shipglows.sh"
UPDATE="$ROOT/cli/shipglows_update.sh"

bash -n "$ENTRY" "$UPDATE"
grep -Fq 'shipglows_update.sh' "$ENTRY"
grep -Fq 'status|--check|check)' "$UPDATE"
grep -Fq 'SHIPGLOWS_BRANCH="$branch"' "$UPDATE"
grep -Fq 'uncommitted changes' "$UPDATE"
grep -Fq 'skills=%s' "$UPDATE"
grep -Fq '[ -e "$UPDATE_ROOT/.git" ]' "$UPDATE"

echo 'ShipGlows Unix update-command tests passed.'
