---
name: 005-sg-ship
description: "Ship with checks, commits, pushes, and closure when needed."
argument-hint: [optional: commit message | "end la tache" for full close | skip-check | all-dirty]
---

Primary artifact type: `specialist-workflow`.

## Canonical Paths

Before resolving ShipGlows-owned content, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Resolve shared and local references from that root; resolve project artifacts from the selected project root.

## Instruction Layering

This activation contract keeps ownership, mode selection, pre-mutation stops, proof limits, and reference triggers local. Load at most one local playbook before the first substantive action; local references do not chain.

## Chantier Tracking

Trace category: `obligatoire`. Process role: `lifecycle`.

For a unique spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read its history and flow, then record `005-sg-ship` as `shipped`, `not shipped`, `blocked`, or `skipped checks`. Otherwise use a `(local)` chantier header without writing to a spec.

## Report Modes

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default to concise, outcome-first `report=user`; use detailed evidence only for explicit agent, handoff, verbose, or full-report requests.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before ShipGlows-owned references, tools, scripts, or runtime checks.

## Mission And Ownership

`005-sg-ship` owns bounded Git shipping: checks, staging, commit, push, and required post-push routing. It does not prove implementation completeness (`102-sg-start`), proof completeness (`103-sg-verify`), production truth (`405-sg-prod`), or closure bookkeeping (`104-sg-end`) unless full-close mode was explicit.

It answers: `What git state should be shipped now, and with what explicit limits?`

If closure bookkeeping is the next unresolved owner, remain with `104-sg-end`; quick ship is not a closure substitute.

## Mode And Scope Decision

- Default mode is `quick`.
- Select `full` only when `$ARGUMENTS` includes `end la tache`, `end`, `fin`, or `close task` as an explicit end-of-task intent.
- Default staging is limited to files clearly belonging to the current task or intentionally selected scope.
- Select whole-repo staging only when `$ARGUMENTS` explicitly includes `all-dirty`, `ship-all`, or `tout-dirty`.
- `skip-check` skips checks but never skips secret, dirty-scope, bug-risk, protected-surface, or proof-claim gates.

Quick mode performs bounded checks when practical, stages, commits, pushes, and reports. It never updates `TASKS.md` or `CHANGELOG.md` and never claims formal closure.

Full mode may update trackers, changelog, and durable decisions before the same Git ship sequence. Before it does so, load `$SHIPGLOWS_ROOT/skills/005-sg-ship/references/full-close-playbook.md`; also load `closure-archive-guard.md` and `documentation-reflection-gate.md`. A material documentation gap prevents full-closure wording and routes to `300-sg-docs`.

Before either mode mutates Git, load exactly one local reference: `$SHIPGLOWS_ROOT/skills/005-sg-ship/references/ship-execution-playbook.md`. Full mode loads its full-close playbook only after the common pre-mutation gates pass.

## Stops Before Mutation

Stop before staging or committing when:

- the target repo or bounded staging scope is ambiguous;
- an unignored `.env`, credential, key, token, or other suspected secret is in scope;
- a required or attempted check fails;
- a linked high/critical bug is open in `open`, `needs-info`, `needs-repro`, `in-diagnosis`, or `fix-attempted`;
- an applicable Atlas staged-path preflight returns `block`;
- high-risk auth, permissions, payments, billing, tenant, destructive, migration, webhook, background-job, or public-flow changes have no meaningful validation and the user has not accepted explicit partial-risk shipping.

A user may explicitly authorize shipping despite a blocked bug or partial validation, but the report must retain the risk and must not claim closure, safety, or readiness. Never commit secrets. Never force-push `main` or `master`.

When a project owns an Atlas registry, load `$SHIPGLOWS_ROOT/skills/references/atlas-protection-preflight.md` and rerun it against staged paths before commit.

## Evidence Boundaries

Classify linked bug risk as `blocked`, `partial-risk`, or `not assessed`; quick mode reports it even with skipped checks. A green check, clean push, updated tracker, or changelog is not proof that the user story, product, security, visual behavior, auth flow, or production behavior is complete.

Read `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` before choosing post-push proof. For `vercel-preview-push`, and for hosted-sensitive `hybrid` changes, a successful push routes immediately to `405-sg-prod`; do not request or claim browser/manual proof first.

## Step 8 — One report

Immediately before reporting, load `$SHIPGLOWS_ROOT/skills/005-sg-ship/references/ship-report-evidence.md`. Report the actual commit/push result, repo state, checks, notable staging scope, bug risk, documentation status, and remaining validation. Match the user's language and keep stable hashes, branches, paths, and status values literal.

Start with the shared chantier and verdict headers. In `report=user`, never expose a spec path, lifecycle flow, internal owner, skill, or command. If the chantier remains open, use the shared plain-language continuation choices. If push fails, say so and preserve the actual repo/check state. If nothing was committed, say so clearly.

## Rules

- Preserve unrelated dirty work unless whole-repo staging was explicitly requested.
- Re-read mutable trackers immediately before any targeted full-mode edit; never rewrite them from stale startup context.
- Skill creation, rename, or material `SKILL.md` changes require the shared runtime visibility check before commit.
- Prefer honest `shipped for iteration`, `checks skipped`, `docs not checked`, or `validation pending` wording. `docs not checked` forbids full closure.
- A `vercel-preview-push` route never sends `107-sg-test` before `405-sg-prod`.
