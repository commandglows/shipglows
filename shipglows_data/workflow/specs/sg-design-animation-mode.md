---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-04"
created_at: "2026-08-04 21:47:07 UTC"
updated: "2026-08-04"
updated_at: "2026-08-04 21:47:07 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: sg-design-animation-mode
owner: Diane
user_story: "As a ShipGlows operator, I want a provider-neutral animation mode in the design skill, so agents can audit, design, implement, and tune coherent accessible website motion while using GSAP when it is the right project adapter."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - skills/references/design-system-token-contract.md
  - skills/108-sg-browser/SKILL.md
  - skills/010-sg-technical/references/performance-audit-playbook.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - README.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
depends_on:
  - artifact: skills/006-sg-design/references/design-lifecycle-routing.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator requested an animation or GSAP mode after reviewing an AI-assisted whole-page animation workflow."
  - "Existing 006-sg-design routing owns motion and accessibility but exposes no dedicated animation workflow."
  - "The design-system token contract already governs motion durations, easings, distances, responsive behavior, and reduced-motion safety."
next_step: "/005-sg-ship SG Design Animation Mode when requested"
---

# SG Design Animation Mode

## Title

SG Design Animation Mode

## Status

reviewed

## User Story

As a ShipGlows operator, I want a provider-neutral animation mode in the design skill, so agents can audit, design, implement, and tune coherent accessible website motion while using GSAP when it is the right project adapter.

## Minimal Behavior Contract

The design skill accepts an explicit animation intent and routes it to one of four bounded actions—`audit`, `design`, `implement`, or `tune`—then produces or changes a coherent motion system scoped to the named surface. It uses the project's declared motion authority, selects GSAP only when appropriate to the stack and interaction, preserves responsive and reduced-motion behavior, and requires observable browser and performance proof for implementation claims. Invalid actions stop with the supported grammar; the easy-to-miss edge case is a whole-page request that must reuse global motion patterns and section overrides rather than generating unrelated effects for every element.

## Success Behavior

- Given an explicit `animation` request, the skill selects the exact action without inventing an audit subtype or silently broadening scope.
- `audit` reports motion coherence, accessibility, responsive behavior, lifecycle safety, and performance risks without editing product source.
- `design` defines motion principles, semantic tokens, repeated-element patterns, section overrides, and proof obligations before implementation.
- `implement` applies a ready motion contract using the project-native solution or GSAP when justified, with cleanup and responsive/reduced-motion handling.
- `tune` preserves the existing motion concept while refining timing, easing, stagger, intensity, trigger boundaries, or breakpoint behavior.
- Whole-page animation reuses a small vocabulary of global patterns and documents exceptions instead of assigning arbitrary effects section by section.

## Error Behavior

- Unknown or missing animation actions list `audit`, `design`, `implement`, and `tune`; no action is inferred when behavior or write scope would change.
- Implementation stops when no canonical motion authority exists, broad work lacks a ready spec, dependency/licensing fit is unknown, or reduced-motion and cleanup behavior cannot be proven.
- The mode never installs GSAP, introduces plugins, or changes licensing posture implicitly; dependency changes require the normal implementation and freshness gates.
- Failed validation remains observable as partial or blocked work and cannot be reported as verified animation behavior.

## Problem

`006-sg-design` already owns motion as part of design-system work, but it has no dedicated route for page animation. Natural-language requests such as “animate the whole page” can therefore produce inconsistent effects, raw timing literals, accessibility regressions, scroll-jank, framework lifecycle leaks, or an unnecessary GSAP dependency without a stable motion-system contract.

## Solution

Add a public `animation <audit|design|implement|tune> [scope]` mode to `006-sg-design`. Keep the activation contract compact, place detailed procedure in a focused animation playbook, treat GSAP as an optional web adapter rather than the public identity, and connect visible implementation to browser, reduced-motion, responsive, cleanup, and performance proof.

## Scope In

- Extend `006-sg-design` metadata, loaders, route summary, validation, and stop conditions for the animation mode.
- Add exact animation grammar and lifecycle sequencing to the design routing reference.
- Add one local animation playbook covering intake, motion inventory, global patterns, section overrides, GSAP selection, framework cleanup, responsive rules, reduced motion, and proof.
- Extend design proof guidance for motion-specific claims.
- Add focused contract tests or mechanical scenarios that prove routing, provider neutrality, safety gates, and discoverability.
- Align the public README, operator cheatsheet, and skill runtime documentation.

## Scope Out

- No AI animation builder UI, live visual timeline, code editor, replay console, or new runtime product.
- No GSAP installation in ShipGlows or target projects.
- No mandatory GSAP usage when CSS, Web Animations API, or framework-native motion is the better fit.
- No reproduction of proprietary “Vibe Code” behavior, branding, prompts, or interface.
- No automatic modification of an audited project as part of `audit` or `design`.
- No new top-level skill or public invocation alias.

## Constraints

- `animation` is the public mode; `gsap` is never a parallel public mode or alias.
- Motion values resolve through the project's declared design-system authority.
- Broad whole-page or multi-section implementation is spec-first.
- Transform and opacity animations are preferred; layout/paint-heavy animation requires explicit justification and measurement.
- `prefers-reduced-motion` behavior is mandatory, including a meaningful low/no-motion result rather than merely shortening durations.
- Framework integrations must define mount/unmount cleanup, route transition behavior, and duplicate-initialization prevention.
- Scroll-driven behavior must preserve content access when JavaScript, observers, or the animation engine fail.

## Test Contract

- Profile: ShipGlows skill contract and documentation change; no product UI runtime is changed in this chantier.
- Proof path: scenario-first contract assertions, metadata lint, skill audit, skill budget audit, runtime sync, and diff checks.
- Pressure scenarios:
  - `ANIM-WHOLE-PAGE`: a request to animate every section yields reusable global patterns plus bounded exceptions, not one arbitrary effect per section.
  - `ANIM-GSAP-FIT`: GSAP is selected only after stack, dependency, plugin/licensing, and lifecycle fit are established.
  - `ANIM-REDUCED-MOTION`: implementation cannot complete without explicit reduced-motion behavior and browser proof obligations.
  - `ANIM-CLEANUP`: React/Vue/Astro route or component remounting requires scoped initialization and cleanup without duplicate triggers.
  - `ANIM-PERFORMANCE`: layout-shifting, paint-heavy, or excessive scroll-trigger behavior is rejected or requires measured justification.
  - `ANIM-INVALID-ACTION`: missing or unknown action exposes exactly the supported animation actions without silently editing source.
- Manual proof: not required because this chantier changes the workflow contract rather than a rendered product; future product implementation remains browser-proof gated.
- Exception: external GSAP documentation is not required for this contract-only change because no versioned API, package, or plugin behavior is being implemented; the playbook must trigger fresh official documentation review before concrete GSAP dependency/API decisions.

## Dependencies

- Existing `006-sg-design` lifecycle and proof references.
- Existing design-system token and decision-quality contracts.
- Existing browser and technical performance proof routes.
- Fresh external docs verdict: `fresh-docs not needed` for this skill-contract change; required later for concrete GSAP package/plugin/API decisions.

## Invariants

- `006-sg-design` remains the sole public design entrypoint.
- Implementation, browser proof, verification, closure, and shipping remain owned by their existing lifecycle stages.
- Animation work cannot bypass design-system tokens, accessibility, responsive behavior, or visible proof.
- Provider-neutral intent survives future animation-library changes.
- Audit and design actions remain read-only with respect to target product source unless a later ready spec authorizes implementation.

## Links & Consequences

- The mode expands the discoverable public design grammar and therefore requires README, operator guide, and runtime documentation alignment.
- Motion implementation may later affect dependencies, bundle size, licensing, page performance, browser compatibility, component cleanup, screenshots, and public experience; the playbook must surface those gates rather than assume them.
- Existing token, a11y, browser, and performance routes remain consumers of the new motion workflow.

## Documentation Coherence

- Update the `006-sg-design` public invocation description and supported modes in `README.md`.
- Update the operator launch cheatsheet with the exact animation grammar and intent keywords.
- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` with the new bounded playbook and public route.
- No editorial/site content page is required because this is workflow documentation, not a new marketed product capability.

## Edge Cases

- Static sites where CSS transitions are sufficient and GSAP would add unjustified weight.
- Existing GSAP projects with premium plugins whose license or build setup cannot be assumed.
- SSR or partial-hydration components where browser-only initialization must be scoped.
- Route transitions and repeated mounts that can duplicate timelines or ScrollTriggers.
- Hidden/offscreen content that becomes inaccessible when initialization fails.
- Responsive layouts where trigger distances and sequencing must be recomputed rather than copied from desktop.
- Reduced-motion users who still need state changes and reading order to remain understandable.
- Animation audits on projects with no declared motion authority.

## Implementation Tasks

- [x] Task 1: Add focused contract scenarios for the animation mode.
  - File: `tools/test_sg_design_contract.py`.
  - Action: Assert exact grammar, provider-neutral naming, GSAP fit gate, reduced-motion/performance/cleanup rules, documentation visibility, and invalid-action behavior.
  - User story link: prevents a vague or unsafe animation workflow from appearing complete.
  - Depends on: none.
  - Validate with: `python3 -m unittest tools.test_sg_design_contract`.
- [x] Task 2: Add the animation playbook and routing contract.
  - Files: `skills/006-sg-design/references/animation-playbook.md`, `skills/006-sg-design/references/design-lifecycle-routing.md`, `skills/006-sg-design/references/design-proof-and-reporting.md`.
  - Action: Define action semantics, motion-system workflow, GSAP selection, lifecycle safety, accessibility, responsive, performance, and proof requirements.
  - User story link: supplies the reusable professional workflow behind the public mode.
  - Depends on: Task 1.
  - Validate with: focused contract tests and metadata lint.
- [x] Task 3: Expose the compact public mode from the design activation contract.
  - File: `skills/006-sg-design/SKILL.md`.
  - Action: Update description, argument hint, required loader, route summary, validation, and stops without duplicating the playbook.
  - User story link: makes animation intent directly routable.
  - Depends on: Task 2.
  - Validate with: focused contract tests and skill budget audit.
- [x] Task 4: Align public and technical discoverability.
  - Files: `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`.
  - Action: Add the exact animation grammar and concise promise; do not market an AI builder or GSAP-only capability.
  - User story link: lets operators discover and invoke the mode accurately.
  - Depends on: Task 3.
  - Validate with: focused contract tests, metadata lint, and targeted `rg`.
- [x] Task 5: Run conservative refresh and full focused validation.
  - Files: changed skill and documentation surfaces only.
  - Action: Review novelty, source completeness, instruction layering, budget, runtime sync, metadata, and diff integrity; repair findings before verification.
  - User story link: ensures the mode is durable and followable by a fresh agent.
  - Depends on: Tasks 1-4.
  - Validate with: validation matrix in Test Strategy.

## Acceptance Criteria

- [ ] AC1: Given `006-sg-design animation audit <scope>`, when the mode is parsed, then it remains read-only and evaluates coherence, accessibility, responsiveness, cleanup risk, and performance.
- [ ] AC2: Given `animation design`, `implement`, or `tune`, when routed, then each action has distinct scope and proof semantics documented in the playbook.
- [ ] AC3: Given a request explicitly mentioning GSAP, when the workflow selects an implementation approach, then GSAP is treated as an optional adapter after project-fit and current-doc checks rather than as the public mode identity.
- [ ] AC4: Given a whole-page request, when the motion contract is produced, then it defines reusable global patterns, section overrides, and an animation budget instead of unrelated effects per section.
- [ ] AC5: Given an implementation action, when completion is evaluated, then reduced-motion, responsive behavior, failure-safe content access, framework cleanup, and browser proof are mandatory.
- [ ] AC6: Given an unknown animation action, when parsing fails, then the workflow exposes exactly `audit`, `design`, `implement`, and `tune` and performs no source edit.
- [ ] AC7: Given the completed change, when focused tests, metadata lint, skill audit, budget audit, runtime sync, and diff checks run, then all pass or the chantier remains unverified.
- [ ] AC8: Given public documentation, when an operator searches for animation work, then the exact invocation and provider-neutral promise are discoverable without claiming an AI visual builder.

## Test Strategy

1. Run focused scenario tests: `python3 -m unittest tools.test_sg_design_contract`.
2. Lint changed frontmatter: `python3 tools/shipglows_metadata_lint.py <changed markdown artifacts>`.
3. Run the generic skill audit: `python3 tools/audit_shipglows_skills.py`.
4. Run budgets: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
5. Check runtime parity: `tools/shipglows_sync_skills.sh --check --skill 006-sg-design`.
6. Run targeted discovery checks for `animation`, `GSAP`, `prefers-reduced-motion`, lifecycle cleanup, performance, and the four actions.
7. Run `git diff --check` and inspect only the scoped diff.

## Risks

- Overfitting the workflow to GSAP could make the design skill stack-specific and brittle.
- A broad mode could encourage decorative over-animation unless reuse, budgets, and intent are explicit.
- Accessibility could be reduced to a checkbox unless reduced-motion outcomes and content access are behavioral requirements.
- Framework cleanup and route lifecycle problems can remain invisible in static code review.
- Documentation growth could dilute activation clarity unless procedure stays in one focused reference.

## Execution Notes

- Read first: `skills/006-sg-design/SKILL.md`, `skills/006-sg-design/references/design-lifecycle-routing.md`, `skills/006-sg-design/references/design-proof-and-reporting.md`, `skills/references/design-system-token-contract.md`, and the focused 006 test if present.
- Keep `SKILL.md` activation-only; place matrices, decision rules, examples, and proof procedure in `animation-playbook.md`.
- Do not add a `gsap` alias or silently install dependencies.
- Use scenario-first implementation: write focused assertions before changing the contract.
- Documentation Update Plan: required for README, operator guide, and runtime documentation.
- Editorial Update Plan: no impact; no marketed feature or public site content is created.
- Stop if the implementation requires broad shared-doctrine changes, a new dependency, plugin licensing claims, or unrelated dirty-file edits.

## Open Questions

None. The operator approved a spec-backed animation mode and requested delegated implementation; provider neutrality and the four-action grammar are implementation decisions grounded in the existing design lifecycle.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-04 | 100-sg-spec | GPT-5 Codex | Created the implementation-ready animation-mode contract from the operator request and current 006 design architecture. | draft | 101-sg-ready |
| 2026-08-04 | 101-sg-ready | GPT-5 Codex | Reviewed user-story fit, exact write surfaces, provider neutrality, scenario-first proof, documentation impact, and stop conditions. | ready | 102-sg-start |
| 2026-08-04 | 102-sg-start | gpt-5.6-terra | Implemented the focused tests, provider-neutral animation playbook, compact 006 route, proof contract, and discoverability updates within the assigned write set. | implemented | 900-shipglows-core refresh |
| 2026-08-04 | 900-shipglows-core | GPT-5 Codex | Conservatively reviewed instruction layering, provider neutrality, source completeness, metadata dependencies, public docs, context budget, and runtime visibility; corrected one dependency-version mismatch. | refreshed | 103-sg-verify |
| 2026-08-04 | 103-sg-verify | GPT-5 Codex | Standard verification passed all eight acceptance criteria with nine focused scenarios, metadata lint, execution-fidelity audit, budget audit, runtime sync, targeted discovery checks, and diff hygiene. | verified | 104-sg-end |
| 2026-08-04 | 104-sg-end | GPT-5 Codex | Closed the local implementation scope after documentation reflection confirmed the README, operator guide, runtime docs, refresh log, spec, and changelog were aligned; no product-runtime proof remained. | closed | 005-sg-ship when requested |

## Current Chantier Flow

`100-sg-spec ✅ -> 101-sg-ready ✅ -> 102-sg-start ✅ -> 900-shipglows-core refresh ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> 005-sg-ship not requested`
