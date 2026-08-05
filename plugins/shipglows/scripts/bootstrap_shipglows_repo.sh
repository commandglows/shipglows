#!/usr/bin/env bash
set -euo pipefail

repo_url="${SHIPGLOWS_REPO_URL:-https://github.com/commandglows/shipglows.git}"
target_dir="${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}"
ref="${SHIPGLOWS_REF:-main}"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat <<'USAGE'
Usage: bootstrap_shipglows_repo.sh [ref]

Clones or updates a sparse ShipGlows source checkout for skills.

Environment:
  SHIPGLOWS_REPO_URL  Repository URL. Defaults to https://github.com/commandglows/shipglows.git
  SHIPGLOWS_ROOT      Target directory. Defaults to $HOME/.shipglows/source
  SHIPGLOWS_REF       Branch, tag, or commit. Defaults to main
USAGE
  exit 0
fi

if [[ $# -gt 0 ]]; then
  ref="$1"
fi

if [[ -e "$target_dir" && ! -d "$target_dir/.git" ]]; then
  echo "Refusing to write into non-Git path: $target_dir" >&2
  echo "Set SHIPGLOWS_ROOT to an empty path or an existing ShipGlows Git checkout." >&2
  exit 2
fi

configure_sparse_checkout() {
  local repo_dir="$1"
  git -C "$repo_dir" sparse-checkout init --cone
  git -C "$repo_dir" sparse-checkout set \
    skills \
    templates \
    tools \
    shipglows_data \
    local
}

if [[ -d "$target_dir/.git" ]]; then
  git -C "$target_dir" fetch --tags origin
  configure_sparse_checkout "$target_dir"
  git -C "$target_dir" checkout "$ref"
  git -C "$target_dir" pull --ff-only origin "$ref" || true
else
  mkdir -p "$(dirname "$target_dir")"
  git clone --filter=blob:none --sparse --branch "$ref" "$repo_url" "$target_dir"
  configure_sparse_checkout "$target_dir"
fi

echo "ShipGlows source ready: $target_dir"
