---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-12"
status: active
source_skill: 006-sg-design
scope: component-system-audit
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/accessibility-audit-playbook.md
  - skills/references/design-system-token-contract.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes:
  - skills/504-sg-audit-components/SKILL.md
  - skills/504-sg-audit-components/references/component-audit-workflow.md
evidence:
  - "Migrated and revalidated from 504-sg-audit-components on 2026-07-15."
  - "Operator-reported testimonial rail regression on 2026-08-05: a horizontal component described as cyclic reached a blank tail instead of looping continuously."
next_step: "/103-sg-verify component-system audit"
---

# Component-System Audit Playbook

## Activation And Pre-Check

Use for `sg-design audit components [scope]`.

- no scope: full project component-system audit
- file path: deep audit of one component/widget
- `global`: explicit selected-project audit and synthesis

Gather project conventions, component/widget directories and counts, a sorted sample, variant/headless-library signals, token/theme consumers, custom interactive primitives, and Flutter semantics/focus signals. If no components exist, stop and report that there is no auditable component system.

The audit is read-only for source. Operational records may be written only through the active lifecycle’s tracker contract after a fresh re-read.

## Project Audit — Nine Phases

### 1. Component Inventory

Classify atoms/primitives, molecules, organisms, templates/layouts, pages, and `UNCLASSIFIED`. Report counts and representative files. Flag an inverted hierarchy, missing primitive layer when controls are repeatedly reinvented, and more than 20% unclassified components.

Use the project’s own architecture vocabulary when it is clearer than Atomic Design; the purpose is boundary quality, not forcing labels.

### 2. Duplication

Find candidates through naming, structure, props, imports, and copy-paste markers. Apply Rule of Three and AHA: prefer duplication over a wrong abstraction when behavior or evolution differs materially.

### 3. God Components

For web, flag strong signals such as more than 15 props, more than 300 lines, mixed business/presentation concerns, or unrelated state/effects. For Flutter, treat build methods over 200 lines or constructors over 10 parameters as strong signals. Thresholds prompt inspection; they are not proof by themselves.

### 4. Unused Components

Trace imports through barrel exports, routes, lazy loading, stories, and tests. Story/test-only use is not production consumption unless the component also serves product code. Avoid deleting by name scan alone.

### 5. Abstraction Quality

Flag boolean-flag farms, generic “Flexible/Super/Universal” wrappers, leaky passthrough, and configuration-object sprawl. Recommend un-abstraction, compound components, headless behavior plus styled shells, or domain wrappers only when evidence supports the boundary.

### 6. Variant System

When Tailwind and more than 20 components are present, assess whether CVA/tailwind-variants or an established equivalent would reduce repeated variant logic. When a variant system exists, check defaults, compound variants, exhaustive states, and semantic design-token consumption.

For Flutter, use `ButtonStyle`, component themes, `ThemeData`, and typed variant/state data. Flag raw colors, spacing, typography, elevation, motion, breakpoints, safe-area, keyboard, or overlay values inside variants.

### 7. Interactive Primitives

For custom comboboxes, dialogs, menus, tabs, toolbars, sliders, listboxes, trees, and disclosures, assess whether native, headless, or platform primitives should replace bespoke focus/keyboard/ARIA behavior. Respect dependency policy. Route full conformance proof to `006-sg-design audit a11y`.

For a carousel, marquee, testimonial rail, or repeated-card track described as cyclic, infinite, seamless, or continuously looping, require behavior proof rather than accepting duplicated markup or an animation declaration as evidence. The proof must show no reachable blank interval, dead tail, visible seam, or reset jump during manual interaction and autoplay when applicable; cover supported responsive widths, resize, remount or route return, reduced-motion behavior, and dynamic or localized content. Route keyboard, announcement, pause/control, and focus proof to `audit a11y`, and timing, cleanup, lifecycle, and performance proof to the animation playbook. A finite rail is valid only when its terminal state is explicit and reachable content is not presented as an infinite loop.

Record behavior ownership separately from visual ownership. Mature native/platform/headless primitives should normally own semantics, focus, keyboard, and state behavior; project wrappers should own composition, variants, and canonical design-token consumption. A component suite is not disqualified because it is a dependency, but it is a poor fit when its visual architecture requires persistent overrides or a parallel token authority.

Never recommend copying vendor component internals into the project to remove a dependency. Treat that as a maintained accessibility and upgrade fork. For migrations, inventory each complex primitive, its current behavior owner, proposed replacement, wrapper boundary, required keyboard contract, and proof status. Prefer incremental replacement behind project-owned wrappers over a broad rewrite.

Pressure scenario `COMPONENT-CYCLIC-CONTINUITY`: given a horizontal testimonial or card rail claimed to loop continuously, reaching blank space, a dead tail, a visible seam, or a reset jump fails the component audit even when the track contains duplicated items or CSS/JavaScript declares an infinite animation. Accept the behavior only after manual/autoplay, responsive resize, remount, reduced-motion, and content-variation proof succeeds or the component is explicitly reframed as finite.

### 8. Composition Versus Configuration

Flag APIs that model layout parts through excessive props when children, slots, snippets, compound components, or Flutter widget composition would be clearer. Prefer the idiom native to the project framework.

### 9. API Hygiene

Audit naming, boolean/enum semantics, required/optional/default props, TypeScript or Dart strictness, refs/keys, event contracts, state coverage, and styling passthrough.

`className`, `style`, arbitrary value props, inline style maps, and Flutter style parameters are acceptable only with documented guardrails. Flag any channel that lets callers bypass centralized visual decisions.

## Cross-Platform Checks

For Flutter, additionally inspect `const` constructors, named `required` parameters, key forwarding, widget duplication, `Semantics`, `Focus`, `Shortcuts`, `Actions`, and inline `EdgeInsets`, `TextStyle`, `BoxDecoration`, `Color`, `Duration`, `Curve`, or `SizedBox` values that bypass shared authority.

For web, account for framework conventions in React, Vue, Svelte, Astro, and other detected stacks. Do not recommend React-specific patterns as universal architecture.

## File And Global Modes

File mode applies phases 3, 5, 8, and 9 plus relevant token/accessibility checks. State explicitly that inventory, duplication, unused, variant adoption, and ecosystem conclusions need cross-file evidence.

Global mode selects projects explicitly, runs one bounded project audit per selection, and reports both comparable grades and platform-specific differences.

## Severity And Report

Use `A/B/C/D` phase scores. Severity follows blast radius:

| Component count | Default priority for systemic findings |
| --- | --- |
| fewer than 10 | medium unless user impact, trust, accessibility, or reuse is directly harmed |
| 10-30 | high |
| more than 30 | critical |

Report inventory counts, duplication/god/unused/abstraction findings, variant and headless status, composition/API findings, phase scores, overall grade, critical/high issues, priority improvements, proof gaps, and chantier potential. An A grade means production-grade architecture, not “it works.”

When library replacement is in scope, also report whether the proposal preserves behavior ownership, restores project visual ownership, avoids a vendor-code fork, and has component-by-component keyboard proof.

## Stop Conditions

Stop when no components exist, a file target is missing or not a component, project selection is ambiguous, or a tracker write would require reconstruction from stale state. Never refactor product code from audit mode.
