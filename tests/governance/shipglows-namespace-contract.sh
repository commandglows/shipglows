#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
OBSOLETE_NAMESPACE="shipglow""z"

if git -C "$ROOT" grep -I -n -i "$OBSOLETE_NAMESPACE"; then
  printf 'Obsolete namespace remains in tracked content.\n' >&2
  exit 1
fi

if find "$ROOT" -path "$ROOT/.git" -prune -o -iname "*$OBSOLETE_NAMESPACE*" -print | grep -q .; then
  printf 'Obsolete namespace remains in a workspace path.\n' >&2
  exit 1
fi

printf 'ShipGlows namespace contract: OK\n'
