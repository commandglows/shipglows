---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "contentglowz"
created: "2026-06-11"
created_at: "2026-06-11 18:00:00 UTC"
updated: "2026-06-11"
updated_at: "2026-06-11 18:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "app-site-design-system-hardening"
user_story: "En tant qu'operatrice ShipGlows, je veux une application et un site ContentGlowz qui restent strictement alignes sur un systeme de tokens commun, avec aucune personnalisation visuelle locale sans source autorisee."
owner: "Diane"
confidence: medium
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "/home/claude/contentglowz/contentglowz_theme.json"
  - "/home/claude/contentglowz/tools/generate_app_theme_tokens.mjs"
  - "/home/claude/contentglowz/tools/check_design_tokens.mjs"
  - "/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme_tokens.dart"
  - "/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme.dart"
  - "/home/claude/contentglowz/contentglowz_app/lib/presentation/screens"
  - "/home/claude/contentglowz/contentglowz_site/src"
  - "shipglows_data/technical/design-system-authority.md"
  - "shipglows_data/technical/guidelines.md"
  - "shipglows_data/technical/public-site-and-content-runtime.md"
  - "skills/references/design-system-token-contract.md"
depends_on:
  - artifact: "shipglows_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
evidence:
  - "Design-token scan from cross-project audit on 2026-06-11 found 2010 findings in 286 files in contentglowz before centralized hardening."
  - "contentglowz has explicit token sources (`contentglowz_theme.json`, `app_theme_tokens.dart`) but no shipped `shipglows_data/technical/design-system-authority.md` inside the project repo."
  - "Existing Flutter and site checks scripts already exist: `tools/generate_app_theme_tokens.mjs` and `tools/check_design_tokens.mjs`."
  - "Hardcoded app values still appear in presentation screens and site ASTRO pages, including layout, spacing, shadow, radius, color and motion properties."
supersedes: []
next_step: "/102-sg-start ContentGlowz app/site token hardening and visual standardization"
---

# Title

ContentGlowz App and Site Token Hardening and Visual Standardization

## Status

Ready.

This chantier enforces strict visual governance on both ContentGlowz surfaces (Flutter app and Astro site) so no quick-fix styling, no random new tokens, and no local exceptions are accepted without explicit authority.

## User Story

En tant qu'operatrice ShipGlows, je veux une coherence visuelle professionnelle et durable entre le site et l'application ContentGlowz sans personnalisation visuelle improvisée.

## Minimal Behavior Contract

Any UI change on app or site surfaces must consume shared tokens from the canonical source (or a generated derivative) before changing component appearance. Direct literals for colors, spacing, typography, shadows, radii, transitions, and motion timings are prohibited unless explicitly listed as temporary exceptions in the chantier documentation and authority.

If a required value is absent from the canonical token source, the chantier must update the source first, then migrate usage.

## Success Behavior

- If the chantier updates shared design tokens, Flutter and site outputs reflect those tokens without introducing new local visual literals in changed production files.
- If app screens are touched, spacing, type, radius, shadow, color and animation values are pulled from `app_theme_tokens.dart`/`AppTheme` helpers (or explicit shared extension files), and not repeated inline.
- If site components/pages are touched, visual styles use shared CSS variables and component-level abstractions generated or declared from the canonical source.
- If checks are clean, mobile and desktop surfaces render with stable layout, readable typography, and WCAG-ready contrast.

## Error Behavior

- If a value is missing in the canonical source, implementation blocks with a follow-up task to add the token first.
- If a component keeps hardcoded visual values without exception, verification fails and returns `BLOCKED`.
- If a token source changes in a way that breaks app or site visual parity, the chantier is paused until both surfaces are remediated.

## Problem

ContentGlowz already has token infra spread between JSON, generator, and generated Flutter artifacts, but it is not yet enforced equally across app and site. Without a strict anti-regression layer, teams can still add local style values and break coherence.

## Solution

Formalize one cross-surface enforcement loop:
1) designate canonical tokens and generated outputs per surface,
2) migrate active app/site files to those shared references,
3) run automated visual-literal detection + build checks,
4) block exceptions unless documented and temporary.

## Scope In

- Canonical token source: `/home/claude/contentglowz/contentglowz_theme.json`.
- Generated canonical outputs:
  - `/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme_tokens.dart`
  - Generated/authoritative theme usage in `/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme.dart` and companion helpers.
- App runtime and screens under:
  - `/home/claude/contentglowz/contentglowz_app/lib/presentation/screens`
  - `/home/claude/contentglowz/contentglowz_app/lib/presentation/widgets`
- Site runtime surfaces:
  - `/home/claude/contentglowz/contentglowz_site/src/layouts`
  - `/home/claude/contentglowz/contentglowz_site/src/components`
  - `/home/claude/contentglowz/contentglowz_site/src/pages`
- Verification tooling:
  - `/home/claude/contentglowz/tools/check_design_tokens.mjs`
  - `tools/design_system_drift_check.py --root /home/claude/contentglowz/contentglowz_site`

## Scope Out

- Product strategy, pricing, or backend/API refactors.
- Deep visual rewrite of all content pages and blog markdown.
- Changing framework stack (Flutter/Astro) outside style token governance.

## Constraints

- Canonical tokens only for visual decisions (spacing, colors, typography, radius, shadow, duration, motion).
- `contentglowz_theme.json` is the root authoring source for both surfaces.
- App and site exceptions must be explicit and tracked as temporary in task notes.
- App mobile compacting must be implemented by responsive token values / helpers, not global hacks.

## Dependencies

- `shipglows_data/technical/design-system-authority.md`
- `skills/references/design-system-token-contract.md`
- `contentglowz_theme.json`
- `tools/generate_app_theme_tokens.mjs`
- `tools/check_design_tokens.mjs`
- `contentglowz_app/lib/presentation/theme/app_theme.dart`
- `contentglowz_site/src/layouts/Layout.astro`

## Invariants

- No production visual literal in changed files without a tracked exception.
- App and site remain visually coherent on key primitives (text, buttons, cards, inputs, navigation, modals).
- Any break in canonical coherence creates a hard stop for the chantier.
- Mobile remains readable and actionable at 360px width before ship.

## Links & Consequences

Downstream:
- App and site design-system migration tasks inherit acceptance checks from this spec.
- `005-sg-ship` and `103-sg-verify` require hardening checks passing before finalization.

Upstream:
- Must align with `shipglows_data/technical/design-system-authority.md` and `skills/references/design-system-token-contract.md`.

## Documentation Coherence

- Update token contract files and changelog surfaces in each touched project when command or scope changes.
- Keep any temporary visual exceptions in explicit chantier notes and link them to expiration criteria.

## Edge Cases

- Third-party style artifacts that require non-token media/layout values.
- SVG, branding assets, and content-specific dimensions that are not reusable UI tokens.
- Platform-dependent behavior on specific screen sizes with safe exceptions for iOS/Android system bars if needed.

## Implementation Tasks

- [ ] Task 1: Declare and lock the canonical visual source for both surfaces
  - Files: `/home/claude/contentglowz/contentglowz_theme.json`, `shipglows_data/technical/design-system-authority.md`
  - Action: confirm authoritative token source and explicitly list approved exception buckets.
  - Validate with: doc review + checklist of exception entries.

- [ ] Task 2: Refresh token generation + verify generated outputs
  - Files: `/home/claude/contentglowz/tools/generate_app_theme_tokens.mjs`, `/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme_tokens.dart`
  - Action: regenerate tokens and check generated file is consistent with schema.
  - Validate with: `node /home/claude/contentglowz/tools/generate_app_theme_tokens.mjs`.

- [ ] Task 3: Harden app runtime helpers and replace hardcoded values in critical screens
  - Files: `/home/claude/contentglowz/contentglowz_app/lib/presentation/theme/app_theme.dart`, `contentglowz_app/lib/presentation/screens/*`, `contentglowz_app/lib/presentation/widgets/*`
  - Action: migrate visual decisions toward `AppSpacing`, `AppRadii`, `AppText`, `AppThemePalette`, and token-driven motion.
  - Validate with: `flutter analyze` and token checker on targeted files.

- [ ] Task 4: Correct app theme preference and mobile compact behavior via tokens
  - Files: `/home/claude/contentglowz/contentglowz_app/lib/core/app_theme_preference.dart`, `/home/claude/contentglowz/contentglowz_app/lib/main.dart`
  - Action: remove remaining global visual hacks, route compact behavior through responsive token surfaces.
  - Validate with: manual mobile check on auth/entry/feed/settings + unit/widget checks.

- [ ] Task 5: Site token injection and migration pass
  - Files: `/home/claude/contentglowz/contentglowz_site/src/layouts/Layout.astro`, key pages/components under `/home/claude/contentglowz/contentglowz_site/src`
  - Action: ensure reusable variables are injected from token source and replace local literals in core pages and shared components.
  - Validate with: `python3 tools/design_system_drift_check.py --root /home/claude/contentglowz/contentglowz_site --format markdown --warn-only`.

- [ ] Task 6: Add/align anti-literal gate for both surfaces
  - Files: `/home/claude/contentglowz/tools/check_design_tokens.mjs`, `shipglows_data/technical/design-system-authority.md`
  - Action: tighten exception allowlist and make checks executable in verification flow.
  - Validate with: script returns 0 for accepted surfaces and explicit failure on regression samples.

- [ ] Task 7: Validate responsiveness and finish proof
  - Files: `/home/claude/contentglowz/contentglowz_site/src/...`, `/home/claude/contentglowz/contentglowz_app`
  - Action: verify desktop and mobile behavior on key surfaces, complete checklist.
  - Validate with: `103-sg-verify` and completed manual checklist.

## Acceptance Criteria

- [ ] AC-1: Changed app/site files have no non-exception hardcoded colors, spacing, typography, radius, shadow, or motion values.
- [ ] AC-2: Shared token updates originate in `contentglowz_theme.json`, then regenerate/apply outputs before surface edits.
- [ ] AC-3: App and site use compatible visual language for shared components (buttons, cards, navigation, inputs, typography scale).
- [ ] AC-4: Mobile compactness is controlled through responsive token behavior and remains readable/tactile-safe.
- [ ] AC-5: Checklist includes all mandatory scenarios and proof pointers.
- [ ] AC-6: Any temporary exception includes expiry and owner in linked notes.

## Test Contract

- surface: app (Flutter) + site (Astro), public and auth flows.
- proof_profile: automated-first + manual visual sampling.
- proof_order:
  1. `cd /home/claude/contentglowz && node tools/check_design_tokens.mjs`
  2. `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/contentglowz/contentglowz_site --format markdown --warn-only`
  3. `cd /home/claude/contentglowz && flutter analyze`
  4. `cd /home/claude/contentglowz && npm --prefix contentglowz_site run build`
  5. `103-sg-verify`
- checklist_path: `shipglows_data/workflow/test-checklists/contentglowz-app-site-token-hardening-and-visual-standardization.md`
- required_scenario_ids:
  - CG-DT-APP-TOKENS-001
  - CG-DT-SITE-TOKENS-001
  - CG-DT-MOBILE-001
- required_results:
  - hardcoded visual values blocked or justified per exception list
  - app/site token generation and usage in sync
  - mobile and desktop consistency validated on critical screens
- exception_with_proof: explicit in checklist + authority note.
- exception_without_proof: forbidden.

## Test Strategy

- `cd /home/claude/contentglowz && node tools/check_design_tokens.mjs`
- `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/contentglowz/contentglowz_site --changed --format markdown`
- `cd /home/claude/contentglowz && flutter analyze`
- `cd /home/claude/contentglowz && npm --prefix contentglowz_site run build`
- Manual mobile/desktop smoke check on:
  - `contentglowz_site/src/pages/index.astro`
  - `contentglowz_site/src/pages/sign-in.astro`
  - `contentglowz_app/lib/presentation/screens/entry/entry_screen.dart`
  - `contentglowz_app/lib/presentation/screens/feed/feed_screen.dart`
- `python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/contentglowz-app-site-token-hardening-and-visual-standardization.md shipglows_data/workflow/test-checklists/contentglowz-app-site-token-hardening-and-visual-standardization.md`

## Risks

- `high`: P0 risk of silent divergence if both surfaces are remediated independently.
- `medium`: Generator/schema mismatch could create churn in Flutter output.
- `low`: Build time increase from extra checks.

## Execution Notes

- Read this order first:
  - `/home/claude/contentglowz/contentglowz_theme.json`
  - `/home/claude/contentglowz/tools/generate_app_theme_tokens.mjs`
  - `/home/claude/contentglowz/tools/check_design_tokens.mjs`
  - `shipglows_data/technical/design-system-authority.md`
- No new local visual tokens outside canonical source.
- Stop immediately on a first regression in sign-in entry, primary nav, or feed readability.
- Keep exception list minimal and with owners + expiry dates.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 18:00:00 UTC | 100-sg-spec | GPT-5 Codex | create | ready | /101-sg-ready ContentGlowz app/site token hardening and visual standardization |
| 2026-06-11 18:00:00 UTC | 101-sg-ready | GPT-5 Codex | readiness-check | ready | /102-sg-start ContentGlowz app/site token hardening and visual standardization |
| 2026-06-11 18:14:00 UTC | 001-sg-build | gpt-5.3-codex-spark | lifecycle-orchestration | partial | /102-sg-start ContentGlowz app/site token hardening and visual standardization |
| 2026-06-11 18:17:00 UTC | 102-sg-start | GPT-5 Codex | implementation-start | in-progress | /102-sg-start ContentGlowz app/site token hardening and visual standardization |

## Current Chantier Flow

- 100-sg-spec: done
- 101-sg-ready: done
- 102-sg-start: in-progress
- 103-sg-verify: not launched
- 104-sg-end: not launched
- 005-sg-ship: not launched
