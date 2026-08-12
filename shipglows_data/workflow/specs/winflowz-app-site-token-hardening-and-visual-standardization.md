---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "WinFlowz"
created: "2026-06-11"
created_at: "2026-06-11 18:20:00 UTC"
updated: "2026-06-11"
updated_at: "2026-06-12 04:02:18 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "app-site-design-system-hardening"
user_story: "En tant qu'operatrice ShipGlows, je veux une interface app/site WinFlowz strictement alignée sur un jeu de tokens unifié, sans valeurs visuelles locales non autorisees."
owner: "Diane"
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglows_data/technical/design-system-authority.md"
  - "shipglows_data/technical/guidelines.md"
  - "shipglows_data/technical/winflowz_app/guidelines.md"
  - "winflowz_app/lib/core/theme/winflowz_theme_tokens.dart"
  - "winflowz_app/lib/core/theme/app_theme.dart"
  - "winflowz_site/src/assets/styles/global.css"
  - "winflowz_site/tailwind.config.mjs"
  - "skills/references/design-system-token-contract.md"
  - "tools/design_system_drift_check.py"
depends_on:
  - artifact: "shipglows_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
evidence:
  - "WinFlowz cross-surface token audit (2026-06-11) found duplicated visual literals in both app and site surfaces (`1506` findings total, `422` high-impact after generated exclusions)."
  - "Existing token sources are present for both surfaces: `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`, `winflowz_app/lib/core/theme/app_theme.dart`, `winflowz_site/src/assets/styles/global.css`, and `winflowz_site/tailwind.config.mjs`."
  - "`winflowz_site/src/components/Button.astro` and `winflowz_site/src/pages/[...lang]/bio.astro` show direct visual literals in critical UI paths."
  - "Flutter theme screens still contain inline style paths outside canonical wrappers in edge cases (`keyboard_theme_studio_screen.dart` flagged by audit)."
supersedes: []
next_step: "/104-sg-end WinFlowz app/site token hardening and visual standardization"
---

# Title

WinFlowz App/Site Token Hardening and Visual Standardization

## Status

Ready.

This chantier enforces strict token-driven UI changes on both WinFlowz Flutter app and Astro site, including no local visual improvisation without explicit temporary exception.

## User Story

En tant qu'operatrice ShipGlows, je veux une experience WinFlowz professionnelle et cohérente, avec un contrat visuel unique pour app et site.

## Minimal Behavior Contract

Any production UI appearance change (app or site) must use tokens defined in the canonical per-surface sources. No ad-hoc colors, spacing, typography, shadow, radius, or motion values are allowed in changed files unless explicitly whitelisted as temporary exceptions.

If an existing visual value is missing, the token source is updated first and the surface is migrated afterward.

## Success Behavior

- App and site share a practical token contract and produce equivalent visual language for shared primitives.
- Flutter UI changes consume `WinFlowzThemeTokens` and `App*` helpers from canonical theme files instead of hardcoded values.
- Site components/pages consume global CSS tokens or documented Tailwind aliases.
- Mobile and desktop remain readable and usable after migration.

## Error Behavior

- If a value is used without tokenization, the modification is blocked from closing.
- If an exception is required, it is documented with owner + expiry in authority/charnier notes.
- If regression is detected (contrast, truncation, spacing collapse, tap target), the change is reverted or revised before ship.

## Problem

WinFlowz has two mature visual layers (Flutter + Astro), but migrations are still vulnerable to local visual drift. Existing findings show non-token values spread across key components and screens, threatening coherence and maintainability.

## Solution

Create and execute a cross-surface hardening path:
1) lock the canonical contract and exceptions,
2) migrate app/site key surfaces to token helpers,
3) enforce checks in verification loops,
4) gate merges on regression evidence.

## Scope In

- `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart` and `winflowz_app/lib/core/theme/app_theme.dart`
- App presentation layer:
  - `winflowz_app/lib/presentation/**/*`
  - `winflowz_app/lib/features/**/*` (UI-heavy screens/widgets only)
- Site style and surface layer:
  - `winflowz_site/src/assets/styles/global.css`
  - `winflowz_site/tailwind.config.mjs`
  - `winflowz_site/src/layouts`, `winflowz_site/src/components`, `winflowz_site/src/pages`
- Verification:
  - `tools/design_system_drift_check.py` with `--root /home/claude/winflowz/winflowz_site`
  - `flutter analyze`

## Scope Out

- Native mobile platform internals (Kotlin/Swift), unless they touch theme tokens.
- Non-UI logic and backend data/service changes.
- Generated builds and static export artifacts.

## Constraints

- Canonical source for visual style is surface-specific:
  - Flutter: `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart` + `app_theme.dart`
  - Site: `winflowz_site/src/assets/styles/global.css` + `tailwind.config.mjs`
- `App`/`App*` helpers are required migration points where appropriate.
- Exceptions must be temporary and tracked.
- Mobile compactness must remain token-driven and accessible, no arbitrary global hacks.

## Dependencies

- `shipglows_data/technical/design-system-authority.md`
- `skills/references/design-system-token-contract.md`
- `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`
- `winflowz_app/lib/core/theme/app_theme.dart`
- `winflowz_site/src/assets/styles/global.css`
- `winflowz_site/tailwind.config.mjs`

## Invariants

- No changed UI file introduces new hardcoded visual literals for color/spacing/typography/shadow/motion.
- App and site use consistent naming and shared intent for shared primitives.
- Build proof and visual scan remain part of the required close criteria.

## Documentation Coherence

- Keep design-token contracts and exceptions in `shipglows_data/technical/design-system-authority.md` and this spec.
- Surface changes should not drift without docs updates to this chantier.

## Edge Cases

- Theme previews and legacy demo files with fixtures.
- Third-party assets or embedded components requiring non-standard values.
- Platform-specific shell/OS-safe-area behavior in app and browser UI wrappers.

## Implementation Tasks

- [ ] Task 1: Lock cross-surface visual source and exception policy
  - Files: `shipglows_data/technical/design-system-authority.md`, `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`, `winflowz_site/src/assets/styles/global.css`
  - Action: confirm canonical sources + define temporary exceptions and owners.
  - Validate with: doc review + explicit exception list.

- [ ] Task 2: Align `app` visual layer with token helpers
  - Files: `winflowz_app/lib/core/theme/app_theme.dart`, `winflowz_app/lib/presentation/**`, `winflowz_app/lib/features/**/*`
  - Action: replace changed hardcoded values with `WinFlowzThemeTokens`, `AppColors`, `AppSpacing`, `AppTypography`, and remove local one-off visual values.
  - Validate with: visual-literal scan on changed Flutter files.

- [ ] Task 3: Align `site` token contracts and migration of critical components
  - Files: `winflowz_site/src/layouts`, `winflowz_site/src/components`, `winflowz_site/src/pages`, `winflowz_site/src/assets/styles/global.css`
  - Action: migrate top-value components/pages to `global.css` tokens and documented Tailwind aliases.
  - Validate with: `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/winflowz/winflowz_site --format markdown --warn-only`.

- [ ] Task 4: Add drift and consistency gate checks
  - Files: `shipglows_data/workflow/specs/winflowz-app-site-token-hardening-and-visual-standardization.md`, `shipglows_data/workflow/test-checklists/winflowz-app-site-token-hardening-and-visual-standardization.md`
  - Action: establish proof steps in this chantier; no merge without PASS on required scenarios.
  - Validate with: checklist completion.

- [ ] Task 5: Hardening verification and close
  - Files: `winflowz_app`, `winflowz_site`, `shipglows_data/workflow/*`
  - Action: run automated checks, verify mobile/desktop spot-checks, update statuses.
  - Validate with: `103-sg-verify`.

## Acceptance Criteria

- [ ] AC-1: Changed app files have no unauthorised visual literals for color, spacing, typography, radius, shadow, or motion.
- [ ] AC-2: Changed site files use shared CSS variables or documented Tailwind aliases, not ad-hoc literals.
- [ ] AC-3: App/site surfaces preserve visual continuity for buttons/cards/inputs/navigation/hero.
- [ ] AC-4: Mobile and accessibility checks pass on representative screens.
- [ ] AC-5: Temporary visual exceptions are listed with owner and expiry.
- [ ] AC-6: Checklist includes mandatory scenarios with proof pointers and statuses.

## Test Contract

- surface: app + site
- proof_profile: automated-first + manual visual checks
- proof_order:
  1. `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/winflowz/winflowz_site --format markdown --warn-only`
  2. `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/winflowz/winflowz_site --changed --format markdown`
  3. `cd /home/claude/winflowz && flutter analyze`
  4. `cd /home/claude/winflowz && pnpm --prefix winflowz_site build`
  5. Manual responsive spot-checks for mobile and desktop.
  6. `103-sg-verify`
- checklist_path: `shipglows_data/workflow/test-checklists/winflowz-app-site-token-hardening-and-visual-standardization.md`
- required_scenario_ids:
  - WFZ-APP-TOKENS-001
  - WFZ-SITE-TOKENS-001
  - WFZ-MOBILE-001
- required_results:
  - no unauthorized hardcoded visuals in changed production UI
  - consistent token-first consumption in app/site
  - mobile/touch targets and contrast remain safe
- exception_with_proof: explicit with owner and expiry only
- exception_without_proof: forbidden

## Test Strategy

- Run drift checks on winflowz site.
- Run `flutter analyze` on app.
- Build site (`pnpm --prefix winflowz_site build`) and confirm no regression.
- Manual responsive sample checks on key pages/screen (see Notes).
- Run `python3 tools/shipglows_metadata_lint.py` on new workflow artifacts.

## Risks

- `high`: Without strict token-first enforcement, app and site diverge quickly.
- `medium`: Existing legacy fixtures create pressure for exceptions.
- `low`: Build duration and scan cost while tightening lint.

## Execution Notes

- Read first:
  - `shipglows_data/technical/design-system-authority.md`
  - `shipglows_data/technical/winflowz_app/guidelines.md`
  - `winflowz_app/lib/core/theme/winflowz_theme_tokens.dart`
  - `winflowz_site/src/assets/styles/global.css`
- Keep changes surface-scoped and reviewable.
- Stop immediately on any critical readability regression at 360px.
- Temporary exception list must be explicit and removable.

## Open Questions

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 18:20:00 UTC | 100-sg-spec | GPT-5 Codex | create | ready | /101-sg-ready WinFlowz app/site token hardening and visual standardization |
| 2026-06-11 18:20:00 UTC | 101-sg-ready | GPT-5 Codex | readiness-check | ready | /102-sg-start WinFlowz app/site token hardening and visual standardization |
| 2026-06-12 03:58:56 UTC | 102-sg-start | GPT-5 Codex | implementation | implemented | /103-sg-verify WinFlowz app/site token hardening and visual standardization |
| 2026-06-12 04:02:18 UTC | 103-sg-verify | GPT-5 Codex | verify | partial | /104-sg-end WinFlowz app/site token hardening and visual standardization |
| 2026-06-12 04:02:18 UTC | 104-sg-end | GPT-5 Codex | end | deferred | /107-sg-test WinFlowz app/site token hardening and visual standardization |

## Current Chantier Flow

- 100-sg-spec: done
- 101-sg-ready: done
- 102-sg-start: implemented
- 103-sg-verify: partial
- 104-sg-end: deferred
- 005-sg-ship: not launched
