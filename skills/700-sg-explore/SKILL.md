---
name: 700-sg-explore
description: "Explore ideas, problems, and requirements before coding."
argument-hint: [optional: sujet ou question a explorer]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write chantier specs or status history. If a durable artifact is produced, use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user` with the chantier opening header.

## Mission

`700-sg-explore` runs a pre-implementation exploration pass. It compares options, identifies uncertainty, and frames the next owner when the problem is real but direction is not yet stable.

It owns exploration posture and persistence thresholds, not implementation truth, closure, or shipping.

## Scope Gate

Use this skill when the operator asks for:

- option comparisons, risk framing, or feasibility mapping,
- clarification of ambiguous requirements,
- hypothesis exploration before writing specs,
- nontrivial architectural decisions.

Stop and hand off when:

- the user asks for code changes or implementation,
- explicit backlog/priority closure is requested,
- a concrete bug work item is already identified,
- proof-heavy verification or closure is needed.

## Required References

- `$SHIPGLOWS_ROOT/skills/references/question-contract.md`
  - before asking a material question that changes direction, scope, or audience.
- `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`
  - when business truth, tradeoffs, or strategy belong to the operator.
- `$SHIPGLOWS_ROOT/skills/700-sg-explore/references/exploration-posture-and-techniques.md`
  - for posture, options framing, and risk surfacing.
- `$SHIPGLOWS_ROOT/skills/700-sg-explore/references/durable-exploration-report.md`
  - only when persistence threshold is met or explicit durable output is requested.

## Stop Conditions

- Do not write code or implementation commands.
- Do not mark tasks as closed or shipped.
- Do not invent evidence; avoid passing unverifiable certainty as conclusion.
- Do not write `TASKS.md`, `AUDIT_LOG.md`, or legacy tracker files in place of a durable exploration report.
- If implementation is requested, hand off to the right owner without forcing exploratory completion.

## Validation

- Do not claim final proof from exploration only.
- Keep one operator-facing synthesis paragraph and the chosen next step.
- If threshold is met, store a durable report with path, source list, and uncertainty notes.
- If threshold is not met, explicitly note that no durable report was written.

## Activation Map

- Start with posture and boundary gates in local playbook.
- If the exploration is substantial, load `$SHIPGLOWS_ROOT/skills/700-sg-explore/references/durable-exploration-report.md`.
- If implementation is requested mid-run, stop and hand off before continuing.
- Load only one local reference before the first meaningful action.
