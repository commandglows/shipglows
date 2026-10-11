---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-09-11"
updated: "2026-09-28"
status: draft
source_skill: 900-shipglows-core
scope: stripe-commerce-payments
owner: ShipGlows maintainers
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/digital-product-commerce-launch-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Generalized on 2026-09-28 for teams selling digital products with Stripe and a server-side purchase or access authority."
next_review: "2026-10-11"
next_step: "Instantiate with the project's current Stripe account, offer, and access contracts."
---

# Playbook - Stripe payments commerce

## Purpose

Run Stripe sales so that checkout, webhook processing, refunds, disputes, fulfillment, and support recovery produce one reliable purchase and access result.

The seller defines identity, product mapping, access state, and support decisions in its own system.

Check current Stripe documentation and the project's chosen Stripe product and merchant model before implementation. This playbook does not assume a particular account structure, tax model, or access store.

## Applicability

Use this playbook for one-time or recurring digital-product purchases through Stripe. Select the checkout and merchant model that fits the product, seller, jurisdiction, and current provider terms.

Do not use this playbook for AppSumo license transitions; follow the AppSumo licensing playbook for that channel.

## Inputs

- Owning business id, product id, offer id, plan id, and channel.
- Stripe Price id environment variable name, never a browser-provided price id.
- A server-verified checkout handoff bound to the authenticated user, product, offer, environment, expiry, and one-time use where separate systems need it.
- The owning business's Stripe account, secret configuration, webhook signing secret, and operator recovery access, supplied through that business's environment.
- Local synthetic webhook fixtures and provider-normalized event tests.
- Current Stripe documentation for the chosen checkout and merchant model, webhook ordering, duplicate delivery, refunds, disputes, and API version behavior.

## Execution Order

1. Verify the offer-to-seller mapping, the correct Stripe account, and the server-side Price configuration.
2. Create checkout only after a signed identity handoff is verified server-side.
3. Store a server-owned checkout reference and pass that reference to Stripe metadata.
4. Keep the raw identity token out of URLs, page markup, Stripe metadata, and logs.
5. Verify webhooks from the exact raw request body.
6. Bind verified Stripe events to the configured merchant account and environment, then normalize them into the project's commerce event model.
7. Persist immutable receipts before changing entitlements.
8. Grant only when the purchase reference, product, owner, offer, plan, environment, and provider evidence match the project's contract.
9. Revoke only the entitlement attached to the refunded, disputed, or revoked purchase.
10. Classify ambiguous or incomplete states as non-granting incidents.
11. Provide operator recovery through authenticated server routes that retrieve Stripe evidence directly.
12. Run local synthetic tests before hosted provider proof.

## Decision Gates

- A browser payload never supplies the entitlement owner, Price id, purchase state, refund state, or provider evidence.
- Stripe webhooks can arrive out of order and more than once; code must be deterministic under duplicate and delayed delivery.
- A refund, revoke, dispute loss, or fraud state for one purchase must not revoke another valid purchase or trial.
- A partial refund is not automatically a full access revoke.
- A failed or still-pending refund does not prove that access should change.
- A late `paid` event must not regrant a purchase after a terminal negative event.
- A support repair must retrieve Stripe evidence server-side, compare environment and ids, and write an audit event.
- Test mode, production mode, and different business accounts must never share idempotency, customer identity, recovery credentials, or provider evidence.

## Outputs

- A checkout route that returns only a verified Stripe checkout URL or a safe error.
- A webhook route that records unsupported, invalid, or failed events without granting access.
- An authoritative processor with durable receipt records and repeatable purchase-state transitions.
- Operator-visible incidents for missing webhooks, pending review, recovery, and alert retry.
- Tests for normal grant, duplicate events, refund, partial refund, dispute, delayed event, wrong environment, missing owner, and repair.
- A runbook that tells the operator what can be retried, recovered, resolved, or escalated.

## Linked Checklists

- Project-specific checkout and access checklist instantiated from this playbook.
- Parent playbook: `digital-product-commerce-launch-playbook.md`

## Failure Modes

- Trusting `sourceRef` supplied by the client.
- Using `checkout.session.completed` alone without binding the payment intent or completed handoff.
- Treating Stripe event order as guaranteed.
- Storing raw payment payloads when hashes and selected provider evidence are sufficient.
- Retrying unknown provider submissions blindly.
- Claiming provider proof from mocked tests.
- Creating private/founder behavior through hidden code branches instead of explicit offers and plan mappings.
