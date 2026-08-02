# 703-sg-review

> Turn recent work into a usable review: what changed, what is actually verified, and what should happen next.

## What It Does

`703-sg-review` closes the loop on a work period. It inspects recent commits, changed files, task trackers, and changelog state, then produces a review artifact that separates evidence from assumptions.

This skill is useful when you want more than a git summary. It helps you reconstruct the user-facing outcome, flag stale docs or weak validation, update task tracking, and prepare the next session with concrete priorities.

## Who It's For

- Solo founders working across several repos
- Operators who want honest closure instead of vague “done”
- Builders who need a lightweight weekly or release review habit

## When To Use It

- when you want a daily, weekly, sprint, or release review
- when a session touched multiple files and you need a clean handoff
- when you want to update the project workflow tracker and `CHANGELOG.md` based on evidence
- when you need next-step priorities after a burst of shipping

## What You Give It

- the current repo or workspace root
- an optional scope: `daily`, `weekly`, `sprint`, or `release`
- normal project evidence: git history, task trackers, changelog, docs

## What You Get Back

- a review report saved under the project workflow review corpus when available
- updated task tracking in the project-local `shipglows_data/workflow/TASKS.md`, with external portfolio updates only for workspace-scoped reviews
- changelog updates for user-facing work
- a concise summary of completed, in-progress, blocked, and risky work
- 1-3 recommended next tasks

## Typical Examples

```bash
/703-sg-review
/703-sg-review weekly
/703-sg-review release
```

## Limits

`703-sg-review` is a review aid, not a guarantee that the product is finished or safe. It can assess evidence, but it cannot invent missing validation. If tests, docs, or functional checks are absent, the report should stay explicit about that gap.

## Related Skills

- `309-sg-tasks` for standalone tracker maintenance
- `103-sg-verify` to judge ship-readiness of a specific change
- `005-sg-ship` when you want to commit and push after formal closure
- `102-sg-start` when the next step is to execute a prioritized task
