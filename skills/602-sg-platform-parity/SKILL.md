---
name: 602-sg-platform-parity
description: "Audit product and technical parity across supported platforms."
argument-hint: '<project | feature | spec path> [platforms=web,android,ios,windows,macos,linux] [report=agent]'
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Load `references/platform-parity-matrix.md` when writing or reviewing a parity matrix, decision log, or platform QA routing. Keep detailed feature findings in project artifacts, not in this skill body.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

Because this skill can reveal cross-platform gaps, evaluate the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report. Add a `Chantier potentiel` block when parity gaps require non-trivial implementation, platform QA, documentation correction, or release sequencing and no unique chantier owns the work.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, decision-oriented, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` when another skill needs the full parity matrix, evidence ledger, or routing detail.

## Mission

`602-sg-platform-parity` keeps product expectations and implementation reality aligned across platforms. It answers: "Do users get the same capability everywhere we claim support, and when they should not, is the adaptation better, explicit, and tested?"

It is an audit and orchestration skill. It does not implement feature ports directly. It routes implementation to `100-sg-spec`, `001-sg-build`, `107-sg-test`, `103-sg-verify`, `300-sg-docs`, or `005-sg-ship` with a clear parity contract.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest useful scope:

- FEATURE MODE: a named capability, screen, workflow, integration, or spec path.
- PROJECT MODE: all visible supported platforms for the current project.
- RELEASE MODE: pending ship or release candidate where platform claims must be checked before publication.
- DOCS CLAIM MODE: user asks whether docs, store copy, site copy, README, or changelog overpromise support.

Default platform set is discovered from project code, docs, specs, package metadata, and deployment files. If discovery is incomplete, report the unknowns instead of inventing support.

## Parity Decision Model

Classify each capability per platform:

- `same`: same user-facing behavior and interaction contract.
- `adapted-better`: platform-native adaptation that improves the outcome without surprising users.
- `adapted-required`: OS, browser, store, hardware, permission, or distribution constraint requires a different interaction.
- `degraded-accepted`: weaker behavior is explicitly accepted, documented, and routed to QA.
- `not-supported`: intentionally absent and not promised.
- `unknown`: evidence is missing.

Do not accept "different" merely because platforms differ. The default expectation is product parity. Prefer the same experience unless the adapted experience is materially better or required by platform constraints.

## Core Workflow

1. Discover platform claims:
   - supported platforms in docs, site copy, app metadata, package manifests, store/readme text, specs, and tasks
   - platform-specific code paths, bridges, permissions, and native hosts
   - existing tests, manual checklists, CI/build surfaces, and known QA limits
2. Build or update a parity matrix using `references/platform-parity-matrix.md`.
3. Compare the intended product concept against platform implementation evidence.
   - For UI platforms, compare the design-system authority across web/mobile/desktop: canonical token source, platform theme carrier, component bridge, layout/motion authority, accessibility states, and validation. Mark platform-specific local styling as a parity risk unless it is an intentional documented adaptation.
4. Separate OS constraints from implementation debt:
   - OS/store/browser limitation
   - native integration missing
   - Flutter/shared UI missing
   - test or manual QA missing
   - docs or public claim drift
5. Route follow-up:
   - `100-sg-spec` when a new platform parity chantier is needed
   - `001-sg-build` when a ready parity implementation can start
   - `107-sg-test` when native/device QA is the missing proof
   - `103-sg-verify` when implementation exists but readiness is uncertain
   - `300-sg-docs` when public/internal claims need correction
   - `005-sg-ship` only after verification and bounded ship scope

## Required Evidence

For every platform claim, collect at least one concrete evidence pointer:

- code path, bridge, native host, permission, route, component, or config
- automated test, build check, manual checklist, CI run, deployed proof, or device QA record
- spec, task, changelog, README, platform behavior doc, or public page claim
- design-system authority, token source, platform theme carrier, component primitive, or drift-check output for UI parity claims

If evidence is absent, mark the cell `unknown` or `proof-gap`; do not infer support from a scaffold, dependency, permission string, or aspirational roadmap text.

## Output Artifacts

When the run creates durable output, prefer project-owned paths:

- `shipglows_data/workflow/audits/<date>-platform-parity.md` for audit reports
- `shipglows_data/workflow/specs/<feature>-platform-parity.md` for new chantiers
- `shipglows_data/workflow/verification/<feature>-platform-parity-checklist.md` for manual QA
- project docs only when claims or operator guidance actually change

## Stop Conditions

Stop and report blocked when:

- platform ownership, target list, or claim source cannot be identified safely
- a required source is unavailable and the missing source changes the parity verdict
- the requested action would implement or ship product changes without routing through the owner skill
- an adaptation would reduce user trust, privacy, security, accessibility, or data safety without explicit acceptance
- dirty unrelated files would need to be overwritten to record the parity artifact

## Validation

Validate this skill after edits with:

```bash
rg -n "Trace category|Process role|Parity Decision Model|Core Workflow|Required Evidence|Stop Conditions|references/platform-parity-matrix" skills/602-sg-platform-parity/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill 602-sg-platform-parity
```
