---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-05"
updated: "2026-08-05"
status: active
source_skill: 006-sg-design
scope: landing-page-experience-coherence
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/references/design-audit-playbook.md
  - skills/006-sg-design/references/component-system-audit-playbook.md
  - skills/009-sg-marketing/references/copywriting-audit-playbook.md
  - skills/references/landing-page-copywriting-framework.md
  - skills/references/design-system-token-contract.md
depends_on:
  - artifact: skills/references/landing-page-copywriting-framework.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decisions from a ReplayGlowz landing-page redesign exposed semantic repetition hidden by different section designs, inconsistent card grammar, and whole-page harmony failures."
  - "Operator decision on 2026-08-05: page and site design decisions require global homogeneity and harmony, not isolated section quality."
next_review: "2026-09-05"
next_step: "/103-sg-verify landing-page experience coherence"
---

# Landing-Page Experience Coherence

## Purpose And Owner Boundary

Coordinate narrative and visual coherence for landing, sales, and offer pages without merging métier ownership. `009-sg-marketing copywriting` and `landing-page-copywriting-framework.md` own reader questions, unique section jobs, argument sequence, repetition, claims, proof, objections, and CTA progression. `006-sg-design` owns visual grammar, alignment, iconography, hierarchy, responsive composition, component behavior, motion, and rendered proof.

The shared outcome is one coherent page, not two independent audit reports. A semantic duplicate cannot be saved by a different design, and a valid narrative sequence can still fail when its sections do not belong to one visual system.

## Coordination Sequence

1. Inventory the current sections and operator-approved strengths before replacement.
2. Apply the copywriting framework's Section Role, Claim/Proof, and Repetition Ledgers.
3. Resolve `keep|move|merge|delete|create|narrow` decisions before polishing duplicated sections.
4. Group retained sections into semantic component families.
5. Establish family grammars and one whole-page harmony contract.
6. Define justified exceptions, motion end behavior, and proportional rendered proof.

Do not rewrite accepted copy merely because its container is inconsistent. Do not preserve a repeated idea merely because its container is visually distinctive.

## Semantic Duplication Behind Visual Variation

Compare semantic roles independently from visual treatment. Distinct layouts, icon scales, colors, illustrations, or card styles do not create distinct sections when they answer the same reader question, express the same promise, or perform the same decision job.

Flag this as `semantic duplication disguised by visual variation`. A later section is retained only when the copywriting Repetition Ledger names added proof, specificity, contrast, objection handling, recap value at a real decision point, or decision value. Otherwise decide `merge`, `delete`, `move`, or `narrow` before design refinement. Never spend design effort harmonizing or polishing both duplicates merely to preserve two component patterns.

## Component-Family Grammar

Build a compact section-family inventory covering:

- semantic role: benefit, feature, step, proof, comparison, pricing, recap, or action;
- content anatomy and order;
- alignment axis;
- icon or media scale and placement;
- heading, body, metadata, and action hierarchy;
- card surface, border, radius, and elevation logic;
- spacing and density;
- grid, row, stack, and responsive reflow behavior.

Across equivalent sections, use one dominant visual grammar or declare a material semantic, responsive, accessibility, brand, or interaction reason for each variant. Flag unexplained drift such as one equivalent section left-aligned and the next centered, large leading icons followed by small incidental icons, or the same card content reordered without a different reader need.

When the operator identifies a preferred existing section, treat it as evidence for the target grammar. Extract its reusable anatomy and design-token relationships rather than copying incidental literals. No alignment, icon scale, or layout direction is universally preferred; unexplained variation is the failure.

## Whole-Page Harmony Contract

Establish shared spatial rhythm, proportional hierarchy, iconography language, surface and elevation logic, typographic cadence, alignment relationships, container widths, responsive transitions, and motion intensity across all section families.

Different roles may use different components, but every family must feel intentionally related through the same design-system authority. Judge transitions between sections as carefully as individual sections. A sequence of polished blocks still fails when scale, density, visual weight, or motion changes arbitrarily from one block to the next.

Use an explicit exception budget. Every departure names the reader, content, responsive, accessibility, brand, or interaction purpose it serves. Several individually defensible exceptions still fail when their cumulative effect fragments the page. Recommend the smallest system-level set of shared rules that restores harmony while preserving purposeful hierarchy and contrast.

## Primary Path, Secondary Summary, And Proof

Distinguish the primary persuasion path from useful secondary scan content. Strong feature or benefit cards may be moved after pricing or the primary CTA when they remain useful as recap but would duplicate or interrupt the main sequence. Placement is contextual, not a universal template.

Place supported social proof where it resolves uncertainty around the claim, mechanism, fit, price, or action it supports. A compact proof rail below a hero trust statement may outperform a remote generic testimonial section; complex proof may still need a dedicated section. Never invent testimonials, counts, portraits, results, or provenance.

## Continuous Content Behavior

For a carousel, marquee, testimonial rail, or repeated-card track described as cyclic, infinite, seamless, or continuously looping, require behavior proof. Duplicated markup or an infinite animation declaration is not evidence.

A claimed continuous loop must show no reachable blank interval, dead tail, visible seam, or reset jump during manual interaction and autoplay when applicable. Cover supported widths, resize, remount or route return, reduced-motion behavior, and dynamic or localized content. Route full keyboard, announcements, pause/control, and focus proof to the accessibility audit; route timing, cleanup, lifecycle, and performance proof to the animation playbook. A finite rail is valid only when its terminal state is explicit.

## Decision Supersession

When operator decisions evolve, the latest explicit decision supersedes an earlier conflicting instruction only for its stated scope. Preserve unrelated constraints and record the supersession when it materially changes page structure or proof obligations. Do not combine contradictory instructions into an unchosen compromise.

## Required Output

- semantic duplicate decisions before visual polish;
- retained operator-approved strengths;
- component-family inventory and dominant grammar;
- whole-page harmony contract and exception budget;
- primary versus secondary placement decisions;
- proof placement and evidence dependencies;
- motion end-state and continuity contract where applicable;
- rendered, responsive, accessibility, and reduced-motion proof plan.

## Pressure Scenarios

### LPX-VISUAL-DISGUISED-DUPLICATION

Given two differently presented sections that answer the same reader question or express the same promise without material added value, visual difference is not evidence of a unique role. The system must not preserve both sections merely because their designs differ. Resolve `merge|delete|move|narrow` through the copywriting sequence authority before polishing both sections.

### LPX-CROSS-SECTION-GRAMMAR

Given equivalent card sections whose alignment, icon scale, content order, density, or surface changes without a named reason, identify the dominant or operator-preferred grammar, preserve justified exceptions, and recommend system-level harmonization.

### LPX-WHOLE-PAGE-HARMONY

Given internally consistent section families that collectively use unrelated rhythm, proportions, iconography, surfaces, widths, or motion intensity, define one whole-page harmony contract and assess cumulative exception cost.

### LPX-CYCLIC-CONTINUITY

Given a horizontal testimonial or card rail claimed to loop continuously, any reachable blank space, dead tail, visible seam, or reset jump fails the contract until manual/autoplay, responsive, remount, reduced-motion, and content-variation proof succeeds or the rail is explicitly finite.

### LPX-SUPERSESSION

Given a later explicit operator decision that conflicts with an earlier scoped instruction, apply the latest decision to its stated scope, retain unrelated boundaries, and record the supersession.
