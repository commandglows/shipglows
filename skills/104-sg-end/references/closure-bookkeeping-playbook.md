---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-30"
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
  - "Operator decision 2026-08-16: editorial impact is classified independently and visibly at every closure."
  - "Operator correction 2026-08-17: clean completed daily work proceeds to bounded commit/push by default instead of accumulating locally."
  - "Operator approval 2026-08-30: changelog impact is classified visibly for every managed-repository closure and significant history capture is bounded to one event."
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

## Step 3b: editorial reflection

- Classify editorial impact independently as `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>`.
- Inspect declared public surfaces and user-visible promises; documentation status never substitutes for this classification.
- `No declared public surface` is a valid no-impact reason when project evidence proves it.
- Apply directly mapped public updates already inside approved scope before setting `closed`; otherwise a material `needs review` result forces `partial`.
- Include the exact editorial classification visibly in every closure report and never create filler content to satisfy the gate.

## Step 4: tracker/changelog updates

- Skip this step entirely in `summary-only`.
- Apply one compact row for the current task entry.
- Keep changelog scoped by intent (Added/Changed/Fixed/Security/Removed).
- Classify the closure as `public-ready`, `internal-only`, `not applicable`, or `needs review`; include the classification visibly beneath `📰 CHANGELOG`.
- `public-ready` confirms safe eligible copy for a declared delivery path, not publication. Published, deployed, or available claims require matching delivery evidence.
- When structured history is adopted, append at most one significant event per closure. Do not create filler events or expose raw internal history to public consumers.
- A material `needs review` result forces `partial`; `internal-only` and `not applicable` remain valid clean outcomes when their reasons are concrete.
- Never claim production readiness from closure text.

## Step 5: next action

- If proof is unresolved, route to `103-sg-verify`.
- If a clean completed daily chantier is not pushed, route directly to `005-sg-ship`; treat delivery as pending until push succeeds, the operator explicitly chooses local-only work, or a concrete blocker is recorded.
- If backlog/priority is needed, route to `011-sg-pilotage`.
- If no unique next owner, keep the result explicit and local.

This playbook never commits or pushes.
