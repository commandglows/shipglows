---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-18"
status: active
source_skill: 900-shipglows-core
scope: human-centered-interaction-heuristics
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - tools/test_human_centered_interaction_heuristics.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved sourced interaction-heuristics theme from the Awwwards tools watch on 2026-08-15."
  - "Design and customer playbooks require a common boundary between observed evidence, usability heuristics, checklists, and pattern inspiration."
next_review: "2026-11-13"
next_step: "/103-sg-verify human-centered interaction heuristics"
---

# Human-Centered Interaction Heuristics

## Purpose

Use this contract when a design audit, customer journey, flow, onboarding path, or interaction recommendation relies on cognitive laws, usability heuristics, checklists, design principles, or pattern-library examples. It turns those materials into bounded decision aids without presenting them as user research, standards conformance, or universal proof.

## Evidence Before Heuristics

Start from the user goal and the actual product state. Use the strongest available evidence in this order:

1. observed behavior in the target product, including rendered states and failure/recovery paths;
2. direct target-user evidence, support evidence, behavioral data, or representative usability research;
3. standards-based accessibility and platform evidence;
4. relevant real-world patterns with known context;
5. checklists, principles, and heuristic inference.

Lower levels may identify a plausible risk or design hypothesis. They do not inherit the confidence of higher levels. State the evidence level and confidence whenever the distinction could change severity or acceptance.

Heuristics generate hypotheses and findings; they do not automatically establish defects. A checklist supports coverage but never proves completeness or quality.

## Interaction Lenses

Apply only lenses relevant to the user goal and observed condition:

- **Cognitive load and chunking:** keep the current decision understandable; use grouping and progressive disclosure without hiding required consequences.
- **Choice complexity:** reduce irrelevant or undifferentiated options, but preserve necessary comparison, expert control, and safe escape routes. Hick-style reasoning is contextual, not an instruction to minimize every choice.
- **Target acquisition:** make important controls reachable and large enough for the target device and input. Fitts-style reasoning does not replace target-size, spacing, zoom, or assistive-technology proof.
- **Familiarity and mental models:** prefer recognizable language and behavior when it helps transfer learning. Familiarity does not justify retaining a deceptive, inaccessible, or harmful convention.
- **Visibility and feedback:** make status, cause, progress, success, failure, and next action perceptible at the right time.
- **Recognition and continuity:** keep context visible and reduce unnecessary recall across screens, interruptions, and recovery.
- **User control and reversibility:** provide safe back, cancel, defer, undo, retry, and resume paths where the consequence warrants them.
- **Error prevention and recovery:** prevent predictable mistakes, preserve user work, explain consequences, and provide an actionable recovery.
- **Consistency with purpose:** keep interaction grammar coherent while allowing a justified exception when the user goal, platform, or risk differs.
- **Accessibility and trust:** preserve semantic operation, keyboard and assistive access, clear consent, honest claims, privacy consequences, and non-coercive choices.

## Finding Contract

For every heuristic finding, record:

```text
Observed condition:
User goal and consequence:
Evidence type and confidence:
Relevant heuristic or standard:
Context or competing heuristic:
Recommended outcome:
Proof needed:
```

A heuristic mismatch is not automatically a defect. Severity comes from the observed consequence, affected users, frequency, reversibility, trust/safety impact, and evidence confidence. When heuristics conflict, prefer the outcome supported by the target user's goal, product promise, platform conventions, risk, and representative evidence; never decide by counting rules.

## Source Roles And Limits

The following sources informed this contract. Consulted 2026-08-15; recheck freshness, access terms, and the specific source content when it materially governs a future decision.

| Source | Role in this contract | What it does not prove |
| --- | --- | --- |
| [Laws of UX](https://lawsofux.com/) | Discovery vocabulary for psychology-informed interface heuristics and their design implications. | That a named law applies universally, that one prescribed treatment is optimal, or that the target users were tested. |
| [Checklist Design](https://www.checklist.design/) | Coverage aid for screen, component, and flow states that may deserve inspection. | Exhaustiveness, implementation quality, accessibility conformance, or completion merely because items were checked. |
| [Mobbin](https://mobbin.com/) | Contextual inspiration from real interface screens and flows; useful for generating pattern hypotheses and comparison questions. | User research, conversion impact, accessibility, legal permission to copy, suitability for another product, or verified best practice. |
| [Design Principles](https://principles.design/) | Examples of how organizations articulate product and design principles; useful when drafting project-specific decision criteria. | Authority to import another organization's principles unchanged or evidence that a principle fits the current product. |
| [Nielsen Norman Group: 10 Usability Heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/) | Established general heuristics for visibility, control, consistency, error handling, recognition, efficiency, and help. | A substitute for usability testing, product-specific evidence, or accessibility evaluation. |
| [W3C Web Content Accessibility Guidelines 2.2](https://www.w3.org/TR/WCAG22/) | Normative web-accessibility success criteria and conformance vocabulary where applicable. | Automatic conformance from a checklist, a single automated scan, or visual inspection alone. |

These are references, not adopted dependencies or endorsements. Do not reproduce proprietary screens or substantial source text. Attribute quoted or closely derived material, keep excerpts minimal, and extract reusable interaction reasoning rather than copying an interface or brand system.

## Pattern And Checklist Intake

When using Mobbin or another pattern library:

1. record the product category, platform, visible state, and date if known;
2. identify the interaction hypothesis rather than copying the composition;
3. compare at least the target product's content, users, platform, states, risks, and design-system authority;
4. inspect failure, loading, empty, permission, responsive, keyboard, and recovery states when applicable;
5. verify the resulting recommendation in the target product.

When using Checklist Design or another checklist, treat uncovered items as prompts for inspection. A checked item means only that it was considered; record the evidence and result separately. Never call a review exhaustive because a third-party checklist was completed.

## Proof And Claims

- Do not claim `user-tested`, `validated`, `proven`, `best practice`, `accessible`, `intuitive`, or `conversion-improving` from heuristic alignment, a screenshot, or checklist completion alone.
- Accessibility conclusions require applicable WCAG/platform criteria plus manual, rendered, keyboard, zoom/reflow, and assistive-technology evidence proportional to the claim.
- Behavioral or business-impact conclusions require representative user or product evidence; similarity to a successful product is not causal evidence.
- If only heuristic evidence exists, report a hypothesis, expected consequence, confidence, and the next proof needed.
- Preserve contradictory evidence and explain why one outcome wins in context.

## Stop Conditions

Stop or narrow the claim when the target user or goal is unknown, the source context is unavailable, the recommendation would copy proprietary expression, a material heuristic conflict has no product basis, or the requested confidence exceeds available evidence. Route visual-system craft to `006-sg-design`, customer-path meaning to `008-sg-customer`, and representative proof to the applicable test/browser/accessibility owner.
