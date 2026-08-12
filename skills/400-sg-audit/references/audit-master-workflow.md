---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 400-sg-audit
scope: 400-sg-audit-master-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/400-sg-audit/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 16 replaced the monolith with a compatibility core and direct conditional leaves."
next_review: "2026-09-12"
next_step: "/103-sg-verify 400-sg-audit compaction"
---

# Audit Master Workflow

Compatibility core for broad audit orchestration. The activation, canonical-path, reporting, chantier, and stop contracts remain authoritative in `../SKILL.md`.

## Decision Core

1. Resolve `global`, project, or file scope and inspect project evidence before selecting domains.
2. If one domain is obvious, route directly to its owner; use this master only for cross-domain or cross-project consolidation.
3. Before multi-domain fan-out, load the shared delegation and lifecycle references named by `../SKILL.md`. Parallelism is read-only and limited to disjoint project × domain cells. Every mutation returns to sequential owner execution unless a ready spec provides write-safe batches.
4. Preserve findings-first reporting, bounded confidence, linked-system consequences, product-story coherence, documentation drift, design-system authority, and security/proof gaps. Never turn missing evidence into a passing grade.
5. Durable audit/task records require the shared operational-record contract. Fixes require explicit authorization and the relevant owner workflow; never mutate logs, trackers, code, or docs during read-only fan-out.

## Direct Conditional Routes

- Scope selection, applicability, specialist mappings, and agent prompts: load `references/audit-scope-and-routing.md` directly.
- Consolidation, severity, confidence, security/proof gates, and report fields: load `references/audit-consolidation-and-proof.md` directly.
- Operational records, task creation, and authorized remediation handoff: load `references/audit-records-and-remediation.md` directly.

Load only the branch needed for the current decision. These references are siblings: none requires or routes through another.

## Completion Gate

An audit result is complete only when selected cells are accounted for, evidence and confidence limits are explicit, cross-domain clusters are consolidated without double counting, security-sensitive findings remain redacted, and every proposed mutation has a concrete owner and authorization state. Evaluate `Chantier potentiel` before the final report.
