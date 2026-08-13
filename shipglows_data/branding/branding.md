---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-04-26"
updated: "2026-08-13"
status: reviewed
source_skill: manual
scope: brand
owner: "unknown"
confidence: medium
risk_level: medium
brand_voice: "direct, lucid, demanding, business-aware, and technically credible"
trust_posture: "earn trust through useful judgment, explicit tradeoffs, visible constraints, and proof rather than hype or passive agreement"
security_impact: unknown
docs_impact: yes
evidence:
  - "Current repository guidance consistently favors clarity, rigor, constraints, and explicit validation"
  - "The framework distinguishes implemented, verified, assumed, stale, and partial rather than optimistic framing"
  - "Operator confirmed decision SG-BIZ-2026-08-13-01: ShipGlows presents itself as a business and delivery partner before its infrastructure capabilities"
linked_artifacts:
  - "shipglows_data/business/business.md"
  - "shipglows_data/business/gtm.md"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-09-13"
next_step: "Validate partner-first language and visual hierarchy on the external public site"
---

# Brand Context

## Voice

- Direct and operator-grade.
- Precise over clever.
- Confident when proven, cautious when evidence is incomplete.
- Serious about engineering quality without sounding corporate or inflated.
- Business-aware without drifting into generic strategy language.

## Trust Posture

- ShipGlows should sound like a framework built by people who have felt the pain of ambiguity, not like a generic AI booster.
- ShipGlows should behave like a partner who understands the objective, challenges weak framing, proposes a direction, and remains accountable through proof.
- Claims should be scoped tightly and tied to visible mechanisms: specs, readiness, verification, metadata, audits, context docs.
- Trust is earned by naming constraints, failure modes, and tradeoffs explicitly.

## Vocabulary

- Prefer: outcome, decision, customer, value, consequence, chantier, proof, context, contract, verification, scope.
- Avoid: magic, autonomous genius, instant, effortless, perfect, seamless unless the constraint is truly negligible.
- Prefer “reduces ambiguity” over “solves everything”.

## Personality

- Rigorous without sounding bureaucratic.
- Technical without sounding exclusionary.
- Calm, explicit, and evidence-oriented.
- Constructively opinionated: recommend a direction and explain its business consequence.

## Claims Boundaries

- Allowed: ShipGlows improves clarity, structure, and repeatability of AI-assisted development work.
- Allowed: ShipGlows helps agents start with better context and verify against explicit contracts.
- Allowed: ShipGlows connects governed business context to métier decisions, bounded execution, and visible proof.
- Allowed: ShipGlows acts as a business-aware delivery partner when project truth supports the decision.
- Not allowed without stronger proof: guaranteed productivity gains, guaranteed correctness, guaranteed security, zero-regression shipping.
- Not allowed: marketing language that implies the framework replaces engineering judgment.

## Style Of Address

- Speak to a capable operator, not to a passive buyer.
- Prefer concrete framing over slogans.
- State tradeoffs when they matter; do not hide them behind generic reassurance.

## Visual Direction

- The product should read as operational and work-focused rather than playful or futuristic.
- Visual trust should come from structure, legibility, and specificity, not decorative hype.
- Any future site should make the hierarchy legible quickly: business-aware delivery partner first; métier agents, governed execution, and environment operations as supporting capabilities.

## Bundle Boundary

This file is the shared brand root. When a project needs more explicit brand governance, the preferred bundle shape is:

- `shipglows_data/branding/branding.md`
- `shipglows_data/branding/voice-and-tone.md`
- `shipglows_data/branding/messaging-pillars.md`
- `shipglows_data/branding/visual-identity.md`
- `shipglows_data/branding/brand-rules.md`
- `shipglows_data/branding/assets/README.md`

Not every project needs every file immediately, but `branding/` is the canonical family for shared brand doctrine.
