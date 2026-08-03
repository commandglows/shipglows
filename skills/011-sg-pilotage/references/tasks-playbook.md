---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 011-sg-pilotage
scope: pilotage-tasks-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/011-sg-pilotage/SKILL.md
  - shipglows_data/workflow/TASKS.md
  - skills/references/operational-record-format.md
  - skills/references/task-registry-routing.md
depends_on:
  - artifact: skills/references/operational-record-format.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/task-registry-routing.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Transferred from the non-session contract of 309-sg-tasks under the approved pilotage consolidation."
next_step: "$011-sg-pilotage tasks"
---

# Tasks Mode Playbook

## Outcome

Make the durable execution tracker match real project state, then recommend one tracker-derived next action. This mode owns task records, evidence-based status changes, active-versus-deferred hygiene inside `TASKS.md`, and tracker repair. It does not execute the selected work.

## Inputs And Sources

- Use `shipglows_data/workflow/TASKS.md` as the canonical project tracker.
- Use root `TASKS.md` only as a legacy fallback or migration source when the canonical tracker is absent.
- Treat archived central trackers as migration evidence, never as an active master dashboard.
- Read git state, relevant files, tests, specs, and project docs only as needed to establish task truth.
- Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before any record write and `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md` before choosing an execution or editorial destination.

## Mode Grammar

`tasks [focus]` may create, update, reconcile, clean, or migrate execution task records. A focus narrows the evidence scan; it does not authorize implementation.

If the arguments contain `tasks sessions`, `rename`, `prune`, or another session operation, stop before reading Codex state and route to `$011-sg-pilotage sessions ...`. This mode never reads `state_5.sqlite` and never invokes a session helper.

If the main outcome is deferred capture, current ranking, retrospective review, continuation, read-only status, verification, or closure, route to `backlog`, `priorities`, `review`, `706-continue`, `308-sg-status`, `103-sg-verify`, or `104-sg-end` respectively.

For an Atlas-roadmap coverage request, load `$SHIPGLOWS_ROOT/skills/references/atlas-cartography-lifecycle.md`, report coverage only, and never create semantic IDs or replace the task tracker/spec registry.

## Write Protocol

1. Read the canonical tracker and relevant evidence.
2. Classify every proposed change as create, status update, field update, move to backlog, or no change.
3. Require concrete implementation and matching proof before changing a task to `done`; intention, a final message, a commit, a build, or a review is insufficient alone.
4. Immediately before writing, authoritatively re-read the target from disk.
5. Apply the smallest possible patch to the intended record or section while preserving unknown fields and manual notes; never rewrite the whole file from stale context.
6. If the anchor moved, re-read once and recompute. If it remains ambiguous, write nothing and ask for the smallest missing context.
7. Re-read the result and report the exact state transition and evidence limit.

If the canonical tracker is missing and creation is explicitly within the task request, create a concise tracker with `Active`, optional `Historical completed work`, `Backlog`, and `Audit Findings` sections, then emit new records in the traffic-first grammar. Do not copy completed historical items into the active backlog.

## Registry And Changelog Boundaries

- Engineering, runtime, security, governed-doc, skill, and implementation follow-ups belong in `shipglows_data/workflow/TASKS.md`.
- Public/editorial follow-ups belong in `shipglows_data/editorial/ROADMAP.md` through the content owner; mixed findings split into two records.
- Durable product or technical decisions belong in their metadata-bearing owner artifact, not in a long task description.
- Task maintenance does not generate or rewrite `CHANGELOG.md` by default. Route standalone changelog work to `304-sg-changelog`; `review`, `104-sg-end`, or `005-sg-ship` may update it when their contract and evidence justify the change.

## Output

Report records created or changed, records intentionally left unchanged, rejected writes, evidence gaps, and one specific next action derived from the corrected tracker. The recommendation does not execute that action.
