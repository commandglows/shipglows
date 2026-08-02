# name

> Name the current work session so it stays visible in your statusline and notes.

## What It Does

`707-name` gives the current session a short label and saves it for later reference. It is useful when you work across many parallel tasks and want a persistent reminder of what this session is about.

## Who It's For

- Solo founders juggling multiple threads of work
- Operators who revisit the same session history later
- Anyone who wants lightweight session organization without renaming the full chat UI

## When To Use It

- when starting a focused task you want to track clearly
- when the scope of a session has changed and the old label no longer fits
- when you want the statusline to reflect the real objective of the session

## What You Give It

- a short session name
- no repo-specific context is required

## What You Get Back

- the session name saved to ShipGlows session notes
- the label reflected in the statusline on the next response
- easier recovery of context later

## Typical Examples

```bash
/name landing page rewrite
/name fix onboarding race condition
/name audit pricing funnel
```

## Limits

This skill tags the ShipGlows session only. It does not rename the chat in the sidebar, and it does not manage tasks, branches, or project metadata.

## Related Skills

- `102-sg-start` to execute the named task end to end
- `701-sg-backlog` to park work that should not stay active
- `703-sg-review` to summarize what happened in the session
