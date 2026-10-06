---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.3.4"
project: ShipGlows
created: "2026-08-11"
created_at: "2026-08-11 17:29:25 UTC"
updated: "2026-10-02"
updated_at: "2026-10-02 11:42:39 UTC"
status: ready
source_skill: sg-docs
source_model: "GPT-5 Codex"
scope: "unified-suite-commercial-entitlement-and-stripe"
owner: Diane
confidence: high
user_story: "As the suite operator, I want a reusable server-owned trial and payment model with explicitly governed product limits, so access rules remain commercially consistent and enforceable while honoring approved product-specific terms."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/references/product-entitlements-playbook.md"
  - "shipglows_data/workflow/playbooks/digital-product-commerce-launch-playbook.md"
  - "shipglows_data/workflow/playbooks/stripe-payments-commerce-playbook.md"
  - "shipglows_data/workflow/playbooks/appsumo-licensing-commerce-playbook.md"
  - "skills/references/winflowz-suite-product-registry.md"
  - "/home/claude/commandglows/commandglows_site/convex"
  - "/home/claude/commandglows/commandglows_site/src/lib/commerce"
  - "/home/claude/commandglows/commandglows_app/lib/features/auth"
  - "/home/claude/communityglows/convex/billing.ts"
  - "/home/claude/communityglows/src/composables/useBillingAccess.ts"
depends_on:
  - artifact: "skills/references/product-entitlements-playbook.md"
    artifact_version: "2.0.0"
    required_status: active
  - artifact: "shipglows_data/technical/external-platforms/stripe-managed-payments.md"
    artifact_version: "2.0.0"
    required_status: active
supersedes:
  - "/home/claude/commandglows/shipglows_data/workflow/specs/commandglows-trial-then-paid-entitlements.md v0.7.0"
  - "/home/claude/communityglows/shipglows_data/workflow/specs/communityglows-trial-access-gates.md v1.0.1"
evidence:
  - "Operator decision on 2026-08-11: one commercial contract applies to every current and future suite product."
  - "Operator decision on 2026-08-11: each trial cycle lasts 30 days, two user-triggered restarts are allowed, and purchase is mandatory after the third cycle."
  - "Operator decision on 2026-08-11: no permanent freemium or default-free product grant remains allowed."
  - "Operator decision on 2026-08-11: Stripe Managed Payments is the only payment provider for the suite; prior Lemon Squeezy and Polar decisions are superseded."
  - "Operator confirmed there are no users to preserve, allowing a clean provider and entitlement reset without customer grandfathering."
  - "Local batch B on 2026-08-11: the active offer registry, checkout route, Stripe webhook and Convex processor are Stripe-only; CommunityGlows and Formation use Price-ID placeholders; signed handoff is mandatory for every offer; active Lemon Squeezy and Polar runtime paths were removed."
  - "2026-09-11: clarified that this contract depends on the entitlement doctrine and is executed through the suite commerce, Stripe and AppSumo workflow playbooks."
  - "Operator clarification on 2026-09-25: a distinct Stripe account is owned by each business; central services are entitlement and email, not merchant accounts."
  - "Operator direction on 2026-09-25: payment integration should be provider-agnostic; extract Polar behind an adapter and add Stripe adapters to products that lack one."
  - "Operator decision on 2026-10-02 supersedes the CommunityGlows cycle limit only: two 30-day cycles and one eligible restart; the three-cycle suite default remains for all other products."
next_review: "2026-09-11"
next_step: "Configure approved Stripe Price IDs and run hosted Stripe/Convex plus provider-account and device proof only in a later authorized chantier."
---

# Unified Suite Commercial Entitlement And Stripe Contract

## Provider architecture amendment (2026-09-25)

The operator has directed a provider-agnostic integration architecture. The Stripe-only sections below describe the currently implemented central allowlist and earlier decision; they must not be read as a permanent prohibition on a Polar adapter. Each provider needs its own verified signatures, account ownership, offer catalogue, event translation, idempotency, and recovery path into the shared entitlement ledger. The operator confirmed that there are no customers and no payment history to retain; ReplayGlows may replace its old Polar-only subscription fields and compatibility lookups without migrating customer payments. Existing free access for product sign-up is a separate entitlement issue. Whether Polar is selectable for *new* sales and the ReplayGlows/ContentGlows paid offer mappings are still open operator decisions. No adapter alone makes an offer sellable or changes a hosted entitlement.

## Decision

This is the sole active commercial entitlement and direct-payment contract for every current and future product operated as part of the Glows suite.

This contract sits between two layers:

- `skills/references/product-entitlements-playbook.md` defines the reusable authorization doctrine.
- `shipglows_data/workflow/playbooks/*commerce*.md` defines how agents run implementation, provider proof, launch readiness and support operations without rediscovering provider-specific lessons.

Update this contract when suite-wide commercial policy changes. Update the playbooks when implementation order, provider operations, support handling or proof sequencing changes without changing the policy.

For each canonical `product_id`:

- the initial server-owned trial lasts exactly 30 × 24 hours;
- the suite default allows at most two restarts, each granting one new 30 × 24-hour cycle (three cycles or 90 days total);
- CommunityGlows allows at most one restart (two cycles or 60 days total);
- after a product's approved cycle allowance expires, purchase is mandatory for protected product access;
- account creation, authentication, identity sync, installation, reinstall, local mode, offline mode, or a new email never grants permanent access;
- no permanent freemium, default-free grant, or implicit free tier is allowed; another product-specific cycle limit requires explicit operator approval and an entry in the canonical policy registry and product spec;
- Stripe Managed Payments is the only allowed direct-payment provider.
- Each business operates its own Stripe account. Products of the same business may share that account; products of different businesses must not share its credentials, catalogue, webhook destination, financial reporting, or operator recovery access.

The previous CommandGlows 14-day/42-day policy, CommunityGlows single-cycle policy, suite default-free policy, Lemon Squeezy provider decision, and Polar provider decision are historical and superseded. Their records remain available for provenance but are not implementation authority. The 2026-10-02 two-cycle CommunityGlows allowance supersedes the earlier CommunityGlows three-cycle limit only; it does not change the suite default for other products.

No price amount is defined by this spec. Every sellable offer must resolve an allowlisted Stripe Price ID from server environment configuration. Missing Price IDs make checkout unavailable; implementations must never invent a price or silently choose another provider.

## Canonical Authority And Fail-Closed Rule

Convex is the sole durable authority for suite identity, trial consumption, paid entitlements, negative commerce transitions, and access decisions. Stripe is an authenticated event source, not an authorization store. Clients and product-local backends are adapters and caches only. The shared entitlement and email services do not own a shared merchant account. A business-owned checkout and verified webhook may submit a business-scoped commerce event to the entitlement ledger.

Every protected read, write, route, sync, or product action must require:

- a verified suite identity;
- the requested canonical `product_id`;
- a current Convex decision granting either an active trial cycle or an active paid entitlement;
- any additional plan capability or quota required by the action.

Missing, stale beyond the documented bounded grace, malformed, unverifiable, cross-environment, or unavailable state is non-granting. Local auth fallback, local storage, cached UI flags, provider redirects, provider metadata, email ownership, and client clocks cannot create access. Recovery surfaces may remain available for sign-in, retry, purchase, restore, support, privacy controls, and data export.

## Generic Per-Product Trial Policy

The server policy registry must use one reusable policy shape for every allowlisted current and future product. Its defaults are:

```text
mode: trial_then_paid
trialDurationMs: 30 * 24 * 60 * 60 * 1000
maxTrialCycles: 3
maxUserRestarts: 2
paymentRequiredAfterExhaustion: true
permanentFreeGrantAllowed: false
paymentProviderAllowlist: [stripe]
```

An approved product-specific cycle cap overrides only `maxTrialCycles` and
`maxUserRestarts`; cycle duration, paid-access requirement, no-permanent-free
rule, and provider policy remain unchanged. CommunityGlows uses
`maxTrialCycles: 2` and `maxUserRestarts: 1`. All other current products and
future products without an explicit approved exception use the defaults above.

Trial rows and snapshots must be keyed and resolved by canonical global identity, canonical `product_id`, environment, and server-owned attempt/cycle data. Required snapshot fields are:

- `productId`;
- `accessState`: `trial_active`, `trial_expired`, `trial_exhausted`, `paid_active`, or a non-granting recovery state;
- `grantsAccess`;
- `trialStartedAt` and `trialExpiresAt` when a cycle exists;
- `trialAttempt` in the inclusive range 1 through that product's `maxTrialCycles`;
- `trialRestartsRemaining` in the inclusive range 0 through that product's `maxUserRestarts`;
- `trialRestartEligible` derived only by the server;
- paid plan, source, and revocation state when applicable.

The generic authenticated mutation
`bridge:ensureSuiteProductTrialByGlobalUserId` is the bridge-level adapter for
all registered products, including products without a dedicated client app.
Dedicated product endpoints remain wrappers over the same writer and policy.

Starting or restarting a trial must be authenticated and idempotent. The first valid start creates attempt 1. A restart is valid only after the prior cycle expired, only when no active paid entitlement already grants the product, and only while fewer than that product's configured maximum cycles exist. Concurrent or repeated requests must return one decision without extending the period or consuming more than one attempt.

Paid access takes precedence over trial expiry. Refund, revoke, dispute, fraud, or other verified non-granting commerce state removes paid access and never resets or recreates trial allowance.

## Anti-Abuse Inputs And Privacy

Eligibility is enforced primarily by global identity plus product-scoped trial history. A recognized installation is a secondary continuity and abuse signal. Network data is a short-lived rate-limit/risk signal only.

Required rules:

- use a random, revocable, app-scoped installation identifier; persist only a keyed hash server-side;
- scope installation and trial history by canonical `product_id` and environment;
- prevent a recognized installation that consumed a product trial from obtaining a fresh cycle through another email or identity;
- allow legitimate identity continuity across new installations without resetting cycle count;
- pseudonymize network signals with rotating/keyed hashing and short retention;
- re-pseudonymize any CommunityGlows client hash with a server-only HMAC before
  persistence or comparison; missing server signal secret is non-granting;
- never persist raw IP addresses for this entitlement decision;
- never use IP alone for permanent denial, identity merging, or entitlement ownership;
- never collect IMEI, MAC address, serial number, advertising ID, or opaque hardware fingerprint for this contract;
- return generic recovery/purchase messaging that does not disclose another account's activity.

Stronger platform integrity may be added later as another risk signal, but it cannot replace identity, ledger history, privacy minimization, or a recoverable support path.

## Stripe-Only Commerce Contract

The active commerce provider allowlist is exactly `stripe`. Every current and future offer must:

- resolve an allowlisted internal `offerId`, `productId`, and `planId` server-side;
- resolve its Stripe Price ID from a named server environment variable;
- create a Stripe Managed Payments Checkout Session explicitly, not ordinary Stripe Payments;
- include normalized non-secret offer/product/plan/environment metadata;
- require a valid short-lived signed identity handoff before checkout creation;
- grant access only after an exact-body signature-verified Stripe webhook is normalized and accepted by Convex;
- process replays idempotently;
- make refund, revoke, dispute, or fraud transitions non-granting without deleting identity or audit history.

The checkout route and Convex commerce processor must reject or classify as `pending_review` every event whose provider is not exactly `stripe`. There is no runtime fallback order and no fallback checkout provider.

### Merchant account boundary

Map each product and offer to exactly one owning business before checkout. That business selects its own Stripe credentials, Price catalogue, webhook signing secret, operator recovery access, and financial reporting. A verified provider event must carry or resolve the business and merchant account provenance before it can change an entitlement. Scope receipt identity, purchase references, customer identities, retries, and recovery to that provenance and environment. An unknown or conflicting business/account binding is non-granting.

The signed suite handoff and the Convex entitlement ledger remain shared. Business-owned checkout and webhook adapters may reuse code and a normalized event contract; sharing code does not imply sharing a Stripe account or hosting every payment endpoint on CommandGlows. AppSumo licensing likewise uses the owning business's partner configuration and submits verified events to the shared entitlement ledger.

The existing CommandGlows-hosted checkout, single `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET`, and suite offer registry still include CommunityGlows. This is a transition gap, not evidence that a shared merchant account was approved. Do not activate a CommunityGlows direct sale through the CommandGlows merchant configuration. Migrate its checkout, webhook, and recovery path to its own business configuration before enabling that offer; preserve historical receipts and their original account provenance.

### Signed identity handoff

Every product client must obtain a short-lived, audience-bound, product-bound signed checkout handoff from the authenticated suite bridge. The checkout server verifies signature, expiry, audience, environment, offer/product compatibility, and replay constraints, then derives the canonical `globalUserId`. Raw client-provided user IDs and email-only matching are rejected. The opaque handoff itself is never copied into Stripe metadata or logs.

If a public marketing page cannot obtain authenticated handoff state, its CTA must lead into the product's authenticated purchase flow. A successful redirect is UX only and never payment or entitlement proof.

Each handoff contains a cryptographically random `jti` and expires after ten
minutes. The opaque token is accepted only in an encrypted POST body and must
never appear in a browser query URL, page markup, Stripe metadata, or logs.
Convex atomically claims a server-keyed hash of the `jti`, binds it to the exact
identity/product/offer/environment context, and returns one stable Stripe
idempotency key. Retries may recover the same Checkout Session, but cannot
create an independent session or reuse the token for a different context.

The additive `commerceCheckoutHandoffs` table stores only the keyed `jti` hash,
context, lifecycle state, expiry, idempotency key and final provider reference.
It requires no destructive migration, backfill, or deletion of historical data.

## Legacy And Clean-Reset Migration

The original 2026-08-11 no-user assumption enabled the initial clean reset. It is historical and must not be applied to current identities, orders, provider accounts, or immutable receipts. Any later merchant-account migration preserves existing evidence and access until each purchase is reconciled to its verified business/account provenance.

- Existing `product_default` rows remain as non-granting historical records or may be removed only through an explicitly reviewed data migration; no resolver may treat them as access.
- All automatic default-free writers and backfills are removed or disabled for every product.
- Existing Lemon Squeezy and Polar adapters, routes, offer mappings, environment keys, webhook handlers, runtime types, and active tests are removed from the active commerce path.
- Historical Lemon Squeezy/Polar docs and specs are retained as `superseded` provenance, not active guidance.
- Any Lemon Squeezy or Polar event reaching a compatibility boundary is rejected or recorded as non-granting `pending_review`; it cannot create or reactivate access.
- Provider identifiers are never translated as if APIs, signatures, customers, products, variants, subscriptions, or events were compatible with Stripe.
- Product-local entitlement tables may remain temporarily only as explicitly documented non-authoritative migration mirrors; they cannot grant protected access.

If any real user, order, subscription, or active provider record is discovered before deployment, stop the clean reset and create a migration amendment before changing hosted state.

## Client Obligations

### CommandGlows

- Display the registered 30-day cycle allowance; use the three-cycle default unless the product registry records an approved exception.
- Consume server `trialAttempt`, `trialRestartsRemaining`, and `trialRestartEligible` without recomputing eligibility locally.
- Hide or disable restart after attempt 3 and show purchase-only recovery.
- Require remote verified identity and a current granting snapshot for every protected route; local mode remains non-granting.
- Persist and send the product-scoped installation signal through the authenticated bridge.
- Start checkout only with the server-issued signed identity handoff; refresh Convex state after webhook fulfillment.

### CommunityGlows

- Grant one initial 30-day cycle and at most one eligible user-triggered restart, then require purchase after the second cycle expires.
- Display remaining restarts, restart success/refusal, expiry, exhaustion, and purchase-only recovery consistently on Windows and Android.
- Persist a random product-scoped installation identifier and send only the derived/pseudonymized signal expected by the bridge.
- Treat its Convex billing module as a suite adapter, not a local entitlement or payment authority.
- Start Stripe checkout with CommunityGlows business credentials after an authenticated signed handoff. Keep Stripe secrets out of clients; route its verified webhook to the shared entitlement ledger with explicit business and account provenance.
- Preserve bounded recovery/grace behavior without allowing stale state to create new access.

Every future product must satisfy these same obligations before it can be considered entitlement-ready. Product-specific prices, plans, device limits, and feature quotas may differ. The 30-day duration, no-freemium rule, provider allowlist, identity boundary, and fail-closed semantics do not; cycle limits use the suite defaults unless an explicit exception is approved and recorded.

## Sequential Execution Batches

Execution remains sequential because the same central policy, bridge, commerce registry, tests, and docs are touched across products. Parallel work is allowed only when the integrator first declares disjoint file ownership and proves that the branches do not modify shared contracts.

1. **Canonical trial authority** — introduce the generic product policy, remove default-free granting semantics, preserve paid precedence, and expose the shared snapshot contract.
2. **CommandGlows client** — migrate 14-day behavior and copy to 30 days while preserving route gating, installation continuity, restart UX, and signed purchase handoff.
3. **CommunityGlows bridge and clients** — enforce at most one eligible restart under the product-specific two-cycle cap, with installation signal, shared snapshot fields, fail-closed UI, and authenticated purchase handoff.
4. **Stripe-only commerce** — migrate all active offers to environment-backed Stripe Price IDs, enforce provider allowlists, and remove active Lemon Squeezy/Polar paths.
5. **Legacy cleanup and docs** — make all `product_default` and non-Stripe inputs non-granting, mark old decisions superseded, and align maps/trackers/public claims where implementation has changed.
6. **Local verification** — run the acceptance matrix below and repair local failures before requesting hosted proof.

Do not split batches 1 and 4 across concurrent agents: both own central authorization and commerce contracts. Product-client batches 2 and 3 may run in parallel only after batch 1 is stable and their file ownership is explicitly disjoint.

### Merchant-account correction after the original batches

1. Record the existing Stripe account owned by each business; never infer ownership from a Price ID name or a suite product ID.
2. Stop offering CommunityGlows checkout through the CommandGlows merchant configuration. Preserve its signed handoff and existing purchase history.
3. Provide CommunityGlows-owned checkout, signed webhook verification, and provider recovery. Keep the shared entitlement writer as the only access authority.
4. Include verified business/account provenance in new commerce receipts, customer matching, replay keys, purchase binding, and recovery. Reconcile historical receipts explicitly instead of rewriting them.
5. Prove wrong-account rejection and each business's purchase/refund/recovery flow locally, then verify the hosted provider binding separately before activating direct sales.

## Local Acceptance Matrix

The implementation is locally ready only when automated tests prove, for at least CommandGlows and CommunityGlows and at the generic policy layer:

- a verified identity and new installation receive exactly one 30-day cycle;
- a repeated start/restart is idempotent;
- the suite default permits two restarts, while CommunityGlows permits exactly one;
- CommunityGlows denies a third cycle and `trialRestartEligible=false`; default-policy products deny a fourth;
- each product's maximum cumulative allowance follows the registered cycle limit without overlapping extension;
- reinstall or alternate email on a recognized installation does not reset allowance;
- identity continuity on another installation preserves dates and attempt count;
- every legacy `product_default` is non-granting for every product;
- absent/malformed/stale entitlement fails closed on protected routes;
- a signed Stripe paid event grants the correct product/plan once;
- refund/dispute/revoke makes paid access non-granting without restoring trial allowance;
- a non-Stripe provider or unknown offer/product/plan is rejected or `pending_review` and never grants access;
- checkout requires a valid signed identity handoff and an environment-backed Price ID;
- a CommandGlows credential cannot create or recover a CommunityGlows checkout, and the inverse is also rejected;
- verified webhook events, receipt identity, customer references, and recovery remain isolated by business, merchant account, and environment;
- the success redirect alone never unlocks access;
- CommandGlows and CommunityGlows clients show correct 30-day/restart/exhausted/purchase states;
- metadata lint and `git diff --check` pass in all touched repositories.

Expected local commands are the repository-supported focused bridge/commerce/unit suites, CommandGlows Flutter analysis/tests, CommunityGlows billing/composable/type checks, site builds, metadata lint on changed governance artifacts, and diff checks. No Android build is required in this documentation/readiness phase.

## Excluded Proof For This Chantier

This documentation-only chantier does not execute or claim:

- deployment or hosted Convex verification;
- Stripe account, Product, Price, coupon, webhook, tax-code, or Managed Payments configuration;
- test-mode or live purchase/refund/dispute proof;
- provider/account migration;
- Windows, Android, browser, reinstall, or alternate-email device proof;
- commit, push, release, or production mutation.

Current Stripe eligibility, API version, Managed Payments availability, pricing, webhook events, and terms must be rechecked against official sources immediately before provider implementation or hosted proof. This spec records the operator's provider policy; it does not claim current provider/account readiness.

## Stop Conditions

Stop implementation and request an operator decision if:

- a required Stripe offer has no approved internal offer/product/plan mapping or environment Price ID key;
- a price amount would need to be invented;
- real users, orders, subscriptions, or hosted entitlements are discovered;
- Stripe Managed Payments is unavailable or ineligible for the target product/country;
- a platform store mandates a payment path that conflicts with Stripe-only direct checkout;
- a proposed anti-abuse mechanism needs raw IP retention, hardware fingerprinting, or irreversible network blocking;
- a product requests permanent free access or a different trial/provider contract.

## Acceptance Criteria

- [x] One canonical active spec defines the suite contract and supersedes product-specific exceptions.
- [x] The central Convex authority, fail-closed behavior, generic trial policy, anti-abuse inputs, Stripe-only allowlist, signed identity handoff, migration behavior, client obligations, sequential batches, local tests, and proof exclusions are explicit.
- [x] Pricing amounts remain undefined and Price IDs are environment-backed.
- [x] Runtime code implements the contract for all current products.
- [x] Local acceptance tests pass after implementation.
- [ ] Hosted/provider/account/device proof is completed in a later authorized chantier.

## Current Chantier Flow

- 2026-09-06 central commerce tranche: locally verified in CommandGlows worktree `codex/unified-commerce-entitlements`, based on revalidated `9016d47`; one processor, completed checkout/PaymentIntent binding, strict environment isolation, immutable receipts and internal audited recovery.
- Current authority: on 2026-09-25 the operator confirmed there are no customers or payment history to retain. This supersedes the earlier history-preservation constraint for payment schema and compatibility code. Concurrent unrelated work remains protected. Hosted data deletion is outside the local adapter change.
- Proof: baseline 20 tests; final tranche 151 tests across 18 commerce/bridge suites, Convex TypeScript and Astro check. Canonical implementation/runbook: CommandGlows `shipglows_data/technical/payment-activation-entitlements.md`.
- Remaining suite scope: transverse identity/recovery, AppSumo, CommunityGlows Windows, mirrors and portfolio adapters. No hosted/provider/native proof is implied. Deployment and real provider data were explicitly excluded for this tranche; delivery remains local.

- sg-docs: canonical decision chain reconciled and specification ready
- implementation batch A: common 30-day/three-cycle trial authority and fail-closed clients implemented locally
- implementation batch B: Stripe-only commerce, CommunityGlows and Formation offers, signed checkout handoff, legacy provider runtime removal, and non-Stripe rejection implemented locally
- implementation batch C: CommunityGlows adapter, pseudonymized installation signal, two-restart/exhaustion UI, authenticated server-side checkout start, public app handoff CTA, active runtime cleanup, tests, and docs implemented locally
- local verification: CommunityGlows focused billing/composable/installation/deep-link/UI tests, core and Convex typechecks, site build, changed-doc metadata lint, active-runtime scan, and diff check passed; full hosted/provider/device proof remains pending
- final correction batch: all eight registered products reach the common trial writer; Formation rejects expired trials; checkout handoffs use random ten-minute `jti` values, Convex one-time claims and Stripe idempotency; Founder/app flows keep tokens out of URLs; CommunityGlows signals receive server-keyed HMAC; active IDs, branding and CSP are aligned
- hosted/provider/account/device proof: explicitly deferred

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-11 | sg-docs | GPT-5 Codex | Consolidated all current/future products onto one 30-day × three-cycle entitlement contract and Stripe Managed Payments-only commerce policy; preserved prior CommandGlows, CommunityGlows, Lemon Squeezy, Polar, and default-free decisions as superseded history. | ready | Implement sequential batches 1–6 without inventing prices; defer hosted/provider/account/device proof. |
| 2026-10-02 | 601-sg-product-entitlements | GPT-6 Codex | Recorded CommunityGlows as an approved two-cycle/one-restart exception while preserving the three-cycle suite default for all other products. | ready | Apply the policy to the central product registry and CommunityGlows snapshots; deployment remains separate. |
| 2026-08-11 | 001-sg-build / sg-development | GPT-5 Codex | Implemented batch B: Stripe-only provider types/registry/checkout, CommunityGlows and Formation Stripe Price-ID placeholders, Clerk-backed Formation/public purchase start, product/environment-bound signed handoff for every offer, central Stripe webhook coverage, Convex non-Stripe rejection, removal of active Lemon Squeezy/Polar routes/adapters/tests/dependency, and directly coupled docs. | implemented | Complete CommunityGlows client batch, then run the final cross-repo acceptance matrix; hosted/provider/account/device proof remains deferred. |
| 2026-08-11 | 001-sg-build / sg-development + sg-docs | GPT-5 Codex | Implemented batch C in CommunityGlows: server-propagated trial counters and explicit exhaustion, authenticated restart, random installation ID with client-side pseudonymized signal, fail-closed app gate, restart/purchase UI, server-held checkout handoff with Stripe URL-only response, authenticated public purchase deep link, local legacy-provider schema cleanup, tests, and active documentation synchronization. | implemented | Configure approved Stripe Price IDs and run hosted Stripe/Convex plus Windows/Android proof in a later authorized chantier. |
| 2026-08-11 | sg-engineering + sg-docs | GPT-5 Codex | Closed the five final-review findings: generic eight-product trial entrypoint and Formation expiry guard; one-time/idempotent Stripe handoff authority; POST-only token transport; server-keyed CommunityGlows signal pseudonymization; active IDs, branding and CSP cleanup; focused and full local proof. | implemented | Keep hosted Stripe/Convex, provider-account and device proof deferred until separately authorized. |
| 2026-09-06 18:22:11 UTC | sg-development | GPT-6 | Revalidated 9016d47, unified central and CommunityGlows commerce processors, bound completed checkout to signed PaymentIntent, hardened environment and historical-reference isolation, added immutable receipts and bounded internal pending-review recovery. Preserved historical records and concurrent work; updated the CommandGlows runbook and tracker. | locally verified | Continue the remaining suite batches separately; no deployment or real provider data authorized in this tranche. |
| 2026-09-10 17:55:00 UTC | sg-development | GPT-5 Codex | Added local AppSumo fulfillment foundation: signed protocol parser, OAuth exchange helper, durable Convex license state, server-only entitlement activation for mapped owner/product offers, non-granting tests/purchases and license replacement/revocation coverage. | locally verified | Build public webhook/OAuth routes, tier configuration and hosted provider reconciliation before claiming AppSumo sale readiness. |
| 2026-09-10 22:55:00 UTC | sg-docs | GPT-5 Codex | Linked the active contract to the entitlement doctrine and the suite commerce, Stripe and AppSumo operational playbooks. | updated | Use the playbook layer for future provider launch execution. |
