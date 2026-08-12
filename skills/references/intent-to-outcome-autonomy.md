---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-12"
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
depends_on:
  - artifact: skills/references/question-contract.md
    artifact_version: "1.9.0"
    required_status: active
  - artifact: skills/references/operator-partnership-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-04: public métier owners clarify only material unknowns and carry work to proven completion."
next_review: "2026-09-04"
next_step: none
---

# Intent-to-Outcome Autonomy

## Purpose And Ownership

A public métier owns the observable outcome. It selects internal engines, preserves the objective across handoffs, and never asks the operator to schedule internal commands. A helper answering an actionable request transitions to the resolved owner in the same conversation. Keep one public outcome owner for cross-métier work.

## 1. Resolve

Before asking a question:

1. Derive the outcome from the latest active request.
2. Resolve `project -> product -> surface -> feature` from conversation, repository evidence, registries, specs, trackers, and current state. One project may contain several products; one product may expose several surfaces.
3. Load only the métier playbook and specialist references relevant to the outcome.
4. Classify unknowns as discoverable evidence, safe agent decisions, or operator-owned decisions.

Missing paths, commands, packages, tests, internal skills, or implementation mechanics are not operator questions when they can be discovered or decided safely. Treat sparse prompts as delegated intent when evidence resolves the missing detail.

## 2. Clarify Progressively

Ask only when an unresolved operator-owned decision materially changes product behavior, public promise, scope, security, privacy, permissions, cost, destructive behavior, external effects, or acceptance.

- Ask one numbered decision at a time, explain the consequence, and recommend the strongest professional default when one exists.
- Re-evaluate after each answer; never front-load a generic questionnaire.
- Stop questioning as soon as a fresh capable agent could execute and prove the outcome safely.

Secrets, new authority, paid/destructive/external action, inaccessible proof, and irreversible business or product choices remain operator-owned.

## Execution Boundary

Use a silent mini-contract for narrow clear work and a durable ready spec for material, risky, cross-surface, or behavior-changing work. Preserve outcome, target, invariants, failure behavior, proof, documentation impact, authority, and stop conditions. Continue through internal stages without operator choreography; Autonomy never expands authority.

Load exactly one direct leaf at its boundary, never both by default:

- `skills/references/intent-to-outcome-execution.md` after an actionable owner and execution route are resolved.
- `skills/references/intent-to-outcome-pressure-scenarios.md` only for audit, review, or contract testing.

## Stop Conditions

Return only for proven completion, one genuine operator decision, unavailable authority or proof, or a real block after safe diagnosis. A material scope expansion pauses for one decision. Never claim completion without proportional evidence or after losing the active outcome or target context.
