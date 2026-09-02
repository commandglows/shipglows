---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-09-02"
status: active
source_skill: 900-shipglows-core
scope: business-context-mesh
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/intent-to-outcome-autonomy.md
  - skills/references/operator-partnership-contract.md
  - skills/references/profile-project-context.md
  - skills/references/context-quality-contract.md
  - skills/references/guided-business-product-discovery.md
  - skills/references/product-decision-chain.md
  - skills/references/question-contract.md
  - skills/references/mutation-plan-approval.md
  - skills/references/project-delivery-policy.md
  - shipglows_data/business/
  - shipglows_data/branding/
depends_on:
  - artifact: skills/references/canonical-paths.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/guided-business-product-discovery.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/question-contract.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/project-delivery-policy.md
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-01: canonical business context owns project delivery posture and the context mesh must recover it before branch selection."
  - "Operator decision 2026-09-02: root PITCH.md is the fast project identity and navigation entrypoint, while canonical business/product sources retain decision authority."
  - "Operator decision 2026-08-22: the target mesh resolves business, brand, product, outcome, surface, and work item without assuming software."
  - "Operator decision 2026-08-13: every métier must act as a business partner grounded in the existing business corpus."
  - "Core audit 2026-08-13: business sources existed but no shared runtime selector connected them to every public outcome path."
  - "Operator decision 2026-08-13: a material governing-context gap may trigger a guided update pass with the ordering authority."
next_review: "2026-09-13"
next_step: "/103-sg-verify business context mesh"
---

# Business Context Mesh

## Purpose

Ground non-trivial ShipGlows work in the target project's existing business truth without loading the whole governance corpus. This mesh is the shared selector: métier and profile contracts specialize it but do not create competing source rules.

## Activation Rule

After resolving `project -> business/brand/product -> outcome -> surface -> work item`, load the smallest coherent source bundle when customer value, product promise, identity, market position, monetization, trust, portfolio priority, or organizational leverage could materially change the decision. Start from the active project's governance root, including a monorepo root; use the ShipGlows corpus only when ShipGlows itself is the target.

Skip this mesh for routine reversible mechanics whose outcome cannot differ under any applicable business source. Do not use lexical resource discovery as proof that no business context exists.

## Canonical Source Map

| Source family | Canonical project source | Decision authority | Load when |
| --- | --- | --- | --- |
| Business | `shipglows_data/business/business.md` | priority customer, problem, value, model, constraints, product delivery posture | beneficiary, value, viability, risk, leverage, release posture, or Git integration target matters |
| Product | `shipglows_data/business/product.md` | promise, outcomes, capabilities, scope, non-goals | behavior, journey, experience, scope, or acceptance changes |
| Go-to-market | `shipglows_data/business/gtm.md` | positioning, offer, objections, channels, conversion, claim limits | acquisition, conversion, pricing, launch, or public promise matters |
| Brand | `shipglows_data/branding/branding.md` | voice, vocabulary, feeling, trust posture, forbidden claims | a user-facing experience, message, identity, or recovery moment changes |
| Portfolio | `shipglows_data/business/portfolio-project-pitch-links.md` | cross-project identity and current pitch locations | portfolio priority, project comparison, shared narrative, or pitch routing matters |
| Project pitch | `PITCH.md` | concise project identity, dated state summary, and pointers to canonical truth | fast project recentering or `#pitch` is requested; never use it to resolve delivery posture or replace business/product truth |
| Alternatives | `shipglows_data/business/project-competitors-and-inspirations.md` | known competitors, alternatives, inspirations, anti-patterns | differentiation, build-versus-adopt, market contrast, or prior-art risk matters |
| Partnerships | `shipglows_data/business/affiliate-programs.md` | affiliate, referral, sponsorship, partner, and disclosure truth | recommendations, monetized links, partnerships, or disclosure obligations matter |

Treat surface-scoped files under the matching governance family as more specific candidates when their metadata says they apply. Root legacy files are migration evidence, not competing authority. `shipglows_data/business/agent-profiles/` governs delegation posture; it is never product, customer, market, or commercial truth.

## Selection Rules

Start with the source that owns the decision, then add only sources needed to detect a consequential contradiction:

- product or experience work usually starts with Product; add Business for customer value and Brand or GTM only when trust or public promise changes;
- content, marketing, SEO, or public documentation usually combines Business, Product, GTM, and Brand, then loads `editorial-content-corpus.md` for surface and claim governance;
- planning and portfolio work starts with Business and Product; add Portfolio and Alternatives only for cross-project or differentiation decisions;
- release, reliability, and internal engineering load business context only when availability, trust, cost, user behavior, or a public promise can change;
- every delivery-sensitive or Git branch-selection decision loads the canonical Business `delivery_posture` field even when no other business source is needed;
- Partnerships is never inferred from a generic recommendation: load it when commercial relationships or disclosures are actually relevant.

Do not read every family by default. Stop adding sources when another file cannot change the decision, expose a material conflict, or strengthen the required proof.

## Truth Quality And Conflict

Inspect metadata, applicability, version/date, and evidence state before relying on a source. `draft`, `hypothesis`, `unknown`, overdue review, or mismatched scope cannot silently become confirmed truth. Apply `context-quality-contract.md` when sufficiency, freshness, or conflict affects action.

- Missing context is a visible evidence gap, not permission to invent strategy.
- Missing or invalid `delivery_posture` invokes `project_delivery_policy.py`, then one product-status question and exact canonical persistence before branch selection; runtime state and pitch cannot fill the gap.
- Two applicable confirmed sources that disagree produce `context_conflict` and stop dependent mutation.
- Creating or substantially repairing business, product, GTM, or brand truth routes through `guided-business-product-discovery.md`.
- A material change to confirmed business or product meaning routes through `product-decision-chain.md` before dependent implementation.

Carry only the material source pointers and evidence states in the working Context Capsule. Never copy the corpus into a parallel summary that could become a second authority.

## Governance Refresh Loop

When a material `unknown`, `stale`, `conflict`, or missing governing claim can change the current outcome, initiate a bounded update pass instead of merely reporting the gap:

1. Preserve the original outcome and name the governing source and exact claim that needs recovery.
2. Inspect existing project evidence and research agent-discoverable facts first. Do not ask the ordering authority to perform repository, market, competitor, or technical research the agent can perform.
3. State what appears known, why the gap matters now, and a proposed interpretation with its evidence state.
4. Load `question-contract.md` and ask one high-leverage business question only when intent, priority, promise, appetite, or acceptance belongs to the ordering authority.
5. Draft the exact canonical change and identify dependent sources that may need reconciliation.
6. Before writing, apply `mutation-plan-approval.md`; an existing approval is sufficient only when it explicitly covers the governing-document update.
7. After confirmation, update the canonical source, preserve superseded truth when material, refresh metadata and evidence pointers, then re-evaluate dependent claims.
8. Resume the original outcome automatically with the refreshed truth; do not make the operator restart or route the chantier.

Use `guided-business-product-discovery.md` for the questioning and confirmation loop. For Portfolio, Alternatives, or Partnerships, reuse that loop while researching factual claims before asking for strategic interpretation. A stale review date alone does not justify interruption when current evidence still establishes the claim; classify and refresh only the claims that can change the decision.

## Pressure Scenarios

- `BUSINESS-MESH-01 TECHNICALLY-RIGHT-WRONG-OUTCOME`: an implementation passes technical checks but conflicts with the confirmed product promise; the result remains partial and the conflict is resolved before completion.
- `BUSINESS-MESH-02 SELECTIVE-CONTEXT`: a narrow internal refactor with no customer, promise, market, trust, cost, or portfolio consequence does not load the business corpus.
- `BUSINESS-MESH-03 CONDITIONAL-EDGE`: competitor, portfolio, or affiliate sources load only when differentiation, cross-project direction, partnership, or disclosure can change the outcome.
- `BUSINESS-MESH-04 PROJECT-FIRST`: work in another managed project reads that project's governance corpus and never substitutes ShipGlows business truth.
- `BUSINESS-MESH-05 ACTIVE-REFRESH`: a material governing gap triggers evidence review, a proposed interpretation, one authority-owned question, an authorized canonical update, and automatic resumption of the original outcome.
- `BUSINESS-MESH-06 DELIVERY-POSTURE`: a delivery or Git decision reads `delivery_posture` from canonical business context; missing truth triggers one product question, exact persistence, and automatic resumption.
- `BUSINESS-MESH-06 NO-QUESTION-OFFLOAD`: an agent-researchable market, competitor, repository, or technical fact is investigated by the agent and never offloaded to the ordering authority.
