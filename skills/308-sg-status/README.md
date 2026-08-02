# 308-sg-status

> Show a fast cross-project git dashboard so you can see what needs attention across your portfolio.

## What It Does

`308-sg-status` reads a legacy-compatible project registry input as dashboard context and inspects each repo in read-only mode. It reports branch names, local uncommitted changes, ahead/behind status, recent commit activity, and stash presence, then filters the view to the repos that matter right now.

For a solo founder juggling multiple products, this replaces hopping repo by repo just to answer “what is dirty, behind, or waiting to be pushed?”

## Who It's For

- Solo founders running several repos at once
- Operators who want a quick daily git health check
- Anyone using ShipGlows as a workspace-level portfolio dashboard

## When To Use It

- when you want to know which projects need attention
- when you suspect local changes are scattered across repos
- when you want a fast “issues only”, “dirty only”, or “all projects” view

## What You Give It

- the legacy ShipGlows control-plane `PROJECTS.md` only as compatibility input (project-local discovery is the default)
- optionally a mode: `issues`, `dirty`, or `all`

## What You Get Back

- a compact dashboard of repo status across projects
- a “needs attention” section for uncommitted work, sync drift, detached heads, missing remotes, or stashes
- quick action suggestions for obvious next steps

## Typical Examples

```bash
/308-sg-status
/308-sg-status issues
/308-sg-status dirty
```

## Limits

`308-sg-status` is intentionally read-only. It does not fix repo state, pull, push, edit project-local trackers, or mutate legacy archive files. It reports what local discovery and git expose, not whether the code itself is good.

## Related Skills

- `005-sg-ship` to commit and push a dirty repo
- `703-sg-review` to review what changed in an active project
- `309-sg-tasks` when repo activity should update project tracking
