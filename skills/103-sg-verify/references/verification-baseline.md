---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-30"
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
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 4"
---

# Verification Baseline

Perform the standard pass after scope/mode selection; the activation contract supplies applicable shared gates.

## Order

1. Identify contract, changed surfaces, proof path, and development mode.
2. Verify outcome, observable success, and forbidden states.
3. Compare tasks, acceptance, invariants, dependencies, and consequences with reality.
4. Run proportional checks and applicable risk, quality, docs, and routing gates.
5. Return the strongest supported verdict; missing proof stays `partial` or worse.

For material work, consume or refresh the bounded capsule; compare it with implementation/evidence and verify reasons, invalidated dependents, gaps and truncation. Small exact verification may stay targeted. Work serving the wrong accepted outcome is `not verified`.

## Success And Error

Report observable success/error behavior and evidence. Unproven moderate risk is `partial`; high-risk security, data, money, destructive, or critical-integration gaps are `not verified` or `blocked`.

## Proof Path Fit

Confirm the selected proof path fits the surface. Unrelated checks cannot upgrade the verdict; atomic work may use focused evidence.

## Development And External Proof

Classify the validation surface. Missing required hosted/browser/manual proof prevents ship readiness and routes to its proof owner. Use the canonical `fresh-docs` verdicts for external behavior.

## Decision And Structure

Challenge shortcuts; require the intended outcome, owner boundaries, durable structure, and proportional behavior-focused code quality.

## Baseline Result

Summarize outcome, success/error, proof fit, correctness, validation surface, risks, docs, and owner routes. Standard success is `verified`, never `excellent`.
