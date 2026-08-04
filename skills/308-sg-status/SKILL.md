---
name: 308-sg-status
description: "Report cross-project git status, sync state, and issues."
disable-model-invocation: true
argument-hint: [optional: all | issues | dirty]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise dashboard, attention items, limits, and `Chantier: non applicable` only when useful. Use `report=agent` when another skill needs the full project matrix, skipped paths, and command evidence.

## Required References

- Load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before asking for dashboard view mode.

## Mission

Report cross-project git status, sync state, and attention items without mutating project governance.

`308-sg-status` answers one reporting question:

```text
What is the current git/sync state across the portfolio, and which repos need attention first?
```

Keep the boundary explicit: `308-sg-status` reports state only. It does not route broad project work, continue a chantier, or mutate trackers, governance, or git state.

Route away instead of staying in `308-sg-status` when the operator really needs:

- the next maintenance or lifecycle owner to act on one repo -> `002-sg-maintain`, `005-sg-ship`, or the narrower owner skill
- context priming for one known task -> `301-sg-context`
- generic route selection or workflow explanation -> `000-shipglows` or `302-sg-help`

## Context

- Current directory: !`pwd`
- Derived project registry (primary): `find`-style scan of workspace roots for directories containing `shipglows_data/` (project-local governance roots). Legacy fallback: `cat local project discovery (`shipglows_data/` markers)` (legacy mode only).

## Flow

### Step 0: Choose view mode

If `$ARGUMENTS` is empty, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`, then ask:
- Question: "Quelle vue du dashboard veux-tu ?"
- `multiSelect: false`
- Options:
  - **Issues only (recommandé)** — "Affiche seulement les projets avec attention requise"
  - **Dirty only** — "Affiche seulement les projets avec changements locaux"
  - **All projects** — "Affiche tout le portefeuille"

If `$ARGUMENTS` is provided, map:
- `issues` -> issues only
- `dirty` -> dirty only
- any other value -> all projects

### Step 1: Read project registry

Derive project paths by scanning workspace roots and project-local markers (`shipglows_data/`), then include ShipGlows itself (`${SHIPGLOWS_ROOT:-$HOME/shipglows}`). Use `local project discovery (`shipglows_data/` markers)` only as legacy compatibility fallback when local discovery is unavailable.

`308-sg-status` must not read the external registry as project governance truth. It is a dashboard input only; per-project governance remains under each project's local `shipglows_data/{business,technical,editorial,workflow}` corpus and is not mutated here.

### Step 2: Gather git status for each project

Before running git commands, normalize registry paths:
- If the registry path starts with `~/`, expand it against the current `$HOME`.
- If the registry path starts with `$HOME/`, expand it against the current `$HOME`.
- If the registry path starts with `/home/<other-user>/` and that path does not exist, retry with the same suffix under the current `$HOME`.
- If neither the original path nor the normalized fallback exists, skip the project.

For each project path, run these git commands (skip if path doesn't exist or isn't a git repo):

```bash
git -C [path] rev-parse --abbrev-ref HEAD 2>/dev/null    # Current branch
git -C [path] status --porcelain 2>/dev/null | wc -l     # Uncommitted changes count
git -C [path] rev-list --count @{upstream}..HEAD 2>/dev/null  # Commits ahead
git -C [path] rev-list --count HEAD..@{upstream} 2>/dev/null  # Commits behind
git -C [path] log -1 --format="%ar — %s" 2>/dev/null     # Last commit
git -C [path] stash list 2>/dev/null | wc -l              # Stashed changes
```

Run all projects in parallel using available parallel agent/tooling when present, or sequentially with Bash if fast enough (<10s total).

### Step 3: Compile dashboard

```
══════════════════════════════════════════════════════════════════════
GIT STATUS DASHBOARD — [date]
══════════════════════════════════════════════════════════════════════

| Project          | Branch   | Uncommitted | Ahead | Behind | Last Commit           |
|------------------|----------|-------------|-------|--------|-----------------------|
| my-robots        | main     | 0           | 0     | 0      | 2d ago — Add SEO crew |
| tubeflow         | feat/ui  | 3           | 2     | 0      | 1h ago — Fix layout   |
| GoCharbon        | main     | 0           | 0     | 5      | 3d ago — New post     |
| ...              |          |             |       |        |                       |
| ShipGlows         | main     | 1           | 1     | 0      | 10m ago — Update tasks|

──────────────────────────────────────────────────────────────────────
```

Apply selected filter before rendering:
- **issues only**: show projects with uncommitted, ahead/behind, no remote, detached HEAD, or stash > 0
- **dirty only**: show projects with uncommitted > 0
- **all projects**: show all valid repos

### Step 4: Highlight issues

```
NEEDS ATTENTION
  ⚠️  tubeflow — 3 uncommitted changes on feat/ui
  ⚠️  GoCharbon — 5 commits behind remote
  ⚠️  ShipGlows — 1 uncommitted change (TASKS.md?)

QUICK ACTIONS
  → tubeflow: /005-sg-ship to commit and push
  → GoCharbon: git -C $HOME/GoCharbon pull
```

Only show NEEDS ATTENTION if there are issues. Issues to flag:
- Uncommitted changes (>0)
- Behind remote (>0)
- Ahead of remote (>0, may need push)
- Detached HEAD
- No remote configured
- Stashed changes (>0)

---

## Important

- **READ-ONLY** — never modify any files or run git commands that change state.
- `local project discovery (`shipglows_data/` markers)` is legacy-only read-only input here; do not treat it as active truth.
- Do not update project-local `shipglows_data/workflow/TASKS.md` or any legacy control-plane trackers from `308-sg-status`; route follow-up work to the explicit `011-sg-pilotage tasks`, `backlog`, `priorities`, or `review` mode, or to `005-sg-ship`.
- Prefer storing home-scoped project paths as `~/...` in local project metadata for portability across usernames and servers.
- Include ShipGlows repo itself in the dashboard.
- Skip projects whose paths don't exist on disk.
- Skip SocialFlowz if it has no git repo.
- Target execution time: under 10 seconds total.
- If a project has no remote tracking branch, show "no remote" instead of ahead/behind counts.
