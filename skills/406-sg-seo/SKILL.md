---
name: 406-sg-seo
description: "SEO domain router for audits, launches, monitoring, and fixes."
argument-hint: <mode|page|URL|content file|project>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Public Métier Ownership

Public label: `sg-seo`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or SEO mode selection. Resolve `project -> business/brand/product -> outcome -> surface -> work item` and own the organic-search outcome through audit, remediation, content/marketing collaboration, monitoring proof, affected public documentation, and closure.

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
- `$SHIPGLOWS_ROOT/skills/406-sg-seo/references/seo-audit-workflow.md`: bounded audit index; it selects protocol plus the required direct target branch.
- `$SHIPGLOWS_ROOT/skills/406-sg-seo/references/gsc-evidence-workflow.md`: live read-only Google Search Console ingestion for monitoring and evidence-backed audits; load when GSC data is requested or useful.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`: shared rubric for project-aware content quality score and blocked criteria.
- `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md`: split SEO follow-up between execution backlog and editorial roadmap.

## Scope Gate

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

Route by intent:

- `launch`: load the playbook and checklist first; produce an indexation/metadata/content/schema readiness verdict and only then route downstream audit details.
- `audit`: load the checklist, `seo-audit-protocol.md`, and exactly one direct page/project/global reference; load AI visibility only when in scope. Audit a project, page, URL, route, or content file without mutation.
- `fix`: load `seo-audit-protocol.md`, the direct target reference, and governance corpora gates; change SEO files or public content only when explicitly requested or owned by the active chantier.
- `monitoring`: load the playbook, checklist, and `gsc-evidence-workflow.md`; inspect sitemap, robots, indexation signals, regressions, live read-only GSC evidence when authorized, supplied evidence as fallback, and unresolved SEO tasks without editing.

Use audit as the default when `$ARGUMENTS` is empty or only names a page, URL, content file, or project. Use launch, fix, or monitoring only when the argument or user request clearly asks for that mode.

For an audit/fix target, select one direct branch: `seo-page-audit.md` for a page/URL/content file, `seo-project-audit.md` for a project, or `seo-global-audit.md` for `global`. Load `seo-ai-visibility-review.md` only when AEO/GEO, AI crawler, or OpenAI/ChatGPT claims are in scope.

## Core Execution Rules

- Load technical/editorial corpus references before changing mapped docs, public content, metadata, sitemap, robots, or schema surfaces.
- Governance Corpora: use `$SHIPGLOWS_ROOT/skills/references/technical-docs-corpus.md` and `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when SEO findings touch mapped docs, public content, claims, sitemap, robots, metadata, or schema.
- Apply the Documentation Freshness Gate before changing external SEO/Search/OpenAI/ChatGPT doctrine.
- Preserve structured data and AI Visibility checks by loading the direct target reference and `seo-ai-visibility-review.md` only for AEO/GEO review.
- Use `gsc-evidence-workflow.md` before claiming that GSC data is unavailable, current, complete, or attached to the requested property. Never initiate OAuth consent or select an ambiguous property without operator input.
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
