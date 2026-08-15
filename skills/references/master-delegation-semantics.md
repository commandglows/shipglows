---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.12.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-15"
status: active
source_skill: 001-sg-build
scope: master-delegation-semantics
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/900-shipglows-core/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/400-sg-audit/SKILL.md
  - tools/test_master_delegation_contract.py
  - skills/references/decision-quality-contract.md
  - skills/references/spec-driven-development-discipline.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-05-04: the primary `000-shipglows` router should use direct main-thread handoff to selected master skills, not nested master-skill subagents."
  - "Operator decision 2026-08-15: bounded technical implementation approval includes ordinary exact-scope local commits without a duplicate prompt."
  - "Operator decision 2026-08-15: standalone `v` is a canonical short approval only for the immediately preceding pending approval message."
  - "User decision 2026-05-04: master skills keep the master conversation clean by delegating file, validation, closure, and ship work to bounded sequential subagents when available."
  - "User decision 2026-05-04: delegation/subagent execution is distinct from parallelism; parallelism means simultaneous subagents and requires ready Execution Batches."
  - "User decision 2026-05-04: short natural-language confirmations continue the current chantier in delegated sequential mode after diagnosis or proposal; they are interpreted by intent, not exact keyword."
  - "User decision 2026-05-06: 006-sg-design joins the master/orchestrator topology set."
  - "User decision 2026-05-14: an `agents` argument should explicitly validate delegated sequential execution; parallelism remains spec-gated through `Execution Batches`, not an `agents parallel` shortcut."
  - "User decision 2026-05-24: delegated execution must optimize for quality, security, performance, and durability before speed or cost."
  - "User decision 2026-06-10: favor subagents broadly to keep the main conversation clean; sequential is the normal default, while parallel remains read-only or spec/batch-gated."
  - "User decision 2026-06-10: using a master skill counts as consent for bounded sequential subagents, and `spark`, `codex`, `sous-agent`/`subagent`, and `mini` arguments request model-specific subagent delegation."
  - "Operator correction 2026-07-18: internal mission selection stays agent-owned while unfinished user reports expose only plain-language outcome choices."
  - "OpenAI latest-model migration guidance checked 2026-08-07: choose model and reasoning independently, verify runtime availability, and promote routing defaults only with representative evidence."
  - "Operator correction 2026-08-07: delegation must be the observable default; use safe read-only parallelism whenever independent investigation benefits from it."
  - "Operator decision 2026-08-07: read-only work parallelizes by default through a selected no-write matrix; concurrent writes require predeclared non-overlapping Execution Batches."
  - "Operator decision 2026-08-14: delegated writes retain explicit post-message consent through the selected cumulative fast-validation or full-plan path."
next_review: "2026-11-07"
next_step: "/103-sg-verify master delegation semantics"
---

# Master Delegation Semantics

## Purpose

This reference defines how ShipGlows master and orchestrator skills choose execution topology without duplicating delegation doctrine in every skill contract.

The goal is a clean master conversation: the master skill owns decisions, routing, status, integration, and final reporting, while bounded execution contexts handle routine file work, validation, closure preparation, and ship preparation when the runtime supports them.

Load `skills/references/decision-quality-contract.md` before choosing topology, model fallbacks, or delegated mission boundaries. Delegation is an execution-quality and excellence tool, not a shortcut around professional engineering standards.

Favor subagents by default to keep the main conversation clean and outcome-focused.
Use parallel subagents by default for two or more independent read-only scopes. Use sequential subagents for mutations unless a ready spec already defines non-overlapping write `Execution Batches`.
Do not narrate routine subagent orchestration; report outcomes, evidence, blockers, and degraded execution only.

## Applies To

This applies to master and orchestrator skills that pilot multiple phases, owner skills, or execution contexts, including `000-shipglows`, `001-sg-build`, `002-sg-maintain`, `007-sg-content`, `006-sg-design`, `900-shipglows-core build`, `004-sg-deploy`, `003-sg-bug`, and `400-sg-audit`.

`000-shipglows` is a special case: it is a primary router, not a lifecycle executor. It loads this reference to avoid invalid topology, then uses direct main-thread handoff to the selected skill. It must not launch selected master skills inside subagents.

Atomic owner skills may cite this reference only when they launch or coordinate subagents themselves.

## Concepts

- `delegation`: assigning a bounded mission to another execution context.
- `subagent`: the delegated execution context that reads, edits, validates, gathers evidence, prepares integration, or prepares ship under a bounded mission.
- `parallelism`: running more than one subagent at the same time.

Delegation to one sequential subagent is not parallelism. It is the normal way a master skill keeps the user-facing thread focused.

## Default

When subagents are available, the default topology is `read-only parallel` for two or more independent no-write scopes and `delegated sequential` for mutations, dependent stages, validation that can change state, closure, or ship. Parallel writes require ready non-overlapping `Execution Batches`.

Invoking a master or orchestrator skill is consent for bounded sequential subagents and bounded read-only parallel fan-out, but never for mutation. Every write mission still requires explicit post-message approval through the fast-validation or full-plan path selected by `skills/references/mutation-plan-approval.md`. That approval includes ordinary exact-scope local commits for a bounded technical chantier under the contract's cumulative authority. Ask again when the next action changes material scope, risk, data, permissions, destructive behavior, unapproved staging, closure, ship semantics, or introduces parallel writes not already authorized by ready `Execution Batches`.

In `delegated sequential` mode, use one bounded subagent at a time. A small scope may use a mini-contract, but small scope is not an exception to delegation. If file work or validation is needed and subagents are available, the master should delegate instead of doing routine diffs or patches in the master conversation.

## Delegation-First Gate

Before a master reads project files for execution, edits files, runs routine validation, prepares closure, or prepares ship, choose and apply one topology:

- `delegated sequential` for a bounded write, fix, implementation, validation, or integration mission;
- `read-only parallel` when at least two independent investigation or evidence scopes can be partitioned safely;
- `main-only` only for the explicit exceptions below.

For executable work, dispatch the bounded mission before doing routine diffs, patches, validation sweeps, or ship preparation in the master conversation. Do not silently substitute direct master execution because delegation is inconvenient. If the runtime has no subagent capability, or cannot apply the required override, stop or report `degraded` with the concrete capability gap before continuing.

`Agents: not needed` is valid only for a pure conversational answer or explicit decision framing. It is not valid for file mutation, validation, closure, ship preparation, or an independent evidence sweep.

When a master skill accepts an `agents`, `subagent`, `sous-agent`, `spark`, `codex`, or `mini` argument, treat it as a strict delegated sequential request for the current work item. If file work, validation, closure preparation, or ship preparation proceeds without a bounded subagent, the run must stop or report `degraded: subagents unavailable/not applied` with the reason. These arguments never mean parallel execution.

For Codex/OpenAI subagents, choose the smallest quality-equivalent model from `skills/704-sg-model/references/model-routing.md`, then choose reasoning separately. `gpt-5.6-luna` is the default for low-risk bounded work; use the `codex` implementation profile for long implementation, multi-file code work, refactors, hard debugging, or terminal-heavy execution; use `gpt-5.6-terra` for balanced non-trivial work and `gpt-5.6-sol` when ambiguity, cross-system reasoning, governance, architecture, audits, product arbitration, security, business risk, or high error cost require frontier quality. Treat `gpt-5.3-codex-spark` as an explicit request requiring runtime availability, not as an assumed entitlement. Preserve the existing model/effort as the migration baseline; promote a new default only after representative evidence shows a quality-contract win at acceptable latency and cost.

Each delegated mission must include:

- project root
- active spec or mini-contract
- assigned mission
- owned files or surfaces
- forbidden files or surfaces
- selected model or alias
- reasoning effort, or the Claude alias behavior when using Claude Code
- runtime availability evidence for the requested override
- fast or cheap fallback only when it remains quality- and excellence-equivalent for the mission risk
- model application status: `override applied`, `recommended only`, or `not supported by runtime`
- validation commands
- expected proof path when the mission changes behavior, fixes a bug, changes a skill contract, or gathers completion evidence
- report mode
- stop conditions

Claim a subagent model override only when the runtime accepted it. If overrides are unavailable, keep the model as recommended-only and report degradation only when it affects risk, cost, or evidence.

## Short Confirmations

After a master skill has displayed the bounded plan required by
`mutation-plan-approval.md`, a short natural-language confirmation in the
active conversation language means, by intent rather than exact keyword:

```text
continue the current chantier with the canonical topology: read-only parallel for independent no-write scopes, otherwise delegated sequential
```

Short confirmations given before that plan authorize no mutation. Confirmations given after it — including standalone `v` under `mutation-plan-approval.md` — authorize the bounded plan, its ordinary exact-scope technical local commits, and read-only parallel fan-out under the canonical matrix. They never authorize parallel writes without ready `Execution Batches`. Ask again when scope, risk, data, permissions, destructive behavior, unapproved staging, closure, or ship semantics change.

The next safe mission remains internal. In an unfinished user-facing report,
offer only plain-language choices about continuing, reprioritizing, changing
scope, or pausing; never require the operator to select an owner, skill, or
command to continue the chantier.

## Read-Only Parallel Batch Matrix

Use `read-only parallel` by default when two or more independent investigation or evidence scopes exist and parallel results improve elapsed time or coverage. Master-skill invocation is sufficient consent because these agents cannot mutate project or external state.

Before dispatch, create a selected batch matrix that states each agent's bounded surface, explicit read-only constraint, requested evidence, and integration owner. Do not use this mode for dependent stages, overlapping scopes, one small investigation, or speculative busywork. Any subsequent fix, tracker rewrite, content update, closure, or ship work returns to delegated sequential unless the write gate below passes.

## Write Execution Batches

Parallel writes are allowed only when a ready spec defines `Execution Batches` before dispatch. Each batch must define:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without ready write batches, writes stay delegated sequential. When ready non-overlapping write batches exist, execute them in parallel rather than unnecessarily serializing them. The integration owner remains responsible for combined validation.

## Exceptions And Degradation

Allowed exceptions to delegated sequential are:

- pure conversational `main-only` responses
- runtime subagents are unavailable
- the user explicitly requests no subagent
- Plan Mode or decision framing where no mutation, file validation, closure, or ship action will occur

If subagents are unavailable or explicitly refused, ask before degrading to master or single-agent mode for file work, validation, closure, or ship. The user-facing question should describe the practical impact: more technical detail in the master thread and less isolation between orchestration and execution.

## Master Role Responsibilities

The master skill owns:

- clarifying material decisions
- selecting execution topology
- setting the bounded mission
- assigning write ownership
- preventing overlapping writes
- providing concise status
- integrating outputs
- checking evidence and validation results
- routing docs, editorial, proof, closure, ship, or deployment gates
- reporting the result and real blockers

The master skill should not perform routine diffs, patches, validation sweeps, or ship preparation itself when a bounded subagent can do that work.

## Stop Conditions

Stop, ask, reroute, or refine the spec when:

- the active chantier or mini-contract is ambiguous
- subagents are unavailable and the user has not accepted degradation
- requested parallel writes lack ready `Execution Batches`
- write ownership overlaps or is undefined
- the next action changes material scope, permissions, data, destructive behavior, closure, unapproved staging, or ship semantics
- validation, proof, docs, editorial, closure, or ship gates are unresolved
- unrelated dirty files would enter the execution or ship scope

## Reporting Expectations

User-facing reports stay concise. Executable work includes the compact agent receipt; topology detail appears only when it matters for trust, evidence, or next steps.

Agent or handoff reports may include:

- execution topology
- delegated mission summaries
- owned and forbidden file sets
- validation commands and results
- expected proof path and whether it was satisfied
- integration notes
- stop conditions hit or cleared

For executable work, retain a structured delegation receipt with `topology`, `agents_dispatched`, `model_status`, the `read_only_batch_matrix` or `write_execution_batches` when applicable, and `integration_result`. `agents_dispatched` and the compact `Agents: <count>` value count only agents directly dispatched successfully by the orchestrator signing the receipt; nested agents belong to their direct parent's receipt and must not be double-counted. Surface one compact line in the user report: `Agents: <count> · <main-only|delegated sequential|read-only parallel|write-batch parallel|degraded>`. Keep detailed missions internal unless degradation or topology materially affects trust.

Never present parallel work as merely "delegation". Name read-only fan-out by its selected matrix and parallel writes by the ready `Execution Batches` that made them safe.
