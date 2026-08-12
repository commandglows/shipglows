---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipglows"
created: "2026-05-03"
created_at: "2026-05-03 04:35:01 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 20:11:48 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "As a ShipGlows maintainer, I want a reusable skill runtime sync command that checks and repairs current-user Claude and Codex skill symlinks, so newly created and existing ShipGlows skills are visible to agents without rerunning a full install."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "tools/shipglows_sync_skills.sh"
  - "install.sh"
  - "skills/*/SKILL.md"
  - "skills/sg-skill-build/SKILL.md"
  - "skills/sg-check/SKILL.md"
  - "skills/sg-verify/SKILL.md"
  - "skills/sg-ship/SKILL.md"
  - "docs/technical/installer-and-user-scope.md"
  - "docs/technical/skill-runtime-and-lifecycle.md"
  - "docs/technical/code-docs-map.md"
  - "README.md"
  - "shipglows_data/workflow/BUGS.md"
  - "shipglows_data/workflow/bugs/BUG-2026-05-03-001.md"
  - "shipglows_data/workflow/explorations/2026-05-03-skill-runtime-symlink-sync.md"
depends_on:
  - artifact: "README.md"
    artifact_version: "0.5.1"
    required_status: "draft"
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.8.1"
    required_status: "draft"
  - artifact: "docs/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/installer-and-user-scope.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "docs/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Historical migration-source provenance (legacy root documents): BRANDING.md, BUSINESS.md, GTM.md, GUIDELINES.md, PRODUCT.md."
  - "User request 2026-05-03: symlink management should likely be a shared mechanism because other skills may need it."
  - "User report 2026-05-03: `sg-build` is not visible in Codex."
  - "Exploration report shipglows_data/workflow/explorations/2026-05-03-skill-runtime-symlink-sync.md found `sg-browser` and `sg-build` missing from both current-user Claude and Codex skill directories."
  - "Local check 2026-05-03: `skills/sg-build/SKILL.md` exists, but `~/.codex/skills/sg-build/SKILL.md` and `~/.claude/skills/sg-build/SKILL.md` do not."
  - "Local check 2026-05-03: `skills/sg-browser/SKILL.md` exists, but both current-user runtime symlink targets are missing."
  - "install.sh already implements install-time skill symlink behavior with `configure_skills`, `ensure_skill_link`, and `verify_skill_link`."
  - "BUG-2026-05-03-001 tracks the current missing runtime symlink visibility issue."
next_step: "/sg-start specs/shared-shipglows-skill-runtime-sync.md"
---

# Spec: Shared ShipGlows Skill Runtime Sync

## Title

Shared ShipGlows Skill Runtime Sync

## Status

ready

## User Story

As a ShipGlows maintainer, I want a reusable skill runtime sync command that checks and repairs current-user Claude and Codex skill symlinks, so newly created and existing ShipGlows skills are visible to agents without rerunning a full install.

## Minimal Behavior Contract

When an operator or ShipGlows skill asks to check or repair skill runtime visibility, the system must compare valid source skills under `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/<name>/SKILL.md` with the current user's `~/.claude/skills/<name>` and `~/.codex/skills/<name>` entries, then either report drift in check mode or create/repair symlinks in repair mode. A successful repair makes `SKILL.md` reachable through both runtime directories and returns a compact summary of checked, repaired, skipped, and blocked entries. On failure, it must identify the exact missing source, stale symlink, non-symlink collision, invalid skill name, or permission problem, and it must not overwrite real files or directories silently. The easy edge case to miss is an already-running Codex or Claude session: filesystem symlinks can be correct while the current process still needs a reload or new session before the skill list updates.

## Success Behavior

- Preconditions: `$SHIPGLOWS_ROOT` is unset or points to the ShipGlows repository; `skills/` contains one or more directories with `SKILL.md`; the current user can write to `~/.claude/skills` and `~/.codex/skills` when repair mode is requested.
- Trigger: the operator runs the shared sync helper directly, `sg-skill-build` creates or renames a skill, `install.sh` configures user skills, or a validation skill checks runtime visibility.
- User/operator result: the report shows whether Claude and Codex runtime skill directories match the ShipGlows source skill set for the selected scope.
- System effect: missing runtime skill entries are created as symlinks in repair mode; stale symlinks are updated in repair mode; check mode makes no filesystem changes.
- Success proof: `readlink -f ~/.claude/skills/<name>` and `readlink -f ~/.codex/skills/<name>` match `readlink -f ${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/<name>`, and both runtime paths expose `SKILL.md`.
- Silent success: not allowed. Every run must print or return a compact summary, even when no repair was needed.

## Error Behavior

- Expected failures: invalid skill name, requested skill source missing, runtime target exists as a real file or directory, runtime target cannot be removed or created, source path resolves outside `$SHIPGLOWS_ROOT/skills`, `$HOME` is unavailable, permission denied, or no valid source skills are found.
- User/operator response: the helper reports the failed runtime, skill name, target path, reason, and next safe action.
- System effect: check mode never mutates files; repair mode only creates missing symlinks or replaces stale symlinks; non-symlink targets are blocked by default.
- Must never happen: silently move, overwrite, or delete a real user file/directory; link to a path outside the ShipGlows skills directory; treat a broken symlink as success; hide partial success; print secrets or unrelated home-directory contents.
- Silent failure: not allowed. A failed check or repair must exit non-zero and name the blocked entry.

## Problem

ShipGlows currently stores canonical skill contracts under `skills/*/SKILL.md`, but Claude and Codex discover local skills through user-level runtime directories. This creates two states that can drift:

```text
source contract                         runtime discovery
skills/<name>/SKILL.md       ---->      ~/.claude/skills/<name>/SKILL.md
                                         ~/.codex/skills/<name>/SKILL.md
```

`install.sh` can create these links during installation, but normal skill maintenance does not have a small reusable command for checking or repairing them. The result is already visible: `sg-build` and `sg-browser` exist in the repository but are not visible through current-user Claude/Codex runtime paths. A one-off fix inside `sg-skill-build` helps new skill creation, but it does not solve existing drift, installer reuse, or future validation gates.

## Solution

Create a reusable ShipGlows helper, implemented as a small Bash script, that checks and repairs current-user Claude/Codex skill symlinks. Integrate it into `sg-skill-build` for new or renamed skills and into `install.sh` for install-time skill linking. Document the helper in technical docs and give validation skills a clear command they can run when runtime skill visibility matters.

The initial helper should prioritize current-user repair and install-time reuse. Broad multi-user repair remains explicit install scope, not a default behavior of normal skill maintenance.

## Scope In

- Create `tools/shipglows_sync_skills.sh` as the shared runtime sync helper.
- Support current-user targets by default: `$HOME/.claude/skills` and `$HOME/.codex/skills`.
- Support `--skill <name>` for one skill and `--all` for every valid ShipGlows skill.
- Support `--check` for read-only drift detection and `--repair` for symlink creation/repair.
- Support `--target-home <path>` so `install.sh` can reuse the helper for selected eligible users.
- Support `--shipglows-root <path>` or `$SHIPGLOWS_ROOT`, defaulting to `$HOME/shipglows`.
- Validate skill names using the same policy as `sg-skill-build`: lowercase letters, numbers, hyphens, no leading/trailing hyphen, no `--`, maximum 64 characters.
- Treat a valid source skill as a non-hidden directory under `$SHIPGLOWS_ROOT/skills/` containing `SKILL.md`.
- Create missing runtime directories when repair mode is active.
- In repair mode, create missing symlinks and replace stale symlinks.
- Block by default when a target exists and is not a symlink.
- Provide an explicit `--backup-existing` option only for install-time compatibility, moving non-symlink targets to a timestamped sibling backup before linking and reporting that action.
- Print a compact summary suitable for skill reports and install logs.
- Update `install.sh` to reuse the helper or exactly share its behavior contract for `configure_skills`.
- Update `skills/sg-skill-build/SKILL.md` to call the helper instead of embedding its own symlink snippet.
- Update relevant validation skills or docs so `sg-check`, `sg-verify`, and `sg-ship` can route to the helper when runtime skill visibility matters.
- Repair the current missing runtime links for `sg-build` and `sg-browser` during implementation validation.
- Update `shipglows_data/workflow/BUGS.md` and `shipglows_data/workflow/bugs/BUG-2026-05-03-001.md` with fix attempt and retest evidence.
- Update technical docs and README where installer/runtime skill visibility is described.

## Scope Out

- Do not automatically restart or reload Codex or Claude processes.
- Do not mutate every `/home/*` account from the helper by default.
- Do not replace non-symlink runtime entries unless `--backup-existing` is explicitly provided by an install-time caller.
- Do not change the semantics of system `.codex/skills/.system` skills.
- Do not add public site content unless the implementation changes public claims or skill page behavior.
- Do not commit unrelated dirty work, including pre-existing `install.sh` Flutter/Android edits, unless a later ship command explicitly scopes them in.
- Do not create a new skill for symlink management in this chantier; this is a shared tool/helper first.

## Constraints

- Use Bash for the helper so it can be reused directly by `install.sh` without introducing a Python dependency into install-time skill linking.
- Preserve idempotence: running the helper repeatedly must converge without duplicating backups or changing correct links.
- Keep current-user behavior safe by default: non-symlink targets block, they are not moved or overwritten.
- Keep install-time compatibility explicit through `--target-home` and optional `--backup-existing`.
- Resolve ShipGlows-owned paths from `$SHIPGLOWS_ROOT`, not from the project working directory.
- Use only POSIX/Bash filesystem operations available on the supported Ubuntu server shape.
- Reports must not print private file contents, environment secrets, tokens, or unrelated home directory listings.
- Existing dirty work in `install.sh` must be preserved and not reverted.

## Dependencies

- Local source contracts:
  - `install.sh` function cluster: `configure_skills`, `ensure_skill_link`, `verify_skill_link`, and `setup_user`.
  - `skills/sg-skill-build/SKILL.md` runtime link gate.
  - `skills/sg-check/SKILL.md`, `skills/sg-verify/SKILL.md`, and `skills/sg-ship/SKILL.md` as possible validation consumers.
- Local docs:
  - `docs/technical/installer-and-user-scope.md`
  - `docs/technical/skill-runtime-and-lifecycle.md`
  - `docs/technical/code-docs-map.md`
  - `README.md`
- Local bug and exploration context:
  - `shipglows_data/workflow/BUGS.md`
  - `shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`
  - `shipglows_data/workflow/explorations/2026-05-03-skill-runtime-symlink-sync.md`
- Fresh external docs verdict: fresh-docs not needed. The behavior is local filesystem/symlink management and existing ShipGlows shell installer integration, not an external framework, SDK, service, API, auth, build, migration, cache, routing, or hosted integration contract.

## Invariants

- `$SHIPGLOWS_ROOT/skills/<name>/SKILL.md` is the source contract for a ShipGlows skill.
- Current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` are runtime discovery entries and must be symlinks to the source skill directory for ShipGlows-owned skills.
- `.system` skills under Codex are managed by Codex/system skill installation and are not part of the ShipGlows source sync.
- Check mode is read-only.
- Repair mode never overwrites non-symlink entries unless `--backup-existing` is explicitly set.
- Stale symlinks can be replaced because they are already link metadata, not user-owned content.
- A correct filesystem symlink does not guarantee an already-running Codex or Claude process has reloaded its skill registry.

## Links & Consequences

- `install.sh`: can remove duplicated symlink logic or delegate to the helper; this is root/user setup behavior and should preserve installer idempotence.
- `sg-skill-build`: must call the helper for newly created or renamed skills so the next `sg-deploy`-style skill is visible immediately after creation.
- `sg-build` and `sg-browser`: current-user runtime links are missing today, so implementation validation should repair and verify them.
- `sg-check`, `sg-verify`, `sg-ship`: can use the helper in check mode when the task touches skills or runtime visibility.
- `docs/technical/code-docs-map.md`: may need a `tools/shipglows_sync_skills.sh` mapping or updated installer/skill validation triggers.
- `docs/technical/installer-and-user-scope.md`: must document the shared helper if install-time skill linking changes.
- `docs/technical/skill-runtime-and-lifecycle.md`: must keep runtime visibility distinct from source contract creation.
- `README.md`: should mention the lightweight repair/check command if it becomes an operator-facing recovery path.
- `BUG-2026-05-03-001`: should move from fix-attempted toward fixed-pending-verify only after helper-based repair and retest evidence exists.

## Documentation Coherence

- Update `docs/technical/installer-and-user-scope.md` if `install.sh` calls the helper or if non-symlink backup behavior changes.
- Update `docs/technical/skill-runtime-and-lifecycle.md` to name the helper as the runtime visibility gate for skills.
- Update `docs/technical/code-docs-map.md` if the new helper needs its own subsystem mapping or validation command.
- Update `README.md` if operators should use a direct repair command after skill additions or visibility drift.
- Update `skills/sg-skill-build/SKILL.md` so its documented runtime link step uses the helper.
- Public site skill content is not impacted unless public copy starts describing runtime repair behavior.
- Changelog should record the helper when the implementation ships.

## Edge Cases

- A runtime target is a real directory created manually by the user.
- A runtime target is a symlink to the wrong skill, a deleted skill, or a path outside `$SHIPGLOWS_ROOT/skills`.
- A requested `--skill` name is invalid or has no source `SKILL.md`.
- `$SHIPGLOWS_ROOT` is unset and `$HOME/shipglows` does not exist.
- `$HOME` differs from `--target-home` during install-time user setup.
- The helper runs as root for another user's home and creates links with wrong ownership.
- A skill is removed from source but stale runtime symlinks remain.
- Multiple runs happen back-to-back after a new skill is created.
- The current Codex session was started before symlinks were repaired.
- `install.sh` already has unrelated dirty edits; implementation must not revert or fold them into this feature unless explicitly scoped.

## Implementation Tasks

- [x] Task 1: Confirm current drift and protect unrelated work
  - File: `shipglows_data/workflow/BUGS.md`, `shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`, `shipglows_data/workflow/explorations/2026-05-03-skill-runtime-symlink-sync.md`
  - Action: Re-read current bug and exploration evidence, run a repo-vs-runtime comparison for current-user Claude/Codex skill symlinks, and note unrelated dirty `install.sh` changes before editing.
  - User story link: Establishes the real runtime visibility gap before building the repair path.
  - Depends on: None
  - Validate with: `comm -23 <(find skills -mindepth 2 -maxdepth 2 -name SKILL.md -printf '%h\n' | xargs -n1 basename | sort) <(find ~/.codex/skills -maxdepth 1 -mindepth 1 -type l -printf '%f\n' | sort)` and the same command for `~/.claude/skills`.
  - Notes: Do not revert unrelated edits in `install.sh`.

- [x] Task 2: Create the shared helper
  - File: `tools/shipglows_sync_skills.sh`
  - Action: Add a Bash CLI with `--check`, `--repair`, `--all`, `--skill <name>`, `--target-home <path>`, `--shipglows-root <path>`, `--runtime claude|codex|all`, and `--backup-existing`.
  - User story link: Provides the reusable command that skills and install flows can call.
  - Depends on: Task 1
  - Validate with: `bash -n tools/shipglows_sync_skills.sh`; focused temp-directory tests from Task 3.
  - Notes: Default mode should be `--check` if neither `--check` nor `--repair` is supplied.

- [x] Task 3: Add focused runtime sync tests
  - File: `tests/skills/runtime-sync.sh`
  - Action: Create a shell test using temporary ShipGlows roots and target homes to verify check/repair behavior without touching real user runtime directories.
  - User story link: Proves the helper repairs visibility without risking operator files.
  - Depends on: Task 2
  - Validate with: `bash tests/skills/runtime-sync.sh`
  - Notes: Cover missing links, stale links, correct links, non-symlink collisions, invalid skill names, `--skill`, `--all`, and `--runtime` filtering.

- [x] Task 4: Integrate installer skill linking with the helper
  - File: `install.sh`
  - Action: Replace or wrap `configure_skills` symlink internals so install-time skill linking uses `tools/shipglows_sync_skills.sh --repair --all --target-home "$target_home" --shipglows-root "$SHIPGLOWS_DIR"` with explicit compatibility for backup behavior.
  - User story link: Keeps install-time and runtime repair behavior from drifting.
  - Depends on: Tasks 2-3
  - Validate with: `bash -n install.sh`; targeted review command `rg -n "shipglows_sync_skills|configure_skills|ensure_skill_link|verify_skill_link" install.sh tools/shipglows_sync_skills.sh`
  - Notes: Preserve installer messages and avoid breaking selected eligible user setup.

- [x] Task 5: Update `sg-skill-build` to call the helper
  - File: `skills/sg-skill-build/SKILL.md`
  - Action: Replace embedded symlink shell snippet with a call to `tools/shipglows_sync_skills.sh --repair --skill <name>` and a follow-up `--check --skill <name>` validation.
  - User story link: Ensures future new skills become visible through Claude/Codex during the skill lifecycle.
  - Depends on: Tasks 2-3
  - Validate with: `rg -n "shipglows_sync_skills|runtime skill links|~/.codex/skills|~/.claude/skills" skills/sg-skill-build/SKILL.md`
  - Notes: Rerun skill budget audit because this changes a skill body.

- [x] Task 6: Expose runtime sync checks to validation skills where appropriate
  - File: `skills/sg-check/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-ship/SKILL.md`
  - Action: Add concise routing guidance that when a task touches `skills/*/SKILL.md`, new skills, renamed skills, or reported skill visibility drift, these skills can run `tools/shipglows_sync_skills.sh --check --skill <name>` or `--check --all`.
  - User story link: Lets other skills use the shared helper without duplicating symlink logic.
  - Depends on: Task 2
  - Validate with: `rg -n "shipglows_sync_skills|runtime skill|skill visibility|codex/skills" skills/sg-check/SKILL.md skills/sg-verify/SKILL.md skills/sg-ship/SKILL.md`
  - Notes: Keep additions compact to protect skill discovery budget.

- [x] Task 7: Repair current missing runtime links through the helper
  - File: runtime filesystem only (`~/.claude/skills`, `~/.codex/skills`), plus `shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`
  - Action: Use the helper to repair current-user links for at least `sg-build`, `sg-browser`, and `sg-skill-build`, then append fix/retest evidence to the bug dossier.
  - User story link: Confirms the helper solves the actual reported visibility failure.
  - Depends on: Tasks 2-3
  - Validate with: `tools/shipglows_sync_skills.sh --repair --skill sg-build`; `tools/shipglows_sync_skills.sh --repair --skill sg-browser`; `tools/shipglows_sync_skills.sh --check --all`; `readlink -f ~/.codex/skills/sg-build ~/.claude/skills/sg-build ~/.codex/skills/sg-browser ~/.claude/skills/sg-browser`
  - Notes: A fresh Codex session may still be required to visually confirm the available skill list.

- [x] Task 8: Update technical and operator documentation
  - File: `docs/technical/installer-and-user-scope.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `docs/technical/code-docs-map.md`, `README.md`
  - Action: Document the helper, current-user default, install-time reuse, non-symlink collision rule, and validation command.
  - User story link: Keeps future agents and operators from rediscovering the same runtime/source split.
  - Depends on: Tasks 2, 4, 5, 6
  - Validate with: `rg -n "shipglows_sync_skills|runtime skill sync|~/.codex/skills|~/.claude/skills" README.md docs/technical/installer-and-user-scope.md docs/technical/skill-runtime-and-lifecycle.md docs/technical/code-docs-map.md`
  - Notes: Public site content remains no-impact unless implementation changes public claims.

- [x] Task 9: Run final validation suite
  - File: `tools/shipglows_sync_skills.sh`, `tests/skills/runtime-sync.sh`, `install.sh`, changed skills/docs/spec/bug files
  - Action: Run syntax, helper tests, skill budget, metadata lint, and targeted runtime link checks.
  - User story link: Proves the helper is safe, reusable, and visible to the lifecycle.
  - Depends on: Tasks 2-8
  - Validate with: `bash -n tools/shipglows_sync_skills.sh install.sh tests/skills/runtime-sync.sh`; `bash tests/skills/runtime-sync.sh`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `python3 tools/shipglows_metadata_lint.py specs/shared-shipglows-skill-runtime-sync.md docs/technical/installer-and-user-scope.md docs/technical/skill-runtime-and-lifecycle.md docs/technical/code-docs-map.md shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`; `tools/shipglows_sync_skills.sh --check --all`
  - Notes: `pnpm --dir shipglows-site build` is not required unless public site content changes.

## Acceptance Criteria

- [ ] AC 1: Given `tools/shipglows_sync_skills.sh --check --all` runs with missing current-user runtime links, when it finishes, then it exits non-zero and reports each missing Claude/Codex skill link without creating files.
- [ ] AC 2: Given `tools/shipglows_sync_skills.sh --repair --skill sg-build` runs and the source skill exists, when runtime links are missing, then it creates `~/.claude/skills/sg-build` and `~/.codex/skills/sg-build` symlinks to the source skill directory.
- [ ] AC 3: Given a runtime symlink points to the wrong source directory, when repair mode runs, then the stale symlink is replaced and the report names it as repaired.
- [ ] AC 4: Given a runtime target exists as a real directory, when repair mode runs without `--backup-existing`, then the helper blocks, exits non-zero, and does not move or delete the directory.
- [ ] AC 5: Given a runtime target exists as a real directory during install-time use with `--backup-existing`, when repair mode runs, then the helper moves it to a timestamped backup, creates the symlink, and reports the backup path.
- [ ] AC 6: Given `--skill` receives an invalid name such as `../bad` or `sg--bad`, when the helper runs, then it exits non-zero before touching runtime directories.
- [ ] AC 7: Given `--runtime codex` is provided, when repair mode runs, then only the Codex runtime directory is checked or repaired.
- [ ] AC 8: Given the helper runs with `--target-home <tmp-home>`, when repair mode runs, then all runtime mutations happen under that target home and not under the invoking user's real home.
- [ ] AC 9: Given `sg-skill-build` creates a new skill, when it reaches runtime visibility validation, then it calls the shared helper and blocks if current-user Claude/Codex symlinks are missing or blocked.
- [ ] AC 10: Given `install.sh` configures a user, when it links skills, then it uses the helper behavior or helper command and preserves idempotent user setup.
- [ ] AC 11: Given `sg-check`, `sg-verify`, or `sg-ship` is validating skill visibility drift, when skill runtime sync is relevant, then the skill can route to the helper check command instead of duplicating symlink logic.
- [ ] AC 12: Given the current ShipGlows repo has `sg-build` and `sg-browser` source skills, when implementation validation runs, then both are visible through current-user Claude and Codex symlink paths.
- [ ] AC 13: Given the current Codex session was opened before symlink repair, when the helper succeeds, then the report states that a new/reloaded Codex session may still be required for UI skill-list visibility.
- [ ] AC 14: Given validation runs after implementation, when all checks pass, then `BUG-2026-05-03-001` records helper-based repair evidence and next retest status.

## Test Strategy

- Shell syntax:
  - `bash -n tools/shipglows_sync_skills.sh install.sh tests/skills/runtime-sync.sh`
- Focused helper tests:
  - `bash tests/skills/runtime-sync.sh`
- Runtime drift checks:
  - `tools/shipglows_sync_skills.sh --check --all`
  - targeted `readlink -f` checks for `sg-build`, `sg-browser`, and `sg-skill-build`.
- Skill budget:
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- Metadata:
  - `python3 tools/shipglows_metadata_lint.py specs/shared-shipglows-skill-runtime-sync.md docs/technical/installer-and-user-scope.md docs/technical/skill-runtime-and-lifecycle.md docs/technical/code-docs-map.md shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`
- Documentation coherence:
  - `rg -n "shipglows_sync_skills|runtime skill sync|~/.codex/skills|~/.claude/skills" README.md docs/technical skills/sg-skill-build/SKILL.md`
- Manual/operator note:
  - If the filesystem checks pass but Codex still does not show a newly linked skill in the current session, restart or reload Codex and record that as process-cache behavior, not symlink failure.

## Risks

- Installer regression risk: changing `configure_skills` can affect first-time setup for all eligible users. Mitigation: keep helper interface explicit, preserve idempotence, run shell tests with temporary homes, and avoid broad user mutation outside install flow.
- Data loss risk: runtime target collision could contain user content. Mitigation: block by default and require explicit `--backup-existing` for install compatibility.
- Ownership risk: root running helper for another user could create root-owned entries. Mitigation: `install.sh` integration must preserve existing user ownership handling or explicitly chown linked config directories after setup.
- Visibility confusion risk: a correct symlink may not appear in an already-running agent. Mitigation: report the reload/new-session limit explicitly.
- Scope creep risk: this could become a full skill package manager. Mitigation: limit this chantier to ShipGlows source skills and current-user/install-time symlink sync.
- Dirty worktree risk: unrelated `install.sh` Flutter/Android changes currently exist. Mitigation: implementation must read and preserve them, and shipping must stage only files in the chosen scope unless the operator approves broader scope.

## Execution Notes

- Read first:
  - `shipglows_data/workflow/explorations/2026-05-03-skill-runtime-symlink-sync.md`
  - `shipglows_data/workflow/bugs/BUG-2026-05-03-001.md`
  - `install.sh` around `configure_skills`, `ensure_skill_link`, `verify_skill_link`, and `setup_user`
  - `skills/sg-skill-build/SKILL.md`
  - `docs/technical/installer-and-user-scope.md`
  - `docs/technical/skill-runtime-and-lifecycle.md`
- Preferred implementation order:
  1. Build and test the helper with temp roots/homes.
  2. Integrate `sg-skill-build`.
  3. Integrate or align `install.sh`.
  4. Add check guidance to validation skills.
  5. Repair current `sg-build` and `sg-browser` runtime links using the helper.
  6. Update docs and bug dossier.
  7. Run final validation.
- Use Bash. Do not introduce a new runtime dependency for this helper.
- Stop conditions:
  - non-symlink collision behavior is ambiguous
  - helper tests touch real `~/.codex` or `~/.claude` during temp tests
  - `install.sh` integration would require reverting unrelated dirty changes
  - metadata lint or skill budget fails
  - helper repair cannot verify `SKILL.md` through runtime paths
- Fresh external docs: fresh-docs not needed; this is local filesystem and ShipGlows shell integration.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 04:35:01 UTC | sg-spec | GPT-5 Codex | Created the initial chantier spec for shared ShipGlows skill runtime sync based on the exploration report and current `sg-build`/`sg-browser` visibility drift. | draft saved | /sg-ready specs/shared-shipglows-skill-runtime-sync.md |
| 2026-05-03 04:42:17 UTC | sg-ready | GPT-5 Codex | Ran readiness gate across structure, behavior contract, task order, docs coherence, language doctrine, adversarial review, and security review. | ready | /sg-start specs/shared-shipglows-skill-runtime-sync.md |
| 2026-05-03 05:06:19 UTC | sg-start | Codex/OpenAI | Implemented shared runtime sync helper, temp-home tests, installer and skill lifecycle integration, validation skill routing, docs, bug evidence, and current-user runtime checks. | implemented | /sg-verify specs/shared-shipglows-skill-runtime-sync.md |
| 2026-05-03 05:30:25 UTC | sg-verify | GPT-5 Codex | Verified shared helper behavior, installer/skill integration, docs coherence, metadata, skill budget, temp-home tests, and current-user Claude/Codex runtime visibility checks. | verified | /sg-end specs/shared-shipglows-skill-runtime-sync.md |
| 2026-05-03 05:46:55 UTC | sg-ship | GPT-5 Codex | Closed and shipped the shared skill runtime sync chantier with changelog/tracker updates, scoped staging, final checks, commit, and push. | shipped | none |

## Current Chantier Flow

- sg-spec: done, initial draft created in `specs/shared-shipglows-skill-runtime-sync.md`.
- sg-ready: ready.
- sg-start: implemented.
- sg-verify: verified.
- sg-end: not launched.
- sg-ship: shipped.
- Next command: none.
