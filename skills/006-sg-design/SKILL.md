---
name: 006-sg-design
description: "Single public entrypoint for design-system work, animation, design audits, accessibility, and inspiration-library curation."
argument-hint: <system [scope] | playground [route-path] | audit <ui|tokens|components|a11y> [scope] | animation <audit|design|implement|tune> [scope] | redesign [scope] | migration [scope] | library <add|retry|approve|list|status> ...>
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Public Métier Ownership

Public label: `sg-design`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or mode selection. Resolve `project -> product -> surface -> feature` and retain ownership from design intent through implementation, accessibility/performance proof, documentation coherence, and closure.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `006-sg-design` row with the correct result, update `Current Chantier Flow`, and open with the chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no unique spec exists, do not write to a spec. For narrow read-only diagnosis, answer or route directly. For non-trivial design implementation, design-system migration, multi-page visual work, public/product-critical UI changes, or proof-sensitive redesigns, route to `/100-sg-spec <title>` and do not edit source files before readiness is `ready`.

## Required References

Load these before the matching work:

- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` for route and implementation decisions.
- `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` before choosing topology; parallelize independent read-only design evidence by default and require ready write batches for concurrent edits.
- `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md` before any UI, layout, token, theme, or visual-proof work.
- `$SHIPGLOWS_ROOT/skills/006-sg-design/references/design-lifecycle-routing.md` for mode grammar, scope gates, and sequencing.
- `$SHIPGLOWS_ROOT/skills/006-sg-design/references/animation-playbook.md` for `animation <audit|design|implement|tune> [scope]` after valid animation selection.
- `$SHIPGLOWS_ROOT/skills/006-sg-design/references/design-token-migration-playbook.md` for token centralization and migration handoff.
- `$SHIPGLOWS_ROOT/skills/006-sg-design/references/design-proof-and-reporting.md` for design completion and handoff evidence.
- `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md` when visual direction changes or an explicit inspiration request exists.
- `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` when defining experience principles, critical moments, desired/avoided emotion, or a design direction that changes product intent.
- `$SHIPGLOWS_ROOT/skills/006-sg-design/references/design-inspiration-library-operations.md` before `library ...` operations.
- `$SHIPGLOWS_ROOT/skills/600-sg-local-cloud-sync/references/sync-guidance-overlay-ui.md` before sync-related UI work; hand off data/merge authority to `600-sg-local-cloud-sync`.
- `$SHIPGLOWS_ROOT/skills/references/skill-refactor-verifier.md` for any skill compaction, extraction, or process-migration check.
- `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md` for email template design, email accessibility, images-off behavior, contrast, responsive rendering, or client-safe visual systems.

## Explicit Invocation Preflight

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

## Mission

`006-sg-design` is the sole public entrypoint for design-related work. It owns lifecycle routing and proof posture for design-system, UI/UX, animation, accessibility, visual-proof, and token migration work, but it does not replace implementation, browser verification, or ship/deploy skills.

## Scope Gate

Use direct routing for read-only design questions, one focused specialist action, one narrow page/component fix, or playground scaffolding when the token layer and route are clear.

Require spec-first for broad redesigns, whole-page or multi-section animation implementation, multi-page or cross-component token migration, new visual direction, palette, typography, brand shifts, public/product-critical UI surfaces, accessibility remediation across flows, no-regression claims across many pages, or changes affecting screenshots, public claims, onboarding, pricing, docs, or trust signals.

When the request is ambiguous enough that one routing question cannot settle scope, route to `700-sg-explore` before implementation.

## Route Summary

Use the exact mode grammar and playbook mapping from `design-lifecycle-routing.md`.

- `system` for design-system creation
- `playground` for token and route exploration
- `audit ui|tokens|components|a11y` for bounded audits
- `animation <audit|design|implement|tune> [scope]` for provider-neutral motion work; GSAP is optional after its project-fit and freshness gates
- `redesign` for lifecycle routing with proof
- `migration` for token centralization and site consumption
- `library ...` for private inspiration curation operations

## Validation

Use project scripts and specialist checks instead of inventing proof.

- `npm run lint`
- `npm run build`
- `npm test`
- `python3 "${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/design_system_drift_check.py" --changed --format markdown`

Run `006-sg-design audit tokens`, `006-sg-design audit a11y`, `108-sg-browser`, `109-sg-auth-debug`, or `405-sg-prod` when the proof path requires specialist evidence. Animation implementation and tuning require the animation playbook's browser, reduced-motion, responsive, cleanup, and performance proof.

## Stop Conditions

Stop and report `blocked` when:

- the design intent is too ambiguous for one targeted routing question and needs `700-sg-explore`
- brand direction, visual identity, public claim, or product surface choice changes materially and the user has not decided
- broad implementation lacks a ready spec
- validation or specialist proof required by the design claim is missing
- visual non-regression is claimed but browser proof was not collected
- design-system drift scan finds unexplained new visual literals outside the canonical token/theme/component source
- accessibility, focus, contrast, or reduced-motion safety is uncertain after changes
- animation dependency/plugin/licensing fit, content access on initialization failure, framework cleanup, or required motion proof is unknown
- cross-surface design parity is claimed from parallel local design-token files without a canonical mapping and resolved-value proof
- component-library replacement weakens mature keyboard/focus behavior or copies vendor internals without equivalent regression proof
- ship scope includes unrelated dirty files without explicit approval

Every blocked report must include the exact next recovery route.

## Rules

- Keep the detailed procedure in references, not in the activation body.
- Use spec-first for broad design implementation and token migration.
- Always surface the token implementation handoff when centralization exists but site consumption is incomplete.
- Verify visual claims with visible proof and specialist evidence, not only code scans.
- Treat GSAP as an optional adapter, never as a public alias or implicit dependency installation.
