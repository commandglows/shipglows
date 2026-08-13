---
artifact: gtm_context
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: "ShipGlows"
created: "2026-04-26"
updated: "2026-08-13"
status: reviewed
source_skill: manual
scope: gtm
owner: "unknown"
confidence: low
risk_level: medium
target_segment: "solo founders first, with adjacent fit for small technical teams and technical builders evaluating a clearer way to ship with AI agents"
offer: "a business-aware delivery partner that turns governed product truth into métier decisions, bounded chantiers, and verified outcomes, supported by integrated environment and release capabilities"
channels: "documentation-first discovery, technical content, demos, founder education, and clarity-oriented positioning"
proof_points: "business-context mesh, thirteen public métier owners plus the ShipGlows router, strategic choices, guided governance refresh, outcome-owned workflows, verification and audits, plus concrete environment and delivery tooling"
security_impact: unknown
docs_impact: yes
evidence:
  - "Current repo demonstrates the mechanics of the framework but not yet validated acquisition or conversion data"
  - "Operator confirmed decision SG-BIZ-2026-08-13-01: partnership and verified outcomes lead the offer; server delivery is supporting proof"
linked_artifacts:
  - "shipglows_data/business/business.md"
  - "shipglows_data/branding/branding.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/portfolio-project-pitch-links.md"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.2.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-09-13"
next_step: "Translate the confirmed offer hierarchy into the external landing, docs, FAQ, and pitch surfaces"
---

# GTM Context

## Target Segment

- Solo founders who already feel the pain of weak AI execution loops.
- Small technical teams that want stronger delivery discipline without turning the workflow into a heavy process stack.
- Autonomous technical users who want stronger delivery discipline rather than generic AI enthusiasm.

## Offer

- ShipGlows should be presented first as the business-aware partner that connects product truth to decisions, delivery, and proof.
- Public métier agents make that partnership concrete by owning outcomes instead of returning isolated technical output.
- The offer is strongest when framed around better judgment, reduced ambiguity, continuity, and verified outcomes, not raw coding speed.
- The first public story should stay simple: ShipGlows helps solo founders turn their business intent into shipped, verified product outcomes with agents.
- Environment and server operations demonstrate that the partnership reaches delivery; they should not lead the category story.
- Small teams should still be able to recognize themselves in the product, but as a secondary audience rather than the lead headline.

## Positioning

- Not “another coding assistant”.
- Not “just a server CLI with PM2 helpers”.
- Not “just a methodology or a bundle of prompts for agents”.
- Not a general-purpose PaaS or platform manager.
- Best current positioning: a business-aware delivery partner for solo founders, powered by governed métier agents and integrated execution infrastructure, with clear applicability to small technical teams.

## Channels

- Technical documentation and examples.
- Content explaining spec-first execution, observability of success/failure, and artifact-based workflow design.
- Demonstrations of fresh-thread onboarding and reduced context rebuild cost.
- Founder-facing content around clarity and shipping without fragile agent loops.

## Conversion Path

- First contact through docs, examples, or technical content.
- Interest through the concrete mechanics: `AGENT.md`, `shipglows_data/technical/context.md`, `shipglows_data/workflow/specs/`, verification, lintable metadata.
- Conversion through confidence that the framework improves reliability of real work, not toy demos.
- The buying motion should stay simple and compatible with a solo-founder audience.
- The public story should make clear that declared products, sales surfaces, and public claims are governed with explicit proof rather than improvised copy.

## Proof Points

- Dedicated context layer for fresh agents.
- Clear routing toward business, product, GTM, architecture, and guidelines.
- Spec, readiness, start, verify workflow.
- Observable success/error behavior discipline.
- Metadata-linted documentation contracts.
- Audit and verification skills built into the same framework.
- Real server operations tooling in the same operating model.
- Product governance for declared products: inventory, sales surfaces, delivery paths, and claim coherence.
- A shared business-context mesh and guided refresh loop that can improve governing truth before dependent work continues.

## Objections

- “This looks heavier than just prompting harder.”
- “Is this a methodology or an actual product?”
- “Is this just a server script plus a few helpers?”
- “Do I need all the docs before I get value?”
- “Is this only for Bash/server-heavy repos?”

- "Is this genuinely business-aware, or only a technical workflow described in business language?"

## KPIs

- To be defined once there is an explicit site and funnel.
- Early candidate signals: activated repos, repeated use of spec/verify loop, reduction in context-restatement, docs adoption across projects.
- Business model is not defined yet; pricing and revenue KPIs remain open hypotheses.

## Evidence Limits

- The current GTM contract is reviewed enough to guide wording and funnel experiments.
- It is not reviewed enough to justify aggressive commercial claims or mature revenue assumptions.
