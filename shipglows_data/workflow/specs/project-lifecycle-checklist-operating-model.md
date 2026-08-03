---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlows"
created: "2026-07-27"
created_at: "2026-07-27 00:00:00 UTC"
updated: "2026-07-28"
updated_at: "2026-07-27 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "project-lifecycle-checklist-operating-model"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows, je veux suivre les checklists techniques de chaque projet par cycles et conserver leur progression et leur historique, afin de savoir exactement ou en est chaque projet sans transformer TASKS.md en checklist geante."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/workflow/TASKS.md"
  - "shipglows_data/workflow/specs/"
  - "shipglows_data/workflow/playbooks/"
  - "shipglows_data/workflow/checklists/"
  - "shipglows_data/workflow/test-checklists/"
  - "shipglows_data/editorial/ROADMAP.md"
  - "skills/references/task-registry-routing.md"
  - "skills/references/task-application-loop.md"
  - "skills/309-sg-tasks/SKILL.md"
  - "tui/"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-tdd-and-manual-checklist-artifacts.md"
    artifact_version: "1.0.0"
    required_status: ready
  - artifact: "shipglows_data/workflow/playbooks/README.md"
    artifact_version: "1.1.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/checklists/README.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Inspection du 2026-07-27: TASKS.md est le tracker local actif; les specs portent l'historique de chantier; PROJECTS.md est legacy/degraded-discovery; le TUI lit deja projets, specs, taches et audits."
  - "Inspection du 2026-07-27: les contrats distinguent deja playbooks reutilisables, checklists reutilisables et test-checklists executees."
  - "Demande operateur: suivre les domaines techniques par projet, avec des checklists maîtres ordonnées, des instances par cycle, une progression et un historique; la stratégie de contenu SEO et les mots-clés relèvent d'un autre projet."
next_step: "/102-sg-start project-lifecycle-checklist-operating-model"
---

# Spec: Project Lifecycle Checklist Operating Model

🟢 [ShipGlows] spec: Project Lifecycle Checklist Operating Model | status: ready | path: shipglows_data/workflow/specs/project-lifecycle-checklist-operating-model.md | next: /102-sg-start project-lifecycle-checklist-operating-model

## Title

Project Lifecycle Checklist Operating Model

## Status

ready — first contract reviewed after auditing the existing task, playbook, checklist, spec, and TUI layers.

## User Story

En tant qu'operatrice ShipGlows, je veux suivre les checklists techniques de chaque projet par cycles et conserver leur progression et leur historique, afin de savoir exactement ou en est chaque projet sans transformer TASKS.md en checklist geante.

## Minimal Behavior Contract

ShipGlows must let a governed project declare applicable lifecycle domains and instantiate reusable Markdown playbooks/checklists without replacing the existing local task tracker or chantier registry. A checklist item may be one-time, recurring, cyclic, or event-triggered; completed work must remain traceable, while open follow-ups route to the existing execution or editorial tracker. A reader must be able to derive current project state, domain progress, overdue or upcoming routines, today's actions, and next week's actions from the same versioned artifacts that skills consume. The easy-to-miss edge case is treating a recurring routine as permanently checked: each recurrence needs its own due state and evidence while the reusable definition remains stable.

## Success Behavior

- Preconditions: A project has a canonical `shipglows_data/` governance root and declares the surfaces/domains that apply to it.
- Trigger: Project bootstrap, lifecycle review, launch readiness, scheduled review, domain audit, or a user request for current project status.
- User/operator result: The operator can identify project phase, domain health, completed one-time gates, active recurring routines, current blockers, today's actions, and the next review window.
- System effect: Reusable playbooks/checklists remain versioned Markdown; concrete follow-ups are emitted through `TASKS.md` or `editorial/ROADMAP.md` according to existing routing; execution evidence remains in the appropriate project artifact.
- Success proof: A fixture project can be parsed into one-time, recurring, cyclic, and event-triggered items, with deterministic next-occurrence and tracker-routing results.
- Silent success: Not allowed. The report or dashboard must expose missing applicability, stale cadence, unresolved required items, and evidence gaps.

## Error Behavior

- Expected failures: missing governance root, unknown checklist identifier, invalid cadence, ambiguous project ownership, stale tracker anchor, duplicate item ID, missing evidence for a completed required item, or an editorial follow-up targeting an undeclared surface.
- User/operator response: Report the exact project/domain/item issue and the smallest repair route; do not infer readiness from incomplete data.
- System effect: Preserve existing tracker state, mark the item `blocked`, `needs_review`, or `not_run` as appropriate, and avoid creating duplicate tasks or recurrence instances.
- Must never happen: a recurring item is permanently closed after one completion; a checklist duplicates `TASKS.md`; a dashboard invents progress from unchecked Markdown; or an editorial finding is silently written into the technical tracker.
- Silent failure: Not allowed. Invalid lifecycle definitions and stale instances must remain visible.

## Problem

ShipGlows already has the foundations for task and proof tracking, but they are currently optimized for individual work items and chantier execution. Projects also need durable technical operating rhythms: technical SEO, cybersecurity, performance, launch gates, production and maintenance. These must be tracked as ordered checklist instances with cycle history; content SEO, keyword research and editorial production are intentionally handled by a separate project.

## Solution

Extend the existing Markdown operating model with a project lifecycle definition and a small, machine-readable checklist-instance contract. Reusable playbooks remain methods, reusable checklists remain control surfaces, executed test-checklists remain proof artifacts, `TASKS.md` remains the active execution tracker, `ROADMAP.md` remains the editorial tracker, and specs remain the chantier registry. The future ShipGlows app consumes the same contracts as a visual projection rather than becoming a second source of truth.

## Scope In

- Define a canonical lifecycle vocabulary for technical, cybersecurity, SEO technique, marketing, copywriting, performance, analytics, launch, production, and maintenance domains; leave keyword strategy, editorial SEO, and content production to a separate project.
- Define item types: `one_time`, `recurring`, `cyclic`, and `event_triggered`.
- Define lifecycle states separately from task states: applicability, not started, in progress, waiting for evidence, verified, overdue, blocked, skipped with reason, and retired.
- Define stable item IDs, cadence fields, due/next-review semantics, evidence pointers, owner role, dependencies, and tracker-routing fields.
- Pair reusable lifecycle playbooks in `workflow/playbooks/` with reusable controls in `workflow/checklists/`.
- Define how a project-local lifecycle instance links to `TASKS.md`, `editorial/ROADMAP.md`, specs, audit records, and executed proof checklists.
- Define deterministic “today”, “this week”, “next week”, overdue, and next-review projections for future CLI/TUI/app consumers.
- Create representative pilot definitions for site publishability, technical SEO, cybersecurity, performance, and ongoing technical maintenance; marketing and copywriting remain first-class lifecycle domains for their own masters.
- Add parser/contract fixtures before changing the ShipGlows app UI.

## Scope Out

- No new database or parallel global task registry.
- No replacement of `TASKS.md`, `ROADMAP.md`, `specs/`, or the existing TUI source readers.
- No full ShipGlows Flutter UI implementation in this first contract phase.
- No automatic claims that a project is launch-ready without required evidence and domain applicability.
- No vendor migration to ClickUp, Linear, Plane, or another external project manager.
- No retroactive reconstruction of every historical project routine before the pilot contract is validated.

## Constraints

- Markdown and Git remain usable without the ShipGlows app.
- Skills must be able to consume the same artifacts in a project repository or through a future app adapter.
- One-time completion and recurring completion must not share the same state semantics.
- A recurring instance must be appendable or otherwise historized without rewriting the reusable checklist definition.
- Technical and editorial follow-ups must preserve `task-registry-routing.md`.
- Existing project trackers are operational records and must remain free of mandatory artifact frontmatter.
- Progress must be explainable from evidence, not from checkbox count alone.

## Dependencies

- Runtime: Markdown/YAML parsing and the existing project/TUI readers; no new runtime dependency assumed.
- Document contracts: `canonical-paths.md`, `task-registry-routing.md`, `operational-record-format.md`, playbook/checklist README contracts, and `shipglows-tdd-and-manual-checklist-artifacts.md`.
- Metadata gaps: the reusable lifecycle-instance artifact type and recurrence representation do not yet have a finalized schema.
- Project/app context: the existing ShipGlows app shell must be inspected only after the contract and parser fixture are stable.

## Invariants

- `playbook` explains a method; `checklist` controls a reusable run; `test-checklist` records concrete proof.
- `TASKS.md` records active executable technical work, not the entire project lifecycle.
- `editorial/ROADMAP.md` records public/editorial follow-up, not technical implementation.
- `specs/` records spec-first chantier history, not recurring project health.
- Every derived status can point back to a definition, an instance, a tracker record, or evidence.
- A project with no declared applicability is `needs_review`, not `100% complete`.
- A routine can be completed for the current period while remaining active for its next period.
- App views and skill reports are projections of the canonical Markdown contracts.

## Links & Consequences

- Upstream systems: project governance bootstrap, project registry/discovery, reusable playbooks/checklists, domain audits, launch workflows, and maintenance workflows.
- Downstream systems: `309-sg-tasks`, content/editorial routing, TUI dashboard, future ShipGlows app, weekly review, and project status reporting.
- Cross-cutting checks: SEO applicability, cybersecurity posture, public-surface declarations, performance evidence, content claims, documentation freshness, accessibility where UI is involved, and Git diff hygiene.

## Documentation Coherence

- Update `workflow/playbooks/README.md` and `workflow/checklists/README.md` with the lifecycle-instance relationship.
- Add a concise lifecycle contract/reference under `skills/references/` after the schema is accepted.
- Update `spec-driven-workflow.md`, `309-sg-tasks`, and `308-sg-status` only where their current ownership boundaries need clarification.
- Add pilot links for SEO/site launch, cybersecurity, and marketing/copywriting/performance domains.
- Defer public app/UI documentation until the application consumes the stable contract.

## Edge Cases

- A one-time SEO launch gate is complete, but the weekly technical crawl is due again.
- A monthly copy review creates an editorial roadmap item while a performance issue creates a technical task from the same audit.
- A project is paused: recurring items stop generating due work but retain the reason and resume policy.
- A cadence changes: prior instances remain historical and only future occurrences use the new cadence.
- A checklist item becomes inapplicable after a product surface is retired.
- A task is done in `TASKS.md` but required evidence is missing; lifecycle status remains `waiting_for_evidence`.
- A project has no Search Console or analytics access; the missing source is recorded as a blocker or confidence limit, not as a pass.
- Multiple projects share one reusable checklist but have different owners, cadences, or public surfaces.

## Implementation Tasks

- [ ] Task 1: Define the lifecycle-instance schema and vocabulary.
  - File: `skills/references/project-lifecycle-checklist-contract.md`
  - Action: Specify IDs, domains, item types, states, cadence, evidence, ownership, applicability, tracker routing, and next-action derivation.
  - User story link: Makes project progress and recurrence machine-readable for skills and the app.
  - Depends on: None
  - Validate with: Contract examples covering all four item types and invalid-state cases.
  - Notes: Keep definitions separate from executed proof artifacts. **Implemented in `skills/references/project-lifecycle-checklist-contract.md`.**

- [ ] Task 2: Define one canonical lifecycle declaration format for governed projects.
  - File: `templates/project_lifecycle.md`
  - Action: Provide project phase, domain applicability, linked playbooks/checklists, review cadence, and current lifecycle summary fields.
  - User story link: Gives every project the same operating surface.
  - Depends on: Task 1
  - Validate with: Metadata lint and a fixture project parse.
  - Notes: Do not turn `TASKS.md` into this declaration. **Implemented in `templates/project_lifecycle.md`; ordered checklist progression now belongs to `templates/project_checklist_instance.md`.**

- [ ] Task 3: Add pilot playbook/checklist pairs for publishability and ongoing technical operations.
  - File: `shipglows_data/workflow/playbooks/`, `shipglows_data/workflow/checklists/`
  - Action: Reconcile existing SEO/site-launch artifacts and add the smallest missing technical SEO, cybersecurity, and performance lifecycle controls. Keep content SEO and keyword work outside this project.
  - User story link: Answers “what remains before publication?” and “what technical controls must keep running afterward?”.
  - Depends on: Tasks 1-2
  - Validate with: Each pilot has purpose, applicability, execution order, outputs, cadence, evidence, and linked checklist.
  - Notes: Existing SEO master found and recentered on technical SEO; project-instance template added. Do not create a second SEO master.

- [x] Task 4: Add a parser/status helper for lifecycle instances.
  - File: `tools/` and focused tests
  - Action: Derive current state, overdue items, today, this week, next week, next review, and tracker routing without mutating source Markdown.
  - User story link: Makes skill and app projections deterministic.
  - Depends on: Tasks 1-3
  - Validate with: Fixtures for timezone boundaries, cadence changes, paused projects, duplicates, and missing evidence.
  - Notes: Reuse existing parser conventions where possible. **Implemented in `tools/shipglows_project_lifecycle_status.py` with a deterministic Markdown fixture and focused tests; checklist-instance parsing remains.**

- [ ] Task 5: Teach the task/status readers to consume lifecycle projections.
  - File: `skills/309-sg-tasks/`, `skills/308-sg-status/`, `tui/src/sources/`
  - Action: Add read-only lifecycle summaries and preserve existing task/spec/audit ownership and routing.
  - User story link: Shows project state without replacing current trackers.
  - Depends on: Task 4
  - Validate with: Existing TUI/source tests plus lifecycle fixture snapshots.
  - Notes: App UI remains a later consumer of the same model. **The TUI now reads `project_lifecycle.md` when present and keeps older projects compatible; skill/status adapter parity remains to be completed.**

- [ ] Task 6: Define skill integration rules.
  - File: `skills/references/task-application-loop.md`, `skills/references/task-registry-routing.md`, relevant domain skills
  - Action: Specify when a lifecycle item becomes a task, audit, editorial roadmap item, spec, or proof record, and how recurring completion creates the next instance.
  - User story link: Prevents checklist-only completion and duplicate trackers.
  - Depends on: Tasks 1 and 4
  - Validate with: Technical/editorial mixed-finding scenarios.
  - Notes: Keep specialist playbooks as owners of domain judgment. **Cybersecurity routing and recurring-instance rules are now explicit in `task-registry-routing.md` and `task-application-loop.md`; broader skill adapters remain.**

- [ ] Task 7: Prepare the ShipGlows app handoff contract.
  - File: `shipglows_data/technical/` and the app project after contract approval
  - Action: Document the read model the future interface must consume: project overview, domain cards, timeline, today/next-week queues, evidence, blockers, and history.
  - User story link: Ensures the visual app is a projection of the same versioned system.
  - Depends on: Tasks 1-6
  - Validate with: App implementation spec or adapter contract; no UI claim before the read model is stable.
  - Notes: This task does not authorize a broad UI rewrite. **Read model draft added in `shipglows_data/technical/project-lifecycle-read-model.md`; app implementation remains out of scope.**

## Acceptance Criteria

- [ ] AC 1: Given a governed project with one-time, recurring, cyclic, and event-triggered items, when the lifecycle parser reads it, then it returns distinct current states and next occurrences for each type.
- [ ] AC 2: Given a completed recurring SEO review, when the current period closes, then the historical completion remains visible and the next due occurrence is generated without marking the reusable checklist permanently complete.
- [ ] AC 3: Given one audit producing technical and editorial findings, when routing is derived, then technical follow-up goes to `TASKS.md` and public/editorial follow-up goes to `editorial/ROADMAP.md`.
- [ ] AC 4: Given missing evidence or undeclared applicability, when status is calculated, then the result is `waiting_for_evidence` or `needs_review`, never clean completion.
- [ ] AC 5: Given the same Markdown source, when a skill reader, TUI reader, or future app adapter consumes it, then each returns the same item IDs, states, due dates, and blockers.
- [ ] AC 6: Existing `TASKS.md`, spec, audit, and test-checklist parsing remains compatible.

## Test Strategy

- Unit: lifecycle schema validation, recurrence calculation, state transitions, routing derivation, deduplication, and timezone boundaries.
- Integration: fixture project consumed by the existing task/spec/audit readers and TUI source layer.
- Manual: inspect the resulting project summary for “today”, “this week”, “next week”, overdue, blockers, and history.

## Test Contract

### Surface

- Stack/surface: Markdown contract, Python/TypeScript readers, TUI; future Flutter app adapter
- Proof profile: contract-and-parser
- Primary proof mode: mixed
- Proof order: contract fixtures → parser tests → reader/TUI integration → manual projection review

### Manual checklist

- Needed: yes
- Checklist path: `shipglows_data/workflow/test-checklists/project-lifecycle-checklist-operating-model.md`
- Required scenario IDs: `one-time-completion`, `recurring-next-instance`, `mixed-routing`, `missing-evidence`, `paused-project`, `timezone-boundary`, `source-parity`
- Required results: all required scenarios must be `PASS`; `FAIL`, `BLOCKED`, or `NOT_RUN` keeps the chantier non vérifié.
- Required scenario coverage: recurrence, mixed routing, missing evidence, paused project, timezone boundary, and source parity
- Exception with proof: no app UI proof is required until the read-model contract is accepted

### Required evidence stack

- Automated / unit / integration checks: focused parser and reader tests, metadata lint, existing TUI tests
- Agent-run browser proof: none in the contract phase
- Auth/session proof (`sg-auth-debug`): none
- Contract/integration proof: fixture parity across skills/readers
- Provider evidence: none
- Device-native proof: none

## Risks

- Security impact: none directly; future app synchronization must not allow untrusted project files to trigger privileged actions.
- Product/data/performance risk: high risk of duplicating task state, generating recurrence noise, or producing misleading progress; mitigate with stable IDs, explicit ownership boundaries, historical instances, and evidence-backed state.

## Execution Notes

- Read first: `skills/references/canonical-paths.md`, `skills/references/task-registry-routing.md`, `skills/references/task-application-loop.md`, `workflow/playbooks/README.md`, `workflow/checklists/README.md`, existing SEO/site-launch artifacts, and TUI source readers.
- Validate with: metadata lint, lifecycle fixtures, focused parser tests, existing TUI/source tests, and a manual projection review.
- Stop conditions: schema conflicts with existing tracker ownership, recurrence semantics cannot preserve history, or app integration is attempted before the read model is stable.

## Open Questions

None for the first contract pass. The exact application persistence/sync strategy is intentionally downstream of the Markdown read model.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-27 00:00:00 UTC | 100-sg-spec | GPT-5 Codex | Created spec after auditing existing task, playbook, checklist, spec, and TUI architecture | draft | /101-sg-ready project-lifecycle-checklist-operating-model |
| 2026-07-27 00:00:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, scope, ownership boundaries, proof contract, and adversarial cases | ready | /102-sg-start project-lifecycle-checklist-operating-model |
| 2026-07-27 00:00:00 UTC | 102-sg-start | GPT-5 Codex | Implemented lifecycle contract, project declaration template, and proof checklist pilot | partial | /102-sg-start project-lifecycle-checklist-operating-model parser and fixtures |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added `cybersecurity` as a canonical lifecycle domain and clarified its boundary with `security_impact` | partial | /102-sg-start project-lifecycle-checklist-operating-model parser and fixtures |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Implemented the read-only lifecycle projection parser, fixture, and seven focused unit scenarios | partial | Add cybersecurity playbook/checklist pilot, then wire readers |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added the reusable cybersecurity readiness and maintenance playbook/checklist pilot | partial | Wire lifecycle projections into task/status readers |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Wired lifecycle summaries into the read-only TUI and clarified cybersecurity/recurrence routing rules | partial | Prepare app read-model handoff and execute manual proof checklist |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added the future ShipGlows app read-model contract without starting a UI rewrite | partial | Run formal verification and manual lifecycle proof |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added Python/TUI source-parity projection tests; six of seven proof scenarios are now recorded PASS | partial | Execute the mixed-routing proof and keep adapter parity explicit |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Recentered the existing SEO master on technical SEO and added the project checklist-instance/cycle template | partial | Add instance parser and a concrete technical SEO project pilot |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added the read-only checklist-instance parser, technical SEO cycle fixture, and focused progression/evidence tests | partial | Wire checklist-instance summaries into the TUI/app read model |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Preserved the former mixed SEO checklist as `seo-content-strategy-a-migrer-plus-tard-checklist.md` instead of discarding its content | partial | Keep the archive as the migration source for the separate SEO content project |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Wired checklist-instance summaries into the read-only TUI, including cycle progress, current phase, next control, and evidence blockers without emitting tasks | partial | Run final verification and retain Markdown as the application source |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Clarified the transversal domain catalog: technical, cybersecurity, technical SEO, performance, analytics, marketing, copywriting, content, launch, production, and maintenance are separate lifecycle lanes; undefined masters remain needs_review | partial | Define the remaining domain masters before claiming full transversal coverage |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added first reusable playbook/checklist masters for performance, analytics, marketing, copywriting, content operations, production, and maintenance; retained technical SEO/content separation | partial | Run metadata and parser verification, then instantiate masters on a real project |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Initialized jarretelacoke.fr with a project lifecycle declaration and seven launch-cycle instances, all at not_started with no inferred progress | partial | Normalize stable IDs in the legacy technical, cybersecurity, SEO and launch masters before instantiating those domains |
| 2026-07-28 00:00:00 UTC | 001-sg-build | GPT-5 Codex | Added explicit project and instance cadence fields, configurable review dates, timezones and event triggers; applied the first cadence policy to all eleven jarretelacoke.fr launch instances | partial | Execute the configured launch-cycle controls and retain each future occurrence as a new instance |

## Current Chantier Flow

- `100-sg-spec`: done, ready contract created.
- `101-sg-ready`: done, ready.
- `102-sg-start`: partial, technical SEO master, checklist-instance template/parser, and concrete cycle pilot added alongside the cybersecurity pilot, TUI projection, and app read-model draft; consumer wiring remains.
- `103-sg-verify`: not launched.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: execute the configured launch-cycle controls on jarretelacoke.fr; each future occurrence must receive a new cycle ID, with content SEO and keyword work outside the technical SEO instance.
