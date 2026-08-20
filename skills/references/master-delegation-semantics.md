---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.15.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-17"
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
  - skills/708-sg-auto/SKILL.md
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
  - "Operator decision 2026-08-15: standalone `v` is a canonical short approval only for one unambiguous pending proposal; the 2026-08-16 correction preserves a narrowly framed mapping across non-material clarification."
  - "Operator correction 2026-08-16: clarification and acknowledgement turns preserve an unchanged pending proposal without duplicate approval prompts or implicit mutation authority."
  - "User decision 2026-05-04: master skills keep the master conversation clean by delegating file, validation, closure, and ship work to bounded sequential subagents when available."
  - "User decision 2026-05-04: delegation/subagent execution is distinct from parallelism; parallelism means simultaneous subagents and requires ready Execution Batches."
  - "User decision 2026-05-04: explicit natural-language action confirmations continue the current chantier in delegated sequential mode after diagnosis or proposal; they are interpreted by intent, not exact keyword."
  - "User decision 2026-05-06: 006-sg-design joins the master/orchestrator topology set."
  - "User decision 2026-05-14: an `agents` argument should explicitly validate delegated sequential execution; parallelism remains spec-gated through `Execution Batches`, not an `agents parallel` shortcut."
  - "Operator correction 2026-08-17: topology must minimize elapsed time and coordination overhead while preserving the applicable architecture and safety floor; delegation is never ceremony."
  - "User decision 2026-06-10: favor subagents broadly to keep the main conversation clean; sequential is the normal default, while parallel remains read-only or spec/batch-gated."
  - "User decision 2026-06-10: using a master skill counts as consent for bounded sequential subagents, and `spark`, `codex`, `sous-agent`/`subagent`, and `mini` arguments request model-specific subagent delegation."
  - "Operator correction 2026-07-18: internal mission selection stays agent-owned while unfinished user reports expose only plain-language outcome choices."
  - "OpenAI latest-model migration guidance checked 2026-08-07: choose model and reasoning independently, verify runtime availability, and promote routing defaults only with representative evidence."
  - "Operator correction 2026-08-07: delegation must be the observable default; use safe read-only parallelism whenever independent investigation benefits from it."
  - "Operator decision 2026-08-07: read-only work parallelizes by default through a selected no-write matrix; concurrent writes require predeclared non-overlapping Execution Batches."
  - "Operator decision 2026-08-14: delegated writes retain explicit post-message consent through the selected cumulative fast-validation or full-plan path."
  - "Operator decision 2026-08-20: explicit shipglows auto authorizes and recommends subagents for independent useful work, but never agent fan-out or higher reasoning solely to consume credits."
next_review: "2026-11-07"
next_step: "/103-sg-verify master delegation semantics"
---

# Master Delegation Semantics

## Purpose

This reference defines how ShipGlows master and orchestrator skills choose execution topology without duplicating delegation doctrine in every skill contract.

The goal is fast, reliable delivery with a clear operator conversation. The master owns decisions, integration, and reporting; bounded execution contexts are used only when they reduce elapsed time, isolate material risk, or improve independent coverage enough to repay coordination cost.

Load `skills/references/decision-quality-contract.md` before choosing topology, model fallbacks, or delegated mission boundaries. Delegation is an execution-quality and excellence tool, not a shortcut around professional engineering standards.

Use `main-only` for one bounded task when delegation would add handoff latency without a material quality gain. Use parallel subagents for two or more independent scopes only when net elapsed time or coverage improves. Use sequential subagents when isolation materially helps a non-trivial mutation; parallel writes still require ready non-overlapping `Execution Batches`.
Do not narrate routine subagent orchestration; report outcomes, evidence, blockers, and degraded execution only.

## Applies To

This applies to master and orchestrator skills that pilot multiple phases, owner skills, or execution contexts, including `000-shipglows`, `001-sg-build`, `002-sg-maintain`, `007-sg-content`, `006-sg-design`, `900-shipglows-core build`, `004-sg-deploy`, `003-sg-bug`, and `400-sg-audit`.

`000-shipglows` is a special case: it is a primary router, not a lifecycle executor. It loads this reference to avoid invalid topology, then uses direct main-thread handoff to the selected skill. It must not launch selected master skills inside subagents. `708-sg-auto` is an orchestrator governed by the explicit Auto-session authority and the mandatory nolocal policy.

Atomic owner skills may cite this reference only when they launch or coordinate subagents themselves.

## Concepts

- `delegation`: assigning a bounded mission to another execution context.
- `subagent`: the delegated execution context that reads, edits, validates, gathers evidence, prepares integration, or prepares ship under a bounded mission.
- `parallelism`: running more than one subagent at the same time.

Delegation to one sequential subagent is not parallelism. It is an optional isolation tool, not a mandatory stage.

## Default

Choose the lowest-overhead topology that can ship the accepted outcome safely: `main-only` for one bounded stream, `read-only parallel` for genuinely independent scopes with net time/coverage benefit, and `delegated sequential` for useful isolation. Parallel writes require ready non-overlapping `Execution Batches`.

Invoking a master or orchestrator skill is consent for bounded sequential subagents and bounded read-only parallel fan-out, but never by itself for mutation. Every write mission requires valid mutation authority. Outside the exact exceptions defined by `skills/references/mutation-plan-approval.md`, that means explicit post-message approval through its fast-validation or full-plan path. That approval includes ordinary exact-scope local commits for a bounded technical chantier under the contract's cumulative authority. Ask again when the next action changes material scope, risk, data, permissions, destructive behavior, unapproved staging, closure, ship semantics, or introduces parallel writes not already authorized by ready `Execution Batches`.

`708-sg-auto` is the narrow exception defined by Auto-session authority: the
explicit `shipglows auto` invocation authorizes its bounded parent and delegated
write missions without a new approval per candidate. Auto subagents are
recommended when at least two independent useful missions improve elapsed time,
isolation, or coverage. They all inherit the frozen launch root and mandatory
nolocal policy. This exception never authorizes overlapping writes, duplicate
work, another project, artificial fan-out, forced reasoning effort, or any
effect forbidden by the no-local policy.

In `delegated sequential` mode, use one bounded subagent at a time. Do not delegate a small cohesive edit, focused check, closure, or ship merely because a subagent exists; coordination must buy measurable speed, isolation, or evidence.

## Topology Value Gate

Before a master reads project files for execution, edits files, runs routine validation, prepares closure, or prepares ship, choose and apply one topology:

- `main-only` for one cohesive bounded mission or when it has the shortest lead time;
- `read-only parallel` when at least two independent scopes can be partitioned safely and the expected gain exceeds coordination cost;
- `delegated sequential` when a bounded write, fix, validation, or integration mission benefits materially from isolation.

Do not dispatch speculative agents or create handoff ceremony for work the active agent can complete faster at the same standard. Missing subagent capability is not degradation unless the approved proof or risk isolation actually depends on it.

`Agents: not needed` is valid for a cohesive bounded mutation, focused validation, closure, or ship when delegation has no material net benefit.

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
`mutation-plan-approval.md`, an explicit natural-language action approval in
the active conversation language means, by intent rather than exact keyword:

```text
continue the current chantier with the canonical topology: read-only parallel for independent no-write scopes, otherwise delegated sequential
```

Action approvals given before that plan authorize no mutation. Explicit action approvals given after it — including standalone `v` only under the bounded mapping in `mutation-plan-approval.md` — authorize the bounded plan, its ordinary exact-scope technical local commits, and read-only parallel fan-out under the canonical matrix. They never authorize parallel writes without ready `Execution Batches`.

A non-material clarification keeps the unchanged proposal pending: answer it without restating the plan or asking again. Neutral acknowledgements such as `ok`, `compris`, `merci`, or `thanks` neither approve nor trigger a repeated approval prompt. A later explicit and unambiguous action approval may authorize that still-current unchanged proposal without a new plan. Material changes invalidate it and require the replacement approval path defined by `mutation-plan-approval.md`, including changes to scope, behavior, target, risk, data, permissions, destructive or external effects, proof strategy, unapproved staging, closure, or ship semantics.

The next safe mission remains internal. In an unfinished user-facing report,
offer only plain-language choices about continuing, reprioritizing, changing
scope, or pausing; never require the operator to select an owner, skill, or
command to continue the chantier.

## Read-Only Parallel Batch Matrix

Use `read-only parallel` when two or more independent investigation or evidence scopes exist and parallel results materially improve elapsed time or coverage. Master-skill invocation is sufficient consent because these agents cannot mutate project or external state.

Before dispatch, create a selected batch matrix that states each agent's bounded surface, explicit read-only constraint, requested evidence, and integration owner. Do not use this mode for dependent stages, overlapping scopes, one small investigation, or speculative busywork. Any subsequent fix, tracker rewrite, content update, closure, or ship work returns to delegated sequential unless the write gate below passes.

## Write Execution Batches

Parallel writes are allowed only when a ready spec defines `Execution Batches` before dispatch. Each batch must define:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without ready write batches, writes stay delegated sequential. When ready non-overlapping write batches exist, execute them in parallel rather than unnecessarily serializing them. The integration owner remains responsible for combined validation.

## Exceptions And Degradation

Valid `main-only` cases include:

- pure conversational `main-only` responses
- one cohesive bounded mutation, focused check, closure, or ship
- delegation whose expected handoff/integration cost exceeds its benefit
- runtime subagents are unavailable
- the user explicitly requests no subagent
- Plan Mode or decision framing where no mutation, file validation, closure, or ship action will occur

If subagents are unavailable or explicitly refused, continue main-only unless a concrete approved proof or isolation requirement depends on them; only then report the exact capability block.

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

The master may perform cohesive diffs, patches, focused validation, closure, and ship directly when this is the fastest professional route. Delegate when concurrency or isolation materially improves delivery.

## Stop Conditions

Stop, ask, reroute, or refine the spec when:

- the active chantier or mini-contract is ambiguous
- a required isolation or proof path depends on unavailable subagents
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
