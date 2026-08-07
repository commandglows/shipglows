---
name: 305-sg-init
description: "Bootstrap ShipGlows tracking, stack detection, and registries."
argument-hint: <project path or bootstrap instruction>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active chantier spec is identified, append the current run to `Skill Run History`; otherwise do not write to any spec.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/bootstrap-workflow.md`: bounded bootstrap index; load only the direct operation reference it selects.
- `$SHIPGLOWS_ROOT/skills/references/project-governance-rules.md`: required when deciding the minimum compliant governed-project shape, especially for monorepos and governance-root expectations.
- `$SHIPGLOWS_ROOT/skills/references/documentation-governance-rules.md`: required when bootstrapping, auditing, or normalizing documentation architecture, metadata, or canonical placement.
- `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`: required for greenfield projects before choosing a source-root layout or confirming the stack preset.
- `$SHIPGLOWS_ROOT/skills/references/question-contract.md`: required before asking bootstrap, project-intent, target-surface, runtime, or governance-scope questions.
- `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`: required when bootstrap depends on operator-owned business, product, audience, or framing truth that cannot be discovered locally.
- `$SHIPGLOWS_ROOT/skills/references/design-system-token-contract.md`: required when bootstrapping or auditing governance for a project with a UI surface.
- `$SHIPGLOWS_ROOT/skills/references/atlas-cartography-lifecycle.md`: required for an explicit `atlas` bootstrap or refresh in a product with user-visible surfaces.
- `$SHIPGLOWS_ROOT/skills/references/guided-business-product-discovery.md`: required when creating or substantially repairing business, product, GTM, brand or customer-led Atlas framing.
- `$SHIPGLOWS_ROOT/skills/references/private-data-repo-contract.md`: required when bootstrap, install, or repair scope touches the durable private data repository under `~/.shipglows/private/data/`.
- `$SHIPGLOWS_ROOT/skills/references/email-work-routing.md`: required only when the operator explicitly requests email-provider, Resend plugin/MCP, sending-domain, or email-operation setup; do not add sending authority for ordinary project bootstrap.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

- Detect whether the request is a new project bootstrap, existing project governance refresh, MCP/server setup, or bootstrap audit.
- `atlas <project>` is the explicit Atlas-cartography mode: load the Atlas lifecycle and operator/question contracts, recover business identity, customer need, and priority journey from the project corpus or concise operator dialogue, then create or refresh the smallest useful **draft** product map. It does not infer operator approval.
- For any mode, load `references/bootstrap-workflow.md` before creating or updating project files. Then load only the direct operation: entrypoint/development mode, trackers/report, context, MCP setup, or governance corpus.
- Direct operation paths are `bootstrap-entrypoint-and-dev-mode.md`, `bootstrap-trackers-and-report.md`, `bootstrap-context-contract.md`, `bootstrap-mcp-setup.md`, and `bootstrap-governance-corpus.md`; do not load another operation without a matching request.
- If business, product, target-surface, or audience framing is materially missing, use the guided discovery loop: show the current synthesis, ask one high-leverage question, then offer `Confirmer`, `Corriger` or `Approfondir` before persisting and continuing.
- For UI projects, detect whether `shipglows_data/technical/design-system-authority.md` or an equivalent project-local authority exists; create the governance gap or route to `300-sg-docs` or `006-sg-design system` before any visual implementation work is considered ready.

## Core Execution Rules

- Preserve absolute-path validation expectations and project-root safety checks.
- Do not rewrite existing project governance artifacts unless the bootstrap workflow explicitly allows it.
- Do not originate a chantier unless the user explicitly asks to formalize setup policy work.
- For an Atlas draft, preserve semantic boundaries: map independently judgeable product surfaces and observable functions, never every DOM node; all newly proposed assessments remain `unknown`.
- Ask only missing business truth in plain language, one decision at a time; do not turn Atlas bootstrap into a technical or exhaustive-feature questionnaire.
- Never infer customer priority, business model, promise or brand intent from the technical stack alone. Mark proposals as hypotheses until the operator confirms them.
- When bootstrap scope includes the private data repository, resolve its remote from configuration such as `SHIPGLOWS_PRIVATE_DATA_REPO` instead of hardcoding an operator-specific repository URL.
- Treat `~/.shipglows/private/data/` as a separate Git working tree for durable private data, not as a subfolder to version inside public repos or `$SHIPGLOWS_ROOT`.
- Stop and report if the target private data path exists but is not a Git repository, unless the active bootstrap contract explicitly includes migration or repair steps.
- For monorepos using the Astro plus Flutter plus backend split, prefer flat source roots at the monorepo root (`site/`, `app/`, `backend/`, `ext/`, `packages/`) instead of nested `apps/*` bundles unless the project documents a durable technical exception. Use `ext/` for the default single browser/web extension; only use `extensions/<extension-name>/` after a second independently shipped extension exists.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|canonical-paths|project-development-mode|governance|Atlas|report" skills/305-sg-init/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
