---
artifact: product_context
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: "ShipGlows"
created: "2026-04-26"
updated: "2026-08-23"
status: reviewed
source_skill: manual
scope: product
owner: "unknown"
confidence: medium
risk_level: medium
target_user: "solo founders and small teams who can use the framework directly, plus AI agents acting through the same governed contracts"
user_problem: "business, identity, content, product, and technical work lose shared intent across human and agent handoffs"
desired_outcomes: "distinctive identities, impactful businesses, solid technical execution, stronger handoffs, bounded chantiers, and visible proof"
non_goals: "mass-market beginner education, generic project management, general-purpose PaaS positioning, consulting or human-accompaniment services, presenting the unbuilt Cockpit SaaS as available, or replacing engineering judgment with autonomous automation"
security_impact: yes
docs_impact: yes
evidence:
  - "Repo artifacts strongly emphasize context routing, specs, readiness, verification, audits, and environment operations"
  - "shipglows_data/editorial/content-map.md and the sg-content repurpose mode add a content routing layer for documentation and marketing reuse"
  - "Thirteen public métier owners plus the ShipGlows router now share business-context, strategic-choice, outcome-ownership, and proof contracts"
  - "Operator confirmed decision SG-BIZ-2026-08-13-01: partnership and outcome ownership lead; environment delivery supports execution"
  - "Operator confirmed decision SG-BIZ-2026-08-14-01: the partnership is delivered by the autonomous ShipGlows product, never by a service offer; Cockpit SaaS remains nonexistent and deferred"
  - "Operator decision 2026-08-21: Git-backed persistence, interruption recovery, and delivery-state clarity are high-impact supporting proof of ShipGlows outcome ownership."
  - "Operator decision 2026-08-22: ShipGlows is a business framework for humans and agents across identity, brand, content, product, technology, growth, delivery, and proof"
linked_artifacts:
  - "shipglows_data/business/business.md"
  - "shipglows_data/technical/architecture.md"
  - "shipglows_data/technical/guidelines.md"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.5.0"
    required_status: "reviewed"
supersedes: []
next_review: "2026-09-13"
next_step: "Test direct human use and agent-assisted use across non-software and technical business work"
---

# Product Context

## Target User

- A solo founder who already ships code and feels the pain of context loss, unreliable prompts, and weak handoffs.
- An autonomous builder who wants AI help without downgrading execution standards.
- A founder who wants an agent to understand business consequences and retain responsibility for the result, not only complete technical instructions.
- A founder or team member who wants to use the same truths, contracts, métiers, and proof model directly without requiring an agent.

## Problem

- Fresh agent threads repeatedly pay a context reconstruction tax.
- The main pain is not only slow coding. It is lost context and weak handoffs between the founder and the agents.
- Product intent, business assumptions, docs, and code changes drift apart easily.
- Technical checks alone do not prove that user-facing behavior or workflow integrity still holds.
- Agent work can be technically valid while serving the wrong customer, promise, priority, or business outcome.

## Desired Outcomes

- A fresh agent can find the right context quickly.
- A founder can hand work to an agent with less ambiguity and less re-explanation.
- Non-trivial work is shaped before coding through explicit contracts.
- Success and failure behavior are made observable and testable.
- Verification catches contract drift instead of just syntax or lint errors.
- Business context can be questioned and refreshed when material gaps would otherwise distort a decision.

## Product Principles

- Reduce ambiguity before increasing automation.
- Prefer explicit contracts over hidden conventions.
- Keep fast paths for local work, but force structure when the task becomes risky or cross-cutting.
- Make success and failure visible to the operator.
- Act as a business partner before selecting technical means.
- Make the framework directly usable by humans and actionable by agents; partnership describes its behavior, not a human service.
- Keep environment and server operations subordinate to the outcome they enable and prove.

## Product Boundary Decision

Decision `SG-BIZ-2026-08-14-01` is `confirmed`:

- ShipGlows is the business framework available today; its software, skills, documentation, and tooling are delivery surfaces for that framework.
- "Business partner" describes product behavior: useful judgment, guided strategic choices, governed context, outcome ownership, and proof.
- Consulting, diagnostics, implementation missions, and human accompaniment are outside the intended product and commercial model.
- Cockpit may become a separate SaaS product later, but it does not exist today and carries no current delivery, roadmap, pricing, or availability promise.

## Product Capability Hierarchy

1. **Truth mesh:** select the smallest coherent business, product, market, brand, portfolio, and evidence context for the decision.
2. **Métier partnership:** route to one public outcome owner that advises, questions when useful, and preserves strategic consequences.
3. **Chantier delivery:** frame, execute, verify, close, and report the accepted outcome across internal handoffs.
4. **Operational capability:** install, run, expose, observe, release, and recover supported environments when the outcome requires it.

Git-backed delivery continuity supports layers three and four: validated milestones are committed and pushed, interrupted work is inspected before new risk is added, and local, remotely backed-up, and deployed states remain distinct.

The first three layers define the primary product promise. The fourth is a differentiated execution capability, not a separate equal product category.

## Core Workflows

- Governed truth -> métier arbitration -> bounded chantier -> execution -> proof -> closure.
- Explore -> Spec -> Ready -> Start -> Verify -> End for material implementation work.
- Fix-first path for bounded bugs.
- Docs and metadata path for keeping context and decision artifacts consistent.
- Content map and sg-content repurpose path for turning product work or source ideas into faithful docs, marketing, landing-page, FAQ, and semantic-cluster material.
- Server environment lifecycle path for deploy, restart, publish, and health management.
- Git persistence path for milestone backup, interruption recovery, sensitive-operation recovery points, and truthful delivery-state reporting.

## Scope In

- Shared business, identity, brand, content, product, technology, growth, delivery, and proof contracts for humans and agents.
- Workflow governance for AI-assisted engineering work.
- Context routing and artifact-based execution.
- Server-hosted environment management for developer workflows.
- A unified operating model between AI delivery and server environment management.
- Guided recovery when governing business context is materially incomplete, stale, or conflicting.

## Scope Out

- General-purpose product management suite.
- Beginner no-code workflow tooling.
- Broad cloud hosting abstraction for every deployment model.
- Generic platform-manager positioning without a strong agent-workflow angle.
- Consulting, agency work, diagnostics, implementation missions, and human-accompaniment offers.
- Selling, pricing, or presenting Cockpit as an available SaaS before a distinct product decision and verified implementation exist.

## Success Signals

- Reduced need to re-explain the same repo facts in fresh threads.
- Less context loss and fewer failed handoffs in real agent-assisted delivery work.
- Specs and docs become usable contracts rather than passive notes.
- Workflow-critical changes are less likely to ship with silent success, silent failure, or stale docs.
- A founder can move from repo state to executable change with less manual framing overhead.
- A founder can tell whether agent work exists only locally, is backed up remotely, or is actually deployed.
- Content and documentation updates are routed through a known content map instead of being rediscovered in each conversation.
- Declared products are kept coherent through a governed product inventory, public-surface mapping, and evidence-backed claim handling instead of scattered ad hoc notes.

## Risks

- The framework can become too broad if its capabilities are presented without the confirmed category, ambition, behavior, and mechanism hierarchy.
- The tool can be mistaken for “just a PM2 server script with helpers” if the AI framing layer is underexplained.
- The tool can be mistaken for “just a prompting method” if the environment-delivery layer is underexplained.
- Documentation volume can grow faster than its clarity if doc roles are not kept exclusive.
- Content repurposing can drift into generic marketing if `shipglows_data/editorial/content-map.md`, `shipglows_data/business/product.md`, `shipglows_data/branding/branding.md`, and `shipglows_data/business/gtm.md` are not kept current.
- Product language can accidentally imply a human service when "partner" is presented as the category rather than framework behavior.
- A future Cockpit concept can distort current priorities if treated as an existing product or committed roadmap.
