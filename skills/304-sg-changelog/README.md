# 304-sg-changelog

> Turn raw git history into a public changelog people can actually understand.

## What It Does

`304-sg-changelog` reads commit history and generates or updates a `CHANGELOG.md` in Keep a Changelog format. It groups related commits, filters out low-signal internal noise, and rewrites technical commit streams into user-readable release notes.

This is useful when the repo history is accurate but not publication-ready.

## Who It's For

- Solo founders shipping frequently and needing clean release notes
- Product teams that want a public-facing change history
- Maintainers who want to stop writing changelogs from scratch

## When To Use It

- when a release is approaching and commit history needs summarizing
- when the existing changelog is stale
- when you want notes since a tag, a date, or the last recorded entry

## What You Give It

- a git repository
- optionally a tag, a date, or `all`
- an existing `CHANGELOG.md` if one already exists

## What You Get Back

- a structured changelog entry grouped into meaningful categories
- cleaner, user-facing wording instead of raw commit subjects
- optional support for tagging a release after review

## Typical Examples

```bash
/304-sg-changelog
/304-sg-changelog v1.4.0
/304-sg-changelog 2026-04-01
```

## Limits

This skill depends on git history quality. If commits are vague, mixed, or poorly scoped, the output still needs human judgment before publication.

## Related Skills

- `011-sg-pilotage review` to summarize recent work before release notes
- `300-sg-docs` when shipped changes require documentation updates
- `005-sg-ship` when you want to complete the release workflow
