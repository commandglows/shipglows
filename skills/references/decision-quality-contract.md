---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.3.1"
project: ShipGlows
created: "2026-05-24"
updated: "2026-11-21"
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
  - skills/references/functional-excellence-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/master-delegation-semantics.md
  - skills/references/operator-partnership-contract.md
  - skills/references/question-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/skill-instruction-layering.md
  - tools/test_industrial_excellence_contract.py
depends_on:
  - artifact: skills/references/functional-excellence-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 15: universal gates here, implementation pressure in one direct leaf."
  - "2026-08-24: functional excellence precedes conception and implementation."
next_review: "2026-09-12"
next_step: "/103-sg-verify decision-quality-contract"
---

# Decision Quality Contract

## Decision Quality Baseline

Set the mandatory decision posture: ship useful product value quickly through the smallest coherent architecture for the accepted horizon. The primary goal is shipped business and user value; architecture, security, and proof enable it. Optimize in order:

1. identify the smallest valuable product outcome to ship and learn from;
2. choose the shortest credible path to production or real-user feedback;
3. preserve correctness and reliability;
4. use coherent boundaries and maintainable architecture proportionate to the product horizon and demonstrated evolution pressure;
5. preserve security, privacy, permissions, tenant isolation, data safety, and abuse resistance;
6. protect performance and robustness where they affect use, cost, reliability, or trust;
7. gather only proof proportional to the claim and cost of error.

Once the floor is met, prefer the faster, simpler, smaller implementation; slow down only for a concrete risk or near-term dead end. Do not trade shipping speed for speculative architecture, ceremonial process, optional proof, or hypothetical requirements.

`Smallest safe path` keeps the accepted outcome, coherent ownership, non-negotiable safety, and maintainability; small blast radius is a strength, hidden debt is not.

## Functional Excellence Gate

Before conception or implementation, load `skills/references/functional-excellence-contract.md` for material outcomes and durable artifacts. Accept the smallest complete, honest, durable form; `Minimal` never means incomplete or weaker safety, accessibility, recovery, nuance, or proof.

## Industrial Excellence Gate

`industrial-grade` completion scales with consequence. Work merely functional, unintentionally generic for the accepted product, or with unresolved provisional elements presented as final is `partial`; complexity, extra layers, and long validation rituals are not excellence. NASA, government, ANSSI, RGAA, and SecNumCloud claims require a framework-specific scoped audit and direct evidence.

## Structure Replacement Fit

A new rule, tool, layer, dependency, or process must replace a weak point, ambiguity, drift, or burden; otherwise do not add it.

## Fast Fix Shortcut Gate

A change fails when it hides root cause, bypasses durable ownership, weakens proof, or leaves an incoherent exception. Use `root cause -> owner boundary -> smallest complete professional fix -> matching proof`. Label mitigation honestly; never report it as completion.

Load `skills/references/decision-quality-implementation-discipline.md` only when implementation, repair, mitigation, tool choice, or shortcut pressure requires the detailed discipline.

## Safety Gate

Stop before unauthorized changes to security, privacy, permissions, tenant boundaries, data, destructive behavior, secrets, irreversible state, or external effects. Never trade these boundaries for speed.

## Product Gate

Ask one targeted question when sound routes differ in product promise, public behavior, architecture, data, pricing, or irreversible posture. Recommend the strongest default. Load `question-contract.md` and, for product meaning, `product-decision-chain.md`.

## Operator Autonomy Gate

Gather safe evidence and runnable proof before asking. Sparse intent delegates diagnosis; missing paths or commands are not ambiguity. Ask only for a decision, secret, manual-only evidence, unavailable environment, or operator-owned truth. Load `operator-partnership-contract.md` for broader decisions.

## Followability Gate

Before completion, ensure a fresh agent can find the owner, next action, conditional reference, stop, and proof. Otherwise keep one owner directive and move detail to the narrowest direct reference. Skill-contract changes load `skill-instruction-layering.md`.

## Conditional Routes

- UI, UX, layout, theme, responsive, motion, component, keyboard/IME, or visual work loads `skills/references/design-system-token-contract.md`; unexplained hardcoded visual values fail or remain partial.
- Model or delegated execution loads its dedicated routing authority; this baseline still applies.
- Conditional detail references load directly from the owner decision and never chain through sibling leaves.

Never present hidden debt as speed, and never present avoidable process or overengineering as quality.
