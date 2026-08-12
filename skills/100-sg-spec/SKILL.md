---
name: 100-sg-spec
description: "Write specs with user stories, contracts, risks, and plans."
argument-hint: [optional: description de ce qu'on veut construire]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before creating or updating a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. `100-sg-spec` must initialize the chantier registry entry inside the spec itself: frontmatter includes `created_at`, `updated_at`, and `source_model`; the body includes `Skill Run History` and `Current Chantier Flow`; and the first history row records the current `100-sg-spec` run. Open the report with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. If no chantier spec is created or updated, use a `(local)` chantier header with a short work name.

If the user input or a source skill provides a `Chantier potentiel` block, treat it as primary intake context. Preserve its proposed title, reason, severity, scope, evidence, recommended spec, and next step in the new or updated spec instead of flattening it into a vague task description.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, spec-path first, next-step oriented, and using the opening chantier header. Use `report=agent`, blocked, handoff, verbose, or full report only when detailed evidence is needed.

## Mission

`100-sg-spec` is the lifecycle skill that creates or repairs the durable implementation contract. It owns spec quality and chantier initialization; it does not implement, verify, close, or ship.

## Required References

Load only the references needed for the active run:

- `references/spec-creation-workflow.md`: detailed context gathering, user-story reconstruction, investigation, spec template, validation, metadata, acceptance criteria, and final report rules.
- `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: required before choosing direct routing, spec scope, recommendations, or implementation-quality language.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md`: required before asking for actor, trigger, audience, product, scope, or framing decisions that materially change the spec contract.
- `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`: required when a missing business, audience, or product fact belongs to operator knowledge rather than repository evidence.
- `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`: required when the spec creates, changes, audits, verifies, or fixes UI, mobile/app design, visual components, layout, styling, design tokens, theming, shadows, typography, spacing, color, motion, or branding implementation.
- `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`: required only when the spec depends on framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior.
- `$SHIPGLOWS_ROOT/shipglows_data/technical/product-behavior-intelligence.md`: required when the spec defines activation stages, retention hypotheses, behavior-based analytics, feature-impact measurement, exploratory analytics workspaces, or GTM proof sourced from actual product usage.
- `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`: required when a `blueprint:` handoff note or context provides a blueprint path. Loads the blueprint system contract for format and matching.
- `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`: required for greenfield product stack decisions before blueprint intake or technology comparison.
- `$SHIPGLOWS_ROOT/skills/references/atlas-cartography-lifecycle.md`: required when a project-owned Atlas exists and the spec creates, changes, splits, or retires a user-visible surface or observable function.
- `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`: required when a spec creates or changes a material business goal, customer journey, capability, critical experience moment, Atlas node or governing product decision.
- `$SHIPGLOWS_ROOT/skills/references/zombies-edge-case-heuristic.md`: required when a non-trivial behavior contract needs edge-case, boundary, interface, or exceptional-path coverage.
- `$SHIPGLOWS_ROOT/skills/references/owasp-application-security-awareness.md`: required when the spec touches an internet-facing or privileged surface; map relevant OWASP Top 10:2025 categories and selected ASVS v5.0.0 requirements to risks, invariants, and proof.
- Supabase, Sentry, development-mode, or other shared references only when the workflow reference triggers their gate.

## Mode Detection

Parse `$ARGUMENTS` and the latest user request, then choose the smallest safe path as defined by `decision-quality-contract`: the smallest complete professional contract, not the fastest/easiest route. Apply the `Structure Replacement Doctrine`: write or expand a spec when it replaces repeated ambiguity, coordination friction, or maintenance burden; do not create process weight that adds no real operator leverage.

- Blueprint intake (handoff includes `blueprint: [id]` or a blueprint path in context): load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`, then load the specified blueprint and pre-fill the spec's Architecture, Stack, Models, and Routes sections before entering the normal workflow. The blueprint is the app skeleton; the spec builds on it with project-specific decisions.
- New non-trivial work or a `Chantier potentiel` intake: load `references/spec-creation-workflow.md` and create or update a durable spec.
- If the user says they want to start a new change but the durable work item does not yet exist, route into spec creation immediately instead of staging a parallel OpenSpec-style scaffold first.
- Small/local work where a spec would add no useful contract: use a `(local)` chantier header and route directly to the owner skill.
- Missing actor, trigger, observable result, scope boundary, security/data policy, or operator-owned business/product framing that changes behavior: ask the smallest targeted question before writing the spec.

## Core Execution Rules

- A ready spec must be autonomous enough for a fresh agent: user story, minimal behavior contract, success/error behavior, scope, tasks, acceptance criteria, risks, linked systems, documentation impact, and run history.
- For non-trivial behavior, acceptance criteria and the proof plan must retain compact `ZOMBIES coverage`; mark irrelevant categories `not applicable` with a reason instead of inventing tests.
- Specs are written for implementation, not brainstorming; avoid placeholders, vague tasks, and undocumented assumptions.
- Specs must preserve the decision-quality and excellence bar: correctness, security, performance where relevant, maintainability, durability, professional best practices, and proof quality before speed or convenience.
- When a spec touches declared products or product-facing surfaces, the contract must state the governed product source of truth, canonical public URLs, delivery model, and claim-proof obligations instead of leaving product coherence implicit.
- When a spec introduces analytics, activation, retention, or AI-feature measurement, it must define the product value loop being measured instead of falling back to vanity events or generic session counts.
- Keep `100-sg-spec` role-pure: produce or repair the durable spec contract, then route ownership forward; do not collapse readiness, implementation, verification, closure, or shipping into this skill.
- Specs must improve the current operating structure, not merely document motion: when a direct owner route is already clear and durable, avoid creating a spec that adds ceremony without reducing friction, delay, or maintenance cost.
- Runtime specs must include Sentry, safe diagnostics/log-copy, and commit/build + Paris/UTC build-time header expectations from `$SHIPGLOWS_ROOT/skills/references/sentry-observability.md`, or document why the static-site exception applies.
- UI/design specs must identify the project design-system authority before implementation: brand contract, canonical token source, technology carrier, component bridge, layout/motion authority, forbidden bypasses, and validation command. If this authority is missing, the spec must route to `300-sg-docs` or `006-sg-design system` before any visual implementation task.
- In an Atlas project, a spec that changes the product map must name the affected stable surface/function IDs, customer outcome, intended delivery-state transition, and any required mapping task; it never creates an approval merely by planning the work.
- For a material product-decision change, specs must show `before → after`, preserve upstream/downstream trace, name affected canonical artifacts/IDs/proofs and state preserved invariants before implementation tasks are accepted.
- Specs must preserve the Operator Autonomy Standard from `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: implementation, diagnosis, test, and verification should gather safe evidence themselves before asking the operator.
- Specs should not treat absent business framing as a generic blocker when one precise operator-owned question can resolve it. Ask for the smallest missing business, audience, or product truth and continue.
- Greenfield product specs with material technology choices not covered by an accepted preferred preset or blueprint must apply the Greenfield Technology Decision Rule from `$SHIPGLOWS_ROOT/skills/references/question-contract.md`: present one researched product-level recommendation, obtain the operator's numbered decision, record its cost/control/maintenance/portability consequences, and keep package-level mechanics agent-owned.
- Before blueprint or stack decisions, greenfield specs must apply the Greenfield Platform Footprint Rule from the same reference: record intended web/PWA/iOS/Android/desktop launch and roadmap surfaces, and never put a major platform in `Scope Out` solely because the first request did not name it.
- After the platform footprint is known, greenfield specs must load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`, apply compatible operator-approved presets without re-asking, and limit the technology decision to uncovered providers or justified exceptions.
- `100-sg-spec` creates or updates the durable chantier spec only; it does not edit `TASKS.md`, `AUDIT_LOG.md`, or legacy `PROJECTS.md`.
- Before creating or mutating a `spec:` operational summary line, load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` and keep the durable spec body separate from that one-line traffic-first record.
- External-doc freshness, security, auth, tenant, data, money, destructive, and public-claim ambiguities must be resolved before the spec is called ready.
- Applicable security specs must retain an `OWASP Security Gate`; do not call a generic security paragraph a sufficient threat or verification contract.
- When a blueprint is active, include `Blueprint: [id] (v[version])` in the final report. Do not override blueprint decisions without explicit user agreement — they represent validated patterns from shipped apps.

## Stop Conditions

Stop and report blocked when:

- A material product, security, data, tenant, external-side-effect, or workflow-integrity decision is missing.
- A greenfield technology direction with material cost, control, maintenance, portability, or provider-lock-in consequences has been fixed without operator agreement.
- A greenfield platform footprint that changes framework or architecture options is missing, inferred from words such as `responsive` or `website`, or excludes a major platform without operator evidence.
- The requested implementation path would satisfy tasks but not the user story.
- A required shared reference is missing or contradicts this activation contract.
- The spec would need `TBD`, hidden assumptions, or untestable acceptance criteria.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier potentiel|Report Modes|Required References|Mode Detection|ready spec|TASKS.md|Atlas|references/spec-creation-workflow" skills/100-sg-spec/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
