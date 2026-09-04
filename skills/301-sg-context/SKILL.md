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

For project delivery, release, deployment, or Git branch selection, load `$SHIPGLOWS_ROOT/skills/references/project-delivery-policy.md` and run its read-only resolver. Carry `delivery_posture` only from `shipglows_data/business/business.md` and derived production/integration/staging branches in the capsule. Also run `$SHIPGLOWS_ROOT/tools/project_git_policy.py` and carry the effective `task_branch_policy`, `worktree_policy`, canonical source, defaulted/invalid reason, and configuration guidance from `shipglows_data/technical/guidelines.md`. Missing or invalid Git-policy values default independently to effective `forbidden`; always explain that this prevents silent creation and can be changed after discussing a justified need with the user. Missing or invalid delivery posture remains `context_partial` with one product question and canonical-update route. Never substitute pitch, `ENVIRONMENT.md`, DevServer live state, `CLAUDE.md`, or branch names.

For a material adopted-repository task, use `tools/code_context_graph.py update` when a compatible worktree-local index exists, otherwise build it once, then use `tools/context_capsule.py` to produce the bounded capsule. The capsule output must expose selection reasons, bounds, missing seeds and fallback state. Never persist task text automatically. Small deterministic tasks keep the targeted native fallback when indexing would cost more than the decision it supports.

When the project adopts structured context history, load `$SHIPGLOWS_ROOT/skills/references/context-history-and-head.md`. Check and prefer a fresh bounded Context Head before broader retrieval; its generated code-context section already combines recent event references with the native bounded graph. Regenerate it only with applicable mutation authority, otherwise render it with `--no-write`. Revalidate material claims against canonical sources before `context_ready`.

Route skill/workflow selection to `000-shipglows`, active-work continuation to `706-continue`, and cross-project status to `308-sg-status`. Empty task input asks one plain-language target question.

## Runtime-Adaptive Retrieval

Resolve and report the current execution envelope from `agent-runtime-awareness.md` before capability claims: operating system, agent surface, terminal host, session location, and machine kind. Preserve `unknown` rather than guessing. For host-dependent tools, carry transport reachability separately from installation, configuration, discovery, exposure, and callability.

Inspect directly exposed tools and the host's deferred/searchable tool catalog
before classifying current-turn capabilities; configuration alone is not
availability, and absence from the first visible list is not non-availability.

When the task depends on Flutter, Android, Windows desktop, or Firebase Device
Streaming, carry the relevant mobile and Windows toolchain fields and their
exact next action from `agent-runtime-awareness.md` into the qualified context
capsule. Do not collapse installed, configured, accelerated, device-ready, and
current-turn callable into one readiness claim.

For a Flutter surface, resolve the selected managed surface, read its surface-level `ENVIRONMENT.md`, and inspect the matching live DevServer registry entry at decision time. The capsule must name `active_development_target`, `session_mode`, `logical_run_command`, and live `state`. Registry `status` is authoritative; `flutterStartupState` and retained process fields never override `stopped` or `error`. Treat `flutterDevice` as the active target only while the matching managed session is current; list repository/toolchain targets separately as available, never active by implication. For a Windows live session report `Flutter Windows`, `managed live`, `flutter run -d windows`, and its observed `running` or `stopped` state. For Android, report `Flutter Android`, the resolved device id, `flutter run -d <device-id>`, and whether the target is a connected device or the managed `ShipGlows_API_36` emulator. Preserve the development boundary: live `flutter run` is the normal iterative path, while builds are release or explicit standalone/package-sensitive proof checkpoints.

When a runtime claim is contradicted or a native transport probe fails, refresh only the execution envelope, selected managed surface, matching registry entry, and affected transport before returning a verdict. A standalone Codex CLI may discover Computer Use and Node REPL without receiving the Codex Desktop native pipe; report that transport failure and route GUI-dependent proof to Codex Desktop rather than giving a vague restart instruction.

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
