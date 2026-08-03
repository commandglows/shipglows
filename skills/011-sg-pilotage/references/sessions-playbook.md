---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 011-sg-pilotage
scope: pilotage-sessions-mode
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/011-sg-pilotage/SKILL.md
  - shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
  - tools/rename_codex_session.py
  - tools/prune_codex_sessions.py
depends_on:
  - artifact: shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
    artifact_version: "1.5.0"
    required_status: draft
supersedes: []
evidence:
  - "Transferred from the session contract of 309-sg-tasks under the approved pilotage consolidation."
next_step: "$011-sg-pilotage sessions"
---

# Sessions Mode Playbook

## Outcome And Required Loader

Keep Codex conversation titles useful as a repository-scoped status/navigation layer without confusing sessions with project tasks. Load `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md` before inspecting or mutating Codex state; it remains the detailed source of truth.

Project work lives in `shipglows_data/workflow/TASKS.md`. Codex titles live in `~/.codex/state_5.sqlite`, table `threads`. Link durable follow-up with `session_id` or `conversation_id`; several sessions may support one task. Never copy transcripts into trackers and never infer a task as `done` from a final message or session cleanup.

## Exact Grammar

- `sessions [project-or-cwd]`: triage unmanaged titles for one exact repository scope.
- `sessions rename <status>`: rename only the current Codex conversation.
- `sessions prune [cwd]`: preview or explicitly apply safe cleanup of old completed sessions.

Accepted statuses are exactly `todo`, `doing`, `in_progress`, `blocked`, or `done`, persisted as an uppercase prefix in `<STATUS> - <work title>`. The semantic work title contains at most five words.

## Repository Triage

1. Resolve the exact absolute `cwd`; never scope by a project-name text match.
2. Read an existing canonical local tracker when present, but create no tracker or governance tree solely for session cleanup.
3. Query only sessions whose stored `cwd` equals the exact target.
4. Skip a managed canonical title completely when its semantic work title is non-generic and at most five words; ordinary triage does not read its context, reclassify it, apply duplicate/inactivity cleanup, or mutate a linked task.
5. For each unmanaged title, read the complete available conversation chronology through the latest objective and outcome. A preview, first message, or existing title is not sufficient.
6. Keep the newest high-confidence same-subject unmanaged session open and mark older duplicates `done`; never change linked task status.
7. Mark an unmanaged non-current session inactive for strictly more than 30 days as `done` unless evidence proves a named blocker or intentional active work. The current thread is never auto-closed.
8. Classify remaining unmanaged sessions conservatively. Missing implementation or proof means `todo`, `in_progress`, or `blocked`, not `done`.
9. Derive an original semantic title from the latest objective or achieved outcome. Never use prefix slicing, first-N-word extraction, stop-word filtering, or character truncation. Leave ambiguous titles unchanged.
10. Mutate only the selected unmanaged title rows, then re-read and report renamed mappings, skipped-managed count, tracker links, and ambiguity.

## Current Session Rename

`sessions rename <status>` requires an explicit supported status before any rename-related work.

`CONVERSATION-RENAME-MISSING-STATUS`: when the status is missing or unsupported, ask for exactly one supported status and do not derive a title, inspect sessions, call the helper, or mutate Codex or `TASKS.md`.

With a valid status:

1. derive one non-generic semantic work title from the visible conversation's latest objective or outcome;
2. resolve and preflight `$SHIPGLOWS_ROOT/tools/rename_codex_session.py`;
3. invoke it with the unprefixed title, exact current `cwd`, and `CODEX_THREAD_ID`;
4. accept its verified persisted result or its explicit recoverable error.

The explicit command authorizes this one rename without a second confirmation. It never inspects other conversations, follows forks, or mutates `TASKS.md`. A missing/invalid thread id, stored-cwd mismatch, generic title, control character, existing status prefix, or title over five words fails without mutation. Repeating the same valid title is an idempotent success.

## Project Session Prune

Resolve and preflight `$SHIPGLOWS_ROOT/tools/prune_codex_sessions.py`; never reproduce SQL, native deletion, or rollout-file deletion ad hoc.

- The default is a mutation-free dry-run.
- Candidates must use the exact absolute `cwd`, have a canonical `DONE - ...` title, and be inactive for strictly more than 30 days.
- Always exclude the current thread identified by `CODEX_THREAD_ID`.
- Preserve missing or unsafe rollout paths and every other project's session.
- Apply requires `--apply` plus exact apply confirmation through `--confirm-cwd` equal to the resolved absolute target.
- Reject unsafe descendant trees, open spawn edges, noneligible descendants, or active agent work; collapse only safe eligible descendants under one root.
- Delegate to the supported native `codex delete --force <UUID>` path, stop on the first native deletion failure, verify outcomes, and report verified deletions, failed root, native-success-but-unverified roots, and unattempted roots.
- Never run `VACUUM` and never mutate titles or project trackers during prune.

## Security And Privacy

Treat thread ids, statuses, cwd values, rollout paths, database paths, and conversation content as untrusted private inputs. Expose no transcript, raw SQLite content, secret, token, cookie, credential, private payload, or unnecessary private path in trackers, public docs, tests, or reports. Preserve other threads, projects, auxiliary rows, rollout files, and active jobs unless the helper's exact verified plan owns them.

## Pressure Scenarios

- `CONVERSATION-CWD-COLLISION`: exact cwd prevents cross-project mutation.
- `CONVERSATION-IDEMPOTENT-SKIP`: a canonical semantic title receives no ordinary-triage reads or writes.
- `CONVERSATION-CLOSURE-OVERCLAIM`: weak proof never closes a linked task.
- `CONVERSATION-TRACKER-ABSENT`: triage creates no governance solely for cleanup.
- `CONVERSATION-SUBJECT-DUPLICATION`: only high-confidence older duplicates close.
- `CONVERSATION-INACTIVE-30D`: the cutoff is more than 30 days, not 30 days or more.
- `CONVERSATION-RENAME-MISSING-STATUS`: invalid input triggers one status question and zero rename work.
- `CONVERSATION-TITLE-TRUNCATION`: the latest objective is summarized semantically, never mechanically shortened.
- `SESSION-PRUNE-DRY-RUN`: preview performs no writes.
- `SESSION-PRUNE-CWD-ISOLATION`: exact cwd excludes every other repository.
- `SESSION-PRUNE-ACTIVE-EXCLUSION`: the current thread is never selected.
- `SESSION-PRUNE-CONFIRMATION`: apply fails before staging without exact confirmation.
- `SESSION-PRUNE-NATIVE-FAILURE`: mutation stops at the first failed native deletion.

## Output

Report the selected sub-action, exact scope without unnecessary private-path disclosure, changed/skipped/ambiguous counts, tracker links when justified, dry-run/apply truth, validation, and the next recoverable action. Never report session cleanup as project-task completion.
