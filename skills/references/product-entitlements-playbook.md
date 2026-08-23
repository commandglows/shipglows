---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.3.0"
project: ShipGlows
created: "2026-05-29"
updated: "2026-08-22"
status: active
source_skill: 601-sg-product-entitlements
scope: product-entitlements
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/references/winflowz-suite-product-registry.md
  - shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md
depends_on: []
supersedes: []
evidence:
  - "Suite authentication separates global identity, product entitlements, and product data namespaces."
  - "Wave 12 moved branch procedures to direct conditional leaves while preserving authorization doctrine here."
  - "Operator decision 2026-08-22: trial-expiry UX must make suspended product value concrete while preserving data safety, eligible restarts, recovery, and non-coercive founder voice."
  - "Operator decision 2026-08-22: govern the complete trial transition from calm pre-expiry reminders through expiration and recovery, with progressive clarity but no progressive pressure."
next_review: "2026-09-12"
next_step: "Implement and locally verify the unified suite contract in shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md."
---

# Product Entitlements Playbook

Use this primary doctrine for product access, plans, trials, activation codes, provider events, grants, refunds, revocations, quotas, premium gates, and missing-access support. It decides authorization invariants and which one direct branch `601-sg-product-entitlements` must load next.

## Core Doctrine

Keep identity, provider events, durable product entitlements, and product-local mirrors separate. Authentication proves identity; it never grants access. Providers and marketplaces report events; they are not runtime authorization sources. Fail closed: protected product behavior reads a server-owned entitlement ledger and denies when identity, verification, lookup, environment, namespace, or mirror state is missing or malformed.

For suite products, extend the canonical suite ledger with one stable `product_id`, ingestion path, bridge, UI, and product gate. Do not create a second durable ledger unless the product is explicitly standalone or a ready spec documents a temporary adapter and retirement path. Product-local state is a cache, mirror, migration adapter, or compatibility fallback only.

Normalize and allowlist product, plan, source, environment, status, and owner before an authorizing write. External customer, order, subscription, license, event, and identity ids remain references, never access truth. Client claims, cookies, local storage, UI state, and client-owned database paths never authorize premium reads or writes.

## Suite Commercial Contract

Every current and future Glows suite product uses a server-owned 30-day initial trial, at most two user-triggered 30-day restarts after expiry, at most three cycles or 90 days total, mandatory purchase afterward, no permanent freemium or authentication grant, and Stripe Managed Payments as the only direct-payment provider.

Managed Payments must be explicit per checkout. Keep the ledger source-neutral internally, but allowlist exactly `stripe` for active suite ingestion. Historical/manual/migration sources remain auditable but non-granting unless canonical policy permits them. Never invent prices: resolve a named server-side Stripe Price ID. If current official eligibility, API, webhook, refund, availability, or terms are unknown or incompatible, apply the freshness gate and stop for an operator decision; do not choose a fallback provider.

## Direct Branch Map

After this doctrine, load at most one branch before the next substantive action:

- Ledger creation/adoption, statuses, backend authorization, product namespace, quota, or mirror/cache: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-ledger-and-authorization.md`.
- Checkout, provider webhooks, manual/LTD/activation codes, refunds, revocations, replay, or ingestion: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-ingestion.md`.
- UI access states, pre-expiry reminders, trial-transition conversion, operator support, reconciliation, redaction, or completion proof: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-support-and-proof.md`.

For suite ids/defaults/sync eligibility, load `$SHIPGLOWS_ROOT/skills/references/winflowz-suite-product-registry.md` directly from the skill. For current provider semantics, load `documentation-freshness-gate.md` and official sources directly from the skill. Branch files never load one another.

## Activation-Critical Stops

Stop for identity/entitlement conflation; duplicate durable ledgers; unknown product/plan/environment/owner; client-authorized access; raw activation-code or secret exposure; unverified, replayed, malformed, cross-environment, or unknown-provider events; mirrors that can stay active after revoke/refund/expiry; missing backend authorization; stale provider truth; or behavior-changing work without a ready contract.

Unknown and `pending_review` states never grant access. Revocation, refund, expiry, cancellation, chargeback, and failed renewal remove access without deleting identity. Product-safe UI may offer recovery or support but cannot promote an unverified state.

## Proof Boundary

Completion requires representative grant and denial evidence through the normal backend access query, plus idempotency/replay, revoke/refund/expiry propagation, cross-user isolation, and redacted support diagnostics as applicable. UI-only evidence is partial. The canonical scenario family `SPE-001` through `SPE-010` lives in the support-and-proof branch.

This doctrine does not replace legal, tax, accounting, invoicing, revenue-recognition, or app-store policy review.
