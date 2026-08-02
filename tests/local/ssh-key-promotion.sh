#!/bin/bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/shipglows-ssh-key-test.XXXXXX")"
ORIGINAL_HOME="$HOME"
trap 'HOME="$ORIGINAL_HOME"; rm -rf "$TEST_ROOT"' EXIT

HOME="$TEST_ROOT/home"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# shellcheck source=../../local/remote-helpers.sh
source "$REPO_ROOT/local/remote-helpers.sh"

test_count=0
pass_count=0

check() {
    local name="$1"
    shift
    test_count=$((test_count + 1))
    printf 'Test %d: %s ... ' "$test_count" "$name"
    if "$@"; then
        echo "pass"
        pass_count=$((pass_count + 1))
    else
        echo "FAIL"
    fi
}

check_fails() {
    local name="$1"
    shift
    test_count=$((test_count + 1))
    printf 'Test %d: %s ... ' "$test_count" "$name"
    if "$@"; then
        echo "FAIL"
    else
        echo "pass"
        pass_count=$((pass_count + 1))
    fi
}

IDENTITY="$(generate_shipglows_identity "ubuntu@example.test")"
OTHER_IDENTITY="$(generate_shipglows_identity "ubuntu@other.example.test")"

check "SSHKEY-A06 generated identity exists" test -f "$IDENTITY"
check "SSHKEY-A06 generated public key exists" test -f "${IDENTITY}.pub"
check "SSHKEY-A06 private key is mode 600" test "$(stat -c '%a' "$IDENTITY" 2>/dev/null || stat -f '%Lp' "$IDENTITY")" = "600"
check "valid generated public key" validate_ssh_public_key_file "${IDENTITY}.pub"
check_fails "generation never overwrites an identity" generate_shipglows_identity "ubuntu@example.test" "$IDENTITY"

PREPARED="$TEST_ROOT/prepared.pub"
check "matching private/public pair is prepared" prepare_identity_public_key "$IDENTITY" "$PREPARED"
check "prepared public blob matches" test "$(ssh_public_key_blob "$PREPARED")" = "$(ssh_public_key_blob "${IDENTITY}.pub")"

cp "${OTHER_IDENTITY}.pub" "${IDENTITY}.pub"
check_fails "SSHKEY-A05 mismatched public key is rejected" prepare_identity_public_key "$IDENTITY" "$TEST_ROOT/mismatch.pub"
ssh-keygen -y -f "$IDENTITY" > "${IDENTITY}.pub"

printf '%s\n%s\n' "$(cat "${IDENTITY}.pub")" "$(cat "${OTHER_IDENTITY}.pub")" > "$TEST_ROOT/multiline.pub"
check_fails "multiline public input is rejected" validate_ssh_public_key_file "$TEST_ROOT/multiline.pub"
printf '%s\n' "restrict $(cat "${IDENTITY}.pub")" > "$TEST_ROOT/options.pub"
check_fails "authorized_keys options are rejected as input" validate_ssh_public_key_file "$TEST_ROOT/options.pub"

REMOTE_HOME="$TEST_ROOT/remote-home"
mkdir -p "$REMOTE_HOME/.ssh"
printf '%s\n' "restrict,command=\"echo kept\" $(cat "${OTHER_IDENTITY}.pub")" > "$REMOTE_HOME/.ssh/authorized_keys"
INSTALL_COMMAND="$(ssh_authorized_key_install_command)"
HOME="$REMOTE_HOME" bash -c "$INSTALL_COMMAND" < "${IDENTITY}.pub" > "$TEST_ROOT/install-1.out"
HOME="$REMOTE_HOME" bash -c "$INSTALL_COMMAND" < "${IDENTITY}.pub" > "$TEST_ROOT/install-2.out"
check "SSHKEY-A03 first install reports installed" grep -qx installed "$TEST_ROOT/install-1.out"
check "SSHKEY-A03 second install reports present" grep -qx present "$TEST_ROOT/install-2.out"
check "SSHKEY-A03 public blob occurs once" test "$(grep -o "$(ssh_public_key_blob "${IDENTITY}.pub")" "$REMOTE_HOME/.ssh/authorized_keys" | wc -l)" -eq 1
check "SSHKEY-A03 existing remote key is preserved" grep -q "$(ssh_public_key_blob "${OTHER_IDENTITY}.pub")" "$REMOTE_HOME/.ssh/authorized_keys"
check "remote SSH directory is mode 700" test "$(stat -c '%a' "$REMOTE_HOME/.ssh" 2>/dev/null || stat -f '%Lp' "$REMOTE_HOME/.ssh")" = "700"
check "remote authorized_keys is mode 600" test "$(stat -c '%a' "$REMOTE_HOME/.ssh/authorized_keys" 2>/dev/null || stat -f '%Lp' "$REMOTE_HOME/.ssh/authorized_keys")" = "600"

REMOTE_HOST="ubuntu@example.test"
CAPTURED_STDIN="$TEST_ROOT/remote-stdin"
run_remote_ssh() {
    cat > "$CAPTURED_STDIN"
    printf '%s\n' installed
}
check "SSHKEY-A01 public key install succeeds through stdin" install_remote_ssh_public_key "${IDENTITY}.pub"
check "SSHKEY-A01 stdin contains exactly the public record" cmp -s "$CAPTURED_STDIN" "${IDENTITY}.pub"
check_fails "SSHKEY-A01 stdin is not the private key" cmp -s "$CAPTURED_STDIN" "$IDENTITY"

SSH_ARGS_CAPTURE="$TEST_ROOT/ssh-args"
ssh() {
    printf '%s\n' "$@" > "$SSH_ARGS_CAPTURE"
    return 0
}
check "SSHKEY-A02 key-only verification succeeds with stub" verify_ssh_key_only "$IDENTITY"
for required_arg in \
    "ControlMaster=no" \
    "ControlPath=none" \
    "BatchMode=yes" \
    "PasswordAuthentication=no" \
    "KbdInteractiveAuthentication=no" \
    "PreferredAuthentications=publickey" \
    "PubkeyAuthentication=yes" \
    "IdentitiesOnly=yes"; do
    check "SSHKEY-A02 includes $required_arg" grep -qx "$required_arg" "$SSH_ARGS_CAPTURE"
done
check "SSHKEY-A02 forces selected identity" grep -qx "$IDENTITY" "$SSH_ARGS_CAPTURE"

HOME="$TEST_ROOT/menu-home"
mkdir -p "$HOME/.ssh" "$HOME/.shipglows"
cp "$IDENTITY" "$HOME/.ssh/existing-key"
cp "${IDENTITY}.pub" "$HOME/.ssh/existing-key.pub"
chmod 600 "$HOME/.ssh/existing-key"
export SHIPGLOWS_LOCAL_CONFIG_DIR="$HOME/.shipglows"

# shellcheck source=../../local/local.sh
source "$REPO_ROOT/local/local.sh"
REMOTE_HOST="ubuntu@example.test"
SSH_AUTH_METHOD="password"
SSH_IDENTITY_FILE=""
printf '%s\n' password > "$CURRENT_AUTH_METHOD_FILE"
printf '%s|password|\n' "$REMOTE_HOST" > "$CONNECTIONS_FILE"

install_remote_ssh_public_key() { printf '%s\n' installed; }
verify_ssh_key_only() { return 1; }

printf 'e\n%s\no\n' "$HOME/.ssh/existing-key" > "$TEST_ROOT/menu-input"
install_ssh_key_for_current_server < "$TEST_ROOT/menu-input" >/dev/null 2>&1
promotion_status=$?
check "SSHKEY-A04 failed proof returns non-zero" test "$promotion_status" -ne 0
check "SSHKEY-A04 password auth state remains" grep -qx password "$CURRENT_AUTH_METHOD_FILE"
check "SSHKEY-A04 saved connection remains password" grep -qx "$REMOTE_HOST|password|" "$CONNECTIONS_FILE"

check "successful state promotion commits all records" promote_connection_state_to_key "$REMOTE_HOST" "$HOME/.ssh/existing-key"
check "promoted auth method is key" grep -qx key "$CURRENT_AUTH_METHOD_FILE"
check "promoted identity path is absolute" grep -qx "$HOME/.ssh/existing-key" "$CURRENT_IDENTITY_FILE"
check "promoted saved connection uses the identity" grep -qx "$REMOTE_HOST|key|$HOME/.ssh/existing-key" "$CONNECTIONS_FILE"

SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_MANAGED_CONFIG_FILE="$HOME/.ssh/shipglows.conf"
export SHIPGLOWS_SSH_CONFIG_FILE="$SSH_CONFIG_FILE"
export SHIPGLOWS_SSH_MANAGED_CONFIG_FILE="$SSH_MANAGED_CONFIG_FILE"
printf '%s\n' "Host unrelated.example.test" "    User untouched" > "$SSH_CONFIG_FILE"
check "standard SSH config sync succeeds" sync_standard_ssh_identity "$REMOTE_HOST" "$HOME/.ssh/existing-key"
check "standard SSH config keeps existing content" grep -qx "Host unrelated.example.test" "$SSH_CONFIG_FILE"
check "standard SSH config includes managed identities" grep -Fqx "Include $SSH_MANAGED_CONFIG_FILE" "$SSH_CONFIG_FILE"
check "standard SSH config records the target identity" grep -Fqx "    IdentityFile $HOME/.ssh/existing-key" "$SSH_MANAGED_CONFIG_FILE"
check "standard SSH config forces identities only" grep -qx "    IdentitiesOnly yes" "$SSH_MANAGED_CONFIG_FILE"
check "standard SSH config supports direct SSH resolution" sh -c "ssh -F '$SSH_CONFIG_FILE' -G '$REMOTE_HOST' 2>/dev/null | grep -Fqx 'identityfile $HOME/.ssh/existing-key'"
check "standard SSH config sync is idempotent" sync_standard_ssh_identity "$REMOTE_HOST" "$HOME/.ssh/existing-key"
check "standard SSH config has one managed target block" test "$(grep -Fc '# >>> ShipGlows managed host example.test' "$SSH_MANAGED_CONFIG_FILE")" -eq 1

echo ""
echo "$pass_count/$test_count tests passed"
[ "$pass_count" -eq "$test_count" ]
