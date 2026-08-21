---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: reviewed
source_skill: shipglows-core
scope: mandatory-article-locale-parity
owner: Diane
user_story: "As an operator publishing articles through ShipGlows, I want every article created or materially updated across all declared public locales so an agent cannot silently leave a translation missing or stale."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-governance-and-quality.md
  - skills/007-sg-content/references/content-delivery-and-proof.md
  - skills/200-sg-redact/SKILL.md
  - shipglows_data/editorial/blog-and-article-surface-policy.md
  - tools/article_locale_parity_lint.py
  - tools/test_007_sg_content_compaction_contract.py
  - tools/test_article_locale_parity_lint.py
depends_on:
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-08-21: article creation must automatically include every declared translation because agents sometimes omit translation entirely."
next_step: Review the updated ShipGlows PR 24; apply the scoped validator whenever an article is created or materially updated.
---

# Mandatory Article Locale Parity

## Status

reviewed

## Outcome Contract

When a project declares more than one public article locale, creating or materially updating an article must create or update every mapped locale peer in the same workstream. Translation is routine agent-owned work, not an operator follow-up.

A clean readiness, completion, closure, or delivery verdict is forbidden while a required peer is missing, stale, structurally incompatible, or no longer maps back to the source article. A monolingual result is allowed only when the project or operator explicitly declares that article surface monolingual.

## Required Parity

- Same article identity and source-faithful meaning across declared locales.
- Locale-native title, description, summary, slug, body, CTA, and internal links.
- Symmetric alternate-locale mapping when the runtime schema supports it.
- Claim strength, caveats, publication state, and material updates remain aligned.
- Translation may adapt idiom and examples; it must not be a literal low-quality copy.

## Pressure Scenarios

- `ARTICLE-LOCALE-MISSING`: a French article in a declared FR/EN surface without its English peer blocks completion.
- `ARTICLE-LOCALE-STALE`: a material source update without the mapped locale update blocks completion.
- `ARTICLE-LOCALE-METADATA`: mismatched article identity, locale, alternate slug, publication state, or required metadata blocks completion.
- `ARTICLE-MONOLINGUAL-DECLARED`: an explicitly monolingual article surface may complete without fabricated translations.

## Acceptance Criteria

- [x] The content owner resolves declared article locales before drafting and owns peer creation/update automatically.
- [x] The drafting owner exposes the locale-parity invariant in its activation contract.
- [x] Content validation treats missing, stale, or structurally mismatched peers as a blocking failure.
- [x] ShipGlows public article policy explicitly requires paired FR/EN articles.
- [x] Focused contract tests prove all four pressure scenarios remain followable.
- [x] Exact-scope commits and pushes preserve unrelated dirty files.

## Current Chantier Flow

`operator correction ✅ -> spec/ready ✅ -> scenario-first contract ✅ -> focused proof ✅ -> documentation sync ✅ -> commit/push ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | shipglows-core | ready | Operator approved mandatory translation enforcement for every article on multilingual surfaces. | implement pressure-scenario contract |
| 2026-08-21 | shipglows-core | reviewed | Content and drafting contracts now own every declared locale; the deterministic linter blocks missing peers, one-sided updates, asymmetric alternate slugs, and publication-state drift while preserving explicit monolingual surfaces. Focused tests pass 10/10 and the real Git/GitHub EN/FR pair passes. | exact-scope commit and push |
| 2026-08-21 | shipglows-core | delivered | Implementation commit `c404120` was pushed to the active ShipGlows PR without staging unrelated dirty files. | review PR 24 |
