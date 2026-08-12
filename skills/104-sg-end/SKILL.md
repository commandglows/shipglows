---
name: 104-sg-end
description: "Close tasks with summaries, trackers, and changelog prep."
argument-hint: [optional summary or notes]
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user` and keep the report outcome-first.
Use `report=agent` only for handoff details, blocked proof, or audit-grade trace.

## Mission

`104-sg-end` closes a work session by preparing closure bookkeeping and explicit next work.

It owns summary and tracker/changelog prep, not implementation proof and not shipping.

## Scope Gate

Use for closure bookkeeping when:

- a task or chantier has clear completion context,
- a concise state summary is needed,
- tracker/changelog preparation is requested.

Do not use this skill for:

- unresolved proof (`103-sg-verify` still needed),
- unresolved ship semantics (`005-sg-ship` still needed),
- unresolved bug diagnosis/fix loops (`003-sg-bug`/`106-sg-fix` still needed).

## Required References

- `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md`
  - before any write on ShipGlows-owned workflow surfaces.
- `$SHIPGLOWS_ROOT/skills/references/closure-archive-guard.md`
  - before closing state transitions.
- `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md`
  - before changelog or tracker text implying completion.
- `$SHIPGLOWS_ROOT/skills/104-sg-end/references/closure-bookkeeping-playbook.md`
  - for closure steps and field-level bookkeeping.
- `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`
  - only when a reusable lesson is explicitly accepted.

## Stop Conditions

- Do not claim done/closed without evidence and required guards.
- Do not mutate tracker/changelog when proof or docs status is materially incomplete unless closure mode is partial.
- Do not mark product work as complete if documentation status is `needs review`.
- Do not include internal file paths in user `report=user`.
- Do not claim shipping, release, or implementation truth from closure alone.

## Validation

Run closure in this order:

1. classify closure mode (`closed`, `partial`, `deferred`, `blocked`, `not applicable`),
2. apply `closure-archive-guard.md`,
3. run changelog/tracker preparation rules,
4. run documentation reflection and route `needs review` cases through `300-sg-docs`,
5. emit closure limits and next owner clearly.

## Activation Map

- Load `closure-bookkeeping-playbook.md` before changing tracker/changelog artifacts.
- If a material docs gap remains, classify result as `partial` and do not force done mode.
- If the run is not tied to a unique spec, apply local `(local)` chantier mode.

### Step 5 — Report

### Final closure summary

- Outcome: `closed`, `partial`, `deferred`, or `blocked`.
- Key proof boundaries: what was verified, what is missing.
- Next owner and next action.
- Tracker/changelog updates made or explicitly skipped.

### Rules

- User-mode reports must stay plain language, no internal owner names, no raw paths, no modified file inventory.
- Include only explicit next action and residual risk.
