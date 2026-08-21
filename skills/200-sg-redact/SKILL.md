---
name: 200-sg-redact
description: "Draft articles, guides, editorials, and brand-voice content."
argument-hint: '<nombre> <format> [sujet] (ex: "3 blog", "1 editorial IA en éducation", "2 informational")'
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `support-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` when this run is attached to a spec-first chantier. If exactly one active chantier spec is identified, append the current run to `Skill Run History`; otherwise do not write to any spec. Do not originate a chantier unless the user explicitly asks to formalize follow-up work.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/redaction-workflow.md`: compact first-decision index for substantive drafting.
- `references/redaction-context-and-governance.md`: load before surface, project-truth, author-identity, or metadata decisions.
- `references/redaction-research-and-planning.md`: load for topic selection, planning, or factual/current research.
- `references/redaction-drafting-and-optimization.md`: load when writing or optimizing the article and its compatible frontmatter.
- `references/redaction-quality-and-reporting.md`: load before a readiness verdict or detailed report.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`: shared rubric for final draft quality score and structured feedback.

## Inspiration Gate

For sales-page or offer-page drafting, CTA/proof/objection sequencing, copy-pattern study, or explicit inspiration requests, load `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`. Filter private `index.yaml` to at most five reference IDs, require operator selection before loading bundles or using direction, and record selected reference IDs in the resulting spec or copy artifact. Summarize transferable patterns and what not to copy; do not reproduce long source passages or redistribute screenshots. A discovered URL is reported with rationale but is not promoted unless curation is in scope or the operator confirms.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

- DRAFTING: load `references/redaction-workflow.md`, then load only its directly selected scenario leaves; leaves never load siblings.
- PUBLIC SURFACE: load editorial and technical corpus references before choosing or changing public content surfaces.
- RESEARCH: apply fresh source checks when factual, market, tool, legal, or current-practice claims are involved.

## Core Execution Rules

- Preserve brand voice, source evidence, public-claim, editorial surface, copyright, disclosure, and quality gates.
- For an article on a multilingual surface, resolve all declared public article locales and create or materially update every mapped peer as one atomic deliverable. Missing or stale translation blocks a ready or completion verdict unless the surface is explicitly monolingual.
- When drafting content about declared products, preserve product-governance coherence: inventory truth, canonical page targets, delivery model, and proof-backed claims must stay explicit or intentionally omitted.
- When requested to score a near-final draft, use `content-quality-rubric.md` for rubric status and structured feedback; do not claim `ready` if blocked criteria remain.
- Do not originate a chantier unless the user explicitly asks to formalize follow-up work.
- Do not invent facts, quotes, legal claims, performance claims, pricing, or customer proof.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Governance Corpora|source|claim|copyright|quality|references/" skills/200-sg-redact/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
