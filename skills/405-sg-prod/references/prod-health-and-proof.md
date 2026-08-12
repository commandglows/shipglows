---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 405-sg-prod
scope: prod-health-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/405-sg-prod/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from production-verification-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify prod health proof"
---

# Production Health And Proof

Choose the URL from the matched provider deployment, then a matching deployment status, then documented project truth. Follow redirects and verify the final domain/environment. Record status, latency when available, and a stable content marker only when the expected marker is known.

Interpret HTTP evidence narrowly: 2xx proves that response; 3xx requires target inspection; 4xx may be expected auth or a client failure; 5xx and timeout are runtime failures. A homepage or health endpoint never proves the changed feature by itself.

Route non-auth browser assertions to `108-sg-browser`, auth/session/callback/provider/protected routes to `109-sg-auth-debug`, durable manual QA to `107-sg-test`, and proof completeness to `103-sg-verify`. For every gap state `proof_type`, `owner_skill`, exact `scenario`, and `target_or_environment`.

Sensitive releases—auth, authorization, payments, private data, webhooks, admin, or multi-tenant boundaries—remain partial until appropriate evidence exists. Do not request credentials, tokens, cookies, private payloads, or production PII as proof.
