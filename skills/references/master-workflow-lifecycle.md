---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlowz
created: "2026-05-04"
updated: "2026-07-17"
status: active
source_skill: 009-sg-skill-build
scope: master-workflow-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/900-shipglowz-core/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/400-sg-audit/SKILL.md
  - skills/references/master-delegation-semantics.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/decision-quality-contract.md
  - skills/references/question-contract.md
  - skills/references/chantier-tracking.md
  - skills/references/preferred-stacks.md
  - skills/references/app-blueprints.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglowz_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.7.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.4"
    required_status: draft
supersedes: []
evidence:
  - "User decision 2026-05-04: master skills should share the same workflow skeleton instead of duplicating lifecycle doctrine."
  - "User decision 2026-05-04: bug work uses one Markdown bug file per bug under shipglowz_data/workflow/bugs/*.md; shipglowz_data/workflow/BUGS.md is optional/generated/triage view, not the source of truth."
  - "User decision 2026-05-04: user-facing questions should share a numbered, context-aware question/default contract."
  - "User decision 2026-05-06: 006-sg-design joins the master lifecycle set."
  - "User decision 2026-05-08: 003-sg-bug is a lifecycle executor through owner skills and bounded subagents, not a simple next-command router."
  - "User decision 2026-05-24: ShipGlowz optimizes first for performance, security, excellence, durability, and professional best practices; speed and convenience are secondary tie-breakers only."
  - "User decision 2026-06-10: favor subagents broadly to keep the main conversation clean; sequential is the normal default, while parallel remains read-only or spec/batch-gated."
  - "User decision 2026-06-10: master-skill invocation is consent for bounded sequential subagents; `spark`, `codex`, `sous-agent`/`subagent`, and `mini` arguments request model-specific subagent delegation."
  - "Spec auto-follow-through-for-local-only-102-sg-start-verification.md defines bounded local auto-verify for 102-sg-start without changing full 001-sg-build lifecycle ownership."
  - "User decision 2026-06-23: blueprints act as global spec skeletons for app archetypes, consumed by the Blueprint Gate in 001-sg-build."
  - "User decision 2026-06-23: Blueprint Gate fires after work item resolution and before the readiness gate for app creation work items."
  - "Operator correction 2026-07-17: preferred stack presets resolve after platform footprint and before blueprint matching."
next_review: "2026-06-04"
next_step: "/103-sg-verify master workflow lifecycle reference"
---

# Master Workflow Lifecycle

## Purpose

This reference defines the shared lifecycle skeleton for ShipGlowz master and orchestrator skills.

It does not redefine delegation, subagent, short-confirmation, or parallelism semantics. Load `skills/references/master-delegation-semantics.md` for execution topology.

Before choosing a lifecycle route, model, topology, owner skill, mini-contract, or direct execution path, load `skills/references/decision-quality-contract.md`. The lifecycle must choose bounded professional work, not the fastest or easiest path. Speed, cost, and convenience are tie-breakers only after correctness, security, performance, maintainability, durability, excellence, and evidence are already sufficient for the risk.

Spec-first is the outer lifecycle contract: it defines user story, scope, success/error behavior, dependencies, risks, and source of truth. Proof-first is the implementation discipline: execution must choose `test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof` from `skills/references/spec-driven-development-discipline.md` before claiming completion.

## Applies To

Use this reference from master and orchestrator skills that pilot more than one phase or owner skill, including `001-sg-build`, `002-sg-maintain`, `007-sg-content`, `006-sg-design`, `900-shipglowz-core build`, `004-sg-deploy`, `003-sg-bug`, and `400-sg-audit`.

Atomic owner skills may cite this reference only when they need to align their own handoff language with the master lifecycle.

## Work Item Abstraction

A master skill always pilots a single current work item unless it is explicitly in read-only dashboard mode.

Supported work item types:

- `chantier spec`: a `specs/*.md` file for non-trivial spec-first work.
- `bug file`: one Markdown file under `shipglowz_data/workflow/bugs/*.md` for one bug work item.
- `mini-contract`: a short in-report contract for narrow local work that is safe without a full spec.
- `release scope`: the bounded set of files, commit, deployment target, and proof obligations for a release.
- `audit finding set`: a read-only or source-de-chantier finding set that may recommend a future spec.
- `content surface`: a bounded content goal, source, target surface, claim set, and validation surface.
- `skill-maintenance target`: one skill contract or tightly bounded set of skill/public-doc surfaces.

The work item decides source of truth:

- Spec-first work: `specs/*.md` is the source of truth and chantier registry.
- Bug work: `shipglowz_data/workflow/bugs/*.md` is the source of truth for reproduction, status, diagnosis, fix attempts, retest history, closure, and residual risk.
- Bug triage view: `shipglowz_data/workflow/BUGS.md`, when present, is only a compact optional/generated/triage index that points to bug files. It is not mandatory and must not override a bug file.
- Mini-contract work: the final report or active handoff contract is the source until the work either closes or is promoted to a spec or bug file.

Do not create separate source-of-truth registries in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` (legacy/compat only), `shipglowz_data`, or `shipglowz_data/workflow/BUGS.md`.

## Shared Skeleton

Master skills adapt this skeleton to their local owner routes:

```text
intake
  -> work item resolution
  -> platform footprint (greenfield app creation only)
  -> preferred stack preset (greenfield app creation only)
  -> blueprint gate (app creation only)
  -> readiness gate
  -> model/topology routing
  -> delegated or owner-skill execution
  -> targeted validation and evidence routing
  -> verification
  -> post-verify closure
  -> bounded ship/deploy/release routing
```

### 1. Intake And Routing

Normalize the user request into one current work item. Route to the owning skill when the request clearly names only one specialist phase.

Ask only when the answer changes behavior, scope, security, data, permissions, destructive side effects, public claims, closure, staging, or ship risk.

Before asking a user-facing question, load `skills/references/question-contract.md`. The question contract decides when a default is safe enough to choose without asking and how to format numbered decision questions.

### 2. Work Item Resolution

Before creating a new durable artifact, search for an existing matching work item:

- `specs/*.md` for spec-first chantiers.
- `shipglowz_data/workflow/bugs/*.md` for bug work items.
- `shipglowz_data/workflow/BUGS.md` only as a secondary index if it exists.
- current release scope, audit scope, content target, or skill target for master-specific work.

If exactly one work item owns the request, continue it. If several match, ask the user to choose. If none exists and the work is non-trivial, create or route to the correct durable artifact owner.

### 3. Preferred Stack And Blueprint Gates (App Creation Only)

Before the readiness gate, when the work item targets a new application or major new module:

1. Establish the platform footprint using `$SHIPFLOW_ROOT/skills/references/question-contract.md`.
2. Load `$SHIPFLOW_ROOT/skills/references/preferred-stacks.md` and apply compatible operator-approved presets.
3. Load `$SHIPFLOW_ROOT/skills/references/app-blueprints.md`.
4. Scan available blueprints for a match against the request archetype.
5. If a match is found, load the blueprint into the active context without silently overriding an accepted preset.
6. Pass the blueprint to downstream skills (`100-sg-spec`, `306-sg-scaffold`) via handoff.

The blueprint is a global spec skeleton — it pre-fills architecture, stack, models, and conventions. It does not replace spec writing. If no blueprint matches, proceed normally.

This step is optional for master skills that do not create new applications.

### 4. Readiness Gate

Use a full spec when the work is non-trivial, cross-file, cross-surface, risky, public-claim-sensitive, security/data-impacting, deployment-impacting, or needs staged validation.

Use a bug file when the work is a concrete defect, regression, failed test, retest, bug closure, or bug ship-risk question.

Use a mini-contract only when the work is narrow, local, low-risk, verifiable in the current run, and still satisfies the decision-quality contract. A mini-contract reduces process weight, not solution quality or excellence.

Do not start implementation from a draft, ambiguous, or contradictory work item.

### 4. Model And Topology Routing

Before expensive or risky execution, choose the model profile using `704-sg-model` guidance or the relevant local model-routing reference, bounded by `skills/references/decision-quality-contract.md`.

Before file work, validation, closure preparation, or ship preparation, choose topology using `skills/references/master-delegation-semantics.md`. Favor subagents by default: sequential normally, parallel only for read-only fan-out or ready `Execution Batches`. Master-skill invocation authorizes bounded sequential subagents; ask again only for material scope, risk, permissions, data, destructive behavior, closure, staging, ship, or parallel execution changes.

Record the choice when it affects trust, cost, evidence, or handoff.

Do not select a smaller, cheaper, faster, or more convenient model/topology if it materially weakens expected correctness, security, performance, maintainability, excellence, or proof quality.

The model decision has two runtime layers:

- Main conversation: recommend or route to the best model, but do not claim the active thread can always switch its own model mid-run.
- Delegated subagents: when the runtime supports model overrides, include model, reasoning or alias behavior, fallback, and application status in each bounded mission.

Use `gpt-5.5` by default in Codex/OpenAI for ambiguous, cross-project, governance-heavy, transverse audit, task-prioritization, prompt/docs migration, and business-risk synthesis work, with `low`, `medium`, `high`, or `xhigh` reasoning calibrated to task risk. Use the `codex` implementation profile from `skills/704-sg-model/references/model-routing.md` for long implementation, multi-file coding, refactors, hard debugging, and terminal-heavy agentic execution. For small bounded subagent missions, default to `gpt-5.4-mini` only when quality-equivalent; use `gpt-5.3-codex-spark` for Spark-eligible summary, text-only, micro-code, targeted UI/local edit, or other low-risk bounded missions when Spark credits/availability permit.

Model-topology arguments are delegated subagent requests:

- `spark` / `--spark`: Spark subagent, `low` by default, only when quality-equivalent.
- `codex` / `--codex`: Codex implementation-profile subagent.
- `sous-agent`, `subagent`, `agents`: subagent using the current model/profile unless a stronger alias is supplied.
- `mini` / `--mini`: `gpt-5.4-mini` subagent for low-risk bounded work.

### 5. Execution Through Owners

Master skills orchestrate; owner skills own specialist internals.

Examples:

- `102-sg-start` owns spec implementation.
- `102-sg-start` may run bounded local auto-verification when the remaining proof is local, tool-backed, non-destructive, and has no preview, production, auth/browser, Sentry, device, manual QA, secret, commit, push, ship, or external side-effect requirement. This does not make `102-sg-start` the full lifecycle orchestrator.
- `106-sg-fix` owns bug diagnosis and fix attempts.
- `107-sg-test` owns durable manual QA, retests, and bug-file mutation.
- `300-sg-docs` owns documentation corpus creation/update/audit.
- `005-sg-ship` owns staging, commit, and push.
- `405-sg-prod`, `108-sg-browser`, and `109-sg-auth-debug` own deployment/browser/auth proof.

Do not duplicate owner internals inside a master skill for convenience.

### 6. Validation And Evidence Routing

Run checks and evidence collection that match the changed surface. Do not invent proof.

For behavior, bug, skill-contract, UI/docs/auth/deploy, operational, or integration changes, name the chosen proof path and verify that the evidence matches it.

Use proof owners by evidence type:

- local checks: `105-sg-check` or project validation commands
- hosted deployment truth: `405-sg-prod`
- non-auth browser/page proof: `108-sg-browser`
- auth/session/provider/protected-route proof: `109-sg-auth-debug`
- durable manual QA or bug retest evidence: `107-sg-test`

### 7. Verification

Run or route through `103-sg-verify` when the user story, release scope, content promise, bug closure, or skill maintenance outcome needs coherence verification.

If an owner skill such as `102-sg-start` already ran explicitly eligible local auto-verification, a master skill may count that local proof for the matching local proof obligation. It must still route or run any remaining broader, hosted, browser, manual, production, closure, or ship proof through the normal owner skills.

If verification fails, route back to correction, retest, spec update, or blocked report. Do not proceed to closure or ship as if the work passed.

### 8. Documentation Reflection Before Closure

Before `104-sg-end`, any milestone that can imply completion must load and apply `$SHIPFLOW_ROOT/skills/references/documentation-reflection-gate.md` against the changed behavior and the canonical project docs map.

Use the reference's exact classification and routing rules; do not wait for the operator to notice documentation drift.

### 9. Post-Verify Closure And Ship

After verification passes, the master skill should continue through its owned closure and ship route unless a named stop condition blocks it.

Typical routes:

- `001-sg-build`: `104-sg-end -> 005-sg-ship`
- `002-sg-maintain`: `104-sg-end` when a chantier needs closure bookkeeping, then `005-sg-ship` or `004-sg-deploy`
- `007-sg-content`: `103-sg-verify -> 005-sg-ship` for bounded content changes
- `900-shipglowz-core build`: `300-sg-docs/help update -> 005-sg-ship`
- `004-sg-deploy`: `105-sg-check -> 005-sg-ship -> 405-sg-prod -> proof -> 103-sg-verify -> 304-sg-changelog`
- `003-sg-bug`: retest/verify/ship-risk execution from the bug file through owner skills

Do not end a successful post-verify master report with a manual `/104-sg-end`, `/005-sg-ship`, or `/004-sg-deploy` next step unless a concrete blocker prevents orchestration in the current run.

## Bug Work Item Rules

Use this vocabulary:

- `bug work item`: the lifecycle unit for one bug.
- `bug file`: the durable Markdown source of truth under `shipglowz_data/workflow/bugs/*.md`.
- `bug index` or `triage view`: optional `shipglowz_data/workflow/BUGS.md` if present.

Avoid folder-like bug vocabulary in new shared doctrine and master-skill instructions. Existing legacy references should be cleaned when touched.

Bug source-of-truth rules:

- Read `shipglowz_data/workflow/bugs/BUG-ID.md` first when a bug ID is known.
- Use `shipglowz_data/workflow/BUGS.md` only to discover candidate bug IDs or show a compact dashboard.
- If `shipglowz_data/workflow/BUGS.md` disagrees with the bug file, the bug file wins and the index should be regenerated or reconciled.
- If a bug file exists without `shipglowz_data/workflow/BUGS.md`, the bug still exists and can be routed.
- If `shipglowz_data/workflow/BUGS.md` references a missing bug file, treat it as an index gap, not as durable evidence.

## Stop Conditions

Stop, ask, or reroute when:

- no single work item can be identified
- the current work item is not ready
- a bug has no usable bug file and cannot be reconstructed safely
- the requested operation would bypass an owner skill's gate
- validation or evidence is missing for the promised outcome
- verification fails
- closure or ship scope includes unrelated dirty files
- the next action changes material scope, security, data, permissions, destructive behavior, public claims, staging, or release semantics

## Reporting

User reports should stay concise:

- result
- work item path or scope
- route taken
- validation/evidence
- remaining blockers only when real
- compact chantier block when applicable

Agent/handoff reports may add work item resolution details, model/topology choice, owner-skill routes, validation matrices, and stop conditions.
