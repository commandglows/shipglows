---
name: 302-sg-help
description: "Answer ShipGlows workflow, skill, mode, and prompt questions."
argument-hint: <mode|modes|help topic or route question>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/help-catalog.md`: bounded index for skill discovery, workflow recipes, and quick answers.
- `references/help-modes-catalog.md`: canonical one-line-per-skill mode list for exact `mode` or `modes` requests.
- `skills/references/shipglows-terms.md`: canonical package terminology for `Dev Server`, `TUI`, `local tools`, and skill-scope references.
- `skills/references/question-contract.md`: canonical doctrine for when ShipGlows should ask questions, what shape they should take, and when not asking is the correct autonomous behavior.
- `skills/references/operator-partnership-contract.md`: canonical doctrine for operator collaboration, delegated intent, and the boundary between technical autonomy and operator-owned business truth.
- `skills/references/profile-activation.md`: canonical profile resolution, precedence, fallback, and reporting contract.
- `skills/references/profile-project-context.md`: canonical project-context bundle mapping for named profiles.
- `skills/references/operator-roles/` and `shipglows_data/business/agent-profiles/`: canonical operator-role and named-profile layer when the user asks who should answer, how a named profile works, or how `%Profile` / `profile=` should be used.
- `skills/references/project-governance-rules.md`: canonical answer when the user asks what rules a ShipGlows-governed project must respect or what `#rules` means.
- `skills/references/documentation-governance-rules.md`: canonical answer when the user asks about documentation architecture, metadata, doc placement, or what `#docs` means.
- `skills/references/private-data-repo-contract.md`: canonical answer when the user asks where durable private ShipGlows data lives, whether it is versioned, how it differs from ephemeral private state, or how install/bootstrap should treat the private data repository.
- `shared:resource-discovery`: resolve this semantic resource ID when the user asks how agents find references or playbooks, how starter packs work, how resources expand, or why skills should avoid repeated physical paths.

The canonical `Chantier Registry` doctrine lives in `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`; this skill only summarizes it for help output.

The canonical decision-quality doctrine lives in `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`; this skill summarizes it when users ask about quality, minimal changes, shortcuts, model choice, best practices, security, performance, engineering standards, or the rule "does this replace part of the current structure with less friction, more speed, or less maintenance?"

The canonical numeric skill-code index lives in `$SHIPGLOWS_ROOT/skills/references/skill-code-index.md`; load it when users ask about skill codes, numeric prefixes, shortcuts, faster skill lookup, or exact skill discovery.

When users ask about app creation, blueprints, "crée une app", "quoi de neuf", or how `001-sg-build` handles new app projects, load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` and `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`. Blueprints are global spec skeletons that pre-fill architecture, stack, models, and routes for recurring app archetypes. `001-sg-build` loads them at the Blueprint Gate (after chantier check, before spec). If no blueprint matches, the normal spec-first workflow runs unchanged. Available blueprints are indexed in `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`.
When users ask who should answer, ask for a named business/operator profile, or ask how `%Profile` / `profile=...` works, load `skills/references/profile-activation.md` and `skills/references/profile-project-context.md` and explain the distinction: skill = capability, operator role = decision contract, profile = human-readable invocation layer. `%<Profile>` is canonical; `#<Tag>` remains a focus-tag surface. Load the matching files when a concrete profile is named.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode as defined by `decision-quality-contract`: bounded and professional, never shortcut quality. When the question is about doctrine or tradeoffs, answer through the `Structure Replacement Doctrine` rather than treating novelty, tooling, or extra process as value by default.

`302-sg-help` answers one helper question:

```text
What workflow, skill, mode, or doctrine does the operator need explained right now?
```

- If the user asks a direct help question, answer concisely from the top-level route and the indexed local reference as needed.
- If the exact request is `mode` or `modes`, load `references/help-modes-catalog.md` and return its list verbatim: one line per skill, name and modes only, preserving canonical order.
- If the user asks for skill codes, numeric prefixes, or shortcut lookup, load `skill-code-index.md` and answer from the code table without renaming canonical skills.
- If the user asks how ShipGlows is invoked from Codex, Claude, OpenCode, KiloCode, another runtime, skill codes, taxonomy, or blueprints, load `references/help-skill-discovery.md`.
- If the user needs workflow cheat sheets, load `references/help-workflow-recipes.md`; for a short route load `references/help-quick-answers.md`.
- If the user asks why ShipGlows asked, did not ask, or should have asked a question, load `skills/references/question-contract.md`.
- If the user asks about passivity, autonomy, collaboration style, business framing, or what the operator is expected to provide, load `skills/references/operator-partnership-contract.md`.
- If the user asks about a named profile such as `Victoire`, `SEO Specialist`, or `Tariq`, or asks who should answer a business/growth/search/acquisition question, load the matching profile plus its operator role and answer from that distinction.
- If the user asks whether `%Victoire` or `#Victoire` should be used, answer: `%<Profile>` is the canonical named-profile syntax at the router/governance layer; `#<Tag>` stays for focus tags.
- If the user asks about `#feature:<term>`, explain it as an optional technical-navigation hint for behavior-index recovery before broad search, not a command language, and note that the free-text request still matters.
- If the user asks what `#rules`, `#docs`, `#public-docs`, or `#internal-docs` mean, load the matching governance reference and explain the distinction rather than answering from local shorthand.
- If the user asks about `~/.shipglows/private/data/`, the private memory repo, versioned private data, or why it is separate from public repos, load `skills/references/private-data-repo-contract.md` and explain the storage contract vs clone contract distinction.
- If the user asks about reference/playbook discovery, semantic resource IDs, starter packs, expansion, or the resolver, resolve `shared:resource-discovery` and explain its authority boundary without presenting recommendations as mandatory gates.
- Use `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` for canonical trace/process role doctrine instead of maintaining a duplicate role matrix here.
- For a catalog route, load `references/help-catalog.md` then only its direct target.

Keep the boundary explicit: `302-sg-help` explains, clarifies, and routes. It tells the operator what to type and which owner takes over next. It does not continue a chantier, invoke runtime internals, summarize hidden repo truth, or mutate durable state.

Route immediately instead of staying in help mode when the operator is no longer asking for explanation:

- continue or advance the current work item -> `706-continue`
- summarize only this visible thread -> `303-sg-resume`
- do real lifecycle work -> route to the owning lifecycle or specialist skill

## Core Execution Rules

- Do not write chantier specs or trackers.
- Keep answers user-facing and in the active user language.
- Route to an owner skill when the user asks ShipGlows to do work rather than explain it.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Registry|Skills at a Glance|Quick Answers|references/" skills/302-sg-help/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
