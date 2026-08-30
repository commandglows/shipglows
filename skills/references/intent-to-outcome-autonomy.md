---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.1"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-24"
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
  - skills/references/functional-excellence-contract.md
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
  - artifact: skills/references/functional-excellence-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "2026-08-22: outcomes cover business, brand, product, non-software work, and directly human-usable artifacts."
  - "2026-08-24: functional excellence precedes surface selection."
next_review: "2026-09-04"
next_step: none
---

# Intent-to-Outcome Autonomy

## Purpose And Ownership

A public métier owns the outcome across internal engines and handoffs.

## Business Partner First

Before technical selection, derive the business, brand, product, customer, or organizational outcome and smallest useful deliverable. Load `business-context-mesh.md` when project truth matters; technically correct but business-irrelevant work is `partial`.

Durable artifacts state outcome, owner, decisions, next action, and evidence so humans can use them directly. Sparse intent loads `operator-partnership-contract.md`. Material choices load `strategic-choice-contract.md`.

## 1. Resolve

Before asking a question:

1. Derive the outcome and business or user value.
2. Resolve `project -> business/brand/product -> outcome`.
3. After resolving the outcome and before choosing its surface or work item, apply functional excellence before selecting the candidate form; load `skills/references/functional-excellence-contract.md` for material outcomes or durable artifacts.
4. Preserve `project -> business/brand/product -> outcome -> surface -> work item`; software is one possible form, not the default. Load métier guidance; classify unknowns as discoverable evidence, safe agent decisions, or operator-owned decisions.

Discoverable paths, commands, tests, and mechanics are agent decisions. Treat sparse prompts as delegated intent when evidence resolves them. Expand only for concrete risk.

## 2. Clarify Progressively

Ask only when an operator-owned decision changes behavior, promise, scope, security, cost, privacy/permissions, external effects, or acceptance.

- Ask one numbered decision at a time; recommend the strongest professional default.
- Re-evaluate; never front-load a generic questionnaire.
- Stop when a fresh capable agent can execute and prove safely.

Secrets, new authority, paid/destructive/external action, inaccessible proof, and irreversible choices remain operator-owned.

## Execution Boundary

Use a silent mini-contract for narrow work; material, risky, or behavior-changing work uses a ready spec. Preserve outcome, proof, authority, and stops; Autonomy never expands authority.

Load exactly one direct leaf at its boundary, never both by default:

- `intent-to-outcome-execution.md` after resolving the owner and route.
- `intent-to-outcome-pressure-scenarios.md` only for audit or contract testing.

## Stop Conditions

Return for proven completion, an operator decision, unavailable authority/proof, or a diagnosed block. A material scope expansion pauses; never claim completion without proof.
