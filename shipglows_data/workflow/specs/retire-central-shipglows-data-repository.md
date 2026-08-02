---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlows"
created: "2026-05-25"
created_at: "2026-05-25 14:51:37 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:36:35 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "migration"
owner: "Diane"
user_story: "En tant qu'utilisatrice ShipGlows, je veux supprimer totalement le repo central ~/shipglows_data après inventaire et migration sans perte, afin que chaque projet reste sa seule source de vérité et que les skills/TUI ne réintroduisent plus un corpus global redondant."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "install.sh"
  - "lib.sh"
  - "README.md"
  - "shipglows_data/technical/metadata-migration-guide.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "skills/references/canonical-paths.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/sg-init/references/bootstrap-workflow.md"
  - "skills/sg-status/SKILL.md"
  - "skills/sg-tasks/SKILL.md"
  - "skills/sg-backlog/SKILL.md"
  - "skills/sg-priorities/SKILL.md"
  - "skills/sg-review/SKILL.md"
  - "skills/400-sg-audit/"
  - "skills/010-sg-technical/references/technical-audit-playbook.md"
  - "skills/010-sg-technical/references/dependency-audit-playbook.md"
  - "skills/010-sg-technical/references/performance-audit-playbook.md"
  - "skills/sg-help/references/help-catalog.md"
  - "tui/src/main.ts"
  - "tui/src/sources/readers.ts"
  - "tui/README.md"
  - "/home/claude/shipglows_data"
  - "project-local shipglows_data/"
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "shipglows_data/workflow/specs/shipglows-data-project-umbrella-documentation-architecture.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Operator decision 2026-05-25: the original reason for the central repo was to give the terminal UI a single source of truth, but it is now more practical to discover project folders and read each project's local shipglows_data."
  - "Operator decision 2026-05-25: target state is total removal of the central ~/shipglows_data repo, not a reduced active control-plane repo."
  - "Operator constraint 2026-05-25: before deletion, verify whether central files must be migrated or merged so useful history, future tasks, or project data are not lost."
  - "Operator constraint 2026-05-25: skills must be changed so they no longer mention or depend on the central concept."
  - "Local inspection 2026-05-25: /home/claude/shipglows_data contains root legacy docs, PROJECTS.md, TASKS.md, AUDIT_LOG.md, OPERATIONS_LOG.md, DEPENDENCY_LOG.md, specs/master-auth-playbook.md, migrations/, and projects/* tracker folders."
  - "Local inspection 2026-05-25: /home/claude/shipglows_data has uncommitted changes in AUDIT_LOG.md, TASKS.md, projects/winflowz/TASKS.md, and projects/winflowz docs."
  - "Local inspection 2026-05-25: ShipGlows code and docs still contain many SHIPGLOWS_DATA_DIR, ~/shipglows_data, PROJECTS.md, master TASKS/AUDIT, and control-plane references."
  - "Local inspection 2026-05-25: tui/src/main.ts hardcodes /home/claude/shipglows_data and tui/src/sources/readers.ts reads central PROJECTS.md, TASKS.md, AUDIT_LOG.md, OPERATIONS_LOG.md, and DEPENDENCY_LOG.md."
  - "Operator constraint 2026-05-25: implementation should not require many manual relaunches; one /sg-start run should continue through sequential phases as far as safely possible, stopping only for conflicts, destructive confirmation, or genuine blockers."
next_step: "/sg-start retire-central-shipglows-data-repository"
---

# Title

Retire Central ShipGlows Data Repository

# Status

Ready.

# User Story

En tant qu'utilisatrice ShipGlows, je veux supprimer totalement le repo central `~/shipglows_data` après inventaire et migration sans perte, afin que chaque projet reste sa seule source de vérité et que les skills/TUI ne réintroduisent plus un corpus global redondant.

# Minimal Behavior Contract

ShipGlows must stop treating `~/shipglows_data` or `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` as an active repo, registry, tracker, dashboard, project data corpus, or source of truth. Before the central repo is removed, ShipGlows inventories every central file, classifies each item as duplicate, project-local migration, ShipGlows-local archive, conflict, or safe deletion, and moves or archives useful unique information into the owning project's local `shipglows_data/` or ShipGlows's own `shipglows_data/`. If any file cannot be mapped safely, implementation stops with a conflict report instead of deleting. After retirement, skills, CLI, installer, docs, and TUI discover and read project-local corpora directly; derived caches are allowed only as disposable performance artifacts and must never become a second persistent truth.

# Success Behavior

- Given a project has a local `shipglows_data/`, when a skill needs project business, technical, editorial, workflow, spec, bug, audit, task, or review context, then it reads that project-local corpus and does not fall back to `~/shipglows_data`.
- Given the TUI opens from ShipGlows or a project, when it needs a portfolio view, then it discovers project roots by scanning configured workspace roots and/or the current project tree for local `shipglows_data/` folders, derives any cache from those folders, and shows diagnostics when a project cannot be read.
- Given global audit-like workflows need project selection, when they run in workspace mode, then they discover projects from local project folders and infer or ask for domain applicability from project-local evidence instead of reading a central `PROJECTS.md` matrix.
- Given `~/shipglows_data` contains a unique task, runbook, decision, spec, or historical note, when the migration runs, then that content lands in the owning project corpus or ShipGlows archive with an inventory entry linking original path to destination.
- Given `~/shipglows_data` contains duplicate or obsolete content, when the migration runs, then it records the duplicate/obsolete verdict and does not create a second active copy.
- Given the operator launches `/sg-start retire-central-shipglows-data-repository`, when no migration conflict, destructive deletion step, or validation blocker occurs, then the implementation continues through the ordered tasks in one sequential execution instead of requiring a separate user relaunch per task.
- Given all code/docs are updated, when `rg` searches for central data concepts, then remaining matches are limited to migration archives, historical bug/spec references, or explicit compatibility notes marked as legacy.
- Given migration and validation pass, when the central repo is removed from the root, then ShipGlows startup, selected skills, TUI tests, and metadata validation pass without recreating it.

# Error Behavior

- If a central file has no clear owner, divergent content, unresolved dirty changes, or possible unique project value, stop before deletion and write a conflict entry in the retirement report.
- If a project path from the old registry no longer exists, preserve the central content under ShipGlows's retirement archive and mark the owning project as unresolved instead of dropping the file.
- If a skill or installer path would recreate `~/shipglows_data`, validation fails and the implementation must update that path before deletion.
- If TUI discovery scans an unreadable, huge, symlink-escaped, or untrusted directory, it must skip with redacted diagnostics and continue with readable project corpora.
- If global project discovery finds multiple project roots with the same normalized name, it must keep both distinguishable by path and report a duplicate-name diagnostic instead of merging their data.
- If destructive deletion is requested before the no-loss inventory and migration report pass, the run is blocked.
- If implementation reaches the final destructive removal step, stop for explicit confirmation unless the operator has already authorized that exact destructive action in the active run.

# Problem

The central `~/shipglows_data` repo originally existed to give the terminal UI and cross-project workflows a single place to read project state. That design now conflicts with the project-local governance doctrine. The current system has three overlapping truths: each project has `shipglows_data/`, ShipGlows itself has `shipglows/shipglows_data/`, and the root-level `~/shipglows_data` repo still holds registries, trackers, project subfolders, logs, legacy docs, and some dirty changes. This creates noisy root state, duplicate mental models, non-portable assumptions, and a risk that skills write future work into the wrong location.

# Solution

Retire `~/shipglows_data` completely. Treat it as a migration source only, not as a reduced control plane. Implement a no-loss retirement flow: inventory, classify, migrate/fuse/archive, update all consumers, validate no recreation paths, then delete or move the central repo out of active root usage. Portfolio features must be rebuilt around direct project discovery and project-local corpora. If a fast portfolio cache is useful, it must be generated from local project data and safe to delete at any time.

# Scope In

- Inventory all files under `/home/claude/shipglows_data`, including dirty git state and untracked files.
- Preserve central git history through a retirement artifact, such as a git bundle or archive report, before deleting the repo.
- Migrate or archive unique central root docs, specs, logs, runbooks, project trackers, and project-specific notes.
- Resolve `projects/*` central folders into owning project-local `shipglows_data/workflow/` locations or ShipGlows retirement archives.
- Remove active dependency on `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` from ShipGlows canonical path doctrine, installer, CLI lifecycle, skills, skill references, public help, and TUI.
- Replace central `PROJECTS.md` discovery with direct project discovery from current root and configured workspace roots.
- Replace central domain applicability matrix reads with project-local evidence, explicit operator selection, or optional project-local override docs.
- Update TUI reader/config/tests so it reads project-local corpora and no longer hardcodes `/home/claude/shipglows_data`.
- Add verification that ShipGlows does not recreate `~/shipglows_data` during install, menu startup, env startup, project init, status, audit, or TUI flows.

# Scope Out

- No deletion of any project-local `shipglows_data/` corpus.
- No broad redesign of the full TUI UX beyond changing data discovery and source ownership.
- No conversion of every historical central note into an active task.
- No mandatory new cross-project registry file under another root path.
- No commit, push, or production deployment as part of the spec itself.
- No public marketing claim change unless README/help pages currently promise the central repo model.

# Constraints

- `sg-spec` must not edit `TASKS.md`, `AUDIT_LOG.md`, or `PROJECTS.md`; this spec only defines the migration contract.
- Do not delete or overwrite any dirty user changes in `/home/claude/shipglows_data`.
- Do not replace `~/shipglows_data` with another persistent project-data repo.
- Generated project indexes or caches must be derived, ignored by git, and never used as source of truth.
- Project-local `shipglows_data/` remains the canonical place for project-owned ShipGlows artifacts.
- ShipGlows-owned references, tools, templates, and specs remain under `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Destructive removal of the central repo requires passing inventory, migration, and no-recreation checks first.
- The implementation should run as one long sequential `/sg-start` flow where possible; do not ask the operator to relaunch for each task.

# Dependencies

- `skills/references/canonical-paths.md`: currently still names external ShipGlows tracking data and `PROJECTS.md`; must be updated by implementation.
- `shipglows_data/workflow/specs/shipglows-data-project-umbrella-documentation-architecture.md`: establishes project-local corpora as source of truth and treated the central repo as out of scope for the earlier phase.
- `lib.sh` and `install.sh`: currently create and update central data files.
- `tui/src/main.ts` and `tui/src/sources/readers.ts`: currently hardcode and read central data sources.
- `skills/*` and `skills/*/references/*`: multiple skills still read central `PROJECTS.md`, `TASKS.md`, or `AUDIT_LOG.md`.
- Fresh external docs: not needed; this is a local ShipGlows architecture and migration change.

# Invariants

- A project artifact has exactly one active owner: its project-local corpus, or ShipGlows's own corpus for ShipGlows-owned artifacts.
- A migrated central artifact must have an inventory row with original path, classification, destination, decision rationale, and validation proof.
- Central data may be archived for history, but archived material is read-only evidence, not an active workflow source.
- The TUI may aggregate views, but aggregation is computed from local project corpora.
- A skill may ask the operator to select projects, but it must not require a central registry to know project truth.
- Historical references inside old specs and bug files may remain if they describe past behavior; current instructions must not teach the central repo as active.

# Links & Consequences

- Skills that used `PROJECTS.md` for selection need a shared discovery policy or helper so audit/status/check workflows do not each invent their own scanner.
- Skills that mirrored audit/task summaries into central `TASKS.md` or `AUDIT_LOG.md` must stop writing those mirrors and instead keep results in project-local workflow trackers.
- `shipglows_init_project` and `show_shipglows_menu` must stop creating central starter files.
- Installer docs must stop telling users to clone `shipglows_data.git` before install.
- TUI source policy must continue to protect against symlink escapes and large/untrusted files while allowing discovered project roots.
- The migration may reveal stale tasks that deserve backlog review, but the migration itself should not decide product priority beyond preserving content.

# Documentation Coherence

- Update `README.md` install/data model sections.
- Update `shipglows_data/technical/metadata-migration-guide.md`.
- Update `shipglows_data/workflow/playbooks/spec-driven-workflow.md` if it still describes `shipglows_data` as cross-project tracking.
- Update `skills/references/canonical-paths.md`.
- Update `skills/sg-help/references/help-catalog.md`.
- Update TUI README data-source documentation.
- Update public skill pages only when they mention central project discovery or master trackers.
- Add a retirement archive README/report under `shipglows_data/workflow/archives/central-shipglows-data-retirement/`.

# Edge Cases

- Dirty central files contain newer content than local project trackers.
- A central project folder maps to a project that no longer exists locally.
- One central project name maps to multiple repos or renamed repos.
- Old registry paths use `/home/claude`, `~/`, spaces, accents, or stale names.
- Central `specs/master-auth-playbook.md` may be shared ShipGlows knowledge rather than a single project artifact.
- Historical bug/spec files mention `~/shipglows_data`; those references should not be rewritten if they are evidence of past behavior.
- TUI runs from `/home/claude/shipglows/tui`, from ShipGlows root, or from another project root.
- A derived cache is stale after a project folder is moved; cache invalidation must not hide current local files.

# Implementation Tasks

- [ ] Task 1: Build a read-only central inventory command.
  - File: `tools/` or `scripts/` under ShipGlows, exact filename chosen by implementation.
  - Action: Walk `/home/claude/shipglows_data`, capture git status, file type, size, mtime, checksum, likely owner, and candidate destination without mutating files.
  - User story link: Prevent data loss before central removal.
  - Depends on: None.
  - Validate with: Run inventory and save a Markdown/JSON report under `shipglows_data/workflow/archives/central-shipglows-data-retirement/`.
  - Notes: Do not include secrets or full private file dumps in user-facing output.

- [ ] Task 2: Classify central files with a no-loss migration matrix.
  - File: `shipglows_data/workflow/archives/central-shipglows-data-retirement/inventory.md`
  - Action: Mark each file as `duplicate`, `migrate-project`, `migrate-shipglows`, `archive-history`, `conflict`, or `delete-safe`.
  - User story link: Ensure deletion is based on explicit decisions.
  - Depends on: Task 1.
  - Validate with: Every central file has one classification and no `conflict` row is ignored.
  - Notes: Dirty files must default to `conflict` or `migrate-*`, never `delete-safe`.

- [ ] Task 3: Preserve central repo history before content migration.
  - File: `shipglows_data/workflow/archives/central-shipglows-data-retirement/`
  - Action: Store a git history preservation artifact, such as a `git bundle`, plus a short README explaining it is historical evidence only.
  - User story link: Keep useful history without keeping the repo active.
  - Depends on: Task 1.
  - Validate with: `git bundle verify` when a bundle is produced, or equivalent archive verification.
  - Notes: The archive must not be used by skills/TUI as runtime input.

- [ ] Task 4: Migrate or archive central root ShipGlows docs and shared playbooks.
  - File: `shipglows_data/workflow/archives/central-shipglows-data-retirement/` and relevant ShipGlows local `shipglows_data/` destinations.
  - Action: Move unique ShipGlows-owned docs, playbooks, migration notes, operations/dependency logs, and obsolete root docs into canonical ShipGlows locations or retirement archives.
  - User story link: Remove central repo while retaining ShipGlows knowledge.
  - Depends on: Tasks 1-3.
  - Validate with: Inventory rows show destination and metadata lint passes for promoted active artifacts.
  - Notes: Use archives for historical material that is not current doctrine.

- [ ] Task 5: Migrate or archive central per-project folders.
  - File: `/home/claude/*/shipglows_data/workflow/` for owning projects, or ShipGlows retirement archive for unresolved projects.
  - Action: Merge unique central `projects/<project>` tasks, docs, concurrent notes, and future-work items into project-local workflow trackers or archives.
  - User story link: Each project becomes its only active source of truth.
  - Depends on: Tasks 1-3.
  - Validate with: Per-project diffs show migrated content or explicit archive decisions; no project-local tracker is overwritten blindly.
  - Notes: If a project has no local corpus, route through `sg-init`/`sg-docs` before migration.

- [ ] Task 6: Define and implement project discovery without central `PROJECTS.md`.
  - File: Shared helper in ShipGlows codebase, plus TUI and skill callers.
  - Action: Discover projects from current root and configured workspace roots by detecting local `shipglows_data/`, `AGENT.md`, or known project markers; return name, path, stack hints, diagnostics, and confidence.
  - User story link: TUI and skills can find projects without a central truth.
  - Depends on: Tasks 1-2 for migration knowledge.
  - Validate with: Unit tests covering existing `/home/claude` project shapes, duplicate names, missing AGENT, stale symlinks, and unreadable paths.
  - Notes: Optional caches must be derived and disposable.

- [ ] Task 7: Replace central domain applicability matrix behavior.
  - File: Audit skills and references that read `PROJECTS.md` domain columns.
  - Action: Use project-local evidence and explicit operator selection for audit applicability; allow optional project-local override docs only under the owning project's `shipglows_data/`.
  - User story link: Global audits no longer depend on a central matrix.
  - Depends on: Task 6.
  - Validate with: Focused `rg` confirms active audit workflows no longer instruct reading central `PROJECTS.md`.
  - Notes: Do not require every project to add a new metadata file before global mode works.

- [ ] Task 8: Update CLI and installer so central data is not created.
  - File: `install.sh`, `lib.sh`, shell docs/tests.
  - Action: Remove central starter creation, central project tracker initialization, central `PROJECTS.md` registration, and central master tracker assumptions.
  - User story link: ShipGlows must not recreate the removed repo.
  - Depends on: Task 6 for replacement discovery behavior.
  - Validate with: Shell syntax checks and project-init/start tests updated to assert no `~/shipglows_data` creation.
  - Notes: Preserve project-local `CHANGELOG.md` behavior only if still valid.

- [ ] Task 9: Update TUI readers and tests.
  - File: `tui/src/main.ts`, `tui/src/sources/readers.ts`, `tui/test/*`, `tui/README.md`.
  - Action: Remove hardcoded `/home/claude/shipglows_data`; read project-local corpora and discovered project list; keep source policy protections.
  - User story link: The original TUI reason for the central repo is replaced by direct local discovery.
  - Depends on: Task 6.
  - Validate with: `bun run typecheck` and `bun test` from `tui/`.
  - Notes: If Bun is unavailable, report degraded validation and run static checks that are available.

- [ ] Task 10: Update skill contracts, shared references, and docs.
  - File: `skills/**`, `skills/references/**`, `README.md`, `shipglows_data/technical/metadata-migration-guide.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.
  - Action: Remove active central control-plane language and replace with project-local source-of-truth plus discovery/derived-cache language.
  - User story link: Skills must stop mentioning and depending on the central concept.
  - Depends on: Tasks 6-8.
  - Validate with: `rg -n "SHIPGLOWS_DATA_DIR|\\$HOME/shipglows_data|~/shipglows_data|shipglows_data/projects|central control-plane|external control-plane|PROJECTS.md"` and manually classify remaining historical references.
  - Notes: Historical evidence in old specs/bugs can remain when clearly historical.

- [ ] Task 11: Add no-recreation and no-central-runtime validation.
  - File: Existing test files or new validation script.
  - Action: Verify install/menu/env/start/status/audit/TUI paths do not create or require `~/shipglows_data`.
  - User story link: Removal must stay removed.
  - Depends on: Tasks 8-10.
  - Validate with: Automated tests plus a smoke run in a temp `$HOME`.
  - Notes: Use temp directories; do not mutate real project data during tests.

- [ ] Task 12: Remove or move the central repo after gates pass.
  - File: `/home/claude/shipglows_data`
  - Action: Delete or move the central repo out of active root use only after inventory, migration, archive, and no-recreation validations pass.
  - User story link: Complete the total removal.
  - Depends on: Tasks 1-11.
  - Validate with: `test ! -e /home/claude/shipglows_data` or equivalent approved final state; ShipGlows checks still pass.
  - Notes: This is destructive and must be executed only by the implementation/ship phase with explicit evidence.

- [ ] Task 13: Final verification and closure.
  - File: Spec, retirement report, changed files.
  - Action: Run metadata lint, skill budget/runtime sync checks, shell tests, TUI tests, and final `rg` audit; update the spec run history through lifecycle skills.
  - User story link: Prove the migration is complete and durable.
  - Depends on: Tasks 1-12.
  - Validate with: `/sg-verify retire-central-shipglows-data-repository`.
  - Notes: Do not ship if any active consumer still requires central data.

# Acceptance Criteria

- [ ] CA 1: Given `/home/claude/shipglows_data` exists, when the inventory runs, then every file is listed with classification, owner, candidate destination, and risk.
- [ ] CA 2: Given central files contain dirty changes, when classification runs, then dirty files are never marked safe-delete without migration or explicit conflict handling.
- [ ] CA 3: Given central git history exists, when migration begins, then a verified history preservation artifact exists before any destructive removal.
- [ ] CA 4: Given a central per-project task exists and is unique, when migration completes, then it appears in the owning project's local workflow corpus or an unresolved-project archive.
- [ ] CA 5: Given a central file duplicates project-local content, when migration completes, then the inventory records the duplicate decision and no second active copy is created.
- [ ] CA 6: Given the installer runs in a fresh temp home, when it completes, then it does not create `~/shipglows_data`.
- [ ] CA 7: Given `shipglows_init_project` or environment startup runs, when a project lacks central tracking, then ShipGlows does not create `shipglows_data/projects/<project>`.
- [ ] CA 8: Given the TUI starts, when it reads data, then it uses discovered project-local corpora and does not require `/home/claude/shipglows_data/PROJECTS.md`.
- [ ] CA 9: Given an audit skill runs in global/workspace mode, when it selects projects, then selection comes from discovered project roots and project-local evidence, not central `PROJECTS.md`.
- [ ] CA 10: Given an active skill/documentation file is searched, when `SHIPGLOWS_DATA_DIR`, `$HOME/shipglows_data`, `~/shipglows_data`, `shipglows_data/projects`, `external control-plane`, or central `PROJECTS.md` appears, then the occurrence is historical, transitional, or explicitly marked legacy.
- [ ] CA 11: Given the central repo is removed, when ShipGlows validation runs, then no check recreates it or fails because it is absent.
- [ ] CA 12: Given a fresh agent reads the updated docs, when it asks where project ShipGlows data lives, then the answer is only the project-local `shipglows_data/` corpus.
- [ ] CA 13: Given the operator launches `/sg-start retire-central-shipglows-data-repository`, when tasks complete without conflict or destructive confirmation, then the run proceeds continuously across inventory, migration, consumer rewrites, and validation rather than stopping after each task.

# Test Strategy

- Inventory proof: run the retirement inventory command and review the generated classification report.
- Data proof: compare checksums and diffs for migrated files; preserve central dirty changes and history before deletion.
- Static proof: use focused `rg` checks for central-path references and manually classify remaining historical mentions.
- Shell proof: run `bash -n shipglows.sh lib.sh config.sh install.sh` plus updated init/start tests in temp homes.
- Skill proof: run `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipglows_sync_skills.sh --check --all` after skill edits.
- Metadata proof: run `python3 tools/shipglows_metadata_lint.py` on changed active artifacts.
- TUI proof: run `bun run typecheck` and `bun test` in `tui/`.
- Removal proof: after approved destructive step, verify `/home/claude/shipglows_data` is absent and repeat the relevant ShipGlows/TUI checks.

# Risks

- Data loss if dirty central trackers are deleted before migration. Mitigation: dirty files default to migrate/conflict and central history is preserved first.
- Hidden consumers may recreate the folder. Mitigation: no-recreation tests and global `rg` audit before deletion.
- Project discovery may become slower without a central registry. Mitigation: bounded root scanning plus disposable derived cache if needed.
- Domain applicability may be less explicit after removing the central matrix. Mitigation: infer from project-local evidence, ask through `question-contract` when ambiguous, and allow optional project-local overrides.
- Historical specs and bug files may keep old central path references. Mitigation: classify them as historical evidence instead of rewriting history.
- Removing `SHIPGLOWS_DATA_DIR` may break user-local overrides. Mitigation: replace with project discovery config for roots/caches, not project data storage.

# Execution Notes

- Read first: `skills/references/canonical-paths.md`, `shipglows_data/workflow/specs/shipglows-data-project-umbrella-documentation-architecture.md`, `lib.sh`, `install.sh`, `tui/src/sources/readers.ts`, and `skills/sg-init/references/bootstrap-workflow.md`.
- Start with inventory and reports only. Do not mutate `/home/claude/shipglows_data` until the no-loss classification exists.
- Use structured parsing or file metadata for inventory; do not rely only on ad hoc grep for migration decisions.
- Prefer adding a shared discovery helper over copying project-scanning logic into each skill/TUI path.
- Keep project discovery bounded. Default candidates can include current project root, `$SHIPGLOWS_ROOT`, and direct children of configured workspace roots; avoid recursive unbounded home scans unless explicitly requested.
- Stop and ask the operator if a conflict would require choosing between divergent central and project-local content.
- Continue sequentially without user relaunch between tasks when the next task follows directly from the validated previous task and does not require a new product, migration-conflict, security, or destructive decision.
- Do not use external documentation freshness gates; this spec is governed by local ShipGlows contracts.

# Open Questions

None for spec readiness. Implementation must still stop for operator choice if the inventory finds divergent content that cannot be mapped safely.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-05-25 14:51:37 UTC | sg-spec | GPT-5 Codex | Created ready migration spec for total retirement of the central `~/shipglows_data` repo after no-loss inventory, migration/fusion, consumer rewrites, and no-recreation validation. | ready | `/sg-ready retire-central-shipglows-data-repository` |
| 2026-05-25 15:35:18 UTC | sg-ready | GPT-5 Codex | Validated readiness and strengthened the execution contract so `/sg-start` continues sequentially as far as safely possible without per-task relaunches. | ready | `/sg-start retire-central-shipglows-data-repository` |
| 2026-05-25 16:10:24 UTC | sg-start | GPT-5 Codex + subagents | Implemented read-only central inventory/archive, verified git history bundle, removed central recreation paths from installer/CLI/TUI, moved TUI to local project discovery, and updated active skills/docs away from central source-of-truth language. Stopped before destructive deletion because inventory found unresolved conflicts and project mappings requiring operator arbitration. | partial | `/sg-verify retire-central-shipglows-data-repository` after resolving inventory conflicts |
| 2026-05-25 16:25:37 UTC | sg-verify | GPT-5 Codex | Verified local proof for inventory, git bundle, no-recreation paths, TUI discovery, skill/runtime sync, metadata, site build, and no active central runtime references. Final retirement remains unverified because migration conflicts are unresolved and the central repo was intentionally not deleted. | partial | Resolve inventory conflicts, migrate/archive remaining content, then rerun `/sg-start` or `/sg-verify` before deletion |
| 2026-05-25 16:56:44 UTC | sg-start | GPT-5 Codex | Migrated 13 central files whose destinations did not exist yet, spanning ShipGlows local governance data plus gocharbon/winflowz/shipglows workflow files. Skipped 11 divergent destination collisions without overwrite. | partial | Diff and merge existing divergent destinations, then archive unresolved legacy project trackers |
| 2026-05-25 16:59:18 UTC | continue | GPT-5 Codex | Resolved the 11 divergent destination collisions without overwrite: archived 9 older central ShipGlows variants, appended gocharbon/winflowz central `TASKS.md` content as local legacy sections, archived 49 unresolved project files and 2 dirty central root trackers as historical evidence. | partial | Run verification checks, then require explicit destructive confirmation before removing `/home/claude/shipglows_data` |
| 2026-05-25 18:40:30 UTC | continue | GPT-5 Codex | After operator narrowed deletion scope, removed only central files already migrated, fused, or archived with proof: ShipGlows root governance files, dirty root trackers, metadata inventory, and gocharbon/shipglows/winflowz project-local migrations. Kept absent-project trackers plus `autre/` and `specs/` in the central repo for later arbitration. | partial | Audit remaining central Markdown by category before any further deletion |

# Current Chantier Flow

| Skill | Status | Notes |
| --- | --- | --- |
| sg-spec | ready | Ready spec created from operator decision to remove the central repo entirely. |
| sg-ready | ready | Readiness validated; execution-continuity constraint added for a single long sequential `/sg-start` flow. |
| sg-start | partial | Inventory/archive, no-recreation edits, TUI discovery, and skill/doc rewrites completed; central deletion blocked by unresolved migration conflicts. |
| sg-verify | partial | Local implementation proof passes, but no-loss migration and central deletion are not verified while 79 inventory conflicts remain unresolved. |
| sg-end | pending | Must close with retirement report and remaining historical references classified. |
| sg-ship | pending | Must not delete or ship until gates pass. |
