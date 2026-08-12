---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 601-sg-product-entitlements
scope: product-entitlement-ledger-and-authorization
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
  - "Extracted from the primary entitlement doctrine in wave 12."
next_review: "2026-11-12"
next_step: none
---

# Product Entitlement Ledger And Authorization

Use for ledger adoption, storage, status resolution, backend guards, quotas, namespaces, or mirrors. The primary playbook owns invariants; this leaf owns implementation detail.

## Canonical-Ledger Preflight

Search project and ShipGlows doctrine for `product_entitlements`, `productAccessEvents`, `suiteAccess`, suite identity, and global-user mappings before adding tables or gates. If a suite ledger exists, add the product allowlist entry, ingestion path, backend query/bridge, and product-specific UI/gates. Freeze newly discovered duplicate local writes and plan a bridge or migration.

A separate ledger requires an intentionally standalone product, a ready temporary migration/removal plan, or documented regulatory/offline/tenant isolation need.

## Model And Status

Use stable allowlisted `product_id`, `plan_id`, `source`, and `environment`; preserve external ids as redacted references and an idempotency key. A simple standalone model uses entitlements, append-only product-access/billing events, and redemption codes only when codes exist. Suite products reuse global users, identity accounts, product entitlements, access events, and product namespaces.

Map every local status to `grantsAccess: true|false`. Only verified `active` or unexpired `trialing` grants. `inactive`, `expired`, `revoked`, `refunded`, and `pending_review` deny. Do not store durable truth only in claims, cookies, local storage, app settings, or client-owned paths.

## Backend And Mirror Gates

Every protected read/write validates session signature/issuer/audience/expiry/subject, server-owned user mapping, product namespace, active entitlement, and feature/quota permission. Never trust client-supplied user, product, plan, entitlement, role, or quota values.

Client-rule databases use a server-owned access mirror derived from the canonical ledger. Give it an explicit freshness/TTL policy and propagate revoke/refund/expiry. Missing, stale, divergent, malformed, or cross-environment mirror state denies. A redacted diagnostic surface must not expose authorization secrets or writable grant state.

