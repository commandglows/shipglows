# 407-sg-translate

> Audit a multilingual product or safely synchronize clearly mapped missing translations.

## What It Does

`407-sg-translate` is the single translation and i18n entrypoint. Its `audit` mode checks completeness, terminology consistency, locale-specific technical SEO, hardcoded strings, formatting, and routing behavior for a page, project, or workspace.

Its `sync` mode fills clearly mapped missing localized entries with safety guardrails. `apply` remains accepted as a compatibility alias to `sync`; it is not a separate mode.

## Who It's For

- Solo founders shipping in more than one language
- Product teams maintaining localized marketing sites or apps
- Operators who need confidence before expanding a multilingual surface

## When To Use It

- when a new locale has been added
- when translation work needs a completeness or quality audit
- when locale files, routes, content, or metadata have drifted
- when missing entries should be synchronized from a reliable source locale

## What You Give It

- `audit`, `sync`, a valid path shorthand, `global`, or the compatibility alias `apply`
- existing locale files, content collections, routes, or localized surfaces

## What You Get Back

- a bounded translation and technical-i18n audit
- evidence of missing, inconsistent, hardcoded, or structurally unsafe content
- a guarded sync report with before/after counts, touched files, and unchanged ambiguous items

## Typical Examples

```bash
/407-sg-translate
/407-sg-translate audit src/pages/fr/pricing.astro
/407-sg-translate audit global
/407-sg-translate sync
/407-sg-translate apply src/i18n
```

## Limits

Audit is read-only. Sync does not rewrite existing non-empty translations; ambiguous or business-sensitive entries remain unchanged for review, and nuanced cultural adaptation may still need a native-speaker review.

## Related Skills

- `009-sg-marketing copy` for localized persuasion and copy quality
- `406-sg-seo` for multilingual search and indexing strategy
- `007-sg-content` for substantive localized-content lifecycles
- `400-sg-audit` for a wider release review
