---
name: 301-sg-context
description: "Prime a known task with sufficient, qualified, and portable context."
argument-hint: <what you want to do>
---

Primary artifact type: `helper`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned resources. Project truth resolves from the selected project root. Load `$SHIPGLOWS_ROOT/skills/references/agent-runtime-awareness.md` before deciding that a configured MCP, app, connector, or tool is callable.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

Do not mutate specs or durable project truth. Use `(local)` reporting and load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final result.

## Report Modes

Default to concise `report=user`. Use `report=agent` only for an explicit handoff that needs the detailed capsule, source pointers, evidence states, invalidation signals, and gaps.

## Mission And Routing

Prime one known task with the minimum sufficient context for a correct next decision. Load `$SHIPGLOWS_ROOT/skills/references/context-quality-contract.md` and return its qualified `Context Capsule` plus verdict.

When the project adopts structured context history, load `$SHIPGLOWS_ROOT/skills/references/context-history-and-head.md`. Check and prefer a fresh bounded Context Head before broader retrieval; regenerate it only with applicable mutation authority, otherwise render it with `--no-write`. Revalidate material claims against canonical sources before `context_ready`.

Route skill/workflow selection to `000-shipglows`, active-work continuation to `706-continue`, and cross-project status to `308-sg-status`. Empty task input asks one plain-language target question.

## Runtime-Adaptive Retrieval

Inspect directly exposed tools and the host's deferred/searchable tool catalog
before classifying current-turn capabilities; configuration alone is not
availability, and absence from the first visible list is not non-availability.

When the task depends on Flutter, Android, Windows desktop, or Firebase Device
Streaming, carry the relevant mobile and Windows toolchain fields and their
exact next action from `agent-runtime-awareness.md` into the qualified context
capsule. Do not collapse installed, configured, accelerated, device-ready, and
current-turn callable into one readiness claim.

### Contextual MCP Path

When callable, use `context_continue` to recover prior qualified state, `context_retrieve` to rank candidates, and `context_read` for focused excerpts. Cached memory accelerates discovery only: validate material claims against canonical sources and observed state before `context_ready`.

### Portable Native Fallback

When any required contextual MCP operation is not callable, use the current host's read-only filesystem and Git capabilities:

1. resolve project root, governing instructions, matching work item, and explicitly named paths;
2. inspect Git branch/`HEAD`/dirty state when it can invalidate prior context;
3. use `rg --files` and targeted `rg -n` queries to find likely owner files, then read only decision-changing excerpts;
4. inspect source-of-truth docs, target entry points, adjacent tests/consumers, environment/runtime evidence, and current official sources only as applicable;
5. stop when the capsule is sufficient or further reading no longer changes a decision.

Use platform-equivalent commands if `rg` or Git is unavailable. Do not claim MCP retrieval, memory recovery, budget telemetry, or equivalent evidence that was not actually obtained.

## Verdict And Handoff

Return `context_ready`, `context_partial`, `context_conflict`, or `context_stale`, with target/outcome, qualified truths and source pointers, applicable constraints, inspected evidence, material gaps, invalidation signals, and next safe action. Keep user mode concise; detailed capsule data belongs to explicit agent handoff.

If the invoking owner and next action are already resolved, handoff directly without asking a generic permission question. A context verdict never authorizes mutation or bypasses plan approval, readiness, security, or product decisions.

## Stop Conditions

Do not report `context_ready` when the target/outcome is unresolved; material evidence is stale or conflicting; a required source is inaccessible; private material would be exposed; or current-turn callable tools cannot establish equivalent evidence. Never broaden into exhaustive repository reading merely to fill a budget.

## Validation

- `python3 -m unittest tools.test_context_quality_contract`
- metadata lint, skill budget audit, activation graph, and public runtime sync check.
