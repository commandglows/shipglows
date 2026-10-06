---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.2"
project: ShipGlows
created: "2026-09-11"
updated: "2026-09-28"
status: draft
source_skill: 900-shipglows-core
scope: digital-product-commerce-launch
owner: ShipGlows maintainers
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/stripe-payments-commerce-playbook.md
  - shipglows_data/workflow/playbooks/appsumo-licensing-commerce-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Generalized on 2026-09-28 for teams selling software, courses, paid content, downloads, and other digital products."
next_review: "2026-10-11"
next_step: "Instantiate with a project's own offer, access, and provider contracts."
---

# Playbook - Digital product commerce launch

## Purpose

Run an end-to-end commerce, payment, fulfillment, access, recovery, and launch workflow for digital products such as software, online courses, paid content, downloads, and memberships.

Checkout alone does not prove a successful sale. A launchable offer needs a verified purchase, clear fulfillment or gated access, recovery and refund handling, support visibility, and evidence that each boundary behaves correctly.

Before use, supply the project's own product catalog, commercial policy, identity model, access authority, provider agreements, and support process. The playbook does not choose those policies for a team.

## Applicability

Use this playbook for digital products sold through direct checkout, a marketplace, or a private offer. It covers one-time and recurring offers, and both file/content delivery and ongoing product access. Use only the provider-specific branches that apply.

Use it before claiming that a product is ready to sell, ready to launch, or ready to advertise paid access.

## Inputs

- The product id, public product name, seller, and customer delivery surfaces.
- Offer ids, plan ids, provider channel, and the server environment variable names that contain provider ids.
- Identity providers or account model used by the sales and delivery surfaces, if accounts are required.
- The authoritative purchase, fulfillment, or access record and event processor.
- The delivery surface: download, course platform, member area, hosted service, app, or a combination.
- Existing local access records, mirrors, caches, and legacy activation flows, where applicable.
- Provider documentation checked close to implementation time.
- Test accounts, local synthetic provider payloads, and later hosted proof credentials entered only through approved provider workflows.

## Execution Order

1. Declare the product, offer, price, refund, and delivery contract before building checkout.
2. Route every purchase and access decision through the project's designated server-side authority.
3. Bind checkout or licensing events to a server-owned purchase or license reference.
4. Record durable, auditable commerce evidence and derive access transitions from it.
5. Make each delivery surface check authoritative purchase/access state where gating is required.
6. Deny gated delivery on missing, malformed, stale, mismatched, revoked, expired, or wrong-environment access.
7. Add support operations for incidents, pending review, replay, reconciliation, and recovery.
8. Prove the applicable purchase or license, refund, duplicate event, delayed event, expiry, and recovery paths locally.
9. Prove hosted provider webhooks only after local invariants pass and the operator authorizes provider work.
10. Prove the actual customer delivery path on each launch platform before public launch claims.

## Decision Gates

- Product id, plan id, and offer id must be explicit. Do not infer them from route names, marketing copy, or provider product names.
- Email matching alone never merges accounts or grants access.
- Client-provided user ids, emails, provider ids, source refs, and entitlement states are hints only. The server must bind ownership from verified identity or provider evidence.
- Partial refunds, disputes, failed refunds, missing purchases, unknown owners, and unsupported provider states become `pending_review` or another non-granting operator state.
- A negative terminal transition for a purchase or license prevents a later positive event from regranting access without audited recovery.
- A client cache can make delivery faster, but it cannot override the project's designated purchase/access authority.
- A marketing or checkout success page is UX feedback only. It does not prove payment or entitlement.
- Deployment, provider mutation, license import, email delivery, DNS change, and production migration remain separate approval and proof gates.

## Outputs

- A current offer and product mapping.
- A working delivery path that honors the designated purchase/access authority.
- A local proof set covering grant, deny, expiry, refund, duplicate, replay, and recovery.
- A support runbook or console path for pending and failed commerce cases.
- A launch status that separates implemented, locally tested, deployed, provider-proven, and customer-delivery-proven.

## Linked Checklists

- Project-specific launch checklist instantiated from this playbook.
- Related playbook: `stripe-payments-commerce-playbook.md`
- Related playbook: `appsumo-licensing-commerce-playbook.md`

## Failure Modes

- Treating a checkout redirect as payment proof.
- Revoking the first active entitlement for a product instead of the entitlement attached to the purchase.
- Letting a late paid event reactivate an already refunded purchase.
- Recording `pending_review` as a permanent duplicate with no replay path.
- Reading product access from a stale mirror without expiry or freshness.
- Duplicating commercial rules across checkout and delivery surfaces.
- Granting AppSumo test validations.
- Announcing launch readiness from local tests while hosted payment events, provider account state, or the real customer delivery path are still unproven.
