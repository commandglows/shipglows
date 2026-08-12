---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 101-sg-ready
scope: readiness-transition-and-report
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/101-sg-ready/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 extracted status transition, trace, and reporting."
next_step: none
---

# Readiness Transition and Report

## Atomic transition

For `ready`, update frontmatter status/version/date/time/next step, run history, and current flow atomically; lint metadata after mutation. For `not ready`, keep or restore `draft`/`reviewed`, name concrete corrections, and route back to spec ownership. Never mutate implementation or claim proof completion.

If the expected metadata/history location moved, re-read once and recompute; unresolved ambiguity blocks mutation. Preserve existing contract sections and verified history.

## Report

User mode shows the chantier header, readiness verdict, only blockers that change the operator's decision, and plain-language choices when unfinished. It never dumps the checklist, internal commands, paths, topology, or lifecycle mechanics.

Agent mode may include section/gate matrix, evidence, mutations, remaining risks, and exact handoff. `ready` means safe to start implementation, not implemented, verified, closed, or shipped.
