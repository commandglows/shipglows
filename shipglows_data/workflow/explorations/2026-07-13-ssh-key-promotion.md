---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlows"
created: "2026-07-13"
updated: "2026-07-13"
status: reviewed
source_skill: 700-sg-explore
scope: "Promote a password-authenticated local-to-server connection to SSH key authentication"
owner: "unknown"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: ["local/local.sh", "local/remote-helpers.sh", "local/install.sh", "local/install_local.ps1", "local/README.md", "shipglows_data/technical/local-tunnels-and-mcp-login.md"]
evidence: ["Existing local connection menu supports password and key modes", "Password mode already reuses an OpenSSH control connection without storing the password", "Saved connections already persist an auth method and optional local identity path", "No current helper provisions a public key into remote authorized_keys"]
depends_on: []
supersedes: []
next_step: "/107-sg-test password-to-ssh-key-promotion on the new server"
---

# Exploration Report: Password-To-SSH-Key Promotion

## Starting Question

Can ShipGlows use an initial password-authenticated connection to install an SSH public key on a newly paired server, then continue tunnels and remote operations without repeated password prompts?

## Context Read

- `CLAUDE.md` - established the server CLI and local tunnel architecture.
- `shipglows_data/technical/context.md` - identified `local/local.sh` as the owner of local SSH UX.
- `shipglows_data/technical/context-function-tree.md` - confirmed the connection-management flow and documentation ownership.
- `shipglows_data/technical/code-docs-map.md` - identified required validation and documentation updates for `local/**` changes.
- `local/local.sh` - confirmed password/key selection, connection testing, and saved connection records already exist.
- `local/remote-helpers.sh` - confirmed auth-specific OpenSSH arguments and password-session reuse already exist.
- `local/install.sh` and `local/install_local.ps1` - confirmed local installation currently configures access but does not provision a remote public key.
- `local/README.md` and `local/README_WINDOWS.md` - confirmed public-key installation remains a manual documented step.

## Internet Research

No internet research was needed. The proposed flow relies on standard OpenSSH client and server behavior already used by the repository.

## Problem Framing

A new server may initially allow password authentication. ShipGlows can already retain that connection through an OpenSSH control socket for eight hours, but the saved connection remains password-based. The missing capability is a safe, recoverable promotion from password authentication to key authentication without handling or storing the password itself.

The trust boundary must remain local-first: the private key is created or selected on the operator's local device, and only its public key is sent to the selected remote account.

## Option Space

### Option A: Use `ssh-copy-id` Directly

- Summary: invoke `ssh-copy-id -i <public-key> <target>` after the password connection succeeds.
- Pros: standard utility, handles common `authorized_keys` setup details, compact implementation.
- Cons: not consistently available on Windows and some minimal local systems; needs a fallback and controlled SSH arguments to match the selected ShipGlows connection.

### Option B: Install The Public Key Through Existing SSH Helpers

- Summary: read a validated local `.pub` file and send it through the existing authenticated SSH connection to an idempotent remote command that creates `~/.ssh`, locks permissions, and appends only when absent.
- Pros: portable across systems with OpenSSH, reuses ShipGlows auth and connection state, allows precise validation and error reporting.
- Cons: shell quoting and line validation must be rigorous; the implementation owns correct permissions and deduplication.

### Option C: Let The Server Generate And Return A Key Pair

- Summary: generate the identity on the server and transfer the private key to the local device.
- Pros: superficially centralizes setup.
- Cons: breaks the private-key trust boundary, creates unnecessary secret transfer and retention risk, and makes ownership ambiguous.

## Comparison

Option B is the strongest default because it works with the existing password-authenticated control connection and can be implemented consistently for Linux, macOS, WSL, Git Bash, and PowerShell. Option A is suitable as an optional fast path where `ssh-copy-id` exists, but it should not define the product contract. Option C should not be implemented.

## Emerging Recommendation

Add a local operation named `Installer une clé SSH sur ce serveur` with two entry points:

- immediately after a password-authenticated server is successfully added;
- in the saved-connection management menu for an existing password connection.

The operation should:

1. Offer an existing local key or generate a dedicated Ed25519 key, preferably `~/.ssh/shipglows_<safe-host-id>`.
2. Never overwrite an existing private key and never print or transfer private-key content.
3. Validate that the public key is one supported single-line OpenSSH public key record.
4. Use the current password-authenticated connection to create remote `~/.ssh` with mode `700` and `authorized_keys` with mode `600` under the connected remote user.
5. Add the public key idempotently without replacing existing authorized keys.
6. Test a fresh key-only connection with password and keyboard-interactive authentication explicitly disabled.
7. Update `current_auth_method`, `current_identity_file`, and the saved connection record only after that fresh test succeeds.
8. Leave password authentication policy on the server unchanged. Disabling password login is a separate hardening action and must never be implicit in pairing.

## Non-Decisions

- Whether generated keys should use a passphrase by default.
- Whether `ssh-copy-id` should be used as an optional implementation optimization.
- Whether Windows PowerShell receives the feature in the first implementation or immediately after the Bash path.
- Whether an explicit key-removal or rotation UX belongs in the same initial scope.

## Rejected Paths

- Server-generated private key copied back to the client - violates the intended secret boundary.
- Replacing `authorized_keys` - could lock out existing devices and destroy unrelated access.
- Automatically disabling SSH password authentication - may lock out the operator and changes machine-wide security policy beyond pairing scope.
- Marking the connection as key-authenticated before an independent key-only test - creates a recoverability failure if provisioning was incomplete.

## Risks And Unknowns

- The remote account may have a nonstandard home directory, restricted shell, read-only filesystem, or managed `AuthorizedKeysCommand` policy.
- Root and regular-user accounts require different operational caution; the key must always be installed for the account in the selected SSH target.
- Public-key parsing must reject multiline input, options supplied by an untrusted source, private-key material, and shell metacharacter injection paths.
- A local private key may be unencrypted. The UX must explain the passphrase tradeoff without silently choosing weak protection.
- Existing OpenSSH multiplexed password sessions can make a test appear successful unless the verification explicitly uses a separate control path and disables password fallback.
- Host-key replacement during server migration must remain explicit; `StrictHostKeyChecking=accept-new` does not accept a changed key, which is the safe behavior.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: No server address, password, private key, public key, token, or customer data was persisted.

## Decision Inputs For Spec

- User story seed: As an operator pairing a new ShipGlows server with a local device, I can authenticate once by password, install a local public key safely, verify key-only access, and continue using tunnels without password prompts.
- Scope in seed: Bash local menu, reusable helper functions, idempotent remote public-key installation, fresh key-only verification, saved connection promotion, tests, and local SSH documentation.
- Scope out seed: SSH daemon reconfiguration, password-login disabling, firewall changes, private-key synchronization between devices, and automatic removal of old keys.
- Invariants/constraints seed: private key never leaves the local device; existing `authorized_keys` entries are preserved; state changes only after independent verification; failures leave password mode recoverable.
- Validation seed: shell syntax checks, focused helper tests with isolated HOME and fake SSH, idempotency test, failed-verification rollback test, duplicate-key test, and a real new-server migration smoke test.

## Handoff

- Recommended next command: `/107-sg-test password-to-ssh-key-promotion on the new server`
- Why this next step: completed on 2026-07-13 through the linked spec and implementation; the remaining gate is real-server manual proof via `/107-sg-test password-to-ssh-key-promotion`.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-13 17:33:55 UTC | Promote initial password access to SSH key access during server migration | Inspected current local install, connection menu, SSH helpers, Windows path, and documentation contracts | Recommended local-first, idempotent public-key provisioning followed by independent key-only verification | `/100-sg-spec password-to-ssh-key-promotion` |
