---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.1"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-09"
status: active
source_skill: 305-sg-init
scope: atlas-cartography-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/atlas/approved-surfaces.json
  - skills/305-sg-init/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/011-sg-pilotage/references/tasks-playbook.md
  - skills/references/atlas-protection-preflight.md
  - shipglows_data/business/business.md
  - shipglows_data/business/product.md
depends_on:
  - artifact: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md
    artifact_version: "2.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator decision 2026-08-02: the agent drafts the Atlas with the operator, who validates visual boundaries and quality."
  - "Operator decision 2026-08-02: stable semantic IDs are not assigned to every DOM div."
  - "Operator decision 2026-08-02: Atlas creation must guide business identity and customer-need formulation, not merely inventory implemented code."
  - "Pilotage consolidation on 2026-08-03 transferred the Atlas roadmap-view boundary to 011-sg-pilotage tasks."
next_review: "2026-09-02"
next_step: "/305-sg-init atlas <project>"
---

# Atlas Cartography Lifecycle

The project-owned Atlas is `shipglows_data/workflow/atlas/approved-surfaces.json`. It is the canonical map of the current and intended product; it is not a DOM inventory, a substitute for a spec, or a replacement for `TASKS.md`.

## Ownership And Entry Points

- `305-sg-init atlas <project>` owns the initial draft or a deliberate cartography refresh. It inspects routes, existing UI, components, and observable outcomes, then writes the smallest useful draft registry.
- The operator validates the visible boundaries and labels in Atlas mode. Only the operator judges Copy, Design, and observable Function quality; a draft starts at `unknown`, with no baseline or protection.
- `100-sg-spec` names the affected stable IDs and intended product-state transition when a spec creates, changes, splits, or retires a mapped surface/function.
- `102-sg-start` updates selectors, project-relative impact paths, function links, and delivery status alongside the implementation. It never turns an assessment into Gold/Diamond or renews a baseline by inference.
- `011-sg-pilotage tasks` may report Atlas status as a roadmap view, but `TASKS.md` remains the execution queue and specs remain the implementation contract.
- `700-sg-explore` resolves genuinely unclear product boundaries before an Atlas draft; it does not implement the registry.

## Business And Customer Intake

Before proposing the map, `305-sg-init atlas` reads the project's existing business, product, brand, GTM, public-surface, and current-site evidence when available. It synthesizes rather than repeats those facts back as a questionnaire.

When a material fact is missing, guide the operator with one plain-language business question at a time. Recover only the facts needed to shape the next map layer:

1. **Business identity:** who the product is for, the offer or transformation, and why it should be trusted or chosen.
2. **Customer need:** the customer's starting situation, job/pain, desired outcome, and meaningful failure or anxiety.
3. **Priority journey:** the first end-to-end journey that must work for this customer to reach value.

The agent first proposes a concise hypothesis from evidence, then asks the operator to correct or confirm it. Do not ask for technical architecture, components, routes, or an exhaustive feature list. Persist durable business/product decisions in their canonical project documents; the Atlas consumes them and does not become a competing business brief.

Turn the accepted priority journey into planned semantic surfaces and functions. Each proposed node must serve an observable customer outcome or delivery state; do not create features solely because a component or endpoint exists.

## Semantic ID Policy

Use lowercase dot-separated IDs such as `home.hero`, `checkout.payment`, and `payment.process`. The dot is a readable product namespace, not DOM nesting; IDs survive component, CSS, copy, or file refactors.

Create a `surface_id` only when at least one is true:

1. The operator could judge its Copy or Design independently.
2. It has an independent roadmap or delivery state.
3. Its protection scope should differ from its parent surface.

Do not create an ID for layout-only divs, wrappers, grids, spacing helpers, or implementation-only components. Use an optional `target_id` only for a meaningful sub-region that needs a separate selection or assessment. Put interactions, animations, and observable backend outcomes in the separate `functions` graph, linked to one or more surfaces.

Start broad and split only after a real independent decision emerges. Retire obsolete IDs rather than silently renaming or reusing them.

## Draft-To-Canonical Flow

1. Recover the business identity, customer need, and priority journey from the project corpus and concise operator dialogue.
2. Inspect the project and propose page/context → surface → optional target and the separate function links.
3. Write only the smallest useful draft to the project Atlas: stable IDs, labels, routes, stable selectors, `unknown` assessments, and known impact/dependency paths.
4. Present the named surfaces in the browser overlay; the operator accepts, merges, splits, or rejects the proposed boundaries.
5. Import explicit operator annotations; Gold/Diamond follow the protected-baseline flow, never a bootstrap shortcut.
6. On later product work, update the same registry when the map changes, then use the protection preflight before writes and at verification/ship gates.

## Pressure Scenarios

- `ATLAS-NO-DIV-SPRAWL`: a page has 60 divs; the initial draft contains only independently meaningful product surfaces, not DOM nodes.
- `ATLAS-DRAFT-NOT-APPROVAL`: an agent-created draft never receives Gold, Diamond, a baseline, or protection without explicit operator annotation and import.
- `ATLAS-SPLIT-DIMENSIONS`: a checkout can retain one visual surface while exposing several independently assessed functions.
- `ATLAS-ROADMAP-NOT-TRACKER`: Atlas delivery state informs prioritization, while the active task queue and spec lifecycle remain distinct.
- `ATLAS-MAP-DRIFT`: a new user-visible surface, removed surface, or changed dependency is reflected in the registry during the same implementation work.
- `ATLAS-CUSTOMER-LED`: a project has pages and components but weak positioning; the agent recovers the operator's customer outcome before treating implementation artifacts as product surfaces.
