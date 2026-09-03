#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENTRY="$ROOT/cli/shipglows.sh"
UPDATE="$ROOT/cli/shipglows_update.sh"

bash -n "$ENTRY" "$UPDATE"
grep -Fq 'shipglows_update.sh' "$ENTRY"
grep -Fq '"${1:-}" = "update"' "$ENTRY"
grep -Fq 'shipglows: choose an explicit update target:' "$ENTRY"
if output="$(bash "$ENTRY" update 2>&1)"; then
    echo 'Bare shipglows update unexpectedly succeeded.' >&2
    exit 1
fi
grep -Fq 'shipglows update runtime' <<<"$output"
if output="$(bash "$ENTRY" update unknown 2>&1)"; then
    echo 'Unknown shipglows update target unexpectedly succeeded.' >&2
    exit 1
fi
grep -Fq 'expected: shipglows update <runtime|status>' <<<"$output"
grep -Fq 'status|--check|check)' "$UPDATE"
grep -Fq 'SHIPGLOWS_BRANCH="$branch"' "$UPDATE"
grep -Fq 'uncommitted changes' "$UPDATE"
grep -Fq 'skills=%s' "$UPDATE"
grep -Fq '[ -e "$UPDATE_ROOT/.git" ]' "$UPDATE"

echo 'ShipGlows Unix update-command tests passed.'
