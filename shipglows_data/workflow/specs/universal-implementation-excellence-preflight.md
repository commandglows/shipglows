---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: ready
source_skill: 900-shipglows-core
scope: universal-implementation-excellence-preflight
owner: Diane
user_story: "As a ShipGlows operator, I want every code chantier to classify and apply its non-negotiable engineering guardrails before writing, then prove them again at the end, so frontend and backend quality cannot silently drift."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/implementation-excellence-preflight.md
  - skills/001-sg-build/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/references/reporting-contract.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/clean-code-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: every frontend or backend chantier must expose and enforce mandatory quality rules at the beginning and the end."
  - "The Bento implementation review showed that conditional token and shared-component rules can be bypassed when scope recognition is implicit."
next_step: /103-sg-verify universal-implementation-excellence-preflight
---

# Universal Implementation Excellence Preflight

## Status

ready

## Scope In

- Add one shared preflight for every authored or materially modified code surface.
- Classify frontend, backend, shared/domain, infrastructure, and documentation scope before the first write.
- Make frontend design authority, semantic tokens, shared primitives, accessibility, responsive behavior, and theme states explicit.
- Make backend trust-boundary validation, server authorization, isolation, concurrency/idempotence, recovery, observability, and migration safety explicit.
- Keep reusable domain decisions stack-agnostic where useful while keeping framework and provider adapters native to their stack.
- Emit a compact `🛡️ GARDE-FOUS` receipt at substantive code-chantier start.
- Re-run the applicable gates during verification and prevent a clean verdict when material drift remains.

## Scope Out

- No new framework, dependency, build, generated artifact, or hosted action.
- No replacement of existing design-system, clean-code, OWASP, or proof authorities.
- No repository-wide cleanup unrelated to the changed surface.
- No mandatory ceremony for branch-free copy or documentation-only micro-edits.

## Acceptance Criteria

- The shared contract distinguishes pre-write classification, implementation reclassification, and final enforcement.
- Feature, refactor, direct fix, and verification routes load the contract at the correct phase.
- Frontend work cannot pass while bypassing the canonical design authority or maintained shared primitives without an evidenced exception.
- Backend work cannot pass while relying on client-only authorization or leaving material isolation, replay, concurrency, recovery, or migration risk unresolved.
- Scope growth triggers reclassification before newly applicable code is written.
- A focused scenario test proves the contract, route wiring, start receipt, and final gate.
- Metadata lint, focused unit tests, skill budget audit, and runtime sync check pass without local build artifacts.

## Implementation Tasks

- [x] Add the canonical shared implementation-excellence preflight.
- [x] Wire feature/refactor, implementation, direct fix, and verification routes.
- [x] Add the visible start receipt to the reporting contract.
- [x] Register profiled conditional resources where applicable.
- [x] Add focused pressure-scenario contract tests.
- [x] Run proportional no-build validation and record the result.

## Pressure Scenarios

- `IEP-FRONTEND-TOKENS`: a UI feature proposes raw visual values instead of the canonical token authority.
- `IEP-FRONTEND-PRIMITIVE`: a new bespoke control duplicates a maintained shared component or accessible primitive.
- `IEP-BACKEND-AUTHZ`: a client-side check is mistaken for server authorization.
- `IEP-BACKEND-CONCURRENCY`: autosave or mutation code omits stale-write, replay, idempotence, or recovery reasoning.
- `IEP-SHARED-BOUNDARY`: reusable domain rules are unnecessarily coupled to a UI or provider adapter.
- `IEP-SCOPE-GROWTH`: a frontend-only task grows into backend mutation after the initial classification.
- `IEP-FINAL-ENFORCEMENT`: checks pass but an applicable mandatory rule remains unresolved.
- `IEP-MICRO-EDIT`: a branch-free documentation or copy edit avoids unnecessary ceremony.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Shared doctrine and route wiring | shared preflight, lifecycle skills, reporting contract, registry | approved contract |
| B | Mechanical proof | focused contract test and spec evidence | batch A |

## Current Chantier Flow

`900-shipglows-core ✅ -> 100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start ✅ -> 103-sg-verify ⚠️ source verified; runtime sync pre-existing drift`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved the shared preflight, visible start receipt, end enforcement, and focused tests. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Scope, invariants, pressure scenarios, and no-build proof path are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Bounded write sets and existing canonical authorities are identified. | 102-sg-start |
| 2026-08-21 | 102-sg-start | implemented | Added the shared three-phase gate, visible receipt, lifecycle wiring, registry entry, and focused scenario proof without builds or generated artifacts. | 103-sg-verify |
| 2026-08-21 | 103-sg-verify | partial | Source scenarios, metadata, budgets, registry graph, and diff checks pass; the all-runtime sync check is blocked by 28 pre-existing stale/broken public-skill symlinks outside this code-only scope. | Repair/install runtime links separately, then rerun sync check |
