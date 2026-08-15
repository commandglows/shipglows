---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-15"
status: active
source_skill: 104-sg-end
scope: closure-bookkeeping-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/104-sg-end/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-5 independent audit restored summary-only and ship-ownership boundaries."
  - "Operator clarification 2026-08-15: documentation reflection must be enforced and visible at closure."
next_step: none
---

# Closure Bookkeeping Playbook

Use this playbook for all closure bookkeeping decisions.

## Execution mode and closure result

Choose execution mode `full`, `partial`, or `summary-only`. Then record one result:

- `closed`: implementation, proof, closure tracking, and source-of-truth sync are complete.
- `partial`: work advanced but one or more critical proof or docs gates remain.
- `deferred`: unresolved owner exists and is explicit.
- `blocked`: missing context or safety gate prevents safe closure.
- `not applicable`: only closure narrative requested.

In `summary-only`, produce a read-only summary with no tracker, changelog, memory, spec, or archive mutation.

If proof or ship is not complete, never set `closed`.

## Pre-flight checks

- Load `shipglows-owned-preflight.md`.
- Load `closure-archive-guard.md`.
- Load `documentation-reflection-gate.md`.
- If a product decision is reused, route through `product-decision-chain.md`.

## Step 1: Track summary

- Distill what was done, what failed, and what is truly complete.
- Preserve a direct boundary with unresolved proof.

## Step 2: Closure status

- Set `closed` only if evidence, proof, and sync are complete.
- Use `partial` when residual risk or stale docs remain.
- Use `blocked` on missing context, missing tests, or unresolved safety gates.

## Step 3: documentation reflection

- Classify documentation as `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>`.
- Apply directly mapped impacted documentation updates before setting `closed`.
- A material `needs review` result forces `partial`; tests, builds, tracker state, or Git state cannot override it.
- Include the exact classification visibly in every closure report, including `not impacted`.

## Step 4: tracker/changelog updates

- Skip this step entirely in `summary-only`.
- Apply one compact row for the current task entry.
- Keep changelog scoped by intent (Added/Changed/Fixed/Security/Removed).
- Never claim production readiness from closure text.

## Step 5: next action

- If proof is unresolved, route to `103-sg-verify`.
- If ship remains unfinished, route to `005-sg-ship`.
- If backlog/priority is needed, route to `011-sg-pilotage`.
- If no unique next owner, keep the result explicit and local.

This playbook never commits or pushes.
