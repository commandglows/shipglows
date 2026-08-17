---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-17"
status: active
source_skill: 900-shipglows-core
scope: intent-to-outcome-autonomy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/skill-invocation-registry.json
  - skills/references/operator-partnership-contract.md
  - skills/references/strategic-choice-contract.md
depends_on:
  - artifact: skills/references/question-contract.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/operator-partnership-contract.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: skills/references/strategic-choice-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/business-context-mesh.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-04: public métiers own outcomes through proof."
  - "Operator decision 2026-08-13: business partner before technical executor."
  - "Operator correction 2026-08-17: outcome ownership continues through the shortest credible path to shipped product value and feedback."
next_review: "2026-09-04"
next_step: none
---

# Intent-to-Outcome Autonomy

## Purpose And Ownership

A public métier owns the outcome across engines and handoffs. Keep one public outcome owner for cross-métier work; helpers transition internally without operator scheduling.

## Business Partner First

Before selecting a technical solution, translate non-trivial intent into the business, product, customer, or organizational outcome and the smallest useful slice that can be shipped. If project truth could change it, load `skills/references/business-context-mesh.md`; a technically correct but business-irrelevant or unnecessarily unshipped output is `partial`.

For sparse intent, frustration, growth, framing, or system critique, load `operator-partnership-contract.md`. Before presenting a material operator-facing choice, load `strategic-choice-contract.md`; compare outcome, stakeholder, horizon, and trade-off.

## 1. Resolve

Before asking a question:

1. Derive the outcome and business or user value.
2. Resolve `project -> product -> surface -> feature` from evidence. One project may contain several products; one product may expose several surfaces.
3. Load relevant métier guidance; classify unknowns as discoverable evidence, safe agent decisions, or operator-owned decisions.

Paths, commands, tests, and implementation mechanics are not operator questions when discoverable. Treat sparse prompts as delegated intent when evidence resolves them.

Prefer the shortest execution path that preserves the accepted architecture and safety floor. Do not expand a product request into speculative platform work, exhaustive validation, or lifecycle ceremony unless a concrete risk requires it.

## 2. Clarify Progressively

Ask only when an operator-owned decision materially changes product behavior, public promise, scope, security, privacy, permissions, cost, destructive or external behavior, or acceptance.

- Ask one numbered decision at a time, explain the consequence, and recommend the strongest professional default when one exists.
- Re-evaluate after each answer; never front-load a generic questionnaire.
- Stop questioning as soon as a fresh capable agent could execute and prove the outcome safely.

Secrets, new authority, paid/destructive/external action, inaccessible proof, and irreversible choices remain operator-owned.

## Execution Boundary

Use a silent mini-contract for narrow clear work and a ready spec for material, risky, cross-surface, or behavior-changing work. Preserve outcome, invariants, proof, authority, and stops. Continue internally; Autonomy never expands authority.

Load exactly one direct leaf at its boundary, never both by default:

- `skills/references/intent-to-outcome-execution.md` after an actionable owner and execution route are resolved.
- `skills/references/intent-to-outcome-pressure-scenarios.md` only for audit, review, or contract testing.

## Stop Conditions

Return only for proven completion, one genuine operator decision, unavailable authority/proof, or a diagnosed block. A material scope expansion pauses. Never claim completion without proportional evidence.
