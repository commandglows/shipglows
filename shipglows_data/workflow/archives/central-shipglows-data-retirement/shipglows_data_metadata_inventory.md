---
artifact: migration_inventory
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows data
created: "2026-04-25"
updated: "2026-04-25"
status: draft
source_skill: manual
scope: shipglows_data_metadata_migration
owner: unknown
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
evidence:
  - "Read-only inventory of /home/claude/shipglows_data Markdown files"
depends_on: []
supersedes: []
next_step: "/sg-docs audit /home/claude/shipglows_data"
---

# ShipGlows Data Metadata Inventory

## Scope

This inventory tracks the first additive metadata migration pass for `/home/claude/shipglows_data`.

The migration target is ShipGlows work artifacts stored outside individual project repositories: business docs, brand docs, cross-project guidelines, research reports, strategy reports, decision records, and long-lived specs.

Operational trackers/registries are documented in this inventory so future agents know not to migrate them by mistake, but they are not metadata targets.

Application runtime content is out of scope.

## Git State Before Migration

`/home/claude/shipglows_data` was already dirty before this migration pass:

- `AUDIT_LOG.md`
- `PROJECTS.md`
- `TASKS.md`
- `projects/contentflowz/TASKS.md`
- `projects/gocharbon/TASKS.md`
- `projects/gocharbon_quiz/TASKS.md`
- `projects/quit-coke-app/TASKS.md`
- `projects/winflowz/TASKS.md`
- deleted: `projects/chatbot/TASKS.md`

Migration edits should stay additive and avoid normalizing these existing changes in the same pass.

## First-Pass Migrated Artifacts

| File | Artifact Type | Project | Confidence | Notes |
|---|---|---|---|---|
| `projects/gocharbon_quiz/BUSINESS.md` | `business_context` | `gocharbon_quiz` | high | Explicit business document. |
| `projects/gocharbon_quiz/BRANDING.md` | `brand_context` | `gocharbon_quiz` | high | Explicit brand document. |
| `autre/AI_GUIDELINES.md` | `technical_guidelines` | workspace | medium | Cross-project AI production doctrine. |
| `autre/UX_GUIDELINES.md` | `technical_guidelines` | workspace | medium | Cross-project UX doctrine. |
| `autre/GAMIFICATION.md` | `research_report` | workspace | medium | Multi-project research/strategy report. |

## Explicitly Deferred

| File Group | Reason |
|---|---|
| `projects/*/TASKS.md` | Operational trackers. No metadata frontmatter required. Extract durable decisions into separate artifacts when needed. |
| `TASKS.md` | Shared master operational tracker. No metadata frontmatter required. |
| `AUDIT_LOG.md` | Shared audit-history tracker. No metadata frontmatter required. |
| `PROJECTS.md` | Project registry and domain matrix. No metadata frontmatter required. |
| `autre/tasks.md` | Historical business task overview with project names that do not fully match current registry. Needs classification first. |
| `autre/tools.md` | Link dump / tool watchlist; needs classification before migration. |

## Next Migration Pass

1. Classify `autre/tasks.md` and `autre/tools.md`.
2. Extract durable decisions/specs from project `TASKS.md` files into separate versioned artifacts only when they need to become long-lived contracts.
3. Keep `TASKS.md`, `AUDIT_LOG.md`, and `PROJECTS.md` as simple operational trackers/registries without frontmatter.
