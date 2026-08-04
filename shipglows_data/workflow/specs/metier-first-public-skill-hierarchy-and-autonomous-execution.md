---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-04"
created_at: "2026-08-04 23:11:03 UTC"
updated: "2026-08-04"
updated_at: "2026-08-05 00:07:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "metier-first-public-skill-hierarchy-and-autonomous-execution"
owner: "unknown"
user_story: "As a ShipGlows operator, I want a small métier-first public skill surface that clarifies only material unknowns and then completes work end to end, so I can operate several products without memorizing internal skills or micromanaging lifecycle steps."
confidence: "high"
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "skills/000-shipglows/SKILL.md"
  - "skills/001-sg-build/SKILL.md"
  - "skills/002-sg-maintain/SKILL.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/004-sg-deploy/SKILL.md"
  - "skills/006-sg-design/SKILL.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/008-sg-customer/SKILL.md"
  - "skills/009-sg-marketing/SKILL.md"
  - "skills/010-sg-technical/SKILL.md"
  - "skills/011-sg-pilotage/SKILL.md"
  - "skills/300-sg-docs/SKILL.md"
  - "skills/302-sg-help/SKILL.md"
  - "skills/406-sg-seo/SKILL.md"
  - "skills/900-shipglows-core/SKILL.md"
  - "skills/references/question-contract.md"
  - "skills/references/operator-partnership-contract.md"
  - "skills/references/entrypoint-routing.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "README.md"
  - "site/"
depends_on:
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.9.0"
    required_status: "active"
  - artifact: "skills/references/operator-partnership-contract.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.6.0"
    required_status: "active"
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.6.0"
    required_status: "active"
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.5.0"
    required_status: "active"
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.10.1"
    required_status: "active"
supersedes: []
evidence:
  - "The operator explicitly wants fewer public skills, clear métier names, multi-product targeting, progressive clarification through playbooks, and autonomous execution from intent to verified completion."
  - "The current corpus exposes more than fifty skills even though many are lifecycle stages, proof owners, implementation engines, or narrow helpers rather than operator-facing métiers."
  - "The existing Question Contract and Operator Partnership Contract already prohibit asking the operator for discoverable context or implementation mechanics, but public métier ownership and automatic continuation are not yet expressed as one enforceable corpus contract."
  - "The agreed information architecture contains six navigation domains, thirteen public métier skills, and one ShipGlows router."
next_step: "/005-sg-ship shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md"
---

# Title

Métier-First Public Skill Hierarchy And Autonomous Execution

# Status

ready

# User Story

As a ShipGlows operator, I want a small métier-first public skill surface that clarifies only material unknowns and then completes work end to end, so I can operate several products without memorizing internal skills or micromanaging lifecycle steps.

# Minimal Behavior Contract

ShipGlows must expose one understandable métier-first surface: thirteen public skills grouped into six navigation domains, plus the `shipglows` router. A public métier skill owns the operator's outcome, not merely the next internal command. It resolves the target as `project -> product -> surface -> feature`, consults the relevant playbooks and repository evidence, asks one material operator decision at a time only while the request is unsafe or materially ambiguous, and stops asking as soon as a fresh capable agent could execute safely. It then carries the request through the necessary internal lifecycle from planning or specification to implementation, checks, proof, documentation coherence, and closure without returning internal orchestration to the operator. The easiest failure to miss is presenting fewer names while still forcing the operator to invoke internal skills step by step.

# Success Behavior

- An operator can choose a skill from a stable métier vocabulary without knowing internal lifecycle or proof-owner skills.
- A sparse but discoverable request starts work without a questionnaire.
- A materially ambiguous request receives the minimum progressive clarification, one numbered decision at a time with a recommendation.
- A multi-product project is never collapsed into a project-equals-product assumption.
- Once intent is executable, the public owner continues automatically through all applicable stages in the authorized scope.
- Cross-métier handoffs, specialist engines, tests, and proof collection remain internal implementation details.
- `sg-help mode` shows both the simple public catalog and, only on demand, the expert/internal engine catalog.
- Public and internal documentation use distinct owners: `sg-content` for public-facing material and `sg-docs` for internal project and agent documentation.

# Error Behavior

- If the target product or surface cannot be resolved and choosing incorrectly would materially change the outcome, ask one target decision and continue immediately after the answer.
- If required business truth, policy, budget, security posture, secret, destructive approval, or external authority is missing, pause only for that operator-owned input.
- If implementation mechanics are uncertain but safely decidable from evidence and conventions, the agent chooses and records the decision; it does not ask the operator.
- If work reveals a material scope expansion, explain the new boundary and ask one decision instead of silently broadening authority.
- If an internal engine fails, the public owner attempts safe diagnosis and recovery before reporting a real block.
- Must never happen: asking the operator which internal skill to run, returning a chain of slash commands as the next steps, claiming completion without proof, or treating project and product as synonyms.

# Problem

ShipGlows has strong specialist and lifecycle capabilities, but the operator-facing corpus mirrors too much of the implementation graph. The operator must remember numbered skills, distinguish orchestration from execution, select proof owners, and repeatedly request the next lifecycle step. This creates cognitive load and turns the operator into a workflow scheduler.

The current organization also makes some métier boundaries harder to understand. Internal and public documentation can blur. SEO can disappear inside marketing or content. Technical engineering and data-oriented product infrastructure can look like unrelated domains. A project containing several products exposes a deeper routing problem when a skill assumes that selecting a repository uniquely selects the product and surface.

The desired system is not merely a renamed catalog. It is a change in ownership: the public métier skill should interpret intent, obtain only unavailable material decisions, and remain responsible until the observable outcome is proven or a genuine operator-owned block exists.

# Solution

Introduce a two-layer skill corpus.

1. The public layer contains thirteen métier skills grouped under six navigation domains, plus `shipglows` as the universal router.
2. The internal layer retains lifecycle stages, proof owners, narrow specialists, and existing engines. These remain callable for expert/debug use but disappear from the default mental model and picker.
3. Every public métier loads a shared Intent-to-Outcome playbook that binds progressive clarification to automatic A-to-Z continuation.
4. Each public métier loads its own domain playbook for discovery, decisions, execution lanes, proof, and completion criteria.
5. The router and help surface use the same canonical registry so names, modes, descriptions, aliases, docs, and packaging cannot drift independently.

## Public Information Architecture

| Navigation domain | Public skill | Public mission | Initial engine owner |
| --- | --- | --- | --- |
| Create | `sg-development` | Build or materially change product behavior from intent to verified implementation | evolve `001-sg-build` |
| Create | `sg-design` | Design systems, interfaces, accessibility, visual audits, inspiration, and animation | retain `006-sg-design` |
| Create | `sg-experience` | Customer journeys, activation, trust, support, and recovery | evolve `008-sg-customer` |
| Quality | `sg-bug` | Reproduce, fix, retest, prove, and close one defect outcome | retain `003-sg-bug` |
| Quality | `sg-engineering` | Architecture, code quality, dependencies, performance, platform/data infrastructure, access, sync, and parity | evolve `010-sg-technical`; consume `600-602` internally |
| Quality | `sg-maintenance` | Plan and complete existing-product upkeep across the appropriate owner lanes | evolve `002-sg-maintain` |
| Publish | `sg-release` | Move a bounded release from readiness through deployment truth and post-release proof | evolve `004-sg-deploy` |
| Grow audience | `sg-content` | Create and maintain public docs and content across guides, README, FAQ, landing pages, blog, tutorials, and email | retain `007-sg-content` façade; consume `200-205` internally |
| Grow audience | `sg-marketing` | Market understanding, positioning, GTM, messaging, and persuasion | retain `009-sg-marketing` |
| Grow audience | `sg-seo` | Audit, launch, monitor, and fix organic-search performance | retain `406-sg-seo` |
| Govern | `sg-docs` | Maintain internal architecture, governance, code, context, metadata, and agent documentation | retain `300-sg-docs` |
| Organize | `sg-planning` | Tasks, backlog, priorities, reviews, and session/portfolio steering | evolve `011-sg-pilotage` |
| Organize | `sg-help` | Explain and route ShipGlows skills, modes, workflows, and prompts | retain `302-sg-help` |
| Universal | `shipglows` | Infer the target métier and preserve the objective through routing | retain `000-shipglows` |

The names above are canonical public labels. Existing numbered names may remain runtime-compatible during migration, but they must be labeled internal, legacy, or engine aliases rather than competing public concepts.

## Target Context Contract

All public owners resolve work using this hierarchy:

`project -> product -> surface -> feature`

- `project`: repository, business umbrella, or delivery workspace.
- `product`: independently promised product, app, service, plugin, site, or offering inside that project.
- `surface`: web, mobile, API, CLI, email, public docs, internal docs, admin, billing, or another user/agent touchpoint.
- `feature`: the bounded behavior or outcome being changed.

The agent must inspect local context and recent conversation before asking. It may omit lower levels when they are irrelevant, but it must never infer that one project contains exactly one product. Persist resolved context across internal handoffs.

## Intent-to-Outcome Playbook Contract

Create one shared reference, tentatively `skills/references/intent-to-outcome-autonomy.md`, loaded by every public métier and the `shipglows` router. It must operationalize the existing Question Contract and Operator Partnership Contract without duplicating them.

### Phase 1: Resolve

1. Restate the observable outcome internally.
2. Resolve `project -> product -> surface -> feature` from conversation, repo context, registries, specs, trackers, and current state.
3. Load the owning métier playbook and only the relevant specialist references.
4. Classify known facts, discoverable facts, safe agent decisions, and operator-owned decisions.

### Phase 2: Clarify progressively

Ask only when an unanswered operator-owned decision would materially alter product behavior, scope, security, cost, external effects, or acceptance.

- Ask one numbered decision at a time.
- Explain why it matters and give a recommended answer when possible.
- Prefer constrained choices only when they reflect real alternatives.
- Never ask for implementation mechanics, file locations discoverable in the repo, test commands, internal skill routing, or permission already granted by the task.
- Re-evaluate after each answer; do not front-load a full questionnaire.
- End clarification when a fresh capable agent could safely implement and prove the requested outcome.

### Phase 3: Contract

- For broad, risky, cross-surface, or behavior-changing work, create or refresh a durable spec and run readiness internally.
- For narrow and already-clear work, record a compact execution contract in the active plan or work item.
- Resolve open questions before material implementation unless an explicit evidence-gathering spike owns them.

### Phase 4: Execute A to Z

The public owner retains outcome ownership while delegating internally through the applicable lifecycle:

`discover -> specify/plan -> ready -> implement -> check -> test/prove -> verify -> update affected docs/content -> close -> ship/deploy when authorized`

- Select and invoke internal engines without asking the operator to do so.
- Continue automatically after each successful stage.
- Repair in-scope failures and rerun relevant proof.
- Preserve the active objective and target context through every handoff.
- Treat commit, push, deploy, external communication, paid action, and destructive mutation according to the authority actually granted; autonomy does not expand scope.

### Phase 5: Return

Return to the operator only when:

- the outcome is complete with proportional proof;
- one genuine operator-owned decision is required;
- new authority, a secret, a paid/destructive/external action, or manual-only proof is required; or
- a real block remains after safe in-scope alternatives have been exhausted.

The final report leads with the outcome, proof, residual risk, and any remaining operator action. It does not expose internal command choreography as work the operator must schedule.

## Public Mode Contract

Each public skill may expose a small set of intent-level modes. Modes describe the kind of outcome, not lifecycle stages or internal tools. The exact mode registry is finalized during implementation, subject to these rules:

- default mode infers intent when unambiguous;
- mode names use métier language recognizable without ShipGlows expertise;
- lifecycle concepts such as `spec`, `ready`, `start`, `verify`, and `end` remain internal engines, not public modes;
- a mode may route to multiple engines while one public owner retains accountability;
- `sg-help mode` renders one line per public skill with its modes, grouped by the six domains;
- `sg-help mode --expert` or equivalent may reveal internal engines and legacy aliases without mixing them into the default catalog.

## Boundary Decisions

- `sg-docs` owns internal docs: architecture, governance, code-adjacent documentation, agent context, metadata, and internal operating knowledge.
- `sg-content` owns public docs/content: public README, help center, tutorials, guides, FAQ, landing pages, blog, editorial repurposing, and audience email.
- `sg-seo` remains a distinct public métier and collaborates with content and marketing without being absorbed by either.
- There is no public `sg-data`. Database, local-cloud sync, entitlements/access, provider events, and platform parity are engineering modes backed initially by internal skills `600-602`.
- One cross-métier request has one public outcome owner. Other métiers participate as internal collaborators; the operator is not asked to coordinate them.

# Scope In

- Define and implement the thirteen-skill public métier surface plus the universal router.
- Add the shared Intent-to-Outcome playbook and load it from every public owner.
- Add or align métier playbooks that specify progressive clarification, execution lanes, proof, and completion.
- Establish canonical public names, modes, descriptions, aliases, and six-domain grouping in one registry/source of truth.
- Support multi-product target resolution through `project -> product -> surface -> feature`.
- Keep existing lifecycle, specialist, and proof skills available as internal engines.
- Update `sg-help mode`, root/public documentation, site skill catalog, generated/plugin manifests, and runtime synchronization surfaces.
- Add automated pressure tests for clarification restraint, autonomous continuation, routing boundaries, multi-product context, and catalog consistency.
- Hide or retire duplicate public aliases such as the unnumbered `emailing` surface when a canonical public owner already exists.

# Scope Out

- Deleting proven internal engines solely to reduce directory count.
- Rewriting every specialist playbook when a loader or ownership mapping is sufficient.
- Changing application products, customer features, or deployment providers unrelated to the skill corpus.
- Granting autonomous authority for destructive, paid, privileged, or external actions that the operator did not authorize.
- Replacing specs with conversation-only plans for material work.
- Making internal engines undiscoverable to expert users or maintainers.

# Constraints

- Public simplicity must not reduce specialist capability, safety gates, or proof standards.
- Reference-first layering applies: shared autonomy doctrine belongs in one reference, métier behavior in local playbooks, and `SKILL.md` files remain compact activation/routing contracts.
- Existing public names that already match the target may remain; renamed skills require compatibility aliases and a documented migration period.
- Default help and picker surfaces show only canonical public skills; internal engines remain available through expert help and direct invocation.
- The same canonical registry must drive help, docs, site catalog, packaging, and validation where technically feasible.
- French operator-facing text must be natural and accented; machine contracts and stable anchors remain English.
- Security-sensitive work must preserve authorization, secret-handling, environment, and destructive-action gates.
- Existing unrelated worktree changes remain outside implementation scope.
- Fresh external docs verdict: `fresh-docs not needed`; this is a local ShipGlows information-architecture and workflow-contract change.
- Runtime diagnostics exception: this chantier changes agent contracts, registries, tests, packaging, and documentation rather than a long-running product runtime; deterministic contract tests, invocation fixtures, sync checks, and captured end-to-end agent scenarios replace Sentry/log instrumentation.

# Test Contract

- Surface: public skill routing, progressive clarification, internal orchestration, help/catalog, documentation boundaries, packaging, and runtime synchronization.
- proof_profile: mixed
- checklist_path: `shipglows_data/workflow/test-checklists/metier-first-public-skill-hierarchy-and-autonomous-execution.md`
- proof_order:
  1. freeze canonical registry and ownership map
  2. add shared autonomy contract and métier loaders/playbooks
  3. migrate router/help/catalog/public docs
  4. run static and runtime validation
  5. run scripted pressure scenarios
  6. manually review métier language and operator experience
- required_scenario_ids:
  - `MH-01-sparse-discoverable-request`
  - `MH-02-multi-product-ambiguity`
  - `MH-03-business-decision-missing`
  - `MH-04-implementation-mechanics-missing`
  - `MH-05-autonomous-lifecycle-continuation`
  - `MH-06-cross-metier-single-owner`
  - `MH-07-public-vs-internal-docs`
  - `MH-08-engineering-data-infrastructure`
  - `MH-09-material-scope-expansion`
  - `MH-10-help-simple-vs-expert`
  - `MH-11-no-capability-orphan`
  - `MH-12-no-public-ownership-duplicate`
- required_results:
  - A discoverable sparse request proceeds without asking a question.
  - An unresolved multi-product target prompts only for the product/surface decision that materially matters, then resumes automatically.
  - A missing business decision produces one numbered question with a recommendation.
  - Missing implementation mechanics never produce an operator question when repository evidence permits a safe choice.
  - A ready request continues through implementation and proof without asking the operator to invoke another skill.
  - Cross-métier work exposes one owner and keeps internal handoffs invisible.
  - Public documentation routes to `sg-content`; internal documentation routes to `sg-docs`.
  - Sync, entitlement/access, event, and parity work routes to `sg-engineering` and the appropriate internal engine.
  - A material scope expansion pauses for one decision rather than silently expanding.
  - Default help shows exactly thirteen public métier skills plus `shipglows`; expert help can show internal engines.
  - Every current capability maps to exactly one public owner or an explicitly internal engine.
  - Metadata lint, skill budget audit, runtime sync, broken-reference checks, and packaging audit pass.
- exception_with_proof: an existing engine may retain its legacy public alias temporarily if removal would break current consumers, but the alias must be labeled legacy, hidden from default discovery, tested, and assigned a removal decision.
- exception_without_proof: none.

# Dependencies

- `skills/references/question-contract.md`: progressive, evidence-first questioning rules.
- `skills/references/operator-partnership-contract.md`: operator-owned versus agent-owned decisions.
- `skills/references/entrypoint-routing.md`: entrypoint and dispatch doctrine.
- `skills/references/master-workflow-lifecycle.md`: internal lifecycle continuation model.
- `skills/references/master-delegation-semantics.md`: owner and delegation semantics.
- `skills/references/reporting-contract.md`: user-facing completion and blocker reports.
- Existing public/master skills listed in the Public Information Architecture.
- Existing internal engines, especially `100-109`, `200-205`, `301-308`, `400-407`, and `600-602`.
- Runtime registries, help generators, plugin manifests, README, and public site catalog discovered during implementation.

# Invariants

- The operator chooses outcomes and material product decisions; agents choose implementation mechanics.
- A public métier remains accountable across internal handoffs.
- Progressive clarification is not a mandatory questionnaire.
- Clarification ends when execution is safe, not when every optional preference is known.
- Autonomy means continuation within authority, never silent scope or permission expansion.
- Project, product, surface, and feature remain distinct target dimensions.
- Public docs and internal docs have different canonical owners.
- SEO remains an explicit métier.
- Data infrastructure is an engineering responsibility, not a separate public corpus branch.
- Internal engines stay testable and directly callable even when absent from default discovery.
- No current capability becomes orphaned and no capability gains two competing public owners.

# Links & Consequences

- Changing names and discovery affects runtime installation, plugin packaging, prompts, docs, the site, aliases, examples, and user muscle memory.
- Making public owners autonomous increases the importance of authority checks, stop conditions, proof discipline, and objective persistence.
- Multi-product context should become reusable infrastructure for specs, tasks, audits, releases, and reports rather than skill-local prose.
- A canonical registry enables future generated help/catalog surfaces and prevents documentation drift.
- Existing numbered skills become a stable implementation API; public métier names become the human interface.

# Documentation Coherence

- Update `README.md` and public site documentation to show the six domains and public catalog.
- Update internal skill/runtime documentation with the two-layer public-owner/internal-engine model.
- Update `AGENT.md` only if repository entrypoint routing materially changes.
- Update `sg-help mode` from the canonical registry and include the docs/content boundary and expert view.
- Route public migration notes through `sg-content`; route internal architecture and governance explanations through `sg-docs`.
- Add a compatibility table from old public/numbered names to canonical métier owners.
- Record renamed/hidden aliases in the changelog during closure.

# Edge Cases

- One repository contains a web app, mobile app, API, public site, and plugin with similarly named features.
- The user says “update the docs” without indicating whether the audience is users or maintainers.
- A request begins as design work but requires implementation and accessibility proof.
- A bug fix requires a migration, public release note, and production verification.
- SEO work changes public content but should keep SEO as the outcome owner.
- A public owner reaches a stage requiring a secret or production approval.
- A legacy alias is referenced by scripts, docs, or installed plugin manifests.
- A user explicitly asks for an internal engine; expert invocation must continue to work.
- The request is tiny and clear; the autonomy playbook must not force a heavyweight spec.
- The request is broad but sounds simple; readiness must still detect hidden product/security risk.
- An internal stage succeeds but later proof fails; the owner must repair/retest rather than hand orchestration back.

# Implementation Tasks

- [x] Task 1: Extend the canonical invocation registry with public-owner metadata.
  - Files: `skills/references/skill-invocation-registry.json`, `skills/000-shipglows/SKILL.md`, and registry validation/generation code discovered through the existing registry consumers.
  - Action: encode six domains, thirteen public skills, canonical names, modes, descriptions, legacy aliases, initial engines, and visibility level in the existing invocation authority; do not create a competing registry.
  - Depends on: none.
  - Validate with: schema validation plus checks for exactly thirteen unique public métier owners and one universal router.

- [x] Task 2: Add the shared Intent-to-Outcome autonomy reference.
  - Files: `skills/references/intent-to-outcome-autonomy.md`, relevant shared-reference indexes.
  - Action: implement Resolve, Clarify, Contract, Execute A-to-Z, and Return phases by extending—not duplicating—the Question and Operator Partnership contracts.
  - Depends on: Task 1.
  - Validate with: metadata lint, reference-link checks, and targeted contract assertions.

- [x] Task 3: Establish the thirteen public activation contracts and métier playbooks.
  - Files: target public `SKILL.md` files and their local `references/` playbooks.
  - Action: rename/evolve façades as required, load the shared autonomy reference, declare owner boundaries and modes, and route to internal engines.
  - Depends on: Tasks 1-2.
  - Validate with: skill budget audit, loader assertions, and manual métier-boundary review.

- [x] Task 4: Implement multi-product target context.
  - Files: `skills/references/entrypoint-routing.md`, `skills/references/master-workflow-lifecycle.md`, `skills/references/intent-to-outcome-autonomy.md`, plus existing work-item templates/schemas identified by references from those contracts.
  - Action: preserve `project -> product -> surface -> feature` through routing, specs, delegated work, proof, and reporting.
  - Depends on: Tasks 1-3.
  - Validate with: `MH-02` plus fixtures for one project containing multiple products and surfaces.

- [x] Task 5: Wire autonomous lifecycle continuation.
  - Files: public master contracts, lifecycle/delegation references, orchestration scripts or templates where applicable.
  - Action: ensure public owners invoke and continue through internal stages without returning slash-command choreography to the operator.
  - Depends on: Tasks 2-4.
  - Validate with: `MH-01`, `MH-03`, `MH-04`, `MH-05`, `MH-06`, and `MH-09`.

- [x] Task 6: Enforce métier boundaries and migrate legacy aliases.
  - Files: old façade skills, aliases, manifests, indexes, and compatibility docs.
  - Action: apply docs/content, SEO, engineering/data, release, experience, planning, and maintenance ownership rules; hide internal/legacy entries from default discovery without breaking expert use.
  - Depends on: Tasks 1-5.
  - Validate with: `MH-07`, `MH-08`, `MH-11`, `MH-12`, and legacy invocation tests.

- [x] Task 7: Rebuild help, public docs, site catalog, and packaging from the canonical registry.
  - Files: `skills/302-sg-help/SKILL.md`, help references/generators, `README.md`, `site/`, plugin/runtime manifests, and relevant internal docs.
  - Action: show the six-domain simple catalog by default and the internal engine catalog only in expert mode.
  - Depends on: Tasks 1-6.
  - Validate with: `MH-10`, catalog snapshots, link checks, packaging audit, and runtime sync.

- [x] Task 8: Add and run pressure tests and full corpus validation.
  - Files: `tools/test_metier_first_public_skills_contract.py`, `shipglows_data/workflow/test-checklists/metier-first-public-skill-hierarchy-and-autonomous-execution.md`, and existing related tests that require compatibility updates.
  - Action: automate scenarios `MH-01` through `MH-12`, run static checks, and manually review natural métier language.
  - Depends on: Tasks 1-7.
  - Validate with: metadata lint, skill budget audit, sync check, packaging audit, broken-reference scan, scenario suite, and manual review record.

- [x] Task 9: Verify, document, and close the migration.
  - Files: this spec, test/verification artifacts, internal architecture docs, public migration docs, trackers, and changelog.
  - Action: prove no orphan/duplicate ownership, document compatibility decisions and residual risks, then complete the normal verify/end/ship flow.
  - Depends on: Tasks 1-8.
  - Validate with: all acceptance criteria checked against evidence and no unresolved open questions.

# Acceptance Criteria

- [x] AC 1: Given default discovery, when the operator views ShipGlows skills, then exactly thirteen métier skills grouped into six domains plus `shipglows` are presented.
- [x] AC 2: Given a public métier request, when relevant context is discoverable, then the owner starts without asking the operator for discoverable facts or mechanics.
- [x] AC 3: Given one material ambiguity, when clarification is required, then the owner asks one numbered decision with context and recommendation, and resumes automatically after the answer.
- [x] AC 4: Given an executable request, when an internal lifecycle stage completes, then the public owner advances to the next applicable stage without an operator command.
- [x] AC 5: Given a project with several products, when work is routed, then product and surface are resolved independently from project and persist through proof/reporting.
- [x] AC 6: Given a public-doc request and an internal-doc request, when routed, then `sg-content` owns the former and `sg-docs` owns the latter.
- [x] AC 7: Given SEO work, when routed, then `sg-seo` remains the public owner while content/marketing participate internally when needed.
- [x] AC 8: Given sync, entitlements/access, provider-event, or parity work, when routed, then `sg-engineering` owns the outcome and uses `600-602` internally as applicable.
- [x] AC 9: Given a cross-métier outcome, when work proceeds, then one public owner remains accountable and the operator is not asked to coordinate handoffs.
- [x] AC 10: Given an unauthorized destructive, paid, privileged, external, or production action, when reached, then the owner pauses for the specific authority required.
- [x] AC 11: Given the current capability corpus, when the ownership audit runs, then every capability has exactly one public owner or explicit internal-engine status.
- [x] AC 12: Given default and expert help, when compared, then default help remains simple while expert help preserves direct internal discoverability and compatibility aliases.
- [x] AC 13: Given implementation completion, when repository validation runs, then metadata, budgets, references, registry generation, runtime sync, packaging, and pressure tests pass.

# Test Strategy

- Add deterministic registry tests for unique names, aliases, visibility, mode ownership, and exact public count.
- Add table-driven routing tests for all current capabilities and target-context dimensions.
- Add conversation pressure fixtures that assert whether a question is allowed, its shape, and whether execution continues afterward.
- Add boundary fixtures for internal/public docs, SEO collaboration, engineering infrastructure, and cross-métier ownership.
- Add compatibility tests for legacy/numbered direct invocation and default-discovery hiding.
- Run existing metadata, skill budget, runtime sync, and packaging checks.
- Manually review default help using only operator vocabulary: a new user should be able to select a métier without reading engine documentation.
- Manually inspect one end-to-end simulated flow from sparse prompt to completion report and one flow requiring a single operator decision.

# Risks

- High: broad routing changes can silently orphan capabilities or create competing owners.
- High: stronger autonomy can exceed intended authority if continuation and permission boundaries are not explicit and tested.
- High: name migration can break installed plugins, prompts, links, scripts, and operator habits.
- Medium: hiding internal engines may reduce debuggability unless expert discovery stays complete.
- Medium: a shared autonomy reference can become abstract doctrine unless pressure tests assert observable behavior.
- Medium: mode proliferation could recreate the current cognitive load inside fewer skill names.
- Medium: generated and handwritten catalogs may drift if a canonical registry is not truly adopted.

# Execution Notes

- Implement this as a staged compatibility migration, not a destructive mass rename.
- Start with the registry and shared contract; do not edit thirteen façades independently before the ownership source of truth exists.
- Reuse current engines wherever their behavior is sound. Public simplification is primarily ownership, activation, discovery, and continuation work.
- Use local métier playbooks to define what “clear enough” means for each domain; use the shared autonomy reference to define how clarification and continuation behave everywhere.
- Audit every current skill before hiding it, but do not automatically promote every helper into a public mode.
- Keep modes outcome-oriented and few. If a mode name requires knowledge of the lifecycle graph, it belongs in expert/internal help.
- Treat public documentation updates as part of the implementation, not a post-hoc optional follow-up.
- Do not ship until the pressure suite proves both sides of the contract: the system asks when a material operator decision is genuinely required and does not ask when the answer is safely discoverable or agent-owned.

# Open Questions

None. Exact mode labels may be refined during implementation within the fixed métier boundaries, provided the canonical registry, public count, and acceptance criteria remain unchanged.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-04 23:11:03 UTC | 100-sg-spec | GPT-5 Codex | Converted the agreed métier-first corpus, multi-product targeting, progressive clarification, and A-to-Z ownership into an implementation contract | drafted | readiness review |
| 2026-08-04 23:16:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed scope, dependencies, invariants, pressure scenarios, authority boundaries, migration risks, and implementation sequencing; added the explicit proof checklist, runtime-observability exception, and existing-registry ownership | ready | /102-sg-start shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md |
| 2026-08-04 23:58:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the public registry, shared autonomy contract, thirteen métier owners, help/runtime visibility, plugin and documentation migration, pressure tests, and public-site catalog | implemented | /103-sg-verify shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md |
| 2026-08-05 00:02:00 UTC | 103-sg-verify | GPT-5 Codex | Ran standard scenario-first verification across 12 MH scenarios, 81 focused regressions, runtime sync, metadata, index, budgets, skill audit, plugin validation, checklist status, and the 83-page public-site build | verified | /104-sg-end shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md |
| 2026-08-05 00:07:00 UTC | 104-sg-end | GPT-5 Codex | Closed local implementation bookkeeping, aligned the changelog and documentation reflection, and preserved Git shipping as a separate unauthorized step | closed | /005-sg-ship shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md |

## Current Chantier Flow

- 100-sg-spec: drafted
- 101-sg-ready: ready
- 102-sg-start: implemented
- 103-sg-verify: verified
- 104-sg-end: closed
- 005-sg-ship: pending
- Next step: `/005-sg-ship shipglows_data/workflow/specs/metier-first-public-skill-hierarchy-and-autonomous-execution.md`
