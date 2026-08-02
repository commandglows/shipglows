---
artifact: product_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows_data"
created: "2026-04-26"
updated: "2026-04-26"
status: draft
source_skill: sg-docs
scope: product
owner: "unknown"
confidence: medium
risk_level: medium
target_user: "operator coordinating multiple ShipGlows projects and agents from one portfolio workspace"
user_problem: "cross-project context drifts when execution is distributed across repositories; operational visibility depends on manual lookup across scattered task and audit files"
desired_outcomes: "a single operational data plane for project intake, planning, status tracking, and audit history with predictable entry points for agents and maintainers"
non_goals: "shipping application code, replacing project codebases, serving as the canonical repo for source code, or owning customer-facing marketing channels"
security_impact: none
docs_impact: yes
evidence:
  - "shipglows_data/CLAUDE.md"
  - "shipglows_data/CONTEXT.md"
  - "shipglows_data/PROJECTS.md"
  - "shipglows_data/TASKS.md"
  - "shipglows_data/AUDIT_LOG.md"
  - "shipglows_data/migrations/shipglows_data_metadata_inventory.md"
linked_artifacts: []
depends_on:
  - artifact: "migrations/shipglows_data_metadata_inventory.md"
    artifact_version: "0.1.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-05-26"
next_step: "/sg-docs audit PRODUCT.md"
---

# Product Context

## Target User

- Portfolio operators and builders managing multiple ShipGlows-enabled repositories.
- Agents and maintainers who need immediate orientation before making cross-project updates.

## Problem

- Each project generates its own `TASKS.md`, while governance is tracked in a single shared layer.
- Without explicit contracts, this shared layer loses clarity during migration, prioritization, and handoff.
- Audit, planning, and project registry updates can become fragmented without a central operating map.

## Desired Outcomes

- Keep project registry, master tasks, and audit history in one authoritative workspace.
- Make onboarding inside `/home/claude/shipglows_data` deterministic (`AGENT.md` then `CONTEXT.md`).
- Preserve durable cross-project decisions through metadata-ready artifacts and migration inventories.

## Product Principles

- Preserve operational trackers as lightweight sources of truth.
- Move long-lived decisions into explicit artifacts before they become organizational knowledge debt.
- Keep migration boundaries clear between operational logs and contract artifacts.

## Core Workflows

- Intake: update `PROJECTS.md` when a project appears, changes stack, or exits.
- Plan: update `TASKS.md` as global source of prioritization and progress.
- Audit: write outcome snapshots in `AUDIT_LOG.md` and link back to actionable tasks.
- Migration: track document classification and frontier decisions in `migrations/`.

## Scope In

- Cross-project planning and portfolio coordination.
- Operational governance for artifacts that survive beyond a single project iteration.
- Shared standards and migration guidance used by multiple project repos.

## Scope Out

- Source code implementation, build pipeline orchestration inside individual project repos.
- Runtime monitoring and hosting operations (except where those repos reference shared operational truth).
- New marketing stack implementation.

## Success Signals

- Agents can begin work from one file sequence instead of searching multiple projects.
- Project and portfolio context remains consistent across audit, task, and registry files.
- Migration debt decreases as documents become explicitly classified and versioned.

## Risks

- Stale project metadata can persist if `PROJECTS.md` and individual repo paths diverge.
- Master trackers can become inaccurate when changes happen outside this workspace.
- Missing dependencies in migration artifacts can cause future automation to skip required docs.
