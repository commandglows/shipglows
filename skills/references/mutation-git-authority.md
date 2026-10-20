---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: mutation-git-authority
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - "Verbatim conditional sections extracted from mutation-plan-approval 1.17.0."
next_review: "2026-10-05"
next_step: none
---

## Git/GitHub stewardship authority

ShipGlows has standing authority to manage ordinary Git/GitHub state for in-scope work without asking for validation. At project or chantier start, each coherent validated milestone, and chantier end, refresh remote truth and converge safely: fetch/prune, inspect branch/upstream/PR/worktree relationships, stage only owned paths, create accurate commits, push them, reconcile merge-ready owned branches or pull requests into the canonical integration branch, and remove proven-integrated temporary branches and worktrees.

Resolve the target from `project-delivery-policy.md`: non-live `development` projects integrate directly into `main`; explicitly live `published` and `sensitive-production` projects integrate into canonical `dev`, while `main` remains production. Promotion `dev -> main` is a release/deployment transition: when its applicable release, CI, preview, security, and production-authority gates are satisfied, perform the Git reconciliation without a separate Git validation.

This standing authority includes safe local and remote branch creation, ordinary commits and pushes, fast-forward or policy-approved merge-ready reconciliation, pull-request lifecycle operations, pruning, and deletion of temporary local/remote branches or worktrees only after exact ownership and integration are mechanically proven. It never includes force push, history rewriting, bypassing protection or required checks, choosing a non-trivial conflict resolution, discarding unique commits, weakening controls, merging an unreviewed or failing change, deploying without deployment authority, or touching unrelated dirty work. Preserve and diagnose uncertain state instead of asking for a Git validation.


## Cumulative milestone persistence authority

Approval of a bounded technical implementation plan that disclosed milestone remote persistence also authorizes its ordinary milestone commits and pushes by default. Apply `git-milestone-delivery-contract.md`: every explicit coherent validated milestone must be committed and pushed before the next milestone starts. The agent may stage, commit, and push silently, without a second approval message, when all of these conditions remain true:

- every staged path belongs to the already approved technical scope;
- unrelated and pre-existing changes remain unstaged;
- secret and sensitive-data checks pass before the commit;
- the commit is new on the current approved branch and the push targets only its resolved unambiguous upstream, with no amend, rebase, squash, reset, tag, force, hook bypass, merge, deployment, or unrelated remote effect;
- the commit records a coherent completed slice after proportional validation, and its subject describes that slice accurately.

The same bounded approval includes updates to directly mapped canonical project documentation required to keep the approved technical behavior truthful at closure. It does not include substantive editorial rewriting, new public claims, broad documentation migration, or unrelated documentation cleanup.

This authority may cover multiple small coherent commits and their ordinary pushes during the same approved chantier and requires both at declared milestones. A milestone is a completed slice, not a message or arbitrary edit. Report commit identifiers and push results at the next natural checkpoint or final handoff; do not interrupt merely to ask permission to protect approved work remotely.

The cumulative authority does not apply when the operator says `no commit`, when staging would include an unresolved or unrelated path, or when the work is primarily substantive editorial judgment or a broad mixed-scope consolidation. Those cases require explicit commit scope in the approval plan. An explicitly requested ordinary push may use clear bounded-request authority; an approved full technical chantier plan may also authorize its ordinary milestone and final current-branch pushes upfront with no duplicate approval. Force, history rewriting, tags, releases, deployments, merges, and unrelated remote effects remain outside that authority.


## Mandatory final delivery authority

A full technical chantier plan includes exact-scope milestone commits and pushes plus ordinary final delivery by default. The plan must expose every remote persistence effect before approval. At completion, commit any remaining owned diff, or reuse the latest owned milestone commit when nothing remains, then confirm the resolved current branch/upstream contains every owned commit. Never manufacture an empty final commit.

Push failure, ambiguous remote/branch, missing authentication, rejected updates, suspected secrets, unrelated staged paths, or failed required proof preserves local commits and leaves the chantier `delivery pending`; it never becomes clean closure. Explicit `no push` or `local only` also leaves delivery pending/local-only rather than standard closed. Read-only and non-Git work are not applicable.

