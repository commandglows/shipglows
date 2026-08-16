---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-16"
created_at: "2026-08-16 08:16:08 UTC"
updated: "2026-08-16"
updated_at: "2026-08-16 08:48:00 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: "GPT-5 Codex"
scope: "proactive-post-ship-artifact-cleanup"
owner: "Diane"
user_story: "As a ShipGlows operator, I want temporary branches and worktrees to be surfaced for cleanup as soon as their work is durably integrated, so repository hygiene does not depend on me noticing leftovers."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/references/skill-execution-fidelity.md"
  - "skills/005-sg-ship/SKILL.md"
  - "skills/005-sg-ship/references/ship-execution-playbook.md"
  - "skills/005-sg-ship/references/ship-report-evidence.md"
  - "tools/test_005_sg_ship_contract.py"
depends_on:
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.10.0"
    required_status: active
  - artifact: "skills/references/mutation-plan-approval.md"
    artifact_version: "1.7.0"
    required_status: active
supersedes: []
evidence:
  - "Operator critique 2026-08-16: after two temporary branches and worktrees were reconciled with main, ShipGlows did not propose their removal until the operator asked."
  - "Read-only audit: 005-sg-ship ends after push and hosted-proof routing; no active contract inventories temporary Git artifacts after durable integration."
next_step: "/102-sg-start proactive post-ship artifact cleanup"
---

# Spec: Proactive post-ship artifact cleanup

## Status

ready

## Minimal Behavior Contract

After a successful integration, ShipGlows inventories only branches and worktrees explicitly created or classified as temporary for the current work. When the remote target branch contains the temporary branch tip and the worktree is clean with no unique or untracked files, ShipGlows proactively proposes an exact cleanup plan. It never deletes a branch, worktree, directory, cache, pull request, or remote ref without fresh approval. Unsafe or ambiguous artifacts are preserved and reported instead of being normalized.

## Success Behavior

- A temporary branch fully contained in the intended remote target is detected after the push and required hosted proof.
- A clean temporary worktree is named in a bounded cleanup proposal without requiring the operator to notice it first.
- Refusal or deferral preserves every artifact and records the remaining temporary state.
- Durable, review-owned, release, protected, or user-created branches are never inferred to be disposable.

## Error Behavior

- Missing remote containment, unique commits, dirty or untracked files, a running process, uncertain ownership, an active review requirement, or an unresolved deployment/proof step blocks the cleanup proposal or downgrades it to a preservation warning.
- A failed cleanup attempt reports the exact residual artifact and never escalates to force deletion.
- Must never happen: automatic deletion, force branch deletion, cleanup before hosted proof, deletion of a shared pnpm store, or mutation of an unrelated main worktree.

## Scope

In scope: shared disposable-artifact doctrine, the 005 activation signal, detailed post-ship decision rules, report evidence, and scenario-first mechanical proof.

Out of scope: implementing a cleanup CLI, automatically deleting artifacts, changing GitHub retention policy, deleting ordinary feature branches, or modifying the current Windows installer/site behavior.

## Pressure Scenarios

- `SHIP-TEMP-CLEAN`: Given an agent-created temporary branch and clean worktree whose tip is reachable from the intended remote main, when post-ship proof is terminal, then ShipGlows proposes exact local/remote cleanup and waits for approval.
- `SHIP-TEMP-UNMERGED`: Given the branch tip is not reachable from the intended remote main, then ShipGlows preserves it and does not call it disposable.
- `SHIP-TEMP-DIRTY`: Given the worktree has tracked or untracked changes, then ShipGlows blocks cleanup and reports the residual state.
- `SHIP-DURABLE-BRANCH`: Given ownership or lifecycle is not explicitly temporary, then ShipGlows does not suggest deletion merely because a push succeeded.
- `SHIP-CLEANUP-DECLINED`: Given the operator declines or defers cleanup, then all artifacts remain intact and the final report records them.
- `SHIP-CLEANUP-PARTIAL`: Given Git removes the worktree metadata but ignored cache files remain, then ShipGlows re-inspects the exact directory and deletes only proven task-local disposable residue after approval; shared stores and unrelated paths remain untouched.

## ZOMBIES Coverage

- Zero: no temporary artifacts produces no cleanup prompt.
- One: one safe temporary branch/worktree produces one bounded proposal.
- Many: multiple repositories are evaluated independently and cleaned sequentially after one exact multi-target approval.
- Boundaries: remote containment, clean status, exact paths, explicit temporary ownership, and terminal proof are mandatory.
- Interfaces: local refs, remote refs, worktree metadata, filesystem residue, approval, and final reporting stay distinct.
- Exceptions: rejection, partial filesystem cleanup, locked cache files, branch protection, and concurrent remote movement fail closed.

## Implementation Tasks

- [x] Add the failing scenario contract to `tools/test_005_sg_ship_contract.py`.
- [x] Extend the shared disposable-artifact rule without duplicating the detailed Git procedure.
- [x] Add the activation-critical post-ship signal to `skills/005-sg-ship/SKILL.md` within its budget.
- [x] Add safe detection/proposal rules to the execution playbook and retained-state evidence to the report reference.
- [x] Run focused, metadata, budget, activation, audit, runtime-sync, diff, and secret checks.

## Acceptance Criteria

- [x] AC1: Safe temporary artifacts are proactively proposed for cleanup after terminal integration proof.
- [x] AC2: No cleanup mutation occurs without a fresh approval message and explicit response.
- [x] AC3: Unmerged, dirty, unique, ambiguous, durable, protected, or review-required artifacts are preserved.
- [x] AC4: The final report records retained temporary artifacts when cleanup is declined, blocked, or partial.
- [x] AC5: The 005 skill remains within its activation budget and runtime-visible contract checks pass.

## Test Contract

- Primary proof: scenario-first static contract tests plus metadata, budget, activation graph, audit, runtime sync, diff, and changed-line secret checks.
- Fresh external docs: not needed; this changes internal ShipGlows workflow behavior and relies on existing Git safety invariants.
- Manual proof: not required because the implementation proposes cleanup but performs no cleanup in its tests.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-16 08:16:08 UTC | 900-shipglows-core | GPT-5 Codex | Converted the missed post-integration cleanup proposal into a bounded scenario-first repair contract. | ready; implementation authorized in an isolated worktree | Add the failing 005 contract scenario, then implement the narrow shared/local repair. |
| 2026-08-16 08:48:00 UTC | 900-shipglows-core | GPT-5 Codex | Added the shared safety doctrine, 005 post-ship review, retained-state reporting, and regression contract. | focused and cross-contract suites pass; metadata, budget, graph, audit, and isolated Windows runtime visibility pass | Commit and publish the dedicated branch; retain it until integration because it is not yet disposable. |

## Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| 100-sg-spec | complete | Behavior, safety boundary, ZOMBIES coverage and proof path defined. |
| 101-sg-ready | complete | Exact owner surfaces and destructive-action stops are resolved. |
| 102-sg-start | complete | Regression-first contract and narrow doctrine/workflow repair implemented. |
| 103-sg-verify | complete | Focused and cross-contract tests, metadata, budget, graph, audit, and isolated Windows runtime visibility pass. |
| 104-sg-end | complete | Documentation reflection is updated in the shared doctrine, 005 references, refresh log, and this spec. |
| 005-sg-ship | in_progress | Commit and push the dedicated branch only; integration into main remains outside this run. |
