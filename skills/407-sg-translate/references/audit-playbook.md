---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 407-sg-translate
scope: translation-audit
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/407-sg-translate/SKILL.md
  - skills/407-sg-translate/references/translation-quality-reference.md
  - skills/400-sg-audit/references/audit-master-workflow.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Page, project, and global audit procedure migrated from the former 407 activation contract."
next_step: "/103-sg-verify consolidate translation skill under sg-translate"
---

# Translation Audit Playbook

Use only for `407-sg-translate audit [path|scope|global]`, the bare project default, `global`, or a valid path shorthand. Load `translation-quality-reference.md` before scoring. Product files remain read-only.

## Scope And Discovery

Classify exactly one audit scope:

- page/content: read the target, its locale counterparts, imported translation data, and relevant layout/components
- project: inspect the i18n architecture, locale files/routes, content collections, and representative UI surfaces
- global: discover applicable multilingual projects, obtain a bounded selection when needed, and run one read-only project audit per selected project

Determine the translation architecture before interpreting gaps: file-based locale routes, JSON/YAML messages, localized content collections, inline `t()` calls, bilingual fields such as `titleFr`/`titleEn`, or a hybrid. Identify supported locales, configured default and fallback locales, route strategy, translation files, locale directories, content mappings, and project terminology/tone authority.

If the current directory is a workspace root rather than an unambiguous project, normalize to global selection. Load the shared question contract before asking. If applicable projects cannot be determined, report the evidence gap and stop; never infer arbitrary repositories.

## Page Audit

1. Resolve all locale versions and message keys used by the target.
2. Check completeness: missing keys/content, untranslated source-language strings, pluralization, alt text, and locale-aware date/number/currency formatting.
3. Check language quality and terminology against `translation-quality-reference.md`.
4. Detect hardcoded visible text in markup, `aria-label`, `placeholder`, `title`, `alt`, and UI-facing code strings.
5. Check technical i18n: `lang`, locale-specific metadata, `hreflang`, alternate links, canonical/`og:url`, localized or intentionally stable slugs, and counterpart mapping.
6. Report findings with exact surface evidence and a bounded owner route. Do not add translations, extract strings, or repair technical markup in audit mode.

## Project Audit

Run these phases in order:

1. Architecture: framework/approach, locales, default/fallback behavior, route strategy, switcher, preference persistence, and unique locale URLs.
2. Completeness matrix: all keys and localized content counterparts by locale, including translatable frontmatter and stable slug/ID links.
3. Consistency: glossary drift, repeated action labels, error-message tone, pluralization, and locale formatting via the project-standard APIs.
4. Hardcoded strings: components, layouts, pages, attributes, and UI-facing code.
5. Technical i18n: dynamic `lang`, `hreflang` including `x-default` when applicable, sitemap locale coverage, `og:locale`, canonical URLs, and localized metadata.
6. Consequences: identify affected routes, linked locale variants, UI surfaces, search/indexing implications, and trust risk before grading.
7. Report: provide per-locale completeness, content coverage, terminology/formatting posture, hardcoded-string counts, technical-i18n posture, priority findings, and evidence limits.

Technical i18n checks remain part of translation safety; strategy, ranking, and remediation ownership remain with `406-sg-seo`.

## Global Audit

1. Discover projects from reliable workspace and project-governance markers, then identify those with multilingual surfaces.
2. Let the operator select applicable projects when selection is not already explicit.
3. Run one bounded audit per selected project. Parallel workers may be used only with disjoint read scopes and must receive the exact project path, absolute date, discovered locale context, this playbook, and the quality reference.
4. Workers are read-only: no product, tracker, task, or spec writes. Missing context becomes an assumption/confidence limit, not a follow-up question inside the worker.
5. Require each result to state scope understood, context read, linked systems/consequences, findings, and confidence/missing context.
6. Consolidate project grades, cross-project terminology/patterns, and all issues by severity. The coordinator alone may persist separately authorized project-local operational records after results return.

## Grades And Reporting

- `A`: complete, natural, consistent, and technically coherent with adequate proof
- `B`: solid with bounded gaps
- `C`: repeated completeness, quality, or technical-i18n problems with user impact
- `D`: critical mixed-language, missing-locale, misleading, or broken-routing behavior

For page scope, report locales checked, completeness, quality, technical i18n, overall grade, and findings; mutation counts are zero because audit is read-only. For project/global scope, report architecture, completeness by locale, content coverage, consistency, hardcoded strings, technical i18n, severity rollup, exact evidence, and confidence limits.

## Operational Records

Persist audit/task records only when the user or one unique active chantier explicitly authorizes persistence. Before writing, load the shared operational-record and task-registry contracts, re-read the canonical project-local `shipglows_data/workflow/AUDIT_LOG.md` or `TASKS.md`, and apply the smallest traffic-first update. Never let global workers write; never create duplicate root tracker mirrors unless the project contract explicitly requires a compatibility mirror.

## Stops And Pressure Scenarios

- `TR-AUDIT-BARE`: bare input audits only the current unambiguous project and never syncs.
- `TR-AUDIT-PATH`: explicit or shorthand path audits only its locale-linked surface.
- `TR-AUDIT-GLOBAL`: global selection runs bounded read-only project audits and centralizes optional records.
- `TR-INVALID`: invalid or materially ambiguous scope loads no audit work and changes nothing.
- Stop when no auditable locale surface exists, project selection is unreliable, required quality doctrine is missing, or evidence is insufficient to grade without invented certainty.
