---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-05-29"
updated: "2026-08-11"
status: active
source_skill: 001-sg-build
scope: product-entitlements
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/decision-quality-contract.md
  - skills/references/documentation-freshness-gate.md
  - skills/references/sentry-observability.md
  - skills/references/master-workflow-lifecycle.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "WinFlowz suite-authentication doctrine separates global identity, product entitlements, and product data namespaces."
  - "WinFlowz Firestore rules require a server-owned suiteAccess mirror before product data access."
  - "SocialGlowz implemented processor-agnostic entitlements, redemption codes, billing events, and Lifetime Deal activation UI."
  - "SocialGlowz adoption review on 2026-05-30 exposed the generic duplicate-ledger risk: a target product must adapt to an existing suite entitlement ledger instead of recreating partial local infrastructure."
  - "Operator decision on 2026-08-11: Stripe Managed Payments is the default Merchant of Record for future eligible Glows digital products; exceptions require a product-specific reason."
  - "Operator decision on 2026-08-11 superseding provider and trial exceptions: every current and future suite product uses a 30-day trial, at most two restarts, mandatory purchase after three cycles, no permanent freemium, and Stripe Managed Payments only."
next_review: "2026-09-11"
next_step: "Implement and locally verify the unified suite contract in shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md."
---

# Product Entitlements Playbook

Use this reference when a project introduces or changes product access, paid plans, Lifetime Deals, activation codes, billing providers, manual grants, refunds, revocations, usage limits, premium gates, or support flows for missing access.

## Core Doctrine

Keep three layers separate:

- Identity: who the user is.
- Provider events: what an external payment, marketplace, app store, or operator action reported.
- Product entitlements: what this product allows this user to access right now.

Authentication proves identity. It must not grant product access by itself.

Payment providers and marketplaces are event sources. They must not be the runtime source of truth for product authorization. Store product access in a server-owned entitlement ledger and have product backends read that ledger before granting access to protected product data or premium capabilities.

For products that belong to a suite, the entitlement ledger should be suite-owned by default. A target product should add its `product_id`, bridge, product UI, and product-specific gates to the canonical ledger. It should not create a second durable entitlement ledger unless the product is explicitly standalone or the spec documents a temporary migration adapter with a retirement path.

Fail closed. If identity, provider verification, entitlement lookup, bridge sync, or product namespace checks are unavailable or malformed, show a recoverable "access not active/unavailable" state and deny protected reads or writes.

## Suite Commercial Contract

Every current and future Glows suite product uses one non-optional commercial
access policy:

- one server-owned 30-day initial trial cycle;
- at most two user-triggered 30-day restarts after expiry;
- at most three cycles or 90 days in total;
- mandatory purchase after the allowance is exhausted;
- no permanent freemium, default-free entitlement, or authentication-based
  product grant;
- Stripe Managed Payments as the only direct-payment provider.

This contract supersedes the former CommandGlows 14-day/42-day policy,
CommunityGlows single-cycle policy, default-free suite policy, and active Lemon
Squeezy or Polar provider decisions. The canonical implementation spec is
`shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md`.

Do not interpret Stripe Managed Payments as ordinary Stripe Payments: each
checkout transaction must explicitly use Managed Payments for Stripe to act as
Merchant of Record. Keep the entitlement ledger source-neutral internally, but
the active suite ingestion allowlist is exactly `stripe`; other provider events
are rejected or remain non-granting `pending_review` migration evidence.

Before implementation, check current official eligibility, supported products,
pricing, API version, preview/availability status, checkout limitations, webhook
events, refunds, and terms. If Stripe Managed Payments is unavailable or
ineligible, stop for a new operator decision rather than selecting a fallback.
Provider acquisition or shared ownership alone is not evidence of API or
contract compatibility.

No documentation or implementation may invent price amounts. Resolve each
allowlisted offer through a named server environment Stripe Price ID; missing
configuration makes checkout unavailable.

## When To Load This

Load this playbook before:

- adding checkout, webhooks, store purchases, provider billing, or payment-provider sync;
- adding Lifetime Deal, early-bird, partner, coupon, or manual activation codes;
- changing account, onboarding, pricing, subscription, plan, trial, or paywall behavior;
- adding feature gating, quota enforcement, or product-data authorization;
- reviewing auth or database rules for paid/protected product surfaces;
- writing support docs for missing, duplicated, refunded, revoked, or migrated access.

Also load `documentation-freshness-gate.md` when provider API behavior, webhook signatures, OAuth, app-store purchase validation, or current marketplace rules matter.

For suite products, trial/default access, account-backed sync eligibility, or
product aliases, also load
`skills/references/winflowz-suite-product-registry.md` before deciding product
ids or grant behavior.

## Canonical Ledger Preflight

Before adding entitlement tables, billing event tables, redemption-code tables, access queries, provider webhooks, or premium gates inside a target project, first prove whether a canonical entitlement ledger already exists for the product family.

Minimum local search:

```bash
rg -n "productEntitlements|product_entitlements|entitlement ledger|suiteAccess|suite identity|globalUserId|global_user_id" .
rg -n "product-entitlements-playbook|suite-authentication|unified-suite-authentication|master-auth-playbook" "$HOME/.shipglows/runtime" "$HOME/shipglows_data" 2>/dev/null
```

If a suite ledger already exists, adapt to it instead of recreating it:

- add or confirm the target `product_id` in the suite allowlist;
- add provider/manual/Lifetime Deal ingestion to the suite ledger;
- add an entitlement snapshot/query/bridge for the target app runtime;
- keep product-local code to activation UI, status display, feature gates, and product-specific authorization calls;
- store product-local entitlement state only as a documented cache, mirror, migration adapter, or compatibility fallback.

Creating a second durable ledger in a target product is a stop condition unless one of these is true:

- the product is intentionally standalone and outside the suite account/access architecture;
- the canonical ledger is not available yet, and the spec explicitly marks local storage as temporary with a migration/removal plan;
- regulatory, app-store, offline, or tenant-isolation constraints require a separate ledger and the security tradeoff is documented.

If duplicate local infrastructure is discovered after implementation, do not keep building on top of it. Freeze additional product-local entitlement writes, identify the canonical owner, plan a bridge or migration, and update docs so future work treats local tables as temporary or deprecated.

## Canonical Product Model

Use stable internal identifiers. External ids stay references, never replacements.

- `product_id`: stable allowlisted product id such as `communityglows`, `commandglows_app`, or `commandglows_formation`.
- `plan_id`: stable allowlisted plan id such as `free`, `trial`, `pro`, `lifetime_deal`, or `team`.
- `source`: normalized event origin. For active suite direct payments this must
  be `stripe`; historical/manual/migration sources may remain audit references
  but cannot bypass the canonical access resolver.
- `source_ref`: provider order/subscription/license/idempotency reference, stored server-side and redacted in logs.
- `environment`: `local`, `preview`, `staging`, or `production`; do not mix entitlements across environments.

Prefer allowlists for `product_id`, `plan_id`, and `source`. Free-form strings are acceptable only at the ingestion edge and must normalize before writes that authorize product access.

## Minimum Tables

For a standalone simple single-product app with no existing suite entitlement ledger, these three tables are enough:

- `entitlements`
  - `userId` or `globalUserId`
  - `productId`
  - `planId`
  - `status`
  - `source`
  - `sourceEventId` or equivalent idempotency key
  - `externalCustomerId`, `externalOrderId`, `externalSubscriptionId`, or equivalent provider references when available
  - `startsAt`, optional `expiresAt`
  - `createdAt`, `updatedAt`
  - optional redacted `metadata`
- `redemptionCodes`
  - `codeHash` preferred; raw `code` acceptable only for early MVPs with strict non-logging and no client table exposure
  - `productId`, `planId`
  - `source`
  - `status`
  - `redeemedBy`, `redeemedAt`
  - `externalOrderId` or partner batch reference
  - `createdAt`, `updatedAt`
  - optional operator note
- `billingEvents` or `productAccessEvents`
  - append-only event ledger
  - `userId` or `globalUserId` when known
  - `productId`, optional `planId`
  - `source`, `eventType`, `sourceEventId`
  - provider references, redemption code id, entitlement id
  - redacted payload summary, never raw secrets
  - `createdAt`

For suite products, use or extend the existing suite-owned identity and entitlement mapping instead of creating similarly shaped project-local copies:

- `global_users`
- `identity_accounts`
- `product_entitlements`
- `product_access_events`
- product data namespaces keyed by `product_id` and server-verified user identity.

The target product may still own redemption UI, product copy, feature gates, and product-specific authorization helpers, but the durable answer to "does this global user have access to this product?" belongs in the canonical ledger.

## Status Semantics

Canonical statuses:

- `active`: grants access.
- `trialing`: grants access until `expiresAt`.
- `inactive`: does not grant access.
- `expired`: does not grant access.
- `revoked`: does not grant access; operator or policy removed it.
- `refunded`: does not grant access; payment/refund event removed it.
- `pending_review`: does not grant access until an operator or verified process resolves it.

Project-specific statuses may exist, but every status must map explicitly to `grantsAccess: true | false`.

Do not store durable entitlement truth only in custom claims, cookies, localStorage, app settings, or client-owned database paths. Short-lived claims may accelerate UI state but must be recomputed from server truth.

## Redemption Codes

Activation codes are bearer credentials. Treat them like secrets.

- Do not log raw codes.
- Do not store raw codes in browser/mobile persistent storage.
- Do not expose redemption-code tables to clients.
- Normalize input server-side.
- Prefer hashing codes at rest once operations stabilize.
- Make same-user re-redemption idempotent.
- Block reuse by another user unless stacking/multi-seat behavior is explicitly designed.
- Code import must require a server/operator secret or authenticated admin role.
- Public UI should say "activation code", "Lifetime Deal code", or "early-bird code" unless the business intentionally wants marketplace branding.

Marketplace channels such as AppSumo can remain internal sources. Do not send direct-sale users toward a marketplace that takes commission unless the operator explicitly chooses that funnel.

## Provider Events

Provider integrations must be idempotent.

- For suite direct payments, allowlist exactly `stripe`. Lemon Squeezy, Polar,
  Paddle, marketplace, or unknown-provider events cannot grant access unless a
  later operator decision explicitly replaces this suite contract.
- Verify webhook signatures or OAuth/API tokens before processing.
- Use `sourceEventId` or provider event id as an idempotency key.
- Preserve provider customer/order/subscription/license ids as references.
- Reject replayed, malformed, partial, cross-environment, or unknown-product events.
- Unknown product ids or plan ids go to `pending_review`, not `active`.
- Refund, chargeback, cancellation, failed renewal, license deactivation, and manual revoke must remove access without deleting identity.
- Recompute entitlement state from durable events when possible; do not depend only on the next login.

If a provider API may have changed, apply the documentation freshness gate and prefer official current provider docs.

## Backend Authorization

Every protected product read or write must validate:

- session token signature, issuer, audience, expiration, and subject;
- mapped server-owned user id or global user id;
- product namespace;
- active entitlement for the requested `product_id`;
- feature or quota permission when the plan limits capabilities.

Never trust `user_id`, `global_user_id`, `product_id`, `plan_id`, `entitlement`, role, or quota values supplied by the client.

For databases with client-side rules, use a server-owned access mirror or equivalent. The mirror must not be client-readable or client-writable unless the product has a deliberate redacted diagnostic surface.

## UI Behavior

A signed-in account without entitlement should feel recognized but not authorized.

Recommended states:

- signed out: sign in or create account;
- backend unavailable: access cannot be checked right now;
- no entitlement: account recognized, access not active;
- active entitlement: show plan/access status;
- refunded/revoked/expired: show inactive status and support or purchase path;
- pending review: show support path without granting access.

Use product-safe language. For example:

- "Lifetime Deal access" for direct/LTD buyers.
- "activation code" for generic redemption.
- "early-bird code" for launch buyers.
- Marketplace names only in private support/import docs unless intentionally public.

## Support Runbook Requirements

Every project with entitlements should document:

- how to find a user by safe support identifiers;
- how to check active entitlements without exposing secrets;
- how to grant, revoke, refund, expire, or reissue access;
- how to handle duplicate emails or provider accounts without silent merge;
- how to handle a code already used by the wrong account;
- how to reconcile provider order/license ids with internal entitlements;
- what data is retained after access is removed.

Support logs and diagnostics must redact tokens, raw activation codes, cookies, provider secrets, raw webhook payload secrets, and unnecessary personal data.

## Smoke Proof

Before claiming entitlement work is complete, prove the smallest representative lifecycle:

- create/import a code or provider event;
- redeem/grant access for a real or realistic test account;
- confirm product access is active through the product's normal access query;
- confirm a second user cannot reuse a single-use code;
- revoke/refund/expire the entitlement;
- confirm protected product access is denied after revocation;
- confirm provider event replay is idempotent;
- confirm support diagnostics are useful and redacted.

For UI-only phases, state that backend revoke/refund or protected data gating remains unproven.

## Suite Adoption Notes

- Keep identity, entitlement, and product data namespace separate.
- Every product uses the shared 30-day × three-cycle policy; product-specific
  trial durations and permanent-free grants are no longer allowed.
- Firestore or other product data requires a server-owned access mirror or
  direct server authorization derived from the canonical Convex ledger.
- Firebase, Clerk, Stripe, app-store, and historical provider ids are external
  references, not product authorization.
- Direct/manual activation codes may remain controlled ingestion sources, but
  cannot reset trial allowance or bypass revoke/refund state.
- Product aliases resolve to one canonical durable `product_id`; marketing or
  platform names do not create new trial allowances.

## Non-Goals

This playbook does not replace legal, tax, accounting, invoicing, revenue-recognition, or app-store policy review. It defines product access control and operator proof obligations.

## Maintenance Rule

Update this playbook when the operator changes the unified suite trial/provider
decision, when Stripe Managed Payments constraints change, or when a new
entitlement status, support pattern, or authorization architecture changes the
reusable doctrine. Do not introduce product-local trial/provider exceptions in
derived docs.
