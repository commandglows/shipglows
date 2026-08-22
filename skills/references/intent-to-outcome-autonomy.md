---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-22"
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
  - "Operator decision 2026-08-22: outcome resolution covers business, brand, product, and non-software work, and durable artifacts must remain directly usable by humans."
next_review: "2026-09-04"
next_step: none
---

# Intent-to-Outcome Autonomy

## Purpose And Ownership

A public métier owns the outcome across internal engines and handoffs.

## Business Partner First

Before technical selection, derive the business, brand, product, customer, or organizational outcome and smallest useful deliverable. Load `business-context-mesh.md` when project truth could change it; technically correct but business-irrelevant work is `partial`.

Durable artifacts state outcome, owner, decisions, next action, and evidence so humans can use them directly; agent metadata remains supplementary.

For sparse intent or system critique, load `operator-partnership-contract.md`. Material choices load `strategic-choice-contract.md` and compare outcome, stakeholder, horizon, and trade-off.

## 1. Resolve

Before asking a question:

1. Derive the outcome and business or user value.
2. Resolve `project -> business/brand/product -> outcome -> surface -> work item`; software is one possible form, not the default.
3. Load relevant métier guidance; classify unknowns as discoverable evidence, safe agent decisions, or operator-owned decisions.

Discoverable paths, commands, tests, and mechanics are agent decisions. Treat sparse prompts as delegated intent when evidence resolves them.

Prefer the shortest path preserving accepted architecture and safety. Expand scope or proof only for concrete risk.

## 2. Clarify Progressively

Ask only when an operator-owned decision materially changes behavior, promise, scope, security, privacy, permissions, cost, external effects, or acceptance.

- Ask one numbered decision at a time, explain the consequence, and recommend the strongest professional default when one exists.
- Re-evaluate after each answer; never front-load a generic questionnaire.
- Stop when a fresh capable agent can execute and prove safely.

Secrets, new authority, paid/destructive/external action, inaccessible proof, and irreversible choices remain operator-owned.

## Execution Boundary

Use a silent mini-contract for narrow clear work and a ready spec for material, risky, cross-surface, or behavior-changing work. Preserve outcome, invariants, proof, authority, and stops. Continue internally; Autonomy never expands authority.

Load exactly one direct leaf at its boundary, never both by default:

- `skills/references/intent-to-outcome-execution.md` after an actionable owner and execution route are resolved.
- `skills/references/intent-to-outcome-pressure-scenarios.md` only for audit, review, or contract testing.

## Stop Conditions

Return only for proven completion, one genuine operator decision, unavailable authority/proof, or a diagnosed block. A material scope expansion pauses. Never claim completion without proportional evidence.
