---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-08-11"
updated: "2026-08-11"
status: active
source_skill: sg-docs
scope: external-platform-stripe-managed-payments
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/product-entitlements-playbook.md
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/external-platforms/README.md
  - shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md
depends_on:
  - artifact: "skills/references/product-entitlements-playbook.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Stripe official documentation checked on 2026-08-11: Managed Payments makes Stripe the Merchant of Record for eligible transactions."
  - "Stripe official documentation checked on 2026-08-11: France and eligible digital software/SaaS products are supported."
  - "Lemon Squeezy update of 2026-01-28 describes Stripe Managed Payments as the forward Merchant of Record platform and a future migration destination."
  - "Operator decision on 2026-08-11: use Stripe Managed Payments by default for CommandGlows and future eligible Glows digital products."
  - "Operator decision later on 2026-08-11 superseding provider exceptions: Stripe Managed Payments is the only active direct-payment provider for every current and future suite product."
next_review: "2026-09-11"
next_step: "Recheck public-preview status, eligibility, pricing and webhook contracts before each first production integration."
---

# Stripe Managed Payments Platform Note

## Purpose

This is the global ShipGlows source map and provider-selection contract for
Stripe Managed Payments. It is the only active direct-payment provider for
every current and future Glows suite product. Ordinary Stripe Payments is not
equivalent: without Managed Payments, the seller remains Merchant of Record.

## Source Map

| Need | Official source |
| --- | --- |
| Product overview | https://stripe.com/managed-payments |
| How it works, eligibility and limitations | https://docs.stripe.com/payments/managed-payments/how-it-works |
| Setup and API requirements | https://docs.stripe.com/payments/managed-payments/set-up |
| Product changelog | https://docs.stripe.com/payments/managed-payments/changelog |
| Pricing | https://stripe.com/fr/pricing |
| Contract terms | https://stripe.com/gb/legal/ssa-services-terms |
| Lemon Squeezy product-direction update | https://www.lemonsqueezy.com/blog/2026-update |

## Freshness Gate Use

Before a spec, implementation, migration, or production claim, verify current
availability/preview status, seller country, product tax-code eligibility,
supported Checkout flow, API version, payment methods, refund behavior, pricing,
webhook events, terms, and prohibited products from official Stripe sources.

Use `fresh-docs conflict` if ordinary Stripe Payments is presented as Merchant
of Record or if local code assumes Lemon Squeezy event/API compatibility.

## ShipGlows Decision Rules

- Require Stripe Managed Payments for every current and future suite product.
- Do not select a fallback provider. If eligibility, geography, capability,
  pricing, availability, migration, platform-store policy, or release risk
  prevents adoption, stop for a new operator decision.
- Keep Stripe as a verified event source; keep authorization in the canonical
  server-owned entitlement ledger.
- Grant access only after a verified, idempotent server event. Never treat the
  Checkout success redirect as payment proof.
- Separate test and production environments, allowlist products/prices/plans,
  and fail closed on unknown or malformed events.
- Do not assume Lemon Squeezy products, variants, signatures, events, customers,
  subscriptions, or identifiers can be reused directly.
- Resolve each sellable offer through an allowlisted server environment Stripe
  Price ID. Never invent or encode a price amount from this policy note.

## Common Project-Local Fields

Record internal offer/product/plan mappings, Stripe Product and Price ID key
names (never values), Managed Payments activation/eligibility, API version,
checkout and webhook routes, event/idempotency mappings, refund/revoke behavior,
test/production separation, and hosted proof status.

## Security Notes

Keep secret keys and webhook signing secrets server-only. Verify signatures
against the exact raw request body, redact customer/payment data from evidence,
and never expose provider credentials or raw webhook payloads in docs or logs.

## Validation

Documentation-only changes require metadata lint and focused source-link checks.
Provider implementation requires test-mode Checkout, signed webhook,
idempotency/replay, refund/revoke, entitlement refresh, and fail-closed proof.

## Reader Checklist

- Confirm the transaction explicitly enables Managed Payments.
- Confirm the seller country and product tax code remain eligible.
- Confirm current API version and webhook event contracts.
- Confirm Convex or the product ledger, not Stripe, owns runtime access.
- Confirm hosted test-mode proof before any production-ready claim.

## Maintenance Rule

Update this note when Stripe changes availability, preview status, supported
countries/products, pricing, API version, Checkout constraints, events, refunds,
terms, or migration guidance from Lemon Squeezy.
