---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 001-sg-build
scope: build-readiness-route
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "BUILD-READY-SPEC preserves bounded readiness and governance gates."
next_step: none
---

# Build Readiness Route

`BUILD-READY-SPEC`: run `100-sg-spec`, then `101-sg-ready`; when unready, apply one correction pass and recheck. Stop boundedly when readiness still fails. Complete every artifact required by the selected workflow schema before implementation.

Before `102-sg-start`, ensure the technical and editorial governance corpus is present and current. Route missing/stale governance to `300-sg-docs update`, then continue the same run. Preserve a technical reader/docs-map pass and editorial updates when behavior, claims, README, FAQ, pricing, onboarding, or support surfaces change.

Before a material question, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`. Ask only when the answer changes behavior, security, permissions, money, side effects, public claims, proof, closure, or ship risk; present consequences and one recommendation.

Resolve model/topology only after readiness, loading `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` and the canonical delegation contract. Prepared parallel writes require the ready spec's non-overlapping batches and integration owner.
