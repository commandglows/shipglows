---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
created_at: "2026-07-16 12:36:02 UTC"
updated: "2026-07-16"
updated_at: "2026-07-16 13:07:12 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5
scope: codex-project-session-prune
owner: Diane
user_story: "As a ShipGlows operator, I want to safely prune old completed Codex sessions for one exact project, so I can reclaim rollout disk space without deleting the active session or another project's history."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/309-sg-tasks/SKILL.md
  - skills/309-sg-tasks/README.md
  - shipglows_data/workflow/playbooks/conversation-tracker-sync-playbook.md
  - tools/prune_codex_sessions.py
  - tools/test_prune_codex_sessions.py
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - ~/.codex/state_5.sqlite
depends_on:
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.6.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "The ContentGlowz project currently has dozens of Codex threads and roughly 114 MiB of rollout files."
  - "Deleting an active session can leave an open rollout descriptor, stale UI state, or inconsistent metadata."
  - "Codex 0.144.4 provides a native `codex delete --force <UUID>` path that owns rollout, subtree, auxiliary-state, and thread cleanup."
  - "Operator decision on 2026-07-16: prefer a safe prune mode over deleting all Codex history from an active session."
next_step: /005-sg-ship Codex project session prune
---

# Codex Project Session Prune

🟢 [ShipGlows] spec: Codex project session prune | status: ready | path: shipglows_data/workflow/specs/codex-project-session-prune.md | next: /005-sg-ship Codex project session prune

## Title

Codex project session prune

## Status

closed locally / ready for bounded ship

## User Story

As a ShipGlows operator, I want to safely prune old completed Codex sessions for one exact project, so I can reclaim rollout disk space without deleting the active session or another project's history.

## Minimal Behavior Contract

`/309-sg-tasks sessions prune [cwd]` previews old completed sessions for the exact absolute project `cwd`. It never mutates by default. An apply run requires explicit confirmation, excludes the current thread, selects only canonical `DONE - ...` sessions inactive for strictly more than the configured age, validates each complete spawn subtree, and delegates deletion to the supported native `codex delete --force <UUID>` command. It never prunes another `cwd`, active/open statuses, unsafe descendant trees, or the current thread.

## Success Behavior

- Default invocation is a dry-run with candidate ids, count, rollout bytes, threshold, and excluded-current count.
- Default threshold is strictly more than 30 days; `--older-than-days` may increase or decrease it explicitly.
- Apply requires both `--apply` and `--confirm-cwd` equal to the resolved absolute target.
- The current thread comes from `CODEX_THREAD_ID` or an explicit argument and is always excluded.
- A root is rejected when any descendant crosses `cwd`, is not independently eligible, has an open spawn edge, is the current thread, or belongs to active agent work.
- Selected descendants are collapsed under their selected root so native recursive deletion runs once per subtree.
- Apply invokes native Codex deletion one root at a time, then verifies main thread and rollout cleanup; the native command remains authoritative for auxiliary logs, memories, goals, tools, and assignments.

## Error Behavior

- Refuse apply when confirmation is missing/mismatched, the current thread cannot be identified in an active Codex environment, the DB/schema is unsupported, the native delete command is unavailable, or subtree safety cannot be proven.
- Missing rollouts are reported in the plan; native Codex remains the sole deletion owner because it can reconcile stale and compressed session state.
- A dry-run never changes SQLite, rollout files, tracker files, or session titles.
- A native deletion failure stops the apply loop, reports completed and remaining roots, and preserves retryability; never claim global atomicity.
- Never run `VACUUM` automatically; it can lock the live Codex database and is not required to reclaim rollout disk space.

## Scope In

- A Python standard-library pruning tool under `tools/`.
- Dry-run and apply modes scoped by exact absolute `cwd`.
- Canonical `DONE - ...` and strict inactivity eligibility.
- Active-thread and unsafe-subtree exclusion, native deletion execution, post-delete verification, and compact JSON/text output.
- Focused tests with temporary SQLite databases and rollout trees.
- `309-sg-tasks` invocation, playbook, and README integration.

## Scope Out

- Deleting all Codex history globally.
- Pruning `TODO`, `DOING`, `IN_PROGRESS`, or `BLOCKED` sessions.
- Deleting the current thread.
- Automatic scheduled jobs, systemd timers, UI buttons, SQLite `VACUUM`, or tracker task deletion.
- Direct mutation of Codex SQLite databases or rollout files outside the native delete command.

## Constraints And Invariants

- Exact normalized absolute `cwd` is the project boundary.
- Candidate selection uses the best available recency timestamp and a strict `age > threshold` comparison.
- The current thread id is immutable and excluded before file or DB mutation.
- Candidate planning may inspect SQLite read-only, but all deletion ownership remains with native Codex.
- Dry-run is idempotent and mutation-free; repeated apply runs safely return zero candidates.
- Unknown ownership fields or status values must fail closed; harmless additional tables do not broaden deletion scope.
- Existing unrelated dirty worktree changes are preserved.

## Pressure Scenarios

- `SESSION-PRUNE-DRY-RUN`: preview reports candidates and bytes while file hashes and DB rows remain unchanged.
- `SESSION-PRUNE-CWD-ISOLATION`: identical titles in another `cwd` are untouched.
- `SESSION-PRUNE-ACTIVE-EXCLUSION`: a qualifying `DONE` current thread is still excluded.
- `SESSION-PRUNE-STATUS-GATE`: old non-`DONE` sessions are untouched.
- `SESSION-PRUNE-STRICT-AGE`: exactly 30 days is ineligible; more than 30 days is eligible.
- `SESSION-PRUNE-CONFIRMATION`: apply without exact `--confirm-cwd` fails before native deletion.
- `SESSION-PRUNE-SUBTREE-SAFETY`: current, cross-cwd, noneligible, open-edge, or active-job descendants block their root.
- `SESSION-PRUNE-NATIVE-FAILURE`: a native delete failure stops later roots and reports a retryable partial result.
- `SESSION-PRUNE-IDEMPOTENT`: a second apply reports zero candidates and no error.

## Implementation Tasks

- [x] Add focused failing tests for all pressure scenarios.
- [x] Implement candidate discovery, dry-run reporting, and strict safety gates.
- [x] Implement safe subtree planning, native deletion execution, and post-delete verification.
- [x] Integrate `sessions prune` into the 309 contract, playbook, README, and operator guide.
- [x] Run focused tests, metadata lint, skill audit, budget audit, diff check, and runtime sync.

## Acceptance Criteria

- [x] AC1: Dry-run is the default and performs no writes.
- [x] AC2: Only exact-cwd, canonical `DONE`, strictly old-enough threads are candidates.
- [x] AC3: The current thread is never a candidate.
- [x] AC4: Apply requires exact cwd confirmation.
- [x] AC5: Unsafe descendant trees are rejected before native deletion.
- [x] AC6: Native deletion failure stops subsequent roots and reports a retryable partial result.
- [x] AC7: Successful apply delegates to native Codex and verifies candidate cleanup while preserving unrelated rows.
- [x] AC8: Repeated apply is idempotent.
- [x] AC9: The 309 contract exposes the mode and its destructive safeguards clearly.

## Test Strategy

- Proof path: scenario-first plus standard-library unit/integration tests.
- Use temporary Codex homes, SQLite schemas, timestamps, spawn trees, job states, and an injected fake native Codex executable.
- Never test destructive behavior against the live `~/.codex` state.
- Fresh external docs: not needed; the feature targets observed local Codex storage and introspects schema defensively.

## Documentation Update Plan

- Update the owner skill, reusable session playbook, skill README, and operator launch cheatsheet.
- No public site or editorial content impact.

## Risks

- Data loss from cwd or path mistakes: mitigated by exact absolute scope, containment checks, dry-run default, and exact confirmation.
- Active-session corruption: mitigated by mandatory current-thread exclusion.
- Partial deletion: native deletion is not globally atomic, so stop on first failure and report completed versus retryable roots precisely.
- SQLite schema drift: mitigated by read-only planning, required-table checks, and native ownership of mutation.
- Database locking: use bounded read-only planning timeouts, delegate mutation to native Codex, and never auto-vacuum.

## Open Questions

None. The operator selected prune, the safe default threshold is 30 days, and global deletion remains out of scope.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-07-16 12:36:02 UTC | 100-sg-spec | GPT-5 | Defined exact-cwd dry-run-first pruning, active-thread exclusion, native deletion ownership, subtree safety, and focused pressure scenarios. | draft saved | /101-sg-ready Codex project session prune |
| 2026-07-16 12:36:02 UTC | 101-sg-ready | GPT-5 | Reviewed destructive scope, error semantics, proof path, idempotence, path containment, and operator confirmation; no open decisions remain. | ready | /102-sg-start Codex project session prune |
| 2026-07-16 13:04:29 UTC | 102-sg-start | GPT-5 Codex | Implemented the read-only planner and native Codex executor, then hardened database alignment, current-thread provenance, subtree status domains, partial-failure reporting, auxiliary verification, and unrelated-state preservation through two independent refresh reviews. | implemented | /103-sg-verify Codex project session prune |
| 2026-07-16 13:07:12 UTC | 103-sg-verify | GPT-5 Codex | Independently reverified destructive safety after two repair loops; exact edge/job/item status domains fail closed and all focused, metadata, audit, budget, diff, dry-run, and runtime checks pass. | verified | /104-sg-end Codex project session prune |
| 2026-07-16 13:07:12 UTC | 104-sg-end | GPT-5 Codex | Closed the local chantier with native Codex as sole mutation owner, no live deletion executed, documentation aligned, and no remaining scoped blocker. | closed locally | /005-sg-ship Codex project session prune |

## Current Chantier Flow

- `100-sg-spec`: draft saved.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `103-sg-verify`: verified.
- `104-sg-end`: closed locally.
- `005-sg-ship`: pending.
- Next step: `/005-sg-ship Codex project session prune`.
