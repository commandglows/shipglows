# Closure Bookkeeping Playbook

Use this playbook for all closure bookkeeping decisions.

## Closure mode

Choose one mode:

- `closed`: implementation, proof, closure tracking, and source-of-truth sync are complete.
- `partial`: work advanced but one or more critical proof or docs gates remain.
- `deferred`: unresolved owner exists and is explicit.
- `blocked`: missing context or safety gate prevents safe closure.
- `not applicable`: only closure narrative requested.

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

## Step 3: tracker/changelog updates

- Apply one compact row for the current task entry.
- Keep changelog scoped by intent (Added/Changed/Fixed/Security/Removed).
- Never claim production readiness from closure text.

## Step 4: next action

- If proof is unresolved, route to `103-sg-verify`.
- If ship remains unfinished, route to `005-sg-ship`.
- If backlog/priority is needed, route to `011-sg-pilotage`.
- If no unique next owner, keep the result explicit and local.
