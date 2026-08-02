---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: ready
source_skill: 900-shipglows-core
scope: codex-current-session-rename
owner: Diane
user_story: "As a Codex operator, I want to rename the current conversation with a canonical status and semantic title so the session list shows its real work state at a glance."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/309-sg-tasks/SKILL.md
  - skills/309-sg-tasks/README.md
  - shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
  - tools/rename_codex_session.py
depends_on:
  - artifact: shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
    artifact_version: "1.2.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator request on 2026-07-16: add sessions rename <status> for the current Codex conversation using STATUS - semantic title."
next_step: "/005-sg-ship Codex current session rename"
---

# Codex Current Session Rename

## Goal

Add `/309-sg-tasks sessions rename <status>` as an explicit, deterministic way
to rename only the current Codex conversation to `<STATUS> - <work title>`.

## Contract

- Accept exactly `todo`, `doing`, `in_progress`, `blocked`, or `done`, case-insensitively.
- Resolve the current conversation from `CODEX_THREAD_ID`; an explicit id exists only for controlled tooling and tests.
- Require the selected row to match the exact absolute current `cwd`.
- Derive the semantic work title from the visible conversation; reject empty, already-prefixed, control-character, or generic work titles.
- Update only `threads.title`, preserve the thread id, and verify the persisted title.
- Do not inspect other conversations, rename forks, mutate `TASKS.md`, or infer a project-task status.
- Treat repeating the same rename as a successful idempotent no-op.

## Pressure Scenarios

- `SESSION-RENAME-CURRENT-ONLY`: a valid command changes one row identified by `CODEX_THREAD_ID` and leaves all other rows untouched.
- `SESSION-RENAME-CWD-ISOLATION`: a current id whose row belongs to another exact cwd is rejected without mutation.
- `SESSION-RENAME-STATUS-GATE`: an unknown status is rejected before opening a write transaction.
- `SESSION-RENAME-SEMANTIC-GATE`: empty, generic, control-character, and already-prefixed work titles are rejected.
- `SESSION-RENAME-IDEMPOTENT`: repeating the same target title succeeds and reports no change.
- `SESSION-RENAME-NO-TRACKER`: the operation never creates or mutates project governance files.

## Proof Path

Scenario-first contract plus standard-library tests against temporary SQLite
databases. No test may write to live Codex state.

## Implementation Tasks

- [x] Add the guarded rename helper and focused tests.
- [x] Integrate the invocation into the owner skill, playbook, README, and operator guide.
- [x] Run focused tests, metadata lint, skill audit, budget audit, diff check, and runtime sync.

## Acceptance Criteria

- [x] AC1: Only the current exact-cwd thread can be renamed.
- [x] AC2: The persisted title uses one canonical uppercase status and a semantic work title.
- [x] AC3: Invalid status/title/current-thread provenance fails without mutation.
- [x] AC4: Repeating the same rename is idempotent.
- [x] AC5: No tracker or unrelated session row is changed.
- [x] AC6: Documentation exposes the exact invocation and boundary.

## Documentation Update Plan

Update the owner skill, its README, the session playbook, operator launch
cheatsheet, help catalog, public skill page, changelog, and existing editorial
roadmap entry. No new public route or plugin-pack change is required.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-07-16 13:13:29 UTC | 100-sg-spec | GPT-5 Codex | Defined current-thread-only rename semantics, exact-cwd isolation, semantic-title gates, idempotence, and isolated proof. | draft saved | /101-sg-ready Codex current session rename |
| 2026-07-16 13:13:29 UTC | 101-sg-ready | GPT-5 Codex | Confirmed the operator-selected syntax, bounded SQLite mutation, no-tracker boundary, and complete pressure scenarios. | ready | /102-sg-start Codex current session rename |
| 2026-07-16 13:13:29 UTC | 102-sg-start | GPT-5 Codex | Implemented the guarded current-session rename helper and aligned the owner skill, playbook, README, and operator guide. | implemented | /103-sg-verify Codex current session rename |
| 2026-07-16 13:13:29 UTC | 900-shipglows-core | GPT-5 Codex | Conservatively refreshed the owner contract; retained the 309 route, added no external dependency, and found no source-freshness need. | refreshed | /103-sg-verify Codex current session rename |
| 2026-07-16 13:13:29 UTC | 103-sg-verify | GPT-5 Codex | Verified current-only targeting, exact-cwd and UUID provenance, status and semantic gates, idempotence, metadata, budget, audit, diff, and runtime sync. | verified | /104-sg-end Codex current session rename |
| 2026-07-16 13:13:29 UTC | 104-sg-end | GPT-5 Codex | Closed the local chantier with no live Codex rename performed and no remaining scoped blocker. | closed locally | /005-sg-ship Codex current session rename |

## Current Chantier Flow

- `100-sg-spec`: draft saved.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `900-shipglows-core refresh`: completed.
- `103-sg-verify`: verified.
- `104-sg-end`: closed locally.
- `005-sg-ship`: pending.
- Next step: `/005-sg-ship Codex current session rename`.
