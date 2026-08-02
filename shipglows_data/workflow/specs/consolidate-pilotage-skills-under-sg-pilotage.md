---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-18"
created_at: "2026-07-18 13:48:06 UTC"
updated: "2026-07-18"
updated_at: "2026-07-18 14:03:18 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "high-reasoning implementation agent (recommended; runtime model override not supported)"
scope: "skill-taxonomy consolidation and public migration"
owner: "Diane"
user_story: "As a ShipGlows operator, I want one public entrypoint for work management — tasks, backlog, priorities, and review — so that I can choose the right action without navigating four competing skills or losing their domain-specific safeguards."
confidence: high
risk_level: high
security_impact: none
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
  - "tools/test_rename_codex_session.py"
  - "tools/test_bug_proof_fidelity_contract.py"
  - "skills/706-continue/SKILL.md"
  - "skills/308-sg-status/SKILL.md"
  - "shipglows-site/src/content/skills/"
  - "shipglows-site/src/content.config.ts"
  - "plugins/shipglows/assets/pack-catalog.json"
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.5.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
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
    artifact_version: "1.10.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.8.0"
    required_status: draft
  - artifact: "skills/references/task-registry-routing.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md"
    artifact_version: "1.4.1"
    required_status: draft
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.5.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-07-18: consolidate 309-sg-tasks, 701-sg-backlog, 702-sg-priorities, and 703-sg-review into the single public sg-pilotage domain with modes tasks, backlog, priorities, and review."
  - "The four source contracts all declare Process role: pilotage and share local-first tracker, question, reporting, and chantier-trace doctrine."
  - "The current public catalog exposes four separate pages (sg-tasks, sg-backlog, sg-priorities, sg-review), while help, runtime guidance, plugin catalogs, and related-skill metadata still name the four old entrypoints."
  - "skills/309-sg-tasks/SKILL.md, the conversation-session playbook, and tools/test_bug_proof_fidelity_contract.py have active uncommitted missing-status safety coverage; the consolidation must transplant it without overwrite or loss."
next_step: "/102-sg-start consolidate-pilotage-skills-under-sg-pilotage"
---

# Title

Consolidate Pilotage Skills Under sg-pilotage

# Status

ready — the operator selected this chantier, the canonical identity is `011-sg-pilotage`, the four public modes and all material boundaries are explicit, and a fresh implementation agent can proceed without a further product decision.

# User Story

As a ShipGlows operator, I want to invoke `$011-sg-pilotage` with `tasks`, `backlog`, `priorities`, or `review` so that I can manage work state through one public domain without losing Codex-session safety, the backlog/execution split, active prioritization, or evidence-based review.

# Minimal Behavior Contract

`$011-sg-pilotage <mode> [arguments]` accepts exactly one of the four public modes: `tasks`, `backlog`, `priorities`, or `review`. It loads only the selected mode's playbook and then performs the corresponding management action. A bare, unknown, or mixed-action input asks one orientation question among the four modes and mutates no tracker, session, or report. Every write is preceded by an authoritative reread of its target; a missing or invalid session-rename status triggers no session read, derived title, or mutation. The easy-to-miss edge case is converting a simple rename migration into hidden compatibility: after transfer, the four old directories, runtime entries, and public pages are truly removed, with no alias or wrapper.

# Success Behavior

- `$011-sg-pilotage tasks` maintains the local execution tracker and preserves the session subflows (`sessions`, `sessions rename <status>`, `sessions prune`, and `name-conversation`) with their exact safeguards.
- `$011-sg-pilotage backlog` captures, defers, cleans up, or promotes items in the local backlog without pretending to rank active tasks.
- `$011-sg-pilotage priorities` ranks active tasks by impact, effort, blockers, dependencies, and risk, then proposes the next work without executing it.
- `$011-sg-pilotage review` reconstructs an evidence-based summary, distinguishes implemented, verified, and assumed states, and performs only justified tracker or changelog writes.
- Operators and agents find one public `sg-pilotage` page, one README, and one index entry that explain the four modes and their limits without losing routes to neighboring owners.
- After runtime sync, the visible skill is `011-sg-pilotage`; none of the four old identities remains installed as a selectable skill.

# Error Behavior

- Missing, unknown, or multiple modes: explain the four choices and request one mode; do not select the last-used mode or load a substantive playbook.
- Missing tracker target or an anchor that remains ambiguous after reread and recompute: write nothing; request the smallest missing context or create only the file explicitly authorized by the playbook.
- A request to continue a chantier, modify code, verify or close an implementation, or only report status: route respectively to `706-continue`, the execution owner, `103-sg-verify`/`104-sg-end`, or `308-sg-status` without silently expanding `sg-pilotage`.
- `tasks sessions rename` without a supported status: ask for exactly one of `todo`, `doing`, `in_progress`, `blocked`, or `done`; do not inspect other threads, call the helper, derive a title, or touch `TASKS.md`.
- A write, backlog deletion, session prune, or task promotion without the proof or confirmation required by the playbook: stop with an explicit recoverable result; never improvise SQL, deletion, or a broad rewrite.

# Problem

Work management is split across four public skills that share one domain, the same local sources, and many safeguards. This fragmentation increases discovery cost, disperses documentation, and creates permanent cross-calls (`tasks` to `backlog`, `priorities`, and `review`, and vice versa). It also retains 858 lines of activated contracts in several places, while the compaction pattern favors a short dispatcher and playbooks loaded after selection. The public page, plugin catalogs, and help extend this split instead of presenting the operator's decision: which management action is needed now.

# Solution

Create `skills/011-sg-pilotage/` as the sole runtime and public identity for this domain. Its `SKILL.md` remains a compact activation contract: mission, strict grammar, a four-mode lazy-loading map, boundaries, stop conditions, trace, and validation. Four local playbooks receive the transferred procedures: tasks/sessions, backlog, priorities, and review. An atomic migration transfers behavior, incorporates the active session-safety hunk, updates active surfaces, and then removes the four old directories and pages rather than disguising them as aliases.

Code `011` is the next available identity in the `000-099` band, reserved for frequent high-level entrypoints. It is therefore stable, memorable, and consistent with the cross-cutting nature of `sg-pilotage`; it is neither a renumbering of the modes nor a fifth skill family.

# Scope In

- Create `skills/011-sg-pilotage/SKILL.md`, `README.md`, and four local playbooks with compliant frontmatter.
- Transfer the contracts of `309-sg-tasks`, `701-sg-backlog`, `702-sg-priorities`, and `703-sg-review` completely and verifiably into the four public modes.
- Integrate the active `sessions rename <status>` safety hunk without overwrite, and preserve its tests and shared playbook.
- Actually remove the four old skill directories, with no mirror directory, runtime alias, compatibility symlink, wrapper, or old index entry.
- Update the code index, runtime sync, help, operator guides, plugin catalogs, README/public page, related links, and active contract tests.
- Replace the four public pages with one `sg-pilotage` page that exposes the four modes clearly for the operator without exposing internal playbook details.
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

- The sole canonical invocation is `$011-sg-pilotage`; its public modes are exactly `tasks`, `backlog`, `priorities`, and `review`. `help` is not a fifth mode: an invalid input response describes the four choices without side effects.
- Never infer a mode from the preceding conversation, a filename, or tracker proximity; resolve ambiguity with one choice-oriented question.
- Load exactly one substantive playbook for an explicit mode; an invalid input loads no working playbook.
- Historical task subcommands remain under `tasks`: `sessions`, `sessions rename <status>`, `sessions prune`, and `name-conversation`. They are not additional `sg-pilotage` modes.
- Activation bodies must remain below `skill-context-budget` thresholds; procedures, matrices, examples, and variants belong in local or shared references without doctrine duplication.
- All internal contracts remain in English; each new operator-visible surface remains in the active language, using natural French and accents when French is active.
- `fresh-docs not needed`: this chantier depends on no provider, SDK, framework, or external behavior; it moves only local contracts, files, and routes.
- The recommended model is `gpt-5.5/xhigh`; its application status is `not supported by runtime`. The execution report must name the model actually available without claiming the recommendation was applied.
- The worktree contains unrelated changes. The active session-rename status diff in `skills/309-sg-tasks/SKILL.md`, its shared playbook, its spec, `tools/test_rename_codex_session.py`, and `tools/test_bug_proof_fidelity_contract.py` is a concurrent flow: implementation must reread it immediately before transfer, integrate it into `tasks`, and never restore, overwrite, or lose it when removing the source directory.

# Test Contract

- Surface: skill activation contract, local playbooks, tracker/backlog mutations, Codex session, index/runtime, help, public catalog, and concurrent session-safety tests.
- proof_profile: `scenario-first` + targeted deterministic Python test + fresh boundary review + mechanical runtime/document validation.
- proof_order: active/historical inventory and concurrent diff -> isolated dispatcher scenarios -> selected-playbook scenarios -> contract test -> lint/index/budget/sync -> public build when public content changes -> independent boundary and diff review.
- required_scenario_ids: `PILOTAGE-EXACT-MODE`, `PILOTAGE-AMBIGUOUS-NO-WRITE`, `PILOTAGE-TASKS-SESSION-STATUS-GATE`, `PILOTAGE-BACKLOG-NOT-PRIORITY`, `PILOTAGE-PRIORITIES-NOT-EXECUTION`, `PILOTAGE-REVIEW-NOT-VERIFY`, `PILOTAGE-BOUNDARY-CONTINUE-STATUS`, `PILOTAGE-LOCAL-TRACKER-SAFETY`, `PILOTAGE-NO-LEGACY-RUNTIME`, `PILOTAGE-PUBLIC-MIGRATION`.
- required_results: every required scenario and the targeted test pass; metadata lint, budget audit, runtime sync, active/historical scan, and `git diff --check` exit `0`; the Astro build passes because the public page changes; every pre-existing global failure is distinguished from a regression attributable to `011-sg-pilotage`.
- Automated proof available: `tools/test_011_sg_pilotage_contract.py`, `tools/test_rename_codex_session.py`, `tools/test_bug_proof_fidelity_contract.py`, metadata lint, `skill_budget_audit.py`, `skill_code_index_lint.py`, sync check, `rg` scans, `git diff --check`, and the Astro build.
- Manual proof required: read the dispatcher alone, then each of the four playbooks alone, and decide whether a fresh agent can select the correct action without absorbing another domain; manually review preservation of the concurrent hunk before retiring `309-sg-tasks`.
- exception_with_proof: a global linter that fails only on the pre-existing `sf-*`/`shipglows` runtime debt must be archived with complete output and a targeted scan proving that no error concerns `011-sg-pilotage` or the four retired directories; it cannot mask a migration error.
- exception_without_proof: none.

## Required Scenarios

| ID | Given | When | Then |
| --- | --- | --- | --- |
| `PILOTAGE-EXACT-MODE` | `$011-sg-pilotage priorities high-roi` | the dispatcher is read alone | it recognizes `priorities`, loads only the priorities playbook, and does not mix tasks, backlog, or review procedures. |
| `PILOTAGE-AMBIGUOUS-NO-WRITE` | a bare, unknown, or “organise everything” input | the dispatcher receives the request | it proposes exactly the four modes and neither reads nor writes a tracker, session, backlog, changelog, or report. |
| `PILOTAGE-TASKS-SESSION-STATUS-GATE` | `tasks sessions rename` with no supported status | `tasks` mode is selected | it asks for exactly one allowed status without deriving a title, reading other sessions, calling a helper, or mutating Codex/TASKS. |
| `PILOTAGE-BACKLOG-NOT-PRIORITY` | an idea to defer | `backlog defer` | the playbook moves it only according to backlog rules and makes the later priorities route explicit; it does not calculate a hidden P0. |
| `PILOTAGE-PRIORITIES-NOT-EXECUTION` | credible active tasks | `priorities blockers` | the playbook ranks and recommends the next target, then routes to `706-continue` or `102-sg-start`; it does not execute the target. |
| `PILOTAGE-REVIEW-NOT-VERIFY` | a week of commits without complete functional proof | `review weekly` | the summary distinguishes activity, implementation, and verification; it does not declare the product validated or replace `103-sg-verify`. |
| `PILOTAGE-BOUNDARY-CONTINUE-STATUS` | operator prompts “continue this chantier” then “what is the status?” | the dispatcher is evaluated | the two requests route respectively to `706-continue` and `308-sg-status`; no new mode absorbs them. |
| `PILOTAGE-LOCAL-TRACKER-SAFETY` | a local tracker whose anchor changes between snapshot and write | a mutating playbook wants to write | it rereads, recomputes once, then blocks or asks if the anchor remains ambiguous; it never rewrites the complete file from memory. |
| `PILOTAGE-NO-LEGACY-RUNTIME` | the migration is complete and sync has run | Codex/Claude resolve skills | `011-sg-pilotage` is the only installed management source; `skills/309-sg-tasks`, `701-sg-backlog`, `702-sg-priorities`, `703-sg-review`, and their runtime links no longer exist. |
| `PILOTAGE-PUBLIC-MIGRATION` | the operator consults the skills page, help, or a plugin catalog | the migration is delivered | they find `sg-pilotage` and its four modes; no active surface presents old names as available commands, while historical archives remain intact. |

# Dependencies

- `skills/references/skill-code-index.md`: runtime name, code band, uniqueness, and index validation; `011` must be added as `sg-pilotage` in the master/high-frequency family.
- `skills/references/skill-instruction-layering.md` and `skills/references/skill-context-budget.md`: dispatcher boundary and contract/playbook allocation.
- `skills/references/question-contract.md`, `reporting-contract.md`, `chantier-tracking.md`, `operational-record-format.md`, and `task-registry-routing.md`: questions, trace, reports, minimal writes, and the editorial/execution split to preserve without divergent copy.
- `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/rename_codex_session.py`, and `tools/test_bug_proof_fidelity_contract.py`: source of truth and concurrent proof for the session flow transferred to `tasks`; their active hunk and active test target are concurrent dependencies to integrate.
- `skills/706-continue/SKILL.md` and `skills/308-sg-status/SKILL.md`: active boundaries that do not change.
- `shipglows-site/src/content.config.ts`: public-content schema. No external documentation is required.

# Invariants

- `011-sg-pilotage` is the sole runtime/public owner of tasks, backlog, priorities, and review; it keeps no second hidden identity.
- The four modes retain distinct outcomes: tracker/sessions, backlog, active work order, and evidence-based summary. Consolidation does not permit a catch-all mode.
- Trackers remain local first; an explicit portfolio state is a derived view, never a return to a central master tracker.
- The `TASKS` / `ROADMAP` route remains compliant with `task-registry-routing`; mixed discoveries split rather than becoming ambiguous records.
- Codex sessions are filtered by exact absolute `cwd`; the current thread, other threads, and task records retain their current boundaries.
- `done` is never inferred from a final message, commit, build, or review alone.
- `706-continue` executes current work; `308-sg-status` reads state; `103-sg-verify` decides conformity proof; and `104-sg-end` closes. `011` routes to them but does not replace them.
- References to old names in archives, closed specs, audits, or changelog remain historical provenance and are not modified by global replacement.
- No secret, private conversation content, token, cookie, or SQLite database reaches the playbooks, public docs, tests, or migration reports.

# Links & Consequences

- References to the four skills currently occur in four public pages, the mode catalog, `related_skills` metadata, `help-catalog`, the operator cheatsheet, `skill-runtime-and-lifecycle`, `skill-code-index`, the JSON/Markdown plugin catalog, READMEs, and neighboring contracts. They must be classified as active, generated, or historical before modification.
- `shipglows-site/src/content/skills/sg-tasks.md` also carries the public promise for session subflows; removing it without transfer would make the rename flow undiscoverable. The new page must expose `tasks` and its safe subcommands without promising an automatic mutation.
- The `sg-resume`, `sg-veille`, `sg-changelog`, `sg-end`, `sg-status`, and `sg-maintain` pages, plus every active page found by inventory, must point to `sg-pilotage <mode>` only when they recommend one of the four actions; other relations must not change reflexively.
- The plugin pack that lists `309`, `701`, `702`, and `703` must present `011-sg-pilotage` only once in the matching pack; no pack retains a retired skill name.
- The design, content, marketing, technical, customer, and veille migrations show the required convention: a compact public dispatcher, local playbooks, a deterministic test, and a migrated public page. They do not authorize rewrites of their historical references.

# Documentation Coherence

## Documentation Update Plan

- Replace the four removed READMEs with `skills/011-sg-pilotage/README.md`, including exact grammar, a four-mode table, `tasks` subflows, and neighboring owner boundaries.
- Update `skills/references/skill-code-index.md`, `skills/302-sg-help/references/help-catalog.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, the `plugins/shipglows/**` catalogs, and only the active neighboring contracts found by inventory.
- Replace the four public content pages `sg-tasks.md`, `sg-backlog.md`, `sg-priorities.md`, and `sg-review.md` with `shipglows-site/src/content/skills/sg-pilotage.md`. The page clearly names the four capabilities as modes and gives `$011-sg-pilotage <mode>` prompts, with no route, redirect, or alias that reintroduces old names.
- Adjust the mode catalog and active `related_skills` so discovery presents `sg-pilotage` and the relevant mode. Do not modify `CHANGELOG.md`, historical ROADMAP, closed specs, audits, or transcripts merely to remove a historical occurrence.
- Add a clear migration entry to CHANGELOG/refresh log following their active formats so that documentation is migrated rather than merely removed.

## Editorial Update Plan

- `checked`: this chantier modifies public tool documentation, not client-project content or a product editorial surface. The public skills page is the sole editorial surface affected.
- The new page must remain operator-oriented: choice of action, observable result, limits, and neighboring routes; it publishes neither internal session doctrine nor persistence details.
- `fresh-docs not needed`: no external claim, provider, platform, or SEO behavior with changing dependencies is introduced. The Astro build checks local content coherence after the update.

# Edge Cases

- An operator enters `$011-sg-pilotage sessions`: because the mode is missing, the dispatcher asks for `tasks`, `backlog`, `priorities`, or `review`; it does not assume `tasks` despite the recognized word.
- An operator enters `$011-sg-pilotage tasks sessions rename done`: the exact subflow remains valid and is limited to the current thread in the exact `cwd`.
- A request combines “add the idea, prioritize it, and start”: ask which mode to perform now, apply at most one action, and then send explicitly selected execution to `706`/`102`.
- A backlog being cleaned contains items to remove: retain the confirmation prompt and the Discarded section; no direct deletion hides in a migration mode.
- A review reveals an active task without a priority decision: it can record that fact honestly and propose `priorities`; it does not create an implicit ranking.
- An old link is found in a closed spec, dated audit, or transcript: retain it as evidence; the test inspects only the declared active inventory.
- The code-index linter continues to report old out-of-scope `sf-*`/`shipglows` identities: document that debt as a separate baseline, then prove no line concerns `011` or the four retired owners.
- No source has an `agents/openai.yaml` file: do not invent a manifest. If implementation creates one for `011`, its display name must equal `011-sg-pilotage` exactly and it joins runtime checks.
- The concurrent rename change evolves during the chantier: perform a logical rebase by reading the current diff before extraction; if its guarantees conflict with the planned `tasks` mode, stop the transfer slice and report the conflict rather than choosing a rule. Before retiring `309`, move the explicit `tools/test_bug_proof_fidelity_contract.py` target to the transferred `011` `tasks` contract and preserve its missing-status assertions.

# Implementation Tasks

- [ ] Task 1: Freeze the active/historical inventory and protect the concurrent hunk.
  - Files: `skills/309-sg-tasks/SKILL.md`, `skills/701-sg-backlog/SKILL.md`, `skills/702-sg-priorities/SKILL.md`, `skills/703-sg-review/SKILL.md`, their READMEs, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/test_rename_codex_session.py`, `tools/test_bug_proof_fidelity_contract.py`, and all `rg` hits in active public/help/runtime/plugin surfaces.
  - Action: Classify each hit as active, generated/runtime, compatibility, concurrent, or historical. Re-read the current 309/session diff immediately before changing it; record its missing-status guarantee and the bug-proof test's `309` path assertion as mandatory transfer content.
  - User story link: Prevents a smaller picker from losing behavior or falsifying historical provenance.
  - Depends on: None.
  - Validate with: saved implementation evidence from `git diff -- ...` plus scoped `rg -n -i "309-sg-tasks|701-sg-backlog|702-sg-priorities|703-sg-review|sg-tasks|sg-backlog|sg-priorities|sg-review"` across active paths; confirm the bug-proof contract's current source path before mutation. No mutation occurs in this task.
  - Notes: Do not modify the historical `pilotage-skills-governance-alignment.md` spec.

- [ ] Task 2: Establish the canonical `011-sg-pilotage` activation contract.
  - Files: `skills/011-sg-pilotage/SKILL.md`, `skills/011-sg-pilotage/README.md`.
  - Action: Create a compact English dispatcher with `name: 011-sg-pilotage`, a concise discovery description, exact grammar `tasks|backlog|priorities|review`, one-playbook lazy map, bare/invalid/multi-mode stop behavior, trace/report loaders, local-first/write-safety boundaries, owner reroutes, and validation commands. State that `tasks` alone owns the preserved session subcommands.
  - User story link: Gives the operator one discoverable, unambiguous entrypoint.
  - Depends on: Task 1.
  - Validate with: focused `rg` for all four modes, all adjacent owners, no fifth public mode, line/token budget audit, and deterministic dispatcher assertions.
  - Notes: The activation body contains no copied procedure matrices and no old runtime identity as alias.

- [ ] Task 3: Transfer `tasks` and sessions into one local playbook.
  - Files: `skills/011-sg-pilotage/references/tasks-and-sessions-playbook.md`, `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`, `tools/test_rename_codex_session.py`, and `tools/test_bug_proof_fidelity_contract.py` only where their ownership text or target paths need the new canonical name.
  - Action: Transfer tracker maintenance, local/legacy distinction, editorial routing, target reread/minimal patch protocol, session scope/title/duplicate/inactivity/prune rules, and every missing-status safeguard from the active hunk. Preserve the helper contract, exact status vocabulary, and the bug-proof test's missing-status assertions by moving its source path to the transferred `tasks` contract.
  - User story link: Keeps the highest-risk pilotage behavior available only after `tasks` is selected.
  - Depends on: Task 2.
  - Validate with: `PILOTAGE-TASKS-SESSION-STATUS-GATE`, `tools/test_rename_codex_session.py`, `tools/test_bug_proof_fidelity_contract.py`, targeted pressure-anchor scan, and manual comparison against the current source plus concurrent diff.
  - Notes: Do not delete `309-sg-tasks` until this transfer and proof are complete.

- [ ] Task 4: Transfer backlog, priorities, and review into three local playbooks.
  - Files: `skills/011-sg-pilotage/references/backlog-playbook.md`, `skills/011-sg-pilotage/references/priorities-playbook.md`, `skills/011-sg-pilotage/references/review-playbook.md`.
  - Action: Move each source’s operational model, input grammar, question gates, tracker safety, report mode, boundaries, confirmation requirements and evidence distinctions into its named playbook. Link shared doctrine instead of duplicating it.
  - User story link: Preserves specialised outcomes while removing four discovery entries.
  - Depends on: Task 2.
  - Validate with: each selected playbook satisfies its scenario (`BACKLOG-NOT-PRIORITY`, `PRIORITIES-NOT-EXECUTION`, `REVIEW-NOT-VERIFY`) and has no unrelated source mode copied into its dispatcher path.
  - Notes: `review` must retain its explicit distinction between activity evidence and verified product outcome.

- [ ] Task 5: Add deterministic migration and boundary proof.
  - Files: `tools/test_011_sg_pilotage_contract.py` and any narrowly necessary existing test fixture.
  - Action: Follow `tools/test_010_sg_technical_contract.py` conventions to assert exact public grammar, one playbook per mode, source-behavior markers, `706`/`308`/`103` boundaries, session missing-status protections, code-index row, active public migration, and absence of the four retired directories after the migration.
  - User story link: Makes future drift back to multiple public pilotage skills mechanically visible.
  - Depends on: Tasks 2-4.
  - Validate with: `python3 -m unittest tools.test_011_sg_pilotage_contract tools.test_rename_codex_session tools.test_bug_proof_fidelity_contract`.
  - Notes: The test may whitelist historical evidence; it must never demand a repository-wide literal-name purge.

- [ ] Task 6: Retire the four source skills only after successful transfer proof.
  - Files: remove `skills/309-sg-tasks/`, `skills/701-sg-backlog/`, `skills/702-sg-priorities/`, `skills/703-sg-review/` through a reviewed patch.
  - Action: Delete their `SKILL.md` and README surfaces after Tasks 3-5 pass. Do not leave redirect directories, wrapper skills, compatibility symlinks, hidden aliases, stale `agents/openai.yaml`, or code-index entries.
  - User story link: Actually reduces the number of selectable skills and removes picker ambiguity.
  - Depends on: Task 5.
  - Validate with: `test ! -e` checks for all four paths, targeted runtime-link inventory, `tools/shipglows_sync_skills.sh --check --skill 011-sg-pilotage`, and contract test.
  - Notes: Preserve historical references outside those source directories.

- [ ] Task 7: Migrate active runtime, help, plugin, and public documentation surfaces.
  - Files: `skills/references/skill-code-index.md`, `skills/302-sg-help/references/help-catalog.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `plugins/shipglows/assets/pack-catalog.json`, `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, `shipglows-site/src/content/skills/sg-pilotage.md`, the four retired public content pages, `shipglows-site/src/pages/skill-modes.astro`, and active `related_skills` surfaces discovered in Task 1.
  - Action: Add the canonical `011` index row; replace active old entries with one `sg-pilotage` entry and mode-aware prompts; delete the four old public pages only after the new page explains their migration. Update pack membership once, then update every active cross-link that would otherwise advertise an unavailable command.
  - User story link: Public and runtime discovery promise the same route as the installed skill.
  - Depends on: Tasks 2-6.
  - Validate with: scoped active-reference scan, JSON parse of pack catalog, content-schema/build checks, `pnpm --dir shipglows-site build`, and contract test.
  - Notes: Keep historical CHANGELOG/ROADMAP/spec/audit hits unless they are active route instructions.

- [ ] Task 8: Refresh, verify, close, and ship through the normal lifecycle.
  - Files: `skills/REFRESH_LOG.md`, `shipglows_data/workflow/TASKS.md`, this spec, `CHANGELOG.md` when closure determines a user-visible entry.
  - Action: Run `900-shipglows-core refresh 011-sg-pilotage` after material edits; record fresh-docs verdict, docs/editorial result, runtime/reload state and active/historical scan. Then run `103`, `104`, and `005` only at their proper gates.
  - User story link: Ensures the reduction stays coherent after implementation rather than merely compiling.
  - Depends on: Tasks 1-7.
  - Validate with: refresh log block, `103` scenario-first report, closure tracker/changelog evidence where applicable, and a ship report that separates unrelated dirty files.
  - Notes: Commit/push remains separately authorized.

# Acceptance Criteria

- [ ] AC 1: Given an operator sees the installed skill list, when they search pilotage work, then exactly one public runtime skill `011-sg-pilotage` represents tasks, backlog, priorities and review.
- [ ] AC 2: Given `tasks`, `backlog`, `priorities`, or `review` is explicit, when the dispatcher resolves it, then it loads only the matching playbook and preserves the corresponding source contract.
- [ ] AC 3: Given mode selection is absent, unknown or combined, when `$011-sg-pilotage` runs, then it asks one orientation question and produces no tracker, session, backlog, review or changelog mutation.
- [ ] AC 4: Given `tasks sessions rename` has no supported status, when it runs, then it performs no rename-related read or mutation and asks exactly one allowed status question.
- [ ] AC 5: Given an idea, active ranking request, retrospective review, continuation request or read-only status request, when routed, then only the correct mode/owner receives it and `706-continue` plus `308-sg-status` remain independent.
- [ ] AC 6: Given the migration is complete, when source directory and runtime inventories run, then no retired 309/701/702/703 directory, index row, runtime link, alias or wrapper is selectable.
- [ ] AC 7: Given a public/help/plugin/operator-doc surface is active, when it presents this domain, then it names `sg-pilotage`, exposes the four modes, and does not present the four former skills as available commands.
- [ ] AC 8: Given an old name appears only in a historical artifact, when active docs are aligned, then that provenance remains intact and does not fail the migration’s stale-route check.
- [ ] AC 9: Given all scoped changes are present, when focused tests, metadata lint, budget audit, code-index audit, runtime sync, public build and diff hygiene run, then they pass or a proven unrelated baseline is reported separately.
- [ ] AC 10: Given the active 309 missing-status hunk existed before implementation, when 309 is retired, then its safety promise, playbook anchor and deterministic proof remain reachable through `011-sg-pilotage tasks`.

# Test Strategy

1. Run the ten required scenarios against the dispatcher and then against only the selected playbook; do not award a scenario merely because another mode still contains the rule.
2. Run `python3 -m unittest tools.test_011_sg_pilotage_contract tools.test_rename_codex_session tools.test_bug_proof_fidelity_contract` after creation and again after retirement/docs migration.
3. Run `python3 tools/shipglows_metadata_lint.py skills/011-sg-pilotage shipglows_data/workflow/specs/consolidate-pilotage-skills-under-sg-pilotage.md` and include every newly added governed Markdown file if the linter invocation requires explicit paths.
4. Run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; record total skill-count reduction of three and confirm the dispatcher/playbooks meet their local budgets.
5. Run `python3 tools/skill_code_index_lint.py`; resolve any 011/retired-owner error. If only the known global `sf-*`/`shipglows` runtime debt remains, retain the exact output as an exception-with-proof rather than treating it as a pilotage success.
6. Run `tools/shipglows_sync_skills.sh --check --skill 011-sg-pilotage` and `tools/shipglows_sync_skills.sh --check --all`; inspect the runtime targets for the four old names and repair only migration-attributable links.
7. Run active-only `rg` scans across `skills`, `shipglows-site`, `plugins`, `README.md`, active technical guides and routing docs. Classify history separately and check `git diff --check`.
8. Validate JSON with `python3 -m json.tool plugins/shipglows/assets/pack-catalog.json >/dev/null`, then run `pnpm --dir shipglows-site build` because public skill content and mode catalog change.
9. Perform an adversarial review: try to make a fresh agent treat pilotage as execution, status, verification, ideation, global tracker rewrite or raw session cleanup; any plausible ambiguity returns to the dispatcher/selected playbook rather than adding a mode.

# Risks

- High: retiring `309` drops a recently hardened session guard. Mitigation: re-read the concurrent diff immediately before transfer; make its no-status behavior a deterministic test and acceptance criterion before removal.
- High: consolidation creates a broad pilotage catch-all that steals `706`, `308`, `103` or editorial ownership. Mitigation: exact four-mode grammar, explicit boundary matrix, scenario proof and dispatcher-only review.
- High: runtime/docs migration leaves old aliases selectable or public links dead. Mitigation: actual-directory removal, code-index/sync checks, active-surface inventory and Astro build.
- Medium: operational procedures become unreadable when copied into the dispatcher. Mitigation: one bounded playbook per explicit mode and budget audits.
- Medium: broad stale-name replacement rewrites historical evidence. Mitigation: active/historical classification before edits and a targeted test allowlist.
- Medium: concurrent dirty work is accidentally committed or overwritten. Mitigation: preserve it as an explicit transfer dependency, inspect diff before each overlapping edit, and report it separately at ship.
- Low: public visitors no longer recognise the retired vocabulary. Mitigation: a single migration-oriented public page describes the four former outcomes as modes, while no old invocation alias remains.

# Execution Notes

Read first, in order:

1. `skills/309-sg-tasks/SKILL.md` plus its current diff and `shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`.
2. `skills/701-sg-backlog/SKILL.md`, `skills/702-sg-priorities/SKILL.md`, and `skills/703-sg-review/SKILL.md`.
3. `skills/references/skill-code-index.md`, `skill-instruction-layering.md`, `skill-context-budget.md`, `task-registry-routing.md`, `operational-record-format.md`, `question-contract.md`, `reporting-contract.md`, and `chantier-tracking.md`.
4. `skills/010-sg-technical/SKILL.md`, its transfer/reference layout and `tools/test_010_sg_technical_contract.py` as a local compaction/testing pattern; do not copy its technical ownership.
5. Active surfaces discovered by the inventory: `help-catalog`, operator cheatsheet, runtime lifecycle, plugin catalogs, current public skill content and `skill-modes.astro`.

Implementation order is deliberate: inventory and protect concurrent behavior; create the new owner; transfer all four behaviors; test transfer; retire old owners; migrate active surfaces; refresh and verify. Never delete a source directory before the matching playbook and scenario proof exist. Never use `git checkout`, `git reset`, broad text replacement or a directory symlink to simplify migration. Re-read a tracker or concurrent file immediately before changing it. The static documentation/skill-contract exception applies: no Sentry, build-time header or external-provider consultation is required.

# Open Questions

None. The operator approved the single public domain, its four modes, real retirement of the four old skills, public documentation migration, and preservation of `706-continue` plus `308-sg-status` boundaries. `011` is allocated by the existing code-index band rule as the next free high-frequency entrypoint code.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-07-18 13:48:06 UTC | 100-sg-spec | high-reasoning implementation agent recommended; runtime model override not supported | Inspected the four pilotage contracts, active/public/runtime surfaces, historical predecessor spec and concurrent session-rename diff; wrote the scenario-first consolidation contract. | ready | `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage` |
| 2026-07-18 14:03:18 UTC | 101-sg-ready | gpt-5.5/xhigh recommended; runtime model override not supported | Independently reviewed structure, traceability, dependencies, scenario-first proof, security and owner boundaries, freshness, and language doctrine; normalized the internal contract to English, corrected the public-content schema path, and incorporated transfer of the concurrent bug-proof session test. | ready | `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage` |

# Current Chantier Flow

| Skill | Status | Notes |
| --- | --- | --- |
| `100-sg-spec` | ready | Full consolidation contract created from explicit operator approval. |
| `101-sg-ready` | ready | Independent readiness review passed; the internal contract, dependency metadata, concurrent proof transfer, and scenario-first boundaries are explicit. |
| `102-sg-start` | pending | Creates `011`, transfers contract, protects concurrent session hunk, retires sources and migrates surfaces. |
| `900-shipglows-core refresh` | pending | Required after material skill edits. |
| `103-sg-verify` | pending | Scenario-first, runtime, active-document and public-build verification. |
| `104-sg-end` | pending | Closure, tracker and changelog decision. |
| `005-sg-ship` | pending | Separately authorized commit/push only. |

Next step: `/102-sg-start consolidate-pilotage-skills-under-sg-pilotage`.
