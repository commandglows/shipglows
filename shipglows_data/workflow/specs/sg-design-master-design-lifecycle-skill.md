---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-06"
updated: "2026-05-06"
status: ready
source_skill: sg-spec
scope: skill
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
user_story: "As a ShipGlows operator, I want one master design entrypoint that can understand any design-related request and route it through the right design, audit, browser, spec, implementation, verification, and ship skills without making me memorize the design skill taxonomy."
linked_systems:
  - skills/sg-design/SKILL.md
  - skills/sg-design-from-scratch/SKILL.md
  - skills/sg-design-playground/SKILL.md
  - skills/sg-audit-design/SKILL.md
  - skills/sg-audit-design-tokens/SKILL.md
  - skills/sg-audit-components/SKILL.md
  - skills/sg-audit-a11y/SKILL.md
  - skills/sg-build/SKILL.md
  - skills/sg-browser/SKILL.md
  - skills/sg-check/SKILL.md
  - skills/sg-verify/SKILL.md
  - skills/shipglows/SKILL.md
  - skills/references/entrypoint-routing.md
  - site/src/content/skills/sg-design.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "The existing `sg-design-from-scratch` spec explicitly states that a future `sg-design` master skill may route to it, while keeping design-system creation focused."
  - "Current design responsibilities are split across `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-components`, `sg-audit-a11y`, `sg-design-from-scratch`, and `sg-design-playground`."
  - "User reported that the previous work on the master design skill was likely lost after a VM crash and requested recreating it as an orchestrator for design-related questions."
  - "User clarified that playground/token centralization reports should also explain the follow-up migration needed to make the whole site consume the centralized values."
next_step: "/sg-ship \"Add sg-design master design skill\""
---

# Spec: sg-design Master Design Lifecycle Skill

## Title

sg-design Master Design Lifecycle Skill

## Status

Ready.

Create a new master skill named `sg-design`. It owns the user-facing design entrypoint for ShipGlows. The operator should be able to ask a design-related question without choosing between token creation, playground scaffolding, design audit, component audit, accessibility audit, browser proof, implementation, verification, or ship routing.

## User Story

As a ShipGlows operator, I want one design master skill that can understand my design intent, choose the right specialist skill or lifecycle path, and keep the work moving through proof and verification, so I do not need to memorize the design skill taxonomy or know when token centralization still needs a site-wide implementation pass.

## Behavior Contract

`sg-design` is a master/orchestrator skill. It routes and sequences design work; it does not duplicate specialist internals.

It must classify design intent into the smallest safe owner route:

- design-system foundation from scattered values -> `sg-design-from-scratch`
- live token preview/editing -> `sg-design-playground`
- token coherence, hardcoded design values, token migration coverage -> `sg-audit-design-tokens`
- general UI/UX quality, hierarchy, layout, responsive behavior -> `sg-audit-design`
- component architecture, variants, duplication, API hygiene -> `sg-audit-components`
- accessibility, keyboard, focus, contrast, WCAG evidence -> `sg-audit-a11y`
- visible page proof or non-regression screenshots -> `sg-browser`
- broad implementation or multi-page migration -> `sg-build` / `sg-spec -> sg-ready -> sg-start`
- checks and verification -> `sg-check`, `sg-verify`, then closure and ship routing

For broad design work, `sg-design` follows the shared master lifecycle:

```text
intake
  -> design work item resolution
  -> audit/discovery when needed
  -> sg-spec/sg-ready for non-trivial changes
  -> owner-skill execution
  -> checks and browser/design proof
  -> sg-verify
  -> sg-end/sg-ship or sg-deploy when appropriate
```

For token centralization and playground outcomes, `sg-design` must explicitly distinguish between:

- creating or editing the central token source
- migrating pages/components/layouts to consume that source
- verifying there was no unintended visual regression

If a run creates or scaffolds tokens but the site is not yet migrated to consume them, the final report must name the follow-up path:

```text
sg-audit-design-tokens
-> sg-build "Migrer le site pour consommer les tokens design centralises sans changement visuel volontaire"
-> sg-check
-> sg-browser
-> sg-verify
-> sg-ship
```

## Success Behavior

- Given an operator asks a design-related question, when the route is clear, then `sg-design` directly hands off to the focused owner skill or lifecycle without asking the operator to choose the taxonomy.
- Given the request spans multiple pages, components, public surfaces, design-system migration, accessibility fixes, or visible UI changes, then `sg-design` creates or continues a spec-first chantier before implementation.
- Given a playground or token source has been created, when migration coverage remains incomplete, then `sg-design` names the site-wide implementation path instead of treating centralization as finished.
- Given a visual change is implemented, when proof is required, then `sg-design` routes to `sg-browser` for non-auth visual evidence and `sg-audit-a11y` or `sg-audit-design-tokens` for specialist evidence as needed.
- Given verification passes, then `sg-design` routes through closure and bounded ship/deploy semantics rather than leaving manual `/sg-end` or `/sg-ship` as boilerplate.

## Error Behavior

- If the design intent is too fuzzy for one targeted routing question, route to `sg-explore` before creating a spec or editing files.
- If a request would invent a new brand identity, visual direction, color palette, typography, or product promise without enough project evidence, ask a targeted business/design question.
- If broad visual implementation lacks a ready spec, block before file edits and route to `sg-spec`.
- If visual proof is missing for a non-regression claim, block closure or ship until `sg-browser` or equivalent evidence exists.
- If accessibility, contrast, focus, or reduced-motion safety would be weakened by token or visual changes, block and route to the appropriate specialist.
- If unrelated dirty files would enter closure or ship scope, stop before ship routing.

## Scope In

- Create `skills/sg-design/SKILL.md`.
- Add public skill page `site/src/content/skills/sg-design.md`.
- Update `shipglows` and shared routing references so design-related operator requests route to `sg-design`.
- Update help, README, workflow, launch cheatsheet, and technical docs for discoverability.
- Update design playground/from-scratch handoff language so token centralization points to migration and non-regression proof when needed.
- Sync current-user Claude/Codex runtime links.

## Scope Out

- Rewriting existing design specialist skills from scratch.
- Duplicating `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-components`, `sg-audit-a11y`, `sg-design-from-scratch`, or `sg-design-playground` internals inside `sg-design`.
- Creating an unrelated brand identity or component library.
- Shipping unrelated dirty work.

## Constraints

- Internal skill contracts use English.
- User-facing reports and questions use the user's active language.
- `sg-design` is a master lifecycle skill and must load the shared master lifecycle, delegation, question, chantier, and reporting references.
- Use direct main-thread handoff from `shipglows`; do not run master skills inside nested subagents from the router.
- Use delegated sequential execution for file work when available; parallelism requires ready non-overlapping `Execution Batches`.
- Ask only targeted questions when the answer changes route, scope, brand direction, proof, security, public claim, closure, or ship posture.

## Dependencies

- Existing design owner skills listed in `linked_systems`.
- Shared master lifecycle references.
- Public site skill content schema.
- Runtime skill sync helper.

Fresh external docs verdict: `fresh-docs not needed` for creating this local skill contract. Future executions of `sg-design` should run the documentation freshness gate only when framework/runtime behavior, accessibility standards, browser evidence policy, or provider-specific current docs affect the design work.

## Invariants

- `sg-design` is the recommended design entrypoint; specialist skills remain available for expert direct use.
- A token source is not complete design implementation unless the product surfaces consume it.
- Design verification needs visible proof when visual non-regression or UI quality is claimed.
- Accessibility and reduced-motion safety outrank token discipline.
- Master skill orchestration routes through owners and does not duplicate specialist internals.

## Links & Consequences

Upstream:
- `shipglows` natural-language router and user design requests.

Downstream:
- Operators can ask `sg-design <question>` for design work.
- `shipglows <design request>` can hand off to `sg-design`.
- Future design-system work has a standard path from token/playground creation to site-wide migration and browser proof.

## Open Questions

None. The user explicitly requested recreating the master design skill and confirmed the intended scope: design-related questions should be handled through a design orchestrator that finds the right method.

## Implementation Tasks

- [x] Task 1: Create this ready spec.
  - File: `specs/sg-design-master-design-lifecycle-skill.md`
  - Action: Capture master-design routing, lifecycle, token migration follow-up, docs impact, validation, and runtime visibility.
  - Validate with: `python3 tools/shipglows_metadata_lint.py specs/sg-design-master-design-lifecycle-skill.md`

- [x] Task 2: Create the skill contract.
  - File: `skills/sg-design/SKILL.md`
  - Action: Encode master lifecycle, routing matrix, token/playground follow-up, proof gates, stop conditions, and final report.
  - Validate with: `rg -n "name: sg-design|Design Intent Routing|Token Implementation Handoff|sg-audit-design-tokens|sg-design-from-scratch|sg-browser" skills/sg-design/SKILL.md`

- [x] Task 3: Add runtime discoverability and public content.
  - Files: `site/src/content/skills/sg-design.md`, current-user Claude/Codex skill links.
  - Action: Create public skill page and sync runtime links.
  - Validate with: `test -f site/src/content/skills/sg-design.md` and `tools/shipglows_sync_skills.sh --check --skill sg-design`

- [x] Task 4: Update routing and help surfaces.
  - Files: `skills/shipglows/SKILL.md`, `skills/references/entrypoint-routing.md`, `skills/sg-help/SKILL.md`, `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Make `sg-design` the recommended master entrypoint for design-related operator requests.
  - Validate with: `rg -n "sg-design" <changed files>`

- [x] Task 5: Update specialist design handoffs.
  - Files: `skills/sg-design-playground/SKILL.md`, `skills/sg-design-from-scratch/SKILL.md`, relevant public skill pages.
  - Action: Explain that token/playground centralization may require site-wide migration and visual non-regression proof through `sg-design` or `sg-build`.
  - Validate with: `rg -n "Token Implementation Handoff|consume|centralized|sg-design" skills/sg-design-playground/SKILL.md skills/sg-design-from-scratch/SKILL.md site/src/content/skills/sg-design-playground.md site/src/content/skills/sg-design-from-scratch.md`

- [x] Task 6: Validate and update docs.
  - Action: Run skill budget audit, metadata lint, public site build, runtime sync check, focused route checks, and leak scan.
  - Validate with commands in Test Strategy.

## Acceptance Criteria

- [x] AC 1: Given an operator runs `/sg-design <design request>`, the skill classifies the design intent and routes to the correct owner skill or lifecycle gate.
- [x] AC 2: Given a request is about creating or centralizing design tokens, the skill can route to `sg-design-from-scratch`, `sg-design-playground`, or `sg-audit-design-tokens` as appropriate.
- [x] AC 3: Given token centralization has happened but pages are not fully migrated, the skill names the implementation path and visual non-regression proof path.
- [x] AC 4: Given a broad design change spans multiple pages/components or product-critical surfaces, the skill requires a ready spec before implementation.
- [x] AC 5: Given `shipglows` receives a design-related request, routing docs point to `sg-design`.
- [x] AC 6: Given the skill is created, current-user Claude and Codex runtime links expose `sg-design`.
- [x] AC 7: Given public skill pages build, `/skills/sg-design` is generated and related design skills link to it.
- [x] AC 8: Given docs/help are searched, `sg-design` is discoverable as the master design entrypoint.

## Test Strategy

- `test -f skills/sg-design/SKILL.md`
- `test -f site/src/content/skills/sg-design.md`
- `rg -n "name: sg-design|Design Intent Routing|Token Implementation Handoff|sg-audit-design-tokens|sg-design-from-scratch|sg-browser" skills/sg-design/SKILL.md`
- `rg -n "sg-design" skills/shipglows/SKILL.md skills/references/entrypoint-routing.md skills/sg-help/SKILL.md README.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md site/src/content/skills`
- `"${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh" --check --skill sg-design`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py specs/sg-design-master-design-lifecycle-skill.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md`
- `pnpm --dir shipglows-site build`
- `rg -n "BEGIN .*KEY|PRIVATE KEY|PASSWORD=|SECRET=|TOKEN=|CREDENTIAL=" skills/sg-design/SKILL.md site/src/content/skills/sg-design.md`

## Risks

- Duplicate responsibility risk: mitigated by making `sg-design` a router/orchestrator and keeping specialist skill internals with existing owners.
- False completion risk after token centralization: mitigated by explicit token implementation handoff and browser non-regression proof.
- Scope creep risk: mitigated by spec-first for broad visual changes and by routing narrow requests to focused owner skills.
- Accessibility regression risk: mitigated by routing contrast, focus, keyboard, and reduced-motion concerns to `sg-audit-a11y`.
- Public claim risk: low; this is a skill routing contract and public skill page, not a product promise beyond workflow behavior.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-06 12:18:18 UTC | sg-spec | GPT-5 Codex | Created the `sg-design` master design lifecycle skill spec from the user's request and existing design skill taxonomy. | ready spec created | `/sg-ready sg-design Master Design Lifecycle Skill` |
| 2026-05-06 12:18:18 UTC | sg-ready | GPT-5 Codex | Evaluated naming, placement as a master skill, overlap with existing design specialists, docs/public impact, token implementation handoff, and validation. | ready | `/sg-start sg-design Master Design Lifecycle Skill` |
| 2026-05-06 12:28:28 UTC | sg-skill-build | GPT-5 Codex | Created `sg-design`, public skill page, routing/docs/help updates, specialist handoff updates, runtime links, and validation evidence. | implemented; not shipped | `/sg-ship "Add sg-design master design skill"` |
| 2026-05-06 12:44:39 UTC | sg-ship | GPT-5 Codex | Prepared full close and bounded ship for the `sg-design` master design lifecycle skill scope, excluding unrelated dirty bug/runtime CLI work. | shipped | none |

## Current Chantier Flow

```text
sg-spec: done (ready)
sg-ready: done (ready)
sg-start: done (implemented)
sg-verify: done (local validation passed)
sg-end: done (full close prepared)
sg-ship: done (bounded ship)
```

Next step:
- none
