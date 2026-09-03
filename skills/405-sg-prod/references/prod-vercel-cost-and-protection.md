---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-04"
status: active
source_skill: 405-sg-prod
scope: production-vercel-cost-and-protection
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/405-sg-prod/SKILL.md
  - skills/405-sg-prod/references/production-verification-workflow.md
  - skills/references/vercel-cost-conscious-operations.md
depends_on:
  - artifact: skills/references/vercel-cost-conscious-operations.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-04: production proof must observe Vercel cost and protection policy without spending credits for convenience."
next_review: "2026-10-04"
next_step: none
---

# Production Vercel Cost And Protection

Load the shared `skills/references/vercel-cost-conscious-operations.md` contract when Vercel is the resolved provider. Prefer callable Vercel MCP evidence and use authorized CLI evidence as fallback. Observe deployment protection, build machine/concurrency policy, and relevant usage or cost anomalies only when the current tool exposes them.

Never trigger a replacement build, change spend controls, enable an add-on, publish a WAF rule, or mutate protection merely to complete verification. A configured but non-callable MCP is not provider proof. Return the observable state and the smallest evidence gap to the production-verification core.
