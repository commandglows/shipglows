---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-06-11"
updated: "2026-08-24"
status: active
source_skill: 900-shipglows-core
scope: design-system-token-contract
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/technical/design-system-authority.md
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/references/decision-quality-contract.md
  - tools/design_system_drift_check.py
  - tools/test_industrial_excellence_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.1.0"
    required_status: active
supersedes: []
evidence:
  - "User directive 2026-06-11: agents must not customize application design outside the centralized design-system tokens for spacing, typography, colors, shadows, and related visual decisions."
  - "Current platform standards favor centralized tokens and themes: Material Design 3 design tokens, Flutter ThemeData, Tailwind v4 CSS theme variables, WCAG 2.2 target size, and adaptive mobile layout guidance."
  - "Operator directive 2026-08-13: public sites should reach award-caliber craft while every interface remains coherent, accessible, performant, and production-ready."
  - "Operator directive 2026-08-21: essential homepage content must remain visible when JavaScript or animation fails."
  - "Operator directive 2026-08-21: prefer semantic HTML and native CSS for presentation, and require a concrete functional reason before adding JavaScript."
  - "Recovery verification 2026-08-23: content-availability, CSS-first, metadata, dependency, skill, topology, and runtime-sync checks passed on the current main baseline."
  - "Operator decision 2026-08-24: Phosphor is the default functional icon family, Unicon is a source-constrained web tool, and Simple Icons is reserved for brand marks."
next_review: "2026-09-12"
next_step: "Apply the gate to the next public or product-critical interface change."
---

# Design-System Token Contract

## Purpose

Make design-system centralization a blocking execution contract, not a preference.

Use this reference before UI, UX, mobile, component, layout, theme, typography, spacing, color, shadow/elevation, motion, safe-area, keyboard/IME, overlay, or responsive implementation, fix, audit, or verification work.

## Core Rule

Every visual decision must resolve through the project's declared design-system authority. The default declaration location is `shipglows_data/technical/design-system-authority.md`; monorepos keep that declaration at the monorepo governance root, with scoped app entries only when needed.

Do not introduce or change raw one-off values in screens, components, route files, or local styles for:

- colors and opacity
- typography families, sizes, line heights, weights, and letter spacing
- spacing, gaps, dimensions, insets, safe-area offsets, and keyboard/IME offsets
- radii, borders, shadows, elevation, z-index layers, overlays, and scrims
- motion durations, easings, animation distances, and transition behavior
- breakpoints, density, touch target sizes, and responsive/adaptive layout constants

The allowed path is:

1. identify the canonical token/theme/component/layout source
2. add or update a named semantic token/constant there only when needed
3. consume that token through components, variants, utilities, or theme APIs
4. prove no unintended visual drift with token checks and visual evidence

## Award-Caliber Craft Gate

Public brand and marketing surfaces use a SOTD/Awwwards-level benchmark for craft: distinctive art direction, intentional composition, strong typographic hierarchy, coherent spatial rhythm, refined responsive behavior, meaningful motion, original detail, and whole-page narrative. This is a quality benchmark, not a promise of an award and never permission to imitate a reference. A template-like, generic, visually noisy, internally inconsistent, or visibly unfinished result is `partial` even when every section renders.

For operational and government-service interfaces, remain clarity-first: information architecture, task completion, error prevention, accessibility, trust, and speed outrank spectacle. They still require deliberate hierarchy, excellent typography, coherent density, polished states, and a distinctive but restrained system; clarity-first never means generic or amateur.

Visual ambition must not weaken accessibility, readability, conversion, performance, maintainability, semantic structure, progressive enhancement, or reduced motion. Motion and decoration earn their cost through comprehension, narrative, feedback, or brand value. Prove the result across representative widths and states with rendered evidence; source correctness alone cannot establish award-caliber craft.

## Content Availability And Progressive Enhancement Gate

Essential content and primary actions must be present, readable, and usable in
the initial semantic document. JavaScript, observers, hydration, transitions,
and animation engines may enhance their presentation, but must never be the
only mechanism that reveals or unlocks them.

Use semantic HTML and native CSS by default for content structure, layout,
responsive adaptation, visual states, themes, transitions, and decorative
motion. Add JavaScript only when the required outcome genuinely depends on
application state, data, complex interaction, coordination, or runtime
measurement that HTML and CSS cannot express robustly. Framework convenience,
visual novelty, or an animation library's availability is not sufficient
justification.

When JavaScript is justified, keep the semantic HTML/CSS baseline independently
usable, minimize the client-owned behavior, and document the functional reason
in the implementation contract or review evidence.

For public and product-critical pages, fail the design preflight when content
starts hidden and depends on successful client initialization without a proven
fallback. Proof must cover disabled or failed JavaScript/animation
initialization where applicable, plus `prefers-reduced-motion`; a build or
source-only review is insufficient for a visibility claim.

## Canonical Sources

Treat the existing project declaration as authoritative. If it is missing, infer only enough to propose the declaration before editing UI:

- Web CSS: CSS custom properties in the central token/theme/global style layer.
- Tailwind: theme variables/config tokens; for Tailwind v4 prefer `@theme` CSS variables and `var(--...)` runtime access.
- React/Vue/Svelte/Astro components: consume tokens through CSS variables, variant systems, or typed theme objects, not local literals.
- Flutter: `ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`, shared `EdgeInsets`/radius/duration/curve/constants, and component themes.
- React Native/Expo: shared theme/tokens object plus typed component variants; avoid inline literal style drift.
- Native mobile: platform theme resources/tokens and adaptive layout APIs, not per-screen numeric drift.

If multiple sources exist, stop or ask one targeted question to choose the canonical source before writing design values. Record the decision in the project design-system authority artifact, not only in the final report.

## Shared Iconography Canon

Use Phosphor as the default functional icon family for new ShipGlows app and
web work. Use its Regular weight by default. Fill may communicate selected or
active state when the state also remains understandable without icon style
alone; do not mix weights decoratively or combine unrelated functional icon
families on one surface.

Use Simple Icons only for third-party brand marks, subject to the brand's
trademark rules and accessible-name requirements. Unicon is an optional web
discovery and export tool, not an icon family or visual authority: constrain
its source to Phosphor for functional icons and to Simple Icons for brand
marks.

A project may choose another coherent family, a custom SVG, or a
platform-native icon only when its project-local design-system authority names
the functional, platform, accessibility, or brand reason. Keep that exception
bounded and preserve one dominant iconography language per surface. Do not
retrofit existing projects solely to satisfy this default; adopt it during new
work or an already-authorized design-system migration.

## Cross-Surface Identity Gate

Multiple applications do not share a design system merely because each one uses variables, themes, or similarly named design tokens. A cross-platform or app/site parity claim requires one of these architectures:

- one canonical semantic source consumed directly by every surface
- generated platform outputs whose mappings and generation path resolve back to one canonical semantic source
- documented platform adaptations that preserve the same semantic roles while naming every intentional value or behavior difference

Audit resolved values and rendered roles, not only source syntax. Compare at least color roles and states, typography, spacing and density, radius, shadow/elevation, motion, focus treatment, and light/dark/high-contrast modes. Parallel hand-maintained token files with no proven mapping are competing authorities, even when their names match.

## Behavior And Visual Ownership Gate

For dialogs, menus, tabs, comboboxes, listboxes, trees, grids, toolbars, and other complex controls, separate two responsibilities:

- native, platform, or maintained headless primitives own semantics, focus, keyboard interaction, and state behavior
- project wrappers own visual composition, variants, and canonical design-token consumption

Do not copy a vendor component implementation into product code as a substitute for a maintained dependency. That creates an accessibility and upgrade fork. A styled component suite is acceptable only when its theme layer can consume the canonical semantic authority without persistent local overrides or visual drift. Otherwise, plan an incremental wrapper-based migration while preserving behavior.

Migration proof must cover Tab and Shift+Tab order, pattern-specific arrows and Home/End, Escape, focus restoration, accessible names and states, visible focus in every supported theme, and application shortcuts that do not fire while the user is editing text unless explicitly intended.

## Mobile And App Design Rules

Mobile app UI must preserve professional app standards:

- adaptive layouts use platform or design-system breakpoints/window classes, not arbitrary viewport checks
- safe area, keyboard, navigation-bar, and IME behavior use platform measurement APIs or named shared constants
- touch targets meet WCAG 2.2 AA minimums and platform recommendations; primary mobile targets should generally be at least 44px/44dp unless the platform pattern justifies otherwise
- dense operational apps still use tokenized density scales instead of screen-local compression
- dark mode, high contrast, reduced motion, and dynamic type/text scaling must be preserved where the project supports them

## Literal Exception Policy

A raw visual literal is allowed only when all of these are true:

- it is required by a platform/API/protocol contract or by a project-standard primitive pattern
- it is named as a shared constant/token if it will be reused
- its scope is local and documented if it truly cannot become a shared token
- validation proves it does not create design-system drift

Unexplained literals are defects. Verification must fail or report partial when a UI change ships by adding hardcoded values outside the source of truth.

## Required Scans

For changed UI/design files, run:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --changed --format markdown
```

For audits or migration planning, run a broader scan:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/design_system_drift_check.py" --format markdown --warn-only
```

The scan is evidence, not the only truth. If it reports acceptable platform-bound literals, the report must name the exception reason and proof.

## Stop Conditions

Stop, reroute, or report `partial`/`not verified` when:

- no design-system source of truth can be identified for a visual change
- the project has UI but no `design_system_authority` declaration and the task would change visual implementation
- the change introduces raw visual values outside that source of truth
- token edits are made but consuming pages/components are not migrated or the gap is hidden
- a component exposes `className`, `style`, inline style maps, or variant props that allow callers to bypass tokens without guardrails
- visual proof or token drift proof is missing for a claimed UI/design completion
- accessibility, reduced motion, dynamic type, contrast, focus, or target-size safety would be weakened to satisfy token discipline
- a cross-surface parity claim relies on parallel token files without a canonical mapping or resolved-value comparison
- a component-library migration replaces mature interaction behavior with copied or bespoke controls without keyboard, focus, and semantics proof
- functional icons mix unrelated families without a documented project exception
- Unicon output is accepted without constraining and recording its source family
