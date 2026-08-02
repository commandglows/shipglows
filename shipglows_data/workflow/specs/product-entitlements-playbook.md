---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-29"
updated: "2026-05-29"
status: ready
source_skill: sg-build
scope: product-entitlements-playbook
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
user_story: "En tant qu'operatrice ShipGlows, je veux un playbook transverse pour les entitlements produit, afin que SocialGlowz, WinFlowz et les futurs projets ne confondent jamais compte utilisateur, paiement provider et acces produit."
linked_systems:
  - skills/references/product-entitlements-playbook.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "WinFlowz suite-authentication docs establish the doctrine: identity is not product access; server-owned entitlements are the source of truth."
  - "SocialGlowz billing implementation exposed reusable LTD/direct/partner redemption needs that should not stay project-local."
next_step: "/sg-start product-entitlements-playbook"
---

# Product Entitlements Playbook

## Intent

Create a reusable ShipGlows reference for product access, billing-provider boundaries, Lifetime Deal redemption, manual grants, refunds, revocations, support triage, and smoke-test proof.

## Scope

- Extract the reusable doctrine from WinFlowz suite authentication and SocialGlowz Lifetime Deal implementation.
- Define the minimum durable data model for product entitlements.
- Define canonical status/source semantics.
- Define provider-agnostic redemption and webhook rules.
- Define fail-closed backend and UI behavior.
- Define smoke tests and docs/update triggers.

## Out of Scope

- Provider-specific current API details for AppSumo, Polar, Stripe, Paddle, Lemon Squeezy, Google Play, or App Store.
- Tax, accounting, invoices, dunning, and revenue recognition.
- A new runtime skill command.

## Acceptance Criteria

- `skills/references/product-entitlements-playbook.md` exists with frontmatter and active status.
- The playbook states that identity, payment provider records, and product access are separate layers.
- The playbook covers Lifetime Deal/direct/early-bird/partner codes without requiring marketplace branding in UI.
- The playbook defines statuses, sources, event idempotency, revoke/refund behavior, support runbook expectations, and smoke proof.
- The lifecycle technical doc references the playbook so future agents can discover it.
- Validation confirms metadata and no accidental project edits are staged.

## Current Chantier Flow

sg-spec ✅ -> sg-ready ✅ -> sg-start ✅ -> sg-verify ✅ -> sg-end ✅ -> sg-ship ✅🎯

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-29 23:39:28 UTC | sg-build | GPT-5 Codex | Created ready spec for a reusable ShipGlows product entitlements playbook. | implemented | `/sg-start product-entitlements-playbook` |
| 2026-05-29 23:40:53 UTC | sg-build | GPT-5 Codex | Implemented shared product entitlements playbook and linked it from the ShipGlows runtime/lifecycle technical reference. | implemented | `/sg-verify product-entitlements-playbook` |
| 2026-05-29 23:41:42 UTC | sg-build | GPT-5 Codex | Verified metadata lint, diff hygiene, and marketplace wording boundaries for the playbook. | implemented | `/sg-ship product-entitlements-playbook` |
| 2026-05-29 23:41:42 UTC | sg-end | GPT-5 Codex | Closed playbook documentation chantier with reference and technical lifecycle discoverability aligned. | closed | `/sg-ship product-entitlements-playbook` |
| 2026-05-29 23:41:54 UTC | sg-ship | GPT-5 Codex | Prepared bounded ship for the product entitlements playbook reference and spec. | shipped | `Adopt playbook in future billing/entitlement chantiers` |
