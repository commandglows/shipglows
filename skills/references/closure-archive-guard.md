---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-06-27"
updated: "2026-06-27"
status: active
source_skill: 104-sg-end
scope: closure-archive-guard
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/104-sg-end/SKILL.md"
  - "skills/005-sg-ship/SKILL.md"
  - "skills/103-sg-verify/SKILL.md"
  - "shipglows_data/workflow/"
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from auditing OpenSpec's archive-change skill as a reusable closure guard."
  - "Extended from auditing OpenSpec's bulk-archive-change skill for batch closure, conflict detection, and partial-result handling."
next_review: "2026-07-27"
next_step: "Use before closure, archive, changelog, tracker-done, or full-close ship claims."
---

# Closure Archive Guard

## Purpose

This reference defines the ShipGlows guard for closing, archiving, or marking work as done without overstating completion.

Use it before tracker closure, changelog framing, archive moves, full-close shipping, or any final report that could imply a work item is complete.

## Closure Preflight

Before closure or archive:

- identify the single work item, spec, bug, task, or session scope being closed
- inspect implementation state, verification state, documentation state, and remaining proof gaps
- check whether any source delta still needs to be synced into the durable source of truth
- check whether closing would hide incomplete tasks, unresolved warnings, stale docs, open bug state, or pending hosted/manual proof
- ask a targeted confirmation only when closure is still possible but would intentionally proceed with known incomplete artifacts or skipped sync

## Sync And Delta Rule

Before marking work complete, compare the changed artifact with the durable source of truth it should update.

Examples:

- spec delta -> canonical spec or current chantier spec
- bug fix state -> `shipglows_data/workflow/bugs/BUG-ID.md` status and retest history
- task completion -> `shipglows_data/workflow/TASKS.md`
- public behavior change -> README, help, site content, docs, or support copy
- skill behavior change -> runtime skill links, help/discovery docs, and relevant shared references

If a delta exists, either sync it, route it to the owner skill, or report a named closure limit. Do not silently archive, mark done, or ship full-close while the durable source of truth is stale.

## Archive Safety

When moving or archiving a durable artifact:

- generate deterministic archive names when possible
- check the target path for collision immediately before moving
- stop rather than overwrite an existing archive target
- preserve metadata and sidecar files unless the work item explicitly says to split them
- keep migration evidence discoverable from the canonical governance path

## Batch Closure And Archive

When closing or archiving multiple work items in one run:

- enumerate the selected items before acting
- collect implementation state, proof state, task state, source-of-truth deltas, and archive target for each item
- detect conflicts where two or more items update the same durable source of truth, public claim, bug state, spec, tracker row, runtime skill surface, or archive target
- resolve conflicts from evidence before closure: inspect the current code/docs/project state, then choose the item(s) whose outcome is actually implemented or proven
- when multiple implemented items update the same source of truth, apply them in a deterministic order, normally oldest-to-newest unless the spec or user explicitly chooses another precedence
- skip or defer items with missing implementation evidence, unresolved conflicts, or unsafe closure gaps instead of weakening the whole batch
- show one consolidated status before committing to the batch when user confirmation is required
- track each item as `closed`, `archived`, `skipped`, `deferred`, `partial`, or `failed`

Batch closure may partially succeed. A failed or skipped item must not be hidden inside a global success report, and a successful item must not inherit proof from a neighboring item.

## Status Semantics

- `closed`: implementation, required proof, source-of-truth sync, and closure bookkeeping are complete for the current scope
- `deferred`: closure is intentionally postponed because remaining work is known and routed
- `partial`: work advanced, but implementation or closure state is incomplete
- `blocked`: closure cannot proceed safely because required context, proof, sync, or ownership is missing
- `archived`: durable artifact was moved to an archive after collision and sync checks

Do not use `closed` or `archived` to hide incomplete tasks or missing proof. If closure proceeds with warnings by explicit operator choice, report the warnings and residual owner route.

## Verification Hooks

Verification should check:

- closure target was unique
- batch closure targets, conflicts, and per-item outcomes were listed when multiple work items were closed together
- source-of-truth deltas were synced or explicitly routed
- tracker/changelog/docs wording does not claim stronger proof than exists
- archive target collision was checked when files were moved
- closure status and proof status are not conflated
