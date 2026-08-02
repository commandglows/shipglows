---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows_data
created: "2026-04-26"
updated: "2026-04-26"
status: active
source_skill: sg-init
scope: workspace
owner: shipglows
confidence: high
depends_on:
  - artifact: CLAUDE.md
    required_status: active
  - artifact: BRANDING.md
    required_status: active
  - artifact: GUIDELINES.md
    required_status: active
evidence:
  - README.md
  - PROJECTS.md
  - TASKS.md
supersedes: []
risk_level: medium
business_model: Internal operating layer
market: Internal operations / documentation governance
target_audience: ShipGlows operators and cross-project maintenance agents
value_proposition: Centralize governance, project metadata, and execution context to reduce drift and rework.
security_impact: low
docs_impact: high
next_review: "2026-10-26"
next_step: "/sg-docs audit shipglows_data/BUSINESS.md"
---

# Business — shipglows_data

## Mission
`shipglows_data` is the single operational source of truth for ShipGlows planning and project governance. It captures project registries, master task state, and cross-project standards so decisions survive tool or repository changes.

## Problem solved
Multiple projects have different stacks, maturity levels, and timelines. Without a shared layer, onboarding, audit posture, and execution history become fragmented. This workspace consolidates:

- Product and delivery status (`TASKS.md`)
- Project inventory (`PROJECTS.md`)
- Audit history (`AUDIT_LOG.md`)
- Long-lived context and operating standards (`BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`, `README.md`)

# Value proposition
- Faster onboarding: one place to find current context before editing any project.
- Better governance: shared conventions reduce project drift.
- Clear execution memory: recurring tasks remain visible even when project repos rotate in and out of active work.

## Target users
- You (ShipGlows operator) and agents assisting with maintenance, planning, and audits.
- Future teammates that need project-level continuity.

## Product/Service model
This is an internal operating model, not a SaaS. Value is measured through:

- Faster execution from context reuse
- Lower rework from repeated setup decisions
- Better signal in cross-project audits

## Success metrics
- Master tracker and project-level tracking stay aligned.
- New project contexts are documented before shipping major code changes.
- Required environment setup for active projects is discoverable from `shipglows_data` docs.

## Current status
- 13 projects tracked in `PROJECTS.md`.
- 0 missing root operating docs before this update; this set now includes required strategy and guidance files.
