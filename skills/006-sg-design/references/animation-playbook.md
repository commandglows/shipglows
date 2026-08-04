---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-04"
status: active
source_skill: 006-sg-design
scope: animation-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/006-sg-design/references/design-proof-and-reporting.md
  - skills/references/design-system-token-contract.md
  - skills/108-sg-browser/SKILL.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/006-sg-design/references/design-proof-and-reporting.md
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Provider-neutral animation workflow approved through the sg-design-animation-mode ready spec on 2026-08-04."
next_review: "2026-09-04"
next_step: "/103-sg-verify sg-design-animation-mode"
---

# Animation Playbook

## Purpose

Use this playbook for `006-sg-design animation <audit|design|implement|tune> [scope]`.

It turns a motion request into a coherent, accessible motion system. It does
not provide an AI animation builder, install dependencies, or make GSAP the
public identity. GSAP is an optional web adapter after project fit is proven.

## Action Contract

- `audit`: read-only inventory of motion coherence, token authority,
  accessibility, responsive behavior, lifecycle risk, and performance risk.
- `design`: read-only motion contract: intent, semantic tokens, reusable
  patterns, exceptions, budget, and required proof.
- `implement`: apply a ready motion contract with the project-native approach
  or a justified adapter; collect the proof matched to the visible claim.
- `tune`: preserve the existing motion concept while refining timing, easing,
  stagger, intensity, trigger boundaries, or breakpoint behavior.

Audit and design never change target product source. Broad whole-page or
multi-section implementation is spec-first; a narrow, ready mini-contract may
be implemented only when the normal design scope gate permits it.

## Intake And Motion System

1. Resolve the canonical design-system authority and its motion tokens before
   proposing values. Do not add raw durations, easings, or distances outside it.
2. State the user or product purpose for each motion family: orientation,
   hierarchy, feedback, continuity, or deliberate emphasis. Decorative motion
   without a purpose is a candidate for removal.
3. Inventory routes, components, repeated headings/cards/lists/media, current
   transitions, scroll behavior, framework boundaries, and supported breakpoints.
4. For a whole-page request, define a small vocabulary of reusable global
   patterns (for example, heading entrance, media reveal, list stagger, and
   interaction feedback), bounded section overrides, and an animation budget.
   Do not assign an arbitrary effect to every section.
5. Record the pattern selector/owner, trigger, tokenized timing/easing/distance,
   reduced-motion outcome, responsive behavior, cleanup owner, and proof plan.

An animation budget limits concurrent effects, scroll-driven triggers, and
exception count. Prefer one coherent pattern family over a collection of
unrelated reveals.

## Adapter Selection

Choose the smallest project-native solution that satisfies the contract. CSS
transitions, the Web Animations API, and framework-native motion can be better
fits than a library.

GSAP is an optional web adapter only after all of the following are established:

- project stack and interaction fit;
- current official documentation for the concrete API, version, and plugin;
- dependency, plugin, and licensing fit, including any existing premium plugin;
- framework lifecycle fit for client-only execution, route changes, and cleanup;
- performance and bundle impact relative to the expected experience.

Never install GSAP, add a plugin, or change licensing posture implicitly. If a
dependency or licensing decision is required, stop and route it through the
normal implementation and freshness gates. A mention of GSAP in the request is
not approval to add it.

## Accessibility, Responsive, And Lifecycle Safety

- `prefers-reduced-motion` requires a meaningful low-motion or no-motion
  outcome. Preserve orientation, state changes, reading order, and access to
  content; merely shortening every duration is insufficient.
- Define responsive behavior by breakpoint and input conditions. Recompute
  responsive measurements and trigger geometry after layout changes rather
  than copying desktop distances to tablet or mobile.
- Content remains available if JavaScript, observers, or the animation engine
  fail. Never hide critical content solely until an animation initializes.
- For React, Vue, Astro islands, or equivalent client boundaries, define scoped
  initialization, mount/unmount cleanup, route-transition behavior, and
  duplicate initialization prevention. Dispose timelines, listeners, and
  scroll observers/triggers owned by the component or route.

## Performance And Proof

Prefer transform and opacity animations. Treat layout- or paint-heavy animation
(for example geometry, filters, or large repaints), excessive scroll triggers,
or continuous effects as a performance risk: remove it, reduce it, or provide
measured justification before accepting it.

For implementation or tuning, use the proof route in
`design-proof-and-reporting.md` and collect:

- browser proof at supported desktop and narrow/mobile conditions;
- browser proof for reduced-motion and content access with failed/disabled
  animation initialization where applicable;
- remount/route-transition proof that cleanup prevents duplicate timelines or
  triggers;
- appropriate performance evidence for scroll-driven, paint-heavy, or
  budget-sensitive motion.

Do not report animation behavior as verified when a required accessibility,
lifecycle, browser, or performance proof is missing.

## Stops

Stop with the exact recovery route when canonical motion authority is absent,
the request needs a broad implementation spec, dependency/plugin/licensing fit
is unknown, reduced-motion or cleanup behavior cannot be proven, or the
requested effect needs unmeasured layout/paint-heavy work. Preserve a partial
or blocked status rather than calling a generated animation complete.
