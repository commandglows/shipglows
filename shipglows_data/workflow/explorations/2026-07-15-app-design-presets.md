---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: draft
source_skill: 700-sg-explore
scope: app-design-presets
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/009-sg-skill-build/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/306-sg-scaffold/SKILL.md
  - skills/500-sg-design-from-scratch/SKILL.md
  - skills/501-sg-design-playground/SKILL.md
  - skills/references/app-blueprints.md
  - skills/references/design-inspiration-library.md
  - skills/references/design-system-token-contract.md
  - skills/app-blueprints/README.md
evidence:
  - "Operator request 2026-07-15: combine application blueprints with a selectable pool of reusable visual styles."
  - "The current Blueprint Gate pre-fills architecture, stack, models, routes, and conventions but has no selectable visual-preset catalog."
  - "The current private inspiration library stores source-derived references but is not an installable design system."
  - "Current ShipGlows design skills create, preview, and audit project token systems but do not distribute reusable first-party presets."
depends_on: []
supersedes: []
next_step: "/100-sg-spec app design preset library and Design Preset Gate"
---

# Exploration Report: App Design Presets

## Starting Question

How can ShipGlows combine reusable application blueprints with a choice of professional visual styles, so an operator can understand and select the future appearance of a new app before scaffolding it?

## Context Read

- `skills/references/app-blueprints.md` - established that blueprints are functional and architectural skeletons.
- `skills/app-blueprints/README.md` - confirmed that the current catalog contains one Flutter CRUD blueprint and no separate visual catalog.
- `skills/001-sg-build/SKILL.md` - located the Blueprint Gate and the point where a visual-selection gate can be inserted.
- `skills/006-sg-design/SKILL.md` - confirmed current design routing, inspiration selection, and token-system responsibilities.
- `skills/references/design-inspiration-library.md` - confirmed that captured third-party references are private analysis inputs, not reusable templates.
- `skills/references/design-system-token-contract.md` - established that every applied preset must compile into the project's canonical token/theme/component sources.
- `skills/500-sg-design-from-scratch/SKILL.md` and `skills/501-sg-design-playground/SKILL.md` - confirmed ShipGlows can create and preview a project's design system after selection, but currently has no reusable preset registry.

## Internet Research

- [shadcn/ui registry introduction](https://ui.shadcn.com/docs/registry) - Accessed 2026-07-15 - validates a registry model capable of distributing components, pages, configuration, rules, and other files across projects.
- [shadcn/ui registry API and presets](https://ui.shadcn.com/docs/registry/api-reference) - Accessed 2026-07-15 - validates machine-readable preset fields and programmatic preset resolution.
- [shadcn/ui GitHub registries](https://ui.shadcn.com/docs/registry/github) - Accessed 2026-07-15 - validates GitHub-backed distribution of tokens, themes, components, templates, and conventions.
- [daisyUI themes](https://daisyui.com/docs/themes/) - Accessed 2026-07-15 - demonstrates a mature selectable theme catalog, while remaining Tailwind-specific and mostly theme-level.
- [Flutter themes](https://docs.flutter.dev/cookbook/design/themes) - Accessed 2026-07-15 - confirms Flutter-wide visual application through `ThemeData`, `ColorScheme`, and `TextTheme`.

## Problem Framing

The operator currently asks `001-sg-build` to create an application but cannot predict its appearance. The existing systems solve three different concerns:

- app blueprints define what the application is and how it is structured;
- private inspirations provide source-derived patterns to study;
- project design systems centralize how the chosen direction is implemented.

The missing layer is a reusable, first-party **design preset**: a named, versioned, previewable visual direction that can be combined with an app blueprint and compiled into the target framework's canonical token and component system.

The intended composition is:

```text
product request
  + app blueprint         (functional anatomy)
  + design preset         (visual language)
  + optional inspiration  (selected patterns, never copied wholesale)
  = project spec + scaffold + canonical token system
```

## Option Space

### Option A: Theme Catalog Only

- Summary: provide palettes, fonts, radii, shadows, and spacing scales.
- Pros: small, fast, portable across frameworks.
- Cons: does not show how restaurant menus, finance dashboards, cards, forms, navigation, and empty states will actually look; different agents can still produce inconsistent compositions.

### Option B: Complete Template Per App And Style

- Summary: create a full restaurant app, finance app, content app, and other app for every visual style.
- Pros: very concrete previews and very fast copying when an exact match exists.
- Cons: creates a combinatorial maintenance burden (`app types × styles × frameworks`), duplicates business logic, and drifts quickly.

### Option C: Composable Design Presets With Domain Preview Packs

- Summary: maintain one framework-neutral preset contract, framework adapters, and small domain preview packs that render representative screens without duplicating full applications.
- Pros: provides visual choice before implementation, preserves token authority, composes with every blueprint, supports Flutter and web, and avoids full-template duplication.
- Cons: requires a careful semantic contract and representative preview generation before it becomes useful.

## Comparison

Option C best matches the need. A preset must be more than a color theme but less than a complete app. It should contain:

- a stable semantic ID and version, for example `warm-editorial-v1`, not only `design-5`;
- visual suitability tags such as `restaurant`, `consumer`, `premium`, `finance`, `dense`, or `playful`;
- semantic tokens for color roles, typography, spacing, density, radius, elevation, motion, and responsive behavior;
- component recipes for navigation, buttons, cards, lists, forms, dialogs, tables, charts, empty/error/loading states;
- composition guidance for hierarchy, imagery, information density, and content rhythm;
- accessibility and anti-drift constraints;
- owned preview images or runnable preview surfaces;
- adapters that map the semantic contract to Flutter `ThemeData`/extensions and web CSS/Tailwind/theme sources;
- compatibility metadata declaring which blueprints, domains, platforms, and adapters have proof.

Domain preview packs should render a small set of representative screens, for example restaurant home/menu/item/cart/reservation and finance dashboard/transaction/detail/form. They are previews and composition recipes, not duplicated application implementations.

## Emerging Recommendation

Add a **Design Preset Gate** to `001-sg-build`, immediately after the Blueprint Gate and before spec/readiness:

```text
intake -> Blueprint Gate -> Design Preset Gate -> spec/readiness -> scaffold
```

The gate should:

1. identify the app blueprint and product domain;
2. shortlist at most three to five compatible presets using suitability tags;
3. show actual preview cards, not names alone;
4. recommend one preset with a concise fit reason;
5. require operator selection before treating a preset as direction;
6. record `Blueprint`, `Design preset`, preset version, adapter, and optional inspiration IDs in the spec;
7. compile the selected preset into the project's canonical token/theme/component authority;
8. let `501-sg-design-playground` modify the result after scaffolding without losing the preset provenance.

Start with approximately ten first-party visual families shared across domains, each with stable names and suitability tags. A possible initial set is:

1. `warm-editorial`
2. `modern-bistro`
3. `premium-dark`
4. `playful-bold`
5. `calm-organic`
6. `clean-minimal`
7. `fintech-precision`
8. `neo-brutalist`
9. `soft-saas`
10. `utility-dense`

These names are working seeds, not final catalog decisions. The UI can display a temporary ordinal for convenience, but specs and automation must use the stable semantic ID and version.

For a restaurant request, the system might recommend `warm-editorial`, `modern-bistro`, and `premium-dark` with restaurant-specific preview screens. For a finance app, it might recommend `fintech-precision`, `clean-minimal`, and `utility-dense`. The underlying app blueprint remains independent.

## Non-Decisions

- Final names, exact number, and visual details of the initial presets.
- Whether the first delivery supports Flutter only or Flutter plus web adapters.
- Whether previews are static generated images, runnable playground routes, or both.
- Final repository topology for preset packages and adapters.

## Rejected Paths

- Reusing the private inspiration corpus as installable templates - source-derived captures are evidence and inspiration, not owned scaffold assets.
- Encoding visual styles directly inside each app blueprint - this couples architecture and appearance and recreates the combinatorial problem.
- Letting the agent silently select a numbered design - the operator still cannot predict the result, and ordinal IDs are unstable.
- Adopting a Tailwind-only theme library as the canonical ShipGlows catalog - useful as an adapter or source of ideas, but incompatible with the cross-platform requirement.

## Risks And Unknowns

- A token-only preset will underdeliver because composition and component behavior matter as much as palette.
- Too many domain-specific variants will recreate full-template duplication.
- Preview imagery can misrepresent the scaffold unless generated from the same preset contract and adapters.
- External component/theme licenses must be checked before code or assets are incorporated; inspiration alone is not permission to redistribute.
- Cross-framework semantic parity requires explicit proof because identical tokens do not guarantee identical rendering.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: only public documentation and repository contracts were used.

## Decision Inputs For Spec

- User story seed: As an operator creating a new application, I can choose from visual previews compatible with the selected app blueprint so I understand the future appearance before scaffolding and can customize it later through canonical tokens.
- Scope in seed: preset contract, preset registry, preview contract, Design Preset Gate in `001-sg-build`, spec handoff fields, first-party starter catalog, at least one target-framework adapter, compatibility and validation rules.
- Scope out seed: copying third-party designs, duplicating complete apps for every style, replacing app blueprints, replacing the private inspiration library, silently choosing a design without operator visibility.
- Invariants/constraints seed: stable semantic IDs and versions; centralized token authority; bounded shortlist; operator selection; owned/licensed assets only; accessibility; framework adapters; previews generated from the same contract used for scaffolding.
- Validation seed: registry schema validation, preset-to-adapter contract tests, token drift checks, representative preview proof, Blueprint Gate and Design Preset Gate scenario tests, one restaurant scaffold smoke test.

## Handoff

- Recommended next command: `/100-sg-spec app design preset library and Design Preset Gate`
- Why this next step: the missing system and preferred architecture are now clear enough to formalize before modifying skills, registries, templates, and scaffolding behavior.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-07-15 16:34:26 UTC | Combine app blueprints with selectable visual styles | Inspected existing blueprint, design, inspiration, token, and playground contracts; compared external registry/theme patterns | Recommended composable first-party design presets plus a Design Preset Gate | `/100-sg-spec app design preset library and Design Preset Gate` |
