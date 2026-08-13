---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.18.5"
project: ShipGlows
created: "2026-04-22"
updated: "2026-08-04"
status: draft
source_skill: 300-sg-docs
scope: spec-driven-workflow
owner: unknown
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems:
  - skills/
  - skills/000-shipglows/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/011-sg-pilotage/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/references/entrypoint-routing.md
  - skills/references/decision-quality-contract.md
  - skills/references/operator-partnership-contract.md
  - templates/
  - tools/shipglows_metadata_lint.py
  - skills/references/canonical-paths.md
  - shipglows_data/technical/
  - shipglows_data/editorial/
  - skills/references/editorial-content-corpus.md
  - skills/references/reporting-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/question-contract.md
depends_on: []
supersedes: []
evidence:
  - "Document title and body define ShipGlows V3 workflow doctrine and artifact metadata rules"
  - "Updated on 2026-04-26 to clarify the documentation frame, context layer, metadata doctrine, and artifact boundaries"
  - "Updated on 2026-04-26 to add the content architecture and repurposing artifact"
  - "Updated on 2026-04-27 to define canonical ShipGlows path resolution for tools and references"
  - "Updated on 2026-04-29 to formalize the ShipGlows language doctrine: English internal contracts, user-facing interaction in the user's active language."
  - "Updated on 2026-05-01 to add the internal technical documentation layer and Documentation Update Plan gate."
  - "Updated on 2026-05-01 to add editorial content governance, public claim safety, Astro runtime-content schema boundaries, and the Editorial Update Gate."
  - "Updated on 2026-05-02 to define the governance corpus lifecycle: 305-sg-init bootstraps, 300-sg-docs maintains, 001-sg-build consumes."
  - "Updated on 2026-05-02 to add 108-sg-browser as the generic non-auth browser evidence path."
  - "Updated on 2026-05-03 to add 004-sg-deploy as the release confidence orchestrator."
  - "Updated on 2026-05-03 to add 002-sg-maintain as the recurring project maintenance orchestrator."
  - "Updated on 2026-05-03 to add shared report modes: concise user reports by default and explicit detailed agent handoff reports."
  - "Updated on 2026-05-04 to clarify user-mode report polish: active-language labels, outcome/evidence/limits ordering, and sober status emojis."
  - "Updated on 2026-05-04 to require business-context decision questions for 001-sg-build planning."
  - "Updated on 2026-05-04 to add a skill launch cheatsheet for master and supporting modes."
  - "Updated on 2026-05-04 to route fuzzy skill-maintenance ideas through 700-sg-explore before 100-sg-spec."
  - "Updated on 2026-05-04 to add 007-sg-content as the master content lifecycle entrypoint."
  - "Updated on 2026-05-04 to clarify 001-sg-build delegated sequential subagent consent and separate subagents from parallelism."
  - "Updated on 2026-05-04 to extract shared master delegation semantics to skills/references/master-delegation-semantics.md."
  - "Updated on 2026-05-04 to extract the shared master workflow lifecycle and clarify that shipglows_data/workflow/bugs/*.md files are bug source of truth while shipglows_data/workflow/BUGS.md is optional/generated triage."
  - "Updated on 2026-05-04 to document 000-shipglows <instruction> as the primary non-technical router with direct main-thread handoff to selected skills."
  - "Updated on 2026-05-05 to document shared question/default doctrine across skills."
  - "Updated on 2026-05-06 to add 006-sg-design as the master design lifecycle entrypoint."
  - "Updated on 2026-07-15 to rename 008-sg-customer as the customer activation lifecycle entrypoint."
  - "Updated on 2026-06-01 to add 600-sg-local-cloud-sync as the local-to-cloud data promotion, merge, sync UX, and security contract entrypoint."
  - "Updated on 2026-05-08 to clarify 003-sg-bug as a bug lifecycle executor that continues through owner skills and bounded subagents when safe."
  - "Updated on 2026-05-11 to add competitive intelligence and affiliate program registries as project-local business artifacts."
  - "Updated on 2026-05-11 to make project governance artifacts canonical under shipglows_data/, including workflow specs."
  - "Updated on 2026-06-28 to clarify public/docs runtime handoffs: helpers explain, the router hands off, owner skills execute, and OpenCode/KiloCode internal calls are not manual commands."
  - "Updated on 2026-06-29 to add Tariq as a named profile for acquisition-channel arbitration and traffic measurement discipline."
  - "Updated on 2026-07-17 to route deterministic micro-edits through direct execution before loading owner workflows."
  - "Updated on 2026-08-04 to route review-template ownership through 011-sg-pilotage review after the pilotage consolidation."
next_review: "unknown"
next_step: "/300-sg-docs audit shipglows_data/workflow/playbooks/spec-driven-workflow.md"
---

# ShipGlows V3: Spec-Driven Workflow

## Summary

ShipGlows V3 shifts iteration upstream.

The current documentation frame is already solid on three axes:

- technical: `CLAUDE.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/context-function-tree.md`, `shipglows_data/editorial/content-map.md`, `shipglows_data/technical/guidelines.md`, and `shipglows_data/workflow/specs/`
- workflow: `100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `300-sg-docs`, and versioned metadata
- product/business: `shipglows_data/business/business.md`, `shipglows_data/branding/branding.md`, versioned docs, and `depends_on` relationships
- editorial coherence: `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/`, public content, claims, page intent, and Astro content schema policy

The recent progress is structural rather than cosmetic:

- a clear agent entrypoint
- a dedicated context layer
- a metadata and lint doctrine
- a public-content governance layer for claims, page intent, editorial gates, and runtime content schema boundaries
- a cleaner separation between active docs, trackers, and runtime content

Default operating stance:
- complete the context before execution
- make the contract implementable by a fresh agent
- avoid “prompt and correct” loops as the normal path
- treat late clarification as a bounded exception, not the workflow itself
- treat sparse operator prompts as delegated intent when the owner layer is inferable locally

Skill launch cheatsheet:

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-technical first command | `000-shipglows <instruction>` | Answers pure conversation directly, executes deterministic micro-edits directly with focused validation, routes substantive work to the right skill, and asks one numbered question when materially ambiguous. |
| Named operator profile | `%Victoire <instruction>`, `%SEO-specialist <instruction>`, or `%Tariq <instruction>` | Canonical profile syntax. Activates the named operator profile; `#Tag` remains a focus-tag surface and the router still picks the owner skill. |
| Non-technical first command with named operator profile | `000-shipglows profile=victoire <instruction>`, `000-shipglows profile=seo-specialist <instruction>`, or `000-shipglows profile=tariq <instruction>` | Same router, but with the selected profile active so the role contract shapes the answer or handoff framing. |
| Non-trivial product, code, site, or docs work | `001-sg-build [spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>` | Plain task text is the story; use `spark`, `codex`, `mini`, `agents`, or `sous-agent` to make model-specific delegated sequential execution a validation gate; for user-facing features, `001-sg-build` evaluates whether to suggest or route `/008-sg-customer` after implementation; use detailed report modes only for handoff evidence. |
| Recurring project upkeep | `002-sg-maintain [mode]` | `full`/no argument, `quick`, `security`, `deps`, `docs`, `audits`, `no-ship`, `global`. |
| Release confidence after implementation | `004-sg-deploy [target or mode]` | no argument, `skip-check`, `--preview`, `--prod`, `no-changelog`. |
| Deploy-target recommendation for an app project | `004-sg-deploy <project or context>` | Uses the canonical advisory matrix in `skills/references/deploy-target-matrix.md`; ShipGlows advises, but final choice remains project-contextual. |
| Bug-loop lifecycle | `003-sg-bug [BUG-ID, summary, or mode]` | no argument, `BUG-ID`, `--fix`, `--retest`, `--verify`, `--ship`, `--close`. |
| Content management | `007-sg-content [goal, source, file, or mode]` | `plan`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship`. |
| Customer experience | `008-sg-customer <audit|flow|onboarding|recovery> <target>` | One customer owner with exact modes for audits, flow contracts, onboarding, recovery, docs impact, and proof routing. |
| Local-to-cloud data sync | `600-sg-local-cloud-sync <project, feature, or data domains>` | Local data promotion, cloud hydration, merge/conflict policy, sync/save UX states, sensitive-data exclusions, and proof routing. |
| Product entitlements and access gates | `601-sg-product-entitlements <project or feature>` | Entitlement ownership, provider events, activation codes, product-local mirrors, backend authorization gates, support flows, and sync handoffs. |
| Internal skill creation or maintenance | `900-shipglows-core build <idea or path>` | new skill idea, existing skill path, optional `700-sg-explore` for fuzzy placement, runtime/docs validation gates. |
| Design lifecycle | `006-sg-design <design question or goal>` | Master design entrypoint for UI/UX, tokens, playgrounds, component/a11y audits, implementation, browser proof, verification, and ship routing. |
| Design system creation | `006-sg-design system [target]` | Build a complete professional token system from an existing UI; use `playground` or `audit tokens` as explicit modes. |
| Manual expert lifecycle | `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end` | Use when you intentionally want to drive each gate instead of using `001-sg-build`. |
| Commit and push ready work | `005-sg-ship [mode]` | no special argument, `skip-check`, `end la tache`/`end`/`fin`/`close task`, `all-dirty`/`ship-all`/`tout-dirty`. |
| Browser, auth, manual QA, or live deployment proof | `108-sg-browser`, `109-sg-auth-debug`, `107-sg-test`, `405-sg-prod` | Pick by proof type: non-auth browser evidence, auth/session diagnosis, durable manual QA, or deployment truth. |
| Git/GitHub hygiene | `010-sg-technical github [mode]` | `audit`, `branches`, `dependabot`, `fix`, plus current-repo or workspace scope. |

Bug loop entrypoint:

```text
003-sg-bug -> 107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship
```

Use `003-sg-bug` when the operator wants one bug lifecycle executor for a new report, a `BUG-ID`, a retest, a closure question, or a ship-risk question. It continues through existing owner skills and bounded subagents when safe rather than mutating bug records or code in the master thread itself.

Bug repair entrypoint:

```text
106-sg-fix -> fix directly or route to spec-first path
```

General browser evidence entrypoint:

```text
108-sg-browser -> 106-sg-fix / 107-sg-test / 405-sg-prod / 109-sg-auth-debug / 103-sg-verify
```

Use `108-sg-browser` for non-auth page-level browser proof: visible assertions, quick visual checks, accessibility snapshots, screenshots, console summaries, and network summaries.

Optional model-selection entrypoint before execution:

```text
704-sg-model -> choose model / reasoning / fallbacks before 102-sg-start
```

`704-sg-model` chooses a model policy, not a guaranteed mid-thread runtime switch. Model choice follows `skills/references/decision-quality-contract.md`: speed, cost, and latency are fallbacks only when quality-equivalent for the risk. In Codex/OpenAI, use `gpt-5.4-mini` for small bounded low-risk missions, `gpt-5.3-codex-spark` for Spark-eligible summaries, text-only handoffs, micro-code, or targeted UI/local edits when it does not replace needed reasoning and credits/availability permit, the `codex` implementation profile for long implementation, multi-file coding, refactors, hard debugging, and terminal-heavy agentic execution, and `gpt-5.5` with calibrated `low`/`medium`/`high`/`xhigh` reasoning for ambiguous, cross-project, governance-heavy, transverse audit, task-prioritization, prompt/docs migration, and business-risk synthesis work. When subagents are available and the runtime accepts model overrides, each bounded mission should state the model, reasoning effort, quality-equivalent fallback, and whether the override is applied or only recommended.

Primary non-technical router entrypoint:

```text
000-shipglows <instruction> -> direct answer, atomic direct execution, or direct handoff to selected skill
```

`000-shipglows <instruction>` is the recommended first command when the operator does not want to choose a skill. It answers pure conversational requests in the main thread and executes deterministic micro-edits there with focused validation, without loading an owner workflow. It hands non-trivial feature, code, and docs work to `001-sg-build`; maintenance to `002-sg-maintain`; bug-loop work to `003-sg-bug`; release, deploy, or production proof to `004-sg-deploy`; content work to `007-sg-content`; onboarding and activation work to `008-sg-customer`; local-to-cloud sync contract work to `600-sg-local-cloud-sync`; product entitlement and access-gate work to `601-sg-product-entitlements`; internal skill maintenance to `900-shipglows-core build`; and obvious specialist audits to `400-sg-audit-*`. Ambiguous requests get one numbered clarifying question with why, recommended answer, and practical options.

Named operator profiles sit above the router as a human-readable invocation layer. They do not replace skills:

- skill = capability
- operator role = decision contract
- named profile = human-readable entry such as `Victoire`, `SEO Specialist`, or `Tariq`

Example:

```text
%Victoire #SEO Faut-il faire le playbook, la checklist, ou l'audit SEO d'abord ?
```

Compatibility form:

```text
000-shipglows profile=victoire Faut-il faire le playbook, la checklist, ou l'audit SEO d'abord ?
```

The router still selects the owner skill, but the answer should follow the growth-oriented arbitration rules of the `Victoire` profile instead of giving a flat neutral list.

Example:

```text
%Tariq #acquisition Quel canal tester en premier, vers quelle landing, et avec quelle mesure ?
```

Canonical syntax split:

- `%<Profile>` for named operator profiles
- `#<Tag>` for focus tags

The router uses direct main-thread handoff to the selected skill. It does not run a master skill inside a subagent, and it does not duplicate the selected skill's lifecycle. Once selected, each master owns its own delegated sequential execution and proof gates.

Public/docs handoff rule:

- `302-sg-help` explains doctrine, invocation, and routing choices.
- `000-shipglows` routes, answers, or keeps deterministic micro-edits in direct execution.
- The selected lifecycle or specialist skill owns execution after handoff.
- In OpenCode or KiloCode-style runtimes, the operator should ask for the ShipGlows router skill in natural language or through the runtime UI. Internal calls such as `skill({ name: "shipglows" })` are runtime internals, not manual commands.

Direct build entrypoint for non-trivial work:

```text
001-sg-build -> existing chantier check -> 100-sg-spec/101-sg-ready loop -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship
```

`001-sg-build` keeps the user conversation focused on decisions and status while following the shared master lifecycle reference in `skills/references/master-workflow-lifecycle.md` and the delegation reference in `skills/references/master-delegation-semantics.md`: invoking a master skill authorizes bounded delegated sequential execution for the current chantier, `spark`, `codex`, `sous-agent`/`subagent`/`agents`, and `mini` request model-specific subagent delegation, short natural-language confirmations after diagnosis or proposal continue the current chantier with one bounded subagent by intent rather than exact keyword, and parallel execution is allowed only when a ready spec defines non-overlapping `Execution Batches`. After user-facing feature work, `001-sg-build` evaluates whether a `/008-sg-customer` pass should be handled or suggested so beginner adoption, setup, and first-success guidance are not forgotten after the code works.

Recommended release entrypoint after implementation:

```text
004-sg-deploy -> 105-sg-check -> 005-sg-ship -> 405-sg-prod -> 108-sg-browser/109-sg-auth-debug/107-sg-test -> 103-sg-verify -> 304-sg-changelog
```

`004-sg-deploy` is the release confidence orchestrator. It does not replace `005-sg-ship`, `405-sg-prod`, or proof skills; it keeps their gates in order and prevents push/build/health status from being treated as complete release proof.

Recommended maintenance entrypoint for existing projects:

```text
002-sg-maintain -> triage -> 100-sg-spec/101-sg-ready when needed -> delegated maintenance lanes -> 103-sg-verify -> 004-sg-deploy/005-sg-ship
```

`002-sg-maintain` is the master maintenance lifecycle. Its default mode executes maintenance as far as safely possible: bug risk, dependency risk, docs drift, checks, audits, migrations, tasks, and security posture flow through owner skills, bounded subagents, verification, and ship/deploy routing. Use `quick` when the operator only wants the old read-only triage.

Recommended entrypoint for ShipGlows skill maintenance:

```text
900-shipglows-core build -> 700-sg-explore when needed -> 100-sg-spec -> skill contract edit/create -> 900-shipglows-core refresh -> skill budget audit -> 103-sg-verify -> 300-sg-docs/help update -> 005-sg-ship
```

`900-shipglows-core build` is scoped to internal skill lifecycle work and enforces ambiguity reduction, internal/public-surface, docs/help, and validation gates before ship routing. When the skill idea or placement is too fuzzy for one targeted question to settle, it routes to `700-sg-explore` before creating the durable `100-sg-spec` contract.

Recommended content lifecycle entrypoint:

```text
007-sg-content -> CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> 103-sg-verify -> 005-sg-ship
```

`007-sg-content` is the master content-management orchestrator. Its `repurpose <source>` mode owns source-faithful packs; it does not replace `200-sg-redact`, `201-sg-enrich`, `009-sg-marketing` modes, `406-sg-seo`, `300-sg-docs`, `205-sg-veille`, or `203-sg-research`. It chooses and sequences those owners while enforcing public-surface, claim, runtime schema, validation, and missing-surface gates.

Recommended end-user experience and activation entrypoint:

```text
008-sg-customer -> first-success path -> setup order -> states/recovery -> docs impact -> proof or 001-sg-build
```

`008-sg-customer` is the customer-experience skill. It does not replace `006-sg-design` or `001-sg-build`; it defines the user path contract that helps users understand a feature, trust it, reduce friction, complete setup in the right order when needed, recover from skipped or blocked steps, and reach value with proof and docs coherence.

Recommended local-to-cloud sync contract entrypoint:

```text
600-sg-local-cloud-sync -> data inventory -> account association -> promotion/hydration -> merge/conflict/tombstones -> sync UX/security -> proof or 001-sg-build
```

`600-sg-local-cloud-sync` is the data-trust skill for local-first products. It does not replace `001-sg-build` or `008-sg-customer`; it defines the sync contract that prevents silent local data loss, cross-account replay, vague merge policy, unsafe secret sync, and unproven reinstall-recovery promises.

Recommended product-entitlement contract entrypoint:

```text
601-sg-product-entitlements -> identity/provider/access separation -> ledger ownership -> backend gates/support -> sync/auth handoff or 001-sg-build
```

`601-sg-product-entitlements` is the access-trust skill for product gates. It does not replace `600-sg-local-cloud-sync` or `109-sg-auth-debug`; it defines the entitlement ownership and authorization contract before product data, premium capabilities, provider events, activation codes, refunds, revokes, support flows, or entitlement-gated sync move into implementation.

For expert manual control, the default non-trivial flow remains:

```text
700-sg-explore -> exploration_report -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end
```

For small, explicit, local fixes, the bounded path remains:

```text
102-sg-start -> 103-sg-verify -> 104-sg-end
```

The goal is not to remove iteration or pursue the shortest route. The goal is to move ambiguity reduction before coding, then let verification close the loop when implementation or spec drift appears without turning the workflow into iterative prompt repair. Small scope is an edit-safety discipline; it never lowers the quality bar.

## Technical Documentation Layer

ShipGlows maintains an internal code-proximate technical documentation layer under `shipglows_data/technical/`.

- `shipglows_data/technical/README.md` indexes subsystem technical docs.
- `shipglows_data/technical/code-docs-map.md` maps code paths to primary technical docs, secondary docs, required validation, and docs update triggers.
- `templates/technical_module_context.md` is the standard template for subsystem docs.
- `skills/references/technical-docs-corpus.md` tells skills how to load the layer without polluting context.

This layer does not replace `shipglows_data/technical/architecture.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/guidelines.md`, specs, or decision records. It gives agents the closest durable technical context for a code area.

### Documentation Update Gate

After every code-changing execution wave, the Reader must produce a `Documentation Update Plan` from `shipglows_data/technical/code-docs-map.md`. End verification must produce or re-check the plan again.

```markdown
## Documentation Update Plan

- Code changed: `path/or/pattern`
- Subsystem: `707-name`
- Primary technical doc: `shipglows_data/technical/example.md`
- Secondary docs: `...`
- Required action: `none | review | update | create`
- Priority: `low | medium | high`
- Reason: `why this doc is impacted`
- Owner role: `executor | integrator`
- Parallel-safe: `yes | no`
- Notes: `constraints or blockers`
```

The Reader diagnoses impact; an executor or integrator applies updates. A mapped code change must either update the impacted technical doc or record a no-impact justification. There is no stale-doc shipping exception for mapped technical docs.

Shared files are sequential integration files by default: `shipglows_data/technical/code-docs-map.md`, `AGENT.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/guidelines.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and `tools/shipglows_metadata_lint.py`. Parallel documentation work is allowed only when a ready spec defines disjoint file ownership.

`AGENT.md` remains the canonical agent entrypoint. `AGENTS.md`, when present, is a compatibility symlink to `AGENT.md`, not a second maintained Markdown source. `shipglows_data/technical/` remains internal-only in v1 and must not be published to the public site.

## Editorial Content Governance Layer

ShipGlows maintains a public-content governance layer under `shipglows_data/editorial/`.

- `shipglows_data/editorial/content-map.md` remains the canonical content routing map.
- `shipglows_data/editorial/README.md` indexes public-content governance docs.
- `shipglows_data/editorial/public-surface-map.md` maps public pages, README, FAQ, docs overview, public skill pages, and future content surfaces.
- `shipglows_data/editorial/page-intent-map.md` records route intent, CTA, source contracts, and shared-file risk.
- `shipglows_data/editorial/claim-register.md` bounds public claims about security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, and business outcomes.
- `shipglows_data/editorial/editorial-update-gate.md` defines the `Editorial Update Plan`, `Claim Impact Plan`, `no editorial impact`, and `pending final copy` statuses.
- `shipglows_data/editorial/astro-content-schema-policy.md` protects Astro content schema and runtime content boundaries.
- `shipglows_data/editorial/blog-and-article-surface-policy.md` requires agents to report `surface missing: blog` when no blog/article surface is declared.

When a wave changes visible behavior, public content, README guidance, public docs, FAQ, pricing, support copy, public skill promises, or claims, the Editorial Reader produces an `Editorial Update Plan`. Sensitive claims also get a `Claim Impact Plan`.

The Editorial Reader is read-only. It diagnoses public-content impact; an executor or integrator applies updates. Shared editorial files stay sequential unless a ready spec assigns exclusive write ownership.

## Governance Corpus Lifecycle

Future projects should not rerun ShipGlows's shipped technical or editorial governance specs as manual per-project chantiers. Those specs are source doctrine. The normal project workflow uses lightweight project-local corpora:

- `305-sg-init` bootstraps `shipglows_data/technical/`, `shipglows_data/technical/code-docs-map.md`, `shipglows_data/editorial/content-map.md`, and applicable `shipglows_data/editorial/` files, or reports `skipped`, `needs audit`, or `blocked` with a recovery command.
- `300-sg-docs` owns ongoing corpus creation, first-run bootstrap, update, and audit. Use `/300-sg-docs technical`, `/300-sg-docs editorial`, or `/300-sg-docs update` to adopt missing governance layers in existing projects.
- `001-sg-build` consumes the corpora through a Governance Corpus Gate before implementation and before closure/ship when public-content impact is relevant. Missing or stale corpus state routes to `300-sg-docs` or blocks instead of relying on chat memory.

Technical governance applies to code projects by default. Editorial governance applies when public pages, README promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content surfaces exist. If a layer is not applicable, the workflow records the reason instead of silently skipping it.

## Core Principles

- `700-sg-explore` is for ambiguity reduction, not implementation.
- `700-sg-explore` may write an `exploration_report` durable artifact when exploration is substantial or explicitly requested, but it does not write chantier spec history.
- `100-sg-spec` produces an implementation contract, not loose notes.
- `101-sg-ready` enforces a real Definition of Ready before non-trivial execution.
- `000-shipglows <instruction>` is the primary non-technical router; it hands off directly in the main thread to the selected skill and asks one numbered question when the route is ambiguous.
- `001-sg-build` is the master orchestrator for end users and should prefer bounded delegated sequential execution over manual command chaining.
- Master/orchestrator skills must load `skills/references/master-workflow-lifecycle.md` for the shared skeleton: intake, work item resolution, readiness, model/topology routing, owner execution, validation, verification, post-verify closure, and ship/deploy routing.
- Skills must load `skills/references/decision-quality-contract.md` before quality-sensitive routing, model choice, fallback choice, implementation, fix, verification, or recommendation. ShipGlows optimizes first for correctness, security, performance where relevant, maintainability, durability, professional best practices, and proof quality.
- Master/orchestrator skills must load `skills/references/master-delegation-semantics.md` before choosing execution topology. The reference defines delegation, subagents, short approvals, degradation, and spec/batch-gated parallelism.
- Every intentional mutation must load `skills/references/mutation-plan-approval.md`, display `🧭 PLAN À VALIDER`, and receive explicit approval after that plan. Initial imperatives, ready specs, skill invocations, and delegation consent do not replace apply approval.
- User-facing questions follow `skills/references/question-contract.md`: ask only when the answer changes route, scope, risk, proof, closure, ship posture, public claims, or technical/product/editorial direction.
- `001-sg-build` planning questions should be decision briefs for business operators: explain the root problem, business stakes, practical options, and the best-practice recommendation before asking for the decision.
- `002-sg-maintain` is the master orchestrator for recurring project maintenance and should prefer bounded delegated sequential execution over command recommendations.
- `007-sg-content` is the master orchestrator for content management and should route to specialist content, docs, audit, research, validation, and ship skills rather than duplicating their internals.
- `900-shipglows-core build` is the sole internal orchestrator for ShipGlows skill maintenance and should route fuzzy ideas through `700-sg-explore` before `100-sg-spec`, then keep skill contract, refresh, budget, docs/help, and internal/public skill surfaces coherent.
- `102-sg-start` begins execution from a ready contract instead of rediscovering intent, and now decides both model routing and execution topology before coding.
- `103-sg-verify` checks against the spec first, then quality and risks, and can now remediate limited gaps.
- `104-sg-end` closes the task against the delivered scope, not only against the diff.
- agent handoffs should be one-pass: complete context up front, no hidden dependency on chat history, explicit linked systems and consequences.
- business, brand, and documentation artifacts are decision contracts, not passive notes.
- every reusable ShipGlows artifact should be traceable through metadata, evidence, status, risk, and next step.

## Report Modes

ShipGlows skills default to concise user-facing final reports. The default mode is `report=user`: outcome first, active user language for labels and explanations, compact check summary, compact chantier flow, no empty `Reste a faire` or `Prochaine etape`, and no redundant verdict lines when the heading already carries the result. Ship reports should read as outcome, evidence, then limits. A few sober status emojis are allowed when they improve scanning; do not decorate every line.

Detailed reports are explicit. Use `report=agent`, `handoff`, `verbose`, or `full-report` when an orchestrator or downstream agent needs file lists, validation matrices, evidence trails, phase details, or handoff context. Skills must not infer caller identity from runtime state; master skills pass a handoff flag when they need detailed downstream evidence.

Audit skills keep findings first. In user mode, they summarize top findings, proof gaps, chantier potential, and the next real action. Full audit matrices and domain checklist outputs belong in agent/handoff mode unless the user explicitly asks for the long report.

## Specs As Chantier Registry

`shipglows_data/workflow/specs/` is the global registry for spec-first chantiers. A chantier spec is not only an implementation contract; it also keeps the durable run history for the skills that acted on that chantier.

Each chantier spec should expose:

- `source_model` in frontmatter when `100-sg-spec` creates or materially updates the spec
- `Skill Run History` with `Date UTC`, `Skill`, `Model`, `Action`, `Result`, and `Next step`
- `Current Chantier Flow` for the readable status of `100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `104-sg-end`, and `005-sg-ship`

Skill application categories:

- `obligatoire`: `100-sg-spec`, `101-sg-ready`, `001-sg-build`, `002-sg-maintain`, `004-sg-deploy`, `102-sg-start`, `103-sg-verify`, `104-sg-end`, and `005-sg-ship` trace their current run when exactly one chantier spec is in scope.
- `conditionnel`: audits, docs, checks, fixes, deps, perf, migrations, scaffold, content, research, test, prod, backlog, priorities, tasks, changelog, review, and veille skills trace only when the run is explicitly attached to one unique chantier spec.
- `non-applicable`: help, context, model selection, exploration, status, resume, session naming, and the `000-shipglows <instruction>` router do not write to specs; if invoked inside a chantier flow, they report `Chantier: non applicable` or `Chantier: non trace` when useful. The selected lifecycle skill owns any chantier trace after handoff.

That trace category is separate from the internal process role:

- `lifecycle`: creates, readies, starts, verifies, ends, or ships an existing chantier.
- `source-de-chantier`: audits, diagnostics, checks, tests, prod verification, migrations, fixes, research, market study, or veille can reveal work that deserves a new spec.
- `support-de-chantier`: docs, content, scaffolding, changelog, design playground, skill refresh, or init work supports a chantier but should not normally originate one.
- `pilotage`: backlog, tasks, priorities, review, and continuation manage the flow and route to spec when the user or evidence requires it.
- `helper`: context, model choice, help, status, resume, exploration, and naming stay read-only for chantier writes.

The upstream intake flow is:

```text
source skill -> Chantier potentiel -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end/005-sg-ship
```

When a source skill finds non-trivial future work without one unique chantier, it must not write into a guessed spec. It should add a `Chantier potentiel` block with `oui`, `non`, or `incertain`, proposed title, reason, severity, scope, evidence, and a recommended `/100-sg-spec ...` command. `100-sg-spec` then consumes that block and turns it into the durable chantier contract.

No skill should create a separate chantier registry in `TASKS.md`, `AUDIT_LOG.md`, `PROJECTS.md` (legacy), `shipglows_data`, or `shipglows_data/workflow/specs` registry. If a spec cannot be identified or multiple specs match, the skill must stop or report non-trace instead of guessing.

## Artifact Doctrine

ShipGlows separates application content from ShipGlows work artifacts.

Application content is content parsed or rendered by the project runtime: `src/content/**`, MDX blog posts, framework content collections, public SEO pages, and app-specific documentation schemas. Those files must keep the schema required by the application.

ShipGlows work artifacts are produced to run and govern the work. They include:

- agent entrypoint docs
- project context docs
- business, product, brand, GTM, architecture, and technical guideline docs
- specs
- readiness reports
- verification reports
- audit reports
- review reports
- research reports
- exploration reports
- architecture notes
- decision records
- API/component docs generated by ShipGlows
- project business and brand documentation

ShipGlows artifacts use a standard YAML frontmatter schema. This makes them searchable, auditable, and safe to pass between skills.

That artifact doctrine also sharpens the boundary between three categories:

- active decision docs that govern implementation and audits
- trackers and registries that stay lightweight and operational
- runtime content that must preserve the application schema

## Canonical Artifact Taxonomy

ShipGlows-owned artifacts map to seven primary types:

- `entrypoint-router`: request intake and safe initial handoff, exemplified by `000-shipglows`.
- `master-workflow`: chantier orchestration from intake to proof handoff (`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> ...`).
- `specialist-workflow`: bounded domain execution inside a selected master flow.
- `contract`: reusable, mandatory rule text that must stay stable across contexts.
- `reference`: support map, checklist, index, playbook, or examples that help apply a contract.
- `template`: reusable structure with fixed required fields, placeholders, and naming conventions.
- `record`: durable one-case or one-event trace of a specific chantier or durable decision.

To keep boundaries usable, each file should keep one primary type. If a file materially performs two primary roles, the safe outcome is split/extract before adding new content.

Operational tracking files are not ShipGlows decision artifacts and do not require metadata frontmatter:

- `TASKS.md` tracks active work and backlog items.
- `AUDIT_LOG.md` tracks audit history.
- `PROJECTS.md` is legacy registry context (historical/migration) and not active project governance.

Do not migrate those files just to satisfy the artifact schema. If they contain durable decisions, extract those decisions into separate versioned artifacts and leave the tracker readable.

Location rule:

- `shipglows_data` is the local project workflow corpus (`TASKS.md`, `AUDIT_LOG.md`) and not a central control plane.
- The master tracker is not a direct substitute for a local project `TASKS.md`.
- Always distinguish between:
  - the master tracker
  - a project section inside the master tracker
  - the local `TASKS.md` file in a repo
- If a local `TASKS.md` is created after work already exists in the master tracker, split old entries into:
  - active backlog
  - historical completed context
- Do not copy completed historical entries from the master tracker into the local active backlog.
- Per-project decision artifacts belong in the project repository that they govern.
- `shipglows_data/business/business.md`, `shipglows_data/branding/branding.md`, `shipglows_data/editorial/content-map.md`, `shipglows_data/technical/guidelines.md`, project competitor/inspiration registries, affiliate/referral/partner registries, specs, research, and decision records should be edited and versioned in the repo they affect, not duplicated into an external master data directory.
- If `shipglows_data` needs visibility, add a reference or inventory entry, not a second canonical copy.

Skill-aligned artifact templates live in `templates/`. They should encode the structures expected by the active skills (`100-sg-spec`, `101-sg-ready`, `103-sg-verify`, `011-sg-pilotage review`, `203-sg-research`) instead of replacing those conventions. The current templates cover:

- `context`
- `spec`
- `business_context`
- `brand_context`
- `product_context`
- `competitive_intelligence`
- `affiliate_program_registry`
- `architecture_context`
- `gtm_context`
- `technical_guidelines`
- `technical_module_context`
- `audit_report`
- `verification_report`
- `readiness_report`
- `review_report`
- `research_report`
- `exploration_report`
- `decision_record`
- `content_map`

Validate metadata with:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}}"
"$SHIPGLOWS_ROOT/tools/shipglows_metadata_lint.py"
```

The linter is intentionally dependency-free. It checks the default ShipGlows artifact locations (`docs/`, `shipglows_data/`, `AGENT.md`, plus legacy root artifact names as migration violations) and can also receive explicit files or folders. Root legacy files such as `BUSINESS.md`, `CONTEXT.md`, `CONTENT_MAP.md`, or `GUIDELINES.md` are not compliant final locations in project repos.

When a skill runs from a project repository, ShipGlows-owned docs, tools, references, templates, and skill-local `references/*` still resolve from `${SHIPGLOWS_ROOT:-${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}}`. Only project artifacts and source files resolve from the current project root.

This decision-contract layer is wired into the active ShipGlows workflow: agent routing (`AGENT.md`), project orientation (`shipglows_data/technical/context.md`), documentation doctrine (`README.md`, this file, `shipglows_data/technical/metadata-migration-guide.md`), the `300-sg-docs` skill, and `tools/shipglows_metadata_lint.py`.

## Language Doctrine

ShipGlows uses a two-layer language model:

- Internal contract language: English. Use English for skill instructions, workflow rules, YAML/frontmatter keys, stable section headings, acceptance criteria, stop conditions, validation notes, and technical decision documentation.
- User-facing language: the user's active language. Use that language for questions, short progress updates, final reports, onboarding copy, and product-visible text. If the user writes in French, answer in natural French with proper accents.

The rule is not "one language everywhere"; it is "one language per layer." A skill can be internally documented in English while still asking:

```text
Veux-tu modifier l'existant ou ajouter un comportement séparé ?
```

Stable machine-readable anchors stay English even in localized artifacts: `Status`, `Scope In`, `Scope Out`, `Acceptance Criteria`, `Test Strategy`, `Skill Run History`, `Current Chantier Flow`, and command names such as `001-sg-build`.

Do not rewrite old mixed-language artifacts only for language cleanup. Apply the doctrine to new artifacts and to touched sections when the change is already in scope.

For existing projects with legacy docs, follow [`shipglows_data/technical/metadata-migration-guide.md`](./shipglows_data/technical/metadata-migration-guide.md) and prefer additive frontmatter migration before deeper document rewrites.

For legacy migration, the official default scope is active context docs and decision contracts when they exist at root (`CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `GUIDELINES.md`) plus root `specs/*.md`, but only as migration sources. The final location is the project-local `shipglows_data/` tree. Do not expand the migration endlessly to every old markdown file unless that file is part of the active ShipGlows documentation set.

## Agent Context Layer

ShipGlows now separates agent context into three levels:

ShipGlows documentation is not meant to be encyclopedic. It is meant to be complete for fast agent navigation:

- point of entry
- operational context
- function tree for large scripts
- routing toward business, product, GTM, architecture, and guidelines
- recognition by `300-sg-docs` and by the metadata linter

- `CLAUDE.md`: repo constraints, critical rules, and coding guidance
- `AGENT.md`: routing doc that tells a fresh agent where to look first
- `shipglows_data/technical/context.md`: compact operational map of the project

Specialized context docs can extend this layer when a repo contains a large procedural or architectural hotspot. `shipglows_data/technical/context-function-tree.md` is the reference example: it exists because a fresh agent cannot efficiently infer the structure of a large shell file like `lib.sh` from memory alone.

`shipglows_data/editorial/content-map.md` extends the context layer for content-heavy projects. It maps blog surfaces, docs, landing pages, FAQs, semantic clusters, pillar pages, and cross-surface update rules so content skills can route output without rediscovering the repository structure in every thread.

`shipglows_data/editorial/` extends that map with content governance: public content impact, claim register, page intent, editorial update gates, Astro content schema policy, and blog/article surface stop conditions.

This layer exists to reduce repeated discovery work in fresh threads. It is not a substitute for reading code. If a context doc and the code disagree, the code wins and the context doc should be updated.

## Decision Contract Layer

ShipGlows also separates decision contracts by role to avoid turning one document into a catch-all:

- `shipglows_data/business/business.md` defines audience, business model assumptions, value proposition, and market frame.
- `shipglows_data/business/product.md` defines product scope, workflows, outcomes, and non-goals.
- `shipglows_data/branding/branding.md` defines voice, trust posture, vocabulary, and claims boundaries.
- `shipglows_data/business/gtm.md` defines public promise, acquisition channels, proof points, objections, and funnel assumptions.
- `shipglows_data/editorial/content-map.md` defines content surfaces, semantic clusters, pillar pages, and repurposing destinations.
- `shipglows_data/editorial/` defines public-content governance, claims, page intent, and runtime content schema boundaries.
- `shipglows_data/technical/architecture.md` defines system organization, flows, boundaries, and structural invariants.
- `shipglows_data/technical/guidelines.md` defines engineering and documentation rules for contributors.

These contracts should reference each other through `depends_on` instead of being merged into one broad strategy file.

In practice, this clarifies the product surface:

- `shipglows_data/business/business.md` = for whom / what value / what model
- `shipglows_data/business/product.md` = what / workflows / non-goals
- `shipglows_data/branding/branding.md` = how we speak
- `shipglows_data/business/gtm.md` = how we present and distribute it
- `shipglows_data/editorial/content-map.md` = where content lives / how ideas move across surfaces
- `shipglows_data/editorial/` = content governance / claims / page intent / Astro content
- `shipglows_data/technical/architecture.md` = how it is organized
- `shipglows_data/technical/guidelines.md` = how we work inside it

Documentation role map:

- `README.md` -> public overview and repo onboarding
- `AGENT.md` -> fast agent routing
- `shipglows_data/technical/context.md` -> operational map of the system
- `shipglows_data/technical/context-function-tree.md` -> structural index for large procedural files
- `shipglows_data/editorial/content-map.md` -> editorial map for blog, docs, landing pages, semantic clusters, and repurposing destinations
- `shipglows_data/editorial/` -> content governance for public content, claims, page intent, editorial update gates, and Astro runtime-content schema boundaries
- `CLAUDE.md` -> critical repository constraints and rules
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md` -> ShipGlows work doctrine
- `shipglows_data/technical/metadata-migration-guide.md` -> frontmatter migration procedure
- `shipglows_data/business/business.md` -> business/product contract: for whom, what problem, what value, what model
- `shipglows_data/branding/branding.md` -> brand contract: tone, posture, vocabulary, claims
- `shipglows_data/business/gtm.md` -> public promise and sales contract: offer, funnel, objections, proof, channels, KPIs
- `shipglows_data/editorial/content-map.md` -> content architecture contract: surfaces, page roles, semantic clusters, pillar pages, and update rules
- `docs/editorial/` -> editorial governance contract: public surfaces, claim register, page intent, content gates, and runtime schema policy
- `shipglows_data/technical/guidelines.md` -> technical constraints and conventions
- `shipglows_data/business/product.md` -> operational product contract
- `shipglows_data/technical/architecture.md` -> system view and structuring invariants
- `shipglows_data/workflow/specs/` -> local execution of a change

Each document has an explicit and exclusive role to avoid duplication, stale context, and conflicting contracts.

Minimum metadata:

```yaml
---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "2026-04-25"
updated: "2026-04-25"
status: draft
source_skill: 100-sg-spec
scope: feature
owner: "[user/team]"
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_step: "/101-sg-ready [title]"
---
```

Artifact-specific metadata can extend this:

- specs add `user_story`
- business docs add `target_audience`, `value_proposition`, `business_model`, `market`
- audits add `domains`, `issue_counts`, `confidence`
- reviews add `period`, `verified_outcomes`, `assumptions`
- research reports add `source_count`, `primary_sources`, `recommendation`

Two versions serve different purposes:

- `metadata_schema_version` tracks the ShipGlows metadata contract. Increment it only when the metadata shape or required fields change.
- `artifact_version` tracks the document's decision content. Increment it when the contract changes meaningfully.

Recommended `artifact_version` convention:

- `0.x.y` for drafts or inferred/migrated artifacts
- `1.0.0` for the first reviewed/active version
- patch bump for clarifications that do not change decisions
- minor bump for changed assumptions, audience, scope, API behavior, pricing, or docs impact
- major bump for a new product promise, business model, security posture, architecture direction, or incompatible decision contract

Concrete examples:

- `1.0.0 -> 1.0.1`: typo fixes, clearer wording, added source link, same decision.
- `1.0.0 -> 1.1.0`: target audience refined, pricing assumption changed, API example updated, onboarding promise clarified, new docs impact.
- `1.1.0 -> 2.0.0`: business model changes from content to SaaS, ICP changes from consumers to B2B teams, security posture changes from local-only to multi-tenant public app, architecture direction changes incompatibly.

Status and version work together:

- `status: draft` can use `0.x.y`.
- `status: reviewed` or `active` should use `>= 1.0.0`.
- `status: stale` means the artifact may still be historically useful but should not be used as an unreviewed dependency for new implementation.
- `status: superseded` should set `superseded_by`.

Specs should record the artifact versions they depend on:

```yaml
depends_on:
  - artifact: shipglows_data/business/business.md
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: shipglows_data/branding/branding.md
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: docs/API.md
    artifact_version: "0.4.0"
    required_status: draft
```

If a dependent artifact becomes stale, the spec is not automatically invalid, but it must be re-evaluated before implementation or closure.

The metadata must not pretend certainty. If an artifact is inferred from old files or weak context, use `confidence: low`, `status: draft`, `risk_level: medium|high`, or explicit `unknown` values.

## Business Docs as Decision Contracts

ShipGlows treats business documentation as technical documentation because agents use it to make technical choices.

`shipglows_data/business/business.md`, `shipglows_data/branding/branding.md`, `shipglows_data/technical/guidelines.md`, personas, market studies, pricing notes, positioning docs, and GTM docs influence:

- what user story a feature should serve
- what copy and UX should promise
- what risks should block shipping
- what price and trust level the product must justify
- what docs, onboarding, and support surfaces must stay coherent
- what audits should consider acceptable or misleading

This means business docs need the same discipline as technical specs:

- metadata frontmatter
- explicit status and confidence
- evidence and assumptions
- review dates
- linked artifacts
- risk level
- owner
- next step

Business documentation should never be treated as generic context if it drives implementation or audit decisions.

Example:

```yaml
---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "[project name]"
created: "2026-04-25"
updated: "2026-04-25"
status: reviewed
source_skill: 300-sg-docs
scope: business
owner: "[user/team]"
confidence: medium
risk_level: medium
business_model: saas
target_audience: "solo founders shipping paid public products"
value_proposition: "Ship safer product iterations through spec-driven AI workflows"
market: "FR/EN indie SaaS and agentic development"
security_impact: yes
docs_impact: yes
evidence:
  - "user interview notes"
  - "current product positioning"
linked_artifacts:
  - "shipglows_data/branding/branding.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
depends_on: []
supersedes: []
next_review: "2026-05-25"
next_step: "/300-sg-docs audit"
---
```

## Documentation Coherence

Feature work is not complete if the user-facing behavior changed but the documentation still describes the old behavior.

When a feature changes, skills should consider these surfaces:

- README
- docs
- API docs
- component docs
- examples
- FAQ
- onboarding
- pricing
- changelog
- support copy
- screenshots
- public marketing pages

Documentation drift is a product risk when it affects:

- setup
- auth
- permissions
- payments
- security
- privacy
- API usage
- migrations
- destructive actions
- support expectations

This is why specs include `docs_impact`, why `102-sg-start` checks documentation coherence during implementation, and why `103-sg-verify` can flag stale docs as a blocking issue.

## Adoption and Migration

Older ShipGlows artifacts may not have the standard frontmatter. During adoption, `300-sg-docs audit` and `300-sg-docs update` should migrate them.

Migration rules:

- preserve the body
- add the ShipGlows metadata frontmatter
- infer only what is obvious from file name, title, date, and content
- use `unknown` for unproven fields
- use `confidence: low` when metadata is reconstructed
- do not convert application runtime content to the ShipGlows schema
- do not overwrite app-specific frontmatter needed by a framework

This lets existing work become traceable without pretending it was originally produced under the new standard.

## Professional Bug Management

ShipGlows uses a bug-file-first record model so tests, triage, and evidence stay readable across sessions:

- `shipglows_data/workflow/TEST_LOG.md` is the compact campaign log.
- `shipglows_data/workflow/test-checklists/<scope>.md` is the operator-fillable manual checklist when a spec needs durable manual, provider, environment, or device proof.
- `shipglows_data/workflow/bugs/BUG-ID.md` is the detailed Markdown source of truth for one bug work item.
- `shipglows_data/workflow/BUGS.md`, when present, is only a compact optional/generated triage index that points to bug files.
- `test-evidence/BUG-ID/` stores redacted supporting evidence when material is too large or too sensitive for inline markdown.

The standard bug loop is:

```text
003-sg-bug -> 107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship
```

Each stage has a narrow job:

- `003-sg-bug` reads bug state and continues the next safe lifecycle action through owner skills or bounded subagents without bypassing lifecycle gates.
- `107-sg-test` consumes a spec checklist when present, captures failures, opens or updates the bug file, and may refresh the optional compact index.
- `106-sg-fix` reads the bug file and appends diagnosis and fix attempts.
- `107-sg-test --retest BUG-ID` appends the retest history and updates the bug state.
- `103-sg-verify` checks whether the remaining bug state still blocks release.
- `005-sg-ship` consumes the final bug state when deciding whether the ship is clean, partial-risk, or blocked.

The direct-fix path does not bypass this memory layer. If `106-sg-fix` is the first skill to touch an actionable bug, it should create or reuse a `BUG-ID` and create `shipglows_data/workflow/bugs/BUG-ID.md` before ending the run. It may also update `shipglows_data/workflow/BUGS.md` when that optional index exists or is generated for triage. The only normal exceptions are narrow copy-only, cosmetic-only, or duplicate cases, and the final report should name the exception explicitly.

Canonical bug states stay explicit:

- `open`
- `needs-info`
- `needs-repro`
- `in-diagnosis`
- `fix-attempted`
- `fixed-pending-verify`
- `closed`
- `closed-without-retest`
- `duplicate`
- `wontfix`

Closure rules are conservative:

- `closed` requires a passing retest.
- `closed-without-retest` requires a visible reason and residual risk note.
- `needs-info` and `needs-repro` mean the bug is still unresolved, not done.
- `duplicate` and `wontfix` must point to a concrete canonical bug or decision.

Evidence rules are strict:

- keep `shipglows_data/workflow/TEST_LOG.md` and optional `shipglows_data/workflow/BUGS.md` compact
- keep large logs, HAR, screenshots, dumps, and traces out of the index files
- redact secrets, cookies, tokens, private emails, request headers, and production PII before persisting evidence
- store larger redacted material under `test-evidence/BUG-ID/`
- never paste raw sensitive evidence inline when a path reference is enough

## Workflow by Stage

### 0. `106-sg-fix` (bug intake)

Use `106-sg-fix` when your intent is "fix a bug" rather than "start a session."

It performs a short triage and routes the bug:
- local and clear -> direct fix now
- ambiguous or non-trivial -> spec-first path

Typical routed outcomes:
- direct: `106-sg-fix -> 103-sg-verify -> 104-sg-end`
- spec-first: `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end`

When `107-sg-test` finds a failure first, the bug should already exist as a bug file under `shipglows_data/workflow/bugs/`. `106-sg-fix` should read that bug file instead of rebuilding context from chat history.

When `106-sg-fix` is the first skill to touch a bug, it should usually create that bug file itself instead of leaving the correction documented only in chat history or git diff. `shipglows_data/workflow/BUGS.md` can be updated as an optional triage view. Only narrow minor exceptions such as copy-only or purely cosmetic fixes may skip bug-file creation, and that exception should be stated explicitly in the final report.

When the bug is auth or browser-session related, run `109-sg-auth-debug` before coding from theory. It consumes the bug report or spec, reproduces with Playwright where possible, and isolates failures across Clerk, OAuth, Google login, YouTube OAuth, Convex auth propagation, cookies, callbacks, protected routes, and Flutter web auth bridges. Its output should route back into `106-sg-fix`, `102-sg-start`, or `103-sg-verify` with evidence rather than guesses.

When the issue needs browser evidence but is not auth-specific, use `108-sg-browser` for the reproduction or observation. It collects the narrow browser proof, preserves read-only defaults, and routes actionable bugs back to `106-sg-fix` or non-trivial follow-up to `100-sg-spec`.

### 1. `700-sg-explore`

Use `700-sg-explore` when the problem is still fuzzy:
- feature idea not fully shaped
- risky refactor
- bug with unclear root cause
- cross-cutting behavior change

Expected outcome:
- clearer problem framing
- surfaced constraints
- identified unknowns
- decision to either stop, keep exploring, or move to `100-sg-spec`
- optional durable `exploration_report` when exploration is substantial or when the user explicitly requests a trace

### 2. `100-sg-spec`

Use `100-sg-spec` to create the implementation contract for non-trivial work.

The spec is expected to be autonomous and structured. It must include:
- `Title`
- `Status`
- `Problem`
- `Solution`
- `Scope In`
- `Scope Out`
- `Constraints`
- `Dependencies`
- `Invariants`
- `Links & Consequences`
- `Edge Cases`
- `Implementation Tasks`
- `Acceptance Criteria`
- `Test Strategy`
- `Risks`
- `Execution Notes`
- `Open Questions`

Status lifecycle:
- `draft`
- `reviewed`
- `ready`
- `implemented`
- `closed`

Rules:
- no unresolved filler markers
- no blocking open questions
- every implementation task must name a file and an action
- every implementation task should also name its validation and dependency ordering
- linked systems, consumers, and downstream consequences must be explicit
- no hidden dependency on conversation history
- tasks must be ordered by dependency

`100-sg-spec` is the canonical entry point for initial framing. It should be the default for medium+ work.

### 3. `101-sg-ready`

Use `101-sg-ready` as the guardrail before first implementation on non-trivial work.

It verifies that the spec is actually executable:
- structure is complete
- ambiguity is low enough
- task ordering is coherent
- linked systems and side effects are explicit
- acceptance criteria are testable
- execution notes are sufficient for a fresh agent
- open questions are resolved

If the spec passes, `101-sg-ready` promotes it to `Status: ready`.

`101-sg-ready` is also the right place to decide whether execution should continue on fresh context:
- if the environment can spawn a clean fresh subagent, it may do so
- otherwise it should explicitly ask the user to open a new thread before `/102-sg-start`

If not, it returns a concrete `not ready` verdict and pushes the work back toward spec refinement.

### 4. `102-sg-start`

`102-sg-start` is the execution kickoff, not a discovery phase.

Behavior:
- accepts direct execution for small, explicit, local fixes
- requires a `ready` spec for non-trivial work
- blocks if the spec is missing, incomplete, or contradictory
- derives an execution contract (target files, invariants, linked systems, validations, stop conditions) before coding
- reads the shared `704-sg-model` routing reference before coding
- chooses a primary execution model and reasoning effort before implementation
- may assign per-group model overrides when the execution is materially non-trivial
- chooses execution topology before launching work, using `skills/references/master-delegation-semantics.md` for master/orchestrator delegation when applicable
- loads only the execution-relevant files and the linked systems that must be revalidated
- prefers fresh context for spec-first execution when that reduces residual ambiguity
- routes non-auth browser proof to `108-sg-browser` and auth/session/protected-flow proof to `109-sg-auth-debug`

The key rule:
- if the work is ambiguous or multi-file, `102-sg-start` should not invent the missing intent

Topology rule:
- use delegated sequential by default for master/orchestrator file work when subagents are available
- use master/single-agent degradation only when allowed by `skills/references/master-delegation-semantics.md`
- use parallel subagents only with ready `Execution Batches`

### 5. Implementation (inside `102-sg-start`)

Once `102-sg-start` begins execution, the implementation should follow the spec contract:
- same scope
- same ordering assumptions
- same acceptance criteria
- same constraints and invariants
- same linked systems and consequence checks

If the implementation reveals a small missing delta, the loop does not automatically restart from scratch.
If it reveals a new side effect outside the contract, that is a reroute signal, not an invitation to improvise.

### 6. `103-sg-verify`

`103-sg-verify` is now both a verifier and a controlled remediation orchestrator.

It verifies in this order:
1. spec compliance
2. traceability from spec to code/tests
3. linked systems and downstream consequences
4. code quality, dependencies, and risks
5. workflow next step

It classifies the primary cause into one of these buckets:
- `specified but not implemented`
- `spec incomplete or ambiguous`
- `implemented but not specified`
- `technical failure only`
- `missing contract`
- `complete and ready`

Then it decides what to do.

#### When `103-sg-verify` remediates directly

If the spec is sound and the gap is only implementation:
- it can complete the missing work
- rerun the relevant checks
- mark traceability entries as `fixed during verify`

If the delta becomes too large, it should stop and route back to `102-sg-start`.

#### When `103-sg-verify` updates the spec

If the implementation exposed a small framing hole:
- it can apply a bounded mini-spec correction
- translate the answers into a mini spec delta
- update the existing spec first
- then resume implementation and re-verify

This is not a replacement for `100-sg-spec`.
It is a local repair path for late-discovered, bounded ambiguity.
It should not become the normal way work gets clarified.

#### When `103-sg-verify` reroutes

Typical routing outcomes:
- `specified but not implemented` -> remediate now, or `/102-sg-start` if the delta is too large
- `spec incomplete or ambiguous` -> mini-spec correction, then continue; if global drift, return to `/100-sg-spec`
- `implemented but not specified` -> clarify whether to keep or remove the extra behavior, then update spec or code
- `technical failure only` -> fix technical breakage and rerun verify
- `complete and ready` -> `/104-sg-end`

Every `103-sg-verify` report should end with:
- `Primary cause`
- `Action taken`
- `Next step`
- `Reason`

### 7. `104-sg-end`

`104-sg-end` closes the task against the spec and the delivered behavior.

It should:
- mark completed tasks as done
- keep partial work explicit
- record drift from the spec when it happened
- move the spec to `implemented` or `closed`
- prepare the next priorities cleanly

## Decision Rules

Use this rule of thumb:

- bug lifecycle orchestration -> `003-sg-bug`
- recurring project maintenance -> `002-sg-maintain`
- content management -> `007-sg-content`
- general design request, UI/UX work, redesign, token migration, or visual proof -> `006-sg-design`
- design system from scattered UI values when the operator already knows that exact target -> `006-sg-design system`
- bug repair intake -> `106-sg-fix`
- unclear problem -> `700-sg-explore`
- non-trivial scoped work -> `100-sg-spec`
- spec candidate before first implementation -> `101-sg-ready`
- ready execution kickoff -> `102-sg-start`
- verify and possibly close the loop -> `103-sg-verify`
- wrap up delivered work -> `104-sg-end`

## Prompted Decisions

Several skills now prompt explicit choices when the next action is ambiguous:

- `106-sg-fix`: direct fix vs spec-first vs diagnostic only
- `102-sg-start`: execute direct vs spec-first vs clarify first (`700-sg-explore`)
- `100-sg-spec`: light spec vs full spec vs auto-by-risk
- `301-sg-context`: proceed now vs add one key file vs refine target
- `103-sg-verify`: fix now vs return to spec vs stop and resume later
- `104-sg-end`: full close vs partial close vs summary only
- `308-sg-status`: issues-only vs dirty-only vs all-project view

This keeps momentum while avoiding silent assumptions in decision-heavy moments.

`704-sg-model` is optional but useful when you want to choose manually before execution.
`102-sg-start` should still reuse the same routing matrix internally, so manual and automatic choices stay aligned.

## One-Pass Agent Handoff

When a skill launches agents, the prompt should already contain:
- the exact scope and absolute date
- the relevant context files already surfaced by the parent skill
- the linked systems / consumers / downstream consequences to think about
- a no-follow-up rule: missing context becomes an explicit assumption, not a clarification round
- a structured output that includes confidence and missing context

The success criterion is strict:
- a fresh agent should be able to execute or audit from the prompt alone
- if that is not true, the parent skill is still underspecified
- if a fresh context is needed for the next step and the environment cannot create it directly, the skill should explicitly ask the user to open a new thread

In practice, this matters most for:
- `101-sg-ready` -> deciding whether the next step should restart cleanly
- `102-sg-start` -> executing non-trivial work from a clean contract instead of accumulated chat state

Shortcut rules:

- if the issue is already specified and simply unfinished, do not rewrite the whole spec
- if the issue reveals real contract ambiguity, update the spec before more code
- if the missing delta is local and obvious, `103-sg-verify` may absorb it
- if the missing delta changes architecture or scope, go back to `100-sg-spec`

## Example Flows

### Small local bug fix

```text
106-sg-fix -> 103-sg-verify -> 104-sg-end
```

### New feature with ambiguity

```text
700-sg-explore -> exploration_report -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end
```

### Feature mostly implemented but incomplete

```text
100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify
                                           |
                                           v
                          remediate missing specified work
                                           |
                                           v
                                        104-sg-end
```

### Feature reveals missing edge case late

```text
100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify
                                           |
                                           v
                         exceptional mini-spec delta + remediation
                                           |
                                           v
                                        104-sg-end
```

## What Changed from Earlier Flow

Earlier, the workflow tended to rediscover intent during `102-sg-start` or after failed implementation.

ShipGlows V3 changes that:
- `102-sg-start` is no longer the place where the problem gets clarified
- `100-sg-spec` is stricter and contract-oriented
- `101-sg-ready` is a real gate, not a nice-to-have
- `103-sg-verify` no longer stops at diagnosis; it can classify, clarify, remediate, and reroute
- the default target is one-pass execution from a complete contract, not prompt-and-correct after the fact
- the system now has an explicit path for incomplete implementation without automatically restarting the full cycle

## Practical Guidance

If a feature is reported as incomplete:
- use `102-sg-start` again only when the spec is still valid and the missing work is already specified
- use `100-sg-spec` again when the contract itself is insufficient
- let `103-sg-verify` absorb the delta when the missing work is local and safe to repair in-place

If you need several clarification rounds after implementation already started, assume the contract was too weak and route back upstream.

The important distinction is not "is the feature incomplete?"

The real distinction is:
- incomplete implementation
- incomplete contract
- implementation/spec drift

That distinction now drives the workflow.

## Questions

### Si je veux ameliorer ou elargir une feature existante, quelle skill utiliser ?

Use this decision rule:

- `700-sg-explore` if the change is still fuzzy (intent, scope, or expected behavior not clear)
- `102-sg-start` if the work is clear and already executable
- `106-sg-fix` if your entrypoint is "adjust/correct this existing feature" and you want automatic routing

Practical shortcut:

- if you hesitate between `700-sg-explore` and `102-sg-start`, begin with `106-sg-fix`
- `106-sg-fix` handles quick direct execution for local changes and routes to spec-first when the scope is non-trivial

### J'ai un bug: est-ce que je dois lancer `103-sg-verify` en premier ?

No. Start with `106-sg-fix`.

- `106-sg-fix` = intake + triage + direct execution when local/clear
- `103-sg-verify` = post-implementation validation and remediation loop

Recommended bug flow:

```text
106-sg-fix -> 103-sg-verify -> 104-sg-end
```

If the bug is non-trivial, `106-sg-fix` routes to:

```text
100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end
```

### Quand faire une revue adversariale de la spec ?

Apply this rule:

- if at least one signal is true, run an adversarial review

Signals:
- more than one file is impacted
- more than one domain is impacted (for example UI + API, backend + data)
- non-trivial business behavior
- security/data/auth/perf/migration/API contract impact
- likely edge cases
- vague wording in spec without testable criteria

Light review is acceptable only for local, obvious, single-file fixes.

### Faut-il renommer `TASKS` en `BACKLOG` ?

No. Keep both with distinct roles.

- `TASKS.md` = active, prioritized, executable now
- `BACKLOG.md` = deferred ideas and parking lot

Promotion rule:
- move an item from backlog to tasks only when it is clear enough and prioritized for execution now
