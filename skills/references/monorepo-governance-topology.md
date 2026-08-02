---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-23"
status: active
source_skill: 300-sg-docs
scope: monorepo-governance-topology
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/
  - skills/references/canonical-paths.md
  - skills/references/technical-docs-corpus.md
  - skills/references/editorial-content-corpus.md
  - skills/300-sg-docs/references/core-governance.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-06-28: monorepo governance should group by theme first, then by surface."
  - "Repeated migration drift caused by mixed site/app folders carrying business, technical, and workflow docs together."
  - "Operator decision 2026-07-23: monorepo source roots (site/, app/, backend/, packages/) are separate from governance roots (shipglows_data/), and flat source roots are the preferred canonical shape."
next_review: "2026-07-28"
next_step: "/300-sg-docs migrate-layout"
---

# Monorepo Governance Topology

## Rule

In ShipGlows monorepos, organize governance by theme first, then by surface.

Use this pattern:

- shared theme contract at the theme root when the source of truth is truly cross-surface
- surface-scoped contract under the theme when the content changes with runtime, funnel, technology, or operator proof path

## Canonical Shape

Examples:

- `shipglows_data/branding/branding.md`
- `shipglows_data/business/site/business.md`
- `shipglows_data/business/app/business.md`
- `shipglows_data/product/site/product.md`
- `shipglows_data/product/app/product.md`
- `shipglows_data/gtm/site/gtm.md`
- `shipglows_data/gtm/app/gtm.md`
- `shipglows_data/editorial/site/content-map.md`
- `shipglows_data/research/site/*`
- `shipglows_data/technical/site/*`
- `shipglows_data/technical/app/*`
- `shipglows_data/workflow/site/*`
- `shipglows_data/workflow/app/*`

## Monorepo Source Root Rule

Source roots and governance roots are separate concerns. Governance stays at the monorepo root under `shipglows_data/`. Canonical source roots may be flat at the monorepo root when the project uses the public-site + application + backend split:

- `site/`
- `app/`
- `backend/`
- `packages/`

Nested `apps/*` packaging is allowed only when the project documents a durable technical reason; it is not the default ShipGlows monorepo shape.

## Decision Rule

Keep a document shared only when changing surface should not change the contract.

Typical shared contracts:

- brand identity
- voice and trust posture
- company-level product inventory
- global commercial constraints

Typical surface-scoped contracts:

- architecture
- technical guidelines
- public content maps
- feature-level product context
- surface-specific GTM
- app/site-specific business mechanics
- workflow trackers and verification notes

## Anti-Pattern

Avoid surface-first umbrella folders that mix unrelated themes together, for example:

- `shipglows_data/site/business/...`
- `shipglows_data/site/editorial/...`
- `shipglows_data/site/research/...`
- `shipglows_data/app/...`

This shape hides the difference between shared business truth and surface-specific implementation truth.

## Migration Heuristic

When normalizing a monorepo:

1. move shared brand docs to `shipglows_data/branding/`
2. move business, product, GTM, editorial, research, technical, and workflow docs under their theme
3. create surface subfolders only where the contract differs by surface
4. delete duplicate shared-source docs after downstream references point to the canonical shared file

## Maintenance Rule

Update this reference when ShipGlows changes the canonical governance topology for monorepos.
