---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-excellence
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Excellence focus extracted from the former monolithic verification-gates reference."
next_step: "/103-sg-verify mode=excellence progressive lifecycle activation compaction wave 4"
---

# Excellence Focus Pass

Run only after standard readiness passes and only for explicit `mode=excellence` or an unambiguous natural-language request. This is a fresh second focus beyond acceptance criteria, not a rerun or a demand for more test volume.

Challenge with evidence: user value/comprehension, cross-surface coherence, duplication/structure, user or operator friction, durability/robustness, and merely adequate choices with a bounded professional alternative. Name challenged surfaces and evidence; inherited confidence or the standard checklist cannot prove excellence.

## Materiality

A material gap changes a reasonable ship, follow-up, or architecture decision by improving user outcome, coherence, reliability, security/privacy, performance/operations, maintainability/durability, duplication, or workload. It needs evidence and a bounded repair or owner route.

Pure taste, unsupported polish, speculative preferences, and generic “could be better” observations are non-material suggestions; they do not reopen the chantier.

## Verdict And Routing

- `verified_with_excellence_gaps`: readiness remains valid and at least one material gap remains; preserve earlier verified history and route bounded follow-up.
- `excellent`: readiness passes, the fresh pass is evidenced, and no material gap remains.
- Proof/correctness/security/blocking-risk failure remains `partial`, `not verified`, or `blocked`; never relabel it as excellence.

Bounded stable repairs may be applied and rechecked. Product/acceptance/architecture changes route to spec/exploration; specialist design, copy, code/security, or performance gaps route to their owner; hosted/auth/browser/manual gaps route to proof owners; multi-owner or security-sensitive repairs use ready-spec lifecycle.

## Pressure Scenarios

- `EXCELLENCE-001 STANDARD-DEFAULT`: normal invocation stays standard, may be verified, and makes no excellence claim.
- `EXCELLENCE-002 MATERIAL-GAP`: an evidenced gap after readiness returns `verified_with_excellence_gaps`, preserves prior history, and creates bounded follow-up.
- `EXCELLENCE-003 NO-MATERIAL-GAP`: evidenced fresh pass with no material gap allows `excellent`.
- `EXCELLENCE-004 PROOF-OR-RISK-FAILURE`: missing hosted proof or blocking correctness/security keeps the lower verdict.
- `EXCELLENCE-005 NON-MATERIAL-SUGGESTION`: optional taste-level advice does not reopen the chantier.
- `EXCELLENCE-006 ATOMIC-PROPORTIONALITY`: a deterministic atomic change keeps focused evidence and does not force an unrelated exhaustive audit.
