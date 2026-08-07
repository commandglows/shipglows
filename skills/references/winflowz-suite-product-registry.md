---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-08-06"
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
  - /home/claude/winflowz/winflowz_site/convex/defaultFreeEntitlements.ts
  - /home/claude/winflowz/winflowz_site/src/lib/suiteBridge.ts
depends_on:
  - artifact: "skills/references/product-entitlements-playbook.md"
    required_status: active
supersedes: []
evidence:
  - "2026-06-12 conversation: Diane decided free access should be auto-created for all current/future suite products at account creation."
  - "2026-06-12 Convex production deployment prod:elegant-mule-677 added default free entitlements and backfilled existing accounts."
  - "2026-06-12 Diane clarified winflowz_android is the same product as winflowz_app, not a separate product_id."
  - "2026-08-06 operator decision: CommandGlows App uses trial_then_paid with one 14-day trial and at most two additional 14-day reactivations; permanent free access is not the default for future paid products."
next_review: "2026-09-06"
next_step: "/103-sg-verify winflowz suite product registry"
---

# WinFlowz Suite Product Registry

Use this reference whenever a task mentions WinFlowz suite products, free products, default access, account-backed sync, product entitlements, cloud sync eligibility, or future products operated by Diane.

## Canonical Rule

Each suite product must declare its commercial access policy before its runtime
creates an entitlement. Account creation or identity bridging proves identity;
it does not automatically create a permanent free entitlement for a product
whose policy is `trial_then_paid` or `paid_only`.

Default free access writes use:

- `plan`: `free`
- `status`: `active`
- `source`: `product_default`
- `environment`: the active runtime environment

Authentication still proves identity only. The entitlement ledger remains the access source of truth.

## Current Default-Free Products

Current canonical `product_id` values that should receive default free access:

- `winflowz_app`
- `winflowz_formation`
- `gocharbon`
- `contentglowz`
- `shipglows`
- `replayglowz`
- `socialglowz`
- `temu_shopping_lists`

These entries remain default-free only until their product-specific commercial
policy is explicitly changed. They are not a universal default for future
products.

## Commercial Access Policies

The suite supports these product-level policies:

- `free`: permanent free access, with optional paid upgrades.
- `trial_then_paid`: a server-owned trial followed by a paid unlock; no
  permanent free entitlement after the trial allowance is exhausted.
- `paid_only`: no product trial unless explicitly granted by an offer or
  support action.
- `subscription`: recurring paid access with provider-driven renewal and
  expiry semantics.

For `trial_then_paid`, the canonical default is:

- 14 days for the initial trial;
- at most two additional 14-day reactivations;
- at most 42 trial days in total;
- eligibility counted server-side by global identity and recognized app
  installation, not by email address alone;
- IP address used only as a privacy-aware anti-abuse signal and rate-limit
  input, never as the sole access identity;
- after the allowance is exhausted, access requires a paid entitlement;
- a refund, revoke, or fraud decision removes access through the canonical
  ledger and does not recreate a trial.

CommandGlows App (`commandglows_app`) is the first suite product assigned the
`trial_then_paid` policy. Other products may reuse this policy only after their
own sales promise, cost model, and product registry entry are updated.

## Alias And Exclusion Notes

- `winflowz_android` is not a separate entitlement product. Treat it as the Android surface of `winflowz_app`.
- Do not create new durable `product_id` aliases for marketing names, platform names, provider product ids, or app-store ids. Normalize them to the canonical internal product id first.
- External provider ids remain references only. They never replace `product_id`.
- If a future product has a free module, free preview, free quota, or free sync
  tier, declare that scope explicitly in the suite ledger policy before
  building product-local gates. Do not infer permanent free access from the
  existence of an account.

## Source Of Truth

Runtime source of truth:

- `/home/claude/winflowz/winflowz_site/convex/defaultFreeEntitlements.ts`

Site/helper mirror:

- `/home/claude/winflowz/winflowz_site/src/lib/suiteBridge.ts`

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
- a paid entitlement could be overwritten by a default free grant;
- a free formation entitlement is treated as premium/private course access without an explicit premium plan gate.
