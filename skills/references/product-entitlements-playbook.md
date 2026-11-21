---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.4.1"
project: ShipGlows
created: "2026-05-29"
updated: "2026-11-21"
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
  - shipglows_data/workflow/playbooks/digital-product-commerce-launch-playbook.md
  - shipglows_data/workflow/playbooks/stripe-payments-commerce-playbook.md
  - shipglows_data/workflow/playbooks/appsumo-licensing-commerce-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Suite authentication separates global identity, product entitlements, and product data namespaces."
  - "Wave 12 moved branch procedures to direct conditional leaves; authorization doctrine stayed here."
  - "Operator decision 2026-08-22: govern the complete trial transition from pre-expiry reminders through recovery, with progressive clarity and no progressive pressure."
  - "2026-09-11: linked the Stripe and AppSumo operational playbooks so provider work reuses this boundary."
  - "Operator decision on 2026-10-02: permit an approved CommunityGlows two-cycle/one-restart exception while retaining the three-cycle suite default."
next_review: "2026-10-11"
next_step: "Use the linked operational playbooks when a product is being prepared for sale or provider proof."
---

# Product Entitlements Playbook

Primary doctrine for product access, plans, trials, activation codes, provider events, grants, refunds, revocations, quotas, premium gates and missing-access support. It decides authorization invariants and the one direct branch `601-sg-product-entitlements` loads next.

## Core Doctrine

Keep identity, provider events, durable entitlements and product-local mirrors separate. Authentication proves identity; it never grants access. Providers and marketplaces report events; they are not runtime authorization sources. Fail closed: protected behavior reads a server-owned entitlement ledger and denies when identity, verification, lookup, environment, namespace or mirror state is missing or malformed.

Suite products extend the canonical suite ledger with one stable `product_id`, ingestion path, bridge, UI and product gate. No second durable ledger unless the product is explicitly standalone or a ready spec documents a temporary adapter and retirement path. Product-local state is cache, mirror, migration adapter or compatibility fallback only.

Normalize and allowlist product, plan, source, environment, status and owner before any authorizing write. External customer, order, subscription, license, event and identity ids are references, never access truth. Client claims, cookies, local storage, UI state and client-owned database paths never authorize premium reads or writes.

## Operational Playbook Layer

This is the entitlement doctrine, not the launch checklist, and it does not replace provider-specific playbooks. Below it, in order:

1. `shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md`: active suite commercial contract and provider policy.
2. `shipglows_data/workflow/playbooks/digital-product-commerce-launch-playbook.md`: reusable method from sellable offer to delivery; instantiate with the project's policy.
3. `shipglows_data/workflow/playbooks/stripe-payments-commerce-playbook.md`: Stripe sales.
4. `shipglows_data/workflow/playbooks/appsumo-licensing-commerce-playbook.md`: AppSumo Licensing, an external license channel feeding the same ledger.

Reusable execution lessons go to the operational playbooks; changes to what product access means go to this doctrine and the active suite contract.

## Suite Commercial Contract

Suite default: server-owned 30-day initial trial, at most two user-triggered 30-day restarts after expiry, at most three cycles or 90 days total, mandatory purchase afterward, no permanent freemium or authentication grant, and Stripe Managed Payments as the only direct-payment provider. A product-specific cycle cap needs explicit operator approval recorded in both the product policy registry and the governing spec; CommunityGlows has one approved exception (two 30-day cycles, one restart).

Managed Payments are explicit per checkout. Keep the ledger source-neutral internally, but allowlist exactly `stripe` for active suite ingestion. Historical, manual and migration sources stay auditable but non-granting unless canonical policy permits. Never invent prices: resolve a named server-side Stripe Price ID. If official eligibility, API, webhook, refund, availability or terms are unknown or incompatible, apply the freshness gate and stop for an operator decision; never choose a fallback provider.

## Direct Branch Map

After this doctrine, load at most one branch before the next substantive action:

- Ledger creation/adoption, statuses, backend authorization, product namespace, quota, mirror/cache: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-ledger-and-authorization.md`.
- Checkout, provider webhooks, manual/LTD/activation codes, refunds, revocations, replay, ingestion: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-ingestion.md`.
- UI access states, pre-expiry reminders, trial-transition conversion, operator support, reconciliation, redaction, completion proof: `$SHIPGLOWS_ROOT/skills/references/product-entitlement-support-and-proof.md`.

Suite and provider-semantics loaders are owned by the skill. Branch files never load one another.

## Activation-Critical Stops

Stop for identity/entitlement conflation; duplicate durable ledgers; unknown product, plan, environment or owner; client-authorized access; raw activation-code or secret exposure; unverified, replayed, malformed, cross-environment or unknown-provider events; mirrors that can stay active after revoke/refund/expiry; missing backend authorization; stale provider truth; or behavior-changing work without a ready contract.

Unknown and `pending_review` states never grant access. Revocation, refund, expiry, cancellation, chargeback and failed renewal remove access without deleting identity. Product-safe UI may offer recovery or support but cannot promote an unverified state.

## Proof Boundary

Completion requires representative grant and denial evidence through the normal backend access query, plus idempotency/replay, revoke/refund/expiry propagation, cross-user isolation and redacted support diagnostics as applicable. UI-only evidence is partial. The canonical scenario family `SPE-001` through `SPE-010` lives in the support-and-proof branch.

Does not replace legal, tax, accounting, invoicing, revenue-recognition or app-store policy review.
