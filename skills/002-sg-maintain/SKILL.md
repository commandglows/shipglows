---
name: 002-sg-maintain
description: "Orchestrate project maintenance from triage to ship."
argument-hint: [optional: quick | full | security | deps | docs | audits | global | no-ship | report=agent]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving a ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, references, templates, workflow docs, and internal scripts resolve from there; project artifacts resolve from the current project root unless stated otherwise.

## Public Métier Ownership

Public label: `sg-maintenance`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or lane selection. Resolve `project -> product -> surface -> feature`, ask only material operator decisions, and retain the maintenance outcome through proof and closure.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before execution. Continue exactly one matching active `specs/*.md` chantier by updating `Skill Run History` and `Current Chantier Flow`; use its opening header. When none exists, use `100-sg-spec` then `101-sg-ready` for non-trivial work, or record a short mini-contract in the final report for a safe, narrow local fix. Ask if several specs plausibly match.

## Report Modes

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to `report=user`: concise, lifecycle-result first, and with the chantier header. `report=agent`, `handoff`, `verbose`, and `full-report` add detailed evidence.

## Required References

Before mode selection, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; ambiguous or invalid invocations never activate this skill. Before topology and lifecycle routing, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` and `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Load `$SHIPGLOWS_ROOT/skills/002-sg-maintain/references/maintenance-playbooks.md` before intake, lane execution, security work, or detailed reporting. It owns the context-discovery commands, lane playbooks, delegation-role detail, detailed security checklist, and full report template.

For documentation governance, additionally load `project-governance-rules.md` for topology/corpus compliance and `documentation-governance-rules.md` for placement, metadata, duplicates, or update discipline.

## Mission And Scope

`002-sg-maintain` owns existing-project upkeep across bug, dependency, documentation, audit, check, security, migration, and release-preparation lanes. It orchestrates the owners below; it neither duplicates their internals nor leaves the operator to stitch commands together.

- bug lifecycle -> `003-sg-bug`; dependency, security/code audit, or migration -> `010-sg-technical deps|audit|migrate`; docs -> `300-sg-docs`; checks -> `105-sg-check`; broad audit -> `400-sg-audit`; tracker updates -> `011-sg-pilotage tasks`.
- repair or feature delivery -> `106-sg-fix` or `001-sg-build`; verification and closure -> `103-sg-verify` then `104-sg-end`; deployment proof or bounded ship -> `004-sg-deploy` or `005-sg-ship`.
- route directly when one feature, one bug loop, one release-confidence pass, or one obvious specialist lane already dominates the request.

## Execution Topology

Use `main-only` only for conversation or one focused read-only scope. For independent read-only lanes, apply the selected canonical batch matrix and integrate their evidence. Mutations stay `delegated sequential` unless a ready spec defines non-overlapping `Execution Batches` for `spec-gated parallel` work. Explicit `/002-sg-maintain` is consent for bounded maintenance delegation in the current project; do not dispatch overlapping writes or ship unrelated dirty files.

## Mode Detection

Parse `$ARGUMENTS` after preflight:

- empty -> full maintenance lifecycle for the current project; `quick` -> read-only triage only.
- `full` -> broad maintenance lifecycle; `security` -> security maintenance through bug, dependency, code-audit, remediation, verification, and ship gates.
- `deps`, `docs`, or `audits` -> the matching owner lane, then remediation lifecycle when findings cross the implementation threshold.
- `global` -> read-only workspace dashboard; ask for a project before modifying more than one project.
- `no-ship` -> verify and report ship-ready, but do not invoke `005-sg-ship` or `004-sg-deploy`.
- `report=agent`, `handoff`, `verbose`, or `full-report` -> detailed evidence in addition to the selected mode.

If a request is specifically to fix, migrate, deploy, or build one thing, retain this master only when it is maintenance work; otherwise hand off to that owner.

## Lifecycle And Gates

Follow the shared lifecycle: intake -> triage -> work-item/spec gate -> owner execution -> focused validation -> documentation and editorial update plans when changed surfaces require them -> `103-sg-verify` -> closure -> ship/deploy. Run dependent phases sequentially and retain only evidence-backed findings.

Use a full spec for production behavior, auth, permissions, data, payments, webhooks, secrets, migrations, dependencies, deployment/rollback risk, multiple files or owners, public claims/docs, or staged proof. Do not implement until `101-sg-ready` is `ready`; a mini-contract is only for a low-risk, local, verifiable fix.

After execution, run focused owner validation and `105-sg-check` when applicable; produce the documentation and, when public claims changed, editorial update plans; then verify. Unless `no-ship` applies, route successful bounded repo/docs/tooling work to `005-sg-ship`, and deployment/browser/production proof to `004-sg-deploy`.

## Stop Conditions

Stop and report `blocked` when project scope or matching chantier is ambiguous; non-trivial work lacks a ready contract; write ownership overlaps; requested work would modify multiple projects without selection; required dependency/security tooling, credentials, or hosted-validation mode is unavailable; security, auth, secret, payment, data, deployment, or rollback evidence is unresolved; checks or verification fail; or the ship scope contains unrelated dirty files.

Never call missing `SECURITY.md`, `.env.example`, or development-mode documentation a vulnerability by itself; report it as a gap. Never call security posture `safe` on partial evidence: use `needs review`.

## Important Rules

- Maintenance ends only as `verified`, `shipped`, `ship-ready` under `no-ship`, or at a named blocked gate.
- Do not invent audit freshness or bypass specialist, validation, documentation, verification, closure, or ship gates.
- Do not commit, push, deploy, or mark complete outside `005-sg-ship` or `004-sg-deploy`.
