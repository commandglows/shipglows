---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-09-01"
status: active
source_skill: 900-shipglows-core
scope: git-milestone-delivery-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/mutation-plan-approval.md
  - skills/references/master-workflow-lifecycle.md
  - skills/102-sg-start/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
depends_on:
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.12.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-01: milestone delivery derives its integration branch from canonical business delivery posture and never from runtime or agent files."
  - "Operator decision 2026-09-01: Git/GitHub persistence and safe convergence are autonomous at project start, coherent milestones, and chantier end."
  - "Operator decision 2026-08-21: every validated milestone is committed and every completed chantier is committed and pushed to prevent local work loss."
  - "Operator clarification 2026-08-21: every validated milestone is also pushed so development work is never protected only by the local machine."
  - "Operator defect correction 2026-08-21: documentation changes reported as locally ready without commit or push cannot be closed."
next_review: "2026-11-21"
next_step: /103-sg-verify git-milestone-delivery-contract
---

# Git Milestone Delivery Contract

## Core Invariant

For an approved mutating chantier in a Git repository:

1. commit and push every explicit coherent milestone after its proportional proof passes and before starting the next milestone
2. at chantier end, commit every remaining owned change and push all owned commits to the resolved current branch upstream
3. do not claim clean closure until that push succeeds

No separate Git validation is requested. Standing Git/GitHub stewardship authority covers exact-scope commits, pushes, safe reconciliation, and proven-integrated cleanup. Resolve the canonical integration branch with `project-delivery-policy.md` from business-context `delivery_posture` only: `main` for non-live `development`, `dev` for live `published` or `sensitive-production`; `main` remains the production branch for live projects. Missing posture asks one product question and records the exact canonical field before continuing.

The approved technical chantier plan grants these exact-scope checkpoint commits and ordinary current-branch pushes, plus final delivery, when the plan names remote delivery. It never grants force push, history rewriting, tags, releases, deployments, merges, pull requests, hook bypass, or unrelated staging.

A checkpoint push proves persistence, not deployment, preview readiness, production behavior, or product acceptance. Apply the project's delivery posture and development mode for those separate obligations.

## Milestone Definition

A milestone is a coherent completed slice declared by the ready spec, approved plan, execution batches, or implementation contract. It has a stable outcome, bounded owned paths, and proportional passing proof. An assistant message, file save, tiny edit, failing experiment, incomplete batch, or arbitrary elapsed interval is not a milestone.

Before crossing a milestone boundary:

- resolve repository, branch, exact owned paths, and current status
- confirm required focused proof passed
- inspect the staged diff and exclude every unrelated or pre-existing path
- scan the staged scope for suspected secrets or sensitive data
- create one non-interactive commit with an accurate project-conventional subject
- push the current branch to its configured unambiguous upstream without force
- reconcile the validated slice into the canonical integration branch when it is on a temporary branch and integration is mechanically safe
- refresh and converge owned PR, branch, upstream, and worktree state without an approval prompt
- record its short SHA and push result in the chantier evidence, then continue without asking again

If the owned milestone has no diff, do not manufacture an empty commit. Record `nothing to commit`; confirm previously owned commits are already present upstream before continuing.

## Final Delivery

After verification and closure bookkeeping:

- commit remaining exact-scope implementation, test, documentation, tracker, or changelog changes
- when nothing remains, treat the latest owned milestone commit as the final commit; never create an empty ceremonial commit
- confirm every chantier-owned commit is reachable from the current branch
- push the current branch to its configured upstream, or establish the sole unambiguous upstream without force
- retain hosted/deployment proof as a separate obligation; push success alone never proves production behavior
- run the same branch/PR/worktree convergence pass and remove proven-integrated temporary artifacts without asking for Git validation

An ordinary final push is mandatory for clean closure. Explicit operator `no push` or `local only` changes the result to delivery-pending/local-only rather than standard closed. Non-Git or genuinely read-only work reports Git delivery as not applicable.

Every intentional mutation, including documentation-only work, follows the same closure invariant. A report containing `Aucun commit ni push` or `modifications locales prêtes` cannot use a completed, corrected, delivered, resolved, or closed verdict when tracked or untracked chantier-owned changes exist. Classify it as `delivery pending`; the mandatory next block names exact-scope commit and push. `Aucun commit ni push` is valid only for genuinely read-only, non-mutating, or non-Git work. A local commit absent from the resolved upstream is also `delivery pending`.

## Stop And Recovery

Stop before commit for ambiguous scope, unrelated staged paths, suspected secrets, failed required proof, protected-surface failure, or an ambiguous repository/branch. Preserve all work unstaged or locally committed as appropriate.

On missing remote, authentication failure, rejection, network failure, branch protection, or other push error, keep the local commits intact, report branch/upstream/status and the actionable error, and leave the chantier `delivery pending`. Never amend, reset, force, merge, switch branches, or widen staging merely to make delivery succeed.

## Pressure Scenarios

- `GMD-CANONICAL-INTEGRATION`: target `main` for non-live development and canonical `dev` for live projects; live promotion to `main` remains release-gated.
- `GMD-CONTINUAL-HYGIENE`: project/chantier start, coherent milestones, and chantier end refresh and safely converge Git/GitHub state.
- `GMD-NO-GIT-VALIDATION`: ordinary commit, push, safe reconciliation, PR lifecycle, and proven cleanup never ask for validation.

- `GMD-MILESTONE-COMMIT`: a declared coherent validated slice cannot be crossed with owned uncommitted changes.
- `GMD-MILESTONE-PUSH`: a validated milestone cannot be crossed while its owned commit exists only locally.
- `GMD-NO-MESSAGE-COMMITS`: messages and partial edits never generate arbitrary commit noise.
- `GMD-FINAL-PUSH`: clean closure requires the ordinary upstream push to succeed.
- `GMD-NO-EMPTY-FINAL`: the latest owned milestone commit serves as final when no closure diff remains.
- `GMD-UNRELATED-DIRTY`: exact-scope staging preserves unrelated and pre-existing dirty paths.
- `GMD-PUSH-FAILURE`: local commits survive push failure and the chantier remains delivery pending.
- `GMD-NON-GIT`: read-only and non-Git work never invent commits or pushes.
- `GMD-MUTATED-DOC-NO-LOCAL-CLOSURE`: changed documentation plus `Aucun commit ni push · modifications locales prêtes` cannot produce a completed verdict.
- `GMD-LOCAL-COMMIT-NO-CLOSURE`: a chantier-owned commit absent from the resolved upstream remains `delivery pending`.
