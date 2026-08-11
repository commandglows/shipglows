---
name: 601-sg-product-entitlements
description: "Design product entitlements, provider events, and sync handoffs."
argument-hint: <project or feature with access, plans, provider events, or support questions>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`.

If a unique ready spec is attached, append the run row to `Skill Run History` and update `Current Chantier Flow` in that spec before reporting. Use the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent` only when a handoff requires extra evidence or unblockers.

## Required References

Load only the references needed for the active mode:

- `skills/references/decision-quality-contract.md` before ownership and proof choices.
- `skills/references/product-entitlements-playbook.md` as the primary doctrine.
- `skills/references/winflowz-suite-product-registry.md` when the task mentions WinFlowz suite products, free products, default access, sync eligibility, or future products operated by Diane.
- `skills/references/spec-driven-development-discipline.md` before non-trivial output.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` when provider/webhook/API behavior affects entitlement state.
- `skills/references/chantier-tracking.md` for lifecycle trace updates.

## Mission

`601-sg-product-entitlements` is the ShipGlows domain skill for product access lifecycle and authorization design.

It should separate:

- identity (who),
- provider events (what happened),
- product entitlements (what is currently authorized),
- and product-local mirrors (availability optimization only).

The skill routes to implementation and proof owners instead of owning product sync or auth debugging internals.

## Mode Detection

Parse `$ARGUMENTS` as an entitlement intent:

| Intent | Route |
| --- | --- |
| Read-only access-contract or gap review | Produce an entitlement contract, risk check, and stop conditions |
| Provider event / manual grant / LTD / activation-code work | Require `skills/references/product-entitlements-playbook.md`, idempotent event model, and status semantics |
| Backend guard, premium access, quota, or premium data-protection questions | Output required server-side authorization checks and deny-by-default conditions |
| Product-local snapshot/mirror/cache design | Require TTL, refresh, fail-closed semantics, and explicit source-of-truth boundary |
| Support runbook planning | Require redacted lookup/lookup-then-change, grant/revoke/refund behavior, and retention notes |
| Sync-oriented questions touching hydration/promote/reinstall recovery | Route entitlement preconditions to `600-sg-local-cloud-sync` |
| Auth/callback/session/cookie/provider identity issues | Route to `109-sg-auth-debug` |
| New implementation path requiring project-level spec | Route `100-sg-spec -> 101-sg-ready -> 102-sg-start/001-sg-build` |

## Entitlement Contract Core

For all non-debug, non-auth flows, load `skills/references/product-entitlements-playbook.md` and enforce these defaults:

- Authentication proves identity only; it must not grant product access.
- External providers and marketplaces are event sources, not runtime authorization sources.
- For suite products, prefer the canonical suite entitlement ledger; add product_id/product surface as extension, not second durable ledger.
- For WinFlowz suite products, load the WinFlowz suite product registry before deciding default-free product ids or aliases.
- Any durable access write must use normalized `product_id`, `plan_id`, `source`, and `environment`.
- Access is active only when status maps to grant semantics (`active`, `trialing`, etc. mapped explicitly).
- Store raw claims, localStorage, cookies, and client payloads as non-authoritative access signals.
- Product-local states are mirror/cache/adapter/compatibility only until sync contracts are validated against entitlement ownership.

## Core Gates

- Fail closed when identity, entitlement lookup, provider verification, mirror refresh, or namespace checks are unavailable or malformed.
- Duplicate durable entitlements for a suite-ledger product are blocked unless a standalone exception is explicitly documented.
- Provider events require signature/token verification, idempotency, environment/product allowlists, replay rejection, and non-active fallback behavior.
- Activation or redemption codes are treated as bearer credentials: no raw logging, no raw client persistence, idempotent server-side handling, support-safe lookup only.
- Product-local snapshots/mirrors require refresh/TTL, revocation propagation, and no active access on stale source-of-truth divergence.
- Support runbooks must include safe user lookup, grant/revoke/refund/expiry flows, duplicate-account paths, and redaction.

## Routing and Handoffs

- `109-sg-auth-debug` for OAuth/session/callback/token/session anomalies and provider identity failures.
- `600-sg-local-cloud-sync` after entitlement preconditions are explicit, for data promotion, hydration, merge, conflict, tombstones, offline queue, and reinstall-recovery.
- `100-sg-spec` when behavior changes need durable implementation scope.
- `101-sg-ready` for non-trivial ready-state transition.
- `102-sg-start` or `001-sg-build` for execution planning and implementation.
- `103-sg-verify` after contract or implementation work.
- `405-sg-prod` and `107-sg-test` for deployment and manual proof after implementation.
- `300-sg-docs` when claims, support docs, workflow guides, or technical claims drift.

## Stop Conditions

Stop and return routed/fenced work when any condition is true:

- identity and entitlement are being conflated,
- duplicate durable ledger is introduced for an existing suite product,
- provider signatures/webhook semantics are required but freshness is unresolved,
- product-local mirrors can remain active after revoke/refund/expiry,
- sensitive values (codes, claims, raw webhook payloads, cookies, provider secrets) are proposed to be logged or persisted unsafely.

## Proof Path

`scenario-first` with mechanical checks first.

Validate required scenarios `SPE-001` to `SPE-010` by ensuring the contract and routing language explicitly covers:

- suite-ledger adaptation,
- standalone minimal model,
- identity-only/claims-only denial,
- provider event safety,
- activation-code handling,
- mirror fail-closed behavior,
- backend gate checks,
- entitlement-gated sync routing,
- auth/session routing,
- support runbook coverage.

## Validation

Run targeted checks for this contract:

```bash
SHIPGLOWS_ROOT="${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}"
rg -n "product-entitlements|product_entitlements|suite ledger|provider event|activation code|snapshot|mirror|backend authorization|600-sg-local-cloud-sync|109-sg-auth-debug|scenario-first" "$SHIPGLOWS_ROOT/skills/601-sg-product-entitlements/SKILL.md"
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill 601-sg-product-entitlements
tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/601-sg-product-entitlements-skill.md "${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}/technical"
git diff --check
```

## Final Report

Use compact user-mode structure:

- `Result: [implemented / partial / blocked / rerouted]`
- `Route: [contract / audit / routed / blocked]`
- `Proof path: scenario-first`
- `Documentation Update Plan`: `complete` / `no impact` / `blocked`
- `Editorial Update Plan`: `complete` / `no editorial impact` / `blocked`
- `Security`: `pass` / `blocked`
- `Chantier` compact block from reporting contract
