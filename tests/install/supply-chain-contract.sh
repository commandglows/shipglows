#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
INSTALLER="$ROOT_DIR/cli/install.sh"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

extract_function() {
    local function_name="$1"
    awk -v function_name="$function_name" '
        $0 ~ "^" function_name "\\(\\)" { capture=1 }
        capture { print }
        capture && /^}$/ { exit }
    ' "$INSTALLER"
}

for function_name in checked_download verify_sha256 extract_tar_member require_exact_line require_only_exact_lines verify_gpg_primary_fingerprint verify_gpg_key_file run_required resolve_linux_arch; do
    function_body="$(extract_function "$function_name")"
    [ -n "$function_body" ] || fail "missing installer helper: $function_name"
    eval "$function_body"
done

error() { :; }

mkdir -p "$TEST_ROOT/bin"
cat > "$TEST_ROOT/bin/curl" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
destination=""
while [ "$#" -gt 0 ]; do
    if [ "$1" = "--output" ]; then
        destination="$2"
        shift 2
        continue
    fi
    shift
done
[ -n "$destination" ] || exit 2
case "${FAKE_CURL_MODE:-valid}" in
    empty) : > "$destination" ;;
    fail) exit 22 ;;
    *) printf '%s\n' 'verified payload' > "$destination" ;;
esac
EOF
chmod +x "$TEST_ROOT/bin/curl"

cat > "$TEST_ROOT/bin/gpg" <<'EOF'
#!/usr/bin/env bash
case "${FAKE_GPG_MODE:-valid}" in
    invalid) exit 2 ;;
    mismatch)
        printf '%s\n' 'pub:-:2048:1:2F59B5F99B1BE0B4:0:0::-:::scESC::::::23::0:'
        printf '%s\n' 'fpr:::::::::0000000000000000000000000000000000000000:'
        ;;
    *)
        printf '%s\n' 'pub:-:2048:1:2F59B5F99B1BE0B4:0:0::-:::scESC::::::23::0:'
        printf '%s\n' 'fpr:::::::::6F71F525282841EEDAF851B42F59B5F99B1BE0B4:'
        ;;
esac
EOF
chmod +x "$TEST_ROOT/bin/gpg"

ORIGINAL_PATH="$PATH"
PATH="$TEST_ROOT/bin:$PATH"

FAKE_CURL_MODE=valid checked_download "https://example.invalid/tool" "$TEST_ROOT/tool" "Fixture"
[ -s "$TEST_ROOT/tool" ] || fail "checked download did not retain a valid payload"

if FAKE_CURL_MODE=empty checked_download "https://example.invalid/empty" "$TEST_ROOT/empty" "Empty fixture"; then
    fail "empty downloads must fail"
fi
[ ! -e "$TEST_ROOT/empty" ] || fail "failed downloads must be removed"

if FAKE_CURL_MODE=fail checked_download "https://example.invalid/fail" "$TEST_ROOT/fail" "Failed fixture"; then
    fail "curl failures must propagate"
fi
[ ! -e "$TEST_ROOT/fail" ] || fail "curl failure residue must be removed"

PATH="$ORIGINAL_PATH"
printf '%s' 'checksum fixture' > "$TEST_ROOT/checksum"
expected_sha="$(sha256sum "$TEST_ROOT/checksum" | awk '{print $1}')"
verify_sha256 "$TEST_ROOT/checksum" "$expected_sha" "Checksum fixture"
if verify_sha256 "$TEST_ROOT/checksum" "0000000000000000000000000000000000000000000000000000000000000000" "Checksum fixture"; then
    fail "checksum mismatches must fail"
fi

mkdir -p "$TEST_ROOT/archive-source" "$TEST_ROOT/archive-output"
printf '%s\n' 'binary fixture' > "$TEST_ROOT/archive-source/supabase"
tar -czf "$TEST_ROOT/archive.tar.gz" -C "$TEST_ROOT/archive-source" supabase
extract_tar_member "$TEST_ROOT/archive.tar.gz" "$TEST_ROOT/archive-output" "supabase" "Archive fixture"
grep -Fq 'binary fixture' "$TEST_ROOT/archive-output/supabase" || fail "expected archive member was not extracted"
if extract_tar_member "$TEST_ROOT/archive.tar.gz" "$TEST_ROOT/archive-output" "missing" "Archive fixture"; then
    fail "missing archive members must fail"
fi

printf '%s\n' 'deb [signed-by=/keyring.gpg] https://packages.example stable main' > "$TEST_ROOT/source.list"
require_exact_line "$TEST_ROOT/source.list" 'deb [signed-by=/keyring.gpg] https://packages.example stable main' "Repository fixture"
if require_exact_line "$TEST_ROOT/source.list" 'deb https://attacker.invalid stable main' "Repository fixture"; then
    fail "unexpected repository content must fail validation"
fi
require_only_exact_lines "$TEST_ROOT/source.list" "Repository fixture" 'deb [signed-by=/keyring.gpg] https://packages.example stable main'
printf '%s\n' 'deb https://attacker.invalid stable main' >> "$TEST_ROOT/source.list"
if require_only_exact_lines "$TEST_ROOT/source.list" "Repository fixture" 'deb [signed-by=/keyring.gpg] https://packages.example stable main'; then
    fail "unexpected active repository lines must fail validation"
fi

PATH="$TEST_ROOT/bin:$PATH"
FAKE_GPG_MODE=valid verify_gpg_primary_fingerprint "$TEST_ROOT/key" "6F71F525282841EEDAF851B42F59B5F99B1BE0B4" "Key fixture"
FAKE_GPG_MODE=valid verify_gpg_key_file "$TEST_ROOT/key" "Key fixture"
if FAKE_GPG_MODE=mismatch verify_gpg_primary_fingerprint "$TEST_ROOT/key" "6F71F525282841EEDAF851B42F59B5F99B1BE0B4" "Key fixture"; then
    fail "GPG fingerprint mismatches must fail"
fi
if FAKE_GPG_MODE=invalid verify_gpg_key_file "$TEST_ROOT/key" "Key fixture"; then
    fail "invalid GPG key files must fail"
fi
PATH="$ORIGINAL_PATH"

run_required "Successful command" true
if run_required "Failed command" false; then
    fail "required command failures must propagate"
fi

[ "$(resolve_linux_arch x86_64)" = "amd64" ] || fail "x86_64 architecture mapping"
[ "$(resolve_linux_arch amd64)" = "amd64" ] || fail "amd64 architecture mapping"
[ "$(resolve_linux_arch aarch64)" = "arm64" ] || fail "aarch64 architecture mapping"
[ "$(resolve_linux_arch arm64)" = "arm64" ] || fail "arm64 architecture mapping"
if resolve_linux_arch riscv64 >/dev/null 2>&1; then
    fail "unsupported architectures must fail"
fi

if grep -Eq 'curl[^|]*\|[[:space:]]*(sudo[[:space:]]+(-E[[:space:]]+)?|)bash' "$INSTALLER"; then
    fail "live curl-to-bash execution remains"
fi
if grep -Fq '/releases/latest/' "$INSTALLER"; then
    fail "unresolved latest release download remains"
fi
if grep -Eq 'dpkg[[:space:]]+-i.*\|\|[[:space:]]*true' "$INSTALLER"; then
    fail "dpkg failure is still ignored"
fi
if grep -Eq 'pip3[[:space:]]+install[[:space:]]+pyyaml' "$INSTALLER"; then
    fail "root PyPI install remains"
fi

grep -Fq 'SUPABASE_VERSION="2.115.0"' "$INSTALLER" || fail "Supabase version is not pinned"
grep -Fq 'FLOX_VERSION="1.14.1"' "$INSTALLER" || fail "Flox version is not pinned"
grep -Fq 'GITHUB_CLI_KEYRING_SHA256="6084d5d7bd8e288441e0e94fc6275570895da18e6751f70f057485dc2d1a811b"' "$INSTALLER" || fail "GitHub CLI keyring checksum is missing"
grep -Fq 'NODESOURCE_GPG_FINGERPRINT="6F71F525282841EEDAF851B42F59B5F99B1BE0B4"' "$INSTALLER" || fail "NodeSource key fingerprint is missing"

echo "Installer supply-chain contract passed"
