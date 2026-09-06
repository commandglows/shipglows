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
  - tools/test_private_memory_offer_contract.py
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
billing. Core body 1992 -> 2047 estimated tokens; memory leaf
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

The common-path increase is only the compact predicate, justified by the observed
failure to offer durable reuse; detailed guidance incurs cost only in memory mode.
The unchanged scenario declarations are evaluated in CI with their existing
thresholds; no ceiling or baseline is raised. The offer checkpoint above covers the
previously undeclared path; it is a reviewed ledger, not a new activation profile.

CI runs focused text guards and existing loading/scenario checks. Text guards detect
named omissions; they do not prove arbitrary agent compliance. Manual pressure
review establishes the intended decisions; no live-user or model replay is claimed.
No local tests or runtime synchronization are part of this GitHub-only delivery.
