# 702-sg-priorities

> Re-rank your task backlog so the next thing you do is the one that matters most.

## What It Does

`702-sg-priorities` reviews open tasks and reorders them using impact, effort, blockers, dependencies, and delivery risk. It defaults to the selected project's local `shipglows_data/workflow/TASKS.md` and uses the external portfolio tracker only when the run is workspace-scoped.

The point is not to create a perfect roadmap. The point is to stop a founder from spending a day on low-value work while the real blocker sits untouched.

## Who It's For

- Solo founders juggling several products or experiments
- Operators managing local project trackers and optional portfolio coordination
- Teams that need a clearer P0 before starting a new work session

## When To Use It

- when the backlog feels noisy or stale
- when too many tasks look equally urgent
- after a strategy change, launch, outage, or major customer signal

## What You Give It

- a ShipGlows project with `shipglows_data/workflow/TASKS.md`, or an explicit workspace/portfolio scope
- optionally, a prioritization angle such as `impact`, `effort`, `blockers`, or `high-roi` / `quick-wins`
- optionally, a project name when you do not want a workspace-wide pass

## What You Get Back

- updated priority buckets
- clearer P0/P1/P2/P3 separation
- rationale for the top tasks
- a recommendation for what to start next

## Typical Examples

```bash
/702-sg-priorities
/702-sg-priorities high-roi
/702-sg-priorities blockers
```

## Limits

- Priority quality depends on the quality of the task list.
- It can organize work, but it cannot invent missing product strategy.
- If tasks are vague or outdated, they may need refinement before the ranking becomes reliable.

## Related Skills

- `309-sg-tasks` to clean up the backlog structure
- `102-sg-start` once the top task is chosen
- `303-sg-resume` for a fast thread-level status snapshot
