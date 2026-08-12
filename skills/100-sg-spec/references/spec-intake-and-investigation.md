---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 100-sg-spec
scope: spec-intake-and-investigation
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/100-sg-spec/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 extracted intake and investigation before authoring."
next_step: none
---

# Spec Intake and Investigation

## Route and depth

Choose the smallest complete contract: local mini-contract for deterministic isolated work; durable spec for new behavior, multi-file/cross-owner work, material risk, repeated ambiguity, or a supplied `Chantier potentiel`.

## Intake

Reconstruct actor, trigger, observable success, observable failure, primary edge case, scope boundaries, constraints, dependencies, affected consumers, documentation impact, and proof surface. Preserve all useful fields from a `Chantier potentiel` block.

Ask only after scanning project truth. A question is operator-owned only when its answer changes product meaning, audience, cost/control, platform commitment, permission, data policy, public claim, or external side effect.

## Investigation

Read the nearest governance artifacts, target code, adjacent patterns, tests, configs, recent relevant history, and linked contracts. Identify 3–5 first-read files, existing conventions to preserve, source-of-truth ownership, and validations available.

For greenfield work, establish launch/roadmap platform footprint before stack or blueprint selection. Apply compatible preferred presets before asking about uncovered material choices.

For external behavior, collect current official/primary documentation under the freshness gate. For UI, Atlas, product decisions, runtime, security, analytics, auth, tenant, data, money, or destructive work, identify the corresponding authority and unresolved decisions before authoring.

Stop before authoring when material truth is missing or contradictory.
