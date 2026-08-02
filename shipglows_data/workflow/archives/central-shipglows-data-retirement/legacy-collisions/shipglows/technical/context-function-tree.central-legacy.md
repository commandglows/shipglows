---
artifact: artifact_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows_data"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: manual
scope: "function-tree"
owner: "unknown"
confidence: "medium"
risk_level: "low"
security_impact: "none"
docs_impact: "yes"
evidence:
  - "shipglows_data/CLAUDE.md"
  - "shipglows_data/PROJECTS.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
  - "shipglows_data/migrations/shipglows_data_metadata_inventory.md"
depends_on:
  - "/home/claude/shipglows_data/CONTEXT.md"
supersedes: []
next_step: "/sg-docs update CONTEXT-FUNCTION-TREE.md"
---

# CONTEXT-FUNCTION-TREE.md — shipglows_data

## Runtime map for this repository

This repo is documentation-orchestrated, not an application runtime. The main functions are:

- register projects,
- synchronize portfolio planning,
- preserve audit history,
- centralize project metadata migration evidence.

## File Roles

- `shipglows_data/CLAUDE.md`
  - workspace-wide operating constraints and skill/workflow reminders
- `shipglows_data/PROJECTS.md`
  - source of truth for project registry and stack matrix
- `shipglows_data/TASKS.md`
  - global master tracker (single source of truth)
- `shipglows_data/AUDIT_LOG.md`
  - global audit history across projects
- `shipglows_data/autre/AI_GUIDELINES.md`
  - cross-project AI safety/productivity standards
- `shipglows_data/autre/UX_GUIDELINES.md`
  - cross-project UX operating standards
- `shipglows_data/autre/GAMIFICATION.md`
  - cross-project gamification research and strategy
- `shipglows_data/autre/tasks.md`
  - historical/auxiliary list requiring classification
- `shipglows_data/autre/tools.md`
  - historical tool watchlist requiring classification
- `shipglows_data/projects/<project>/TASKS.md`
  - project-level execution backlog
- `shipglows_data/migrations/*`
  - metadata migration inventories and migration notes

## Operational Functions

### `project registry maintenance`

```text
PROJECTS.md
  -> validate project names/paths/stacks
  -> align with existing project repos
  -> keep domain applicability matrix current
```

### `global planning flow`

```text
TASKS.md
  -> project selection and status updates
  -> issue creation and completion state
  -> dashboard readability maintenance
```

### `global audit flow`

```text
AUDIT_LOG.md
  -> append audit outcomes
  -> map outcomes to TASKS.md action items
```

### `project-task synchronization`

```text
projects/<project>/TASKS.md
  -> project execution updates
  -> optional upstream sync to master TASKS.md
```

### `metadata migration flow`

```text
migrations/shipglows_data_metadata_inventory.md
  -> classify files and scope
  -> record migrated artifacts
  -> keep historical context for future passes
```

## Edit Boundaries

- Global planning changes should start in `TASKS.md`.
- Project-level task updates should stay in the project’s local `TASKS.md` unless global dashboard alignment is needed.
- New cross-project contracts should update `CONTEXT.md` and the relevant context artifacts.
- Migration decisions should update `migrations/` notes before touching docs.

## Suggested Update Triggers

- stack or path changes in `PROJECTS.md`
- audit cadence changes in `TASKS.md`/`AUDIT_LOG.md`
- classification decision for `autre/tasks.md` or `autre/tools.md`
- any new durable cross-project contract added under `autre/` or `migrations/`
