# 701-sg-backlog

> Keep active work focused while safely parking ideas, deferred tasks, and future improvements.

## What It Does

`701-sg-backlog` manages project-local ShipGlows backlog files and can coordinate a portfolio backlog when explicitly asked. It helps capture new ideas, defer non-urgent work, review what should be promoted next, and clean out stale items before the backlog turns into noise.

The core value is focus: active work stays small, while future work remains searchable and structured.

## Who It's For

- Solo founders balancing shipping speed with a long list of ideas
- Operators managing several products from one workspace
- Teams that want task hygiene without losing good future work

## When To Use It

- when a good idea should not interrupt the current task
- when active tasks have grown bloated and need pruning
- when you want a review of what is worth promoting now

## What You Give It

- an optional mode such as `add`, `defer`, `review`, or `clean`
- a project context if the idea belongs to a specific product
- an existing ShipGlows project with `shipglows_data/workflow/TASKS.md` or `shipglows_data/workflow/BACKLOG.md` tracking

## What You Get Back

- backlog entries added or reorganized in the selected project's workflow tracker, or in the external portfolio tracker only for workspace-level coordination
- a cleaner separation between now, later, and probably never
- recommendations on what to activate or discard

## Typical Examples

```bash
/701-sg-backlog
/701-sg-backlog add pricing page experiment ideas
/701-sg-backlog review
```

## Limits

This skill is for task organization, not prioritization strategy by itself. It preserves ideas and trims clutter, but it does not replace product judgment on what matters most.

## Related Skills

- `702-sg-priorities` to reorder work by impact and effort
- `309-sg-tasks` to update active project tasks
- `102-sg-start` when a backlog item becomes real execution work
