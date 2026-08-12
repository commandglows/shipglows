---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.6"
project: "ShipGlows"
created: "2026-07-13"
created_at: "2026-07-13 17:37:20 UTC"
updated: "2026-08-11"
updated_at: "2026-08-11 22:30:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "As an operator pairing a new ShipGlows server with a local device, I want to install a public key after the first password-authenticated connection so subsequent tunnels and remote commands use SSH key authentication without asking for the server password again."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: ["local/local.sh", "local/remote-helpers.sh", "local/install.sh", "local/install_local.ps1", "local/README.md", "shipglows_data/technical/operator-guides/windows-devserver.md", "shipglows_data/technical/local-tunnels-and-mcp-login.md", "shipglows_data/technical/context-function-tree.md"]
depends_on:
  - artifact: "shipglows_data/technical/local-tunnels-and-mcp-login.md"
    artifact_version: "1.1.1"
    required_status: reviewed
  - artifact: "shipglows_data/workflow/explorations/2026-07-13-ssh-key-promotion.md"
    artifact_version: "1.0.1"
    required_status: reviewed
supersedes: []
evidence: ["Operator decision on 2026-07-13 to test password-first pairing during server migration", "Existing password and key auth modes in local/local.sh", "Existing password ControlMaster reuse in local/remote-helpers.sh", "Current official OpenSSH manuals for ssh-keygen, ssh_config, and authorized_keys behavior"]
next_step: "none"
---

# Spec: Password-To-SSH-Key Promotion

## Title

Password-To-SSH-Key Promotion

## Status

ready

## User Story

As an operator pairing a new ShipGlows server with a local device, I want to install a public key after the first password-authenticated connection so subsequent tunnels and remote commands use SSH key authentication without asking for the server password again.

## Minimal Behavior Contract

From a working saved ShipGlows connection, the operator can install an existing local public key or generate a dedicated local key and authorize its public half for the selected remote account. ShipGlows preserves all existing remote keys, never sends the private key, and changes saved connection state only after a new connection succeeds with the selected identity and no password or multiplexed-session fallback. Failure leaves the previous auth mode recoverable, and reinstalling an already authorized key does not duplicate it.

## Success Behavior

- Preconditions: a valid SSH target is saved and the same remote account is currently reachable, normally through password authentication during first pairing.
- Trigger: the operator chooses the French UI action `Installer une clé SSH sur ce serveur` after password setup or from the current-connection menu.
- User/operator result: the UI shows the selected/generated identity path, SHA256 fingerprint, remote installation result, independent key-only verification, and saved-mode promotion.
- System effect: the public key blob occurs once in the remote account's `~/.ssh/authorized_keys`; `current_auth_method`, `current_identity_file`, and the matching `connections.conf` record identify the verified local private key.
- Success proof: a fresh SSH call succeeds with `ControlPath=none`, password and keyboard-interactive disabled, `PreferredAuthentications=publickey`, and `IdentitiesOnly=yes`; a repeated install remains idempotent.
- Silent success: not allowed; each state transition is visible without printing key material.

## Error Behavior

- Expected failures: missing `ssh-keygen`, invalid/mismatched key files, malformed public key, missing target, initial SSH failure, unwritable remote home, nonstandard authorized-key policy, remote mutation failure, or key-only verification failure.
- User/operator response: a French, actionable message identifies the failed stage and preserves password recovery; ShipGlows never reads or stores the server password.
- System effect: saved auth state remains byte-for-byte unchanged. A newly generated local identity may remain on disk with an explicit message but is not activated.
- Must never happen: private-key transfer/output, replacement of `authorized_keys`, removal of third-party keys, implicit `sshd_config` changes, success through the password ControlMaster, or a saved key mode that was not independently proven.
- Silent failure: not allowed; the operation returns non-zero and explains recovery.

## Problem

ShipGlows can save password-based connections and reuse a protected OpenSSH master session for eight hours, but it cannot promote first-time access into durable per-device key authentication. A server migration therefore requires manual key setup or repeated password use.

## Solution

Add a local-first promotion operation that validates or generates an identity, sends only its public record over the existing SSH session, appends it idempotently, performs a truly independent publickey-only check, and atomically updates local ShipGlows state only after proof.

## Scope In

- Bash flow for Linux, macOS, WSL, and Android Termux in `local/local.sh`.
- Reusable validation, generation, installation, and verification helpers in `local/remote-helpers.sh`.
- Promotion prompt after successful password server setup and a permanent current-connection menu action.
- Existing identity selection or non-overwriting dedicated Ed25519 generation.
- Remote `700`/`600` permissions, blob-based deduplication, local-state rollback, tests, and docs.

## Scope Out

- Private-key synchronization or transfer between devices.
- `sshd_config`, daemon restart, password-login disabling, firewall changes, or remote account creation.
- Key removal, rotation, revocation, `AuthorizedKeysCommand`, or nonstandard `AuthorizedKeysFile` support.
- Native PowerShell automation in V1; Windows docs route automated use through WSL and preserve a manual PowerShell procedure.

## Constraints

- Private keys remain local with mode `600`; only validated public-key data reaches remote stdin.
- No public-key content is interpolated into a remote shell command and no `eval` is allowed.
- Generated keys live under `~/.ssh/`, use Ed25519, never overwrite, and derive names from a sanitized target identifier.
- Automatic generation uses no passphrase only after a clear French warning because non-interactive `autossh` cannot prompt. Existing protected keys remain supported through `ssh-agent`.
- Public inputs must start with an allowed OpenSSH key type, contain exactly one record, pass `ssh-keygen -lf`, and contain no `authorized_keys` options.
- The final proof disables connection sharing and all password-like fallback while forcing the selected identity.
- The implementation does not depend on `ssh-copy-id`.

## Test Contract

### Surface

- Stack/surface: Bash, OpenSSH, local-to-server authentication.
- Proof profile: `mixed`.
- Proof order: automated shell tests -> security/contract assertions -> real new-server migration.

### Manual checklist

- Needed: yes.
- Checklist path: `shipglows_data/workflow/test-checklists/password-to-ssh-key-promotion.md`.
- Required scenario IDs: `SSHKEY-M01` first promotion; `SSHKEY-M02` repeat/idempotence; `SSHKEY-M03` password ControlMaster closed; `SSHKEY-M04` existing remote keys preserved; `SSHKEY-M05` second device/key.
- Required results: every scenario records `pass`, `fail`, or `blocked`, UTC timestamp, redacted target label, and a secret-free observation.
- Exception with proof: real SSH proof may remain blocked until the new server exists, but automated implementation can proceed; full `103-sg-verify` success requires these manual rows.

### Required evidence stack

- Automated / unit / integration checks: `bash -n local/*.sh`; `bash tests/local/ssh-key-promotion.sh`; metadata lint for changed governance docs.
- Agent-run browser proof: not applicable because there is no web surface.
- Auth/session proof: covered by the isolated OpenSSH argument contract and real-server checklist rather than browser auth tooling.
- Contract/integration proof: `SSHKEY-A01` public-only stdin; `SSHKEY-A02` key-only fresh args; `SSHKEY-A03` deduplication; `SSHKEY-A04` state rollback; `SSHKEY-A05` key mismatch rejection; `SSHKEY-A06` no overwrite.
- Provider evidence: local OpenSSH plus the operator's new server for the manual gate.
- Device-native proof: Android Termux `urls` promotion and one real tunnel after closing the password master session.

## Dependencies

- Runtime: `bash`, `ssh`, `ssh-keygen`, `awk`, `chmod`, and `mkdir`, already consistent with the local tooling layer.
- Document contracts: `local-tunnels-and-mcp-login.md` v1.1.0 and the linked exploration v1.0.0.
- Fresh external docs: `fresh-docs checked` on 2026-07-13 against current official OpenSSH `ssh-keygen(1)`, `ssh_config(5)`, and `sshd(8)` manuals. They support Ed25519 identities, public records in `~/.ssh/authorized_keys`, `ControlPath none` to disable sharing, and restrictive user-only permissions.
- Metadata gaps: none for the directly used contracts.

## Invariants

- Each device owns a distinct private key; multiple device public keys may coexist remotely.
- Saved connection state changes only after independent key-only proof.
- Reinstalling the same public blob does not add a duplicate.
- Existing `authorized_keys` entries remain present and unchanged.
- The password is never read by ShipGlows, passed as an argument, or persisted.
- Private-key contents are never displayed, logged, copied, or sent.

## Links & Consequences

- Upstream systems: local installer aliases, saved target/auth state, operator-selected identity.
- Downstream systems: app tunnels, OAuth/CLI helpers, and `autossh` all consume `current_auth_method` and `current_identity_file`.
- Cross-cutting checks: SSH input validation, filesystem permissions, Linux/macOS/WSL compatibility, recoverable French UX, and regression checks for existing tunnel/login flows.
- Observability: Sentry is not applicable to this local shell CLI. Step output, exit codes, isolated tests, and final SSH state provide evidence; diagnostics must remain secret-free.

## Documentation Coherence

- Update `local/README.md` for password-to-key promotion, one-key-per-device, rollback, and troubleshooting.
- Update `shipglows_data/technical/operator-guides/windows-devserver.md` to recommend WSL for automation and retain an accurate native PowerShell manual path.
- Update `shipglows_data/technical/local-tunnels-and-mcp-login.md` for helpers, invariants, and failures.
- Update `shipglows_data/technical/context-function-tree.md` for the new connection-management branch.
- Update global `README.md` only if its local-tunnel capability list would otherwise become incomplete.

## Edge Cases

- SSH aliases and unusual targets must produce a sanitized local filename without changing SSH resolution.
- If `<private>.pub` is absent, derive public output with `ssh-keygen -y` without exposing private content.
- Reject a `.pub` that does not match the private identity by comparing derived fingerprints.
- Deduplicate by base64 blob even when an existing remote entry has a different comment or options.
- Preserve an empty/missing/no-final-newline `authorized_keys` file and all long existing lines.
- Ensure an active password ControlMaster cannot satisfy the final check.
- A passphrase-protected key unavailable to the agent must fail batch proof with an `ssh-add` recovery hint.
- If remote install succeeds but local state write fails, report the installed public key and retain the previous local auth mode.
- A changed host key remains an OpenSSH error; ShipGlows never edits `known_hosts` automatically.
- Remote ACL/home-policy failures stop without `sudo`.

## Implementation Tasks

- [x] Task 1: Implement public-key and independent-verification primitives.
  - File: `local/remote-helpers.sh`.
  - Action: resolve/validate private and public files, compare fingerprints, generate non-overwriting Ed25519 identities, install validated public data via stdin, and verify a fresh publickey-only connection.
  - User story link: preserves the private-key boundary and proves durable access.
  - Depends on: none.
  - Validate with: `bash -n local/remote-helpers.sh && bash tests/local/ssh-key-promotion.sh`.
  - Notes: deduplicate on the base64 blob; never use `eval` or the password ControlPath for proof.

- [x] Task 2: Integrate promotion into setup and connection menus.
  - File: `local/local.sh`.
  - Action: add the French UI action, existing/generate choices, fingerprint display, explicit confirmation, post-password offer, and atomic saved-state promotion.
  - User story link: makes the capability available during migration and later recovery.
  - Depends on: Task 1.
  - Validate with: `bash -n local/local.sh` plus isolated menu/function smoke tests.
  - Notes: preserve previous state on every failure path.

- [x] Task 3: Add adversarial and rollback tests.
  - File: `tests/local/ssh-key-promotion.sh`.
  - Action: cover `SSHKEY-A01` through `SSHKEY-A06`, malformed inputs, final SSH flags, idempotent remote behavior, success promotion, and failure rollback with isolated HOME and command stubs.
  - User story link: prevents lockout and secret-boundary regressions.
  - Depends on: Tasks 1 and 2.
  - Validate with: `bash tests/local/ssh-key-promotion.sh`.
  - Notes: no real server or real private key in automated fixtures.

- [x] Task 4: Align local and technical documentation.
  - File: `local/README.md`, `shipglows_data/technical/operator-guides/windows-devserver.md`, `shipglows_data/technical/local-tunnels-and-mcp-login.md`, `shipglows_data/technical/context-function-tree.md`, optional `README.md`.
  - Action: document flow, device-key model, limits, rollback, Windows/WSL route, and validation.
  - User story link: makes future server pairing reproducible.
  - Depends on: Tasks 1 through 3.
  - Validate with: metadata lint and focused `rg` proof.
  - Notes: no real host, password, or key content.

- [x] Task 5: Record real migration proof.
  - File: `shipglows_data/workflow/test-checklists/password-to-ssh-key-promotion.md`.
  - Action: execute and record `SSHKEY-M01` through `SSHKEY-M05` on the new server.
  - User story link: proves the exact migration outcome.
  - Depends on: Tasks 1 through 4 and new-server access.
  - Validate with: all required checklist rows completed without sensitive data.
  - Notes: external availability may block total verification, not implementation checks.

## Acceptance Criteria

- [x] AC 1: Given a saved password connection, when the operator confirms promotion with a valid identity, then only the public record is installed and saved state changes after independent key-only success.
- [x] AC 2: Given generation is selected, when no destination files exist, then a mode-600 dedicated Ed25519 identity is created without passphrase after warning, never overwriting files, and its SHA256 fingerprint is shown.
- [x] AC 3: Given the public blob is already authorized, when promotion is repeated, then no duplicate is added and key-only proof still runs.
- [x] AC 4: Given existing keys/options, when a new key is installed, then every existing entry remains and final directory/file modes are `700`/`600`.
- [x] AC 5: Given a password ControlMaster exists, when final proof runs, then it includes `ControlPath=none`, password/keyboard-interactive disabled, publickey preferred, and the selected identity forced.
- [x] AC 6: Given install or proof failure, when the flow exits, then all saved connection files preserve their previous content and a French recovery message appears.
- [x] AC 7: Given multiline, option-prefixed, private, unsupported, or mismatched public input, when validation runs, then failure occurs before remote mutation.
- [ ] AC 8: Given a protected key unavailable in batch mode, when proof fails, then ShipGlows recommends `ssh-add`, does not promote, and never falls back to server password.
- [ ] AC 9: Given a changed host key, when OpenSSH refuses it, then ShipGlows preserves the error and does not edit `known_hosts`.
- [x] AC 10: Given two devices, when each installs a distinct public key, then both coexist without private-key sharing.
- [x] AC 11: Given changed scripts/docs, when automated checks run, then Bash syntax, promotion tests, and metadata lint pass.
- [x] AC 12: Given the new server is available, when the manual checklist runs, then `urls` and one tunnel work after the password master session closes without a server-password prompt.

## Test Strategy

- Unit: path/key validation, public derivation, mismatch rejection, generation collision, fingerprint, and fresh SSH arguments.
- Integration: stubbed SSH captures public stdin and simulates remote deduplication; isolated HOME verifies atomic state success/rollback.
- Manual: new-server promotion, closed ControlMaster, real tunnel, repeated install, and second device/key.
- Security: assert malformed inputs never invoke SSH and captured output/stdin never contains private material.

## Risks

- Security impact: high, mitigated by local-only private keys, stdin public data, strict validation, preservation, independent proof, and state rollback.
- Lockout: prevented by retaining password mode until proof succeeds.
- Secret exposure: prevented by APIs accepting validated public paths/data and assertions on remote stdin/output.
- Compatibility: nonstandard server policies fail explicitly without global changes or `sudo`; Termux installation uses `pkg` rather than Debian/Ubuntu instructions.
- Product confusion: French UX/docs consistently say one key per device and never describe private-key synchronization.

## Execution Notes

- Read first: `local/remote-helpers.sh`, `local/local.sh`, `local/README.md`, `shipglows_data/technical/local-tunnels-and-mcp-login.md`, and this spec.
- Implementation order: testable helpers -> stubs/tests -> menu/state orchestration -> docs/checklist -> real proof.
- Validate with: `bash -n local/*.sh`; `bash tests/local/ssh-key-promotion.sh`; scoped metadata lint.
- Fresh docs: official current OpenSSH manuals checked on 2026-07-13; do not assume `ssh-copy-id`.
- Stop conditions: stop without promotion if private data reaches remote stdin, final proof can reuse a master connection, existing authorized keys cannot be preserved, or server key storage is nonstandard.

## Open Questions

None. V1 targets Bash on Linux, macOS, WSL, and Android Termux, generates an explicitly unencrypted dedicated key only by operator choice, supports existing agent-backed keys, and leaves server password policy unchanged.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-13 17:37:20 UTC | 100-sg-spec | GPT-5 Codex | Created the implementation contract from the approved exploration | draft | /101-sg-ready password-to-ssh-key-promotion |
| 2026-07-13 17:39:40 UTC | 101-sg-ready | GPT-5 Codex | Reviewed language doctrine and mechanical proof contract | not ready: internal body language and scenario IDs required repair | /100-sg-spec password-to-ssh-key-promotion |
| 2026-07-13 17:39:40 UTC | 100-sg-spec | GPT-5 Codex | Rewrote internal contract in English and added explicit automated/manual proof IDs | draft repaired | /101-sg-ready password-to-ssh-key-promotion |
| 2026-07-13 17:41:30 UTC | 101-sg-ready | GPT-5 Codex | Re-ran structure, security, freshness, adversarial, and proof-contract review | ready | /102-sg-start password-to-ssh-key-promotion |
| 2026-07-13 17:48:22 UTC | 102-sg-start | GPT-5 Codex | Implemented local public-key promotion, fresh key-only verification, state rollback, tests, docs, and manual checklist | implemented; local checks pass, real new-server proof pending | /103-sg-verify password-to-ssh-key-promotion |
| 2026-07-13 17:49:31 UTC | 103-sg-verify | GPT-5 Codex | Verified automated behavior, security invariants, docs, metadata, checklist structure, and existing CLI regressions | partial: SSHKEY-M01 through SSHKEY-M05 require the operator's new server | /107-sg-test password-to-ssh-key-promotion on the new server |
| 2026-07-13 20:37:47 UTC | 107-sg-test | GPT-5 Codex | Created a retained Hetzner QA VM and exercised password promotion, idempotence, two distinct identities, permissions, and a Linux tunnel after closing the password master; added explicit Termux installer support after detecting the platform gap | partial: SSHKEY-M01, M02, M04, and M05 pass; SSHKEY-M03 still requires the real Android Termux device | /107-sg-test password-to-ssh-key-promotion from Android Termux on the retained QA server |
| 2026-08-09 UTC | 107-sg-test | GPT-5 Codex + operator | Ran the physical Android Termux flow: password-first pairing, per-device key installation, session identity discovery, port selection, and browser tunnel proof | verified: SSHKEY-M03 pass; all required manual scenarios pass | none |
| 2026-08-09 UTC | 007-sg-content | GPT-5 Codex | Aligned repository and public install wording with the physical Termux proof, without exposing host, credentials, or key material | implemented; public wording remains bounded to the verified password-first, device-key tunnel flow | none |

## Current Chantier Flow

- `100-sg-spec`: done.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented; auto-verify skipped because real-server manual proof is required.
- `103-sg-verify`: verified; automated proof and all five real-server scenarios pass.
- `104-sg-end`: ready to launch.
- `005-sg-ship`: not launched.

Next step: none.
