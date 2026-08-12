---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "ShipGlows"
created: "2026-06-12"
created_at: "2026-06-12 20:33:21 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "home-mobile-navigation-hero-hardening"
user_story: "En tant que visiteur mobile du site ShipGlows, je veux une home plus lisible et mieux hiérarchisée, avec une navigation compacte et des espacements plus professionnels, pour comprendre l'offre sans friction ni sensation de maquette fragile."
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "shipglows_data/technical/design-system-authority.md"
  - "shipglows_data/technical/public-site-and-content-runtime.md"
  - "shipglows_data/editorial/content-map.md"
  - "shipglows_data/branding/branding.md"
  - "site/src/pages/index.astro"
  - "site/src/pages/fr/index.astro"
  - "site/src/components/NavBar.astro"
  - "site/src/components/Hero.astro"
  - "site/src/styles/global.css"
  - "skills/references/design-system-token-contract.md"
depends_on:
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/design-system-authority.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/technical/public-site-and-content-runtime.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
evidence:
  - "Wave 20 migrates every active branding reference to shipglows_data/branding/branding.md while preserving the reviewed 1.1.0 authority."
  - "`site/src/components/NavBar.astro` n'a actuellement ni bouton hamburger ni état mobile dédié."
  - "`site/src/styles/global.css` conserve un `h1` mobile à `clamp(2.5rem, 16vw, 4rem)` et une topbar qui se replie sans navigation compacte."
  - "La source canonique de tokens du site est déjà `site/src/styles/global.css`; la correction doit passer par cette couche."
  - "La home publique en anglais et en français assemble la même structure via `site/src/pages/index.astro` et `site/src/pages/fr/index.astro`."
supersedes: []
next_step: "/102-sg-start ShipGlows home mobile navigation and hero hardening"
---

# Title

ShipGlows Home Mobile Navigation and Hero Hardening

## Status

Ready.

This chantier covers the mobile-first hardening of the public ShipGlows home so the page reads as operational and trustworthy rather than cute or oversized. The implementation must fix navigation, hero scale, spacing rhythm, and elevation through the existing site token layer instead of local visual patches.

## User Story

En tant que visiteur mobile du site ShipGlows, je veux une home plus lisible et plus structurée, avec un vrai menu compact, un hero moins massif, des espacements mieux contrôlés et une profondeur visuelle plus crédible, afin de comprendre rapidement la proposition de valeur et de naviguer sans friction.

## Minimal Behavior Contract

On viewport widths around 360px to 640px, the public home must provide:

- a compact navigation pattern with a hamburger toggle and clear access to primary links
- a hero title that remains prominent without dominating the first screen
- spacing and section padding that feel intentional rather than cramped or randomly loose
- stronger card/panel depth that supports the brand's operational trust posture

Any new visual values must be introduced through `site/src/styles/global.css` tokens or shared aliases first.

## Success Behavior

- If the visitor opens the home on mobile, then the top navigation collapses into a hamburger interaction instead of wrapping the full desktop menu.
- If the hero renders on mobile, then the `h1` remains strong but no longer overwhelms the viewport or crowds the CTA stack.
- If cards, hero panels, or the topbar are shown, then elevation is visibly stronger and more coherent across the page.
- If sections stack on mobile, then gaps, paddings, and button widths feel deliberate and consistent.
- If English and French home pages render, then they inherit the same improved navigation and layout behavior.

## Error Behavior

- If a mobile nav requires local ad-hoc values in `NavBar.astro`, implementation blocks until those values are represented through tokens or named shared rules in `global.css`.
- If the navigation hides links without an accessible toggle state, verification fails.
- If the hero scale is reduced but CTA clarity or reading order regresses, the chantier returns to implementation.
- If new shadow, spacing, or typography values are introduced outside the token layer, drift proof fails and the chantier cannot close.

## Problem

The current home still reads like an early visual draft on mobile. The desktop nav wraps instead of becoming a compact mobile menu, the hero title remains too large for a disciplined first-screen read, spacing choices feel under-resolved, and the low-elevation surfaces make the UI look soft instead of reliable.

## Solution

Harden the home through a focused mobile-first pass:

1. add a real hamburger navigation pattern in the shared navbar component
2. rebalance hero typography and action spacing for narrow screens
3. strengthen shared spacing and shadow tokens in `site/src/styles/global.css`
4. verify the public home visually and technically on both locales

## Scope In

- `site/src/components/NavBar.astro`
- `site/src/components/Hero.astro`
- `site/src/styles/global.css`
- `site/src/pages/index.astro`
- `site/src/pages/fr/index.astro`
- supporting copy in `site/src/i18n/ui.ts` only if the mobile nav or CTA wording needs minimal adjustment
- design-system declaration updates in `shipglows_data/technical/design-system-authority.md` if ShipGlows site authority is still missing
- verification checklist under `shipglows_data/workflow/test-checklists/`

## Scope Out

- full site-wide redesign outside the home/navigation surfaces
- new product positioning, claim changes, or marketing rewrite
- shipping/commit/push
- desktop-only polish unrelated to the mobile hierarchy problem

## Constraints

- Keep the brand posture operational, disciplined, and unsentimental.
- Do not invent a second token source; `site/src/styles/global.css` remains canonical.
- Mobile controls must preserve touch target safety and keyboard accessibility.
- Do not hide or drop core nav destinations on mobile without explicit rationale.
- Preserve bilingual route support.

## Dependencies

- `shipglows_data/branding/branding.md`
- `shipglows_data/technical/design-system-authority.md`
- `shipglows_data/technical/public-site-and-content-runtime.md`
- `shipglows_data/editorial/content-map.md`
- `skills/references/design-system-token-contract.md`
- `site/src/styles/global.css`
- `site/package.json`

## Invariants

- The home remains a public non-auth Astro surface.
- Visual changes route through shared tokens and shared CSS rules.
- The navigation remains understandable without exposing internal-only content.
- The French and English home pages continue to share one component system.

## Links & Consequences

Upstream:

- `shipglows_data/branding/branding.md` sets the trust posture and visual direction.
- `shipglows_data/technical/design-system-authority.md` must declare the ShipGlows site authority if missing.

Downstream:

- `103-sg-verify` needs local build proof plus browser/mobile evidence.
- `104-sg-end` must record docs/editorial impact and proof status before any ship decision.

## Documentation Coherence

- Update `shipglows_data/technical/design-system-authority.md` if the ShipGlows site authority is missing or incomplete.
- Update `shipglows_data/technical/public-site-and-content-runtime.md` only if navigation/runtime behavior changes in a way that affects public-site rules.
- Update `shipglows_data/editorial/content-map.md` only if the role of the landing page or cross-surface update rules materially change.

## Edge Cases

- Mobile nav open state on small screens with long localized labels.
- French title wrapping differently from English in the hero.
- CTA stack becoming too tall once the hero title is reduced.
- Increased shadows creating muddy contrast on the warm background.
- Menu toggle remaining visible/usable when the desktop nav resumes above the mobile breakpoint.

## Implementation Tasks

- [ ] Task 1: Formalize the chantier and proof surface
  - Files: `shipglows_data/workflow/specs/shipglows-home-mobile-navigation-and-hero-hardening.md`, `shipglows_data/workflow/test-checklists/shipglows-home-mobile-navigation-and-hero-hardening.md`
  - Action: create the spec/checklist pair and define proof obligations through `104-sg-end`.
  - Validate with: metadata lint on both artifacts.

- [ ] Task 2: Add a mobile navigation contract
  - Files: `site/src/components/NavBar.astro`, `site/src/styles/global.css`
  - Action: implement a hamburger toggle pattern with accessible labels, open/closed state handling, and tokenized mobile menu styling.
  - Validate with: local browser proof on `/` and `/fr/`.

- [ ] Task 3: Rebalance hero scale and spacing
  - Files: `site/src/components/Hero.astro`, `site/src/styles/global.css`
  - Action: reduce hero title dominance on mobile, improve CTA rhythm, and preserve a strong first-screen hierarchy.
  - Validate with: mobile viewport inspection plus build.

- [ ] Task 4: Strengthen depth and section spacing
  - Files: `site/src/styles/global.css`
  - Action: harden shared shadow/elevation and mobile spacing tokens for the topbar, hero, cards, and sections.
  - Validate with: drift check on changed files and visual inspection.

- [ ] Task 5: Update design-system authority if needed
  - Files: `shipglows_data/technical/design-system-authority.md`
  - Action: declare ShipGlows site token authority so future UI work does not infer it.
  - Validate with: doc review and metadata lint.

- [ ] Task 6: Run implementation proof and closure
  - Files: changed site files + checklist artifact
  - Action: run build, drift check, browser/mobile proof, then update checklist and chantier flow through `104-sg-end`.
  - Validate with: commands and recorded PASS evidence.

## Acceptance Criteria

- [ ] AC-1: On mobile widths around 360px to 640px, the home navigation uses a hamburger menu instead of wrapped desktop links.
- [ ] AC-2: The hero `h1` is materially less oversized on mobile while preserving a strong value proposition hierarchy.
- [ ] AC-3: Shared spacing and elevation feel more intentional on the home without introducing raw visual literals outside the canonical style layer.
- [ ] AC-4: Both `/` and `/fr/` pass the same navbar/hero/mobile behavior.
- [ ] AC-5: `pnpm --dir shipglows-site build` passes.
- [ ] AC-6: `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/shipglows/site --changed --format markdown` reports no unapproved drift in changed site files.

## Test Contract

- surface: ShipGlows public home and shared top navigation
- proof_profile: automated -> browser/manual
- proof_order:
  1. `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/shipglows/site --changed --format markdown`
  2. `pnpm --dir shipglows-site build`
  3. browser/mobile proof on `/` and `/fr/`
- checklist_path: `shipglows_data/workflow/test-checklists/shipglows-home-mobile-navigation-and-hero-hardening.md`
- required_scenario_ids:
  - SG-HOME-NAV-001
  - SG-HOME-HERO-001
  - SG-HOME-MOBILE-001
- required_results:
  - mobile nav is accessible and usable
  - hero scale and CTA spacing are improved on mobile
  - tokenized visual changes pass drift and build proof
- exception_with_proof: none
- exception_without_proof: forbidden

## Test Strategy

- `python3 /home/claude/shipglows/tools/design_system_drift_check.py --root /home/claude/shipglows/site --changed --format markdown`
- `pnpm --dir shipglows-site build`
- local browser verification on `/` and `/fr/` with a narrow mobile viewport
- `python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/shipglows/shipglows_data/workflow/specs/shipglows-home-mobile-navigation-and-hero-hardening.md /home/claude/shipglows/shipglows_data/workflow/test-checklists/shipglows-home-mobile-navigation-and-hero-hardening.md`

## Risks

- `medium` — mobile nav behavior can regress if the breakpoint or open-state logic is fragile.
- `medium` — stronger shadows can overshoot and make the site look heavy instead of disciplined.
- `low` — localized labels may wrap differently and need minor spacing adjustments.

## Execution Notes

- Read first:
  - `shipglows_data/branding/branding.md`
  - `shipglows_data/technical/design-system-authority.md`
  - `shipglows_data/technical/public-site-and-content-runtime.md`
  - `site/src/components/NavBar.astro`
  - `site/src/components/Hero.astro`
  - `site/src/styles/global.css`
- Implementation order:
  1. token/shared CSS updates
  2. navbar and hero component updates
  3. verification and checklist
- Stop immediately if the mobile nav becomes inaccessible or if the French home becomes materially more cramped than the English one.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-12 20:33:21 UTC | 100-sg-spec | GPT-5 Codex | create | ready | /101-sg-ready ShipGlows home mobile navigation and hero hardening |
| 2026-06-12 20:33:21 UTC | 101-sg-ready | GPT-5 Codex | readiness-check | ready | /102-sg-start ShipGlows home mobile navigation and hero hardening |
| 2026-06-12 20:40:49 UTC | 001-sg-build | GPT-5 Codex | delegated implementation, verification, and closure without ship | implemented | stop before /005-sg-ship per user request |

## Current Chantier Flow

- 100-sg-spec: done
- 101-sg-ready: done
- 102-sg-start: done
- 103-sg-verify: done
- 104-sg-end: done
- 005-sg-ship: not launched
