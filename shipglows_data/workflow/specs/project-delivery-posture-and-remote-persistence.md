---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: reviewed
source_skill: 900-shipglows-core
scope: project-delivery-posture-and-remote-persistence
owner: Diane
user_story: "As a solo product operator, I want each project to declare its delivery posture while every validated milestone is backed up remotely, so professional release safeguards stay proportional without risking local work loss."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-delivery-policy.md
  - skills/references/project-development-mode.md
  - skills/references/git-milestone-delivery-contract.md
  - skills/305-sg-init
  - skills/005-sg-ship
depends_on:
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: project maturity, validation surface, and remote Git persistence are separate concerns."
  - "Operator decision 2026-08-21: GitHub backup remains mandatory during development, including after validated milestones."
next_step: none
---

# Project Delivery Posture And Remote Persistence

## Status

complete

## Scope In

- Add a provider-agnostic delivery posture: `development`, `published`, or `sensitive-production`.
- Keep the existing development mode as the separate validation-surface contract.
- Make remote Git persistence mandatory for validated milestones and clean chantier completion in every posture.
- Default to short-lived work branches and `main` as the production branch, without imposing a permanent `develop` branch.
- Derive proportional preview, staging, production, and branch-protection expectations.
- Integrate the policy into project bootstrap and the development, verification, ship, deploy, and closure routes.
- Preserve unknowns and distinguish declared policy from observed provider state.

## Scope Out

- No provider installation, repository settings mutation, deployment, merge, release, or production change.
- No secrets, executable project commands, or machine-specific configuration in the policy.
- No assumption that development means local-only or that a push proves deployed behavior.
- No forced staging environment for ordinary unpublished products.

## Acceptance Criteria

- `development` never disables milestone or final remote persistence.
- `published` requires preview-backed review before production merge for deployable changes.
- `sensitive-production` additionally requires staging or an explicitly documented equivalent isolation gate.
- The production branch defaults to `main`; work branches are short-lived; permanent `develop` remains opt-in only with a documented reason.
- Existing `local`, `vercel-preview-push`, and `hybrid` validation modes remain valid and migrate without data loss.
- Missing, stale, contradictory, or unsupported policy is reported rather than silently guessed.
- Focused pressure tests cover posture separation, Git persistence, provider neutrality, migration, and invalid combinations.

## Implementation Tasks

- [x] Add the shared project delivery policy and align milestone persistence.
- [x] Integrate bootstrap and lifecycle owners.
- [x] Add focused contract tests and canonical documentation.
- [x] Commit and push each completed milestone, then complete final delivery.

## Pressure Scenarios

- `PDP-DEVELOPMENT-NOT-LOCAL-ONLY`: development posture still requires remote Git persistence.
- `PDP-SEPARATE-AXES`: maturity, validation surface, and observed provider state cannot overwrite one another.
- `PDP-PUBLISHED-PREVIEW`: published deployable changes require preview-backed review.
- `PDP-SENSITIVE-STAGING`: sensitive production requires staging or a documented equivalent isolation gate.
- `PDP-NO-PERMANENT-DEVELOP`: short-lived branches are default; permanent `develop` is not imposed.
- `PDP-DECLARED-VS-OBSERVED`: provider detection reports drift without silently rewriting declared policy.
- `PDP-LEGACY-MODE`: existing development-mode projects remain valid during migration.
- `GMD-MILESTONE-PUSH`: a validated milestone is committed and pushed before the next milestone starts.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Canonical policy and persistence | shared policy, Git delivery doctrine, approval/lifecycle semantics, focused tests, spec | approved plan |
| B | Activation and documentation | bootstrap and lifecycle skills, technical docs, final spec evidence | batch A pushed |

## Current Chantier Flow

`900-shipglows-core ✅ -> 100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start ✅ -> milestone commit/push ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> final commit/push ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved the corrected plan with mandatory GitHub persistence in every posture and after each validated milestone. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Scope, migration boundary, pressure scenarios, and two sequential pushed milestones are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Existing development-mode and Git-delivery contracts provide compatible extension points; unrelated dirty files are excluded. | 102-sg-start |
| 2026-08-21 | 102-sg-start | milestone pushed | Added the canonical posture contract, milestone-push authority, ship behavior, and focused pressure tests. Commit `4b81843` is present on the configured upstream. | lifecycle integration |
| 2026-08-21 | 103-sg-verify | verified | 41 focused scenarios and six metadata artifacts pass; diff whitespace is clean. The source contract remains provider-agnostic and legacy development modes remain compatible. | 104-sg-end |
| 2026-08-21 | 104-sg-end | complete | Bootstrap, start, verify, end, ship, deploy, production verification, and canonical technical guidelines consume the delivery policy. Commit `ed3afe9` is present on the configured upstream. Runtime alias installation was intentionally excluded; the read-only sync check reported missing local aliases. | final commit/push |
