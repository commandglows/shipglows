---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 305-sg-init
scope: bootstrap-context-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Context bootstrap extraction; canonical templates remain authoritative."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Context Contract

Use canonical templates exactly: `$SHIPGLOWS_ROOT/templates/business_context.md`, `product_context.md`, `gtm_context.md`, and `brand_context.md`, governed by `guided-business-product-discovery.md`. Create in business → product → GTM → brand order. Existing confirmed content wins; stack detection never confirms audience, promise, business model or brand intent. Present one high-leverage question at a time and offer `Confirmer`, `Corriger` or `Approfondir`; drafts keep `hypothesis`/`unknown` and `artifact_version: "0.1.0"` until reviewed.

Use `templates/content_map.md` only when discovered editorial surfaces justify it. Do not invent blog/routes or create optional competitor/affiliate registries without an explicit request.
