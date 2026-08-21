---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "2.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: reviewed
source_skill: 900-shipglows-core
scope: mandatory-next-block-and-git-backed-closure
owner: Diane
user_story: "As a ShipGlows operator, I want every chantier report to identify the highest-value evidence-backed continuation and every mutated Git chantier to be remotely persisted before closure, so ShipGlows behaves as an autonomous business partner instead of ending with ceremonial or null next steps."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/reporting-pressure-scenarios.md
  - skills/references/next-outcome-selection.md
  - skills/references/audit-cadence-matrix.json
  - skills/references/git-milestone-delivery-contract.md
  - skills/011-sg-pilotage/references/priorities-playbook.md
  - skills/002-sg-maintain/references/maintenance-playbooks.md
  - skills/104-sg-end/SKILL.md
  - tools/audit_cadence_status.py
  - tools/test_audit_cadence_status.py
  - shipglows_data/workflow/TASKS.md
  - shipglows_data/workflow/AUDIT_LOG.md
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "2.11.0"
    required_status: active
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-08-21: every final report must include a SUITE block."
  - "Operator defect example 2026-08-21: a documentation chantier was reported corrected while its changes remained local without commit or push."
  - "Operator correction 2026-08-21: no-action-required wording violates business continuity; SUITE must select open conversational work, pending proof or delivery, active chantiers, tracker priorities, overdue audits, then a grounded business improvement."
  - "Read-only audit 2026-08-21: TASKS.md and AUDIT_LOG.md exist, but no canonical audit-cadence matrix exists."
next_step: Review and merge ShipGlows PR 24, then complete the authenticated visual review of site PR 13.
---

# Mandatory Next Block And Git-Backed Closure

## Status

complete — the null-continuation escape hatch is removed and the evidence-backed continuity ladder is shipped

## Acceptance Criteria

- Every chantier report contains `🧭 SUITE` with one concrete evidence-backed next outcome; `none`, `no action required`, ceremonial menus, and semantic equivalents are forbidden.
- Continuation selection follows this order: unfinished current-conversation outcome; pending proof/review/PR/delivery; active chantier; `TASKS.md` P0 then P1/P2/P3; most overdue audit; grounded product/business improvement.
- Agent-runnable work inside the authorized current chantier continues before a final report instead of being downgraded into a suggestion.
- A new unrelated chantier remains subject to normal scope and mutation approval; autonomy never invents urgency or authority.
- A canonical audit-cadence matrix defines default maximum ages and event triggers, while projects may document stricter overrides.
- `AUDIT_LOG.md` supplies last-run truth and the deterministic checker ranks overdue or never-run audit domains.
- A Git-backed chantier with any intentional mutation cannot close with no commit, a local-only commit, a missing push, or a failed push.
- `Aucun commit ni push` is truthful only for genuinely read-only, non-mutating, or non-Git work.
- Documentation-only mutations obey the same commit/push closure invariant as code changes.
- A local mutation awaiting delivery is reported `delivery pending`, and its mandatory suite is commit/push delivery.
- Focused tests cover the supplied failure example and preserve unrelated dirty files.

## Pressure Scenarios

- `SSRP-024 mandatory next block`: every chantier report includes a useful `🧭 SUITE` and rejects null or no-action-required outcomes.
- `SSRP-025 conversation continuity`: an unfinished outcome or pending PR/proof in the current conversation wins over tracker and audit candidates.
- `SSRP-026 tracker priority`: when conversation and delivery are clear, P0 then P1/P2/P3 wins without urgency inflation.
- `SSRP-027 overdue audit fallback`: when no actionable tracker item exists, the most overdue required audit becomes the suite.
- `SSRP-028 grounded business continuation`: when operational sources are clear, choose one evidence-backed product, editorial, security, quality, or funnel improvement rather than fabricate busywork.
- `SSRP-029 authority boundary`: a selected next outcome does not silently authorize a new unrelated mutation.
- `GMD-MUTATED-DOC-NO-LOCAL-CLOSURE`: changed documentation plus `Aucun commit ni push · modifications locales prêtes` cannot produce a completed verdict.
- `GMD-LOCAL-COMMIT-NO-CLOSURE`: a commit not present upstream remains `delivery pending`.

## Implementation Tasks

- [x] Make the final-report next block mandatory.
- [x] Harden Git-backed closure for every mutation, including documentation.
- [x] Add focused mechanical proof and align closure guidance.
- [x] Commit and push the validated milestone and final record.
- [x] Replace null continuation with the deterministic next-outcome ladder.
- [x] Add the canonical audit-cadence matrix and overdue-audit checker.
- [x] Connect pilotage and maintenance discovery to the same shared sources.
- [x] Add focused pressure scenarios for conversation, delivery, tracker, audit, business fallback, and authority.
- [x] Record the correction in TASKS/AUDIT_LOG doctrine without rewriting operational history.
- [x] Commit and push each validated correction milestone.

## Current Chantier Flow

`original contract ✅ -> null-continuation defect confirmed ✅ -> spec/reopened ready ✅ -> next-outcome ladder ✅ -> audit cadence ✅ -> focused proof ✅ -> commit/push ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | approved | Operator approved mandatory SUITE and Git-backed closure correction after clarification of pressure and regression tests. | 102-sg-start |
| 2026-08-21 | 100-sg-spec | ready | Exact failure examples, invariants, and focused proof are explicit. | 101-sg-ready |
| 2026-08-21 | 101-sg-ready | ready | Existing reporting and Git delivery contracts provide narrow correction points; unrelated dirty files remain excluded. | 102-sg-start |
| 2026-08-21 | 102-sg-start | milestone pushed | Mandatory SUITE, Git-backed documentation closure, supplied failure cases, and focused tests implemented in commit `a347490` and pushed upstream. | 103-sg-verify |
| 2026-08-21 | 103-sg-verify | verified | 30 reporting/Git delivery tests and 6 closure compaction tests pass; four metadata artifacts and diff whitespace pass. | 104-sg-end |
| 2026-08-21 | 104-sg-end | complete | Closure guidance now rejects local-ready mutations and always states the next outcome. Runtime alias installation remained explicitly out of scope; unrelated dirty files remained unstaged. | final commit/push |
| 2026-08-21 | 900-shipglows-core | ready | Operator rejected the prior no-action-required escape hatch and approved a continuity ladder backed by conversation state, delivery proof, tracker priority, audit cadence, and business value. | implement scenario-first correction |
| 2026-08-21 | 102-sg-start | milestone pushed | The deterministic continuity ladder, cadence matrix, audit status checker, writer doctrine, pilotage/maintenance routing, and focused scenarios shipped in commit `f415441`. | 103-sg-verify |
| 2026-08-21 | 103-sg-verify | verified | 29 focused scenarios pass; metadata, JSON parsing, and diff hygiene pass; the real audit log yields deterministic actionable freshness results without misclassifying issue text. | 104-sg-end |
| 2026-08-21 | 104-sg-end | complete | The supplied null-SUITE failure is prevented, operational history is preserved, and unrelated design/preflight changes remain unstaged. | review and merge PR 24, then visually review site PR 13 |
