---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-08-16"
created_at: "2026-08-16 08:16:08 UTC"
updated: "2026-08-16"
updated_at: "2026-08-16 08:42:23 UTC"
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
  - "skills/references/git-temporary-artifact-lifecycle.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/005-sg-ship/SKILL.md"
  - "skills/005-sg-ship/references/ship-execution-playbook.md"
  - "skills/005-sg-ship/references/ship-report-evidence.md"
  - "tools/test_005_sg_ship_contract.py"
depends_on:
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.5.0"
    required_status: active
  - artifact: "skills/references/git-temporary-artifact-lifecycle.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "2.3.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.10.0"
    required_status: active
  - artifact: "skills/references/mutation-plan-approval.md"
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "Operator critique 2026-08-16: after two temporary branches and worktrees were reconciled with main, ShipGlows did not propose their removal until the operator asked."
  - "Read-only audit: 005-sg-ship ends after push and hosted-proof routing; no active contract inventories temporary Git artifacts after durable integration."
  - "Operator decision 2026-08-16: merged task branches and worktrees should be removed within the same lifecycle so dead Git artifacts do not require later chantier archaeology."
next_step: "/102-sg-start proactive post-ship artifact cleanup"
---

# Spec: Proactive post-ship artifact cleanup

## Status

ready

## Minimal Behavior Contract

Agent-created task branches and worktrees are temporary by default unless declared durable at creation. After successful integration, ShipGlows proves ancestry or an exact merged pull request, then immediately proposes safe cleanup. The lifecycle remains active until `removed`, `retained-explicit`, `blocked`, or `not-applicable` is recorded. No branch, worktree, directory, cache, pull request, or remote ref is deleted without fresh approval.

## Success Behavior

- A temporary branch fully contained in the intended remote target is detected after the push and required hosted proof.
- A clean temporary worktree is named in a bounded cleanup proposal without requiring the operator to notice it first.
- Refusal or deferral preserves every artifact and records the remaining temporary state.
- Durable, review-owned, release, protected, or user-created branches are never inferred to be disposable.
- A deliberate retention records its reason and review date instead of becoming silent branch debt.

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
- `SHIP-SQUASH-MERGED`: Given ancestry cannot prove a squash merge, when authoritative hosted metadata matches the exact source head and intended target, then integration is proven without weakening the deletion gates.
- `SHIP-DISPOSITION-PENDING`: Given an owned temporary artifact remains pending, then the lifecycle cannot report a fully clean completion.
- `SHIP-RETAINED-EXPLICIT`: Given cleanup is declined, then retention is terminal only with a reason and review date.

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
- [x] Define task-scoped agent Git artifacts as temporary by default and record their creation receipt.
- [x] Support ancestry and exact merged-PR integration proof without trusting content similarity.
- [x] Require one terminal cleanup disposition and keep pending/blocked state visible across lifecycle reporting.

## Acceptance Criteria

- [x] AC1: Safe temporary artifacts are proactively proposed for cleanup after terminal integration proof.
- [x] AC2: No cleanup mutation occurs without a fresh approval message and explicit response.
- [x] AC3: Unmerged, dirty, unique, ambiguous, durable, protected, or review-required artifacts are preserved.
- [x] AC4: The final report records retained temporary artifacts when cleanup is declined, blocked, or partial.
- [x] AC5: The 005 skill remains within its activation budget and runtime-visible contract checks pass.
- [x] AC6: Squash/rebase integration is accepted only through exact authoritative merged-PR evidence.
- [x] AC7: A task-owned temporary artifact cannot disappear from reporting while its disposition is pending, blocked, or explicitly retained.

## Test Contract

- Primary proof: scenario-first static contract tests plus metadata, budget, activation graph, audit, runtime sync, diff, and changed-line secret checks.
- Fresh external docs: not needed; this changes internal ShipGlows workflow behavior and relies on existing Git safety invariants.
- Manual proof: not required because the implementation proposes cleanup but performs no cleanup in its tests.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-16 08:16:08 UTC | 900-shipglows-core | GPT-5 Codex | Converted the missed post-integration cleanup proposal into a bounded scenario-first repair contract. | ready; implementation authorized in an isolated worktree | Add the failing 005 contract scenario, then implement the narrow shared/local repair. |
| 2026-08-16 08:25:00 UTC | 900-shipglows-core | GPT-5 Codex | Added the shared safety doctrine, 005 post-ship review, retained-state reporting, and regression contract. | focused and cross-contract suites pass; metadata, budget, graph, audit, and isolated Windows runtime visibility pass | Commit and publish the dedicated branch; retain it until integration because it is not yet disposable. |
| 2026-08-16 08:42:23 UTC | 900-shipglows-core | GPT-5 Codex | Hardened the proposal into a complete Git artifact lifecycle with temporary-by-default classification, merge-strategy-aware proof, and terminal dispositions. | 89 focused/cross-contract tests, full dependency and activation graphs, metadata, budget, audit, runtime visibility, diff, and secret checks pass | Commit and update the dedicated remote branch; retain it until integration because it is not yet disposable. |

## Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| 100-sg-spec | complete | Behavior, safety boundary, ZOMBIES coverage and proof path defined. |
| 101-sg-ready | complete | Exact owner surfaces and destructive-action stops are resolved. |
| 102-sg-start | complete | Scenario-first lifecycle hardening implemented on the existing dedicated branch. |
| 103-sg-verify | complete | 89 tests, full graphs, metadata, budget, audit, runtime visibility, diff, and secret checks pass. |
| 104-sg-end | complete | Shared doctrine, lifecycle, ship references, refresh log, and active spec are aligned; public/editorial surfaces are not impacted. |
| 005-sg-ship | in_progress | Commit and push the dedicated branch only; integration into main remains outside this run. |
