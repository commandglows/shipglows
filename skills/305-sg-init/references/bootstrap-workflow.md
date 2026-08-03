---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-workflow-index
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Former bootstrap monolith split by mutable operation."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Workflow Index

Detect stack and current project state first. Then load only the active operation: `bootstrap-entrypoint-and-dev-mode.md`, `bootstrap-trackers-and-report.md`, `bootstrap-context-contract.md`, `bootstrap-mcp-setup.md`, or `bootstrap-governance-corpus.md`. Context uses `$SHIPGLOWS_ROOT/templates/business_context.md`, `$SHIPGLOWS_ROOT/templates/product_context.md`, `$SHIPGLOWS_ROOT/templates/gtm_context.md`, and `$SHIPGLOWS_ROOT/templates/brand_context.md` with `Confirmer`, `Corriger` or `Approfondir`. Never overwrite existing artifacts without the owner contract and an explicit safe decision.
