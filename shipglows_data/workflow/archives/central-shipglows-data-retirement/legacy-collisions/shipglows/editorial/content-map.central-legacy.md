---
artifact: content_map
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows_data"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sg-docs
scope: content-map
owner: "unknown"
confidence: medium
risk_level: low
content_surfaces:
  - project_registry
  - global_planning
  - audit_history
  - migration_records
  - cross_project_guidelines
  - project_task_snapshots
security_impact: none
docs_impact: yes
evidence:
  - "shipglows_data/PROJECTS.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
  - "shipglows_data/migrations/shipglows_data_metadata_inventory.md"
  - "shipglows_data/autre/AI_GUIDELINES.md"
  - "shipglows_data/autre/UX_GUIDELINES.md"
  - "shipglows_data/autre/GAMIFICATION.md"
linked_artifacts: []
depends_on:
  - artifact: "PRODUCT.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "GTM.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
next_review: "2026-05-26"
next_step: "/sg-repurpose"
---

# Content Map

## Purpose

`CONTENT_MAP.md` defines where operational content lives inside `shipglows_data` and how repurposing should happen without rediscovering file roles.

## Content Surfaces

| Surface | Canonical path | Purpose | Format | Source of truth | Update when |
|---|---|---|---|---|---|
| Project registry | `shipglows_data/PROJECTS.md` | Maintain active project list, paths, and stack summary | Markdown table | `PROJECTS.md` | New/migrated project or stack change |
| Global planning | `shipglows_data/TASKS.md` | Master tracker and dashboard for execution | Markdown table | `TASKS.md` | Task status changes, prioritization shifts |
| Audit history | `shipglows_data/AUDIT_LOG.md` | Historical quality and scope audit outcomes | Markdown table | `AUDIT_LOG.md` | New audit result recorded |
| Migration notes | `shipglows_data/migrations/*.md` | Track doc migration boundaries and evidence | Markdown notes | `migrations/` directory | New migration pass or inventory update |
| Cross-project guidance | `shipglows_data/autre/*.md` | Shared guidelines, studies, and recurring references | Markdown notes | `autre/` | New reusable guidance is added |
| Context routes | `shipglows_data/CONTEXT*.md` | Onboarding, functional map, and artifact boundaries | Markdown | `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `AGENT.md` | Scope or routing rules change |
| Project task snapshots | `shipglows_data/projects/*/TASKS.md` | Per-project execution details and findings | Markdown table | Project snapshot files | Project backlog changes materially |

## Semantic Architecture

| Cluster | Surface | Supporting paths | Target intent | Link rule | Status |
|---|---|---|---|---|---|
| Project orchestration | `PROJECTS.md` | `TASKS.md` | Keep portfolio and ownership clear | `PROJECTS.md` should match project paths in project snapshots | live |
| Execution quality | `AUDIT_LOG.md` | `TASKS.md` + project snapshots | Connect audit outcomes to action | Audit rows must be traceable to backlog actions | live |
| Migration governance | `migrations/shipglows_data_metadata_inventory.md` | `PROJECTS.md` | Preserve frontmatter migration boundaries | Inventory must reflect in-scope vs deferred artifacts | live |

## Repurposing Rules

- Operational updates go first to the corresponding canonical surface; do not duplicate planning context in unrelated files.
- Use project task snapshots for project-level status, and `TASKS.md` only for shared governance.
- Keep guidelines and migration evidence in their owning files; reference them from `AGENT.md` or `CONTEXT.md`.
- Repurposed outputs should preserve file-role boundaries: registry, planning, audit, migration.

## Cross-Surface Update Rules

| Trigger | Update these surfaces |
|---|---|
| New project | `PROJECTS.md` + `AGENT.md` routing check + `CONTEXT.md` |
| Priority change | `TASKS.md` + relevant `projects/*/TASKS.md` when needed |
| New audit run | `AUDIT_LOG.md` + `TASKS.md` |
| Migration expansion | `migrations/` + this `CONTENT_MAP.md` + linked context files |
| New reusable guidance | `autre/` + root context map references |

## Open Gaps

- No dedicated public docs or website for `shipglows_data`; all content is internal operations.
- Historical files (`autre/tasks.md`, `autre/tools.md`) remain unclassified and need migration decisions in next pass.
