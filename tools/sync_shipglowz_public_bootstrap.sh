#!/usr/bin/env bash

set -euo pipefail

SHIPGLOWZ_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE_FILE="$SHIPGLOWZ_ROOT/install-shipglowz.sh"
POWERSHELL_SOURCE_FILE="$SHIPGLOWZ_ROOT/install-shipglowz.ps1"
WINGLOWZ_ROOT="${WINGLOWZ_ROOT:-/home/claude/winglowz}"
MODE=""

usage() {
  cat <<'EOF'
Usage: sync_shipglowz_public_bootstrap.sh (--check|--write) [--winglowz-root PATH]

Synchronize the canonical ShipGlowz bootstrap with WinGlowz's generated public asset.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --check|--write)
      if [ -n "$MODE" ]; then
        printf 'Choose exactly one mode: --check or --write.\n' >&2
        exit 2
      fi
      MODE="$1"
      ;;
    --winglowz-root)
      shift
      if [ "$#" -eq 0 ]; then
        printf 'Missing path after --winglowz-root.\n' >&2
        exit 2
      fi
      WINGLOWZ_ROOT="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [ -z "$MODE" ]; then
  usage >&2
  exit 2
fi

TARGET_DIR="$WINGLOWZ_ROOT/winglowz_site/src/generated"
TARGET_FILE="$TARGET_DIR/shipglowz-installer.sh"
POWERSHELL_TARGET_FILE="$TARGET_DIR/shipglowz-installer.ps1"

if [ ! -f "$SOURCE_FILE" ]; then
  printf 'Canonical bootstrap missing: %s\n' "$SOURCE_FILE" >&2
  exit 1
fi

if [ ! -f "$POWERSHELL_SOURCE_FILE" ]; then
  printf 'Canonical PowerShell bootstrap missing: %s\n' "$POWERSHELL_SOURCE_FILE" >&2
  exit 1
fi

case "$MODE" in
  --check)
    if [ ! -f "$TARGET_FILE" ]; then
      printf 'Generated public bootstrap missing: %s\n' "$TARGET_FILE" >&2
      printf 'Run this command with --write, then commit both repositories intentionally.\n' >&2
      exit 1
    fi
    if ! cmp -s "$SOURCE_FILE" "$TARGET_FILE"; then
      printf 'Bootstrap drift detected between:\n  %s\n  %s\n' "$SOURCE_FILE" "$TARGET_FILE" >&2
      printf 'Run this command with --write, review the WinGlowz diff, then rerun --check.\n' >&2
      exit 1
    fi
    if [ ! -f "$POWERSHELL_TARGET_FILE" ] || ! cmp -s "$POWERSHELL_SOURCE_FILE" "$POWERSHELL_TARGET_FILE"; then
      printf 'PowerShell bootstrap drift detected between:\n  %s\n  %s\n' "$POWERSHELL_SOURCE_FILE" "$POWERSHELL_TARGET_FILE" >&2
      printf 'Run this command with --write, review the WinGlowz diff, then rerun --check.\n' >&2
      exit 1
    fi
    printf 'ShipGlowz public bootstrap parity: OK\n'
    ;;
  --write)
    mkdir -p "$TARGET_DIR"
    cp "$SOURCE_FILE" "$TARGET_FILE"
    cp "$POWERSHELL_SOURCE_FILE" "$POWERSHELL_TARGET_FILE"
    chmod 0644 "$TARGET_FILE"
    chmod 0644 "$POWERSHELL_TARGET_FILE"
    printf 'Synchronized public bootstrap: %s\n' "$TARGET_FILE"
    ;;
esac
