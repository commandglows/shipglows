---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 407-sg-translate
scope: translation-quality
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/407-sg-translate/SKILL.md
  - skills/407-sg-translate/references/audit-playbook.md
  - skills/407-sg-translate/references/sync-playbook.md
depends_on: []
supersedes: []
evidence:
  - "Cross-mode language, completeness, formatting, placeholder, and technical-i18n rules migrated from the former 407 activation contract."
next_step: "/103-sg-verify consolidate translation skill under sg-translate"
---

# Translation Quality Reference

Load from the selected audit or sync playbook. This file owns cross-mode quality rules; it does not select a mode or grant mutation authority.

## Contents

- Architecture Patterns
- Completeness
- Language And Terminology
- French Quality
- Structure And Placeholder Integrity
- UI And Formatting Risk
- Technical I18n Invariants
- Evidence And Reporting Fields

## Architecture Patterns

Classify the project without assuming one framework:

- file-based locale routes such as localized page trees
- JSON, YAML, ARB, PO, or code-based message catalogs
- localized content collections and frontmatter
- inline translation functions such as `t('key')`
- paired bilingual fields such as `titleFr` and `titleEn`
- hybrid systems combining routes, content, and message catalogs

For content collections, verify that locale counterparts map through a reliable slug, ID, translation key, or declared relation. A shared-looking filename alone is not proof.

## Completeness

Check all applicable surfaces:

- keys or entries exist in every supported target locale
- localized content counterparts and translatable frontmatter exist
- no target value is accidentally left in the source language
- plural/select variants cover locale rules
- dynamic dates, times, numbers, and currencies use locale-aware formatting
- image alt text, labels, placeholders, titles, errors, empty states, and accessibility text are localized
- bilingual object/message fields are checked together

Counts must name their denominator and scope. Missing-key equality does not prove natural language, correct mapping, or rendered completeness.

## Language And Terminology

- Write like a native speaker; reject gibberish, literal calques, and machine-like syntax.
- Preserve project tone and formality, including `tu`/`vous`, `du`/`Sie`, and equivalent locale conventions.
- Translate the same established source term consistently unless context justifies a documented variant.
- Preserve brand and product names. Keep universal or project-standard technical nouns such as API, URL, and JavaScript in English when that is the project convention.
- Adapt idioms, examples, dates, numbers, currencies, units, and cultural references for the locale without changing business meaning.
- Treat offer, legal, pricing, guarantee, security, regulated, and trust wording as business-sensitive; do not invent equivalence.

## French Quality

- All required accents and ligatures are mandatory: `é`, `è`, `ê`, `à`, `â`, `ù`, `û`, `ô`, `î`, `ï`, `ç`, `œ`, and `æ` where linguistically required.
- Apply project typography for non-breaking spaces before `:`, `;`, `!`, and `?`, and around `« »`.
- Avoid unnecessary anglicisms when a natural project-consistent French term exists.
- Re-read every created or modified French entry specifically for missing accents; an omitted accent is an orthographic error, not a style preference.

## Structure And Placeholder Integrity

Compare source and target structures, not only visible words:

- named and positional placeholders
- ICU plural/select fragments
- interpolation delimiters and escape sequences
- Markdown links and reference targets
- HTML/XML tags, attributes, and nesting
- component placeholders or rich-text markers
- line breaks and formatting tokens when structurally significant

Different placeholder sets or malformed nesting block low-risk sync. Never delete, rename, translate, reorder unsafely, or silently escape a token to make a validator pass.

## UI And Formatting Risk

- Flag likely clipping, overflow, wrapping, or button-label risk for longer translations; language-specific expansion percentages are heuristics, not proof.
- Verify repeated action labels and system states remain consistent.
- Ensure errors, confirmations, loading, empty, and recovery states match the product tone.
- Do not modify layout or design tokens from this skill; route observed rendered issues to `006-sg-design` with exact evidence.

## Technical I18n Invariants

Check when applicable:

- `<html lang>` or equivalent runtime locale matches the rendered locale
- each locale has a stable, unique URL under the project's declared strategy
- `hreflang`/alternate links cover available counterparts and `x-default` where the strategy requires it
- canonical and `og:url` are locale-correct rather than all pointing to the source locale
- localized metadata, titles, and descriptions exist
- sitemap and `og:locale` cover supported locales
- language switching and preference persistence do not strand or mix locales
- fallback behavior does not silently expose source-language strings as complete target coverage

Translation mode may inspect these invariants. SEO strategy, ranking/index decisions, and broad technical remediation remain owned by `406-sg-seo` or the appropriate implementation lifecycle.

## Evidence And Reporting Fields

Every material finding or sync decision should carry locale, exact key/file/surface, observed source and target state, rule violated, user consequence, confidence, and owner route. Reports distinguish checked facts, inferred source-locale decisions, unchanged ambiguous items, and untested rendered behavior.

`TR-BOUNDARY`: persuasion, SEO strategy, drafting/editorial, docs, design, and implementation findings retain their adjacent owners. `TR-HISTORY`: historical records may keep the retired identity; current instructions and discovery surfaces may not.
