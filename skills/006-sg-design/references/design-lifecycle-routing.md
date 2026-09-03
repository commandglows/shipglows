---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-09-03"
status: active
source_skill: 006-sg-design
scope: design-lifecycle-routing
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/
  - skills/108-sg-browser/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/006-sg-design/references/animation-playbook.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-22 adds identity as a first-class design outcome with explicit marketing, content, implementation, Git, and human-usability boundaries."
  - "Operator decision 2026-09-03 adds interface as the explicit mode for UI composition within established product, brand, and design-system direction."
  - "Operator decision 2026-09-03 requires state and transition modeling for stateful, temporal, Rive-driven, and 3D-driven interface work."
  - "2026-07-15 consolidation replaced six public specialist routes with explicit 006-sg-design modes and bounded playbooks."
  - "2026-08-04 added the provider-neutral animation mode and its bounded playbook."
next_review: "2026-08-15"
next_step: "/104-sg-end consolidate design skill surface into modes and playbooks"
---

# Design Lifecycle Routing

## Purpose

Define how `006-sg-design` routes design work after activation.

Use this reference after loading:

- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`
- `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`

## Canonical Mode Grammar

Public `sg-design` accepts these commands: `identity [scope]`, `interface [scope]`, `system [scope]`, `playground [route-path]`, `audit ui [scope]`, `audit tokens [scope]`, `audit components [scope]`, `audit a11y [scope]`, `animation <audit|design|implement|tune> [scope]`, `redesign [scope]`, `migration [scope]`, and the separately defined `library ...` operations. `tokens-only` and `with-playground` are optional modifiers of `system`, not public skill aliases. `gsap` is not a public mode or alias.

`identity` loads `brand-identity-playbook.md`. It creates or evolves the visual identity system from governed business, audience, positioning, promise, and brand truth. Marketing owns market, offer, positioning, message strategy, and verbal foundations; design owns art direction and the visual identity system; content owns editorial expression; implementation owners apply the accepted system to technical surfaces. One public owner retains the outcome and coordinates these boundaries internally.

`interface` owns the visual and interaction composition of a page, screen, or bounded product surface when product intent, journey, brand direction, and design-system authority are already established. It covers hierarchy, layout, responsive behavior, component composition, interaction presentation, and applicable accessibility. It does not silently redefine the customer journey, product behavior, brand identity, or design-system foundations; route those material changes through their existing owners or modes. Load reference-driven frontend guidance when visual references define the target. For stateful, temporal, session-based, continuously interactive, Rive-driven, or 3D-driven surfaces, load `$SHIPGLOWS_ROOT/skills/references/interactive-state-transition-contract.md` and define the behavioral model before visual completion. Use the normal design proof contract before completion.

`audit` without a subtype, an unknown subtype, or an invalid mode must list these supported choices or ask one targeted routing question. Never infer an audit subtype. Load only its mapped primary playbook after a valid selection; `audit ui deep` may then load the three explicit companion audit playbooks required by its contract.

`redesign` is a lifecycle route, not a hidden implementation shortcut: establish current-state evidence with `audit ui` when needed, apply the Inspiration Gate when direction changes, frame a ready spec, then route implementation and visible proof. `migration` loads the token-migration playbook, establishes design-token consumption with `audit tokens`, and uses spec-first execution for cross-surface work.

When screenshots, mockups, appshots, or visual references define the frontend target, load `$SHIPGLOWS_ROOT/skills/006-sg-design/references/reference-driven-frontend-playbook.md` directly. Keep the selected public mode unchanged. The ready contract must inventory representative widths and product-relevant states, identify the repository-native component and design-token authorities, and require iterative rendered comparison against the references rather than build-only proof.

`animation` loads `animation-playbook.md` after the matching token and proof
contracts. Missing or unknown animation actions must list exactly `audit`,
`design`, `implement`, and `tune`, then perform no source edit. Audit and
design are read-only. Implement applies a ready motion contract; tune preserves
its motion concept while making bounded refinements. Broad whole-page or
multi-section implementation is spec-first.

## Routing Rule

Choose the smallest safe owner: the bounded professional route that preserves centralized design tokens, brand coherence, accessibility, performance, maintainability, and proof.

Do not ask the user to choose a specialist when the request clearly names an intent. When two routes are plausible and the answer changes scope, proof, brand direction, public claim, or ship risk, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and ask one numbered decision question.

## Scope And Readiness Rules

Use direct routing for:

- read-only design audits
- one focused specialist action
- one narrow page/component fix that can be described as a mini-contract
- playground scaffolding when the token layer and route are clear

Require spec-first for:

- broad redesign
- multi-page or cross-component token migration
- new visual direction, palette, typography, or brand shift
- public/product-critical UI surfaces
- accessibility remediation across flows
- work that claims no visual regression across many pages
- changes that affect screenshots, public claims, onboarding, pricing, docs, or trust signals
- broad whole-page or multi-section animation implementation

Before implementation, the ready spec must name:

- user-facing outcome
- target pages/components/layouts
- design source of truth or brand docs
- intended visual change or explicit non-regression contract
- token/theme/component/source-of-truth plan for any visual dimensions, spacing, overlays, IME/keyboard behavior, or responsive layout values
- mode playbook and lifecycle or proof skills to run
- validation and browser proof obligations
- reference viewport/state inventory and acceptable project-system adaptations when visual references are the target
- state/transition matrix, temporal invariants, runtime adapter and fallback boundaries, and transition-test obligations when the interactive-state contract applies
- docs/editorial impact
- ship/deploy posture

## Mode And Lifecycle Sequencing

Typical flow for design-system creation:

```text
006-sg-design system -> 006-sg-design audit tokens -> 006-sg-design playground optional -> 103-sg-verify
```

Typical flow for interface creation or evolution:

```text
006-sg-design interface -> 100-sg-spec when broad or product-critical -> 102-sg-start -> 108-sg-browser -> 103-sg-verify
```


Typical flow for brand identity creation or evolution:

```text
006-sg-design identity -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> identity proof -> 103-sg-verify -> commit/push -> authorized application
```

Typical flow for token migration across a site:

```text
006-sg-design audit tokens -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 105-sg-check -> 006-sg-design audit tokens -> 108-sg-browser -> 103-sg-verify -> 104-sg-end -> 005-sg-ship
```

Typical flow for visual redesign:

```text
006-sg-design audit ui -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 105-sg-check -> 108-sg-browser -> 006-sg-design audit a11y as needed -> 103-sg-verify -> 104-sg-end -> 005-sg-ship
```

Typical flow for deep design audit:

```text
006-sg-design audit ui deep -> 100-sg-spec for chosen remediation -> 101-sg-ready -> 102-sg-start -> proof -> 103-sg-verify
```

Typical flow for accessibility-first design fix:

```text
006-sg-design audit a11y -> 100-sg-spec or 106-sg-fix depending scope -> 108-sg-browser/107-sg-test proof -> 103-sg-verify
```

Typical flow for whole-page animation:

```text
006-sg-design animation audit|design -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 105-sg-check -> 108-sg-browser -> 103-sg-verify -> 104-sg-end -> 005-sg-ship
```

For design work that changes public wording, claims, docs screenshots, page promises, or content surfaces, run the editorial/docs gates from `001-sg-build` or route to `300-sg-docs`/`007-sg-content` as needed before closure.

## Security And Safety

- Never expose private screenshots, logs, secrets, credentials, or internal operational data in design reports.
- Never weaken contrast, focus visibility, keyboard access, target size, or reduced-motion behavior to satisfy token discipline.
- Never invent a brand identity, palette, typography, or public claim when the existing project context does not support it.
- Never treat screenshots alone as sufficient proof for accessibility.
- Never ship unrelated dirty files.
