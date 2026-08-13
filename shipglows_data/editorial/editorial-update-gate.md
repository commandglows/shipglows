---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-14"
status: reviewed
source_skill: sg-start
scope: editorial-update-gate
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - repo_docs
  - public_skill_pages
  - future_blog
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - CONTENT_MAP.md
  - docs/editorial/
  - skills/references/subagent-roles/editorial-reader.md
  - skills/300-sg-docs/SKILL.md
  - skills/007-sg-content/references/repurpose-playbook.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-editorial-content-governance-layer-for-ai-agents.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Ready spec defines Editorial Update Plan, Claim Impact Plan, and pending final copy rules."
  - "Positioning decision SG-BIZ-2026-08-13-01 requires propagation from canonical governance to the external public site."
  - "Product-boundary decision SG-BIZ-2026-08-14-01 confirms autonomous software, no service offer, and no current Cockpit SaaS promise."
  - "commandglows/shipglows_app PR #6 merged on 2026-08-14 and production routes on shipglows.com returned the approved EN/FR positioning."
next_review: "2026-09-13"
next_step: "Monitor product-led adoption evidence and prevent service-led or premature Cockpit claims from re-entering public surfaces"
---

# Editorial Update Gate

## Purpose

The Editorial Update Gate prevents product, workflow, public docs, public skill promises, pricing, support copy, and claims from drifting after a change ships.

The gate can output either an update plan or an explicit no-impact justification. It should not force copy work for internal-only changes that have no public-content consequence.

## Triggers

Run the gate when a workstream changes or verifies any of these:

- user-visible product behavior
- public documentation truth
- public skill promise or skill category
- README guidance or onboarding
- landing page, FAQ, pricing, support copy, docs overview, or skill pages
- public claim about security, privacy, compliance, AI reliability, automation, speed, savings, availability, pricing, or business outcomes
- Astro runtime content under `site/src/content/**`
- blog, article, newsletter, or future content output
- workflow or spec requirement for project-aware content quality scoring or an editorial score gate
- introduction, removal, or renaming of a sellable product surface, including sales page, product page, demo, screenshots, video, checkout, or delivery path
- introduction, removal, or renaming of a declared product in the governed product inventory

## Editorial Update Plan

```markdown
## Editorial Update Plan

- Changed behavior or source: `[spec, diff, file, user decision, or verified behavior]`
- Impacted surface: `[route/file/surface]`
- Source of truth: `[BUSINESS.md|PRODUCT.md|BRANDING.md|GTM.md|README.md|spec|verified behavior]`
- Required action: `[none|review|update|create|remove|surface missing|pending final copy]`
- Reason: `[why this surface is or is not impacted]`
- Owner role: `[Editorial Reader|executor|integrator|human decision]`
- Parallel-safe: `[yes|no]`
- Validation: `[build, rg check, claim review, schema check, manual review]`
- Closure status: `[complete|no editorial impact|pending final copy|blocked]`
```

## Claim Impact Plan

When a sensitive claim is affected, add the plan from `docs/editorial/claim-register.md`. The claim plan can stand alone or attach to an Editorial Update Plan item.

## Completed Editorial Update Plan: SG-BIZ-2026-08-13-01 + SG-BIZ-2026-08-14-01

- Changed source: confirmed positioning decision `SG-BIZ-2026-08-13-01`, product-boundary decision `SG-BIZ-2026-08-14-01`, and reviewed business/product/GTM/brand contracts.
- Impacted surfaces: external EN/FR landing, about, docs overview, FAQ, product-status route, contact, pitch, skills discovery, and shared homepage components.
- Source of truth: `shipglows_data/business/business.md` 1.4.0, `product.md` 1.4.0, `gtm.md` 1.4.0, and `shipglows_data/branding/branding.md` 1.2.0.
- Required action: completed. Public copy leads with the business-aware delivery product, shows governed truth, métier outcome ownership, bounded chantiers, and proof before environment operations, and explicitly excludes service offers and current Cockpit availability.
- Claim boundary: environment/runtime capability remains valid supporting evidence; the partnership is autonomous product behavior; do not promise human services, current Cockpit availability, correct business advice, unattended delivery, market success, growth, revenue, conversion, or guaranteed outcomes.
- Reason: external surfaces previously expressed the superseded equal-pillar hierarchy and left service/Cockpit interpretation insufficiently bounded.
- Owner role: public content owner with human review of the final offer hierarchy.
- Parallel-safe: no for shared landing, navigation, docs overview, FAQ, or claim components.
- Validation: EN/FR copy parity; targeted stale-positioning and service-language searches; Astro check and production build; 19 focused route/install tests; local route checks; Vercel checks; human visual approval; production HTTP and semantic checks on landing, FAQ, product-status, and contact routes.
- Publication evidence: `commandglows/shipglows_app` PR #6, merge commit `6459f0c220f5ca65fe8265fff68f2e7f1aca7aea`, and verified `https://shipglows.com` production routes.
- Closure status: `complete`.

## Status Rules

| Status | Use when |
| --- | --- |
| `complete` | Required public-content update is applied and validated |
| `no editorial impact` | The change has no user-visible public content consequence and the reason is stated |
| `surface missing` | The affected surface is not declared in `CONTENT_MAP.md` or `docs/editorial/public-surface-map.md` |
| `claim mismatch` | Public claim conflicts with product, business, brand, GTM, spec, or verified behavior |
| `needs proof` | Claim could be true but lacks evidence |
| `pending final copy` | Update is intentionally deferred with owner, reason, and a block-before-ship condition |
| `blocked` | Public content would mislead, expose private detail, break schema, or require an unresolved decision |

## Content Quality Score Gate

When an editorial score gate is declared, use `skills/references/content-quality-rubric.md` as the scoring contract. The gate is complete only when the score output contains the required schema fields, final status, blocked reasons when relevant, evidence, recommendations, confidence, and applied project-rule revisions.

`sg-verify` rejects recoverable, duplicate, stale, conflicting, or mismatched score states. It also rejects any blocking criterion even when the numeric score is high, including unsupported sensitive claims, unresolved project context, invalid surfaces, missing project rules, or unauthorized evaluator fields.

## Shared Surface Rules

- Shared surface writes are sequential by default.
- Block or reroute if parallel write agents are assigned to `CONTENT_MAP.md`, `docs/editorial/claim-register.md`, `docs/editorial/page-intent-map.md`, `site/src/pages/index.astro`, shared components, nav/footer, FAQ, pricing, docs overview, README, or `site/src/content.config.ts`.
- Parallel public skill page edits are allowed only when a ready spec assigns exclusive files and no shared collection schema, hub copy, nav, map, register, FAQ, docs, pricing, or landing file changes in the same wave.

## Closure And Ship Rules

- A chantier is not cleanly closed if known public content still describes old behavior.
- `pending final copy` is acceptable only with owner, reason, and a block-before-ship condition.
- If a public surface is missing, update the shared map first or route to a separate spec.
- If a declared product exists but its canonical inventory entry is missing, the gate must not close cleanly; mark the surface `surface missing` until declared.
- If a product has public marketing or conversion intent but its canonical sales/product/delivery URLs are missing, the gate must not close cleanly; mark the surface `surface missing` or `pending final copy` until declared.
- If a public claim cannot be tied to source truth, a live surface, or proof assets, the gate must not close cleanly; mark it `needs proof`, `pending final copy`, or remove the claim.
- If a claim is unsupported, downgrade, remove, or block it before publication.
- If Astro runtime content schema would reject the update, stop and preserve the schema.
- For page-level claim placement, use `page-intent-map.md`; for validation state and claim review, use this gate; for sensitive public claims, use `claim-register.md`.

## Maintenance Rule

Update this gate when editorial statuses, closure rules, parallelism rules, public claim handling, or content-validation expectations change.
