---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 601-sg-product-entitlements
scope: identity-consent-access
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: ["Auth0","Convex","Postmark"]
depends_on: []
supersedes: []
evidence:
  - "Approved Core plan: central identity, consent, access and email agent training, September 5, 2026."
next_review: "2026-10-05"
next_step: Revalidate project configuration and current official provider behavior before integration.
---

# Identity, Consent and Product Access

Use when a task connects identity, product access, newsletter consent or central
email delivery. This is a reusable boundary contract, not a provider selection
or authorization to migrate a project. Read the selected project's durable
identity, backend, commercial and email contracts before implementation.

## Independent owners

| Responsibility | Canonical decision | Never infer from |
| --- | --- | --- |
| Identity | Verified issuer + subject mapped to an internal person ID | Email match, contact import, browser claim |
| Product access | Server-owned entitlement ledger and current policy | Login, email delivery, provider dashboard, UI cache |
| Marketing consent | Business + audience/purpose + address scope with evidence | Purchase, account creation, another brand's consent |
| Delivery | Eligible outbox job, transport result and authenticated events | A template preview or a configured API key |

Convex is the chosen central data owner where the project declares the
CommandGlows service. Postmark is its selected transport. Auth0 is an identity
adapter where explicitly selected. Do not convert these bindings into defaults
for unrelated projects. Reuse a declared central service; do not copy its ledger
into each product. Keep standalone models explicit.

## Identity and anonymous contacts

An anonymous newsletter signup may exist without an account or product access.
Keep an address/contact distinct from the authenticated person. Verified email
alone never authorizes account linking: require an explicit linking procedure
proving control of both identities. Retain provider issuer/subject references;
email changes do not silently transfer ownership, purchases or consent.

Every server operation resolves user, business, product, purpose and environment
from verified context and server allowlists. Client-supplied identifiers select
only within the caller's authorized scope. Missing or malformed identity, scope,
provider verification or entitlement lookup denies protected access.

## Consent lifecycle

Persist requested -> confirmed -> withdrawn state and immutable consent evidence:
notice version, purpose, source, locale and recorded time. Use confirmation
(double opt-in) for the central newsletter pattern; this is a product policy,
not a universal legal claim. A confirmation proves address control for this
subscription, never authentication or a product entitlement.

Confirmation tokens expire, are single-use and generation-bound. A scanner GET
must not mutate consent. Withdrawal invalidates pending confirmations and queued
marketing work. Scope unsubscribe to the declared purpose/business; offer wider
preferences only explicitly. Resubscription needs fresh evidence and cannot
clear hard-bounce or complaint suppression automatically.

Purchase does not subscribe marketing. Unsubscribe preserves account and license.
Refund/revocation/expiry changes access without fabricating a consent withdrawal.
Service/security mail needs an actual service trigger and approved classification;
it does not require newsletter opt-in. Never disguise marketing as transactional
to evade withdrawal. Check marketing consent for marketing jobs and applicable
delivery suppression for every job immediately before dispatch.

## Reliable service boundary

Keep recipients, audience, consent, suppressions and entitlements canonical;
provider contacts/events are projections and evidence. Normalize events, authenticate
callbacks, deduplicate and isolate namespaces. Provider events cannot grant
entitlements or consent. An older event cannot reactivate a withdrawn subscription.

Persist idempotent commands and outbox attempts before external send. Separate
submission, delivery, unknown and failure; internal idempotency does not promise
provider exactly-once delivery. Maintain retry/reconciliation policy and prevent
uncertain sends from being blindly repeated.

Erasure and retention use a project-approved policy per data class. Preserve only
justified minimal suppression evidence (for example keyed tombstones); never
silently remove opposition or delete another business's shared data. Do not
hardcode company addresses, domains, credentials, retention durations or legal
claims in generic skills.

## Adaptation record and proof

Before connecting another product, record in its governance: chosen identity and
backend, central service owner/origin, business/product/audience IDs, environment,
notice/version, permitted commands, provider/stream binding and test recipient
authority. Secret values belong only in the declared secret store.

Prove: login without entitlement denies; purchase without consent sends no
marketing; withdrawal retains license; same address across brands is isolated;
revocation reaches backend/cache; replay cannot multiply effects; provider outage
does not report success. Support diagnostics reveal safe identifiers and states,
never tokens, raw webhooks or personal address lists.

The owning skill selects provider, newsletter and entitlement detail directly.
This leaf does not load other leaves.
