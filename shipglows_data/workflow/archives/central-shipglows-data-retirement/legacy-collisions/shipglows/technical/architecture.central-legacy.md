---
artifact: architecture_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows_data"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: manual
scope: "architecture"
owner: "unknown"
confidence: "medium"
risk_level: "low"
linked_systems:
  - "shipglows_data/CLAUDE.md"
  - "shipglows_data/CONTEXT.md"
  - "shipglows_data/CONTEXT-FUNCTION-TREE.md"
  - "shipglows_data/PROJECTS.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
  - "shipglows_data/autre/"
  - "/home/claude/*/CLAUDE.md"
  - "/home/claude/shipglows_data/AGENT.md"
external_dependencies:
  - "Git"
  - "ShipGlows skills and orchestration conventions"
  - "Markdown"
  - "Shell/CLI tooling used by project teams"
invariants:
  - "Global trackers remain in shipglows_data; project source artifacts stay in their respective repos."
  - "Project registry in PROJECTS.md stays synchronized with active project paths."
  - "TASKS.md is the single global backlog source in this repo."
  - "AUDIT_LOG.md is append-only history for audit outcomes."
  - "Legacy notes in autre/tasks.md and autre/tools.md should be classified before promotion."
security_impact: "none"
docs_impact: "yes"
next_review: "2026-07-26"
evidence:
  - "shipglows_data/PROJECTS.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
  - "shipglows_data/migrations/shipglows_data_metadata_inventory.md"
  - "shipglows_data/CLAUDE.md"
depends_on:
  - "/home/claude/shipglows_data/CONTEXT.md"
  - "/home/claude/shipglows_data/CONTEXT-FUNCTION-TREE.md"
supersedes: []
next_step: "/sg-docs audit ARCHITECTURE.md"
---

# Architecture Context — shipglows_data

## System Shape

`shipglows_data` is a control-plane repository layer for multi-project coordination.
It combines:

- registries (project inventory and stacks),
- execution trackers (`TASKS.md`, project `TASKS.md` copies),
- audit trail (`AUDIT_LOG.md`),
- cross-project guidance documents and migration inventories.

## Entry Points (organizational)

- `shipglows_data/PROJECTS.md`: canonical project registry map.
- `shipglows_data/TASKS.md`: global task orchestration for all projects.
- `shipglows_data/AUDIT_LOG.md`: audit evidence and trend history.
- `shipglows_data/autre/*` and `shipglows_data/migrations/*`: shared standards and migration context.

## Boundaries and State

- Scope boundary:
  - Source code, build systems, and product runtimes remain in project repos.
- State boundary:
  - This repo is declarative and append-heavy; no runtime state cache.
- Control boundary:
  - Global planning decisions are made here and reflected in individual projects when needed.

## Data and Control Flow

```text
Project onboarding or execution
  -> PROJECTS.md / project CLAUDE discovery
  -> TASKS.md status updates
  -> project-specific TASKS.md sync as needed
  -> AUDIT_LOG.md append on review completion
  -> CONTEXT docs updated when governance shape changes
```

## External/Adjacent Systems

- ShipGlows orchestration (`shipglows` CLI and skills) reads task/audit intent and project registry context from this repo.
- Project-level repos provide details when specific domain changes are needed.
- Human operators and AI agents are the active consumers of this data layer.

## Hotspots

- `PROJECTS.md`: path and stack registry accuracy.
- `TASKS.md`: global status semantics and synchronization consistency.
- `AUDIT_LOG.md`: long-horizon traceability integrity.
- `migrations/shipglows_data_metadata_inventory.md`: determines metadata migration scope and risk.

## Known Constraints

- It is easy to over-migrate legacy docs; only promote docs with explicit contract value.
- Tooling assumptions (project naming and paths) can rot silently; stale entries should be corrected promptly.
- This repo should avoid becoming a source of conflicting product truth; product contracts remain in project repos.

## Maintenance Rule

Update this architecture when:

- new canonical artifact categories are introduced in `shipglows_data`,
- project tracking model changes,
- registry/audit synchronization rules are redefined,
- migration policy is materially changed.
