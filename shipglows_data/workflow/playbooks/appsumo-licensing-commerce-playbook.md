---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-09-11"
updated: "2026-09-28"
status: draft
source_skill: 900-shipglows-core
scope: appsumo-licensing-commerce
owner: ShipGlows maintainers
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/digital-product-commerce-launch-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Generalized on 2026-09-28 for teams selling software through an external licensing channel."
next_review: "2026-10-11"
next_step: "Instantiate with the project's current AppSumo agreement, tier map, and access contract."
---

# Playbook - AppSumo Licensing commerce

## Purpose

Implement AppSumo as an external licensing channel whose verified license state drives the seller's designated access authority.

The seller owns user identity, product mapping, access decisions, support recovery, and product enforcement.

Check the current AppSumo agreement and API documentation before implementation. The project's own commercial policy determines tier, stacking, replacement, and access rules.

## Applicability

Use this playbook for AppSumo OAuth activation, license validation, webhook handling, tier changes, key replacement, deactivation, and reconciliation.

Do not use legacy activation codes as a substitute for AppSumo Licensing. A local code can be a migration input, but it is not AppSumo OAuth, API evidence, or webhook proof.

## Inputs

- Owning business id, its AppSumo partner configuration, product id, license tier mapping, plan/capability mapping, and stacking or replacement policy.
- OAuth callback route and provider application configuration.
- Webhook route and HMAC verification settings.
- License API client with environment-safe configuration.
- Product and offer identifiers in the seller's access system.
- Synthetic AppSumo payloads for activation, inactive activation, upgrade, downgrade, deactivate, and test validation.
- Current AppSumo Licensing documentation checked immediately before provider implementation or hosted proof.

## Execution Order

1. Record the business, product, tier, plan, and capability mapping before accepting real licenses.
2. Implement OAuth code exchange as single-use server behavior.
3. Retrieve the license key server-side and bind it to a verified user in the seller's system.
4. Verify webhooks with timestamp and signature before parsing business state.
5. Bind verified AppSumo transitions to the configured partner account and environment, then normalize them into the seller's commerce or license events.
6. Keep `test` validations non-granting.
7. Store license state, current key, previous key, tier, status, owner, product, environment, and provider evidence.
8. Handle upgrade and downgrade as key lineage, not as an unrelated new sale.
9. Deactivate the old key without removing the replacement entitlement when AppSumo sends both transitions close together.
10. Reconcile via AppSumo API events and licenses after outages or ambiguous webhooks.
11. Expose operator-visible incidents for unknown tier, owner mismatch, inactive activation, signature failure, and lineage conflict.
12. Prove local synthetic transitions before using real AppSumo credentials or licenses.

## Decision Gates

- AppSumo tier and capability mapping is a business decision. Do not invent it in code.
- `test: true` or equivalent provider test validations never grant access.
- A license key is provider evidence, not a password and not a public user identifier.
- OAuth activation proves a user action, but access still depends on provider license state and the seller's product mapping.
- Webhook delivery can be delayed, duplicated, or arrive next to a key replacement; the final license lineage must be deterministic.
- Email address alone cannot decide the owner of a license.
- If AppSumo sends `activate` with an inactive license status, record and review it instead of granting blindly.
- Hosted provider proof starts only after local parser, HMAC, state, lineage, and reconciliation tests pass.

## Outputs

- OAuth callback and license lookup flow.
- Signed webhook endpoint with normalized provider envelopes.
- Durable AppSumo license state and lineage records.
- Mapping from tier to canonical product plan and capabilities.
- Reconciliation operation using provider API evidence.
- Tests for activation, inactive activation, test validation, upgrade, downgrade, deactivation, duplicate webhook, out-of-order webhook, owner conflict, and unknown tier.
- Support guidance for users who already bought on AppSumo but are signed into a different app account.

## Linked Checklists

- Project-specific licensing and access checklist instantiated from this playbook.
- Parent playbook: `digital-product-commerce-launch-playbook.md`

## Failure Modes

- Treating `source = appsumo` as proof that AppSumo Licensing is implemented.
- Granting from old activation-code imports and calling it AppSumo.
- Losing access on upgrade because the old key is deactivated before the new key is linked.
- Granting inactive or test licenses.
- Merging accounts by email.
- Ignoring reconciliation because webhooks are expected to be reliable.
- Building AppSumo-specific authorization rules into product clients instead of the designated server-side access authority.
