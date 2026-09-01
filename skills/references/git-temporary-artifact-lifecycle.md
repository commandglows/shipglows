---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-16"
updated: "2026-09-01"
status: active
source_skill: 005-sg-ship
scope: git-temporary-artifact-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/005-sg-ship/SKILL.md
  - skills/005-sg-ship/references/ship-execution-playbook.md
  - skills/005-sg-ship/references/ship-report-evidence.md
  - skills/references/master-workflow-lifecycle.md
depends_on:
  - artifact: "skills/references/mutation-plan-approval.md"
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-16: merged task branches and worktrees should be removed as part of the same lifecycle instead of accumulating as forgotten Git artifacts."
  - "Operator decision 2026-09-01: proven-integrated temporary Git artifacts are cleaned automatically without a validation prompt."
next_review: "2026-09-16"
next_step: none
---

# Git Temporary Artifact Lifecycle

## Purpose

Keep task-scoped Git branches and worktrees owned until they have a terminal cleanup disposition. This contract prevents a successful merge from leaving untracked operational debt while retaining ShipGlows destructive-action safeguards.

## Classification At Creation

An agent-created branch or worktree dedicated to one bounded task is temporary by default. Classify it as durable only when the operator, repository policy, release process, or active review purpose explicitly requires continued ownership.

When creating a temporary artifact, retain a compact receipt in the active spec or handoff: repository, branch, worktree path when present, intended target branch, task owner, classification, and cleanup disposition `pending`. Do not create a second Git-artifact registry.

Ordinary operator-created, shared, protected, release, environment, long-lived integration, and explicitly durable branches are never inferred to be temporary.

## Integration Proof

Refresh the intended remote before deciding. Integration is proven only when either:

- the temporary branch tip is an ancestor of the refreshed intended target branch; or
- a merged pull request is authoritatively confirmed with the exact source head SHA and intended target branch, covering squash and rebase merge strategies.

A closed-but-unmerged pull request, mismatched head SHA, mismatched target, stale remote, content similarity, or operator-facing success message is not integration proof. When authoritative hosted metadata is unavailable and ancestry does not prove integration, preserve the artifact as `blocked`.

## Cleanup Eligibility And Order

After integration and required hosted or production proof are terminal, inspect the exact artifacts from a surviving canonical worktree rather than the disposable worktree being removed. Require a clean tracked and untracked state, no unintegrated work, no active process using the path, no unresolved review/release/protection purpose, exact task ownership, and no shared-store boundary.

When eligible, immediately converge under the standing Git/GitHub stewardship authority in `mutation-plan-approval.md`; do not propose or request validation for ordinary cleanup. Use this order:

1. remove worktree metadata through Git;
2. inspect and remove only proven task-local disposable residue;
3. remove the local branch with safe deletion, never force;
4. remove the remote branch when it still exists and exact temporary ownership plus integration proof remain valid.

Recheck after every step. An already absent remote branch is successful convergence, not an error. A partial failure stops the sequence and records the exact residual artifact without escalating to force or asking for a cleanup validation.

## Terminal Disposition

Every owned temporary artifact ends with exactly one cleanup disposition:

- `removed`: every approved temporary artifact is absent and verified;
- `retained-explicit`: the operator or durable policy chose retention, with a concrete reason and review date;
- `blocked`: cleanup is unsafe or integration/ownership proof is insufficient, with the blocking fact recorded;
- `not-applicable`: the run created no temporary Git artifact.

`pending` is an active intermediate state, never a terminal disposition. A master lifecycle must not report a fully clean completion while an owned temporary artifact remains `pending`. A blocked or retained artifact stays visible in the final report and durable chantier trace so it cannot become forgotten branch debt.
