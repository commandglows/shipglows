---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 006-sg-design
scope: reference-driven-frontend-design
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - tools/test_sg_design_contract.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "OpenAI Learn, Build responsive front-end designs, reviewed 2026-08-13."
  - "OpenAI curated playwright-interactive skill, reviewed 2026-08-13."
next_review: "2026-09-13"
next_step: "/103-sg-verify reference-driven frontend design contract"
---

# Reference-Driven Frontend Playbook

## Activation

Load this playbook when screenshots, mockups, appshots, design briefs with visual targets, or other visual references define the intended frontend result. It refines the existing `redesign` or narrow page/component route; it does not create a new public mode.

## Reference Contract

Before implementation, inventory the evidence that materially changes the result:

- representative desktop and mobile compositions or explicit supported widths
- hover, focus, selected, expanded, disabled, loading, empty, error, and success states when shown or product-relevant
- long or localized content, dynamic data, and content-density variations that can change layout
- motion, reduced-motion, resize, and input-mode behavior when applicable
- intended hierarchy, spacing, alignment, typography, imagery, and interaction direction

A single reference may be sufficient for a narrow surface. Do not invent missing product behavior. Choose the simplest project-native interpretation for non-material visual ambiguity and record it briefly; stop for a material brand, product, or interaction decision.

## Project-Native Translation

Treat the references as the observable visual target, not as a foreign implementation specification. Inspect the repository's routing, state, data-fetch, styling, design-token, component, typography, icon, and asset conventions before editing.

Reuse canonical components, wrappers, variants, utilities, and semantic design tokens. Translate the reference into those authorities instead of creating a parallel component layer, copying vendor internals, or introducing screen-local visual literals. When the reference conflicts with the project system, preserve accessibility, behavior, performance, and maintainability; make the smallest system-level adjustment that retains the intended direction and report the material deviation.

Do not imitate protected source code or proprietary assets merely because a visual reference was supplied. Recreate the design intent through original, project-owned implementation and appropriately licensed assets.

## Responsive Implementation

Derive responsive behavior from content priority and the project's canonical breakpoints rather than shrinking a desktop screenshot mechanically. Define what reflows, stacks, wraps, scrolls, condenses, changes order, or disappears, and preserve readable hierarchy, focus order, touch targets, safe areas, zoom, dynamic type, and localization.

Use the smallest representative viewport matrix supported by the evidence and product contract. Desktop and mobile are the default minimum when both surfaces are in scope; add intermediate widths only where layout behavior changes materially.

## Iterative Rendered Proof

Browser comparison is part of implementation, not a final screenshot ceremony:

1. render each representative viewport and applicable state in a real browser
2. compare hierarchy, composition, spacing, alignment, typography, imagery, overflow, interaction, and responsive behavior against the references
3. classify mismatches as material, acceptable project-system adaptations, or unresolved evidence gaps
4. correct material mismatches through the canonical component/token layer
5. rerender affected viewport-state pairs and repeat until the accepted target is met or a real blocker remains

For non-auth implementation signoff, hand the reference viewport/state inventory and intended visible claims to `108-sg-browser` as its bounded QA inventory. Require separate functional, viewport-fit, and visual-quality verdicts; a visually clipped result fails even when numeric layout metrics appear acceptable. Reuse a persistent browser session across iterations only when the current runtime exposes that capability.

A build, lint, unit test, DOM snapshot, or source inspection alone never proves reference fidelity. Visual similarity alone never proves accessibility or interaction correctness. Preserve the dedicated accessibility, reduced-motion, performance, auth, and hosted-proof routes.

## Pressure Scenario

`DESIGN-REFERENCE-001`: Given a fresh agent receives screenshots or visual references for a frontend surface, when it implements the target in an existing repository, then it inventories relevant widths and states, reuses canonical components and design tokens, translates rather than copies the reference, compares rendered browser evidence back to the target, and iterates on material mismatches before reporting completion.

## Stop Conditions

Report `partial` or `blocked` when a material target state or viewport cannot be observed, the repository has no identifiable design-system authority, the requested fidelity would weaken accessibility or behavior, a reference requires unlicensed assets or copied implementation, or browser evidence cannot be collected for a visual-completion claim.
