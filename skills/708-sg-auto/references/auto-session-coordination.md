---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-20"
updated: "2026-08-20"
status: active
source_skill: 708-sg-auto
scope: auto-session-coordination
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/708-sg-auto/SKILL.md
  - skills/708-sg-auto/references/auto-credit-window-playbook.md
  - skills/references/no-local-execution-policy.md
  - tools/shipglows_auto_claim.py
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-20: parallel auto conversations should avoid duplicate work and overlapping file ownership while remaining inside the root where each was launched."
next_review: "2026-09-20"
next_step: "/103-sg-verify shipglows auto session coordination"
---

# Auto Session Coordination

## Purpose

Coordinate independent `shipglows auto` conversations sharing one project root
without turning coordination into a workload or a source of artificial model
activity. Claims prevent duplicate candidates and overlapping writes; they do
not assign quota, elect a global leader, or authorize broader scope.

## Root and storage

Use only `<frozen-project-root>/.shipglows-auto/claims/`. The project must ignore
`.shipglows-auto/`. Never place claims in a home directory, sibling repository,
global runtime, external service, branch, or additional worktree.

Use `$SHIPGLOWS_ROOT/tools/shipglows_auto_claim.py`; do not recreate claim logic ad hoc. It
stores claims in `active` and `completed` directories. Claim metadata is
minimal and non-sensitive: run identifier, canonical candidate or tracker,
owned relative paths, `captured_git_root`, and status. Do not copy
prompts, findings, source content, secrets, or diffs into claims.

## Claim protocol

1. Derive a stable claim key from the canonical tracker/spec path and bounded
   slice. Use the smallest useful relative file or directory ownership.
2. Inspect active claims and current read-only Git status/diff before selection.
3. Reject any candidate whose files equal, contain, or are contained by an
   active claim. A different candidate name never permits overlapping paths.
4. Reserve through the helper's atomic exclusive creation. Never overwrite an
   existing claim. If the reservation loses a race, skip it and select another
   candidate.
5. On a truthful handoff, use the helper to move the owned claim atomically
   from `active` to `completed`.

Never reclaim, expire, delete, or replace an abandoned active claim silently.
Recovery is ordinary explicitly approved maintenance because a hidden live
conversation may still own it.

Claim creation and moves are the only coordination mutations. They do not
permit builds, tests, installs, Git state changes, external writes, or edits
outside the frozen root.

## Delegated ownership

The parent owns the claim and integration. A subagent receives the frozen root,
claim key, owned paths, forbidden paths, and mandatory nolocal policy. It must
not create a second claim for the same mission, widen its paths, launch work in
another root, or edit a path held by another claim.

Parallel writes still require ready non-overlapping Execution Batches. Claims
make those batches visible across conversations; they do not create them.

## Degraded behavior

If a canonical Git root is unavailable, or the ignored coordination directory
or safe lock cannot be created or inspected, do not invent a remote ledger or
leave the root. No auto mutation may continue, even for an operator-given
exclusive scope or apparently non-overlapping candidate. Continue read-only
analysis, select another safe candidate, or report `coordination unavailable`.

## Pressure scenarios

- `AUTO-CLAIM-RACE`: two conversations reserve the same key; exactly one keeps
  the active claim and the other selects different work.
- `AUTO-CLAIM-PATH-OVERLAP`: different candidate names with parent/child file
  ownership still conflict.
- `AUTO-CLAIM-LOCK-SYMLINK`: a lock symlink is rejected without reading or
  writing its external target.
- `AUTO-CLAIM-ROOT`: claims and all owned paths remain below the frozen root.
- `AUTO-CLAIM-NO-SECRETS`: claim metadata contains identifiers and relative
  paths only, never findings, prompts, source excerpts, secrets, or diffs.
- `AUTO-CLAIM-CHILD`: a child consumes its parent's claim and cannot replace or
  complete it under another owner identity.
- `AUTO-CLAIM-ABANDONED`: a later run never silently reclaims an active claim.
