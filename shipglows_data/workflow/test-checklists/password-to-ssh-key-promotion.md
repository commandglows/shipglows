---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-13"
created_at: "2026-07-13 17:41:30 UTC"
updated: "2026-08-09"
updated_at: "2026-08-09 00:00:00 UTC"
status: reviewed
source_skill: "102-sg-start"
scope: "local-ssh-authentication"
owner: "Diane"
target_scope: "password-to-ssh-key-promotion"
stack_profile: "bash-openssh"
proof_profile: "automated -> contract -> manual-server"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
evidence: ["Automated helper and rollback tests live in tests/local/ssh-key-promotion.sh"]
depends_on:
  - artifact: "shipglows_data/workflow/specs/password-to-ssh-key-promotion.md"
    artifact_version: "1.1.4"
    required_status: ready
supersedes: []
next_step: "none"
---

# Manual Test Checklist: Password-To-SSH-Key Promotion

Use a redacted server label such as `new-server`; do not record a hostname, password, public-key record, private-key path, IP address, or raw SSH output.

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| SSHKEY-M01 | local SSH menu | Add the new server with password auth, accept promotion, and generate or select a per-device key | yes | Public key installs, independent key-only proof passes, and saved mode becomes `key` | PASS | Tooling observed password setup, dedicated key generation, `installed`, independent key-only success, and saved `key` mode | shipglows_data/workflow/TEST_LOG.md | 2026-07-13 20:37:47 UTC; target label `qa-server` | |
| SSHKEY-M02 | remote authorized keys | Run `Installer une clé SSH sur ce serveur` again with the same identity | yes | Operation reports the key as present and does not add a duplicate blob | PASS | Repeated menu action reported `present`; each tested public blob occurred exactly once | shipglows_data/workflow/TEST_LOG.md | 2026-07-13 20:37:47 UTC; no key content retained | |
| SSHKEY-M03 | Android Termux SSH session | Close the password ControlMaster, restart `urls`, and start one app tunnel from Termux | yes | Tunnel starts without a server-password prompt | PASS | Physical Android Termux paired with password once, generated and installed its device key, then discovered the registered app port and opened the tunnel without another password prompt; the browser proof passed | shipglows_data/workflow/TEST_LOG.md | 2026-08-09 UTC; target label `qa-server`; no endpoint, key, or credential retained | |
| SSHKEY-M04 | remote authorized keys | Confirm pre-existing authorized keys still authenticate after promotion | yes | Existing device access remains valid and file modes are restrictive | PASS | First identity still authenticated after second promotion; remote modes were `700` and `600` | shipglows_data/workflow/TEST_LOG.md | 2026-07-13 20:37:47 UTC; no key lines recorded | |
| SSHKEY-M05 | second local device | Install a distinct public key from another device | yes | Both devices authenticate independently; no private key is copied | PASS | A second isolated local home generated a distinct identity; both identities authenticated independently and coexisted | shipglows_data/workflow/TEST_LOG.md | 2026-07-13 20:37:47 UTC; physical Android proof remains M03 | |
