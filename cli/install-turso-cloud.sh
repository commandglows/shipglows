#!/usr/bin/env bash
set -euo pipefail

TURSO_VERSION="1.0.32"
TURSO_X86_64_SHA256="c35acbcad8e2e7a32580fe380adc4658d3032ddc56d25396b9b123aa4a704107"
TURSO_ARM64_SHA256="672f29e8f77b4c30a5f31c04fe0d5636d29fb1bb5be1137c40234bb2e76c2150"
TURSO_RELEASE_BASE="https://github.com/tursodatabase/turso-cli/releases/download/v${TURSO_VERSION}"

die() {
  printf 'ShipGlows Turso install failed: %s\n' "$1" >&2
  exit 1
}

command -v curl >/dev/null 2>&1 || die 'curl is required.'
command -v tar >/dev/null 2>&1 || die 'tar is required.'
command -v sha256sum >/dev/null 2>&1 || die 'sha256sum is required.'
command -v install >/dev/null 2>&1 || die 'install is required.'

case "$(uname -m)" in
  x86_64|amd64)
    archive_name='turso-cli_Linux_x86_64.tar.gz'
    expected_sha256="$TURSO_X86_64_SHA256"
    ;;
  aarch64|arm64)
    archive_name='turso-cli_Linux_arm64.tar.gz'
    expected_sha256="$TURSO_ARM64_SHA256"
    ;;
  *) die "unsupported Linux architecture: $(uname -m)" ;;
esac

destination_dir="${HOME:?HOME is required}/.local/bin"
destination="$destination_dir/turso"

if [[ -x "$destination" ]] && "$destination" --version 2>&1 | grep -Eq "(^|[^0-9])${TURSO_VERSION//./\\.}([^0-9]|$)"; then
  printf 'Turso Cloud CLI %s is already ready at %s.\n' "$TURSO_VERSION" "$destination"
  exit 0
fi

umask 077
temporary_dir="$(mktemp -d "${TMPDIR:-/tmp}/shipglows-turso.XXXXXX")"
destination_candidate=''
cleanup() {
  rm -rf -- "$temporary_dir"
  if [[ -n "$destination_candidate" ]]; then rm -f -- "$destination_candidate"; fi
}
trap cleanup EXIT HUP INT TERM

archive="$temporary_dir/$archive_name"
candidate="$temporary_dir/turso.candidate"
curl --fail --silent --show-error --location \
  --proto '=https' --tlsv1.2 \
  "$TURSO_RELEASE_BASE/$archive_name" \
  --output "$archive"

actual_sha256="$(sha256sum "$archive" | awk '{print $1}')"
[[ "$actual_sha256" == "$expected_sha256" ]] || die "checksum mismatch for $archive_name."

tar -xzf "$archive" -C "$temporary_dir" --no-same-owner --no-same-permissions turso
[[ -f "$temporary_dir/turso" && ! -L "$temporary_dir/turso" ]] || die 'the verified archive did not contain the expected binary.'
install -m 0755 "$temporary_dir/turso" "$candidate"

candidate_version="$($candidate --version 2>&1)" || die 'the downloaded Turso binary did not run.'
printf '%s\n' "$candidate_version" | grep -Eq "(^|[^0-9])${TURSO_VERSION//./\\.}([^0-9]|$)" || die 'the downloaded Turso binary reported an unexpected version.'

if [[ ! -d "$destination_dir" ]]; then
  install -d -m 0700 "$destination_dir"
fi
destination_candidate="$destination_dir/.turso.shipglows.$$"
install -m 0755 "$candidate" "$destination_candidate"
mv -f -- "$destination_candidate" "$destination"
destination_candidate=''
chmod 0755 "$destination"

installed_version="$($destination --version 2>&1)" || die 'the installed Turso binary did not run.'
printf '%s\n' "$installed_version" | grep -Eq "(^|[^0-9])${TURSO_VERSION//./\\.}([^0-9]|$)" || die 'post-install Turso verification failed.'
printf 'Turso Cloud CLI %s installed at %s. Authentication was not started.\n' "$TURSO_VERSION" "$destination"
