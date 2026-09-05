---
name: 601-sg-product-entitlements
description: "Design entitlement, provider-event, mirror, and support contracts."
argument-hint: <project, access flow, provider event, activation code, premium gate, or support question>
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project artifacts resolve from the current project root.

## Chantier And Report Modes

Trace category: `conditionnel`. Process role: `source-de-chantier`.

Attach only to one unique spec and apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`; otherwise use `(local)`. Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before reporting. Default to compact `report=user`; evidence-heavy handoff uses `report=agent`.

## Mission And Boundary

`601-sg-product-entitlements` owns product-access lifecycle and authorization design. Keep identity (who), provider events (what happened), durable entitlement (what is authorized), and product-local mirror/cache (availability optimization) distinct.

Route sync/hydration/promotion/reinstall recovery to `600`; OAuth/session/callback/cookie/provider identity failure to `109`; behavior-changing implementation through `100 -> 101 -> 102/001`; final proof to `103`, deployment/manual proof to `405`/`107`, and affected docs/claims to `300`.

## Mode And Progressive Authorities

Accept read-only contract/audit, provider/manual grant/LTD/activation code, backend premium guard/quota, local mirror/cache, trial-transition UX, support runbook, sync precondition, auth debug, or implementation intent.

The accounting profile lives in `skill-invocation-registry.json`; runtime loaders here remain authoritative.

- Before an ownership/proof choice, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`.
- Once entitlement work is selected, load `$SHIPGLOWS_ROOT/skills/references/product-entitlements-playbook.md` as primary doctrine.
- After the primary doctrine selects the next concern, load exactly one direct branch: `product-entitlement-ledger-and-authorization.md`, `product-entitlement-ingestion.md`, or `product-entitlement-support-and-proof.md`. Branches never chain.
- WinFlowz suite/free/default-access/sync eligibility loads `$SHIPGLOWS_ROOT/skills/references/winflowz-suite-product-registry.md`.
- Non-trivial behavior change loads `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` before output or mutation.
- Current provider/webhook/API semantics load `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` and official sources.
- When access work crosses identity linking, consent or central email, load `$SHIPGLOWS_ROOT/skills/references/identity-consent-access-contract.md`; unrelated entitlement work does not activate email/provider playbooks. Actual Auth0 diagnosis remains owned by `109`.

Load at most one entitlement doctrine before the first substantive action; load a branch only after the primary doctrine has selected it.

## Activation-Critical Entitlement Gates

- Authentication proves identity only; it never grants product access.
- Providers/marketplaces are event sources, not runtime authorization sources.
- Prefer one canonical suite ledger; product-local state is cache/mirror/adapter/compatibility only.
- Durable writes normalize product, plan, source, environment, status, and ownership.
- Fail closed on missing/malformed identity, lookup, provider verification, mirror refresh, or namespace checks.
- Provider events require verification, idempotency, environment/product allowlists, replay rejection, and non-active fallback.
- Activation/redemption codes are bearer credentials: never raw-log or persist them client-side.
- Mirrors require TTL/refresh and revocation/refund/expiry propagation; stale divergence never remains active.
- Backend/provider authorization owns premium reads/writes; UI and client claims are non-authoritative.
- Trial-transition UX preserves pre-expiry calm, progressive clarity, data truth, valid restart/recovery actions, evidenced value showcases, governed offer terms, and non-coercive founder voice.

## Stop Conditions

Stop or reroute when identity and entitlement are conflated; a duplicate durable ledger is proposed; provider truth is stale; mirror/cache can stay active after revoke/refund/expiry; tenant/product/environment ownership is unclear; raw codes, claims, webhooks, cookies, or secrets would be logged; backend authorization is absent; or implementation lacks a ready contract.

## Proof And Report Boundary

Use scenario-first proof covering suite adaptation, standalone model, identity/claims denial, provider safety, code handling, mirror fail-closed behavior, backend gates, sync/auth routing, support grant/revoke/refund/expiry paths, and the complete trial-transition journey. The authorization scenario family remains `SPE-001` through `SPE-010`; trial-transition UX uses `TEX-001` through `TEX-010` in the support-and-proof branch.

Report result, route, proof limit, and documentation status. Never claim access correctness from UI state, local claims, or an unverified provider event.

## Validation

Run `tools/test_601_sg_product_entitlements_compaction_contract.py`, activation-profile and engineering-owner consumers, metadata, fidelity, budget, and runtime sync.
