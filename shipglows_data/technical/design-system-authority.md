---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-06-11"
updated: "2026-08-13"
status: active
source_skill: 300-sg-docs
scope: design-system-authority
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/branding/branding.md
  - shipglows_data/technical/guidelines.md
  - shipglows_data/technical/code-docs-map.md
  - skills/references/design-system-token-contract.md
depends_on:
  - artifact: shipglows_data/branding/branding.md
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-06-11: every managed application must declare the canonical design-system source instead of letting agents infer or customize design per screen."
  - "2026-07-17 DevServer implementation confirms cli/lib.sh ui_* primitives as the shared gum/Bash shell UI authority."
  - "Brand 1.2.0 changes public visual hierarchy to lead with business partnership while preserving existing code-level design authority."
next_review: "2026-09-13"
next_step: "/103-sg-verify design-system-authority"
---

# Design-System Authority

## Purpose

This file defines where a ShipGlows-managed project declares the source of truth for design tokens and visual implementation.

`branding.md` owns brand direction. This technical artifact owns the code-level authority: which files, theme APIs, component variants, and validation checks agents must use before changing application UI.

## Required Project Declaration

Every project with a UI must declare a `Design-System Authority` section in the nearest governance-root technical docs:

- default location: `shipglows_data/technical/design-system-authority.md`
- monorepo-wide shared UI: monorepo-root `shipglows_data/technical/design-system-authority.md`
- app-specific exception: a scoped technical doc such as `shipglows_data/technical/apps/<app>.md`, referenced from the root design-system authority and `code-docs-map.md`

Do not create `shipglows_data/` inside each app/package just to declare design authority. Use the monorepo root governance corpus and scoped entries.

## Declaration Schema

Use this compact schema in the project artifact:

```yaml
design_system_authority:
  status: declared | missing | split-brain | not-applicable
  brand_contract: shipglows_data/branding/branding.md
  canonical_source: "path/to/tokens-or-theme"
  technology_carrier: css-custom-properties | tailwind-theme | flutter-theme | react-native-theme | native-platform-theme | dtcg-json | other
  component_bridge: "path/to/component primitives or variant system"
  layout_authority: "path/to/layout scale, breakpoints, density, safe-area, or platform measurement policy"
  motion_authority: "path/to/motion tokens or platform motion policy"
  forbidden_bypass:
    - inline visual literals outside canonical source
    - arbitrary Tailwind values outside token migration
    - screen-local colors, spacing, typography, shadows, motion, safe-area, keyboard, or overlay constants
  validation:
    - python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --changed --format markdown
    - project build/lint command
    - browser/simulator/device proof route when visual behavior changes
```

If a project has multiple frontends, list one entry per app/surface and identify the shared source when it exists.

## Technology Defaults

The declaration is project-owned, but the carrier must follow the stack:

- CSS/web default: CSS custom properties in a central token/theme/global style file.
- Tailwind v4: `@theme` variables and CSS custom properties as the runtime token layer.
- Tailwind v3: `tailwind.config.*` plus CSS variables when runtime theming is needed.
- Flutter: `ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`, shared `EdgeInsets`/radius/duration/curve constants, and component themes.
- React Native/Expo: typed shared theme/tokens object plus component variants.
- Native mobile: platform theme resources/tokens and adaptive layout APIs.
- DTCG token pipeline: `tokens.json` or equivalent only when the project actually has a token build pipeline.

The agent must not choose the easiest carrier. It must use the declared carrier or route a design-system unification task before editing UI.

## Missing Or Split-Brain Authority

If no declaration exists:

1. inspect existing brand docs, global styles, theme files, component primitives, and framework config
2. propose the declaration in this artifact or the scoped app doc
3. route to `006-sg-design system` when no coherent token layer exists
4. route to `006-sg-design` or spec-first when multiple sources compete

If components consume one theme source while pages or utilities use another, report `split-brain`. Do not make visual changes until the authority is unified or the exception is explicitly documented.

## Stop Conditions

Stop or report `partial` when:

- UI work starts and no design-system authority can be identified
- an agent wants to add visual literals outside the declared authority
- a project has competing token/theme sources without an explicit resolution
- token files are edited but component/page consumption and visual proof are not addressed
- mobile safe-area, keyboard/IME, density, touch target, or adaptive layout constants are handled screen by screen

## Maintenance Rule

Update this artifact whenever the project adds a frontend, changes styling technology, introduces a token pipeline, changes component primitives, changes theme mode behavior, or accepts a documented platform-bound exception.

## ShipGlows Surface Declarations (2026-06-26)

- `ShipGlows DevServer shell`:
  - status: `declared`
  - brand_contract: `shipglows_data/branding/branding.md`
  - canonical_source: `cli/lib.sh` shared `ui_*` primitives
  - technology_carrier: `other` (ANSI/Bash with optional gum and fzf adapters)
  - component_bridge: `ui_choose`, `ui_filter_choose`, `ui_letter_list`, `ui_back_label`, `ui_text_center`, `ui_list_filter`, `ui_traffic_color`
  - layout_authority: `ui_screen_header`, `ui_header`, `ui_text_center`
  - motion_authority: terminal-native; spinners and pending-input handling stay behind shared helpers
  - forbidden_bypass:
    - frontend-local letter generation, cancellation semantics, status colors, or centering logic
    - fixed input waits outside `ui_flush_pending_input`
    - direct gum/Bash styling that changes observable selection behavior without updating the shared primitive
  - validation:
    - `bash tests/cli/input-validation.sh`
    - `bash tests/cli/menu-navigation.sh`
    - real-TTY gum and Bash fallback cancellation walkthrough when interaction behavior changes

- `shipglows-site`:
  - status: `declared`
  - brand_contract: `shipglows_data/branding/branding.md`
  - canonical_source: `shipglows-site/src/styles/global.css`
  - technology_carrier: `css-custom-properties`
  - component_bridge: `shipglows-site/src/components/NavBar.astro`, `shipglows-site/src/components/Hero.astro`, and the shared component set under `shipglows-site/src/components`
  - layout_authority: `shipglows-site/src/styles/global.css` plus shared page composition in `shipglows-site/src/pages/index.astro` and `shipglows-site/src/pages/fr/index.astro`
  - motion_authority: `shipglows-site/src/styles/global.css`
  - forbidden_bypass:
    - inline visual literals inside Astro components when a shared CSS rule or token can own the decision
    - mobile-nav, hero, spacing, shadow, or elevation values created directly in page/component markup
    - locale-specific visual overrides that diverge from the shared home component system without explicit proof
  - validation:
    - `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --root "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/shipglows-site" --changed --format markdown`
    - `npm --prefix "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/shipglows-site" run build`
    - browser/mobile proof on `/` and `/fr/` when home or navigation visuals change

- `ShipGlows Atlas overlay`:
  - status: `declared`
  - brand_contract: not applicable; developer-only inspection chrome must not inherit or mutate the inspected application's brand system
  - canonical_source: `injectors/web-inspector.css` (`--sg-atlas-*` custom properties)
  - technology_carrier: `css-custom-properties`
  - component_bridge: `injectors/web-inspector.js` Atlas toggle, labels and panel
  - layout_authority: the overlay stylesheet's spacing, layer and responsive panel tokens
  - motion_authority: the overlay stylesheet; no application motion token is consumed
  - forbidden_bypass:
    - inline Atlas visual literals in `injectors/web-inspector.js`
    - modifying inspected application tokens, components or styles from the overlay
    - loading a remote stylesheet or script for Atlas mode by default
  - validation:
    - `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --changed --format markdown`
    - `node --check injectors/web-inspector.js`
    - browser proof on an opted-in dev/preview project before visual completion is claimed
