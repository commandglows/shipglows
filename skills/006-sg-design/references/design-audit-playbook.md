---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-05"
status: active
source_skill: 006-sg-design
scope: design-audit
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-token-audit-playbook.md
  - skills/006-sg-design/references/component-system-audit-playbook.md
  - skills/006-sg-design/references/accessibility-audit-playbook.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes:
  - skills/502-sg-audit-design/SKILL.md
  - skills/502-sg-audit-design/references/audit-gates.md
  - skills/502-sg-audit-design/references/audit-checklists.md
evidence:
  - "Migrated and revalidated from 502-sg-audit-design on 2026-07-15."
  - "Operator-reported landing-page coherence failures on 2026-08-05: equivalent sections changed alignment, icon scale, and card grammar without a semantic reason."
next_step: "/103-sg-verify design audit"
---

# UI/UX Design Audit Playbook

## Activation And Modes

Use for `006-sg-design audit ui [scope]`.

- no scope: full project audit
- file/route scope: page audit including imported layout, components, and relevant styles
- `deep`: UI audit plus explicit `audit tokens`, `audit components`, and `audit a11y` companion missions
- `global`: selected-project audits followed by a cross-project synthesis

The audit is read-only for product source. Operational tracking writes are allowed only through the shared traffic-first record contract after re-reading the target; otherwise report findings without mutating trackers.

## Evidence And Confidence

Read the project design-system authority, branding/product/guidelines contracts when present, representative pages/components, and current public/documentation claims. If brand or product context is absent, stale, or low-confidence, continue but cap brand-coherence confidence and name the proof gap.

Use strict evidence-backed grades:

- `A`: production-grade, coherent, and proven
- `B`: solid with notable bounded gaps
- `C`: significant repeated issues with user impact
- `D`: critical failure, exclusion, misleading state, or unsafe UX

Every priority finding includes severity, `file:line` or exact surface, observed evidence, why it matters, and a bounded owner route. Do not soften accessibility, trust, or public-claim failures to keep the report short.

## Core Domains

Score the domains that apply:

1. visual hierarchy and layout
2. typography and typographic design tokens
3. color, contrast, semantic palette, and theme architecture
4. responsiveness, safe areas, touch ergonomics, keyboard/IME, and overlays
5. component consistency, variants, and state coverage
6. accessibility posture against WCAG 2.2
7. usability and recoverability against established interaction heuristics
8. outdated or fragile interaction patterns
9. modern platform/CSS primitives when they materially simplify the system
10. generator/AI smells such as conflicting utilities, dynamic class construction, clickable non-controls, and missing states
11. cross-page product and trust coherence
12. spacing and density design tokens
13. motion design tokens and reduced-motion behavior
14. content, documentation, screenshot, and public-claim mismatches

Treat unexplained visual literals, component-local styling bypasses, and first-paint/theme inconsistencies as design-system findings. Screenshots alone never prove accessibility.

## Mandatory Checks

### Typography, Spacing, And Motion

- one coherent naming strategy; flag mixed semantic and t-shirt scales without a bridge
- bounded modular ratios and purposeful outliers
- `clamp()` with accessible zoom behavior where fluid type is used
- token consumption rather than screen-local values
- reduced-motion coverage for non-trivial motion

### Color And Theme

- semantic intents for success, warning, danger, info, neutral, text, surfaces, borders, and overlays
- WCAG contrast findings routed to `audit a11y` for full proof
- light/dark/system persistence, first-paint correctness, discoverable selector, and server sync when auth/product contract requires it
- no `if (isDark)`-style component color forks that bypass semantic design tokens

### Responsive And Interaction Quality

- reflow and content priority at narrow widths
- stable layouts under zoom, long text, localization, and dynamic type
- platform-safe keyboard/IME and safe-area behavior
- visible focus, meaningful target size, disabled/loading/empty/error/success states
- native/headless primitives preferred when custom behavior creates accessibility or maintenance risk

### Cross-Section Coherence

For a landing, sales, or offer page, load `$SHIPGLOWS_ROOT/skills/references/landing-page-experience-coherence.md`. Apply its semantic-duplication gate before visual polish, then audit component-family grammar, whole-page harmony, exception budget, primary versus secondary placement, proof proximity, and continuous-content behavior. Keep `landing-page-copywriting-framework.md` authoritative for reader questions, section roles, sequence, repetition, and claims; this audit owns visual-system decisions and rendered proof.

## Mode Flows

### Page

Read the target, wrappers, imports, token authority, and relevant public copy. Score applicable domains and return at most five priority improvements plus material blockers.

### Project

Inventory the design system, scan representative pages, compare cross-page patterns, identify systemic drift, then rank bounded remediations by user impact and blast radius.

### Deep

After the UI pass, load the three companion playbooks and run explicit token, component, and accessibility missions. They may be parallel only when execution batches are non-overlapping and the orchestration contract permits it. Consolidate one report; overall grade is the worst material domain grade, not an average that hides a blocker.

### Global

Select applicable projects explicitly, run one bounded project audit per selection, then report shared patterns, project-specific risks, severity rollup, and top cross-project improvements. Do not infer all repositories are in scope.

## Severity And Reporting

- `critical`: exclusion, deceptive/high-risk state, product/security-adjacent misrepresentation, or systemic design-token failure with broad impact
- `high`: repeated hierarchy, responsiveness, usability, state, or consistency failure
- `medium`: bounded quality gap with lower blast radius

User mode is findings-first and concise. Agent/handoff mode may include the full score matrix. Always report scope, evidence confidence, domain grades, severe findings, top improvements, proof gaps, and chantier potential.

## Stop Conditions

Stop when no auditable scope exists, a required contract/reference is missing with no safe fallback, or deep/global missions cannot be bounded. Do not turn an audit into redesign or implementation without the correct owner and lifecycle gate.
