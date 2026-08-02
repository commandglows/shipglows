---
name: 702-sg-priorities
description: "Prioritize work by impact, effort, blockers, and ROI."
disable-model-invocation: false
argument-hint: [optional priority criteria: impact, effort, blockers, high-roi/quick-wins]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `pilotage`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active `specs/*.md` chantier is identified, append the current run to `Skill Run History`, update `Current Chantier Flow` when the run changes the chantier state, and open the report with the opening chantier header. If no unique chantier is identified, do not write to any spec; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise priority recommendation, tracker changes, proof gaps, and opening chantier header when applicable. Use `report=agent` for detailed scoring matrices, tracker anchors, or handoff state.

## Required References

- Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking project or prioritization-scope questions.
- Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before creating or mutating task operational records in `TASKS.md`.


## Context

- Current directory: !`pwd`
- Project workflow TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project TASKS.md"`
- Project-local TASKS.md: !`cat shipglows_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Git branch and status: !`git status --short --branch 2>/dev/null || echo "Not a git repo"`
- Recent commits: !`git log --oneline -5 2>/dev/null || echo "N/A"`
- Project CLAUDE.md: !`head -40 CLAUDE.md 2>/dev/null || echo "No CLAUDE.md"`
- Workspace CLAUDE.md: !`head -20 $HOME/CLAUDE.md 2>/dev/null || echo "N/A"`

## Operational tracker model

Prioritization is local-first for project work.

- For a selected project, prioritize within `[project]/shipglows_data/workflow/TASKS.md`.
- Root `TASKS.md` is a legacy project tracker location; read it as a migration/fallback source only when canonical workflow tasks are absent.
- Legacy central archives are migration evidence only. Prefer local project discovery (`shipglows_data/` markers) and project-local trackers.
- When re-ranking portfolio work, report a derived view from local trackers; do not update a central Dashboard table.
- If the user specifies a project name as argument, focus prioritization on that project's local workflow tracker unless they explicitly ask for portfolio coordination.

## Shared tracking file write protocol

- Before creating or mutating task operational records, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md`.
- Treat the TASKS snapshots loaded at skill start as informational only.
- Right before editing the project or portfolio TASKS file, re-read the target from disk and use that version as authoritative.
- Apply a minimal targeted edit to the relevant dashboard rows and task sections; never rewrite the whole file from stale context.
- If the expected anchor moved or changed, re-read once and recompute.
- If it is still ambiguous after the second read, stop and ask the user instead of forcing the write.

## Your task

Analyze all tasks and reorganize them by priority using a smart prioritization framework.

This skill answers one operator question: among the active tasks already on the table, what should we do first now and why?

It owns current ranking of active work inside the selected task tracker, including explicit impact/effort/blocker reasoning and the recommendation for the next execution target.

Keep the boundary explicit:
- stay here when the user wants current execution order, tie-breaking, or impact/effort/blocker ranking across active tasks
- hand off to `701-sg-backlog` when the main need is to capture, defer, or clean future work instead of ranking current work
- hand off to `700-sg-explore` when the work is still too fuzzy to score credibly
- hand off to `703-sg-review` when the user wants a retrospective of completed or partial work rather than a forward ranking

`702-sg-priorities` does not serve as a generic idea inbox, does not replace backlog hygiene, and does not treat review bookkeeping as prioritization by another name.

### Workspace root detection

If the current directory has no project markers (no `package.json`, no `src/` dir) BUT contains multiple project subdirectories, you are at the workspace root. Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`, then ask:
- Question: "Which project(s) should I prioritize?"
- `multiSelect: true`
- Options:
- **All projects** — "Re-prioritize across discovered local projects" (Recommended)
  - One option per project with active tasks: label = project name, description = number of open tasks
- Read local project list from project-local discovery (`shipglows_data/` markers).

### Steps

1. **Parse existing tasks**:
- Read all tasks from the selected project's `shipglows_data/workflow/TASKS.md`, or root `TASKS.md` only as legacy project fallback.
   - Categorize by status: completed, in progress, todo
   - Identify task dependencies and blockers

2. **Analyze each uncompleted task** using criteria:
   - **Impact**: How much value does this deliver? (High/Medium/Low)
   - **Effort**: How much work is required? (High/Medium/Low)
   - **Blockers**: Does this unblock other tasks? (Yes/No)
   - **Dependencies**: What must be done first?
   - **Risk**: What happens if we delay this?

3. **Apply prioritization logic**:
   - P0 (Critical): Blockers, security/bugs, high impact + bounded effort
   - P1 (High): High impact + medium effort, important features
   - P2 (Medium): Medium impact, or high effort without clear blocker
   - P3 (Low): Nice to have, low impact, can wait

4. **Consider user's criteria** (`$ARGUMENTS`):
   - `impact`: Prioritize by business/user value
   - `effort`: Show high-impact bounded-effort tasks first
   - `blockers`: Prioritize tasks that unblock others
   - `quick-wins` / `high-roi`: Focus on high-impact, bounded-effort tasks
   - If no argument, use balanced approach

5. **Update the selected TASKS.md** with priority sections:
   ```markdown
   # Tasks

   ## Completed
   - [x] Done items

   ## 🔴 P0 - Critical (Do First)
   - [ ] Blocker task [Impact: High | Effort: Low | Unblocks: 3 tasks]

   ## 🟠 P1 - High Priority
   - [ ] Important task [Impact: High | Effort: Medium]

   ## 🟡 P2 - Medium Priority
   - [ ] Standard task [Impact: Medium | Effort: Medium]

   ## 🟢 P3 - Low Priority
   - [ ] Nice to have [Impact: Low | Effort: High]

   ## Notes
   - Priority last updated: [date]
   - Prioritization criteria: [criteria used]
   ```

6. **Provide priority summary**:
   - List P0 tasks with why they're critical
   - Suggest which P0 task to start immediately
   - Note any dependencies or prerequisites
   - Highlight high-ROI bounded-effort opportunities if present

### Important

- Default to the selected project's `shipglows_data/workflow/TASKS.md` for project priority edits.
- Update project-local `shipglows_data/workflow/TASKS.md` for selected project priority changes.
- Use Edit tool to update the target TASKS.md with priority markers
- Be realistic about impact/effort assessments
- Consider technical debt alongside features
- Flag tasks with missing context as needing refinement
- Explain your prioritization reasoning clearly
- If tasks seem equally important, break ties by effort without letting ease of execution outrank strategic value
- Update "Priority last updated" timestamp
- Update the external Dashboard table's "Top Priority" column only when the run is portfolio-scoped and the dashboard exists.
