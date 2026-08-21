---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: ready
source_skill: 900-shipglows-core
scope: mandatory-milestone-commits-and-final-push
owner: Diane
user_story: "As a ShipGlows operator, I want every validated implementation milestone committed and every completed chantier committed and pushed, so completed work is not lost locally."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/git-milestone-delivery-contract.md
  - skills/references/mutation-plan-approval.md
  - skills/references/master-workflow-lifecycle.md
  - skills/102-sg-start/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
depends_on:
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.12.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: require a commit at every milestone and a commit plus push at every chantier end to prevent work loss."
next_step: /103-sg-verify mandatory-milestone-commits-and-final-push
---

# Mandatory Milestone Commits And Final Push

## Status

ready

## Scope In

- Define a milestone as an explicit, coherent, proportionally validated implementation slice rather than a conversation turn.
- Require an exact-scope local commit before execution continues beyond each milestone.
- Require the final exact-scope commit, or the last milestone commit when nothing remains, and an ordinary push before clean closure.
- Include ordinary current-branch final push authority in the approved technical chantier plan.
- Preserve unrelated dirty work, secret checks, protected-branch rules, and all force-push restrictions.
- Keep a failed or unavailable push visibly delivery-pending instead of closed.

## Scope Out

- No empty commits, force pushes, automatic merges, tags, releases, deployments, or whole-repository staging.
- No commit for read-only work or a milestone with no owned diff.
- No absorption of pre-existing or unrelated changes.
- No weakening of validation, security, hosted-proof, or production gates.

## Acceptance Criteria

- A full approved technical chantier plan grants cumulative exact-scope checkpoint commits and one ordinary final push to the resolved current branch/upstream.
- Execution cannot cross an explicit milestone with owned uncommitted changes.
- Closure cannot be clean while owned commits remain unpushed.
- A final empty commit is forbidden; the latest owned milestone commit is the final commit when no closure diff remains.
- Push rejection, missing/ambiguous remote, dirty-scope ambiguity, suspected secrets, or failed required checks stop delivery without losing the local commit.
- Focused pressure tests prove milestone, final, no-op, unrelated-dirty, and push-failure behavior.

## Implementation Tasks

- [x] Add the shared milestone-delivery contract.
- [x] Update mutation authority and lifecycle orchestration.
- [x] Add checkpoint commit mode and final-push enforcement to Git shipping.
- [x] Align implementation and closure routes.
- [x] Add focused contract tests and canonical technical documentation.
- [x] Commit each completed batch and push the final branch.

## Pressure Scenarios

- `GMD-MILESTONE-COMMIT`: a coherent validated slice is committed before the next slice starts.
- `GMD-NO-MESSAGE-COMMITS`: intermediate messages do not manufacture milestones or commits.
- `GMD-FINAL-PUSH`: clean closure requires all owned commits pushed to the resolved upstream.
- `GMD-NO-EMPTY-FINAL`: no empty final commit is created when the last milestone already contains the final diff.
- `GMD-UNRELATED-DIRTY`: unrelated dirty paths remain unstaged at checkpoint and final delivery.
- `GMD-PUSH-FAILURE`: a rejected push preserves the local commit and leaves delivery pending.
- `GMD-NON-GIT`: read-only or non-Git work reports Git as not applicable without inventing delivery.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Authority and lifecycle | shared contract, approval doctrine, lifecycle and owner skills, spec | approved plan |
| B | Proof and documentation | focused tests, canonical technical documentation, final spec evidence | batch A commit |

## Current Chantier Flow

`900-shipglows-core ✅ -> 100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start ✅ -> milestone commit ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> final commit/push ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved mandatory checkpoint commits and final commit/push, with exact-scope and no-force safeguards. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Milestone semantics, exceptions, stops, pressure scenarios, and two commit batches are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Existing Git owner and approval boundaries support a bounded additive change. | 102-sg-start |
| 2026-08-21 | 102-sg-start | milestone committed | Authority, lifecycle, checkpoint mode, implementation route, closure route, and shared contract passed 58 focused tests and metadata lint. Commit `e12c896`. | Proof/documentation batch |
| 2026-08-21 | 103-sg-verify | verified | 63 focused scenarios pass; six metadata artifacts and all skill budgets pass; diff whitespace is clean. | 104-sg-end |
| 2026-08-21 | 104-sg-end | complete | Canonical lifecycle documentation and the durable chantier record are aligned; final exact-scope commit/push is authorized. | 005-sg-ship |
| 2026-08-21 | 005-sg-ship | shipped | Milestone `e12c896` and proof/documentation `ecca0b0` pushed successfully to the configured current-branch upstream; unrelated dirty paths remained unstaged. | none |
