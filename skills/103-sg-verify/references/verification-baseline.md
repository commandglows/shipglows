---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
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
depends_on: []
supersedes: []
evidence:
  - "Baseline gates extracted from the former monolithic verification-gates reference."
next_step: "/103-sg-verify progressive lifecycle activation compaction wave 4"
---

# Verification Baseline

This leaf playbook performs the standard pass after scope and mode selection. The activation contract supplies every applicable shared gate.

## Order

1. Identify work-item contract, changed surfaces, proof path, and development mode.
2. Verify user-story outcome plus observable success and forbidden error states.
3. Compare tasks, acceptance criteria, expected files, invariants, and linked consequences with actual state.
4. Check metadata and declared dependency versions/statuses when a spec exists.
5. Inspect bug records and required manual checklist rows.
6. Run proportional technical checks and judge their exact evidence boundary.
7. Apply risk, decision-quality, documentation, and owner-routing gates selected by the activation contract.
8. Return the strongest verdict supported by all evidence; missing proof stays `partial` or worse.

## Success And Error

Report expected observable success, system effect, and evidence. Report expected error handling, forbidden states, and evidence. Unproven moderate-risk behavior is `partial`; high-risk gaps involving security, data, money, destructive behavior, or critical external integration are `not verified` or `blocked`.

## Proof Path Fit

Confirm `test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof` matches the changed surface. Passing checks outside the accepted proof path cannot upgrade the verdict. A deterministic atomic change may use focused proportional evidence.

## Development And External Proof

Classify local, preview-push, hybrid, unknown preview, or unknown when the validation surface matters. Required hosted/browser/manual proof missing in preview/hybrid scope prevents ship readiness and routes to the concrete proof owner. Current external behavior uses `fresh-docs checked`, `fresh-docs not needed`, `fresh-docs gap`, or `fresh-docs conflict`.

## Bug And Manual Gates

Bug source of truth is `shipglows_data/workflow/bugs/*.md`; the aggregate index is secondary. Any open high/critical in-scope bug blocks ship. Required checklist rows must pass, have an accepted exception, or transition to stronger recorded proof. `NOT_RUN`, `FAIL`, and `BLOCKED` otherwise produce `partial` or `not verified`.

## Decision And Structure

Challenge fastest-path shortcuts. Verify that the result improves the stated friction or outcome, preserves owner boundaries and durable structure, and does not add decorative layers. Clean code is proportional and behavior-focused, not stylistic dogma.

## CI And Technical Checks

When workflows exist, confirm path filters run owned jobs, unrelated expensive jobs skip, manual dispatch remains available, and branch protection does not require routinely skipped jobs without an umbrella status. Run only relevant lint, typecheck, and tests; a failure is critical. No local workflow means `not assessed`, with the responsible repository named when known.

## Baseline Result

Summarize user story, success/error, proof-path fit, completeness, correctness, development mode, fresh docs, bug/manual status, risks, documentation, and owner routes. Standard success is `verified`, never `excellent`.
