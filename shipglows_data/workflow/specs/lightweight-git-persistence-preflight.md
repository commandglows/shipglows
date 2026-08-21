---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: ready
source_skill: 900-shipglows-core
scope: lightweight-git-persistence-preflight
owner: Diane
user_story: "As a solo operator, I want ShipGlows to detect locally vulnerable work at existing lifecycle boundaries without adding ceremony when Git state is healthy."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/git-persistence-preflight.md
  - skills/references/git-milestone-delivery-contract.md
  - skills/references/reporting-contract.md
  - skills/102-sg-start/SKILL.md
  - skills/706-continue/SKILL.md
  - skills/104-sg-end/SKILL.md
depends_on:
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval 2026-08-21: add lightweight Git safeguards without making the workflow heavy."
  - "Operator decision 2026-08-21: healthy state stays silent; checks run at mutating start, interrupted resume, before sensitive operations, and closure."
next_step: /103-sg-verify lightweight-git-persistence-preflight
---

# Lightweight Git Persistence Preflight

## Status

ready

## Acceptance Criteria

- The preflight runs only at existing lifecycle boundaries: mutating start, interrupted resume, before sensitive operations, and closure.
- Healthy state adds no question, approval, screen, or blocking step.
- The preflight resolves repository, branch, upstream, ahead/behind state, chantier-owned local changes, and inherited unrelated changes through read-only inspection.
- `local`, `backed up`, and `deployed` remain distinct and evidence-based.
- Unknown ownership, wrong/ambiguous remote, local-only commits, and overlapping inherited changes produce one actionable warning rather than generic ceremony.
- Unrelated dirty work is preserved and does not block non-overlapping work merely because it exists.
- A remote recovery point is required before auth, payment, permissions, migration, destructive, tenant, secret, production, or private-data mutation.
- Focused tests prove silent health, interruption recovery, sensitive checkpoint, wrong remote, unrelated dirty preservation, and closure behavior.

## Pressure Scenarios

- `GPP-HEALTHY-SILENT`: healthy backed-up state continues without question or visible preflight receipt.
- `GPP-START-LOCAL-AHEAD`: a mutating start detects a local-only commit before the first write.
- `GPP-RESUME-INTERRUPTED`: resume reports last upstream commit, remaining local work, and next expected outcome.
- `GPP-UNRELATED-DIRTY`: clearly unrelated inherited changes remain unstaged and do not block non-overlapping scope.
- `GPP-WRONG-REMOTE`: ambiguous or unexpected upstream stops remote persistence rather than guessing.
- `GPP-SENSITIVE-RECOVERY-POINT`: sensitive mutation begins only after the relevant checkpoint is backed up.
- `GPP-STATE-SEPARATION`: push proves `backed up`, provider evidence alone proves `deployed`.

## Implementation Tasks

- [ ] Add the shared lightweight persistence preflight.
- [ ] Integrate start, resume, sensitive-operation, closure, and reporting boundaries.
- [ ] Add focused pressure tests and canonical documentation.
- [ ] Commit and push each validated milestone and final record.

## Current Chantier Flow

`900-shipglows-core ✅ -> 100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start -> milestone commit/push -> 103-sg-verify -> 104-sg-end -> final commit/push`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved lightweight persistence safeguards with a strict no-workflow-bloat condition. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Boundaries, silent healthy behavior, state separation, recovery, and failure scenarios are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Existing lifecycle boundaries support one shared read-only preflight without a new manual phase. | 102-sg-start |
