---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "1.4.1"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-18"
status: draft
source_skill: 309-sg-tasks
scope: conversation-tracker-sync
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/309-sg-tasks/SKILL.md
  - shipglows_data/workflow/TASKS.md
  - ~/.codex/state_5.sqlite
  - tools/prune_codex_sessions.py
  - tools/rename_codex_session.py
depends_on: []
supersedes: []
evidence:
  - "Operator request on 2026-07-15: reuse the Codex conversation rename workflow as a task-tracker mode."
  - "Codex UI session titles are stored in the local threads table; project tasks are stored in the local TASKS.md tracker."
  - "Operator decision on 2026-07-16: tracker-less cwd scopes remain valid, older same-subject sessions close, and sessions inactive for more than 30 days close without changing linked task completion."
  - "Operator decision on 2026-07-16: project session cleanup uses a dry-run-first prune that excludes the active thread and open work."
  - "Operator decision on 2026-07-16: sessions rename <status> renames only the current Codex conversation using STATUS - semantic title."
  - "Operator correction on 2026-07-16: session names summarize the latest conversation objective or its outcome in at most five words and never truncate message text."
  - "Operator decision on 2026-07-18: a missing rename status must not be inferred or trigger any session or tracker mutation."
next_review: "2026-08-15"
next_step: "/309-sg-tasks sessions <project>"
---

# Codex Sessions Status Playbook

## Purpose

Keep Codex conversation names useful as a project navigation layer while
keeping project work in the local `TASKS.md` tracker. The two records are linked
when a conversation creates or advances durable work. This is a many-to-one
relationship: several sessions may support the same task, especially after a
fork or a context-reuse session.

## Applicability

Use for a repository-wide conversation review, a cleanup of stale session names,
or a single conversation rename. Invoke:

```text
/309-sg-tasks sessions <project-or-cwd>
/309-sg-tasks sessions rename <status>
/309-sg-tasks sessions prune <project-or-cwd>
/309-sg-tasks name-conversation
```

## Inputs

- exact project root / `cwd`;
- local `shipglows_data/workflow/TASKS.md`;
- Codex `~/.codex/state_5.sqlite`, table `threads`;
- conversation preview or first user message, when available;
- implementation and proof evidence needed to judge closure.

## Status Contract

Use the exact tracker vocabulary in both the thread title and any linked task:

| Status | Meaning |
| --- | --- |
| `todo` | identified, not started |
| `doing` | actively being executed now |
| `in_progress` | started but not ready to close |
| `blocked` | cannot advance without a named dependency or decision |
| `done` | implementation and required proof are complete |

Use a short title shaped as `<STATUS> - <work title>`, with the tracker status
uppercased. The work title contains at most five words; the status prefix does
not count. Keep the original Codex thread `id` unchanged.

The work title is the navigation label, not a workflow label: it must expose
the concrete object, system, or outcome at the heart of the conversation.
Reject generic labels such as `Review work`, `Review ContentGlowz work`,
`General task`, or a skill name alone.

Derive the work title from the complete available conversation chronology.
Always summarize the latest user objective or its achieved outcome; earlier
objectives may only disambiguate it. A SQLite preview, the first message, or an
existing title may locate the conversation but is not sufficient naming
evidence. Never form a title through prefix slicing, first-N-word extraction,
stop-word filtering, or character truncation. If the conversation cannot be
read far enough to identify its latest objective confidently, leave the title
unchanged and report it as ambiguous.

## Incremental Idempotence Gate

A title matching `^(TODO|DOING|IN_PROGRESS|BLOCKED|DONE) - .+` is already
managed when its work title is not a prohibited generic label and contains at
most five words. On ordinary
`sessions` runs, skip it completely: do not read its preview or first message,
reclassify its status, rewrite its title, apply duplicate or inactivity rules,
or mutate a tracker record linked to it.

Only unmanaged titles enter triage. An operator may override this gate by
explicitly asking to refresh existing titles or by naming thread ids.

## Project Session Prune

Use `sessions prune` to reclaim rollout disk space without deleting active
work. Resolve and preflight `$SHIPGLOWS_ROOT/tools/prune_codex_sessions.py`, then
invoke the tool instead of writing ad hoc SQL or deleting rollout files from
the agent.

The default run is a dry-run. Candidate sessions must all match the exact
absolute `cwd`, have a canonical `DONE - ...` title, and be inactive for
strictly more than 30 days. The current `CODEX_THREAD_ID` is always excluded.
Missing or unsafe rollout paths are reported and preserved.

An apply run requires `--apply` and `--confirm-cwd` equal to the resolved
absolute target. The planner rejects unsafe descendant trees, collapses
eligible descendants under one root, and delegates mutation to the supported
native `codex delete --force <UUID>` command. It stops on the first native
failure, verifies outcomes, and never runs `VACUUM`. Pruning never mutates
`TASKS.md`, session titles, or another project's state directly.

Pressure scenarios:

- `SESSION-PRUNE-DRY-RUN`: preview performs no writes.
- `SESSION-PRUNE-CWD-ISOLATION`: exact cwd prevents cross-project deletion.
- `SESSION-PRUNE-ACTIVE-EXCLUSION`: the current thread is never pruned.
- `SESSION-PRUNE-CONFIRMATION`: apply fails before staging without exact confirmation.
- `SESSION-PRUNE-SUBTREE-SAFETY`: cross-cwd, current, open, noneligible, or active-job descendants block their root.
- `SESSION-PRUNE-NATIVE-FAILURE`: stop after the first failed native deletion and report a retryable partial result.

## Current Session Rename

Use `sessions rename <status>` only after the operator explicitly invokes it
with a supported status. If `sessions rename` omits or supplies an unsupported
status, ask for exactly one supported status (`todo`, `doing`, `in_progress`,
`blocked`, or `done`) and do not derive a title, inspect sessions, call the
helper, or mutate Codex or `TASKS.md`. With a valid status, derive a concise
semantic work title from the visible conversation, resolve and
preflight `$SHIPGLOWS_ROOT/tools/rename_codex_session.py`, then pass the status
and unprefixed work title to the helper. The explicit command authorizes this
single rename, so no second confirmation is needed.

The helper accepts only the status contract vocabulary and work titles of at
most five words, resolves the current
conversation from `CODEX_THREAD_ID`, requires its stored cwd to equal the exact
absolute current cwd, writes only `threads.title`, and verifies the persisted
value. It rejects generic or already-prefixed work titles. Do not inspect or
rename other conversations, follow forks, or mutate `TASKS.md` in this mode.

Pressure scenarios:

- `SESSION-RENAME-CURRENT-ONLY`: only `CODEX_THREAD_ID` changes.
- `SESSION-RENAME-CWD-ISOLATION`: a cwd mismatch fails without mutation.
- `SESSION-RENAME-STATUS-GATE`: unsupported statuses fail before mutation.
- `CONVERSATION-RENAME-MISSING-STATUS`: a missing status asks for exactly one
  supported status and does not derive a title, inspect sessions, call the
  helper, or mutate Codex or `TASKS.md`.
- `SESSION-RENAME-SEMANTIC-GATE`: empty, generic, control-character, or already-prefixed work titles fail.
- `SESSION-RENAME-FIVE-WORD-GATE`: a six-word work title fails without mutation.
- `SESSION-RENAME-IDEMPOTENT`: repeating the same title is a successful no-op.

## Execution Order

1. Resolve the exact absolute `cwd`. Read the current local tracker when it
   exists. If the directory has no tracker, keep the `cwd` as the session scope
   and do not create `TASKS.md` or `shipglows_data/` solely for this review.
2. Query only `id` and `title` using exact `cwd`; never match by project name in text.
3. Partition rows through the incremental idempotence gate and stop processing managed rows.
4. Read the complete available chronology only for unmanaged sessions, through
   the latest objective and outcome, to derive the work title, subject, last
   activity, and evidence state. Do not substitute SQLite preview fields for
   the conversation.
5. Group only high-confidence same-subject unmanaged sessions. Prefer normalized exact
   matches or clear semantic equivalence; leave ambiguous neighboring topics
   separate. Keep the row with the latest activity timestamp as the canonical
   open session and mark older duplicates `done`.
6. Mark an unmanaged non-current session `done` when its latest activity is more than 30
   days old, unless its context explicitly proves a named blocker or intentional
   continuing work. This is session cleanup, not proof that a linked task is
   complete.
7. Classify the remaining unmanaged thread using the status contract. Treat missing proof as
   `in_progress`, `todo`, or `blocked`, not as `done`.
8. Derive an original semantic work title of at most five words from the latest
   objective or its achieved outcome. Do not copy or mechanically shorten
   message text. Leave the title unchanged and report ambiguity when the
   available chronology is insufficient.
9. Update only unmanaged `threads.title` rows in SQLite so the Codex UI reflects the result.
10. If durable follow-up exists and a project tracker exists, update one canonical `task` record in
   `TASKS.md` and add `session_id: <thread id>` (or preserve an existing
   `conversation_id` field). Follow the operational-record format.
11. Re-read the SQLite source and any existing tracker, then report the renamed mapping, skipped-managed count, unresolved ambiguity, and
   next action.

## Decision Gates

- `done` requires concrete implementation evidence and the relevant proof
  path when updating a project task. A session title may also become `done`
  through the duplicate or 30-day cleanup rules, but that must not mark a
  linked task `done`.
- The current thread is never auto-closed by duplicate or inactivity cleanup.
- Already managed semantic titles are immutable during ordinary `sessions` runs, even when their status appears stale or they resemble another managed conversation.
- Choose the newest same-subject session by the best available activity field
  (`recency_at_ms`, then `updated_at_ms`); preserve all thread ids and content.
- A conversation without durable project follow-up gets a renamed session but
  no synthetic tracker row.
- A task may link to several conversation ids, but one conversation id must
  not create duplicate task records.
- Sessions from another `cwd`, private data, or unrelated projects are out of
  scope and must remain unchanged.
- Never put transcripts, secrets, cookies, tokens, or private payloads in the
  tracker.

## Outputs

- renamed Codex thread titles;
- tracker rows created or updated only for durable follow-up;
- explicit list of ambiguous or blocked conversations;
- compact report with validation and next step.

## Linked Checklists

No separate execution checklist is required for the first mode. A future
checklist may capture a batch review, but the playbook remains the reusable
method and `TASKS.md` remains the operational record.

## Failure Modes

- `ok`/`cours` or other legacy labels remain in titles: normalize to the exact
  tracker vocabulary.
- the UI does not reflect a rename: verify SQLite `threads.title`; updating
  only `session_index.jsonl` is insufficient for the session list.
- a project-name text match catches unrelated sessions: rerun with exact
  `threads.cwd` filtering.
- a tracker-less workspace gets a synthetic governance tree: revert that
  tracker creation and keep the exact `cwd` as the session-only scope.
- several sessions cover the same subject: keep only the most recently active
  session open and mark older high-confidence duplicates `done`.
- an inactive session remains open without explicit override evidence: apply
  the strict `more than 30 days` cutoff; do not use `30 days or more`.
- closure is uncertain: keep the session open under `in_progress`, `todo`, or
  `blocked` and name the missing evidence.
- prune reports candidates but the operator did not request apply: stop after
  the preview; a dry-run is the successful default outcome.
- current-session rename lacks `CODEX_THREAD_ID`, has a cwd mismatch, or cannot
  derive a semantic work title: stop without changing any thread or tracker.
- current-session rename lacks a supported status: ask for exactly one supported
  status before any rename-related read or mutation.

## Validation

```bash
rg -n "CONVERSATION-TRACKER-ABSENT|CONVERSATION-SUBJECT-DUPLICATION|CONVERSATION-INACTIVE-30D|more than 30 days|current thread" \
  /home/claude/shipglowz/skills/309-sg-tasks/SKILL.md \
  /home/claude/shipglowz/shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
python3 /home/claude/shipglowz/tools/shipglows_metadata_lint.py \
  /home/claude/shipglowz/shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
python3 -m unittest tools.test_rename_codex_session
```
