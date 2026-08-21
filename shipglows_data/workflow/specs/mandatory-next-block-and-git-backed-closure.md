---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: reviewed
source_skill: 900-shipglows-core
scope: mandatory-next-block-and-git-backed-closure
owner: Diane
user_story: "As a ShipGlows operator, I want every final report to state what follows and every mutated Git chantier to be remotely persisted before closure, so I never mistake local work for delivered work."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/reporting-pressure-scenarios.md
  - skills/references/git-milestone-delivery-contract.md
  - skills/104-sg-end/SKILL.md
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "2.8.0"
    required_status: active
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-08-21: every final report must include a SUITE block."
  - "Operator defect example 2026-08-21: a documentation chantier was reported corrected while its changes remained local without commit or push."
next_step: none
---

# Mandatory Next Block And Git-Backed Closure

## Status

complete

## Acceptance Criteria

- Every final user report contains `🧭 SUITE` with the next outcome, missing action/proof, decision surface, or explicit no-action-required statement.
- A Git-backed chantier with any intentional mutation cannot close with no commit, a local-only commit, a missing push, or a failed push.
- `Aucun commit ni push` is truthful only for genuinely read-only, non-mutating, or non-Git work.
- Documentation-only mutations obey the same commit/push closure invariant as code changes.
- A local mutation awaiting delivery is reported `delivery pending`, and its mandatory suite is commit/push delivery.
- Focused tests cover the supplied failure example and preserve unrelated dirty files.

## Pressure Scenarios

- `SSRP-024 mandatory next block`: every final user report includes a useful `🧭 SUITE`, including a truthful no-action-required outcome after terminal completion.
- `GMD-MUTATED-DOC-NO-LOCAL-CLOSURE`: changed documentation plus `Aucun commit ni push · modifications locales prêtes` cannot produce a completed verdict.
- `GMD-LOCAL-COMMIT-NO-CLOSURE`: a commit not present upstream remains `delivery pending`.

## Implementation Tasks

- [x] Make the final-report next block mandatory.
- [x] Harden Git-backed closure for every mutation, including documentation.
- [x] Add focused mechanical proof and align closure guidance.
- [x] Commit and push the validated milestone and final record.

## Current Chantier Flow

`900-shipglows-core ✅ -> 100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> commit/push ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved mandatory SUITE and Git-backed closure correction after clarification of pressure and regression tests. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Exact failure examples, invariants, and focused proof are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Existing reporting and Git delivery contracts provide narrow correction points; unrelated dirty files remain excluded. | 102-sg-start |
| 2026-08-21 | 102-sg-start | milestone pushed | Mandatory SUITE, Git-backed documentation closure, supplied failure cases, and focused tests implemented in commit `a347490` and pushed upstream. | 103-sg-verify |
| 2026-08-21 | 103-sg-verify | verified | 30 reporting/Git delivery tests and 6 closure compaction tests pass; four metadata artifacts and diff whitespace pass. | 104-sg-end |
| 2026-08-21 | 104-sg-end | complete | Closure guidance now rejects local-ready mutations and always states the next outcome. Runtime alias installation remained explicitly out of scope; unrelated dirty files remained unstaged. | final commit/push |
