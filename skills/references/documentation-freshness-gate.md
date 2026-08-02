---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-05-18"
updated: "2026-05-24"
status: active
source_skill: 300-sg-docs
scope: documentation-freshness-gate
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/external-platforms/
  - shipglows_data/technical/platforms/
  - skills/references/technical-docs-corpus.md
depends_on: []
supersedes: []
evidence:
  - "Frontmatter added when the external platform corpus became the global source-map layer for Freshness Gate decisions."
  - "Operator decision on 2026-05-24: project-local provider usage notes are conditional on risk and project-specific behavior."
  - "Operator decision on 2026-05-24: monorepo provider usage notes live under the root governance corpus, scoped by affected app/package."
next_review: "2026-06-24"
next_step: "/300-sg-docs technical audit"
---

# Documentation Freshness Gate

Use this gate when a decision depends on behavior outside the local codebase and that behavior may have changed.

## Trigger

The gate is required when a bug, spec, implementation, or verification depends on:
- framework behavior, routing, caching, rendering, build, packaging, deployment, or config semantics
- SDK/library APIs, deprecations, version-specific behavior, or generated code
- authentication, authorization, sessions, cookies, OAuth, callbacks, protected routes, or tenant boundaries
- external services, APIs, webhooks, payments, email, storage, analytics, search, AI providers, or background jobs
- migrations, upgrade guides, compatibility matrices, peer dependencies, or security-sensitive defaults

The gate is not required for clearly local changes where existing project code fully defines the behavior, such as small copy edits, simple styling tweaks, or isolated refactors with no external contract dependency.

## Source Order

1. Read the local repo first: installed versions, lockfiles, config, wrappers, adapters, and adjacent project patterns.
2. Read the global provider note under `shipglows_data/technical/external-platforms/<provider>.md` when it exists, then read the governance-root provider usage note under `shipglows_data/technical/platforms/<provider>.md` when it exists or when project-specific provider behavior affects the decision.
3. Use Context7 first for official current documentation when the dependency is covered.
4. If Context7 is unavailable or incomplete for the needed point, use official web documentation from the vendor/project.
5. Use changelogs, release notes, GitHub issues, blogs, or Q&A only as secondary evidence for symptoms or known issues, not as the contract to implement.

## Evidence To Capture

When the gate changes or confirms the decision, record:
- dependency/service name and local version when discoverable
- documentation source consulted: Context7 library id or official docs URL/title
- global provider note consulted when available
- governance-root usage note consulted when available or marked `not needed` with a risk-based reason
- the specific rule, API, constraint, migration note, or behavior that affects the decision
- whether the local code follows, intentionally diverges from, or must be changed to match that source

## Verdicts

- `fresh-docs checked`: current official docs were consulted and support the chosen path.
- `fresh-docs not needed`: the task is fully local and no external behavior contract is involved.
- `fresh-docs gap`: docs should have been checked but were unavailable, inconclusive, or skipped.
- `fresh-docs conflict`: current docs contradict the intended or existing implementation and the task must be rerouted, rescoped, or explicitly decided by the user.

## Reporting

Mention the documentation verdict in the final report when it materially affects the fix, spec, implementation, readiness, or verification.

## Maintenance Rule

Update this gate when the source order, evidence requirements, verdict semantics, external platform corpus, or governance-root usage note contract changes.
