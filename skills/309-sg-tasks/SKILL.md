---
name: 309-sg-tasks
description: "Update task trackers and suggest next steps."
disable-model-invocation: false
argument-hint: [sessions|sessions rename <status>|sessions prune|name-conversation|optional focus area or task type]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.


## Context

- Current directory: !`pwd`
- Project-local dashboard (primary): !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || echo "No local project TASKS.md"`
- Legacy cross-project dashboard fallback: disabled; use project-local trackers or explicit migration evidence only.
- Local project tracker (if exists): !`cat TASKS.md 2>/dev/null || cat shipglows_data/workflow/TASKS.md 2>/dev/null || echo "No local project TASKS.md"`
- Recent git status: !`git status --short 2>/dev/null || echo "Not a git repository"`
- Current branch: !`git branch --show-current 2>/dev/null || echo "N/A"`
- Project CLAUDE.md (if exists): !`head -30 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md found"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`

## Multi-project tracking system

**CRITICAL**: This workspace tracks projects through local project trackers (`shipglows_data/workflow/TASKS.md`). Local project trackers are the active source of truth.

- `TASKS.md` is an operational tracker, not a ShipGlows decision artifact. Do not add YAML frontmatter or metadata schema fields to `TASKS.md`.
- `shipglows_data/editorial/ROADMAP.md` is the separate operational tracker for editorial/public-content follow-up. `309-sg-tasks` does not own that file by default.
- If a task contains a durable decision, spec, business rule, research conclusion, or product contract, keep the task entry concise and extract the durable content into a separate metadata-bearing artifact via `/300-sg-docs`, `/100-sg-spec`, `/203-sg-research`, or the relevant skill.
- **Prioritize local tracker updates** (`TASKS.md` or `shipglows_data/workflow/TASKS.md`) as the operational source of truth.
- Do not update a central master tracker during normal task work. Treat old master files as migration evidence only.

## Shared tracking file write protocol

- Before creating or mutating task operational records, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` and follow its traffic-first grammar for new `TASKS.md` entries.
- Before deciding whether a follow-up belongs in the execution tracker at all, load `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md`. If the work is primarily editorial/public-content, reroute to the editorial roadmap instead of mutating `TASKS.md`.
- Treat the TASKS snapshots loaded at skill start as informational only.
- Right before editing the project-local TASKS file, re-read the target from disk and use that version as authoritative.
- Apply the smallest possible patch to the relevant project section or backlog block; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.
- If the file is still missing after that authoritative re-read, create it from the canonical format.

## Codex Session Triage

Use `sessions` for repository-scoped Codex title/status cleanup, `sessions
rename <status>` for the current conversation, and `sessions prune` for old
completed-session storage cleanup. These modes must load the session playbook
before inspecting or mutating Codex state; the compact owner contract and
pressure scenarios below remain activation-critical.

## Sessions Mode

Use `sessions` when the operator wants the Codex conversation archive to act as
a navigable status index alongside the project tracker. The reusable operating
method is `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`.

This mode has two separate sources of truth:

- `shipglows_data/workflow/TASKS.md` is authoritative for project work and uses
  the exact status vocabulary `todo`, `doing`, `in_progress`, `blocked`, `done`.
- `~/.codex/state_5.sqlite`, `threads.title`, is authoritative for the title
  shown in the Codex session list. The session `cwd` must match the target
  project before any rename.

Relate them through a stable `session_id`/`conversation_id` field on the task
record when a conversation produced a durable follow-up. Several conversations
may link to the same task, including forks and context-reuse sessions. Do not copy full
conversation transcripts into `TASKS.md`, and do not infer `done` from a final
message alone: require implementation or proof evidence appropriate to the
conversation.

### Mode contract

`/309-sg-tasks sessions [project|cwd]` must:

1. scope by exact absolute `cwd`; read an existing local tracker, but do not
   create `TASKS.md` or `shipglows_data/` for a tracker-less directory;
2. query `id` and `title` for Codex `threads` rows filtered by the exact project `cwd`, then skip only managed titles whose work title is semantic and contains at most five words;
3. inspect the complete available conversation for every unmanaged title, from the first request through the latest objective and outcome; a preview or first-message field alone is insufficient;
4. for high-confidence same-subject unmanaged threads, keep the most recently active
   open and mark older duplicates `done`; never change linked task status;
5. mark unmanaged non-current sessions inactive for more than 30 days `done`, unless
   explicit evidence shows they are blocked or intentionally active;
6. classify the remaining unmanaged threads with the tracker vocabulary, preserving the
   original thread id and deriving a semantic work title of at most five words;
7. update only unmanaged `threads.title` rows to `<STATUS> - <work title>` using one exact uppercase status; never build the work title by truncating, taking the first words, or removing stop words from a message;
8. create or update a concise tracker task only when an unmanaged conversation yielded
  durable follow-up, recording `session_id` rather than transcript content;
9. report renamed sessions, skipped-managed count, tracker links, ambiguous cases, and validation.

`/309-sg-tasks name-conversation` proposes or applies one title using the same
status vocabulary. It must not mutate `TASKS.md` unless the conversation also
produced a durable task.

`/309-sg-tasks sessions rename <status>` requires an explicit supported status
before any rename-related work. If `sessions rename` has no status or an
unsupported status, ask for exactly one supported status (`todo`, `doing`,
`in_progress`, `blocked`, or `done`) and do not derive a title, inspect
sessions, call the helper, or mutate Codex or `TASKS.md`. With a valid status,
derive one semantic work title from the visible conversation, then invoke the ShipGlows-owned
`tools/rename_codex_session.py` with that title. Accept only `todo`, `doing`,
`in_progress`, `blocked`, or `done`; target only `CODEX_THREAD_ID` in the exact
current `cwd`; persist `<STATUS> - <work title>` with at most five work-title
words; and never inspect other
threads or mutate `TASKS.md`. The explicit command authorizes this one rename;
do not ask for a second confirmation.

`/309-sg-tasks sessions prune [cwd]` loads the session playbook and the
ShipGlows-owned `tools/prune_codex_sessions.py`. It previews by default and may
apply only after the operator confirms the exact absolute `cwd`. Prune is
restricted to canonical `DONE - ...` sessions inactive for strictly more than
30 days by default, always excludes `CODEX_THREAD_ID`, never runs `VACUUM`, and
never mutates project trackers. Follow the tool's dry-run/apply contract; do
not reproduce destructive SQLite or filesystem logic ad hoc in the agent.

### Pressure scenarios

- `CONVERSATION-STATUS-DRIFT`: a thread title uses `ok`, `cours`, `done`, or
  another non-tracker label; map it to the exact local vocabulary before
  writing.
- `CONVERSATION-IDEMPOTENT-SKIP`: a thread already has a canonical uppercase
  status prefix and a non-generic work title; skip it without context reads,
  status changes, title writes, duplicate cleanup, inactivity cleanup, or
  tracker mutation unless the operator explicitly targets it for refresh.
- `CONVERSATION-CWD-COLLISION`: sessions from another repository mention the
  project name; filter by exact `threads.cwd` and leave unrelated rows alone.
- `CONVERSATION-CLOSURE-OVERCLAIM`: a thread sounds finished but lacks
  implementation or required proof; use `in_progress`, `todo`, or `blocked`.
- `CONVERSATION-TRACKER-DUPLICATION`: a thread has no durable follow-up;
  rename the session only and do not create a synthetic task.
- `CONVERSATION-TRACKER-ABSENT`: exact `cwd` remains the scope; create no
  governance solely for session cleanup.
- `CONVERSATION-SUBJECT-DUPLICATION`: keep the newest clear match open; close
  older matches without merging ambiguous topics or altering tasks.
- `CONVERSATION-INACTIVE-30D`: close non-current sessions after more than 30
  inactive days unless explicit evidence overrides the rule; task status is
  independent.
- `CONVERSATION-PRUNE-SAFETY`: pruning starts as a dry-run, uses exact `cwd`,
  excludes the current thread, requires exact apply confirmation, and deletes
  neither open-status sessions nor another project's rows or rollout files.
- `CONVERSATION-RENAME-CURRENT-ONLY`: an explicit `sessions rename <status>`
  changes only `CODEX_THREAD_ID` in the exact current cwd, rejects generic work
  titles, and leaves project trackers and every other thread untouched.
- `CONVERSATION-RENAME-MISSING-STATUS`: `sessions rename` without a supported
  status asks for exactly one supported status and does not derive a title,
  inspect sessions, call the helper, or mutate Codex or `TASKS.md`.
- `CONVERSATION-TITLE-TRUNCATION`: a first request or preview begins with a
  long sentence; read through the latest objective and outcome, then write an
  original semantic summary of at most five words. Never use prefix slicing,
  first-N-word extraction, stop-word filtering, or character truncation.

## Conversation Naming

For `name-conversation` and all rename flows, load the session playbook. Read
the complete available conversation through its latest objective and outcome,
then propose `<STATUS> - <work title>` with at most five work-title words.
Earlier objectives may only disambiguate the latest one. Never generate the
title by copying or shortening message text. Report `Suggested title`, tracker
`Status`, and a one-line `Why`; add an alternate only when ambiguity is real.

## Tracker synchronization rules

- Distinguish clearly between:
  - the project-local `shipglows_data/workflow/TASKS.md` file
  - legacy root `TASKS.md` files inside old projects
  - archived central trackers used only as migration evidence
- There is no active central master tracker for normal task updates.
- The local tracker (`TASKS.md` or `shipglows_data/workflow/TASKS.md`) should represent the active project backlog and may include a small `Historical completed work` section when older project work exists only in the legacy master.
- Completed historical entries from archived central trackers must not be copied into the local active backlog.

For an Atlas-roadmap request, load `$SHIPGLOWS_ROOT/skills/references/atlas-cartography-lifecycle.md`; report coverage only, never create IDs or replace `TASKS.md`/specs.
- If a local `TASKS.md` is created after project work already exists in the legacy master tracker, first audit the existing project entries there, then split them into:
  - active backlog
  - historical completed context
- Do not claim that a tracker "did not exist" without specifying whether you mean:
  - the legacy master tracker
  - the project section in the legacy master tracker
  - the local `TASKS.md` file

## Your task

Intelligently manage the TASKS.md file by:
1. Checking off completed tasks
2. Adding remaining tasks to be done
3. Suggesting the next priority action
4. **Keeping the execution tracker in sync** (`shipglows_data/workflow/TASKS.md` primary, legacy master optional)

This skill answers one operator question: what should change in the task tracker right now so the durable task record matches the real project state?

It owns tracker bookkeeping: task records, status updates, active-vs-backlog hygiene inside `TASKS.md`, and a tracker-derived suggestion for the next step after the file is accurate.

Keep the boundary explicit:
- stay here for execution backlog maintenance
- reroute editorial/public-content backlog work to `shipglows_data/editorial/ROADMAP.md` through the content owner skill or the shared routing contract
- stay here when the main need is to create, update, migrate, clean, or reconcile the task tracker itself
- hand off to `706-continue` when the main need is to advance the currently resolved work item rather than maintain the tracker
- hand off to `701-sg-backlog` when the main need is deferred capture or backlog cleanup rather than active tracker maintenance
- hand off to `702-sg-priorities` when the tracker is already credible and the user wants current execution order
- hand off to `703-sg-review` when the user wants a retrospective summary of what happened rather than tracker mutation

`309-sg-tasks` does not become the default owner for active execution, does not replace continuation of the current chantier, and does not treat every nearby `TASKS.md` mention as permission to run the work itself.

### Workspace root detection

If the current directory has no project markers (not inside a specific project) — you are at the **workspace root**. Use the runtime's structured question tool when available, or a concise plain-text question:
- Question: "Which project(s) should I update tasks for?"
- `multiSelect: true`
- Options:
  - **All projects** — "Review and update tasks across the full workspace" (Recommended)
  - One option per project: label = project name, description = number of open tasks in local project tracker

### Steps

1. **Analyze current state**:
   - Read TASKS.md if it exists (shown in context above)
   - Check the git status and file changes to identify what's been done
   - Look for project-specific patterns in CLAUDE.md to understand the project structure

2. **Identify completed tasks**:
   - Review unchecked tasks in TASKS.md
   - Cross-reference with actual project state (files, git commits, running processes)
   - Mark tasks as complete by changing `- [ ]` to `- [x]` for done items
   - Add completion timestamps where helpful

3. **Identify remaining tasks**:
   - Based on the project context and any arguments provided by the user (`$ARGUMENTS`)
   - Consider common next steps: tests, documentation, deployment, refactoring
   - Think about the project lifecycle: setup → development → testing → deployment → maintenance
   - Look for TODOs in code, pending PRs, failing tests, or incomplete features

4. **Update TASKS.md**:
   - **Always check if TASKS.md exists first.** If it does not exist, create it using a concise project heading plus task operational records that follow `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` — do NOT create a bare-minimum file.
  - If project work already exists in the legacy master tracker for this repo, import only the still-active items into the local active backlog. Historical `done` items may be copied into a short context section, but never into the active backlog.
   - If TASKS.md doesn't exist, create it with this compact structure (adapt section titles to the detected project):
     ```markdown
     # Tasks — [Project Name]

     > Operational task records follow `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`.

     ---

     ## Active

     [traffic-first task records]

     ## Historical completed work

    Optional. Use only when older project work already exists in the legacy master tracker and would otherwise be lost locally.

     ---

     ## Backlog

     [traffic-first task records for deferred work]

     ---

     ## Audit Findings
     <!-- Populated by /400-sg-audit with traffic-first task records when findings become tasks. -->
     ```
   - When **audit findings** are added to TASKS.md (by `/400-sg-audit` or manually), add or update task operational records using the shared traffic-first contract.
   - If TASKS.md exists, update it:
     - Update existing canonical task records in place when present, preserving unknown fields.
     - Treat legacy tables or checklist rows as migration input only; do not add new legacy-only task rows.
     - Preserve existing audit sections — never remove dated `### Audit:` blocks
     - Keep traffic markers consistent with `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`: 🔴 🟠 🟡 🟢.

5. **Update CHANGELOG.md**:
   - Look for a `CHANGELOG.md` in the current project directory
   - If it doesn't exist, create it with a standard Keep a Changelog structure
   - Add an entry under `## [Unreleased]` (or today's date if releasing) for every task marked done in this session
   - Group entries by type: `### Added`, `### Changed`, `### Fixed`
   - Keep entries concise and user-facing (what changed, not how)
   - Example format:
     ```markdown
     ## [Unreleased]
     ### Added
     - Page /quiz dédiée fullscreen (FR + EN) avec redirection de tous les CTAs
     - Minimum 2 semaines imposé avant toute réservation (validation Zod + Calendar)
     ### Changed
     - BookingForm : typography et spacing réduits pour tenir sur un écran sans scroll
     ```

6. **Suggest next steps**:
   - Analyze the remaining tasks
   - Recommend the highest priority item based on:
     - Blockers (tasks that unblock other work)
     - Dependencies (what needs to happen first)
     - High-ROI bounded-effort opportunities
     - User's argument/focus area if provided
   - Explain why this task should be next (1-2 sentences)

### Important

- Do not update legacy central trackers for cross-project visibility; use local project discovery and project-local files.
- If a root project `TASKS.md` also exists (e.g., `winflowz/TASKS.md`), treat it as a legacy project tracker and prefer `shipglows_data/workflow/TASKS.md` when available.
- Use the Edit tool to update existing TASKS.md or Write tool to create a new one
- Be intelligent about what's "done" - check actual evidence, don't just guess
- Keep task descriptions clear and actionable
- Use sections to organize tasks logically
- The suggestion should be specific and immediately actionable
- If the user provided arguments, use them to focus on specific task types or areas
- Preserve any manual notes or custom sections the user has added
- Add context/notes when a task is more complex than it appears
- Update the master Dashboard table's "Status" and "Top Priority" columns when significant changes occur
