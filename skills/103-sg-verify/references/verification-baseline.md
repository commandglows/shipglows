---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-11-21"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-baseline
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
  - skills/references/context-quality-contract.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Baseline gates extracted from the former monolithic verification-gates reference."
  - "User decision 2026-11-21: verification reads the diff itself and checks critical requirements with an independent property-level check."
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 4"
---

# Verification Baseline

Run the standard pass; the activation contract supplies shared gates.

## Order

1. Identify contract, changed surfaces, proof path, and development mode.
2. Verify outcome, observable success, and forbidden states.
3. Compare tasks, acceptance, invariants, dependencies, and consequences with reality.
4. Run proportional checks and applicable risk, quality, docs, and routing gates.
5. Return the strongest supported verdict; missing proof stays `partial` or worse.

For material work, refresh the bounded capsule and check its reasons, invalidated dependents, gaps and truncation against evidence. Small exact verification may stay targeted. Work serving the wrong accepted outcome is `not verified`.

## Success And Error

Report observable success/error behavior and evidence. Unproven moderate risk is `partial`; unproven high-risk security, data, money, destructive or critical-integration gaps are `not verified` or `blocked`.

## Proof Path Fit

The proof path must fit the surface. Unrelated checks cannot upgrade the verdict; atomic work may use focused evidence.

## Development And External Proof

Classify the validation surface. Missing required hosted/browser/manual proof blocks ship readiness and routes to its owner. Use canonical `fresh-docs` verdicts.

## Requirement Stickiness

Review `git status`, `git diff --stat`, then the diff itself, never the implementer's summary; flag edited assertions that pinned a requirement. For each critical or counter-intuitive requirement, a distinct agent that did not implement it writes, after implementation and unseen by the implementer, a property-level check of the requirement itself across inputs, not one example. Measure claimed memory, time or size externally. A failing check or dropped requirement is `partial` or `not verified`, never closure.

## Decision And Structure

Challenge shortcuts; require intended outcome, owner boundaries, durable structure, and proportional behavior-focused code quality.

## Baseline Result

Summarize outcome, success/error, proof fit, correctness, validation surface, risks, docs, owner routes. Standard success is `verified`, never `excellent`.
