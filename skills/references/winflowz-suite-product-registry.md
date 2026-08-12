---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.1.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-08-11"
status: active
source_skill: 009-sg-skill-build
scope: winflowz-suite-product-registry
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/references/product-entitlements-playbook.md
  - /home/claude/commandglows/commandglows_site/convex/defaultFreeEntitlements.ts
  - /home/claude/commandglows/commandglows_site/src/lib/suiteBridge.ts
  - shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md
depends_on:
  - artifact: "skills/references/product-entitlements-playbook.md"
    required_status: active
supersedes: []
evidence:
  - "2026-06-12 conversation: Diane decided free access should be auto-created for all current/future suite products at account creation."
  - "2026-06-12 Convex production deployment prod:elegant-mule-677 added default free entitlements and backfilled existing accounts."
  - "2026-06-12 Diane clarified winflowz_android is the same product as winflowz_app, not a separate product_id."
  - "2026-08-06 operator decision: CommandGlows App uses trial_then_paid with one 14-day trial and at most two additional 14-day reactivations; permanent free access is not the default for future paid products."
  - "2026-08-11 operator decision superseding all prior exceptions: every current and future suite product uses three maximum 30-day trial cycles, then mandatory purchase, with no permanent free grants and Stripe Managed Payments only."
next_review: "2026-09-11"
next_step: "Implement and verify the unified policy across every current product registry entry and access resolver."
---

# Glows Suite Product Registry

Use this reference whenever a task mentions Glows suite products, trial/default
access, account-backed sync, product entitlements, cloud sync eligibility,
payments, or future products operated by Diane. The filename is retained for
compatibility; this document is the active suite-wide registry policy.

## Canonical Rule

Every current and future suite product uses the same `trial_then_paid` policy.
Account creation and identity bridging prove identity only; they never grant
permanent product access. Convex is the canonical entitlement authority.

## Current Product Registry

Known canonical product ids governed by the unified policy include:

- `commandglows_app`
- `commandglows_formation`
- `gocharbon`
- `contentglowz`
- `shipglows`
- `replayglowz`
- `communityglows`
- `temu_shopping_lists`

Legacy names are aliases for lookup and migration evidence only; they are not
canonical identifiers and cannot create a separate allowance. Every entry above and every future allowlisted product uses
the same trial and provider contract; none receives `product_default` access.

## Commercial Access Policy

The sole active suite policy is:

- 30 days for the initial server-owned trial cycle;
- at most two additional user-triggered 30-day restarts after expiry;
- at most three cycles or 90 trial days in total;
- eligibility counted server-side by global identity and recognized app
  installation, not by email address alone;
- IP address used only as a privacy-aware anti-abuse signal and rate-limit
  input, never as the sole access identity;
- after the allowance is exhausted, access requires a paid entitlement;
- a refund, revoke, or fraud decision removes access through the canonical
  ledger and does not recreate or reset a trial;
- no permanent freemium, default-free grant, or product-specific trial duration;
- Stripe Managed Payments is the only active direct-payment provider.

Offer prices and plans may differ by product. Their Stripe Price IDs are
allowlisted server environment values; this registry never defines or invents
price amounts. Missing offer configuration fails closed.

The prior default-free suite rule, CommandGlows 14-day/42-day rule,
CommunityGlows single-cycle rule, and Lemon Squeezy/Polar provider exceptions
are superseded history.

## Alias And Exclusion Notes

- `winflowz_android` and `winflowz_app` are historical aliases for the CommandGlows app surface. Normalize them to `commandglows_app`; neither creates a separate entitlement product.
- `winflowz_formation` is a historical alias for `commandglows_formation`.
- `socialglowz` is a historical alias for `communityglows`.
- Do not create new durable `product_id` aliases for marketing names, platform names, provider product ids, or app-store ids. Normalize them to the canonical internal product id first.
- External provider ids remain references only. They never replace `product_id`.
- A free public preview or unauthenticated marketing/demo surface may exist
  only outside protected product access. It must not create an entitlement,
  reset trial allowance, or become an implicit free product tier.

## Source Of Truth

Runtime source of truth:

- `/home/claude/commandglows/commandglows_site/convex/defaultFreeEntitlements.ts`

Site/helper mirror:

- `/home/claude/commandglows/commandglows_site/src/lib/suiteBridge.ts`

Canonical policy/specification:

- `/home/claude/shipglows/shipglows_data/workflow/specs/unified-suite-commercial-entitlement-and-stripe.md`

When this registry and runtime code disagree, do not guess. Inspect the code, identify the drift, and route the correction through `601-sg-product-entitlements` or `900-shipglows-core build` depending on whether the product behavior or the skill documentation is wrong.

## Skill Routing

- Product access, default grants, plan gates, paid/free semantics, provider events, refunds, revokes, support access, or canonical product ids: route to `601-sg-product-entitlements`.
- Sync, hydration, local-to-cloud promotion, reinstall recovery, or "why are my data local only?": load this reference, then route entitlement preconditions to `601-sg-product-entitlements` before the sync contract in `600-sg-local-cloud-sync`.
- Skill memory, registry drift, or future-agent context loss: route to `900-shipglows-core build`.

## Stop Conditions

Stop and route before implementation when:

- a new product id would duplicate an existing product surface;
- a product-local ledger is proposed while the suite ledger can own access;
- a client claim, cookie, local storage value, or provider payload is treated as durable access truth;
- a paid entitlement could be overwritten or bypassed by a trial/default grant;
- a free formation entitlement is treated as premium/private course access without an explicit premium plan gate.
- a product proposes a provider other than Stripe or a trial contract other
  than 30 days plus two maximum restarts;
- a price amount would need to be invented instead of supplied through an
  approved Stripe Price ID environment key.
