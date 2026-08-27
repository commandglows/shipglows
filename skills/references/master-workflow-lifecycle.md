---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.9.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-27"
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
  - skills/900-shipglows-core/SKILL.md
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
  - skills/references/git-temporary-artifact-lifecycle.md
  - skills/references/git-milestone-delivery-contract.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.8.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.7.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.4.4"
    required_status: draft
  - artifact: "skills/references/git-temporary-artifact-lifecycle.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-05-04: master skills should share the same workflow skeleton instead of duplicating lifecycle doctrine."
  - "User decision 2026-05-04: bug work uses one Markdown bug file per bug under shipglows_data/workflow/bugs/*.md; shipglows_data/workflow/BUGS.md is optional/generated/triage view, not the source of truth."
  - "User decision 2026-05-04: user-facing questions should share a numbered, context-aware question/default contract."
  - "User decision 2026-05-06: 006-sg-design joins the master lifecycle set."
  - "User decision 2026-05-08: 003-sg-bug is a lifecycle executor through owner skills and bounded subagents, not a simple next-command router."
  - "Operator correction 2026-08-17: ShipGlows prioritizes shipped business value and execution speed while preserving coherent architecture and non-negotiable safety proportional to real risk."
  - "User decision refined 2026-08-07: favor subagents broadly; independent read-only scopes run in parallel by default, mutations are delegated sequentially, and parallel writes require prepared non-overlapping Execution Batches."
  - "User decision 2026-06-10: master-skill invocation is consent for bounded sequential subagents; `spark`, `codex`, `sous-agent`/`subagent`, and `mini` arguments request model-specific subagent delegation."
  - "Spec auto-follow-through-for-local-only-102-sg-start-verification.md defines bounded local auto-verify for 102-sg-start without changing full 001-sg-build lifecycle ownership."
  - "User decision 2026-06-23: blueprints act as global spec skeletons for app archetypes, consumed by the Blueprint Gate in 001-sg-build."
  - "User decision 2026-06-23: Blueprint Gate fires after work item resolution and before the readiness gate for app creation work items."
  - "Operator correction 2026-07-17: preferred stack presets resolve after platform footprint and before blueprint matching."
  - "Operator decision 2026-08-07: lifecycle orchestration defaults to parallel read-only fan-out and reserves parallel writes for prepared non-overlapping Execution Batches."
  - "Operator decision 2026-08-14: lifecycle approval has a cumulative fast path for exact local routine reversible mutations and retains the full plan for every ineligible mutation."
  - "Operator decision 2026-08-21: validated implementation milestones commit and push before execution continues, and clean chantier closure requires ordinary final push."
  - "Operator decision 2026-08-16: task-scoped agent branches and worktrees remain lifecycle-owned until removal or another explicit terminal disposition."
  - "Operator correction 2026-08-17: daily MVP work should privilege construction, use zero or one focused check when sufficient, and commit/push every clean completed chantier by default."
  - "Operator decision 2026-08-21: lightweight Git persistence preflight runs at existing start, resume, sensitive-operation, and closure boundaries while healthy state stays silent."
  - "Operator correction 2026-08-27: every long-running process is lifecycle-owned until its exact session or PID is stopped and its termination is verified."
next_review: "2026-11-07"
next_step: "/103-sg-verify master workflow lifecycle reference"
---

# Master Workflow Lifecycle

## Purpose

This reference defines the shared lifecycle skeleton for ShipGlows master and orchestrator skills.

It does not redefine delegation, subagent, short-confirmation, or parallelism semantics. Load `skills/references/master-delegation-semantics.md` for execution topology.

Before choosing a lifecycle route, model, topology, owner skill, mini-contract, or direct execution path, load `skills/references/decision-quality-contract.md`. The lifecycle must target the smallest valuable shippable outcome. Architecture and safety remain professional constraints; among paths that meet the applicable floor, choose the fastest and simplest. Extra ceremony, proof, abstraction, or orchestration needs a concrete risk or delivery benefit.

Spec-first is the outer lifecycle contract: it defines user story, scope, success/error behavior, dependencies, risks, and source of truth. Proof-first is the implementation discipline: execution must choose `test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof` from `skills/references/spec-driven-development-discipline.md` before claiming completion.

Before any intentional mutation, load `skills/references/mutation-plan-approval.md`. Apply exact micro-request authority only to one qualifying micro-mutation; it does not authorize a chantier. Every other mutation chooses fast validation only when every cumulative eligibility criterion is established, otherwise presents the full plan, and waits for explicit post-message approval. Readiness, a ready spec, a master-skill invocation, or delegation consent never substitutes for chantier approval. For mutating technical chantiers, also load `git-milestone-delivery-contract.md`: ordinary exact-scope milestone commits and pushes inherit an approved full plan that disclosed remote persistence, and need no duplicate approval.

At the first-write, interrupted-resume, sensitive-operation, and closure boundaries of a Git-backed chantier, apply `git-persistence-preflight.md`. This is one silent read-only inspection when healthy, not a new lifecycle stage. Before auth, payment, permission, migration, destructive, tenant, secret, production, or private-data mutation, require the relevant baseline backed up remotely; never manufacture a checkpoint from incomplete, failing, secret-bearing, ambiguous, or unrelated work.

## Applies To

Use this reference from master and orchestrator skills that pilot more than one phase or owner skill, including `001-sg-build`, `002-sg-maintain`, `007-sg-content`, `006-sg-design`, `900-shipglows-core build`, `004-sg-deploy`, `003-sg-bug`, and `400-sg-audit`.

Atomic owner skills may cite this reference only when they need to align their own handoff language with the master lifecycle.

## Work Item Abstraction

A master skill always pilots a single current work item unless it is explicitly in read-only dashboard mode.

Supported work item types:

- `chantier spec`: a `specs/*.md` file for non-trivial spec-first work.
- `bug file`: one Markdown file under `shipglows_data/workflow/bugs/*.md` for one bug work item.
- `mini-contract`: a short in-report contract for narrow local work that is safe without a full spec.
- `release scope`: the bounded set of files, commit, deployment target, and proof obligations for a release.
- `audit finding set`: a read-only or source-de-chantier finding set that may recommend a future spec.
- `content surface`: a bounded content goal, source, target surface, claim set, and validation surface.
- `skill-maintenance target`: one skill contract or tightly bounded set of skill/public-doc surfaces.

The work item decides source of truth:

- Spec-first work: `specs/*.md` is the source of truth and chantier registry.
- Bug work: `shipglows_data/workflow/bugs/*.md` is the source of truth for reproduction, status, diagnosis, fix attempts, retest history, closure, and residual risk.
- Bug triage view: `shipglows_data/workflow/BUGS.md`, when present, is only a compact optional/generated/triage index that points to bug files. It is not mandatory and must not override a bug file.
- Mini-contract work: the final report or active handoff contract is the source until the work either closes or is promoted to a spec or bug file.

Do not create separate source-of-truth registries in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` (legacy/compat only), `shipglows_data`, or `shipglows_data/workflow/BUGS.md`.

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

Ask only when the answer changes behavior, scope, security, data, permissions, destructive side effects, public claims, closure, unapproved staging, or ship risk. Exact-scope staging for an already approved technical commit is not a new decision.

Before asking a user-facing question, load `skills/references/question-contract.md`. The question contract decides when a default is safe enough to choose without asking and how to format numbered decision questions.

### 2. Work Item Resolution

Before creating a new durable artifact, search for an existing matching work item:

- `specs/*.md` for spec-first chantiers.
- `shipglows_data/workflow/bugs/*.md` for bug work items.
- `shipglows_data/workflow/BUGS.md` only as a secondary index if it exists.
- current release scope, audit scope, content target, or skill target for master-specific work.

If exactly one work item owns the request, continue it. If several match, ask the user to choose. If none exists and the work is non-trivial, create or route to the correct durable artifact owner.

### 3. Preferred Stack And Blueprint Gates (App Creation Only)

Before the readiness gate, when the work item targets a new application or major new module:

1. Establish the platform footprint using `$SHIPGLOWS_ROOT/skills/references/question-contract.md`.
2. Load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md` and apply compatible operator-approved presets.
3. Load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`.
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

Before file work, validation, closure preparation, or ship preparation, choose topology using `skills/references/master-delegation-semantics.md`. Favor subagents by default: parallel for two or more independent read-only scopes, sequential for writes, and parallel writes only through ready `Execution Batches`. Master-skill invocation authorizes bounded sequential and read-only parallel subagents; ask again only for material scope, risk, permissions, data, destructive behavior, closure, unapproved staging, ship, or unauthorized parallel-write changes.

Record the choice when it affects trust, cost, evidence, or handoff.

Do not select a smaller, cheaper, faster, or more convenient model/topology if it materially weakens expected correctness, security, performance, maintainability, excellence, or proof quality.

The model decision has two runtime layers:

- Main conversation: recommend or route to the best model, but do not claim the active thread can always switch its own model mid-run.
- Delegated subagents: when the runtime supports model overrides, include model, reasoning or alias behavior, fallback, and application status in each bounded mission.

Use `skills/704-sg-model/references/model-routing.md` as the sole detailed model matrix. In brief, route frontier/high-cost-of-error reasoning to Sol, balanced daily work to Terra, bounded low-risk/high-volume missions to Luna when quality remains equivalent, and long agentic implementation to the `codex` profile. Use Spark only when the runtime explicitly exposes it; otherwise apply the canonical quality-equivalent fallback. Keep model and reasoning effort as separate decisions and record whether an override was actually applied.

Model-topology arguments are delegated subagent requests:

- `spark` / `--spark`: Spark subagent, `low` by default, only when quality-equivalent.
- `codex` / `--codex`: Codex implementation-profile subagent.
- `sous-agent`, `subagent`, `agents`: subagent using the current model/profile unless a stronger alias is supplied.
- `mini` / `--mini`: Luna-class subagent for low-risk bounded work, resolved through the current model-routing reference.

### 5. Execution Through Owners

Master skills orchestrate; owner skills own specialist internals.

Examples:

- `102-sg-start` owns spec implementation.
- `102-sg-start` may run bounded local auto-verification only when the shared
  checkpoint triggers below apply, or when an immediate high-risk focused check
  is necessary. Eligibility alone does not authorize checks during intermediate
  conversation turns. This does not make `102-sg-start` the full lifecycle
  orchestrator.
- `106-sg-fix` owns bug diagnosis and fix attempts.
- `107-sg-test` owns durable manual QA, retests, and bug-file mutation.
- `300-sg-docs` owns documentation corpus creation/update/audit.
- `005-sg-ship` owns staging, commit, and push.
- `405-sg-prod`, `108-sg-browser`, and `109-sg-auth-debug` own deployment/browser/auth proof.

Do not duplicate owner internals inside a master skill for convenience.

### 5.1 Managed Process Lifecycle

Any command that may outlive its immediate check, including a development server,
watcher, log stream, tunnel, emulator, or interactive tool, is a managed process.
Before starting it, the executing agent must name its bounded purpose, retain a
controllable session handle or exact PID, and define the stop condition. Never
detach a process without a lifecycle owner and a deterministic termination path.

The agent that starts a managed process owns it until one terminal disposition is
proven: `stopped`, `transferred-explicit`, or `retained-explicit`. Normal completion,
failure, interruption, task replacement, worktree cleanup, and final handoff all
trigger reconciliation. For `stopped`, signal the retained session or exact PID,
wait for exit, and verify that the exact process no longer runs; do not kill by a
broad executable name or affect unrelated processes. A transfer or retention must
name the new owner or operational reason, scope, and review/stop condition.

An untracked, unreachable, or still-running managed process blocks clean closure
and removal of any directory it uses. A final report may omit healthy lifecycle
detail, but it must expose a non-terminal disposition as a concrete limit.

### 6. Validation And Evidence Routing

Validation is checkpoint-based, not message-based. Do not automatically run ESLint,
typechecks, tests, production builds, or other heavyweight checks after each
operator message, small correction, or intermediate implementation slice.

Run checks only when one of these triggers is present:

- the operator explicitly asks for checks, a build, lint, or verification;
- the current work reaches an explicit checkpoint or the end-of-conversation
  handoff;
- `104-sg-end` / `SGEND` or `005-sg-ship` / `SGSHIP` owns the next step;
- a high-risk change makes an immediate focused check necessary to avoid unsafe
  continuation, and the check is limited to that risk.

When no trigger is present, record `validation deferred: intermediate work` and
continue the implementation. A deferred check is not a failure or a claim that
the work is verified. The next checkpoint must run the proportional proof before
completion, closure, or ship claims.

After an explicit coherent milestone passes its proportional proof, route immediately to `005-sg-ship checkpoint`. Do not begin the next milestone while its owned diff remains uncommitted or its owned commit remains only local. A message or partial edit is not a milestone.

For daily construction, start from the smallest useful proof rather than from a suite:

- a low-risk local edit may use zero automated checks when no focused check can materially detect a regression;
- a behavior change normally uses one focused regression, contract, syntax, or smoke check;
- do not stack lint, typecheck, build, tests, metadata, budget, audit, and full-suite commands merely because they exist;
- reserve full suites and broad audit/check bundles for release preparation, explicit health or security audits, dependency/platform migrations, broad shared-runtime changes, high-risk security/data/auth/payment/destructive surfaces, or a focused failure that establishes the need.

Document the narrow proof or the concrete reason for no check. Skipped irrelevant broad checks do not weaken an iteration claim; an attempted failing check still blocks normal shipping.

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

### 8. Mandatory Visible Documentation Reflection Before Closure

Before `104-sg-end`, full-close shipping, or any other report/transition claiming `closed`, `complete`, `done`, `resolved`, or `shipped`, load and apply `$SHIPGLOWS_ROOT/skills/references/documentation-reflection-gate.md` against the changed behavior and the canonical project docs map.

Use the reference's exact classification and routing rules; do not wait for the operator to notice documentation drift. Every closure report exposes `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>`. A material `needs review` result keeps the chantier partial.

### 9. Post-Verify Closure And Ship

After verification passes, the master skill should continue through its owned closure and ship route unless a named stop condition blocks it.

For a clean completed daily chantier, the default terminal route is bounded commit and push, and it is mandatory rather than an unpushed handoff. Include ordinary current-branch push in the approval plan so no closing ceremony repeats. If no closure diff remains, the latest owned milestone commit is final; never create an empty commit. Explicit local-only intent or a push blocker leaves delivery pending and forbids standard clean closure.

When the run created a task-scoped branch or worktree, continue through `005-sg-ship` until `git-temporary-artifact-lifecycle.md` records a terminal Git disposition. `pending` forbids a fully clean completion; `retained-explicit` is terminal only with a concrete reason and review date, while `blocked` remains a visible limit.

Typical routes:

- `001-sg-build`: `104-sg-end -> 005-sg-ship`
- `002-sg-maintain`: `104-sg-end` when a chantier needs closure bookkeeping, then `005-sg-ship` or `004-sg-deploy`
- `007-sg-content`: `103-sg-verify -> 005-sg-ship` for bounded content changes
- `900-shipglows-core build`: `300-sg-docs/help update -> 005-sg-ship`
- `004-sg-deploy`: `105-sg-check -> 005-sg-ship -> 405-sg-prod -> proof -> 103-sg-verify -> 304-sg-changelog`
- `003-sg-bug`: retest/verify/ship-risk execution from the bug file through owner skills

Do not end a successful post-verify master report with a manual `/104-sg-end`, `/005-sg-ship`, or `/004-sg-deploy` next step unless a concrete blocker prevents orchestration in the current run.

## Bug Work Item Rules

Use this vocabulary:

- `bug work item`: the lifecycle unit for one bug.
- `bug file`: the durable Markdown source of truth under `shipglows_data/workflow/bugs/*.md`.
- `bug index` or `triage view`: optional `shipglows_data/workflow/BUGS.md` if present.

Avoid folder-like bug vocabulary in new shared doctrine and master-skill instructions. Existing legacy references should be cleaned when touched.

Bug source-of-truth rules:

- Read `shipglows_data/workflow/bugs/BUG-ID.md` first when a bug ID is known.
- Use `shipglows_data/workflow/BUGS.md` only to discover candidate bug IDs or show a compact dashboard.
- If `shipglows_data/workflow/BUGS.md` disagrees with the bug file, the bug file wins and the index should be regenerated or reconciled.
- If a bug file exists without `shipglows_data/workflow/BUGS.md`, the bug still exists and can be routed.
- If `shipglows_data/workflow/BUGS.md` references a missing bug file, treat it as an index gap, not as durable evidence.

## Stop Conditions

Stop, ask, or reroute when:

- no single work item can be identified
- the current work item is not ready
- a bug has no usable bug file and cannot be reconstructed safely
- the requested operation would bypass an owner skill's gate
- validation or evidence is missing for the promised outcome
- verification fails
- closure or ship scope includes unrelated dirty files
- the next action changes material scope, security, data, permissions, destructive behavior, public claims, unapproved staging, or release semantics

## Reporting

User reports should stay concise:

- result
- work item path or scope
- route taken
- validation/evidence
- remaining blockers only when real
- compact chantier block when applicable

Agent/handoff reports may add work item resolution details, model/topology choice, owner-skill routes, validation matrices, and stop conditions.
