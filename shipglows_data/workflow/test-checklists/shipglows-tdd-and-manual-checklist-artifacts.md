---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "ShipGlows"
created: "2026-05-28"
created_at: "2026-05-28 00:00:00 UTC"
updated: "2026-05-29"
updated_at: "2026-05-29 03:41:57 UTC"
status: draft
source_skill: "sg-start"
scope: "workflow"
owner: "sg-start"
target_scope: "shipglows-tdd-and-manual-checklist-artifacts"
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

# Manual Test Checklist: shipglows-tdd-and-manual-checklist-artifacts

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S001 | skill-governance | checklist semantics are operator-filled and machine-readable | yes | required rows are PASS and evidence pointer is safe | PASS | helper confirms syntax and required PASS rows | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/checklist-semantics.json | operator-facing checklist is clean and non-blocking for this scope | |
| S002 | skill-governance | optional parser sample: explicit alias normalization case | no | parser fixture case remains documented for regression checks | NOT_RUN | not executed in operator pass | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/parser-fixture-note.md | parser behavior is covered by dedicated fixture file | |
| S003 | skill-governance | optional parser sample: edge status path exists in dedicated fixture | no | fixture-only status examples are non-blocking for operator flow | NOT_RUN | dedicated fixture contains FAIL/BLOCKED/NOT_RUN examples | test-evidence/shipglows-tdd-and-manual-checklist-artifacts/parser-fixture.md | see parser fixture file for required status semantics | |
