---
name: 701-sg-backlog
description: "Triage backlog ideas, deferred work, and cleanup."
disable-model-invocation: false
argument-hint: [optional: add "idea", move "defer", review, clean]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise backlog outcome, files touched, remaining risk, and opening chantier header when applicable. Use `report=agent` for handoffs that need detailed tracker anchors, rejected edits, or validation evidence.

## Required References

- Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking project, scope, deletion, promotion, or activation questions.
- Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before creating or mutating task/backlog operational records in `TASKS.md` or `BACKLOG.md`.


## Context

- Current directory: !`pwd`
- Project workflow TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project TASKS.md"`
- Project workflow BACKLOG.md: !`cat shipglows_data/workflow/BACKLOG.md 2>/dev/null || cat BACKLOG.md 2>/dev/null || echo "No project BACKLOG.md"`
- Project-local TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Project CLAUDE.md: !`head -30 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`
- Code TODOs: !`rg -n "TODO|FIXME" -g "*.ts" -g "*.tsx" -g "*.js" -g "*.jsx" -g "*.py" -g "*.sh" . 2>/dev/null | head -20 || echo "No TODOs found"`

## Operational tracker model

Project backlog work is local-first.

- For a selected project, use `[project]/shipglows_data/workflow/BACKLOG.md` as the primary backlog and `[project]/shipglows_data/workflow/TASKS.md` as the active task tracker.
- Root `BACKLOG.md` and `TASKS.md` are legacy project tracker locations; read them as migration/fallback sources only when canonical workflow files are absent.
- Legacy central archives are migration evidence only. Prefer project discovery from local `shipglows_data/` markers and write backlog changes to project-local workflow files.
- Do not write backlog updates to a central control-plane `TASKS.md`.

## Shared tracking file write protocol

- Before creating or mutating task/backlog operational records, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`.
- Treat the TASKS.md and BACKLOG.md snapshots loaded at skill start as informational only.
- Right before editing the project or portfolio tracking file, re-read the target from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant project section or backlog block; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

## Your task

Manage the backlog to keep active work focused and capture future ideas.

This skill answers one operator question: what should be captured, deferred, cleaned up, or promoted in the backlog without pretending that everything belongs in active execution right now?

It owns backlog state: ideas recorded for later, deferred tasks, cleanup of stale backlog items, and bounded promotion from backlog into active tracking.

Keep the boundary explicit:
- stay here when the user wants to add an idea, defer work, clean backlog noise, or review deferred items for possible promotion
- hand off to `702-sg-priorities` when the user already has active tasks and wants the current execution order
- hand off to `700-sg-explore` when the idea is still too fuzzy to record cleanly without deeper thinking
- hand off to `703-sg-review` when the user wants a retrospective of what happened rather than backlog grooming

`701-sg-backlog` does not become the main prioritizer of active work, does not act like an open-ended ideation mode, and does not claim closure of a completed review cycle.

### Workspace root detection

If the current directory has no project markers (not inside a specific project), you are at the workspace root. Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`, then ask:
- Question: "Which project's backlog should I manage?"
- `multiSelect: false`
- Options:
  - **Full workspace** — "Inspect local project backlogs through project discovery" (Recommended)
  - One option per project: label = project name, description = backlog item count

### Steps

1. **Understand user intent** from `$ARGUMENTS`:
   - `add [description]`: Add new idea/task to backlog
   - `defer`: Move non-urgent tasks from TASKS.md to backlog
   - `review`: Review backlog items for promotion to active tasks
   - `clean`: Remove outdated/irrelevant backlog items
   - No argument: General backlog organization

2. **If adding to backlog**:
   - Create `shipglows_data/workflow/BACKLOG.md` if it doesn't exist for the selected project.
  - Use `shipglows_data/workflow/TASKS.md` for the selected project.
   - Add the idea with context, date, and category
   - Acknowledge addition and ask if it should be active now

3. **If deferring tasks**:
   - Review the selected project's `shipglows_data/workflow/TASKS.md` for low-priority or future items
   - Move them to `shipglows_data/workflow/BACKLOG.md` with reason for deferral
   - Keep the project workflow `TASKS.md` focused on current sprint/milestone
   - Update the project workflow `TASKS.md` to remove deferred items

4. **If reviewing backlog**:
   - Read all backlog items
   - Identify items that should become active tasks:
     - Changed context making them relevant now
     - Prerequisites completed
     - Strategic importance increased
   - Suggest promoting 1-3 items to the selected project's `shipglows_data/workflow/TASKS.md`
   - Explain reasoning for each promotion

5. **If cleaning backlog**:
   - Identify obsolete items (completed elsewhere, no longer relevant, duplicates)
   - Mark items for removal with explanation
   - Load `question-contract` and ask the user to confirm before deleting
   - Archive removed items in a "Discarded" section with date

6. **Organize BACKLOG.md structure**:
   ```markdown
   # Backlog

   ## Future Features
   - [ ] Feature idea (added YYYY-MM-DD)
     - Context: Why this matters
     - Blocked by: Prerequisites

   ## Technical Debt
   - [ ] Refactoring needed (added YYYY-MM-DD)
     - Impact: What improves
     - Effort: Estimated size

   ## Ideas & Research
   - [ ] Exploratory task (added YYYY-MM-DD)
     - Questions to answer
     - Expected outcome

   ## Deferred
   - [ ] Task moved from active (deferred YYYY-MM-DD)
     - Reason: Why deferred
     - Review after: Date or milestone

   ## Discarded
   - [x] Removed item (discarded YYYY-MM-DD)
     - Reason: Why removed
   ```

7. **Harvest code TODOs**:
   - Check for TODO/FIXME comments in codebase (shown in context)
   - Add any significant ones to backlog if not already tracked
   - Note file/line references

### Important

- Default to project-local `shipglows_data/workflow/BACKLOG.md` and `shipglows_data/workflow/TASKS.md` for project work.
- Update project-local `shipglows_data/workflow/TASKS.md` only when backlog triage changes active project tasks.
- Prefix portfolio backlog items with the project name (e.g., `- tubeflow: Native app feature parity`).
- Keep each project's active tracker focused (5-10 items max).
- Portfolio backlog sections can be larger (20-50 items across all projects).
- Always date entries (added/deferred/discarded)
- Preserve context - why the idea matters
- Use categories to organize
- Review backlog weekly to keep it relevant
- Don't let backlog become a graveyard - actively clean it
- When deferring, explain the reason (helps future review)
