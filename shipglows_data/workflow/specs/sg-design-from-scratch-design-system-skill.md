---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-12"
status: ready
source_skill: sg-spec
scope: skill
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
user_story: "As a ShipGlows operator, I want a skill that creates a complete professional design-token system from an existing UI so projects without tokens can get a central design-system source of truth before playgrounds or deep token audits."
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-playground-playbook.md
  - skills/006-sg-design/references/design-token-audit-playbook.md
  - skills/sg-design-from-scratch/SKILL.md
  - skills/sg-design-playground/SKILL.md
  - skills/sg-audit-design/SKILL.md
  - skills/sg-audit-design-tokens/SKILL.md
  - skills/sg-audit-components/SKILL.md
  - skills/sg-audit-a11y/SKILL.md
  - site/src/content/skills/sg-design-from-scratch.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/consolidate-design-skill-surface-into-modes-and-playbooks.md"
    artifact_version: "1.1.1"
    required_status: ready
supersedes: []
evidence:
  - "Wave 20 records that the historical playground and design-token-audit skills were consolidated into direct modes and playbooks owned by 006-sg-design."
  - "User clarified that Design from Scratch should own full design-system creation from existing UI signals instead of leaving the behavior as a weak playground exception."
  - "sg-design-playground currently mentions a from-scratch seed-token exception but does not define a complete design-system creation lifecycle."
  - "sg-audit-design-tokens audits existing token systems and explicitly stops when no system exists."
  - "Existing design audit skills already define the professional typography scale doctrine as modular ratio / modular scale with Utopia.fyi and rem-based clamp() generation."
  - "User corrected the framing: this skill must create a complete professional design system, not a small or minimal design system."
next_step: "/sg-ship \"Add sg-design-from-scratch design system skill\""
---

# Spec: sg-design-from-scratch Design System Skill

## Title

sg-design-from-scratch Design System Skill

## Status

Ready.

Create a new specialist skill named `sg-design-from-scratch`. It owns the concrete task of creating a centralized design system from an existing frontend. It is not the future general design router. A future `sg-design` master skill may route to this skill, but this skill itself should stay focused on design-system creation.

## User Story

As a ShipGlows operator arriving on a project with no coherent design-token system, I want one skill that can extract the existing visual signals, turn them into a complete professional design-system source of truth, migrate the project toward those variables, and set up the right follow-up tools, so the app gets a real design system instead of another audit report or a disconnected playground.

## Behavior Contract

`sg-design-from-scratch` inspects the existing UI, fonts, colors, spacing, type sizes, motion, theme files, global CSS, Tailwind config, and representative components; derives a complete, professional, central token system from the best existing signals; enforces strict coherence by default; creates or updates the canonical token source; rewires global styles and obvious hardcoded literals to consume variables; then routes to `sg-design-playground` once a token layer exists and runs `sg-audit-design-tokens` after the migration to check coherence.

Typography creation must use the same professional scale doctrine already present in ShipGlows's design audits: choose a coherent modular ratio / modular scale, keep no more than 5 size tokens by default, and use `Utopia.fyi` or equivalent base-size + ratio + viewport-range math for fluid `clamp(MIN_REM, X_REM + Y_VW, MAX_REM)` tokens when headings or display text need responsive scaling.

The default system must stay intentionally disciplined and complete across core domains:

- no more than 5 font roles or loaded font families
- no more than 3 chromatic color families, plus neutral/surface/text tokens when needed
- no more than 5 font-size tokens, selected from one coherent modular ratio
- centralized CSS variables or the framework-equivalent token source
- spacing, radius, shadow/elevation, motion, theme, and semantic state tokens when those domains exist in the project
- semantic aliases for product intent, not loose one-off values

If the project needs more than these constraints, the skill asks a targeted product/design question before expanding the system.

## Success Behavior

- Given a project has no real token layer, when the skill runs, then it creates a complete professional token system from the current app instead of aborting.
- Given fonts, colors, sizes, and spacing already exist in scattered code, when the skill evaluates them, then it preserves the strongest existing brand signals while consolidating duplicates and hardcoded literals.
- Given the token system exists after the migration, when follow-up tooling is useful, then the skill routes to `sg-design-playground` instead of duplicating playground internals.
- Given the migration is applied, when validation runs, then the app build/checks pass or the failure is reported with a concrete unblock action.
- Given the token system is created, when verification completes, then `sg-audit-design-tokens` can audit the result instead of stopping with "no design token system detected".

## Error Behavior

- If the frontend framework or styling stack is unsupported, stop before file edits and report the safest viable manual route or a spec for support.
- If there are multiple competing brand directions and no clear existing winner, ask one targeted question instead of inventing a new visual identity.
- If the project has no representative UI surface to derive from, ask for the target page/screen before creating tokens.
- If changing global styles would affect production-critical or auth/payment flows, require spec-first readiness before broad migration.
- If validation fails, report the exact failing check and route to `sg-fix`, `sg-start`, or the owner skill instead of declaring the design system done.
- If unrelated dirty files would be included in ship scope, stop before ship routing.

## Scope In

- Create `skills/sg-design-from-scratch/SKILL.md`.
- Create a public skill page for `sg-design-from-scratch`.
- Update `sg-design-playground` so no-token from-scratch work routes to this skill.
- Update help, workflow, launch cheatsheet, and skill runtime docs for discoverability.
- Define the design-system creation lifecycle, constraints, stop conditions, validation, and follow-up routing.
- Sync current-user Claude/Codex runtime skill links.

## Scope Out

- Creating a future general `sg-design` router.
- Rewriting the existing design audit skills.
- Duplicating the full internals of `sg-design-playground`, `sg-audit-design`, `sg-audit-design-tokens`, `sg-audit-components`, or `sg-audit-a11y`.
- Creating a production component library or Storybook from scratch.
- Inventing a brand identity unrelated to the existing app.
- Committing or pushing unrelated dirty work.

## Constraints

- Internal skill contracts use English.
- User-facing report follows the active user language.
- Keep the invocation key `sg-design-from-scratch`.
- Preserve existing brand signals when they are coherent enough to keep.
- Constrain the default token architecture aggressively: 5 font roles/families, 3 chromatic color families, 5 font sizes.
- Do not count required neutral/surface/text tokens as chromatic color families.
- Typography sizes must be modular, not linear: allowed default ratios include `1.125`, `1.2`, `1.25`, `1.333`, `1.414`, `1.5`, and `1.618`.
- Fluid typography tokens must use a `rem + vw` preferred value with moderate `vw`, not pure viewport units.
- Prefer semantic CSS custom properties for web projects unless the framework already has a clear canonical token format.
- Do not add a playground before a usable token layer exists.
- Do not turn `sg-design-from-scratch` into a general design router.

## Dependencies

- `skills/sg-design-playground/SKILL.md` for playground scaffolding after tokens exist.
- `skills/sg-audit-design-tokens/SKILL.md` for token validation after creation.
- `skills/sg-audit-design/SKILL.md` for broad design diagnosis when the visual direction is unclear.
- `skills/sg-audit-components/SKILL.md` and `skills/sg-audit-a11y/SKILL.md` for follow-up remediation.
- Project framework files such as global CSS, Tailwind config, theme files, layouts, and representative pages/components.
- Fresh external docs verdict: `fresh-docs not needed` for creating this local skill contract; future executions of the skill should use the docs freshness gate when framework-specific current behavior matters.

## Invariants

- The skill creates a complete professional design-system source of truth, not just a debug page.
- Existing visual evidence is the source; arbitrary new branding is not.
- The token system is centralized before the playground is created.
- Constraints are defaults and must be explicitly exceeded.
- Broad UI migration is spec-first when it spans many files or public/product-critical surfaces.
- Follow-up audit and playground work remains owned by the specialist skills.

## Links & Consequences

Upstream:
- User design direction, existing UI, brand docs when present, and the current design audit/playground skills.

Downstream:
- Projects can get a professional token layer before running `sg-design-playground` or `sg-audit-design-tokens`.
- A future `sg-design` master router can route "create a design system from scratch" to this skill without carrying implementation details.

## Open Questions

None for this skill creation. Naming is resolved as `sg-design-from-scratch`.

## Implementation Tasks

- [x] Task 1: Create the ready spec.
  - File: `specs/sg-design-from-scratch-design-system-skill.md`
  - Action: Capture target behavior, constraints, lifecycle, routing boundaries, and validation.
  - Validate with: `python3 tools/shipglows_metadata_lint.py specs/sg-design-from-scratch-design-system-skill.md`

- [x] Task 2: Create the skill contract.
  - File: `skills/sg-design-from-scratch/SKILL.md`
  - Action: Encode focused professional design-system creation flow, token constraints, unblock rules, validation, and final report.
  - Validate with: `rg -n "5 font|3 chromatic|5 font-size|sg-design-playground|sg-audit-design-tokens|unblock|Validation" skills/sg-design-from-scratch/SKILL.md`

- [x] Task 3: Update playground handoff.
  - File: `skills/sg-design-playground/SKILL.md`
  - Action: Route no-token from-scratch requests to `sg-design-from-scratch` instead of keeping a weak seed-token exception.
  - Validate with: `rg -n "sg-design-from-scratch|No design token system detected" skills/sg-design-playground/SKILL.md`

- [x] Task 4: Add public and internal discoverability.
  - Files: `site/src/content/skills/sg-design-from-scratch.md`, `skills/sg-help/SKILL.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Add the new skill to public skill content, help, launch routing, and skill runtime docs.
  - Validate with: `rg -n "sg-design-from-scratch|Design from Scratch" site/src/content/skills skills/sg-help/SKILL.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md`

- [x] Task 5: Sync runtime links and validate.
  - Files: `~/.claude/skills/sg-design-from-scratch`, `~/.codex/skills/sg-design-from-scratch`
  - Action: Run runtime sync, skill budget audit, metadata lint, site build, focused rg, and leak scan.
  - Validate with: commands in Test Strategy.

## Acceptance Criteria

- [x] AC 1: Given a project has no design token system, when the operator wants a design system from the existing UI, then `sg-design-from-scratch` is the explicit skill to run.
- [x] AC 2: Given `sg-design-playground` sees no tokens and the user asks for from-scratch work, then it routes to `sg-design-from-scratch`.
- [x] AC 3: Given the new skill is read, then it states the default constraints: 5 font roles/families, 3 chromatic color families plus neutrals/surfaces/text, and 5 font-size tokens.
- [x] AC 4: Given the new skill is created, then current-user Claude and Codex runtime links point to `skills/sg-design-from-scratch`.
- [x] AC 5: Given the public skill index builds, then `/skills/sg-design-from-scratch` is generated.
- [x] AC 6: Given documentation/help surfaces are searched, then `sg-design-from-scratch` is discoverable.
- [x] AC 7: Given the new skill creates typography tokens, then it uses modular ratio / modular scale logic and points to `Utopia.fyi` or equivalent fluid-scale math rather than linear font-size increments.
- [x] AC 8: Given the skill is presented publicly or internally, then it promises a complete professional design system, not a small or minimal design system.

## Test Strategy

- `test -f skills/sg-design-from-scratch/SKILL.md`
- `test -f site/src/content/skills/sg-design-from-scratch.md`
- `rg -n "5 font|3 chromatic|5 font-size|modular ratio|Utopia|clamp|sg-design-playground|sg-audit-design-tokens|Unblock" skills/sg-design-from-scratch/SKILL.md`
- `rg -n "sg-design-from-scratch|Design from Scratch" site/src/content/skills skills/sg-help/SKILL.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md`
- `"${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh" --check --skill sg-design-from-scratch`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py specs/sg-design-from-scratch-design-system-skill.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md`
- `pnpm --dir shipglows-site build`
- `rg -n "BEGIN .*KEY|PRIVATE KEY|PASSWORD=|SECRET=|TOKEN=|CREDENTIAL=" skills/sg-design-from-scratch/SKILL.md site/src/content/skills/sg-design-from-scratch.md`

## Risks

- Duplicate responsibility risk: mitigated by making this skill own design-system creation only, while audits and playground stay in their specialist skills.
- Over-broad migration risk: mitigated by spec-first for broad UI rewrites and by keeping first migrations bounded.
- Brand drift risk: mitigated by preserving existing signals and asking targeted questions when no clear direction exists.
- Public claim risk: low; this is an internal/public skill description, not a product capability claim beyond local workflow.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-04 11:36:48 UTC | sg-spec | GPT-5 Codex | Created the `sg-design-from-scratch` design-system creation skill spec from the user's clarified request and existing design skill evidence. | ready spec created | `/sg-ready sg-design-from-scratch Design System Skill` |
| 2026-05-04 11:36:48 UTC | sg-ready | GPT-5 Codex | Evaluated naming, placement, overlap with playground/audit skills, scope, success/error behavior, docs impact, and validation. | ready | `/sg-start sg-design-from-scratch Design System Skill` |
| 2026-05-04 11:36:48 UTC | sg-skill-build | GPT-5 Codex | Created the `sg-design-from-scratch` skill contract, public skill page, playground handoff, audit-token handoff, help/workflow/docs routing, runtime links, and validation evidence. | implemented; not shipped due unrelated dirty worktree | `/sg-ship "Add sg-design-from-scratch design system skill"` |
| 2026-05-04 11:58:41 UTC | sg-skill-build | GPT-5 Codex | Reconciled the user's remembered typography-scale research with existing design audit doctrine and added modular ratio / Utopia fluid-scale requirements to the new skill. | implemented; targeted validation passed | `/sg-ship "Add sg-design-from-scratch design system skill"` |
| 2026-05-04 13:30:13 UTC | sg-skill-build | GPT-5 Codex | Reframed `sg-design-from-scratch` away from the prior small/minimal framing and toward a complete professional design-system source of truth with disciplined constraints. | implemented; targeted validation passed | `/sg-ship "Add sg-design-from-scratch design system skill"` |
| 2026-05-04 17:24:11 UTC | sg-ship | GPT-5 Codex | Bounded and shipped the design-system skill plus related professional-scope skill-language pass without staging unrelated dirty work. | scoped ship in progress | ship remaining unrelated scopes separately |

## Current Chantier Flow

```text
sg-spec: done (ready)
sg-ready: done (ready)
sg-start: done (implemented)
sg-verify: done (local validation passed)
sg-end: not launched
sg-ship: done (scoped quick ship)
```

Next step:
- Ship the remaining dirty scopes separately after grouping them by owner/risk.
