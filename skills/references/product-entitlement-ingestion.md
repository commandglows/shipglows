---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 601-sg-product-entitlements
scope: product-entitlement-ingestion
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/references/product-entitlements-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Extracted from provider-event and redemption-code doctrine in wave 12."
next_review: "2026-09-12"
next_step: none
---

# Product Entitlement Ingestion

Use for provider events, checkout, manual grants, Lifetime Deal or activation codes, refunds, revocations, and migrations.

## Codes

Activation codes are bearer credentials. Never log them, persist them in browser/mobile storage, or expose code tables to clients. Normalize server-side, prefer hashes at rest, make same-user retries idempotent, block unintended cross-user reuse, and protect imports with a server/operator secret or authenticated admin authorization.

## Provider Events

For suite direct payments, accept only verified Stripe Managed Payments events. Verify signature/token, product/plan/environment allowlists, and a unique provider event id before processing. Reject replayed, partial, malformed, cross-environment, or unknown-product events; ambiguous evidence becomes non-granting `pending_review`.

Preserve redacted provider references. Refund, chargeback, cancellation, failed renewal, license deactivation, and manual revoke remove access without deleting identity. Recompute from durable events when possible rather than waiting for login.

Historical provider/manual/migration evidence may be retained for reconciliation but cannot bypass the canonical resolver, trial-cycle limit, or revoke/refund state. Any potentially changed provider/API behavior requires the freshness gate and current official sources before implementation or correctness claims.

