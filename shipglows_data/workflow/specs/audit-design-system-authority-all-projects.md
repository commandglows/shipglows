---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipglows"
created: "2026-06-11"
created_at: "2026-06-11 14:12:23 UTC"
updated: "2026-08-12"
updated_at: "2026-06-11 14:17:50 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "cross-project design-system governance audit"
owner: "Diane"
confidence: high
user_story: "En tant qu'opératrice ShipGlows, je veux auditer chaque projet produit du serveur contre la doctrine design-system authority, afin d'empêcher les agents de produire des UI incohérentes ou des tokens locaux hors source canonique."
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "/home/claude/contentglowz"
  - "/home/claude/gocharbon"
  - "/home/claude/replayglowz"
  - "/home/claude/shipglows_app"
  - "/home/claude/socialglowz"
  - "/home/claude/temu"
  - "/home/claude/winflowz"
  - "shipglows_data/technical/design-system-authority.md"
  - "skills/references/design-system-token-contract.md"
  - "tools/design_system_drift_check.py"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 migrates the branding dependency to the canonical shipglows_data/branding/branding.md authority with the same reviewed 1.1.0 contract."
  - "2026-06-11 server scan found UI/app signals in contentglowz, gocharbon, replayglowz, shipglows_app, socialglowz, temu, and winflowz."
  - "2026-06-11 server scan found design-system authority already present in shipglows and temu."
  - "2026-06-11 server scan found missing design-system authority in contentglowz, gocharbon, replayglowz, shipglows_app, socialglowz, and winflowz."
  - "Several missing-authority projects already have theme/token files, so the immediate risk is governance drift rather than absence of all design primitives."
next_step: "/300-sg-docs technical design-system-authority contentglowz"
---

# Spec: Audit Design-System Authority All Projects

## Title

Audit Design-System Authority All Projects

## Status

Ready.

## User Story

En tant qu'opératrice ShipGlows, je veux auditer chaque projet produit du serveur contre la doctrine design-system authority, afin d'empêcher les agents de produire des UI incohérentes ou des tokens locaux hors source canonique.

## Minimal Behavior Contract

The audit accepts the current server project set, detects UI/app projects, checks whether each has a canonical design-system authority declaration, identifies existing token/theme/component sources, classifies each project as compliant, missing-authority, partial, or blocked, and produces a prioritized remediation route. If a project lacks enough evidence or has dirty/unavailable state, the audit records an explicit proof gap instead of editing or guessing. The easy edge case to miss is a project that already has token/theme files but no governance authority, which must be treated as a documentation/governance defect before any visual implementation continues.

## Success Behavior

Given a project has UI or app surfaces, when the audit runs, then it reports the canonical design-system authority status and the source files that appear to own tokens, themes, components, layout, motion, or mobile design constants.

Given a project is missing `shipglows_data/technical/design-system-authority.md`, when it has UI surfaces, then the audit classifies it as a governance gap and routes remediation to `300-sg-docs` and `006-sg-design` before visual implementation work.

Given a project already has a design-system authority, when the audit runs, then it still verifies whether the declared authority matches actual token/theme/component files and whether drift-check evidence is available.

Given a project has no UI/app surface, when the audit runs, then it records `not applicable` with the evidence used for that classification.

## Error Behavior

If a project path is missing, unreadable, or not a git/project root, record `blocked` for that project and continue with the others.

If a project has unrelated dirty files, keep the audit read-only and do not modify it without a project-specific owner decision.

If the scan detects possible secret or private paths while traversing projects, do not copy secret contents into reports; record only redacted path-level evidence.

If a project has multiple competing token/theme sources and no declared authority, classify it as `partial` or `missing-authority` and route to a project-specific authority decision instead of choosing silently.

## Problem

ShipGlows now has a central design-system token doctrine, but the product repos on the server were created before this doctrine was formalized. Agents can still enter those repos and produce local UI changes unless each project declares a canonical source for colors, typography, spacing, shadows, motion, component variants, layout constants, and mobile/app behavior.

## Solution

Run a staged cross-project audit. First produce a read-only inventory and compliance matrix. Then, project by project, create or update the project-local `shipglows_data/technical/design-system-authority.md` and route deeper token/component audits only where the authority exists or is intentionally created.

## Scope In

- Audit these detected product/project repos: `contentglowz`, `gocharbon`, `replayglowz`, `shipglows_app`, `socialglowz`, `temu`, and `winflowz`.
- Keep `shipglows` as the reference/control project because it already has the doctrine and tooling.
- Detect UI/app surfaces from project markers such as `package.json`, `astro.config.*`, `vite.config.*`, `tailwind.config.*`, `pubspec.yaml`, `app.json`, and source directories.
- Check for canonical authority at `shipglows_data/technical/design-system-authority.md`, with monorepo root handling.
- Identify likely token/theme/component authority candidates.
- Run broad drift scans only in warn-only/read-only mode.
- Produce a central audit report under `shipglows_data/workflow/audits/`.
- Route per-project remediation, not a bulk blind rewrite.

## Scope Out

- No visual redesign.
- No direct UI implementation in product apps during the initial audit.
- No bulk edits across multiple product repos before each project has a specific remediation contract.
- No production deployment, app release, or visual screenshot QA in the inventory phase.
- No modification of unrelated dirty files in any project.
- No assertion that a project is visually excellent just because an authority file exists.

## Constraints

- Use `skills/references/design-system-token-contract.md` as the governing doctrine.
- Project authority defaults to `shipglows_data/technical/design-system-authority.md`.
- Monorepos use one governance-root authority unless a standalone subproject exception is documented.
- Preserve existing brand direction and product-specific design primitives.
- Do not create local one-off styling exceptions as part of the audit.
- Reports must distinguish `missing authority`, `authority present but unverified`, `token drift`, and `not applicable`.
- Keep all scans non-destructive and avoid copying secrets, credentials, private URLs, cookies, or sensitive logs.
- Active user-facing reporting is in French; durable internal contract headings remain English.
- Runtime impact: none; this chantier creates governance audit artifacts and does not change runtime app code, Sentry setup, diagnostics, or build headers.

## Test Contract

- `surface`: cross-project governance audit for UI/app design-system authority.
- `proof_profile`: evidence-first, read-only inventory plus focused mechanical checks.
- `proof_order`: project discovery -> UI/app classification -> authority detection -> token/theme candidate detection -> warn-only drift scan -> report -> readiness/verification.
- `checklist_path`: none for the first inventory; add project-specific checklists only if remediation requires manual visual/mobile proof.
- `required_scenario_ids`: `authority-inventory`, `missing-authority-routing`, `existing-authority-control`, `token-source-candidates`, `dirty-project-safety`.
- `required_results`: central report lists every audited project, status, evidence, remediation route, and proof gaps.
- `exception_with_proof`: screenshots/mobile/device proof are not required for the first governance inventory because no visual implementation is being claimed.
- `exception_without_proof`: none.

## Dependencies

- `shipglows_data/technical/design-system-authority.md` as the ShipGlows reference authority model.
- `skills/references/design-system-token-contract.md` as the contract for allowed visual decisions.
- `tools/design_system_drift_check.py` for mechanical drift scanning.
- Project-local `shipglows_data/`, `CLAUDE.md`, package/config files, theme/token files, and existing specs.
- Fresh external docs verdict: `fresh-docs not needed` for the first inventory because it audits local governance and source structure, not framework behavior or API semantics.

## Invariants

- Audit first, edit later.
- The project-local code remains the implementation truth; governance docs must describe actual token/theme/component sources, not desired future architecture.
- A project with tokens but no authority is not compliant.
- A project with authority but no drift/check evidence is not fully verified.
- Accessibility and mobile app safety cannot be weakened to satisfy token discipline.
- Every remediation must be scoped to one project unless a ready spec defines non-overlapping execution batches.

## Links & Consequences

Upstream:
- ShipGlows design-system token doctrine and project governance layout.
- Existing product app tokens/themes/components.

Downstream:
- `300-sg-docs` creates or updates project authority docs.
- `006-sg-design` or `500-sg-design-from-scratch` handles projects without a coherent token system.
- `503-sg-audit-design-tokens` and `504-sg-audit-components` handle deeper health checks.
- `103-sg-verify` checks whether the inventory and remediation routes satisfy this spec.
- `005-sg-ship` ships only bounded changes in the active repo.

## Documentation Coherence

The first audit creates or updates a central ShipGlows workflow audit report. It does not alter project docs unless a project-specific remediation task is started. Each project that lacks authority should later receive a local `shipglows_data/technical/design-system-authority.md` or an explicit documented exception.

## Edge Cases

- `shipglows_app` stores governance under `app/shipglows_data` signals, but the repo root has the git root; the audit must identify whether this is a standalone exception or migration debt.
- `socialglowz` has both root app and `site/` governance signals; the audit must avoid treating nested governance as authoritative without a documented monorepo rule.
- `contentglowz`, `replayglowz`, and `winflowz` mix site and Flutter app surfaces; authority may need scoped entries per surface under one root.
- File names containing `theme` may be content topics rather than design-system tokens; candidate detection must be checked against source context.
- Existing dirty files in a repo must not be staged or overwritten by this chantier.

## Implementation Tasks

- [x] Task 1: Create the ready spec.
  - File: `shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md`
  - Action: Capture scope, project set, gates, proof path, and remediation route.
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md`

- [x] Task 2: Run read-only project inventory.
  - File: `shipglows_data/workflow/audits/2026-06-11-design-system-authority-all-projects.md`
  - Action: Record each project, UI evidence, authority status, token/theme candidates, dirty-state note, and remediation priority.
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/audits/2026-06-11-design-system-authority-all-projects.md`

- [x] Task 3: Run mechanical drift checks where practical.
  - Files: product project source trees, read-only.
  - Action: Run `tools/design_system_drift_check.py --format markdown --warn-only` from each UI project or scoped subproject when the tool can classify files safely.
  - Validate with: report includes command status or explicit exception per project.

- [x] Task 4: Prioritize remediation.
  - File: `shipglows_data/workflow/audits/2026-06-11-design-system-authority-all-projects.md`
  - Action: Rank projects by missing authority, existing token source confidence, monorepo complexity, and likely UI drift risk.
  - Validate with: every missing-authority project has a concrete next owner route.

- [x] Task 5: Verify ShipGlows audit artifacts.
  - Files: this spec and the central audit report.
  - Action: Run metadata lint, drift-check script smoke, focused report coverage checks, and `103-sg-verify`.
  - Validate with: checks named in `Test Strategy`.

## Acceptance Criteria

- [x] AC 1: Every detected product UI/app project is listed with an authority status.
- [x] AC 2: Projects missing `design-system-authority.md` are not marked compliant even when they have token/theme files.
- [x] AC 3: `temu` and `shipglows` are used as authority-present controls, not assumed perfect.
- [x] AC 4: The audit report distinguishes root governance, nested governance, and missing governance.
- [x] AC 5: No product project is modified during the first read-only inventory.
- [x] AC 6: Every remediation recommendation names an owner skill and a concrete next action.
- [x] AC 7: Validation output records metadata lint and drift-check evidence or named exceptions.

## Test Strategy

- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/audit-design-system-authority-all-projects.md`
- `python3 tools/design_system_drift_check.py --format markdown --warn-only`
- `python3 tools/design_system_drift_check.py --changed --format markdown --warn-only`
- `git status --short` before and after inventory to prove only ShipGlows audit artifacts changed.
- Focused project discovery command listing `.git`, `shipglows_data`, UI markers, authority files, and token/theme candidates.
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/audits/2026-06-11-design-system-authority-all-projects.md`

## Risks

- Cross-repo blast radius: mitigated by read-only inventory first and per-project remediation later.
- False positives in token/theme detection: mitigated by reporting candidates with confidence, not claiming ownership without context.
- Monorepo governance ambiguity: mitigated by explicitly classifying nested `shipglows_data` as migration debt unless documented.
- Operator fatigue: mitigated by ranking projects and fixing one project at a time.
- Unrelated dirty work: mitigated by checking git status and not staging unrelated files.
- Security impact: none, because the first phase is read-only governance inventory and must not copy secrets, credentials, cookies, private logs, or sensitive payloads.

## Execution Notes

Read first:
- `skills/references/design-system-token-contract.md`
- `shipglows_data/technical/design-system-authority.md`
- `shipglows_data/technical/guidelines.md`
- each project `CLAUDE.md` when present
- each project `shipglows_data/technical/code-docs-map.md` when present

Recommended route:
1. `101-sg-ready` on this spec.
2. `102-sg-start` for the read-only inventory report in ShipGlows.
3. `103-sg-verify` to check the inventory against acceptance criteria.
4. Project-specific `300-sg-docs`/`006-sg-design` chantiers for remediation.

Stop conditions:
- A project has unclear ownership or path ambiguity that would change where authority should live.
- A remediation would require editing a product repo before inventory is accepted.
- A scan would include secrets or private generated outputs.
- A product repo has dirty files that overlap with the proposed remediation.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 14:12:23 UTC | 100-sg-spec | GPT-5 Codex | Created cross-project design-system authority audit spec from the server scan and operator approval to proceed. | draft spec created | `/101-sg-ready audit-design-system-authority-all-projects` |
| 2026-06-11 14:14:20 UTC | 101-sg-ready | GPT-5 Codex | Validated structure, user story fit, design-system authority contract, read-only proof path, documentation coherence, and security scope. | ready | `/102-sg-start audit-design-system-authority-all-projects` |
| 2026-06-11 14:16:25 UTC | 102-sg-start | GPT-5 Codex | Created the read-only cross-project authority inventory report and ran warn-only drift scans for the detected UI/app projects. | implemented | `/103-sg-verify audit-design-system-authority-all-projects` |
| 2026-06-11 14:17:50 UTC | 103-sg-verify | GPT-5 Codex | Verified metadata, report coverage, changed-file drift check, diff check, evidence-first proof path, and project-by-project remediation routing. | verified | `/300-sg-docs technical design-system-authority contentglowz` |

## Current Chantier Flow

```text
100-sg-spec: done (draft created)
101-sg-ready: done (ready)
102-sg-start: done (implemented; auto-verify skipped because 001-sg-build owns lifecycle verification)
103-sg-verify: done (verified for inventory scope)
104-sg-end: not needed for this continuing audit sequence
005-sg-ship: pending if the operator wants to ship the audit artifacts before project remediation
```
