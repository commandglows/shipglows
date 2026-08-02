---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-28"
created_at: "2026-05-28 00:00:00 UTC"
updated: "2026-05-29"
updated_at: "2026-05-29 03:41:57 UTC"
status: draft
source_skill: "sg-start"
scope: "workflow"
owner: "sg-start"
target_scope: "shipglows-tdd-and-manual-checklist-artifacts-parser"
stack_profile: "mixed"
proof_profile: "automated -> browser/auth -> contract -> manual"
confidence: medium
risk_level: medium
security_impact: no
docs_impact: yes
evidence: []
depends_on: []
supersedes: []
next_step: "/sg-test shipglows-tdd-and-manual-checklist-artifacts"
---

# Manual Test Checklist: shipglows-tdd-and-manual-checklist-artifacts parser fixture

This file is a dedicated parser fixture and is intentionally non-operator. It is
used to validate status normalization and blocker semantics without impacting scope
verification gates.

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S001 | skill-governance | parser helper accepts valid aliases | yes | `pass` recorded as PASS | PASS | helper normalizes to PASS | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/pass-aliases.json | parser alias smoke test succeeded | |
| S002 | skill-governance | required block status with fail | yes | fail must remain FAIL and require observed | FAIL | parser reported FAIL for unresolved scenario | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/fail-status.json | manual note indicates behavior mismatch | BUG-2026-05-28-001 |
| S003 | skill-governance | blocked scenario records blocker | yes | BLOCKED requires blocker evidence | BLOCKED | no deployment URL was available for blocked row | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/blocked-status.json | blocked by missing local auth URL | |
| S004 | skill-governance | skipped required item remains blocker | yes | NOT_RUN is unresolved | NOT_RUN | not executed yet | N/A | deferred due to environment limitation | |
| S005 | skill-governance | optional smoke scenario | no | optional path remains visible | NOT_RUN | not run in this pass | N/A | optional exploratory check | |
