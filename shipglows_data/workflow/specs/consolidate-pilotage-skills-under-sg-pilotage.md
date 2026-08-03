---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-07-18"
created_at: "2026-07-18 13:48:06 UTC"
updated: "2026-08-03"
updated_at: "2026-08-03 23:38:42 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "skill-taxonomy consolidation and public migration"
owner: "Diane"
user_story: "As a ShipGlows operator, I want one public pilotage entrypoint with explicit tasks, backlog, priorities, review, and sessions modes, so that I can manage work and conversation state without navigating competing skills or loading unrelated procedures."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/011-sg-pilotage/"
  - "skills/309-sg-tasks/"
  - "skills/701-sg-backlog/"
  - "skills/702-sg-priorities/"
  - "skills/703-sg-review/"
  - "skills/references/skill-code-index.md"
  - "shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md"
  - "tools/rename_codex_session.py"
  - "tools/prune_codex_sessions.py"
  - "tools/test_rename_codex_session.py"
  - "tools/test_prune_codex_sessions.py"
  - "tools/test_bug_proof_fidelity_contract.py"
  - "skills/700-sg-explore/SKILL.md"
  - "skills/704-sg-model/SKILL.md"
  - "skills/705-sg-conversation-audit/SKILL.md"
  - "skills/706-continue/SKILL.md"
  - "skills/707-name/SKILL.md"
  - "skills/308-sg-status/SKILL.md"
  - "skills/references/product-decision-chain.md"
  - "skills/references/atlas-cartography-lifecycle.md"
  - "plugins/shipglows/assets/pack-catalog.json"
  - "plugins/shipglows/skills/shipglows/references/public-help-catalog.md"
  - "plugins/shipglows/skills/shipglows/references/pack-catalog.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.5.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/skill-context-budget.md"
    artifact_version: "0.3.1"
    required_status: draft
  - artifact: "skills/references/operational-record-format.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.9.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.10.1"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.8.0"
    required_status: draft
  - artifact: "skills/references/task-registry-routing.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/product-decision-chain.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/atlas-cartography-lifecycle.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md"
    artifact_version: "1.4.1"
    required_status: draft
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.6.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-07-18: consolidate 309-sg-tasks, 701-sg-backlog, 702-sg-priorities, and 703-sg-review into the single public sg-pilotage domain with modes tasks, backlog, priorities, and review."
  - "The four source contracts all declare Process role: pilotage and share local-first tracker, question, reporting, and chantier-trace doctrine."
  - "Operator selection 2026-08-03: run the pilotage consolidation next, with sessions promoted to an explicit public mode rather than hidden under tasks."
  - "Current inventory 2026-08-03: the four source contracts total 863 activated lines; 309 mixes tracker maintenance with a large Codex-session contract, while 701, 702, and 703 remain separate discovery entries for one métier."
  - "Current active discovery surfaces still expose 309, 701, 702, and 703 independently through the code index, plugin pack catalogs, operator cheatsheet, runtime lifecycle guide, neighboring references, and focused tests."
  - "Current repository inventory contains no shipglows-site or site source tree; public migration therefore targets the repository-backed plugin help/catalog and operator documentation surfaces, not a nonexistent public-page build."
  - "The existing session playbook and deterministic tests preserve exact-cwd isolation, missing-status no-mutation behavior, dry-run-first pruning, and semantic-title safeguards that must transfer to the sessions mode."
next_step: "/102-sg-start consolidate-pilotage-skills-under-sg-pilotage"
---

# Title

Consolidate Pilotage Skills Under sg-pilotage

# Status

ready — the operator selected this chantier; the canonical `011-sg-pilotage` identity, five-mode contract, migration boundaries, security invariants, and scenario-first proof are explicit enough for a fresh implementation agent.

# User Story

As a ShipGlows operator, I want to invoke `$011-sg-pilotage` with `tasks`, `backlog`, `priorities`, `review`, or `sessions` so that I can manage work and conversation state through one métier-first domain without losing tracker safety, the backlog/execution split, active prioritization, evidence-based review, or Codex-session safeguards.

# Minimal Behavior Contract

`$011-sg-pilotage <mode> [arguments]` accepts exactly one of five public modes: `tasks`, `backlog`, `priorities`, `review`, or `sessions`. It loads only the selected mode's playbook and performs only that management action. A bare, unknown, or mixed-action input asks one orientation question among the five modes and mutates no tracker, backlog, review artifact, changelog, or Codex state. Every mutable target is authoritatively reread immediately before a bounded write; `sessions rename` without a valid explicit status performs no session read, title derivation, helper call, or mutation. The easy-to-miss edge case is retaining sessions as a hidden tasks subcommand or leaving old skill aliases selectable: both are forbidden after migration.

# Success Behavior

- `$011-sg-pilotage tasks` maintains the local execution tracker and suggests a tracker-derived next step without inspecting or mutating Codex sessions.
- `$011-sg-pilotage backlog` captures, defers, cleans up, or promotes items in the local backlog without pretending to rank active tasks.
- `$011-sg-pilotage priorities` ranks active tasks by impact, effort, blockers, dependencies, and risk, then proposes the next work without executing it.
- `$011-sg-pilotage review` reconstructs an evidence-based summary, distinguishes implemented, verified, and assumed states, and performs only justified tracker or changelog writes.
- `$011-sg-pilotage sessions` triages repository-scoped Codex titles, renames only the current conversation with an explicit status, or previews/applies safe old-session pruning through the governed helper contract. The legacy `name-conversation` route is retired as redundant with `sessions rename <status>`; `707-name` remains the separate Claude statusline-label helper.
- Operators and agents find one `sg-pilotage` README, one index entry, and aligned plugin/operator documentation that explain the five modes and their limits without losing routes to neighboring owners.
- After runtime sync, the visible skill is `011-sg-pilotage`; none of the four old identities remains installed as a selectable skill.

# Error Behavior

- Missing, unknown, or multiple modes: explain the five choices and request one mode; do not select the last-used mode or load a substantive playbook.
- Missing tracker target or an anchor that remains ambiguous after reread and recompute: write nothing; request the smallest missing context or create only the file explicitly authorized by the playbook.
- A request to continue a chantier, modify code, verify or close an implementation, or only report status: route respectively to `706-continue`, the execution owner, `103-sg-verify`/`104-sg-end`, or `308-sg-status` without silently expanding `sg-pilotage`.
- `sessions rename` without a supported status: ask for exactly one of `todo`, `doing`, `in_progress`, `blocked`, or `done`; do not inspect any thread, call the helper, derive a title, or touch `TASKS.md`.
- A write, backlog deletion, session prune, or task promotion without the proof or confirmation required by the playbook: stop with an explicit recoverable result; never improvise SQL, deletion, or a broad rewrite.

# Problem

Work management is split across four public skills that share one métier, local workflow sources, and repeated safeguards. The four activation bodies total 863 lines, and `309-sg-tasks` alone mixes tracker maintenance with a large Codex-session operating contract. This fragmentation raises discovery cost, forces permanent cross-calls, and loads unrelated procedures before the operator has selected the intended outcome. Active plugin catalogs, operator guidance, references, and focused tests still reinforce the split.

# Solution

Create `skills/011-sg-pilotage/` as the sole runtime and public identity for this métier. Its `SKILL.md` remains a compact activation contract: mission, exact five-mode grammar, lazy-loading map, boundaries, stop conditions, trace, and validation. Five local playbooks receive the transferred procedures: tasks, backlog, priorities, review, and sessions. The migration transfers behavior and session safeguards before it retires the four old directories, updates every active discovery surface, and leaves no wrapper, alias, or hidden `tasks sessions` compatibility path.

Code `011` is the next available identity in the `000-099` band, reserved for frequent high-level entrypoints. It is therefore stable, memorable, and consistent with the cross-cutting nature of `sg-pilotage`; it is neither a renumbering of the modes nor a fifth skill family.

# Scope In

- Create `skills/011-sg-pilotage/SKILL.md`, `README.md`, and five local playbooks with compliant frontmatter.
- Transfer the contracts of `309-sg-tasks`, `701-sg-backlog`, `702-sg-priorities`, and `703-sg-review` completely and verifiably into five public modes, splitting tasks and sessions before retirement.
- Transfer `sessions`, `sessions rename <status>`, and `sessions prune [cwd]` into the top-level `sessions` mode; retire redundant `name-conversation` rather than preserving it as a hidden alias, while keeping `707-name` separate.
- Actually remove the four old skill directories, with no mirror directory, runtime alias, compatibility symlink, wrapper, or old index entry.
- Update the code index, runtime sync, help, operator guides, plugin catalogs, README, neighboring references, code-docs map, and active contract tests.
- Update current repository-backed public help/catalog surfaces; do not invent or depend on a `site/` or `shipglows-site/` tree that is absent from the current repository.
- Update migration documentation, the refresh log, and `TASKS.md`/CHANGELOG only when closure governance requires it; then run scenario-first validation and the normal refresh/verify/end/ship lifecycle.

# Scope Out

- No change to the role of `706-continue`: it continues the current chantier and does not become a management mode.
- No change to the role of `308-sg-status`: it remains a read-only view and does not mutate trackers.
- No transfer of the editorial roadmap into the management domain; the `shipglows_data/editorial/ROADMAP.md` / `shipglows_data/workflow/TASKS.md` split remains governed by `task-registry-routing`.
- No merge with `700-sg-explore`, `704-sg-model`, `705-sg-conversation-audit`, `707-name`, `304-sg-changelog`, `103-sg-verify`, `104-sg-end`, or the content and technical domains.
- No change to the SQLite schema, internal logic of `tools/rename_codex_session.py` or `tools/prune_codex_sessions.py`, except when a migration test reveals a reference required by the new owner.
- No rewrite of archives, closed specs, historical audits, historical changelogs, or transcripts merely to erase old names.
- No commit, push, plugin publication, or deployment without the operator's explicit authorization through the ship cycle.

# Constraints

- The sole canonical invocation is `$011-sg-pilotage`; its public modes are exactly `tasks`, `backlog`, `priorities`, `review`, and `sessions`. `help` is not a sixth mode: an invalid input response describes the five choices without side effects.
- Never infer a mode from the preceding conversation, a filename, or tracker proximity; resolve ambiguity with one choice-oriented question.
- Load exactly one substantive playbook for an explicit mode; an invalid input loads no working playbook.
- `tasks` must not accept session operations. The canonical session grammar is `sessions [project-or-cwd]`, `sessions rename <status>`, and `sessions prune [cwd]`; old `tasks sessions ...` and `name-conversation` forms are migration provenance only, not runtime aliases.
- Activation bodies must remain below `skill-context-budget` thresholds; procedures, matrices, examples, and variants belong in local or shared references without doctrine duplication.
- All internal contracts remain in English; each new operator-visible surface remains in the active language, using natural French and accents when French is active.
- `fresh-docs not needed`: this chantier depends on no provider, SDK, framework, or external behavior; it moves only local contracts, files, and routes.
- Implementation must re-read `skills/309-sg-tasks/SKILL.md`, the shared session playbook, and the focused session tests immediately before transfer; current safety behavior is source evidence even if the worktree is clean now.

# Test Contract

- Surface: skill activation contract, five local playbooks, tracker/backlog/review mutations, Codex-session operations, index/runtime, repository-backed public help/catalog, operator docs, and focused session-safety tests.
- proof_profile: `scenario-first` + targeted deterministic Python test + fresh boundary review + mechanical runtime/document validation.
- proof_order: active/historical inventory -> isolated dispatcher scenarios -> one selected playbook per scenario -> focused contract and session tests -> metadata/index/budget/sync -> active documentation and plugin-catalog scans -> independent boundary and diff review.
- required_scenario_ids: `PILOTAGE-EXACT-FIVE-MODES`, `PILOTAGE-AMBIGUOUS-NO-WRITE`, `PILOTAGE-TASKS-NOT-SESSIONS`, `PILOTAGE-SESSIONS-STATUS-GATE`, `PILOTAGE-SESSIONS-CWD-AND-PRUNE-SAFETY`, `PILOTAGE-BACKLOG-NOT-PRIORITY`, `PILOTAGE-PRIORITIES-NOT-EXECUTION`, `PILOTAGE-REVIEW-NOT-VERIFY`, `PILOTAGE-BOUNDARY-NEIGHBORS`, `PILOTAGE-LOCAL-TRACKER-SAFETY`, `PILOTAGE-NO-LEGACY-RUNTIME`, `PILOTAGE-ACTIVE-DOCS-MIGRATION`.
- required_results: all twelve scenarios and focused tests pass; metadata lint, skill budget, code index, runtime sync, active/historical scan, JSON catalog parse, and `git diff --check` pass; any pre-existing global failure is separated from a regression attributable to `011-sg-pilotage`.
- Automated proof available: `tools/test_011_sg_pilotage_contract.py`, `tools/test_rename_codex_session.py`, `tools/test_prune_codex_sessions.py`, `tools/test_bug_proof_fidelity_contract.py`, `tools/test_guided_business_product_discovery_contract.py`, metadata lint, budget/index audits, runtime sync, JSON parse, scoped `rg`, and diff hygiene.
- Manual proof required: read the dispatcher alone, then each of the five playbooks alone; verify that a fresh agent selects one outcome without absorbing another mode, and manually compare every session invariant against the current source contract and playbook before retiring `309-sg-tasks`.
- exception_with_proof: a known global failure may be accepted only with complete baseline output plus a targeted check proving no line concerns `011-sg-pilotage`, the five-mode grammar, or retired-owner availability. A missing website build is not an exception: the current repo contains no site tree, so no website build belongs to this contract unless one is added before implementation.
- exception_without_proof: none.

## Required Scenarios

| ID | Given | When | Then |
| --- | --- | --- | --- |
| `PILOTAGE-EXACT-FIVE-MODES` | each of `tasks`, `backlog`, `priorities`, `review`, and `sessions` is invoked once | the dispatcher is read alone | it exposes exactly those five modes and loads only the matching playbook for each invocation. |
| `PILOTAGE-AMBIGUOUS-NO-WRITE` | a bare, unknown, or “organise everything” input | the dispatcher receives the request | it proposes exactly the five modes and neither reads nor writes a tracker, session, backlog, changelog, or review artifact. |
| `PILOTAGE-TASKS-NOT-SESSIONS` | `$011-sg-pilotage tasks sessions rename done` | `tasks` is selected | it refuses the mixed route and directs the operator to the explicit `sessions` mode without inspecting or mutating Codex state. |
| `PILOTAGE-SESSIONS-STATUS-GATE` | `$011-sg-pilotage sessions rename` with no supported status | `sessions` is selected | it asks for exactly one allowed status without deriving a title, reading any session, calling a helper, or mutating Codex/TASKS. |
| `PILOTAGE-SESSIONS-CWD-AND-PRUNE-SAFETY` | another project has similar titles and pruning has not been confirmed | `sessions` or `sessions prune` runs | exact absolute cwd isolates the scope, the current thread remains excluded, and pruning stays a dry-run until exact apply confirmation. |
| `PILOTAGE-BACKLOG-NOT-PRIORITY` | an idea to defer | `backlog defer` | the playbook moves it only according to backlog rules and makes the later priorities route explicit; it does not calculate a hidden P0. |
| `PILOTAGE-PRIORITIES-NOT-EXECUTION` | credible active tasks | `priorities blockers` | the playbook ranks and recommends the next target, then routes to `706-continue` or `102-sg-start`; it does not execute the target. |
| `PILOTAGE-REVIEW-NOT-VERIFY` | a week of commits without complete functional proof | `review weekly` | it writes the canonical metadata-bearing review artifact, distinguishes activity, implementation, verification, and assumptions, and does not declare the product validated or replace `103-sg-verify`. |
| `PILOTAGE-BOUNDARY-NEIGHBORS` | operator asks to explore an idea, choose a model, audit conversations, continue a chantier, inspect status, or tag the Claude statusline | the dispatcher is evaluated | `700`, `704`, `705`, `706`, `308`, or `707` remains the owner; no pilotage mode absorbs the request. |
| `PILOTAGE-LOCAL-TRACKER-SAFETY` | a local tracker whose anchor changes between snapshot and write | a mutating playbook wants to write | it rereads, recomputes once, then blocks or asks if the anchor remains ambiguous; it never rewrites the complete file from memory. |
| `PILOTAGE-NO-LEGACY-RUNTIME` | the migration is complete and sync has run | Codex/Claude resolve skills | `011-sg-pilotage` is the only installed management source; `skills/309-sg-tasks`, `701-sg-backlog`, `702-sg-priorities`, `703-sg-review`, and their runtime links no longer exist. |
| `PILOTAGE-ACTIVE-DOCS-MIGRATION` | the operator consults the skill README, plugin help/catalog, operator cheatsheet, runtime guide, or code index | the migration is delivered | they find `011-sg-pilotage` and five modes; no active surface presents old names as available commands, while historical provenance remains intact. |

# Dependencies

- `skills/references/skill-code-index.md`: runtime name, code band, uniqueness, and index validation; `011` must be added as `sg-pilotage` in the master/high-frequency family.
- `skills/references/skill-instruction-layering.md` and `skills/references/skill-context-budget.md`: dispatcher boundary and contract/playbook allocation.
- `skills/references/question-contract.md`, `reporting-contract.md`, `chantier-tracking.md`, `operational-record-format.md`, and `task-registry-routing.md`: questions, trace, reports, minimal writes, and the editorial/execution split to preserve without divergent copy.
- `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/rename_codex_session.py`, `tools/prune_codex_sessions.py`, and their focused tests: source of truth and proof for the session flow transferred to `sessions`.
- `skills/700-sg-explore/SKILL.md`, `skills/704-sg-model/SKILL.md`, `skills/705-sg-conversation-audit/SKILL.md`, `skills/706-continue/SKILL.md`, `skills/707-name/SKILL.md`, and `skills/308-sg-status/SKILL.md`: adjacent boundaries that remain separate.
- `plugins/shipglows/assets/pack-catalog.json`, its Markdown catalog, the public-help catalog, the operator cheatsheet, runtime lifecycle guide, code-docs map, and active neighboring references: current discovery/documentation surfaces. No external documentation is required.

# Invariants

- `011-sg-pilotage` is the sole runtime/public owner of tasks, backlog, priorities, review, and Codex-session operations; it keeps no second hidden identity.
- The five modes retain distinct outcomes: tracker state, deferred backlog, active work order, evidence-based review, and Codex-session state. Consolidation does not permit a catch-all mode.
- Trackers remain local first; an explicit portfolio state is a derived view, never a return to a central master tracker.
- The `TASKS` / `ROADMAP` route remains compliant with `task-registry-routing`; mixed discoveries split rather than becoming ambiguous records.
- Codex sessions are filtered by exact absolute `cwd`; the current thread, other threads, and task records retain their current boundaries.
- `done` is never inferred from a final message, commit, build, or review alone.
- `706-continue` executes current work; `308-sg-status` reads state; `103-sg-verify` decides conformity proof; and `104-sg-end` closes. `011` routes to them but does not replace them.
- References to old names in archives, closed specs, audits, or changelog remain historical provenance and are not modified by global replacement.
- No secret, private conversation content, token, cookie, or SQLite database reaches the playbooks, public docs, tests, or migration reports.

# Security Review

- Authentication and authorization remain local-runtime concerns: the migration creates no remote endpoint or privilege path, and session mutations stay limited to the current user's Codex state through the existing governed helpers.
- Treat status, thread, and path inputs as untrusted until the helper validates the exact status vocabulary, current `CODEX_THREAD_ID`, resolved absolute `cwd`, and target row. No playbook may reproduce direct SQL or deletion logic.
- Exact-cwd isolation, current-thread exclusion, dry-run-first pruning, exact apply confirmation, stop-on-first native deletion failure, and post-write verification preserve workflow integrity and prevent concealed cross-project or partial-failure effects.
- Reports, tests, trackers, public help, and migration artifacts never copy transcripts, secrets, cookies, tokens, private payloads, raw SQLite contents, or unnecessary private paths.
- No new secret, provider trust, network access, multi-tenant boundary, or uncontrolled fan-out is introduced. Focused rename/prune tests and the source-to-playbook invariant matrix mitigate the residual local-overreach risk before source retirement.

# Links & Consequences

- References to the four skills currently occur in the code index, JSON/Markdown plugin catalogs, operator cheatsheet, runtime lifecycle guide, code-docs map, READMEs, shared routing references, operator-role references, and focused tests. They must be classified as active, generated/runtime, or historical before modification.
- The current repository has no public site source tree. The plugin public-help/catalog and operator documentation are therefore the active public discovery surfaces; an implementation must re-inventory before editing in case a site appears later.
- `sg-resume`, `sg-veille`, `sg-changelog`, `sg-end`, `sg-status`, `sg-maintain`, Atlas/task routing, and guided-product-decision contracts must point to `sg-pilotage <mode>` only where they actively recommend one of the five actions; unrelated ownership must not change reflexively.
- The plugin pack that lists `309`, `701`, `702`, and `703` must present `011-sg-pilotage` only once in the matching pack; no pack retains a retired skill name.
- The design, content, marketing, technical, customer, and veille migrations show the required convention: a compact public dispatcher, local playbooks, a deterministic test, and a migrated public page. They do not authorize rewrites of their historical references.

# Documentation Coherence

## Documentation Update Plan

- Replace the four removed READMEs with `skills/011-sg-pilotage/README.md`, including exact five-mode grammar, safe session subcommands, and neighboring owner boundaries.
- Update `skills/references/skill-code-index.md`, `skills/302-sg-help/references/help-catalog.md` when its active catalog requires the route, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/code-docs-map.md`, plugin pack/public-help catalogs, and only the active neighboring contracts found by inventory.
- Update tests and tool-owned generic-title/owner references that target `309-sg-tasks`; retain tool behavior and private-data boundaries.
- Do not create public content pages in an absent site. If a site source tree appears before implementation, pause the docs batch, inventory its current content contract, and add its active pilotage surface to the same migration before retirement.
- Do not modify historical ROADMAP, closed specs, audits, changelog history, or transcripts merely to remove a historical occurrence.
- Add a clear migration entry to CHANGELOG/refresh log following their active formats so that documentation is migrated rather than merely removed.

## Editorial Update Plan

- `checked`: this chantier modifies skill, plugin, and operator documentation, not client-project content or a product editorial surface.
- Public/plugin help remains operator-oriented: choice of action, observable result, limits, and neighboring routes; it publishes neither raw session data, SQLite details, private paths, nor deletion internals.
- `fresh-docs not needed`: no framework, SDK, provider, or external API behavior governs this local contract migration.

# Edge Cases

- An operator enters `$011-sg-pilotage sessions`: this is a valid explicit mode and defaults to repository-scoped session triage under exact-cwd safeguards.
- An operator enters `$011-sg-pilotage tasks sessions rename done`: reject the mixed mode before any Codex read and point to `$011-sg-pilotage sessions rename done`; never preserve a hidden compatibility alias.
- A request combines “add the idea, prioritize it, and start”: ask which mode to perform now, apply at most one action, and then send explicitly selected execution to `706`/`102`.
- A backlog being cleaned contains items to remove: retain the confirmation prompt and the Discarded section; no direct deletion hides in a migration mode.
- A review reveals an active task without a priority decision: it can record that fact honestly and propose `priorities`; it does not create an implicit ranking.
- An old link is found in a closed spec, dated audit, or transcript: retain it as evidence; the test inspects only the declared active inventory.
- The code-index linter continues to report old out-of-scope `sg-*`/`shipglows` identities: document that debt as a separate baseline, then prove no line concerns `011` or the four retired owners.
- No source has an `agents/openai.yaml` file: do not invent a manifest. If implementation creates one for `011`, its display name must equal `011-sg-pilotage` exactly and it joins runtime checks.
- The source session contract evolves during the chantier: re-read the current files and focused tests immediately before extraction; if their safeguards conflict with the planned `sessions` mode, stop the transfer batch and repair the spec rather than choosing silently. Before retiring `309`, move every focused source-path assertion to the transferred `011` sessions contract.

# Implementation Tasks

- [ ] Task 1: Freeze the active/historical inventory and session-safety baseline.
  - Files: `skills/309-sg-tasks/SKILL.md`, `skills/701-sg-backlog/SKILL.md`, `skills/702-sg-priorities/SKILL.md`, `skills/703-sg-review/SKILL.md`, their READMEs, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/test_rename_codex_session.py`, `tools/test_bug_proof_fidelity_contract.py`, and all `rg` hits in active public/help/runtime/plugin surfaces.
  - Action: Classify each hit as active, generated/runtime, compatibility, or historical. Record exact-cwd isolation, missing-status no-read/no-mutation behavior, semantic title derivation, dry-run pruning, current-thread exclusion, and focused `309` path assertions as mandatory transfer content.
  - User story link: Prevents a smaller picker from losing behavior or falsifying historical provenance.
  - Depends on: None.
  - Validate with: scoped `rg -n -i "309-sg-tasks|701-sg-backlog|702-sg-priorities|703-sg-review|sg-tasks|sg-backlog|sg-priorities|sg-review"` across active paths plus focused reads of the session playbook and tests. No mutation occurs in this task.
  - Notes: Do not modify the historical `pilotage-skills-governance-alignment.md` spec.

- [ ] Task 2: Establish the canonical `011-sg-pilotage` activation contract.
  - Files: `skills/011-sg-pilotage/SKILL.md`, `skills/011-sg-pilotage/README.md`.
  - Action: Create a compact English dispatcher with `name: 011-sg-pilotage`, concise discovery description, exact grammar `tasks|backlog|priorities|review|sessions`, one-playbook lazy map, bare/invalid/multi-mode stop behavior, trace/report loaders, local-first/write-safety boundaries, neighbor reroutes, and validation commands.
  - User story link: Gives the operator one discoverable, unambiguous entrypoint.
  - Depends on: Task 1.
  - Validate with: focused `rg` for all five modes, all adjacent owners, no sixth public mode, line/token budget audit, and deterministic dispatcher assertions.
  - Notes: The activation body contains no copied procedure matrices and no old runtime identity as alias.

- [ ] Task 3: Transfer tracker maintenance into the `tasks` playbook.
  - Files: `skills/011-sg-pilotage/references/tasks-playbook.md` and active shared tracker references only where owner names change.
  - Action: Transfer local/legacy tracker distinction, task-registry routing, authoritative reread/minimal patch protocol, evidence-based completion, active-vs-backlog hygiene, changelog boundary, and tracker-derived next-step recommendation. Exclude all Codex-session operations.
  - User story link: Preserves execution-tracker management without loading private session procedures.
  - Depends on: Task 2.
  - Validate with: `PILOTAGE-TASKS-NOT-SESSIONS`, tracker-safety scenarios, focused pressure-anchor scan, and manual comparison against the non-session portions of `309`.
  - Notes: Do not delete `309-sg-tasks` until this transfer and proof are complete.

- [ ] Task 4: Transfer sessions into a first-class local playbook.
  - Files: `skills/011-sg-pilotage/references/sessions-playbook.md`, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/rename_codex_session.py`, `tools/prune_codex_sessions.py`, `tools/test_rename_codex_session.py`, `tools/test_prune_codex_sessions.py`, and `tools/test_bug_proof_fidelity_contract.py` only where owner paths/names must migrate.
  - Action: Transfer repository-scoped triage, exact status vocabulary, semantic-title rules, duplicate/inactivity behavior, current-session rename, dry-run-first pruning, exact-cwd and current-thread protection, private-data redaction, and every missing-status safeguard. Retire `name-conversation` as redundant with the canonical rename route; do not alter helper behavior except owner/generic-title references required by the migration.
  - User story link: Makes the highest-risk session behavior explicit and lazily loaded.
  - Depends on: Task 2.
  - Validate with: `PILOTAGE-SESSIONS-STATUS-GATE`, `PILOTAGE-SESSIONS-CWD-AND-PRUNE-SAFETY`, `python3 -m unittest tools.test_rename_codex_session tools.test_prune_codex_sessions tools.test_bug_proof_fidelity_contract`, and a manual source-to-playbook invariant matrix.
  - Notes: Do not retire `309-sg-tasks` until both Tasks 3 and 4 pass.

- [ ] Task 5: Transfer backlog, priorities, and review into three local playbooks.
  - Files: `skills/011-sg-pilotage/references/backlog-playbook.md`, `skills/011-sg-pilotage/references/priorities-playbook.md`, `skills/011-sg-pilotage/references/review-playbook.md`.
  - Action: Move each source’s operational model, input grammar, question gates, tracker safety, report mode, boundaries, confirmation requirements and evidence distinctions into its named playbook. Link shared doctrine instead of duplicating it.
  - User story link: Preserves specialised outcomes while removing four discovery entries.
  - Depends on: Task 2.
  - Validate with: each selected playbook satisfies its scenario (`BACKLOG-NOT-PRIORITY`, `PRIORITIES-NOT-EXECUTION`, `REVIEW-NOT-VERIFY`) and has no unrelated source mode copied into its dispatcher path.
  - Notes: `review` must retain its explicit distinction between activity evidence and verified product outcome.

- [ ] Task 6: Add deterministic migration and boundary proof.
  - Files: `tools/test_011_sg_pilotage_contract.py` and any narrowly necessary existing test fixture.
  - Action: Follow existing compaction-test conventions to assert exact five-mode grammar, one playbook per mode, source-behavior markers, all adjacent-owner boundaries, sessions missing-status/cwd/prune protections, code-index row, active documentation migration, and absence of the four retired directories after migration.
  - User story link: Makes future drift back to multiple public pilotage skills mechanically visible.
  - Depends on: Tasks 2-5.
  - Validate with: `python3 -m unittest tools.test_011_sg_pilotage_contract tools.test_rename_codex_session tools.test_prune_codex_sessions tools.test_bug_proof_fidelity_contract tools.test_guided_business_product_discovery_contract`.
  - Notes: The test may whitelist historical evidence; it must never demand a repository-wide literal-name purge.

- [ ] Task 7: Retire the four source skills only after successful transfer proof.
  - Files: remove `skills/309-sg-tasks/`, `skills/701-sg-backlog/`, `skills/702-sg-priorities/`, `skills/703-sg-review/` through a reviewed patch.
  - Action: Delete their `SKILL.md` and README surfaces after Tasks 3-5 pass. Do not leave redirect directories, wrapper skills, compatibility symlinks, hidden aliases, stale `agents/openai.yaml`, or code-index entries.
  - User story link: Actually reduces the number of selectable skills and removes picker ambiguity.
  - Depends on: Task 6.
  - Validate with: `test ! -e` checks for all four paths, targeted runtime-link inventory, `tools/shipglows_sync_skills.sh --check --skill 011-sg-pilotage`, and contract test.
  - Notes: Preserve historical references outside those source directories.

- [ ] Task 8: Migrate active runtime, help, plugin, and operator documentation surfaces.
  - Files: `skills/references/skill-code-index.md`, `skills/302-sg-help/references/help-catalog.md` when active routing requires it, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/technical/code-docs-map.md`, `plugins/shipglows/assets/pack-catalog.json`, `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, `plugins/shipglows/skills/shipglows/references/public-help-catalog.md`, and active neighboring contracts discovered in Task 1.
  - Action: Add the canonical `011` index row; replace active old entries with one `sg-pilotage` entry and five-mode prompts; update pack membership once, then update every active cross-link that would advertise an unavailable command. Recheck whether a public site exists before declaring docs complete.
  - User story link: Public and runtime discovery promise the same route as the installed skill.
  - Depends on: Tasks 2-7.
  - Validate with: scoped active-reference scan, `python3 -m json.tool plugins/shipglows/assets/pack-catalog.json`, metadata lint for governed Markdown, code-docs-map consistency, and contract test. Run a site build only if Task 1 discovers a current site source tree.
  - Notes: Keep historical CHANGELOG/ROADMAP/spec/audit hits unless they are active route instructions.

- [ ] Task 9: Refresh, verify, close, and ship through the normal lifecycle.
  - Files: `skills/REFRESH_LOG.md`, `shipglows_data/workflow/TASKS.md`, this spec, `CHANGELOG.md` when closure determines a user-visible entry.
  - Action: Run `900-shipglows-core refresh 011-sg-pilotage` after material edits; record fresh-docs verdict, docs/editorial result, runtime/reload state and active/historical scan. Then run `103`, `104`, and `005` only at their proper gates.
  - User story link: Ensures the reduction stays coherent after implementation rather than merely compiling.
  - Depends on: Tasks 1-8.
  - Validate with: refresh log block, `103` scenario-first report, closure tracker/changelog evidence where applicable, and a ship report scoped to the reviewed consolidation diff.
  - Notes: Commit/push remains separately authorized.

# Acceptance Criteria

- [ ] AC 1: Given an operator sees the installed skill list, when they search pilotage work, then exactly one public runtime skill `011-sg-pilotage` represents tasks, backlog, priorities, review, and sessions.
- [ ] AC 2: Given any one of the five modes is explicit, when the dispatcher resolves it, then it loads only the matching playbook and preserves the corresponding source contract.
- [ ] AC 3: Given mode selection is absent, unknown or combined, when `$011-sg-pilotage` runs, then it asks one orientation question and produces no tracker, session, backlog, review or changelog mutation.
- [ ] AC 4: Given `sessions rename` has no supported status, when it runs, then it performs no rename-related read or mutation and asks exactly one allowed status question; given `tasks sessions ...`, it rejects the mixed route before any Codex read.
- [ ] AC 5: Given an idea exploration, model choice, conversation audit, continuation, read-only status, or Claude statusline-tag request, when routed, then `700`, `704`, `705`, `706`, `308`, or `707` remains independent.
- [ ] AC 6: Given the migration is complete, when source directory and runtime inventories run, then no retired 309/701/702/703 directory, index row, runtime link, alias or wrapper is selectable.
- [ ] AC 7: Given a public-help/plugin/operator-doc surface is active, when it presents this domain, then it names `011-sg-pilotage`, exposes the five modes, and does not present the four former skills as available commands.
- [ ] AC 8: Given an old name appears only in a historical artifact, when active docs are aligned, then that provenance remains intact and does not fail the migration’s stale-route check.
- [ ] AC 9: Given all scoped changes are present, when focused tests, metadata lint, budget audit, code-index audit, runtime sync, active-doc/plugin checks, conditional site build, and diff hygiene run, then they pass or a proven unrelated baseline is reported separately.
- [ ] AC 10: Given the 309 session safeguards exist before implementation, when 309 is retired, then their promises, playbook anchors, and deterministic proof remain reachable only through `011-sg-pilotage sessions`.
- [ ] AC 11: Given the current repository has no site source tree, when documentation migration completes, then plugin help/catalog and operator docs are aligned without inventing public pages or reporting a skipped website build as a failure.

# Test Strategy

1. Run the twelve required scenarios against the dispatcher and then against only the selected playbook; do not award a scenario merely because another mode still contains the rule.
2. Run `python3 -m unittest tools.test_011_sg_pilotage_contract tools.test_rename_codex_session tools.test_prune_codex_sessions tools.test_bug_proof_fidelity_contract tools.test_guided_business_product_discovery_contract` after creation and again after retirement/docs migration.
3. Run `python3 tools/shipglows_metadata_lint.py skills/011-sg-pilotage shipglows_data/workflow/specs/consolidate-pilotage-skills-under-sg-pilotage.md` and include every newly added governed Markdown file if the linter invocation requires explicit paths.
4. Run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; record total skill-count reduction of three and confirm the dispatcher/playbooks meet their local budgets.
5. Run `python3 tools/skill_code_index_lint.py`; resolve any 011/retired-owner error. If only the known global `sg-*`/`shipglows` runtime debt remains, retain the exact output as an exception-with-proof rather than treating it as a pilotage success.
6. Run `tools/shipglows_sync_skills.sh --check --skill 011-sg-pilotage` and `tools/shipglows_sync_skills.sh --check --all`; inspect the runtime targets for the four old names and repair only migration-attributable links.
7. Run active-only `rg` scans across `skills`, `plugins`, `README.md`, active technical guides, routing references, tools, and tests. Classify history separately and check `git diff --check`.
8. Validate JSON with `python3 -m json.tool plugins/shipglows/assets/pack-catalog.json`; run a public-site build only if the implementation inventory finds a current site source tree.
9. Perform an adversarial review: try to make a fresh agent treat pilotage as execution, status, verification, ideation, model routing, conversation auditing, Claude statusline naming, global tracker rewrite, or unconfirmed session deletion; every plausible ambiguity must resolve to one explicit mode or neighboring owner.

# Risks

- High: retiring `309` drops a session guard or moves it into the wrong mode. Mitigation: source-to-playbook invariant matrix, focused rename/prune tests, and no retirement until the sessions proof passes.
- High: consolidation creates a broad pilotage catch-all that steals `700`, `704`, `705`, `706`, `707`, `308`, `103`, or editorial ownership. Mitigation: exact five-mode grammar, explicit boundary scenario, and dispatcher-only review.
- High: runtime/docs migration leaves old aliases selectable or active help stale. Mitigation: actual-directory removal, code-index/sync checks, active-surface inventory, plugin catalog parsing, and conditional site discovery.
- Medium: operational procedures become unreadable when copied into the dispatcher. Mitigation: one bounded playbook per explicit mode and budget audits.
- Medium: broad stale-name replacement rewrites historical evidence. Mitigation: active/historical classification before edits and a targeted test allowlist.
- Medium: session operations remain hidden under `tasks` for compatibility and defeat lazy loading. Mitigation: reject mixed `tasks sessions` input mechanically and expose `sessions` as a first-class mode everywhere active.
- Low: operators no longer recognise retired names. Mitigation: current help explains their outcomes as five modes without keeping callable aliases; historical artifacts retain provenance.

# Execution Notes

Read first, in order:

1. `skills/309-sg-tasks/SKILL.md`, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, and the rename/prune/bug-proof tests.
2. `skills/701-sg-backlog/SKILL.md`, `skills/702-sg-priorities/SKILL.md`, and `skills/703-sg-review/SKILL.md`.
3. `skills/references/skill-code-index.md`, `skill-instruction-layering.md`, `skill-context-budget.md`, `task-registry-routing.md`, `operational-record-format.md`, `question-contract.md`, `reporting-contract.md`, and `chantier-tracking.md`.
4. `skills/010-sg-technical/SKILL.md`, its transfer/reference layout and `tools/test_010_sg_technical_contract.py` as a local compaction/testing pattern; do not copy its technical ownership.
5. Active surfaces discovered by the inventory: operator cheatsheet, runtime lifecycle, code-docs map, plugin pack/public-help catalogs, neighboring references, tools, and tests; check for a current site tree rather than assuming one.

Implementation order is deliberate: inventory current behavior; create the dispatcher; transfer tasks and sessions separately; transfer backlog/priorities/review; prove all five modes; retire old owners; migrate active surfaces; refresh and verify. Never delete a source directory before every matching playbook and scenario proof exists. Never use `git checkout`, `git reset`, broad text replacement, or a directory symlink to simplify migration. Re-read each mutable or source contract immediately before changing it. The static documentation/skill-contract exception applies: no Sentry, build-time header, external-provider consultation, or website build is required unless a current site source tree is discovered.

# Open Questions

None. The operator approved the single métier-first domain and selected this consolidation; the current architecture makes `sessions` a fifth explicit mode, retires the four old skills without aliases, migrates current repository-backed documentation, and preserves `700`, `704`, `705`, `706`, `707`, `308`, `103`, and `104` boundaries. `011` remains the previously approved and still-unused high-frequency entrypoint code.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-07-18 13:48:06 UTC | 100-sg-spec | high-reasoning implementation agent recommended; runtime model override not supported | Inspected the four pilotage contracts, active/public/runtime surfaces, historical predecessor spec and concurrent session-rename diff; wrote the scenario-first consolidation contract. | ready | `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage` |
| 2026-07-18 14:03:18 UTC | 101-sg-ready | gpt-5.5/xhigh recommended; runtime model override not supported | Independently reviewed structure, traceability, dependencies, scenario-first proof, security and owner boundaries, freshness, and language doctrine; normalized the internal contract to English, corrected the public-content schema path, and incorporated transfer of the concurrent bug-proof session test. | ready | `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage` |
| 2026-08-03 23:30:23 UTC | 100-sg-spec | GPT-5 Codex | Re-audited the four pilotage owners, session contract, adjacent 700/704-707 boundaries, current docs/plugin/test surfaces, and prior ready spec; promoted sessions to a fifth explicit mode and removed stale public-site assumptions. | draft repaired; readiness expired by material contract change | `/101-sg-ready consolidate-pilotage-skills-under-sg-pilotage` |
| 2026-08-03 23:38:42 UTC | 101-sg-ready | gpt-5.6-sol/high | Independently reviewed the revised five-mode contract, active source paths, transfer completeness, neighboring ownership, scenario proof, metadata, security, freshness, and language doctrine; declared review/Atlas dependencies and strengthened local-session security and review-artifact proof. | ready | `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage` |

# Current Chantier Flow

| Skill | Status | Notes |
| --- | --- | --- |
| `100-sg-spec` | completed | Existing unimplemented contract repaired in place for five explicit modes and the current repository surface. |
| `101-sg-ready` | ready | Independent readiness review passed for the revised five-mode contract, dependencies, security boundaries, and scenario-first proof. |
| `102-sg-start` | pending | Creates `011`, transfers five mode contracts, proves sessions safeguards, retires sources, and migrates active surfaces after readiness. |
| `900-shipglows-core refresh` | pending | Required after material skill edits. |
| `103-sg-verify` | pending | Twelve scenario-first checks plus runtime, active-document, plugin, and conditional site verification. |
| `104-sg-end` | pending | Closure, tracker and changelog decision. |
| `005-sg-ship` | pending | Separately authorized commit/push only. |

Next step: `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage`.
