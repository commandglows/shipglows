---
name: 706-continue
description: "Resume paused work and report the next step."
argument-hint: <optional focus>
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Project files remain relative to the current project root unless stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

When exactly one spec-first chantier owns the run, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report, append the run to `Skill Run History`, and change `Current Chantier Flow` only if state changed. Otherwise write no spec and use a `(local)` chantier header.

This skill may route non-trivial new work to `100-sg-spec`; it does not turn every continuation into a chantier source.

## Mission And Boundary

Resolve the current work item, advance its single next action-ready unit, integrate the result, and report what is unlocked without silently switching chantiers.

Stay here when the user wants to move an already resolved item forward. Route tracker repair to `011-sg-pilotage tasks`, recap-only requests to `303-sg-resume`, doctrine questions to `302-sg-help`, and unresolved non-trivial work to `700-sg-explore` or `100-sg-spec`.

`706-continue` does not groom the backlog as its primary purpose, rewrite a tracker from stale context, skip lifecycle gates, or use an inconvenient blocker as permission to select another work item.

## Conditional Reference Loading

After confirming that continuation is the correct owner, load `$SHIPGLOWS_ROOT/skills/706-continue/references/continuation-playbook.md`. It is the only local substantive playbook and owns target resolution plus next-ready-action selection.

Load shared references only at their decision boundary:

- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` only before asking the operator to choose among plausible targets;
- `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` before choosing or dispatching execution topology;
- `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` before selecting, recommending, or overriding a delegated model;
- `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` only for an attached chantier report;
- `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` only before the final user report.

Do not preload agent templates, model catalogues, or unrelated lifecycle skills.

## Inputs And Ownership Decision

Treat `$ARGUMENTS` as a focus, not proof of ownership. Confirm it against current durable evidence. With no arguments, use the latest user request, the current conversation, focused tracker/spec state, current dirty scope, and recent validation evidence.

If the request is really a recap, doctrine question, tracker repair, new scope, or broad prioritization, route before loading the continuation playbook. If continuation owns the intent, use the playbook to resolve exactly one target and its first ready boundary.

A short confirmation such as “continue”, “vas-y”, or “poursuis” authorizes the already resolved target only. It never selects among materially different chantiers.

## Execution Decision

Classify the selected unit as one of:

- `answer`: a direct decision, explanation, or status is sufficient;
- `local`: a tiny action is tightly coupled to the current thread;
- `investigate`: bounded read-only evidence is missing;
- `implement`: bounded file work has clear ownership and validation;
- `lifecycle route`: another owner must run the next gate;
- `blocked`: a user decision, authority, or external state is required.

Before any agent dispatch, follow `master-delegation-semantics.md`. Two or more independent read-only scopes run in parallel by default; mutations use delegated sequential execution unless a ready spec defines non-overlapping `Execution Batches` with one integration owner.

Delegated missions must state the outcome, owned and forbidden surfaces, relevant evidence, chosen model status, validation, and stop condition. Do not paste shared skill bodies or reusable prompt templates into this activation contract.

Use `model-routing.md` as the sole detailed model source. Choose the smallest quality-equivalent policy for the bounded mission, distinguish recommendation from an applied override, and never invent runtime availability.

## Integration And Proof

After execution:

- do not repeat delegated work locally;
- review the result against the resolved unit and owned scope;
- run focused validation when changes were made and it is feasible;
- preserve unrelated dirty work;
- record what moved, what proof passed, what remains blocked, and the single next concrete step;
- retain the structured delegation receipt required by `master-delegation-semantics.md`.

One invocation advances one action-ready unit unless the operator explicitly requested an authorized end-to-end lifecycle run.

## Stop Conditions

Stop, ask, or reroute when:

- the current work item is absent or materially ambiguous;
- the next action changes product behavior, security, data handling, permissions, destructive behavior, cost, external side effects, closure, unapproved staging, or ship semantics without authority;
- a dependency, earlier task, proof gate, or required owner remains unresolved;
- write ownership overlaps, unrelated dirty files would enter scope, or concurrent writes lack ready batches;
- the selected topology or model cannot be applied safely;
- validation fails outside the owned unit.

## Report Modes

Load the shared reporting contract before the final response. Open with the chantier header, then give the outcome first in the user’s language.

For executable work, include the exact compact receipt shape `Agents: <count> · <mode>`. Count only agents directly dispatched by this orchestrator. Report model or topology detail only when it affects trust, proof, degradation, or the next decision.

End with what changed, the validation result, remaining risk or blocker, and one concrete next step. If nothing executed, make the blocker and exact required decision the next step.
