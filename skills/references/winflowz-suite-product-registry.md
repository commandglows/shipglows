---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-12"
updated: "2026-06-12"
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
next_review: "2026-07-12"
next_step: "/103-sg-verify winflowz suite product registry"
---

# WinFlowz Suite Product Registry

Use this reference whenever a task mentions WinFlowz suite products, free products, default access, account-backed sync, product entitlements, cloud sync eligibility, or future products operated by Diane.

## Canonical Rule

For WinFlowz suite products, account creation or first identity bridge should auto-create free access unless a later explicit product decision says otherwise.

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

## Alias And Exclusion Notes

- `winflowz_android` is not a separate entitlement product. Treat it as the Android surface of `winflowz_app`.
- Do not create new durable `product_id` aliases for marketing names, platform names, provider product ids, or app-store ids. Normalize them to the canonical internal product id first.
- External provider ids remain references only. They never replace `product_id`.
- If a future product has a free module, free preview, free quota, or free sync tier, add its canonical product id to the suite ledger policy before building product-local gates.

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
