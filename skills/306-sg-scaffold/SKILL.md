---
name: 306-sg-scaffold
description: "Scaffold pages, components, routes, hooks, and utilities."
disable-model-invocation: true
argument-hint: <type> <name> (e.g., "page about", "component UserCard")
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving ShipGlows-owned files (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). Project source resolves from the current project root.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` only when attached to one unique spec-first chantier. Otherwise use a `(local)` chantier header and do not edit a spec.

## Mission

Create a page, component, layout, API route, content entry, hook, or utility that looks native to the project because it is derived from verified local patterns.

## Scope Gate

Parse `$ARGUMENTS` as `<type> <name>`, where type is `page`, `component`, `layout`, `api`, `content`, `hook`, or `util`. If either value is missing, ask a targeted question.

Resolve conventions in this strict order: **project examples > loaded blueprint > inference**. Read 2-3 complete examples of the same type plus the nearest flow, route, layout, primitive, validation, security, and documentation owners that affect the scaffold.

If `$BLUEPRINT_PATH` is set or a `blueprint:` handoff is present, preserve that handoff, load the blueprint contract and file, and use them only where project examples do not already decide. On a true clean slate, the blueprint may become primary.

## Required References

- Load `$SHIPGLOWS_ROOT/skills/306-sg-scaffold/references/scaffold-discovery-playbook.md` after type and name are known and before generation.
- Load `$SHIPGLOWS_ROOT/skills/306-sg-scaffold/references/scaffold-generation-playbook.md` only when discovery has produced a safe, coherent generation contract.
- Load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` only for `$BLUEPRINT_PATH` or a `blueprint:` handoff, then read the named blueprint.
- Load `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` before any page, component, layout, or artifact that introduces UI styling or visual decisions.
- Load only the relevant Supabase auth, storage, or database reference when the detected project and scaffold actually touch that boundary.

## Stop Conditions

Do not scaffold when reliable examples and an applicable blueprint are both absent, unless a professional behavior-only safe shell is explicitly justified by the generation playbook.

Stop and ask targeted questions when ambiguity changes auth or authorization, tenant/org/project boundaries, data visibility, destructive or billable actions, external trust, public navigation, success/error behavior, or documentation truth.

Never invent server authorization, tenant scoping, validation, secret handling, webhook trust, pricing/security/compliance/capability claims, or privileged mutations. UI visibility is never authorization. For styled UI, stop if no canonical design-system authority is discoverable; do not create raw colors, spacing, typography, radii, shadows, motion, or a parallel component system.

If a blueprint conflicts with project terminology, routes, component APIs, security boundaries, or established patterns, the project wins. Surface material conflicts before writing.

## Report Modes

On success, report type/name, created files, examples used, matched patterns, blueprint/version when applicable, security impact, and documentation impact. On a stop, report `NOT SCAFFOLDED`, the precise ambiguity or missing authority, targeted decisions required, and the safest next path. Never fake completeness.

## Validation

- `python3 -m unittest tools.test_306_sg_scaffold_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --skill 306-sg-scaffold`
