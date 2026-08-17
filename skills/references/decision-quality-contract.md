---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.2.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-08-17"
status: active
source_skill: 900-shipglows-core
scope: decision-quality-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/decision-quality-implementation-discipline.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/master-delegation-semantics.md
  - skills/references/operator-partnership-contract.md
  - skills/references/question-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/skill-instruction-layering.md
  - tools/test_industrial_excellence_contract.py
depends_on: []
supersedes: []
evidence:
  - "Wave 15 preserves the universal decision gates in the canonical path and moves implementation pressure detail to one direct conditional leaf."
  - "Operator correction 2026-08-17: ShipGlows is business-oriented and must ship product value quickly while preserving a coherent architecture and non-negotiable safety boundaries; process and maximal proof are not the product."
next_review: "2026-09-12"
next_step: "/103-sg-verify decision-quality-contract"
---

# Decision Quality Contract

## Purpose

Set the mandatory decision posture for ShipGlows work: ship useful product value quickly through the smallest coherent architecture that can support the accepted horizon.

## Decision Quality Baseline

The primary goal is shipped business and user value. Architecture, correctness, security, maintainability, and proof are enabling constraints, not competing deliverables. Optimize the work as follows:

1. identify the smallest valuable product outcome that can be shipped and learned from;
2. choose the shortest credible path to production or real-user feedback;
3. preserve correctness and reliability for that accepted outcome;
4. use coherent boundaries and maintainable architecture proportionate to the product horizon and demonstrated evolution pressure;
5. preserve non-negotiable security, privacy, permissions, tenant isolation, data safety, and abuse resistance;
6. protect performance and operational robustness where they materially affect use, cost, reliability, or trust;
7. gather only proof proportional to the claim and cost of error.

Once the applicable floor is met, prefer the faster, simpler, smaller implementation. Choose a slower path only when it prevents a concrete material risk or near-term structural dead end. Do not trade shipping speed for speculative architecture, ceremonial process, exhaustive optional proof, or hypothetical future requirements.

`Smallest safe path` is the smallest shippable professional implementation preserving the accepted product outcome, coherent ownership boundaries, non-negotiable safety, and enough maintainability for the known horizon. Small blast radius and short lead time are strengths; hidden debt and bypassed invariants are not.

## Industrial Excellence Gate

`industrial-grade` completion scales with consequence. Work merely functional, unintentionally generic for the accepted product, fragile, cluttered, or with unresolved provisional elements presented as final is `partial`; complexity, extra layers, and long validation rituals are not excellence. MVP architecture must remain coherent and evolvable without solving unproven future problems. NASA, government, ANSSI, RGAA, and SecNumCloud claims require a framework-specific scoped audit and direct evidence.

## Structure Replacement Fit

A new rule, tool, layer, dependency, or process must replace a weak point, manual step, ambiguity, drift, or maintenance burden. If it only adds structure without a quality-equivalent reduction elsewhere, do not add it.

## Fast Fix Shortcut Gate

A change fails this gate when it hides root cause, bypasses the owner or durable structure, weakens proof, or leaves an incoherent exception. Use `root cause -> owner boundary -> smallest complete professional fix -> matching proof`. Label unavoidable temporary mitigation honestly and route durable follow-up; never report mitigation as completion.

Load `skills/references/decision-quality-implementation-discipline.md` only when implementation, repair, refactoring, mitigation, library/tool choice, or shortcut pressure requires the detailed discipline.

## Safety Gate

Stop or ask before a choice changes security, privacy, permissions, tenant boundaries, data handling, destructive behavior, secrets, irreversible state, or external side effects without authority. Never trade these boundaries or their required proof for speed, cost, or convenience.

## Product Gate

Ask one targeted operator question when the high-quality routes materially differ in product promise, public behavior, architecture/provider, data model, migration, pricing/claims, material cost, or irreversible business posture. Recommend the strongest professional default. Load `question-contract.md` and, for product meaning or acceptance, `product-decision-chain.md`.

## Operator Autonomy Gate

Gather safe evidence, diagnostics, logs, project context, and runnable proof before asking the operator. Sparse intent normally delegates diagnosis and localization; missing file paths or commands are not ambiguity. Ask only for a real decision, secret, privileged/manual-only evidence, unavailable environment, or operator-owned business truth. Load `operator-partnership-contract.md` only for broader partnership or initiative decisions.

## Followability Gate

Before completion, verify that a fresh agent can identify the owner, next required action, conditional reference, stop boundary, and proof from the activation path. If not, keep one compact directive at the owner layer and move detail to the narrowest direct reference. Skill-contract changes load `skill-instruction-layering.md` for the full gate.

## Conditional Routes

- UI, UX, layout, theme, responsive, motion, component, keyboard/IME, or visual work loads `skills/references/design-system-token-contract.md`; unexplained hardcoded visual values fail or remain partial.
- Model or delegated execution loads its dedicated routing/delegation authority while preserving this baseline.
- Conditional detail references load directly from the owner decision and never chain through sibling leaves.

Never present hidden debt as speed, and never present avoidable process or overengineering as quality.
