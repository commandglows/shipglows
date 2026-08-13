---
artifact: workflow_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: guided-business-product-discovery
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - templates/business_context.md
  - templates/product_context.md
  - templates/gtm_context.md
  - templates/brand_context.md
  - skills/300-sg-docs/SKILL.md
  - skills/305-sg-init/SKILL.md
  - skills/references/atlas-cartography-lifecycle.md
  - skills/references/product-decision-chain.md
  - skills/references/business-context-mesh.md
  - skills/references/question-contract.md
  - skills/references/mutation-plan-approval.md
depends_on:
  - artifact: skills/references/question-contract.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-02: a business owner must be guided to express business identity and customer needs instead of being expected to fill documents alone."
  - "Local BMAD review 2026-08-02: retain sequential discovery, targeted questions, proposed synthesis, explicit confirmation, journeys and capability derivation without importing BMAD complexity."
  - "Operator decision 2026-08-13: agents may initiate a guided governing-document update pass when a material gap needs ordering-authority input."
next_review: "2026-09-13"
next_step: "Use this contract when creating, refreshing, or substantially repairing business, product, GTM, brand or Atlas framing."
---

# Guided Business And Product Discovery

## Purpose

Turn incomplete, stale, or conflicting business context into durable business, product, GTM and brand decisions. The operator is never asked to fill a blank template alone, and the agent never presents guesses as confirmed facts.

## Evidence States

Every material statement is one of:

- `confirmed`: explicitly accepted by the operator;
- `evidence_backed`: supported by an existing product, customer signal, document or source;
- `hypothesis`: useful proposal awaiting confirmation;
- `unknown`: unresolved and important enough to keep visible.
- `stale`: previously supported but outside its applicable freshness boundary;
- `conflict`: applicable authoritative sources disagree.

Code and stack evidence can prove what exists. They cannot prove who the priority customer is, why they care, which outcome matters most, the intended promise or the desired brand feeling.

## Governance Refresh Entry

`business-context-mesh.md` may start this loop when a material governing claim is missing, unknown, stale, or conflicting. Preserve the original chantier outcome and narrow the pass to the claims that can change it.

Before questioning, inspect the repository, live product, current sources, customer evidence, and researchable market facts. Ask the ordering authority only for business intent, priority, promise, risk appetite, or acceptance that evidence cannot establish. Lead with a synthesis and a proposed interpretation so the question advances a decision rather than transferring research work.

Questioning may begin without mutation. Before persisting any change, satisfy `mutation-plan-approval.md`; reuse an existing approval only when its scope already includes the affected governing documents. After confirmation, update the canonical source and affected dependents, preserve evidence states and superseded decisions, then resume the original chantier automatically.

## Guided Loop

For one thematic step at a time:

1. Read only the relevant existing evidence: current business/product/GTM/brand docs, live product, specs, Atlas, customer signals and prior operator decisions.
2. State a short synthesis of what appears known and label any hypothesis.
3. Ask one plain-language, high-leverage question. Do not dump a questionnaire.
4. If the operator struggles, offer two or three tailored contrasts and a recommended interpretation. Do not replace their decision.
5. Draft the exact section that the answer would add or change.
6. Ask the operator to `Confirmer`, `Corriger` or `Approfondir`. Advance only after confirmation, while preserving explicit hypotheses and unknowns.
7. Persist the confirmed result and first unresolved decision, then resume the original outcome without making the operator re-route the work.

Do not ask again for facts already supported by reliable evidence. When documents are partial, stale, or conflicting, preserve confirmed content and question only the consequential gaps.

## Discovery Sequence

### 1. Business Identity

Establish who the business serves, the costly or meaningful situation it changes, the promised transformation, why this business should exist, its commercial model and its material constraints.

### 2. Customer Need

Describe the priority customer in context: trigger, current workaround, practical and emotional stakes, desired outcome, buying/user roles and evidence. Prefer a concrete situation over a demographic label.

### 3. Journeys

Write the priority value journey from trigger to first value, then long-term value. Include at least one failure or recovery journey when trust depends on it. Capture what the person does, expects, fears, learns and sees at each decisive moment. Apply `product-decision-chain.md` to the few critical moments whose failure changes adoption, trust, conversion or retention.

### 4. Capabilities And Scope

Derive capabilities from confirmed journeys as user-observable outcomes: `actor can capability`. State WHAT the product must enable, not HOW it will be coded. Separate existing, planned, deferred and explicitly out-of-scope capabilities, then link them to Atlas surface/function IDs when available and preserve their upstream/downstream trace through `product-decision-chain.md`.

### 5. Go-To-Market

Clarify the buying trigger, segment, offer, positioning against current alternatives, objections, proof, acquisition/conversion path, channels and learning signals. Claims must stay inside the evidence boundary.

### 6. Brand

Clarify the feeling and trust posture the experience should create, personality, voice, vocabulary, forbidden claims, visual direction and behavior at critical touchpoints. Brand choices must support the priority customer and promise.

## Focused Deepening

Use at most one of these lenses when an answer is vague or a decision is risky, then return to the guided loop:

- alternative customer perspective;
- failure, recovery and trust analysis;
- current alternative or competitor contrast;
- first-principles challenge;
- pre-mortem: what would make this promise fail?

## Pressure Scenarios

- `ATLAS-015 GUIDED-VAGUE-FOUNDER`: given only a vague project idea, the agent synthesizes what is known, marks hypotheses, asks one business question and does not fabricate completed context documents.
- `ATLAS-016 GUIDED-PARTIAL-CORPUS`: given partial existing documents, the agent preserves confirmed content and asks only about the first consequential gap.
- `ATLAS-017 JOURNEY-TO-CAPABILITY`: given a confirmed customer journey, the agent derives user-observable capabilities and candidate Atlas surfaces/functions without prescribing implementation details.
- `ATLAS-018 NO-QUESTIONNAIRE-DUMP`: the operator receives one thematic question, a proposed synthesis and visible confirmation choices, never an exhaustive questionnaire.
- `GOV-REFRESH-01 RESUME-AFTER-UPDATE`: a material business gap discovered during another chantier produces one proposed interpretation and authority-owned question; after authorized canonical update, the original chantier resumes automatically.
- `GOV-REFRESH-02 RESEARCH-BEFORE-ASKING`: competitor, market, repository, and technical facts are researched by the agent; only the strategic interpretation or decision is asked of the ordering authority.

## Completion Contract

A discovery pass is complete only when the durable docs distinguish confirmed decisions, evidence, hypotheses and unknowns; the priority customer journey is coherent; product capabilities and scope trace back to it; GTM and brand do not contradict the business promise; and the next unresolved decision is explicit.
