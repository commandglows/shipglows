---
artifact: business_context
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: "ShipGlows"
created: "2026-04-26"
updated: "2026-08-13"
status: reviewed
source_skill: manual
scope: business
owner: "unknown"
confidence: medium
risk_level: medium
business_model: "not defined yet; current hypothesis is a simple sales motion for solo founders with product and documentation that support autonomy"
target_audience: "solo founders first, plus small technical teams using AI agents to turn business and product intent into shipped, verified software without fragile handoffs"
value_proposition: "turn governed business truth into better decisions, bounded chantiers, and verified outcomes through business-aware agent métiers, with delivery infrastructure as an integrated execution capability"
market: "solo founders first, with adjacent fit for small technical teams and highly autonomous builders running simple product sales cycles"
security_impact: yes
docs_impact: yes
evidence:
  - "README.md describes ShipGlows as a server-first environment manager plus structured AI workflow system"
  - "Repository contains workflow, verification, audit, docs, and metadata tooling rather than a narrow single-purpose CLI"
  - "The public system now exposes thirteen métier owners plus the ShipGlows router, backed by shared business-context, strategic-choice, execution, and verification contracts"
  - "Operator decision 2026-08-13: ShipGlows is first a business and delivery partner; server tooling is an integrated execution capability rather than an equal top-level promise"
linked_artifacts:
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/gtm.md"
  - "shipglows_data/branding/branding.md"
  - "shipglows_data/business/portfolio-project-pitch-links.md"
depends_on: []
supersedes: []
next_review: "2026-09-13"
next_step: "Validate this hierarchy against the external public site and early user evidence"
---

# Business Context

## Mission

ShipGlows exists to help solo founders turn business and product truth into better decisions, bounded chantiers, and verified software outcomes with AI agents, without accepting fragile handoffs, repeated context rebuilding, or technically correct work that misses the business objective.

## Audience

- Solo founders making business, product, and delivery decisions while shipping real products, not toy repos.
- Small technical teams that want the same execution discipline without a heavy process layer.
- Autonomous builders who need one coherent path from intent through product, implementation, delivery, and proof.
- Users who already feel the pain of weak agent handoffs, repeated re-explanation, and context loss.

## Value Proposition

- ShipGlows turns governed business truth into decisions, chantiers, and results that can be verified against the intended outcome.
- Its public métier agents act as business-aware owners before they become technical executors.
- The core value is not raw speed. It is stronger judgment, less lost context, less ambiguity, and continuity from intent through proof.
- Environment and server-delivery tooling strengthens execution and operational proof; it is a capability inside the partnership, not a competing product promise.
- The product narrative stays solo-founder-first, but the same operating model can work well for small teams that want more rigor without enterprise overhead.
- Small teams should recognize a lightweight operating model with professional rigor, not an enterprise process layer.

## Strategic Product Hierarchy

Decision `SG-BIZ-2026-08-13-01` is `confirmed`:

1. **Governing truth:** business, product, GTM, brand, portfolio, and evidence establish what should improve and why.
2. **Business partnership:** public métier agents interpret that truth, expose consequential choices, and retain outcome ownership.
3. **Execution and proof:** chantiers move from framing through implementation, verification, and closure without operator choreography.
4. **Environment and delivery:** runtime, server, release, and observability capabilities make outcomes operable and provable.

This supersedes the prior equal-pillar framing of AI delivery and server environment management. It does not retire either capability.

## Business Model

- There is no defined business model yet.
- Current working assumption: if monetized, the offer should fit a simple sales motion for solo founders rather than a complex enterprise process.
- The commercial model remains a hypothesis to test after the positioning and product framing are clearer.

## Market

- Primary market assumption: solo founders who need clarity and a practical operating model for agent-assisted shipping.
- Secondary market assumption: small technical teams are a legitimate adjacent fit, but they are not the primary narrative to optimize for now.
- Current scope does not support broad beginner-market positioning; the product still reads as technical and operator-oriented.

## Evidence

- The repo contains an unusually strong layer for specs, readiness, verification, audits, metadata, and context routing.
- The CLI layer is built around PM2, Flox, Caddy, and SSH tunnels, which suggests operational users rather than lightweight front-end-only teams.

## Assumptions

- The strongest wedge is context preservation and stronger handoffs, not generic “AI coding speed”.
- Buyers will care about reduced ambiguity, cleaner execution framing, and fewer weak handoffs across specs, docs, code, and operations.
- The highest-value users already feel pain from context loss and fragile agent loops.
- The product should be positioned as neither a generic PaaS nor a generic AI prompting method.

## Decision Status

- The audience, problem frame, product hierarchy, and partner-first value proposition are confirmed enough to guide product and documentation work now.
- The business model remains intentionally open and should not be treated as settled strategy.

## Risks

- Positioning will regress if public surfaces return to equal-pillar or server-first framing.
- The partnership promise can become generic unless métier decisions remain grounded in project truth and finish with observable proof.
- Commercial claims should stay behind evidence; the repo shows doctrine strength, not validated market traction.
- Product strategy can drift if README-level narrative substitutes for explicit business and GTM decisions.
