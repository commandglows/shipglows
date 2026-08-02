---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-07-18"
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
  - "User decision 2026-05-04: master skills keep the master conversation clean by delegating file, validation, closure, and ship work to bounded sequential subagents when available."
  - "User decision 2026-05-04: delegation/subagent execution is distinct from parallelism; parallelism means simultaneous subagents and requires ready Execution Batches."
  - "User decision 2026-05-04: short natural-language confirmations continue the current chantier in delegated sequential mode after diagnosis or proposal; they are interpreted by intent, not exact keyword."
  - "User decision 2026-05-06: 006-sg-design joins the master/orchestrator topology set."
  - "User decision 2026-05-14: an `agents` argument should explicitly validate delegated sequential execution; parallelism remains spec-gated through `Execution Batches`, not an `agents parallel` shortcut."
  - "User decision 2026-05-24: delegated execution must optimize for quality, security, performance, and durability before speed or cost."
  - "User decision 2026-06-10: favor subagents broadly to keep the main conversation clean; sequential is the normal default, while parallel remains read-only or spec/batch-gated."
  - "User decision 2026-06-10: using a master skill counts as consent for bounded sequential subagents, and `spark`, `codex`, `sous-agent`/`subagent`, and `mini` arguments request model-specific subagent delegation."
  - "Operator correction 2026-07-18: internal mission selection stays agent-owned while unfinished user reports expose only plain-language outcome choices."
next_review: "2026-06-04"
next_step: "/103-sg-verify master delegation semantics"
---

# Master Delegation Semantics

## Purpose

This reference defines how ShipGlows master and orchestrator skills choose execution topology without duplicating delegation doctrine in every skill contract.

The goal is a clean master conversation: the master skill owns decisions, routing, status, integration, and final reporting, while bounded execution contexts handle routine file work, validation, closure preparation, and ship preparation when the runtime supports them.

Load `skills/references/decision-quality-contract.md` before choosing topology, model fallbacks, or delegated mission boundaries. Delegation is an execution-quality and excellence tool, not a shortcut around professional engineering standards.

Favor subagents by default to keep the main conversation clean and outcome-focused.
Use sequential subagents by default; use parallel subagents only for read-only work or ready `Execution Batches`.
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

When subagents are available, the default topology for master-skill work that reads files, edits files, validates, prepares closure, or prepares ship is `delegated sequential`.

Invoking a master or orchestrator skill is consent for bounded sequential subagents. Ask again only when the next action changes material scope, risk, data, permissions, destructive behavior, staging, closure, ship semantics, or parallel execution.

Use one bounded subagent at a time. A small scope may use a mini-contract, but small scope is not an exception to delegation. If file work or validation is needed and subagents are available, the master should delegate sequentially instead of doing routine diffs or patches in the master conversation.

When a master skill accepts an `agents`, `subagent`, `sous-agent`, `spark`, `codex`, or `mini` argument, treat it as a strict delegated sequential request for the current work item. If file work, validation, closure preparation, or ship preparation proceeds without a bounded subagent, the run must stop or report `degraded: subagents unavailable/not applied` with the reason. These arguments never mean parallel execution.

For Codex/OpenAI subagents, the default bounded mission model is the smallest quality-equivalent model for the mission. Use `gpt-5.4-mini` only for low-risk bounded work where it can meet the quality and excellence bar. Use `gpt-5.3-codex-spark` when `spark` is requested and the mission is quality-equivalent on Spark, including concise summaries, text-only handoffs, micro-code, targeted UI/local edits, or other low-risk bounded work while Spark credits/availability permit. Use the `codex` implementation profile when `codex` is requested or the mission is long implementation, multi-file code work, refactor, hard debugging, or terminal-heavy execution; resolve that profile through `skills/704-sg-model/references/model-routing.md` rather than pinning it to a deprecated slug. Use `gpt-5.5` with the appropriate `low`, `medium`, `high`, or `xhigh` reasoning for non-implementation work when ambiguity, cross-system reasoning, governance, architecture, audits, product arbitration, security, business risk, or high error cost require it.

Each delegated mission must include:

- project root
- active spec or mini-contract
- assigned mission
- owned files or surfaces
- forbidden files or surfaces
- selected model or alias
- reasoning effort, or the Claude alias behavior when using Claude Code
- fast or cheap fallback only when it remains quality- and excellence-equivalent for the mission risk
- model application status: `override applied`, `recommended only`, or `not supported by runtime`
- validation commands
- expected proof path when the mission changes behavior, fixes a bug, changes a skill contract, or gathers completion evidence
- report mode
- stop conditions

Claim a subagent model override only when the runtime accepted it. If overrides are unavailable, keep the model as recommended-only and report degradation only when it affects risk, cost, or evidence.

## Short Confirmations

After a master skill has diagnosed the current chantier or proposed a bounded
action, a short natural-language confirmation in the active conversation
language means, by intent rather than exact keyword:

```text
continue the current chantier in delegated sequential mode with one bounded subagent
```

Short confirmations never authorize parallel subagents. Ask again only when scope, risk, data, permissions, destructive behavior, staging, closure, or ship semantics change.

The next safe mission remains internal. In an unfinished user-facing report,
offer only plain-language choices about continuing, reprioritizing, changing
scope, or pausing; never require the operator to select an owner, skill, or
command to continue the chantier.

## Parallelism

Parallelism means simultaneous subagents. It is allowed only through ready `Execution Batches`.

Do not define an argument-level `agents parallel` mode. If the user asks for parallel agents, route to the ready spec's `Execution Batches` or block until those batches define non-overlapping ownership and integration.

Ready `Execution Batches` must define:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without ready batches, parallelism is blocked. The next action is spec or batch refinement, not opportunistic fan-out.

Read-only audit fan-out may run in simultaneous subagents only when the master skill has an explicit selected batch matrix, such as project x domain, and each agent is forbidden to edit files. Any fix, tracker rewrite, content update, closure, or ship work after that returns to delegated sequential unless a ready spec defines write-safe `Execution Batches`.

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
- requested parallelism lacks ready `Execution Batches`
- write ownership overlaps or is undefined
- the next action changes material scope, permissions, data, destructive behavior, closure, staging, or ship semantics
- validation, proof, docs, editorial, closure, or ship gates are unresolved
- unrelated dirty files would enter the execution or ship scope

## Reporting Expectations

User-facing reports stay concise. They should include the execution mode only when it matters for trust, evidence, or next steps.

Agent or handoff reports may include:

- execution topology
- delegated mission summaries
- owned and forbidden file sets
- validation commands and results
- expected proof path and whether it was satisfied
- integration notes
- stop conditions hit or cleared

Never present parallel work as merely "delegation"; name simultaneous subagents as parallelism and point to the ready `Execution Batches` that made it safe.
