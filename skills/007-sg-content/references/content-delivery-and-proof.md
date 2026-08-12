---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 007-sg-content
scope: content-delivery-and-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 8 extracted validation, proof, and delivery routing."
next_step: none
---

# Content Delivery and Proof

Validate only changed surfaces: metadata/schema, links/assets, content-quality score when required, secret/claim leak scans, focused build, and browser observation for public visual/route behavior. Use `108-sg-browser` for non-auth observation, `109-sg-auth-debug` for auth, and `405-sg-prod` only for deployed truth.

Record Fresh Docs Gate as `fresh-docs checked`, `fresh-docs not needed`, `fresh-docs gap`, or `fresh-docs conflict`. Never publish a current external claim on stale evidence.

Verification remains with `103-sg-verify`; bounded publication/ship remains with `005-sg-ship`. A failed build, schema, metadata, claim, proof, or runtime-link check blocks clean delivery.
