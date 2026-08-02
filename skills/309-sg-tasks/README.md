# 309-sg-tasks

> Keep project task tracking honest by updating what is done, what remains, and what should happen next.

## What It Does

`309-sg-tasks` maintains ShipGlows task trackers based on actual project evidence. It reviews current repo state, checks which tasks are truly complete, adds missing follow-up work, updates the master workspace tracker, and suggests the next priority item.

It is designed for operational clarity, not note-taking. The goal is to keep `TASKS.md` aligned with reality across both the local repo and the shared workspace dashboard.

## Who It's For

- Solo founders coordinating several projects from one workspace
- Developers who want backlog hygiene without manual bookkeeping
- Teams using `TASKS.md` as an active operations tracker

## When To Use It

- when work was completed and the tracker is stale
- when a repo has drifted from the master workspace backlog
- when you want a suggested next action based on blockers and dependencies

## What You Give It

- the current repo or workspace root
- existing `TASKS.md` files if they exist
- optionally a focus area or task type

## What You Get Back

- updated master `TASKS.md` entries
- updated local `TASKS.md` when relevant
- newly added tasks for unfinished work, docs, tests, or follow-ups
- changelog updates for tasks completed in the session
- a recommended next priority

## Typical Examples

```bash
/309-sg-tasks
/309-sg-tasks onboarding
/309-sg-tasks tests
/309-sg-tasks sessions /home/claude/temuglowz
/309-sg-tasks sessions rename done
/309-sg-tasks sessions prune /home/claude/temuglowz
/309-sg-tasks name-conversation
```

## Limits

`309-sg-tasks` is only as good as the evidence available in the repo. It should not mark work done based on intention alone, and it is not the right place to store long-lived product decisions or technical contracts. Those should move into dedicated artifacts.

## Related Skills

- `703-sg-review` for broader session review and planning
- `102-sg-start` when the next task should move into execution
- `005-sg-ship` when the work is ready to be committed and pushed

## Conversation mode

Use `sessions` to review and rename Codex session titles with the exact
project tracker statuses (`todo`, `doing`, `in_progress`, `blocked`, `done`).
The session title is a navigation/status layer, not a 1:1 mirror: several
sessions may point to one task. `TASKS.md` remains the work source of truth.
Link durable follow-up with `session_id`/`conversation_id`, without copying
transcripts into the tracker. The reusable method lives in
`shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md`.
Directories without a tracker are still valid session scopes through their
exact absolute `cwd`; the mode does not scaffold governance just to rename
sessions. For one subject, only the most recently active session remains open;
older high-confidence duplicates are marked `done`. Non-current sessions with
more than 30 days of inactivity are also marked `done`, without closing any
linked project task. These cleanup rules apply only to unmanaged titles. A
semantic title already shaped as `STATUS - work title` is skipped without
context inspection or mutation unless the operator explicitly requests a
refresh.

`sessions rename <status>` renames only the current Codex conversation. The
status must be `todo`, `doing`, `in_progress`, `blocked`, or `done`; the skill
derives the concrete work title from the visible conversation and persists
`STATUS - work title`. The work title summarizes the latest objective or its
outcome in at most five words and never truncates message text. It does not
inspect other sessions or update `TASKS.md`.

`sessions prune` previews old completed sessions for one exact project and
reclaims their rollout files only after explicit apply confirmation. It skips
the active thread, open statuses, unsafe or missing rollout paths, and every
other project. The default threshold is strictly more than 30 inactive days;
the default invocation is always non-mutating.
