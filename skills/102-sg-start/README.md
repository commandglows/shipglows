# 102-sg-start

> Start a task by actually implementing it, while forcing spec-first discipline when the scope is too risky to wing.

## What It Does

`102-sg-start` is the execution entrypoint for ShipGlows work. It decides whether a task is small enough to implement directly or whether it needs a ready spec first. Once the contract is clear, it reads only the necessary code, makes the change, runs focused validation, and reports what was done.

The skill is designed to preserve the promised user outcome, not just complete a technical diff.

## Who It's For

- Solo founders who want one command to begin real work
- Developers moving from task selection to implementation
- Teams that want guardrails without adding ceremony to simple changes

## When To Use It

- when you want to begin a task and expect code changes now
- when a tracker item should become implementation work
- when you want automatic routing between direct execution and spec-first flow
- when implementation depends on reproducing a broken auth or protected browser flow before fixing it
- when implementation depends on non-auth browser evidence such as visible state, console errors, or network failures

## What You Give It

- a task description or a selected `TASKS.md` item
- the current repo context
- optionally a ready spec if the work is non-trivial

## What You Get Back

- implemented code changes for the scoped task
- task tracking moved to in-progress
- focused validation results tied to the user story
- a concise execution report with the outcome, checks run, and documentation impact
- or a reroute to `100-sg-spec` and `101-sg-ready` if the contract is not strong enough
- when needed, an explicit diagnostic pass through `109-sg-auth-debug` before or during the implementation
- when needed, a route to `108-sg-browser` for non-auth browser proof before or after implementation
- development-mode-aware validation: local projects can validate locally, while Vercel-preview projects route next to `005-sg-ship` then `405-sg-prod` before browser/manual testing

## Typical Examples

```bash
/102-sg-start fix session timeout banner
/102-sg-start add project export endpoint
/102-sg-start
```

## Limits

`102-sg-start` is not meant to improvise through high-ambiguity work. If permissions, data boundaries, money movement, destructive actions, or external side effects are unclear, it should stop and require a better contract instead of coding a guess.

## Related Skills

- `100-sg-spec` to define non-trivial work
- `101-sg-ready` to validate the spec contract
- `109-sg-auth-debug` when the task depends on reproducing a Clerk, OAuth, or browser-session failure
- `108-sg-browser` when the task depends on non-auth page, visual, console, or network evidence
- `103-sg-verify` to judge whether the finished work is ready to ship
- `005-sg-ship` once the implementation is ready to commit and push
- `405-sg-prod` immediately after `005-sg-ship` when the project uses Vercel preview-push validation
