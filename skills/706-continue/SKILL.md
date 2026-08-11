---
name: 706-continue
description: "Resume paused work and report the next step."
argument-hint: <optional focus>
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`) if present. Project files resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` only when this run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

As a `pilotage` skill, `706-continue` can route toward `/100-sg-spec` when the next useful step clearly deserves a durable chantier, but it should not declare every continuation or backlog note as a chantier source.

## Purpose

`706-continue` is a cockpit skill for global conversations.

It answers one pilotage question:

```text
What is the next action-ready step for the currently resolved work item, and how do we move it forward without switching chantiers by accident?
```

Use it when the user wants to move the current work forward without loading the whole execution path into the main conversation. The main thread stays responsible for routing, integration, user-facing status, and the final next-step recommendation. Fresh agents do bounded execution when that will reduce context drag or improve focus.

The goal is not to spawn an agent every time. The goal is to choose the next useful action and run it in the right place.

Keep the boundary explicit: `706-continue` advances a resolved work item. It is not a generic doctrine/help surface and not a conversation-only recap surface.

This skill answers one operator question: what is the single next action-ready move for the active work item, and who should own it now?

It owns continuation of the currently resolved work item from durable local evidence: the next gate, next unchecked task inside that work item, next proof step, or next owner route needed to keep momentum.

Keep the boundary explicit:
- stay here when the user wants to continue the current work item without reopening broad planning
- hand off to `011-sg-pilotage tasks` when the main need is to repair or reconcile tracker state rather than advance the work item itself
- hand off to `303-sg-resume` when the user only wants a conversation recap with no execution push
- hand off to `302-sg-help` when the user needs doctrine or skill-choice explanation
- hand off to `700-sg-explore` or `100-sg-spec` when there is no resolved work item to continue safely

`706-continue` does not become a generic tracker-grooming surface, does not rewrite `TASKS.md` as its primary purpose, and does not silently switch to another chantier because the current one is inconvenient.

## Required References

- `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking the user to choose between plausible work items.
- `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before final reporting when this run is attached to a spec-first chantier.
- `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` before choosing or dispatching an execution topology.
- `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` before selecting or recommending a delegated model.

## Inputs

- If `$ARGUMENTS` is provided, treat it as the requested focus.
- If `$ARGUMENTS` is empty, infer the next useful step from the latest user request, current conversation, TASKS.md, open specs, git status, and recent tool results.
- If several unrelated next steps are plausible, choose the one most likely to unblock progress. Ask the user only when the choice changes product behavior, security, data handling, destructive operations, cost, or external side effects.

Route away instead of staying in `706-continue` when the user really needs:

- explanation of workflow, doctrine, or skill choice -> `302-sg-help`
- thread recap only -> `303-sg-resume`
- a new non-trivial chantier definition -> `100-sg-spec` or `700-sg-explore`

## Target Resolution

Resolve the continuation target from durable local evidence, not only from stale conversation memory.

When no explicit target is provided:

- scan only the focused context needed to identify candidate work items: active `shipglows_data/workflow/specs/*.md`, bug files, current TASKS entry, release scope, recent validation failure, or the current dirty write scope;
- prefer the single candidate that is both current and action-ready;
- if multiple unrelated candidates are plausible, ask one numbered selection question using `$SHIPGLOWS_ROOT/skills/references/question-contract.md`;
- recommend the most recent/current candidate only when local evidence supports it, but do not silently auto-select among materially different work items;
- if no durable work item exists and the next work is non-trivial, route to the correct owner (`100-sg-spec`, bug intake, backlog, or a mini-contract) instead of inventing a hidden continuation target.

Do not treat a short confirmation like "continue", "vas-y", or "poursuis" as permission to switch to another chantier. It continues the currently resolved work item only. If the current work item is ambiguous, resolve or ask before executing.

## Next Ready Action

Advance one action-ready unit per invocation unless the user has clearly asked for an end-to-end lifecycle run.

For a resolved target:

- identify the first blocked/ready boundary from the source of truth: next unchecked task, next spec lifecycle gate, next bug retest/fix step, next validation command, next closure item, or next ship/proof route;
- read dependency artifacts before writing or delegating work that depends on them;
- do not skip ahead to later tasks, closure, ship, or archive while earlier required proof or dependency work is unresolved;
- after completing the unit, report what moved, current progress, what is now unlocked, and the single next concrete step.

## Quick Context Check

Gather only enough context to route correctly:

- Current directory, project name, branch, and git status.
- Project-local `shipglows_data/workflow/TASKS.md` or legacy root `TASKS.md` when present.
- Relevant specs in `docs/` or `specs/` when the next step appears spec-driven.
- Obvious failing command output or latest validation result if available in the conversation.
- Existing skill instructions only when directly useful, especially `102-sg-start`, `106-sg-fix`, `105-sg-check`, `103-sg-verify`, `704-sg-model`, or `104-sg-end`.

Avoid re-reading large files or broad project trees before deciding the route.

## Routing Decision

Classify the next step:

- `answer`: the user needs a direct explanation, decision, or status update.
- `local`: the work is tiny, tightly coupled to the current thread, or immediately blocking.
- `explorer-agent`: the next step is read-only investigation, codebase mapping, diagnosis, or options analysis.
- `worker-agent`: the next step is bounded implementation, test repair, documentation update, or mechanical cleanup with a clear write scope.
- `spec-route`: the work is non-trivial or ambiguous and needs `100-sg-spec`, `101-sg-ready`, or `102-sg-start` rather than ad hoc execution.
- `blocked`: a required user decision or external permission is missing.

Prefer delegation when:

- a fresh context would materially help;
- the subtask is concrete and bounded;
- the main thread can continue integrating or reporting without depending on hidden assumptions;
- file ownership can be stated clearly for write tasks.

When two or more useful investigations are independent and read-only, dispatch them in parallel by default. Mutations are delegated sequentially by default. Parallel writes require ready, predeclared, non-overlapping `Execution Batches` plus one integration owner; a vague claim that tasks are independent is insufficient.

Keep the work local when:

- the next action is trivial;
- the result is needed immediately before any other progress can happen;
- the task is too coupled to the current conversation;
- delegation would duplicate work or create integration overhead greater than the task.

## Agent Choice

When spawning is appropriate:

- Use `explorer` for read-only codebase questions, diagnosis, architecture discovery, or validation of an assumption.
- Use `worker` for implementation or file changes. Give explicit ownership of files/modules and state that other agents or the main thread may also be working in the codebase.
- Use multiple agents by default for two or more independent read-only scopes.
- Use one mutation agent at a time by default. Multiple writing agents may run concurrently only through ready non-overlapping `Execution Batches` with an integration owner.
- Do not spawn agents just to satisfy the skill name; a local action with a clear report is valid.

### ShipGlows Skills

Before launching an agent, decide whether a ShipGlows skill should drive the work. The agent may use any installed ShipGlows skill when it fits the task; all skill documentation is available under `$SHIPGLOWS_ROOT/skills`.

Common routes:

- `102-sg-start`: execute a defined task end-to-end.
- `106-sg-fix`: triage and fix a bug.
- `105-sg-check`: run typecheck, lint, build, and repair failures.
- `103-sg-verify`: verify that work is ready to ship.
- `400-sg-audit-*`: run focused audits for code, design, SEO, GTM, copy, a11y, components, dependencies, or performance.
- `100-sg-spec` / `101-sg-ready`: clarify or harden non-trivial work before implementation.
- `704-sg-model`: choose the model when routing is uncertain.

If a skill is useful, name it in the delegation prompt and tell the agent to open its `SKILL.md` first. Do not paste large skill contents into the prompt.

### Model Choice

Always think about the right model before spawning an agent. Use `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` as the source rather than duplicating its matrix: Sol for frontier/high-cost-of-error reasoning, Terra for balanced daily work, Luna for bounded low-risk/high-volume missions, and the `codex` profile for long agentic implementation. Spark is selectable only when the runtime explicitly exposes it; otherwise apply the canonical quality-equivalent fallback.

If the choice is not obvious, or if the task has high ambiguity, high cost of error, long execution, security/data implications, or unclear provider/runtime constraints, use the `704-sg-model` skill before spawning: open `$SHIPGLOWS_ROOT/skills/704-sg-model/SKILL.md`, then read `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` if instructed or needed. Otherwise inherit the current model only when that is clearly adequate.

## Delegation Prompt Template

For an `explorer`:

```text
You are an explorer agent for the current repo. Investigate only; do not edit files.

Question:
[specific question]

Context:
- Project/root: [path]
- Relevant files or specs: [short list]
- Current hypothesis or failure: [one paragraph]

Return:
- concise findings with file references
- risks or unknowns
- recommended next action
```

For a `worker`:

```text
You are a worker agent in the current repo. You are not alone in the codebase; do not revert or overwrite edits made by others. Adjust your work to coexist with concurrent changes.

Task:
[specific implementation task]

Ownership:
- You may edit: [files/modules]
- Treat as read-only: [files/modules]

Context:
- User outcome: [one paragraph]
- Relevant spec/task: [path or none]
- ShipGlows skill to use, if any: [skill name or none]
- Model chosen: [model + reasoning effort + why]
- Constraints: follow existing patterns; keep scope tight; avoid unrelated refactors

Validation:
- Run: [commands, if known]
- If blocked, report the blocker and the smallest next step

Return:
- files changed
- validation run and result
- remaining risks
- recommended next step
```

## Main Thread Responsibilities

After delegating:

- Do not redo the same work locally.
- While an agent runs, do non-overlapping useful work only if available.
- Wait only when the agent result is needed for the next critical step.
- Review the returned work before reporting it as complete.
- Run focused validation locally when changes were made and it is feasible.
- Preserve the canonical structured receipt and include `Agents: <count> · <mode>` in the final report. If dispatch or an override was unavailable, state degraded execution and the actual model/topology used.

## Final Report

End with a short report in French unless the user used another language:

```text
Fait:
- [what happened]

Agents: [count] · [read-only parallel / delegated sequential / prepared write batches / degraded / not applicable]

Reste:
- [remaining work or risk]

Prochaine étape:
- [one concrete next action]
```

If nothing was executed because routing found a blocker, make the blocker and the exact needed decision the next step.

## Guardrails

- Never hide uncertainty behind delegation.
- Never delegate destructive operations without explicit user approval.
- Never let a subagent decide product/security/data policy when the main thread should ask the user.
- Keep the main conversation as the source of truth for status and next-step decisions.
- Prefer one crisp next step over a broad plan.
