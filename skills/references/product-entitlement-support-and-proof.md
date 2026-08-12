---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 601-sg-product-entitlements
scope: product-entitlement-support-and-proof
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
  - "Wave 12 made the previously named SPE-001 through SPE-010 scenario family explicit."
next_review: "2026-11-12"
next_step: none
---

# Product Entitlement Support And Proof

## UI And Support Contract

Distinguish signed out, lookup unavailable, recognized/no entitlement, active, expired/refunded/revoked, and pending-review states. Only verified active access unlocks product behavior. Use product-safe recovery language and expose marketplace/provider branding only when intentionally public.

Support documentation must explain safe user lookup, entitlement inspection, grant/revoke/refund/expire/reissue, duplicate identity handling without silent merge, wrong-account code recovery, provider reconciliation, and retention after access removal. Redact tokens, raw codes, cookies, provider secrets, raw webhook payloads, and unnecessary personal data.

## Scenario Family

- `SPE-001`: suite product adapts to the canonical ledger; no duplicate ledger.
- `SPE-002`: explicitly standalone product uses the minimum server-owned model.
- `SPE-003`: authenticated identity or client claim alone is denied.
- `SPE-004`: verified provider event grants once; replay is idempotent.
- `SPE-005`: malformed, cross-environment, unknown-product/provider event denies or remains pending review.
- `SPE-006`: activation code is protected, same-user retry is idempotent, and unintended second-user reuse is denied.
- `SPE-007`: backend premium read/write and quota gates ignore client-supplied authorization fields.
- `SPE-008`: mirror/cache becomes non-granting when missing, stale, divergent, revoked, refunded, or expired.
- `SPE-009`: sync and auth failures route to their owners without weakening entitlement truth.
- `SPE-010`: support grant/revoke/refund/expiry path is useful, auditable, and redacted.

## Completion Proof

Exercise the smallest representative grant lifecycle with a realistic test account: ingest/grant, query normal backend access, deny unauthorized reuse/cross-user access, revoke/refund/expire, confirm protected denial, replay the event, and inspect redacted support diagnostics. State untested provider, production, device, UI, or backend surfaces explicitly. UI-only work never proves backend authorization or revocation propagation.

