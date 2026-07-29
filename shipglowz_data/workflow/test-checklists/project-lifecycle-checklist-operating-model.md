---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: ShipGlowz
created: "2026-07-27"
created_at: "2026-07-27 00:00:00 UTC"
updated: "2026-07-28"
updated_at: "2026-07-28 00:00:00 UTC"
status: draft
source_skill: 102-sg-start
scope: project-lifecycle-checklist-operating-model
owner: Diane
target_scope: shipglowz_data/workflow/test-checklists/project-lifecycle-checklist-operating-model.md
stack_profile: mixed
proof_profile: contract
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
evidence:
  - "Required by project-lifecycle-checklist-operating-model spec."
depends_on:
  - artifact: "shipglowz_data/workflow/specs/project-lifecycle-checklist-operating-model.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
next_step: "/107-sg-test project-lifecycle-checklist-operating-model"
---

# Manual Test Checklist: Project Lifecycle Checklist Operating Model

## Contract

- Target scope: `shipglowz_data/workflow/test-checklists/project-lifecycle-checklist-operating-model.md`
- Proof profile: contract → parser → reader/TUI projection
- Required proof rows: `PASS`/`FAIL`/`BLOCKED`/`N/A`/`NOT_RUN`

## Status Vocabulary

- `NOT_RUN`: not executed yet
- `PASS`: expected result observed
- `FAIL`: failure reproduced with a concrete observation
- `BLOCKED`: execution prevented by a named blocker
- `N/A`: not applicable with a reason in Notes

## Operator Editing Rules

- Update only `Observed`, `Status`, `Evidence pointer`, and `Notes`.
- Preserve scenario IDs and required flags.
- Keep evidence pointers repo-relative and redacted.

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| one-time-completion | lifecycle parser | A one-time item stays verified after completion | yes | Completion persists until retired or reopened | PASS | Python projection keeps `seo-launch-gate` verified and out of the actionable queue | `tools/test_shipglowz_project_lifecycle_status.py::test_projection_separates_one_time_recurring_and_open_items` | Automated deterministic test passed | |
| recurring-next-instance | lifecycle parser | A recurring item closes the current period and creates the next due instance | yes | History remains visible and the next occurrence is actionable | PASS | `security-review` keeps history and projects `2026-08-03T09:00:00+00:00` | `tools/test_shipglowz_project_lifecycle_status.py::test_projection_separates_one_time_recurring_and_open_items` | Automated deterministic test passed | |
| mixed-routing | tracker routing | One audit creates technical and editorial follow-ups | yes | Technical work routes to TASKS and public work to ROADMAP | NOT_RUN | | | | |
| missing-evidence | lifecycle state | A required item has no evidence | yes | State is waiting_for_evidence or needs_review, never verified | PASS | Required `seo-launch-gate` becomes `waiting_for_evidence` in both projections | `tools/test_shipglowz_project_lifecycle_status.py::test_missing_evidence_cannot_be_verified`; `tui/test/lifecycle.test.ts` | Automated deterministic tests passed | |
| paused-project | lifecycle state | A paused project has active recurring definitions | yes | New due work is suspended with a visible resume policy | PASS | Recurring security work is marked suspended and excluded from `today` | `tools/test_shipglowz_project_lifecycle_status.py::test_paused_project_suspends_recurring_work` | Automated deterministic test passed | |
| timezone-boundary | projection | A due time crosses the operator timezone boundary | yes | Today/this-week projection uses the declared timezone deterministically | PASS | UTC due time projects into Los Angeles local `today` | `tools/test_shipglowz_project_lifecycle_status.py::test_timezone_boundary_projects_into_local_today` | Automated deterministic test passed | |
| source-parity | consumers | The same source is read by a skill, TUI reader, and future adapter fixture | yes | IDs, states, due dates, and blockers remain identical | PASS | Python and TUI projections agree on IDs, states, due dates, evidence, recurrence, and overdue status | `tools/test_shipglowz_project_lifecycle_status.py`; `tui/test/lifecycle.test.ts` | Canonical fixture parity tests passed | |

## Maintenance

- This checklist records proof for the contract and parser pilot.
- Required unresolved rows block a clean verification verdict.
- Do not paste secrets, cookies, tokens, private logs, or absolute paths.
