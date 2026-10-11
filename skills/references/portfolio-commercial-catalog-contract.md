---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-08-18"
status: active
source_skill: 601-sg-product-entitlements
scope: portfolio-commercial-catalog
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/references/winflowz-suite-product-registry.md
  - skills/references/product-access-and-license-ui-contract.md
  - shipglows_data/business/portfolio-commercial-catalog.json
depends_on:
  - artifact: skills/references/product-entitlements-playbook.md
    artifact_version: "2.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-18: normalize every primary portfolio project and connect its decided or explicitly undecided commercial truth to entitlements and reusable customer UI."
next_review: "2026-11-18"
next_step: none
---

# Portfolio Commercial Catalog Contract

## Purpose And Ownership

Use this contract whenever work creates, changes, displays, sells, gates, or audits a product, offer, plan, feature, quota, activation allowance, license term, price, or provider mapping.

- Each primary repository owns exactly one project-local catalog at `shipglows_data/business/commercial-offer-catalog.md`.
- The project-local catalog owns commercial intent, public meaning, decision status, and provenance.
- The suite registry owns canonical `product_id` values, aliases, and shared entitlement policy; it does not invent product-specific offers or prices.
- Active runtime registries implement mappings and must agree with decided catalog fields. Runtime presence alone does not approve price or public copy.
- The entitlement ledger owns current access. Provider objects, checkout redirects, catalogs, caches, and UI never authorize access.
- Customer UI consumes a server-resolved model whose labels and explanations map to the owning catalog.

The central portfolio index locates catalogs and exposes coverage only. It must not become a duplicate commercial authority.

## Required Authority States

Use one explicit state; absence never selects a default:

- `decided`: operator-approved commercial truth;
- `implemented`: decided mapping present in active runtime code, without implying hosted/provider readiness;
- `planned`: intended but not yet implemented or publicly claimable;
- `undecided`: operator-owned choice remains open;
- `not_monetized`: deliberately no paid offer now;
- `transactional_not_entitlement`: per-order goods/services rather than reusable access;
- `surface_of`: repository consumes another product's catalog and cannot duplicate ownership;
- `historical`: provenance only;
- `missing_authority`: registered product has no owning project catalog and is non-sellable.

Every missing price, quota, feature matrix, device allowance, provider, or term remains `undecided` or `not_applicable`. Missing never means free, unlimited, active, included, or approved.

## Required Project Catalog Shape

The Markdown document contains one machine-readable JSON block between `commercial-catalog:start` and `commercial-catalog:end`. It records:

- schema version, repository key, authority status, catalog owner, entitlement participation, and optional `surfaceOf`;
- canonical products and lookup-only aliases;
- offers with stable `offerId`, `productId`, `planId`, public label, status, term, price status, feature status/keys, quotas, activation policy, provider status, and provenance;
- active decision sources, historical sources, and unresolved decisions.

Product IDs, plan IDs, provider IDs, offer IDs, and feature keys are machine identifiers. Customer labels remain separate and localizable. A marketing label cannot become an authorization key.

## Source Priority And Conflict Handling

Use this priority when sources disagree:

1. current explicit operator decision in the project-local catalog;
2. current project business/product contract named as an active decision source;
3. approved technical offer mapping for implemented identifiers and limits;
4. public copy only as evidence to reconcile, never as silent authority;
5. historical audits/specs for provenance only.

Do not silently choose between conflicting sources. Preserve the implemented truth needed for compatibility, mark the commercial decision unresolved, name both sources, and block new public/provider claims until reconciled.

## Portfolio Coverage

- A suite-registered product resolves to exactly one project-local catalog or one central `missing_authority` entry.
- A repository may be `not_registered`, `excluded`, or `surface_only` without receiving a fabricated suite product ID.
- A display or legacy alias never creates a second canonical product.
- Central-only products are non-sellable until a project owner and catalog exist.
- Worktrees, previews, archives, generated evidence, and migration snapshots never receive active catalogs.

## Runtime, Entitlement, And UI Boundary

When a catalog field is `implemented`, validate the relevant runtime mapping. When it is merely `decided` or `planned`, do not claim runtime availability. Provider Price IDs remain secret environment configuration and are represented only by configured/not-configured state.

The backend resolves product, plan, status, term, features, quotas, activations, freshness, and allowed actions. The UI maps those resolved fields to catalog-governed customer language. UI may never infer a higher plan, compute a granting entitlement from price, or turn `undecided` into a fallback offer.

## Change Protocol

1. Update the owning project-local catalog when commercial meaning changes.
2. Update the central index only for location, ownership, registration, alias, or coverage changes.
3. Update runtime mappings only through a separately approved product-entitlement implementation.
4. Update public pricing/offer copy only when the catalog state permits the exact claim.
5. Review affected project catalogs, suite ownership, and runtime mappings after any product, plan, offer, alias, or ownership change.

A new product is not entitlement-ready until its project catalog, registry ownership, runtime adapter, backend guard, UI state, and proof route are all explicit.

## Pressure Scenarios

- `PCC-MISSING-PRODUCT`: registered product without a catalog remains `missing_authority`, non-sellable, and validation-visible.
- `PCC-HISTORICAL-ACTIVE`: historical pricing in active decision sources fails validation.
- `PCC-RUNTIME-DRIFT`: implemented offer/plan/activation fragments missing from runtime fail validation.
- `PCC-UNKNOWN-NOT-UNLIMITED`: unknown price/quota/activation cannot contain a value or render as free/unlimited.
- `PCC-ALIAS-COLLISION`: alias collision with canonical products fails validation.
- `PCC-SURFACE-OWNERSHIP`: a `surface_of` catalog owns zero products.
- `PCC-NON-ENTITLEMENT`: transactional menu/order pricing never creates a suite entitlement.

## Stop Conditions

Stop before inventing a price, plan, feature, quota, activation limit, provider, product ID, public availability, or approval. Stop when a historical document would become active authority, a product has multiple owners, runtime contradicts an implemented catalog, or a commercial mutation would be needed. Route commercial truth to the operator/project corpus, entitlement behavior to `601`, customer presentation to `006`, and public claims to the appropriate business/content owner.
