---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
created_at: "YYYY-MM-DD HH:MM:SS UTC"
updated: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD HH:MM:SS UTC"
status: draft
source_skill: "sg-spec"
scope: "manual-test-checklist"
owner: "[owner]"
target_scope: "shipglows_data/workflow/test-checklists/<scope>"
stack_profile: "[flutter|astro|python|api|auth|provider|device|mixed]"
proof_profile: "[automated|browser|auth|contract|provider|device|manual]"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
evidence:
  - "[documentation contract, governance note, or none]"
depends_on: []
supersedes: []
next_step: "/sg-test [scope]"
---

# Manual Test Checklist: [scope]

## Contract

- Target scope: `shipglows_data/workflow/test-checklists/<scope>.md`
- Stack profile: `[chosen stack profile from sf-spec Test Contract]`
- Proof profile: `[automated -> browser/auth -> contract -> provider -> manual/device]`
- Required proof rows: `PASS`/`FAIL`/`BLOCKED`/`N/A`/`NOT_RUN` are all machine-read.

## Status Vocabulary

- `NOT_RUN`: not executed yet
- `PASS`: required checks and result observed
- `FAIL`: failure reproduced with a concrete observation
- `BLOCKED`: could not execute due to environment/accessibility/dependency blockers
- `N/A`: not applicable with an explicit reason in Notes

## Operator Editing Rules

- Update only the following columns:
  - `Observed`
  - `Status`
  - `Evidence pointer`
  - `Notes`
- Preserve existing scenario IDs and required flags.
- `Observed` is mandatory for `FAIL` and `BLOCKED`.
- `Evidence pointer` is mandatory for `FAIL` when `Bug-` is not yet linked.
- Keep `notes` concise and redacted.

## Evidence Rules

- Use repo-relative evidence paths only (`test-evidence/...` or `shipglows_data/workflow/bugs/...`).
- No absolute paths, `..` segments, secrets, cookies, tokens, raw PII, or raw logs in this file.
- For large or sensitive evidence, use `test-evidence/<BUG-ID>/` and link to that path only.

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| S001 | [surface] | [operator-fill short scenario] | yes | [success criterion] | NOT_RUN | [actual result when not-pass] | [safe path or N/A] | [optional notes] | [BUG-YYYY-MM-DD-NNN or empty] |
| S002 | [surface] | [operator-fill short scenario] | no | [success criterion] | NOT_RUN | [actual result when not-pass] | [safe path or N/A] | [optional notes] | [BUG-YYYY-MM-DD-NNN or empty] |

## Maintenance

- This checklist is operator-owned evidence. Re-run `sf-test` to convert `FAIL`/`BLOCKED` rows into `shipglows_data/workflow/bugs/BUG-ID.md` entries.
- Keep optional rows as guidance only; required rows block verification when unresolved (`FAIL`, `BLOCKED`, `NOT_RUN`).
