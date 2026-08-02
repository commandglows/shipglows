---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: active
source_skill: 006-sg-design
scope: design-token-audit
owner: Diane
confidence: high
risk_level: medium
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
    artifact_version: "1.0.0"
    required_status: active
supersedes:
  - skills/503-sg-audit-design-tokens/SKILL.md
  - skills/503-sg-audit-design-tokens/references/deep-audit-playbook.md
evidence:
  - "Migrated and revalidated from 503-sg-audit-design-tokens on 2026-07-15."
next_step: "/103-sg-verify design token audit"
---

# Design-Token Audit Playbook

## Activation And Pre-Check

Use for `006-sg-design audit tokens [scope]`.

- no scope: full project audit
- file path: audit the named token/theme source
- `global`: selected-project audit and cross-project synthesis

Confirm that a real design-token authority exists and is consumed by production UI. If none exists, stop and route to `006-sg-design system`. If multiple sources compete, report split-brain authority as a high-priority finding before scoring downstream quality.

This audit is read-only for product source. Use the term **design tokens** throughout; never shorten it to “tokens” where that could be confused with credentials or model units.

## Context Inventory

Detect CSS custom properties, Tailwind/theme configuration, typed theme objects, Flutter `ThemeData`/`ColorScheme`/`TextTheme`/extensions, DTCG JSON, theme modes, component consumers, design-system drift, and relevant token-file history.

Run the broad drift scan in warn-only mode. Its findings are evidence, not automatic conclusions; justify platform-bound literals and flag all unexplained visual bypasses.

## Project Audit — Seven Phases

### 1. Four-System Inventory

Report source, format, count, naming, and consumer coverage for:

- color palette: semantic core, surfaces, text/border/overlay, domain intents, component hue names
- typography: family roles, size/line-height/letter-spacing bundles, naming, fluid scale, literal count
- spacing: base unit, scale, naming, density/adaptive values, literal count
- motion: durations, easings, reduced-motion handling, literal transition/animation count

Include radius and shadow/elevation in the closest applicable system and explicitly state when the project uses them without design tokens.

### 2. Coverage Matrix

Verify every semantic color/surface/state design token across declared light, dark, system, high-contrast, and custom modes. Missing mode values are high severity because they fail silently. Check component states and platform/adaptive roles, not only base colors.

### 3. Modular Ratio Analysis

Extract numeric typography and spacing values, calculate adjacent ratios, and classify each scale as `coherent`, `inconsistent`, or `chaotic`. Distinguish purposeful semantic outliers from accidental drift. When regeneration is warranted, state base, ratio, and viewport assumptions rather than recommending a tool name alone.

### 4. Dependency Graph

Trace primitive-to-semantic-to-component aliases and report:

- orphan design tokens
- alias cycles
- chains deeper than three levels without clear value
- duplicate intents resolving to the same value without an intentional alias
- component consumers bound to a non-canonical source
- passthrough APIs that let callers bypass the authority

### 5. Historical Drift

Use bounded git history on the authority to identify recent ad-hoc additions, repeated fix churn, author dispersion without stewardship, and repeated renames/moves. Report a short relevant timeline; do not equate frequent legitimate evolution with poor quality without evidence.

### 6. DTCG Compliance

When DTCG JSON exists, verify `$value`, `$type`, useful `$description`, alias syntax, semantic grouping, and mode/extensions structure. Mark `N/A` when the project does not claim or need DTCG; absence alone is not a defect.

### 7. Theme Architecture

Verify declared modes, fallback normalization, preference persistence, first-render/FOUC prevention, system preference when no override exists, selector discoverability, server sync when authentication/product contract requires it, and the absence of component-local theme forks.

Include reduced motion, safe area, keyboard/IME, touch target, adaptive breakpoint, density, and elevation constants for mobile/app projects. Map vocabulary to the platform without lowering the audit bar.

## File And Global Modes

File mode runs inventory, ratio analysis, DTCG when applicable, and bounded history for the target. It must state that project-wide coverage, dependency, and theme-architecture conclusions were not proven.

Global mode explicitly selects projects, runs the complete project audit for each, and reports comparable grades plus shared systemic patterns. Do not infer workspace-wide authority from one project.

## Severity And Score

Each phase receives `A/B/C/D` or `N/A`, with overall grade equal to the worst material failure when a blocker would otherwise be averaged away.

Adapt priority to blast radius:

| Project size | Default priority for systemic drift |
| --- | --- |
| fewer than 10 component files | medium unless user trust or accessibility is harmed |
| 10-30 component files | high |
| more than 30 component files | critical |

## Report Contract

Report the four-system inventory, phase scores, overall grade, critical/high findings, priority improvements, canonical authority, production-consumption status, drift scan status, and chantier potential. If the authority exists but pages/components bypass it, route the consumption migration explicitly; do not present playground creation or source centralization as completed implementation.

Operational tracking writes, when owned by the active lifecycle, must use the traffic-first grammar after a fresh re-read. Never rewrite trackers or product source during the audit.

## Stop Conditions

Stop when no authority exists, the target file is invalid, project selection is ambiguous, or a required source cannot be read safely. Be evidence-strict: an A grade means production-grade design-token architecture, not merely the presence of variables.
