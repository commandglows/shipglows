---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-27"
status: active
source_skill: 005-sg-ship
scope: ship-execution
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: no
linked_systems:
  - skills/005-sg-ship/SKILL.md
  - skills/references/git-temporary-artifact-lifecycle.md
depends_on:
  - artifact: "skills/references/git-temporary-artifact-lifecycle.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Wave-2 compaction extracted bounded Git execution from the ship activation contract."
  - "Operator critique 2026-08-16: completed temporary branches and worktrees should be surfaced for cleanup without requiring the operator to notice them."
  - "Operator decision 2026-08-16: task-scoped agent Git artifacts remain owned through a terminal cleanup disposition after integration."
  - "Operator correction 2026-08-17: quick daily shipping uses zero or one focused check when sufficient; broad suites are reserved for release, audit, migration, shared-runtime, or high-risk triggers."
  - "Operator decision 2026-08-21: checkpoint mode commits every coherent validated milestone, while final delivery pushes all owned commits before clean closure."
  - "Operator clarification 2026-08-21: checkpoint mode also pushes every validated milestone so no accepted slice remains only on the local machine."
  - "Operator correction 2026-08-27: temporary-artifact cleanup must reconcile every task-owned managed process through an exact, verified terminal disposition."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Ship Execution Playbook

Load this playbook only after `005-sg-ship` has selected checkpoint, quick, or full mode and a candidate repository, but before its first Git mutation. The activation contract remains authoritative for every stop.

## Resolve The Repository

Inspect the current repository, branch, status, diff summary, relevant recent commit style, documented development mode, and available project tracker/changelog. If the current directory is not a repository but contains several dirty project repositories, ask one bounded single-select question. Keep every later command inside the selected repository.

If the branch is detached, the target remote is unclear, or several unrelated dirty scopes remain plausible, stop and resolve the target before staging.

## Confirm Intent And Scope

Use checkpoint only for a declared coherent validated milestone, quick for ordinary delivery, and full for explicit end-of-task intent. Ask only when the answer changes closure, staging, release, or safety posture.

For bounded staging, enumerate explicit task-owned paths. For `all-dirty`, inspect the complete tracked, deleted, modified, and untracked set. Do not silently exclude unrelated files from an explicitly requested all-dirty ship; stop if any file is unsafe.

## Secret And Bug Gates

Inspect untracked and staged candidates for unignored environment files, credentials, private keys, tokens, or equivalent sensitive material. Stop rather than partially staging an unsafe all-dirty scope.

Read `shipglows_data/workflow/bugs/*.md` as the known-bug source of truth and `shipglows_data/workflow/BUGS.md` only as optional triage context. Open only linked high-impact bug files needed to confirm scope and status; do not turn quick ship into a broad audit.

Classify:

- `blocked`: a linked high/critical bug remains open, needs information/reproduction, is under diagnosis, or only has a fix attempt;
- `partial-risk`: a linked item is `fixed-pending-verify` or linkage is uncertain;
- `not assessed`: no usable registry exists or the ship scope cannot be linked safely.

Stop for `blocked` unless the user explicitly accepts risk. Retain `partial-risk` and `not assessed` in evidence.

## Checks

Unless `skip-check` was explicit, choose the smallest useful daily proof:

- use no automated check for a low-risk localized change when no focused check adds meaningful regression signal, and record that reason;
- otherwise run one focused owner test, contract test, syntax check, or smoke check for the changed behavior;
- add a second check only when it covers a distinct material failure boundary;
- do not automatically combine lint, typecheck, build, tests, metadata, budget, audit, and full-suite commands because this is a ship action;
- use a full suite or broad check bundle only for release preparation, an explicit health/security audit, dependency/platform migration, broad shared-runtime change, high-risk security/data/auth/payment/destructive behavior, or after a focused failure proves broader diagnosis is needed.

Stop on a required or attempted check failure. The user may then request a distinct risk-accepted ship, but the failed proof remains visible.

## Stage, Inspect, Commit

Stage explicit paths for bounded scope; use whole-repository staging only for explicit `all-dirty`, `ship-all`, or `tout-dirty`. Inspect the staged diff and staged file list after staging. If an Atlas registry applies, run its staged-path preflight now and stop on `block`.

When changes create, rename, or materially update `skills/*/SKILL.md`, run the canonical `shipglows_sync_skills` check for the affected skill, or the all-skills check for broad visibility changes. Do not repair runtime links inside this skill.

If there is nothing to commit, do not manufacture a commit. Otherwise derive a concise message from explicit arguments or the bounded outcome, preserve repository commit conventions, and commit without interactive editors.

For checkpoint mode, push the current branch to its configured unambiguous upstream without force, record the commit SHA and push result, then return to implementation. The chantier remains open; the push proves persistence, not deployment or product behavior.

## Push And Failure Handling

Checkpoint, quick, and full modes push the current branch to its configured upstream. If no upstream exists and the branch/remote are unambiguous, establish it without force. Full closure requires every chantier-owned commit reachable from the pushed branch. Never force-push `main` or `master`.

On rejection or other push failure, stop and report the actual local commit, branch, upstream, dirty state, checks, and error. Do not claim shipment.

After success, use the activation contract's development-mode rule. Hosted-sensitive preview work routes to `405-sg-prod` before downstream proof; a local-mode push needs no invented deployment step.

## Post-Ship Temporary Artifact Review

After the push and every required hosted or production proof reaches a terminal result, apply `skills/references/git-temporary-artifact-lifecycle.md`. Task-scoped branches and worktrees created by the agent are temporary by default unless declared durable at creation; never infer that an ordinary operator, shared, release, or protected branch is disposable merely because its push or merge succeeded.

Propose cleanup only when all of these are proven with fresh read-only checks:

- the refreshed intended remote target contains the temporary branch tip, or authoritative hosted metadata proves a merged pull request with the exact source head and target;
- the temporary worktree has no tracked or untracked changes;
- the branch has no unique commits, unresolved review purpose, protection, release ownership, or concurrent operator ownership;
- the exact worktree path is resolved, task-owned, and not used by a running process;
- every task-owned managed process has a terminal disposition under the shared lifecycle; for `stopped`, its retained session or exact PID was signalled, awaited, and verified absent without broad process-name termination;
- every required deployment, hosted proof, and post-push verification is terminal.

When the gate passes, propose the exact cleanup scope without waiting for the operator to notice it and follow the shared removal order from a surviving canonical worktree. Obtain fresh destructive-action approval under `mutation-plan-approval.md`; remote ref deletion always uses its full-plan path. Multiple repositories are proposed together only when each target is exact, then cleaned sequentially; never delete automatically, never force branch deletion, and never touch a shared dependency store or unrelated main worktree.

If the gate fails or cleanup is declined, preserve the artifacts and record the shared cleanup disposition. Explicit retention requires a reason and review date; `pending` never supports a fully clean completion. If Git removes worktree metadata but ignored residue remains, re-inspect the exact directory before any approved deletion and stop on unexpected content, shared-store boundaries, locks, or ownership ambiguity.
