---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-15"
status: active
source_skill: 006-sg-design
scope: design-token-migration-playbook
owner: unknown
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - tools/design_system_drift_check.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "2026-07-15 consolidation rewrote token-migration handoffs to use canonical 006-sg-design modes."
next_review: "2026-08-15"
next_step: "/104-sg-end consolidate design skill surface into modes and playbooks"
---

# Design Token Migration Playbook

## Purpose

Define the token centralization and migration doctrine used by `006-sg-design`.

Use this reference before token centralization, design-system creation, token migration, or any handoff that distinguishes token creation from UI consumption.

## Token Implementation Handoff

Do not treat token centralization as complete site implementation.

Always distinguish three stages:

1. Token source created or updated.
2. Pages, layouts, and components migrated to consume the token source.
3. Visual non-regression or intended visual change verified with checks and browser proof.

If a run creates tokens or a playground but migration coverage is incomplete, route the next real work explicitly:

```text
/006-sg-design "Migrer le site pour consommer les tokens design centralises sans changement visuel volontaire"
```

Internal lifecycle for that follow-up:

```text
006-sg-design audit tokens
-> 100-sg-spec
-> 101-sg-ready
-> 102-sg-start
-> 105-sg-check
-> 006-sg-design audit tokens
-> 108-sg-browser
-> 103-sg-verify
-> 104-sg-end
-> 005-sg-ship
```

If the user only asks for the exact implementation command, recommend:

```text
/001-sg-build "Actualiser le site pour utiliser les variables design centralisees dans toutes les pages, sans changement visuel volontaire"
```

## Visual Shortcut Ban

Before any design implementation, apply `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` and `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`.

For IME, keyboard, overlay, responsive, spacing, typography, color, motion, target-size, or layout defects, do not accept a one-off hardcoded visual value as the default repair. Route the work to the source of truth: design tokens, theme constants, component primitives, layout utilities, platform inset/measurement APIs, or documented framework behavior.

If a literal value is unavoidable because the platform/API contract requires it, it must be named, scoped, explained, and proven. Otherwise route to `006-sg-design system`, `audit tokens`, `audit components`, `audit a11y`, or spec-first implementation instead of shipping drift.

Any implementation handoff must name the canonical token/theme source for spacing, typography, colors, shadows/elevation, motion, and mobile/adaptive constants. If no source exists, route to `006-sg-design system` before changing product UI.

## Migration Proof

A token migration report must distinguish:

- token source status: `created`, `updated`, `unchanged`, or `missing`
- consumption status: `complete`, `partial`, `not started`, or `not applicable`
- drift scan status: `pass`, `warnings explained`, `fail`, or `not run`
- visual proof status: `browser proof collected`, `not required`, or `missing`

If token edits are made but consuming pages/components are not migrated, report `partial` and name the next owner route instead of claiming design-system completion.
