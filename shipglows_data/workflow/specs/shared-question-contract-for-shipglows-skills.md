---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-05-05"
created_at: "2026-05-05 17:07:53 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 13:46:36 UTC"
status: ready
source_skill: sg-skill-build
source_model: "GPT-5 Codex"
scope: skill-maintenance
owner: Diane
user_story: "As a ShipGlows operator, I want all skills to share one question/default contract, so questions are rare, numbered, contextual, and recommended defaults are chosen only when they are safe and verifiable."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/preferred-stacks.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/entrypoint-routing.md
  - skills/sg-build/SKILL.md
  - skills/shipglows/SKILL.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - site/src/content/skills/shipglows.md
  - site/src/content/skills/sg-build.md
depends_on:
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "conversation-shipglows-questions-contextuelles-des-skills.md captured the earlier question-contract draft and user decisions."
  - "User decision 2026-05-04: questions should be numbered, explain why, include helpful icons when useful, and name the recommended answer."
  - "User decision 2026-05-04: a skill may proceed by default only when the default is compatible with project context and current best practices."
  - "Operator correction 2026-07-17: platform footprint must be established before greenfield blueprint and stack decisions; an initially omitted mobile surface must not be silently excluded."
  - "Operator correction 2026-07-17: the established Astro-site and Flutter-app defaults must be resolved before blueprint matching or a broad technology comparison."
  - "Operator clarification 2026-07-17: Astro/Vercel and Flutter are first recommendations, and a new app should default to one Flutter codebase across Web, iOS, and Android instead of a single platform."
next_step: "/104-sg-end preferred stack preset contract"
---

# Spec: Shared Question Contract For ShipGlows Skills

## Title

Shared Question Contract For ShipGlows Skills

## Status

Ready.

The behavior is already decided from the captured conversation. No naming, placement, or public-promise question remains open.

## User Story

As a ShipGlows operator, I want all skills to share one question/default contract, so questions are rare, numbered, contextual, and recommended defaults are chosen only when they are safe and verifiable.

## Minimal Behavior Contract

ShipGlows skills must use one shared question/default doctrine for user-facing questions. They should ask only when the answer changes route, scope, risk, proof, closure, ship posture, public claims, or technical/product/editorial direction. They may proceed without asking only when the default is clear, low-risk, reversible, inside scope, compatible with current context and best practices, and verifiable in the current run.

## Success Behavior

- Preconditions: ShipGlows master/orchestrator skills already load shared lifecycle and routing references.
- Trigger: A skill needs to choose whether to ask the user or proceed by default.
- User/operator result: The skill asks a numbered decision question with why, recommendation, and practical options, or proceeds with a context-safe default and states important assumptions when useful.
- System effect: the shared reference is reused instead of duplicating question doctrine in every skill.
- System effect: greenfield platform scope is established before blueprint and stack selection, so credible mobile-capable options such as Flutter cannot disappear because a spec silently assumed web-only delivery.
- Success proof: metadata lint, skill budget audit, runtime skill sync, targeted text checks, diff whitespace check, and site build pass.
- Silent success: not allowed; material assumptions or questions must be visible.

## Error Behavior

- If no responsible default exists, the skill asks a question instead of guessing.
- If the obvious option conflicts with project context, public claims, architecture, security posture, or current best practices, the skill surfaces the conflict.
- If a runtime prompt tool cannot express the full decision brief, the skill sends a short framing paragraph first and uses concise prompt options.
- If validation fails, stop before shipping.
- If launch or roadmap platforms are ambiguous and change the credible architecture, ask one numbered product question before placing any major platform in `Scope Out`.

## Scope In

- Create `skills/references/question-contract.md`.
- Wire the shared contract into master lifecycle and entrypoint routing references.
- Keep local `sg-build` and `shipglows` question gates aligned with the shared contract.
- Update technical docs, workflow docs, README, launch cheatsheet, help, refresh log, and public skill pages where the promise is visible.
- Extend the greenfield question contract, blueprint matching, spec creation, and readiness gates with an explicit platform-footprint decision.

## Scope Out

- Rewriting every skill body.
- Forcing every atomic skill to load the reference when it does not ask user-facing questions.
- Changing skill invocation names.
- Changing runtime prompt tooling.
- Shipping unrelated dirty files.

## Constraints

- Internal skill contracts stay in English.
- User-facing questions use the active user language.
- Icons are helpful scanning aids, not required semantic content.
- The shared contract must reduce duplicated doctrine rather than add long local question sections to every skill.

## Implementation Tasks

- [x] Task 1: Add the shared question contract reference.
  - File: `skills/references/question-contract.md`
  - Validate with: `python3 tools/shipglows_metadata_lint.py skills/references/question-contract.md`

- [x] Task 2: Wire the contract into master lifecycle and routing references.
  - Files: `skills/references/master-workflow-lifecycle.md`, `skills/references/entrypoint-routing.md`
  - Validate with: `rg -n "question-contract|Question Contract" skills/references/master-workflow-lifecycle.md skills/references/entrypoint-routing.md`

- [x] Task 3: Align the main local question gates.
  - Files: `skills/sg-build/SKILL.md`, `skills/shipglows/SKILL.md`
  - Validate with: `rg -n "question-contract|compatible with the current" skills/sg-build/SKILL.md skills/shipglows/SKILL.md`

- [x] Task 4: Update docs and public surfaces.
  - Files: `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `docs/technical/skill-runtime-and-lifecycle.md`, `skills/sg-help/SKILL.md`, `site/src/content/skills/shipglows.md`, `site/src/content/skills/sg-build.md`
  - Validate with: metadata lint where applicable and `pnpm --dir shipglows-site build`.

- [x] Task 5: Prevent platform scope from being inferred before stack selection.
  - Files: shared question and blueprint doctrine plus build/spec/readiness owner contracts.
  - Validate with: focused `SSRP-009` scans, metadata lint, skill audits, budget audit, and runtime sync checks.

- [x] Task 6: Apply operator-approved preferred stack presets before blueprint matching.
  - Files: `skills/references/preferred-stacks.md`, shared question/blueprint/lifecycle doctrine, and build/spec/readiness owner contracts.
  - Validate with: focused `PSP-003` and `SSRP-010` scans, metadata lint, core tests, skill audit, budget audit, runtime sync, and project-spec coherence checks.

- [x] Task 7: Make Astro/Vercel and cross-platform Flutter the first recommendation rather than neutral options.
  - Files: preferred-stack and question doctrine plus the readiness owner contract.
  - Validate with: focused `PSP-005` and `SSRP-011` scans, metadata lint, core tests, skill audit, budget audit, runtime sync, and diff checks.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-05 17:07:53 UTC | sg-skill-build | GPT-5 Codex | Created the shared question-contract chantier from the captured conversation, after confirming prior duplicate/frontmatter/runtime warnings were no longer reproducible. | implemented | /sg-verify specs/shared-question-contract-for-shipglows-skills.md |
| 2026-05-05 17:14:23 UTC | sg-verify | GPT-5 Codex | Verified shared question contract integration: metadata lint, skill budget audit, runtime skill sync, targeted wording checks, bug gate review, AGENTS alias check, diff whitespace, and clean Astro build after purging stale content cache. | verified | /sg-ship "shared question contract" |
| 2026-05-05 17:14:48 UTC | sg-ship | GPT-5 Codex | Quick ship requested for `shared question contract`; staged the bounded question-contract scope after checks, then committed and pushed it. | shipped | none |
| 2026-07-17 08:46:16 UTC | 900-shipglows-core | GPT-5 Codex | Extended the shared greenfield decision contract after the Best Fried Chicken scope failure: platform footprint now precedes blueprint/stack selection, and Flutter must be considered when iOS/Android are required. | implemented | /103-sg-verify greenfield platform footprint question contract |
| 2026-07-17 08:48:04 UTC | 103-sg-verify | GPT-5 Codex | Verified the `SSRP-009` ordering and failure scenario across build, blueprint, spec, and readiness owners; official Flutter docs, metadata lint, core tests, skill audit, budget audit, runtime sync, and diff checks passed. | verified | /104-sg-end greenfield platform footprint question contract |
| 2026-07-17 13:38:03 UTC | 900-shipglows-core | GPT-5 Codex | Promoted the existing Astro-site and Flutter-app convention into a canonical preferred-stack preset resolved before blueprints, then aligned the Best Fried Chicken architecture and narrowed its open technology decision to the shared backend. | implemented | /103-sg-verify preferred stack preset contract |
| 2026-07-17 13:39:53 UTC | 103-sg-verify | GPT-5 Codex | Verified `PSP-003` and `SSRP-010` across lifecycle, build, blueprint, spec, and readiness contracts; metadata, core tests, skill audit, budget, runtime sync, project-doc coherence, and diff checks passed. | verified | /104-sg-end preferred stack preset contract |
| 2026-07-17 13:45:15 UTC | 900-shipglows-core | GPT-5 Codex | Strengthened the preferred preset after the operator's follow-up: Astro/Vercel and one Flutter Web/iOS/Android codebase are now first recommendations, with narrower app targets requiring an explicit constraint. | implemented | /103-sg-verify cross-platform-first preset contract |
| 2026-07-17 13:46:36 UTC | 103-sg-verify | GPT-5 Codex | Verified the cross-platform-first rule with `PSP-005`, `SSRP-011`, an executable regression test, metadata lint, core tests, skill audit, budget audit, runtime sync, and diff checks. | verified | /104-sg-end cross-platform-first preset contract |

## Current Chantier Flow

- `warning cleanup`: done; Astro build, skill budget audit, runtime sync, and metadata lint are clean in the current repo state.
- `sg-spec`: done; ready spec created from the captured conversation and user request.
- `sg-ready`: ready by prior explicit user decisions.
- `sg-skill-build`: implemented; shared contract and integration surfaces updated.
- `sg-verify`: verified; metadata lint, skill budget, runtime sync, targeted wording checks, bug gate review, AGENTS alias check, diff whitespace, and Astro build passed.
- `sg-ship`: shipped; quick mode commit + push.
- `900-shipglows-core`: implemented follow-up correction for greenfield platform-footprint decisions.
- `900-shipglows-core preferred stack follow-up`: implemented; canonical Astro/Flutter/Vercel presets now resolve before blueprint matching and the active product spec is aligned.
- `103-sg-verify`: verified; `SSRP-009`, metadata, core tests, audit, budget, runtime sync, and focused ordering/coherence scans pass.
- `103-sg-verify preferred stack follow-up`: verified; `PSP-003`, `SSRP-010`, metadata, core tests, audits, runtime sync, project coherence, and diff checks pass.
- `900-shipglows-core cross-platform-first follow-up`: implemented; the canonical preset now leads with Astro/Vercel and Flutter Web/iOS/Android, including apparently mobile-only requests.
- `103-sg-verify cross-platform-first follow-up`: verified; focused scenarios, 11/11 core tests, metadata, audits, runtime sync, and diff checks pass.
