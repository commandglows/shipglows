---
name: 005-sg-ship
description: "Ship with checks, commits, pushes, and closure when needed."
argument-hint: [optional: checkpoint | commit message | "end la tache" for full close | skip-check | all-dirty]
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md`; project artifacts resolve from project root.

## Instruction Layering

Keep ownership, modes, mutation stops, proof limits, and reference triggers local. Load at most one local playbook; local references do not chain.

## Chantier Tracking

Trace category: `obligatoire`. Process role: `lifecycle`.

For one unique spec, load `chantier-tracking.md`, preserve history/flow, and record `shipped`, `not shipped`, `blocked`, or `skipped checks`. Otherwise use `(local)` without writing a spec.

## Report Modes

Before reporting load `reporting-contract.md`. Default to concise `report=user`; detail requires explicit agent or handoff intent.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before ShipGlows-owned references, tools, scripts, or runtime checks.

## Mission And Ownership

`005-sg-ship` owns bounded Git shipping and autonomous cleanup for task branches/worktrees, temporary by default. Proven-integrated Git cleanup uses standing stewardship authority without validation; other owners retain implementation, proof, production, and closure unless full-close is explicit.

`104-sg-end` retains unresolved closure bookkeeping; quick ship never substitutes.

## Mode And Scope Decision

- Default mode is `quick`.
- `checkpoint` commits and pushes one validated milestone without closure.
- Select `full` only when `$ARGUMENTS` includes `end la tache`, `end`, `fin`, or `close task` as an explicit end-of-task intent.
- Default staging is limited to files clearly belonging to the current task or intentionally selected scope.
- Select whole-repo staging only when `$ARGUMENTS` explicitly includes `all-dirty`, `ship-all`, or `tout-dirty`.
- `skip-check` skips checks but never skips secret, dirty-scope, bug-risk, protected-surface, or proof-claim gates.

Quick mode uses zero or one sufficient focused check, then stages, commits, pushes, and reports. It never updates `TASKS.md` or `CHANGELOG.md` and never claims formal closure.

When structured history is adopted, load `context-history-and-head.md` before final staging and append at most one bounded delivery event. Public fields require bilingual safe copy and delivery proof; ambiguity stays internal.

Full mode may update trackers, changelog, and durable decisions. Load `full-close-playbook.md`, `closure-archive-guard.md`, `context-quality-contract.md`, `documentation-reflection-gate.md`, and `editorial-reflection-gate.md`; revalidate its bounded capsule before documentation classification. Material gaps prevent full closure.

Before either mode mutates Git, load exactly one local reference: `$SHIPGLOWS_ROOT/skills/005-sg-ship/references/ship-execution-playbook.md`. Full mode loads its full-close playbook only after the common pre-mutation gates pass.

After terminal post-push proof, load `$SHIPGLOWS_ROOT/skills/references/git-temporary-artifact-lifecycle.md` when the run owns a task-scoped branch or worktree.

## Stops Before Mutation

Stop before staging or committing when:

- the target repo or bounded staging scope is ambiguous;
- an unignored `.env`, credential, key, token, or other suspected secret is in scope;
- a required or attempted check fails;
- a linked high/critical bug is open in `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted`;
- an applicable Atlas staged-path preflight returns `block`;
- high-risk auth, permissions, payments, billing, tenant, destructive, migration, webhook, background-job, or public-flow changes have no meaningful validation and the user has not accepted explicit partial-risk shipping.

A user may accept partial-risk shipping, but the report retains risk and cannot claim closure, safety, or readiness. Never commit secrets. Never force-push `main` or `master`.

When a project owns an Atlas registry, load `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md` and rerun it against staged paths before commit.

## Evidence Boundaries

Classify linked bug risk as `blocked`, `partial-risk`, or `not assessed`; quick mode reports it even with skipped checks. A green check, clean push, tracker, or changelog is not proof of user, product, security, visual, auth, or production completion.

Read `$SHIPGLOWS_ROOT/skills/references/project-delivery-policy.md` and `project-development-mode.md` before choosing post-push proof. Delivery posture never waives remote persistence; development mode decides whether hosted proof is authoritative. For `vercel-preview-push`, and for hosted-sensitive `hybrid` changes, a successful push routes immediately to `405-sg-prod`; do not request or claim browser/manual proof first.

## Step 8 — One report

Before reporting, load `$SHIPGLOWS_ROOT/skills/005-sg-ship/references/ship-report-evidence.md`. Report commit/push result, repo state, checks, staging scope, bug risk, documentation status, and remaining validation. Match the user's language; keep hashes, branches, paths, and statuses literal.

Start with the shared chantier and verdict headers. In `report=user`, never expose a spec path, lifecycle flow, internal owner, skill, or command. If the chantier remains open, use the shared plain-language continuation choices. If push fails, say so and preserve the actual repo/check state. If nothing was committed, say so clearly.

## Rules

- Preserve unrelated dirty work unless whole-repo staging was explicitly requested.
- Re-read mutable trackers immediately before any targeted full-mode edit; never rewrite them from stale startup context.
- Skill creation, rename, or material `SKILL.md` changes require the shared runtime visibility check before commit.
- Prefer honest `shipped for iteration`, `checks skipped`, or `validation pending` wording.
- Do not turn quick daily shipping into a release rehearsal: full suites and broad check bundles require a material release, audit, migration, shared-runtime, or high-risk trigger.
- `docs not checked` forbids full closure; so does `editorial not checked`.
- A `vercel-preview-push` route never sends `107-sg-test` before `405-sg-prod`.
