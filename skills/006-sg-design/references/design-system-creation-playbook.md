---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-12"
status: active
source_skill: 006-sg-design
scope: design-system-creation
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-token-migration-playbook.md
  - skills/references/design-system-token-contract.md
  - tools/design_system_drift_check.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes:
  - skills/500-sg-design-from-scratch/SKILL.md
evidence:
  - "Migrated and revalidated from 500-sg-design-from-scratch on 2026-07-15."
next_step: "/103-sg-verify design system creation"
---

# Design-System Creation Playbook

## Activation

Use for `sg-design system [scope]`. Optional modifiers after mode selection are `tokens-only` and `with-playground`; they do not create separate public commands.

Load the decision-quality, design-system token, and token-migration contracts first. Detect the framework and styling stack, then inspect the existing global styles/theme, root layouts, representative pages, representative components, and brand contract when present.

## Scope Gate

Direct execution is allowed only for one bounded product, one credible token authority, and a bounded representative migration. Require a ready spec for mixed frameworks, multi-page or cross-component migration, public/product-critical flows, broad component rewrites, new visual direction, or unclear brand decisions.

This mode creates or completes the design-system source of truth. It does not invent a brand identity, build a component documentation product, perform a whole-app redesign, or create a parallel token source.

## Professional Completion Standard

A few variables are not a completed design system. Cover every visual domain the product actually uses:

- font roles and loading strategy
- semantic color primitives, surfaces, text, borders, overlays, and state colors
- typography size, line-height, and letter-spacing
- spacing, radius, shadow/elevation, and motion
- light, dark, system, and high-contrast behavior when supported
- component-intent aliases for recurring buttons, cards, forms, alerts, navigation, and sections
- bounded consumption by global styles, the application shell, and representative components/pages

Default coherence constraints are evidence gates, not arbitrary quotas:

| Domain | Default | Expansion rule |
| --- | --- | --- |
| Font roles/families | Prefer 1-2 families; maximum 5 roles by default | Exceed only when existing brand/product roles justify it |
| Chromatic families | Maximum 3 brand chromatic families | Neutral, surface, text, border, overlay, and semantic state families are separate support roles |
| Type sizes | Maximum 5 core size tokens by default | Add only for a distinct product role, not a one-off screen |
| Spacing | One coherent 4px, 8px, or proven existing scale | No screen-local exceptions |
| Motion | Semantic duration and easing tokens | Preserve reduced-motion behavior |

## Creation Flow

### 1. Inventory

Read only the files needed to understand the current visual system: global/reset styles, token or theme files, Tailwind config when present, root layouts, 3-8 representative pages/screens, and 5-10 representative components.

Record fonts and loading, repeated literals, color intents, typography clusters, spacing/radius/elevation/motion clusters, theme behavior, and the production consumers of each candidate authority.

### 2. Token Plan

Before editing, state:

```text
Canonical token source: [file]
Authority type: [CSS variables / Tailwind theme / typed theme / Flutter ThemeData]
Fonts and roles: [selection]
Chromatic families: [selection]
Typography base and ratio: [selection]
Fluid type: [none / headings / display+headings]
Spacing base: [4px / 8px / proven existing]
Theme modes: [selection]
Migration batch: [files]
Open decision: [only if material]
```

If several sources are credible, choose the one already consumed by production UI or ask one targeted question when the choice changes architecture. Never choose by convenience.

### 3. Build The Authority

Use the project-native source: central CSS variables, existing Tailwind theme, existing typed theme object, or Flutter `ThemeData`/`ColorScheme`/`TextTheme`/`ThemeExtension` plus shared constants.

Bundle related decisions. Typography tokens include size, line-height, and letter-spacing. Color tokens separate primitives from semantic aliases. Motion tokens include duration and easing. Component aliases map intent to the shared primitives.

### 4. Apply A Bounded Migration

Migrate global styles, the root shell, repeated primitives, and the target or 1-3 representative pages. Do not claim completion while the production UI still bypasses the authority. When the authority is complete but the application-wide consumption sweep is staged, report `consumption: partial` and route the remaining batch through a ready spec.

### 5. Audit And Handoff

Run `006-sg-design audit tokens`, the drift scan, and focused project checks. Route optionally to `playground`, `audit components`, or `audit a11y` based on evidence. The `with-playground` modifier may continue only after the authority exists and passes the pre-check.

## Typography Doctrine

Derive kept typography tokens from a coherent modular scale rather than isolated values. Start from the readable body size, choose one product-appropriate ratio (`1.125`, `1.2`, `1.25`, `1.333`, `1.414`, `1.5`, or `1.618`), and keep hierarchy bounded. Fluid headings use a real `rem` base and moderate viewport contribution so browser zoom remains effective. Treat Utopia-style base-size, ratio, and viewport math as a method, not as an external authority.

## Proof And Output

Report the canonical source, authority type, domains completed, migration coverage, remaining literal/drift findings, checks, and next route. A successful result requires:

- source authority identified and consumed
- no new unexplained visual literals
- theme and reduced-motion behavior preserved
- focused build/lint/type checks passed when available
- drift scan passed or every warning justified
- browser proof for any claimed visual non-regression or intentional visual change

## Stop And Recovery

Stop with an exact recovery route when no auditable UI exists, the stack is unsupported for safe edits, multiple authorities remain unresolved, brand direction is ambiguous, a ready spec is required, validation fails outside scope, or professional constraints need a material product decision.

Never remove brand/legal assets without confirmation, weaken contrast/focus/reduced motion, overwrite an authority without understanding its imports, or ship unrelated dirty files.
