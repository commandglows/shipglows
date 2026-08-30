#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
INSTALLER="$ROOT/cli/install-turso-cloud.sh"
EXPECTED_X64='c35acbcad8e2e7a32580fe380adc4658d3032ddc56d25396b9b123aa4a704107'

fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }
temp="$(mktemp -d)"
trap 'rm -rf -- "$temp"' EXIT
mock_bin="$temp/mock-bin"
home="$temp/home"
mkdir -p "$mock_bin" "$home"

cat >"$mock_bin/uname" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "${SG_TEST_ARCH:-x86_64}"
EOF
cat >"$mock_bin/curl" <<'EOF'
#!/usr/bin/env bash
output=''
while (($#)); do
  if [[ "$1" == '--output' ]]; then output="$2"; shift 2; else shift; fi
done
printf 'fixture archive' >"$output"
EOF
cat >"$mock_bin/sha256sum" <<EOF
#!/usr/bin/env bash
printf '%s  %s\n' "\${SG_TEST_SHA:-$EXPECTED_X64}" "\$1"
EOF
cat >"$mock_bin/tar" <<'EOF'
#!/usr/bin/env bash
destination=''
while (($#)); do
  if [[ "$1" == '-C' ]]; then destination="$2"; shift 2; else shift; fi
done
cat >"$destination/turso" <<'BIN'
#!/usr/bin/env bash
printf 'turso version %s\n' "${SG_TEST_VERSION:-1.0.32}"
BIN
chmod +x "$destination/turso"
EOF
cat >"$mock_bin/install" <<'EOF'
#!/usr/bin/env bash
if [[ "$1" == '-d' ]]; then
  shift
  [[ "$1" == '-m' ]] && shift 2
  mkdir -p "$1"
else
  [[ "$1" == '-m' ]] && shift 2
  cp "$1" "$2"
  chmod +x "$2"
fi
EOF
chmod +x "$mock_bin/uname" "$mock_bin/curl" "$mock_bin/sha256sum" "$mock_bin/tar" "$mock_bin/install"

PATH="$mock_bin:$PATH" HOME="$home" "$INSTALLER" >"$temp/first.out"
[[ -x "$home/.local/bin/turso" ]] || fail 'verified CLI was not installed in the user scope'
grep -q 'Authentication was not started' "$temp/first.out" || fail 'success did not preserve the authentication boundary'

before="$(sha256sum "$home/.local/bin/turso" | awk '{print $1}')"
PATH="$mock_bin:$PATH" HOME="$home" "$INSTALLER" >"$temp/second.out"
after="$(sha256sum "$home/.local/bin/turso" | awk '{print $1}')"
[[ "$before" == "$after" ]] || fail 'idempotent rerun changed the installed binary'
grep -q 'already ready' "$temp/second.out" || fail 'idempotent rerun did not report readiness'

rm -f "$home/.local/bin/turso"
if PATH="$mock_bin:$PATH" HOME="$home" SG_TEST_SHA='bad' "$INSTALLER" >"$temp/bad-sha.out" 2>&1; then
  fail 'checksum mismatch was accepted'
fi
[[ ! -e "$home/.local/bin/turso" ]] || fail 'checksum failure replaced the destination'
grep -q 'checksum mismatch' "$temp/bad-sha.out" || fail 'checksum failure was not explicit'

if PATH="$mock_bin:$PATH" HOME="$home" SG_TEST_VERSION='9.9.9' "$INSTALLER" >"$temp/bad-version.out" 2>&1; then
  fail 'unexpected binary version was accepted'
fi
[[ ! -e "$home/.local/bin/turso" ]] || fail 'version failure replaced the destination'

PATH="$mock_bin:$PATH" HOME="$home" SG_TEST_ARCH='aarch64' SG_TEST_SHA='672f29e8f77b4c30a5f31c04fe0d5636d29fb1bb5be1137c40234bb2e76c2150' "$INSTALLER" >"$temp/arm.out"
[[ -x "$home/.local/bin/turso" ]] || fail 'arm64 verified fixture was not installed'

! rg -n 'turso[[:space:]]+(auth|db|shell)|/latest/|releases/latest' "$INSTALLER" >/dev/null || fail 'installer contains an auth, database, shell, or latest-release action'
printf 'Turso Cloud installer contracts passed.\n'
