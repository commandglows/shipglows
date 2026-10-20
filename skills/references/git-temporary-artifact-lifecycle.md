---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-16"
updated: "2026-10-20"
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
  - "Operator clarification 2026-09-03: closure always classifies Git state, but automatic versus proposed cleanup is proportional to chantier size and observed Git complexity."
  - "Operator decision 2026-08-16: merged task branches and worktrees should be removed as part of the same lifecycle instead of accumulating as forgotten Git artifacts."
  - "Operator decision 2026-09-01: proven-integrated temporary Git artifacts are cleaned automatically without a validation prompt."
next_review: "2026-09-16"
next_step: none
---

# Git Temporary Artifact Lifecycle

## Purpose

Keep task-scoped Git branches and worktrees owned until they have a terminal cleanup disposition. This contract prevents a successful merge from leaving untracked operational debt while retaining ShipGlows destructive-action safeguards.

## Resting State

The end goal of every chantier, once its work is shipped, is a repository at rest: the checkout sits on the canonical integration branch from `project-delivery-policy.md` (`main` for `development`; `dev` for live postures, with `main` kept as the durable production branch), clean and in sync with its upstream, with no extra worktree, no temporary local or remote branch, and no open pull request. Branches, worktrees, and pull requests are means to ship, never resting places. Prefer working directly on the integration branch when the posture allows it; create isolation only when parallel writers, required review, or risk demand it.

Run the resting-state sweep at chantier closure after ship, and when work starts in a repository: `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/git_resting_state.py" . --integration <canonical integration branch>`. Its scope is the whole repository, not only artifacts this run created, so leftovers from earlier sessions, other agents, and abandoned experiments surface too.

- `auto` deviations converge immediately under standing Git/GitHub stewardship authority, following Cleanup Eligibility And Order: push or fast-forward, prune missing worktrees, delete branches and worktrees whose work is proven integrated.
- `merge` deviations owned by the current chantier are reconciled when merge-ready (green required checks, policy review satisfied, no non-trivial conflict), then cleaned.
- `ask` deviations and every `merge` deviation the chantier does not own go into one consolidated proposal in the final report, phrased as the remaining path to a clean integration branch: what to merge, what to delete, what to keep, each with its evidence. Never leave them silent and never split them into several questions. A refusal records `retained-explicit` with a reason and review date.

A chantier report is not fully clean until it states either `Git: at rest on <branch>` or the consolidated proposal.

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

Choose the closure path proportionately. If no task-owned temporary artifact exists, record `not-applicable`. For one small, exact, clean, proven-integrated artifact set with no shared, durable, review, process, protection, unique-commit, or concurrency purpose, immediately converge under the standing Git/GitHub stewardship authority in `mutation-plan-approval.md`; do not request validation for that ordinary cleanup. For a large chantier, multiple repositories or artifacts, dirty state, shared ownership, durable purpose, active process, protection, unique commits, or ambiguous evidence, preserve the state and present one exact evidence-backed cleanup proposal, or record `blocked` when no safe proposal exists. The operator may refuse a proposed cleanup; record `retained-explicit` with a reason and review date. Use this order only for the exact automatic or approved scope:

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
