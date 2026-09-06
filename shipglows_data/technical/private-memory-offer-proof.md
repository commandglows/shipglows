---
artifact: technical_documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-06"
updated: "2026-09-06"
status: active
source_skill: 900-shipglows-core
scope: private-memory-offer-proof
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/603-sg-private/references/memory-operations.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved one general predicate and progressive private guidance."
next_step: none
---

# Private memory offer proof

Mini-contract: suggest durable reuse without accessing private storage or granting
persistence authority. The core owns the decision predicate; the existing private
memory leaf owns record guidance. No new schema, backend, invocation or access
permission. No actual private values enter this change.

Scenario-first review, fixed before implementation:

| Evidence / intent | Required action |
| --- | --- |
| Verified reusable pointer, storage unknown | Offer once; no private read or claim of absence. |
| Unverified or transient information | Continue task; no offer under this predicate. |
| Known saved or declined in this conversation | No repeated offer. |
| Interest in guidance only | Select private owner; show minimal proposed record/destination; no write. |
| Explicit approval of a complete record | Existing dry-run/revision/apply gates; no redundant approval. |
| Suspected secret | Existing private owner stops persistence. |
| Remembered pointer used later | No new authority over target actions. |

## Loading review

Baseline: ab6784bfcd211894137b7e7e4269ea40762f5abc. Estimator: ceil(text characters / 4), not provider
billing. Core full file 1992 -> 1990 estimated tokens; memory leaf
965 -> 1061. All other files on compared paths remain unchanged.

Before offer / refusal checkpoint:
`shipglows -> 000-shipglows -> existing independently triggered references -> reporting`.
The core addition owns a reusable cross-domain decision. No new file read or depth;
the private wrapper, engine and leaf remain cold. Unknown storage is not a lookup trigger.

After explicit interest:
the existing `sg-private -> 603-sg-private -> memory-operations` route, including
its canonical paths, roots, intent and reporting requirements. No new edge or
sibling cascade; the existing selected leaf gains bounded guidance when the
record decision needs it. Existing safety and proof loads remain mandatory.

Nearby core prose is compacted without removing decisions or guards; the predicate fixes the observed
failure to offer durable reuse without increasing common-path cost. Guidance stays in memory mode.
The unchanged scenario declarations are evaluated in CI with their existing
thresholds; no ceiling or baseline is raised. The offer checkpoint above covers the
previously undeclared path; it is a reviewed ledger, not a new activation profile.

CI runs existing loading/scenario checks and a frozen-baseline diagnostic. Manual
pressure review establishes intended decisions; no live-user or model replay is claimed.
Initial CI exposed scenario-budget failures; these blocked merging until compared
with the baseline and resolved by the approved repair below. No threshold is waived.
No local tests or runtime synchronization are part of this GitHub-only delivery.

## Shared reporting budget repair

The operator approved resolving the four pre-existing failures through the shared
reporting reference. Baseline for this repair is `50ef313b2f289b4d0bed9deb292f9225a95bbd9c`.
The full reference shrinks from 9,908 to 8,040 Unicode characters (2,477 to 2,010
estimated tokens using the evaluator's ceil(chars/4)). Removed examples were illustrative; direct triggers, all report
states, consent/authority, time, layout, continuity, privacy and proof gates remain.
Metadata dependencies are unchanged; no loading edge, scenario read, threshold,
baseline ledger or evaluator is changed. Existing wording-dependent expectations
follow equivalent reviewed clauses; negative guards and leaf checks remain.
CI compares all twelve scenarios with this frozen baseline and runs existing
reporting, common-path and loading tests. No model replay is claimed.

Final reporting/code proof on 7724038e: 46 reporting/common-path tests and five
loading tests passed in GitHub Actions run 34040008021. All twelve scenarios
are structurally valid and within unchanged budgets. The evidence-only receipt
update is tested again on its own final head by the same workflow.

| Scenario | Frozen 50ef313b | After repair | Depth (unchanged) |
| --- | ---: | ---: | ---: |
| common-bug-proof-selection | 24016 | 23549 | 3 |
| common-docs-direct | 4424 | 4424 | 1 |
| common-feature-approval | 34876 | 34409 | 1 |
| common-page-comprehension | 19895 | 19428 | 1 |
| common-resume-missing | 19498 | 19031 | 1 |
| common-resume-ready | 12514 | 12514 | 1 |
| common-verify-direct | 4424 | 4424 | 1 |
| core-help | 11226 | 10759 | 2 |
| core-skill-audit | 20653 | 20186 | 2 |
| engineering-deps-witness | 23112 | 22645 | 2 |
| quality-continue-proof-complete | 19767 | 19300 | 2 |
| quality-core-exact-correction | 34982 | 34515 | 2 |
