---
name: 406-sg-seo
description: "SEO domain router for audits, launches, monitoring, and fixes."
argument-hint: <mode|page|URL|content file|project>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report. Add a `Chantier potentiel` block when findings reveal non-trivial future work and no unique chantier owns it.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when the user or next owner needs detailed evidence.

## Mission

`406-sg-seo` is the SEO domain router. It selects the smallest safe SEO mode, loads the canonical doctrine, and returns an audit, launch readiness verdict, monitoring readout, or owned fix plan without duplicating SEO playbooks in the activation body.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/seo-charge-referencement-web-playbook.md`: SEO operating model, execution order, gates, outputs, and failure modes.
- `$SHIPGLOWS_ROOT/shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md`: reusable SEO control surface for launch, audit, and verification.
- `$SHIPGLOWS_ROOT/skills/406-sg-seo/references/seo-audit-workflow.md`: SEO audit modes, technical/on-page/content/schema/internal-linking/AI-visibility checks, tracking, and report details.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`: shared rubric for project-aware content quality score and blocked criteria.
- `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md`: split SEO follow-up between execution backlog and editorial roadmap.

## Scope Gate

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

Route by intent:

- `launch`: load the playbook and checklist first; produce an indexation/metadata/content/schema readiness verdict and only then route downstream audit details.
- `audit`: load the playbook, checklist, and SEO audit workflow; audit a project, page, URL, route, or content file for technical SEO, on-page fit, schema, internal linking, and AI visibility.
- `fix`: load the SEO audit workflow plus governance corpora gates; change SEO files or public content only when explicitly requested or owned by the active chantier.
- `monitoring`: load the playbook and checklist; inspect sitemap, robots, indexation signals, regressions, search-console-like evidence supplied by the user, and unresolved SEO tasks without editing.

Use audit as the default when `$ARGUMENTS` is empty or only names a page, URL, content file, or project. Use launch, fix, or monitoring only when the argument or user request clearly asks for that mode.

## Core Execution Rules

- Load technical/editorial corpus references before changing mapped docs, public content, metadata, sitemap, robots, or schema surfaces.
- Governance Corpora: use `$SHIPGLOWS_ROOT/skills/references/technical-docs-corpus.md` and `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when SEO findings touch mapped docs, public content, claims, sitemap, robots, metadata, or schema.
- Apply the Documentation Freshness Gate before changing external SEO/Search/OpenAI/ChatGPT doctrine.
- Preserve structured data and AI Visibility checks by loading `$SHIPGLOWS_ROOT/skills/406-sg-seo/references/seo-audit-workflow.md` for technical SEO, schema, internal linking, and AEO/GEO review.
- When SEO output includes editorial scoring, use `content-quality-rubric.md` for status, score, and blocking criterion handling.
- Evaluate `Chantier potentiel` for indexation, schema, content architecture, AI visibility, or multi-page remediation.
- Treat playbooks/checklists/references as doctrine. Do not expand this activation body with long SEO matrices, templates, provider claims, or troubleshooting trees.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source-faithfulness, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Governance Corpora|OpenAI|ChatGPT|Chantier Potential|Report Modes|structured data|AI Visibility" skills/406-sg-seo/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
