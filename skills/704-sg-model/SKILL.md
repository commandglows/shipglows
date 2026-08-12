---
name: 704-sg-model
description: "Route models for ShipGlows tasks and reasoning levels."
argument-hint: <task description, spec path, ou scope>
---

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). Project artifacts remain relative to the current project root unless stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill never writes chantier history. Inside a spec-first flow, use a `(local)` chantier header and leave `Skill Run History` unchanged.

## Mission And Boundary

Choose one quality-safe model policy for the resolved scope, then stop routing and name the execution owner.

This skill owns:

- runtime/provider identification;
- primary model or stable alias choice;
- reasoning effort or alias behavior;
- quality-equivalent fast and cheap fallbacks;
- whether the choice applies to the current conversation, a subagent override, or the next run.

It does not execute the work, mutate the work item, guarantee model availability, or claim that the active main-thread runtime switched.

Stay here for a concrete model or reasoning decision. Route execution to `102-sg-start`, workflow doctrine to `302-sg-help`, and an unresolved task to `700-sg-explore` or `100-sg-spec`.

## Required References

Load only what the decision needs:

1. Load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before optimizing cost, speed, or latency.
2. Load `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` before every model recommendation. It is the sole detailed provider matrix and alias catalogue; do not reproduce it here.
3. Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` only before the final user report.

## Decision Contract

1. Resolve the requested scope from `$ARGUMENTS`, the current request, or one clearly relevant spec/task. Prefer a durable spec when one exists.
2. Identify the actual or requested runtime. If none is explicit, use the current session runtime.
3. Classify only the factors needed by `model-routing.md`: dominant work type, complexity, expected duration, error cost, reversibility, and latency pressure.
4. Apply the shared quality contract first. Speed and price break ties only between options expected to preserve correctness, security, maintainability, performance relevance, excellence, and proof quality.
5. Select a primary policy, reasoning effort or alias behavior, and at most one fast and one cheap quality-equivalent fallback.
6. Record availability evidence and application status separately from the recommendation.
7. Name the exact next owner or invocation. Do not prolong routing once one defensible policy is clear.

## Runtime Application Boundary

Every recommendation must choose exactly one status:

- `current conversation acceptable`: the active runtime is adequate for the risk;
- `subagent override applied`: the runtime exposed an override and the dispatch actually used it;
- `subagent override recommended, not applied`: an override is useful but unavailable or unused;
- `switch recommended for next run`: the main conversation should change runtime outside this thread.

Never infer access from documentation. Never report an override as applied without runtime evidence.

## Freshness And Evidence

Revalidate official provider documentation when the answer depends on `latest`, `current`, `default`, availability, migration, pricing, context size, or a recent comparison. For OpenAI/Codex, use the official OpenAI documentation connector first and official OpenAI domains as fallback. For Claude Code, prefer documented stable aliases unless the operator requests dated model names.

Provider documentation describes policy; the current runtime or tool model list proves availability. If either source is missing, label the claim `recommended, not applied` or stop when execution risk would be material. Never invent benchmarks, price, capacity, context windows, or accepted reasoning levels.

## Stop Conditions

Stop and ask or reroute when:

- no task scope can be resolved without choosing between materially different work items;
- runtime/provider ambiguity changes the recommendation materially;
- no quality-equivalent fallback exists for a requested cost or speed constraint;
- availability cannot be proved and using the wrong model would make the work unsafe;
- the user is asking for execution rather than another routing decision.

## Validation

Before reporting, verify that the recommendation:

- follows the current `model-routing.md` and quality contract;
- separates model choice from reasoning effort;
- identifies freshness and availability evidence;
- states application status truthfully;
- includes upgrade and downgrade conditions based on risk, not prestige;
- ends with one concrete next action.

## Report Modes

Use the shared chantier-then-verdict opening. Keep the report decision-focused: scope, runtime, primary policy, reasoning or alias behavior, brief rationale, quality-equivalent fallbacks, freshness and availability evidence, application status, upgrade/downgrade triggers, and the next owner.

If no valid recommendation can be made, report the blocker and the single missing decision or evidence item instead of filling a model-choice template with guesses.
