---
artifact: gtm_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows_data"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sg-docs
scope: gtm
owner: "unknown"
confidence: medium
risk_level: medium
target_segment: "operators coordinating multiple technical projects through ShipGlows, including solo founders and small technical teams"
offer: "a centralized project portfolio operations layer that keeps planning, audits, and project registry synchronized across repos"
channels: "developer documentation, AGENT/CODE guidance, operational audits, and agent onboarding workflows"
proof_points: "CONTEXT.md and CONTEXT-FUNCTION-TREE.md define boundaries; AGENT.md defines required read order; TASKS.md is the global planning source; AUDIT_LOG.md stores historical outcomes"
security_impact: none
docs_impact: yes
evidence:
  - "shipglows_data/AGENT.md"
  - "shipglows_data/CONTEXT.md"
  - "shipglows_data/CONTEXT-FUNCTION-TREE.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
linked_artifacts:
  - "AGENT.md"
  - "CONTEXT.md"
depends_on:
  - artifact: "CONTEXT.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
next_review: "2026-05-26"
next_step: "/sg-docs audit GTM.md"
---

# GTM Context

## Target Segment

- Portfolio operators who need to coordinate work across 10+ ShipGlows projects.
- Agent workflows that depend on consistent project-level onboarding and artifact routing.

## Offer

- Reduce context-switch cost with a central operational index and standardized entry sequence.
- Provide durable artifacts and trackers that persist beyond individual agent sessions.

## Positioning

- Not a product marketing homepage for external audiences; internal execution infrastructure for project operators.
- Positioned as a lightweight control plane for planning and quality visibility, not source code orchestration.

## Channels

- `AGENT.md` and `CONTEXT*.md` for direct operator onboarding.
- Task execution surfaces (`TASKS.md`, project task files, audit log) for practical usage.
- `sg-*` skills that depend on consolidated project state (audit, docs, and readiness flows).

## Conversion Path

- Discover `shipglows_data` via workspace onboarding.
- Use it as entrypoint for cross-project edits.
- Feed project updates into `TASKS.md` and track outcomes in `AUDIT_LOG.md`.

## Proof Points

- Centralized registry (`PROJECTS.md`) prevents repository role confusion.
- Audits become actionable through global-to-project task synchronization.
- Metadata migration inventory exists and captures pass boundaries.

## Objections

- "Why not keep each project file separate?" -> this repo already defines shared truth for coordination.
- "Is this another source of truth duplication?" -> only cross-project planning and governance live here, while each repo owns implementation details.
- "Can agents work safely without these docs?" -> they can, but at higher cost and with higher handoff risk.

## KPIs

- Reduction in context discovery time between context handoffs.
- Timeliness of updates in `PROJECTS.md`, `TASKS.md`, and `AUDIT_LOG.md`.
- Decreasing number of unclassified markdown artifacts in future migration passes.

## Evidence Limits

- This context is operational and internal; commercial assumptions are not validated for external sales channels.
