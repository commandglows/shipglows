---
artifact: editorial_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-08"
updated: "2026-08-08"
status: active
source_skill: "sg-content"
scope: "public benefit-first language"
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/editorial/claim-register.md"
  - "shipglows_data/editorial/page-intent-map.md"
  - "shipglows_data/business/business.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/gtm.md"
  - "shipglows_data/branding/branding.md"
  - "skills/references/decision-quality-contract.md"
  - "skills/references/zombies-edge-case-heuristic.md"
  - "skills/references/clean-code-quality-contract.md"
  - "skills/references/owasp-application-security-awareness.md"
depends_on:
  - artifact: "shipglows_data/editorial/claim-register.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-08-08: familiar reader understanding comes before technical vocabulary; technical terms remain accurate second-level proof."
  - "Public benefit-first language spec defines the relevant mechanisms, claim limits, and shared English/French surfaces."
next_review: "2026-11-08"
next_step: "Apply to the declared public-site batches in public-benefit-first-language-for-shipglows-skills.md"
---

# Public Benefit-First Language

## Purpose

Use this guide when public ShipGlows copy explains a workflow, skill, quality gate, or delivery practice. Lead with the practical change a capable founder can recognize. Put the technical mechanism next only when it makes the promise more credible, useful, or actionable.

This is a wording guide, not a new product claim. `claim-register.md` remains the authority for sensitive claims; source skills remain the authority for actual workflow behavior.

## Copy Order

Use this order whenever space allows:

1. **Reader outcome:** what becomes clearer, safer to decide, easier to verify, or less likely to be missed.
2. **Technical evidence:** the contract, check, workflow, or term that supports that outcome.
3. **Proof or limit:** for security, quality, autonomy, speed, savings, or any claim a reader could mistake for a guarantee.

Short cards, labels, and CTAs may omit the second step for space, but must not become a stronger claim. Preserve the technical term in nearby body copy, a detail, or a linked public skill/docs path.

## Approved Translations

| Mechanism | Reader outcome first | Technical evidence second | Allowed wording / claim limit |
| --- | --- | --- | --- |
| Context map | A new agent can start without making you reconstruct the project. | An operational context map identifies the relevant entry points, constraints, and documents. | Say “gives agents better context” or “reduces context reconstruction”; do not say an agent always understands the project. |
| Task or spec contract | Important work is framed before the product changes. | A task contract records scope, invariants, proof, and stop conditions. | Say “makes the intended change explicit”; do not say it prevents every wrong change. |
| Readiness | Risks and missing decisions are surfaced before implementation. | Readiness checks confirm the contract, ownership, and proof path are sufficiently clear. | Say “surfaces unresolved decisions”; do not imply all risks are discovered. |
| Verification | A green build is not the only signal used to judge completion. | Verification compares the result with the stated behavior, evidence, and relevant checks. | Say “makes completion evidence visible”; do not say “proves it is correct.” |
| Decision-quality gate | Speed does not automatically outrank correctness, security posture, or maintainability. | The decision-quality contract prioritizes the relevant trade-offs for the work. | Say “prioritizes” or “checks proportionally”; do not promise best-practice, high-quality, or defect-free code. |
| ZOMBIES | Important edge cases are considered before calling non-trivial work complete. | ZOMBIES challenges zero, one, many, boundaries, interfaces, exceptions, and simple scenarios. | Say “examines relevant edge cases”; do not say it covers every edge case. |
| Clean Code gate | A change is easier to read and evolve when its structure remains understandable. | The pragmatic Clean Code gate reviews naming, cohesion, complexity, side effects, and behavior-focused proof. | Say “reviews maintainability concerns”; do not guarantee maintainability or prescribe a style religion. |
| OWASP and selected ASVS | Relevant application-security risks are considered when the work warrants it. | OWASP Top 10 awareness and selected, verifiable ASVS requirements inform the security gate. | Say “uses OWASP awareness” and “selected ASVS requirements where relevant”; never imply compliance, certification, complete coverage, or vulnerability prevention. |
| Read-only parallel investigation | Independent parts of a project can be understood sooner without changing it. | Read-only research may run in parallel when surfaces are independent. | Say “can inspect independent areas in parallel”; do not say every task is parallelized or faster. |
| Write Execution Batches | Concurrent changes are used only when responsibilities and proof are deliberately separated. | Predefined write batches assign exclusive files and validation. | Say “keeps simultaneous changes controlled”; do not imply conflict-free or autonomous delivery. |
| Server-aware delivery | The code and the environment required to deliver it stay connected. | Delivery work can retain environment, process, routing, health, and log evidence in the workflow. | Say “keeps delivery context visible”; do not promise uptime, deployment success, or production safety. |

## Shared English/French Patterns

Use native-language equivalents, not literal technical slogans. These examples define the strength boundary, not mandatory page copy.

| Situation | English | Français |
| --- | --- | --- |
| Context | “A new agent can start without making you reconstruct the project.” | “Un nouvel agent peut commencer sans vous faire reconstruire le projet.” |
| Work framing | “Important work is framed before the product changes.” | “Les changements importants sont cadrés avant de modifier le produit.” |
| Verification | “A green build is not the only signal used to judge completion.” | “Un build vert n’est pas le seul signal utilisé pour juger qu’un travail est terminé.” |
| Edge cases | “Relevant edge cases are examined explicitly.” | “Les cas limites pertinents sont examinés explicitement.” |
| Code quality | “The change is reviewed for clarity and maintainability concerns.” | “Le changement est examiné pour sa lisibilité et les enjeux de maintenabilité.” |
| Security | “Relevant security risks are considered proportionally to the work.” | “Les risques de sécurité pertinents sont examinés proportionnellement au travail.” |
| Delegation | “Independent areas can be inspected in parallel before writing begins.” | “Des zones indépendantes peuvent être inspectées en parallèle avant les modifications.” |

## Anti-Overclaim Rules

- Do not turn a check into a guarantee: no “secure,” “bug-free,” “correct,” “maintainable,” or “production-ready” without the exact, sufficient evidence.
- Do not turn awareness into compliance: no “OWASP compliant,” “ASVS compliant,” “certified,” “complete coverage,” or “prevents vulnerabilities.”
- Do not turn a heuristic into exhaustive proof: ZOMBIES identifies relevant cases; it does not prove all cases were found.
- Do not turn coordination into autonomy: ShipGlows can orchestrate guarded workflows; it does not promise unattended shipping or replace engineering judgment.
- Do not turn parallelism into a speed claim: use it only for independent, read-only inspection or preplanned exclusive write batches; do not claim universal parallelism or measured time savings.
- Do not invent customer, conversion, reliability, revenue, adoption, availability, or ROI evidence. Use qualitative, evidence-safe language until proof exists.
- If the technical mechanism cannot be translated truthfully, keep it in a technical context and explain it rather than inventing a familiar but false analogy.

## Review Prompt

Before publishing, ask: **Can a newcomer name the practical outcome before decoding the technical term, and does the supporting sentence preserve the exact proof and limit?** If either answer is no, revise or remove the claim.
