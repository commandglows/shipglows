---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-07-08"
status: active
source_skill: 900-shipglows-core
scope: public-first-content-default
owner: unknown
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/references/editorial-content-corpus.md
  - shipglows_data/editorial/content-map.md
depends_on:
  - artifact: "shipglows_data/editorial/content-map.md"
    artifact_version: "0.10.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator decision 2026-07-08: when Diane invokes sg-content, the default goal is public content unless she explicitly says internal content or uses sg-docs."
next_review: "2026-07-22"
next_step: "/103-sg-verify public-first-content-default"
---

# Public-First Content Default

## Purpose

This reference removes ambiguity for Diane's normal content workflow.

When Diane invokes ShipGlows content-writing skills, the default target is a public content surface unless she explicitly redirects the task toward internal documentation or an internal-only artifact.

## Applies To

Apply this default when Diane invokes:

- `007-sg-content`

This reference may also guide adjacent writing skills when the same public-surface ambiguity appears, but it is binding first for those two owner paths.

## Default Rule

Assume `public surface` by default when Diane asks for content through `007-sg-content`, including `repurpose <source>`.

That means:

- do not default to free paragraphs, loose notes, or ambiguous intermediate copy
- do not treat public-vs-internal as still undecided
- do not ask whether the content is public unless Diane's instruction conflicts with the repo evidence

Choose the correct declared public surface instead:

- blog/article
- public docs
- FAQ
- pricing/support/public skill page
- other declared public route

## Internal Exception

Do not apply the public-first default when one of these is explicitly true:

- Diane says `internal`, `interne`, `private`, `not public`, or equivalent
- Diane explicitly asks for an internal artifact, operator note, governance note, or execution-facing draft
- Diane uses `300-sg-docs` for the task

In those cases, treat the content as internal-facing and preserve the normal documentation/governance path.

## Output Rule

For Diane's public-first content runs:

- `007-sg-content repurpose <source>` may produce a source-faithful structured pack, but it must name the intended public surface explicitly
- `007-sg-content repurpose <source>` must not stop at unlabeled free paragraphs
- `007-sg-content` must treat public placement as already decided in principle and only arbitrate which declared public surface is correct

## Prevention Rule

If a content answer could plausibly be mistaken for a preparatory note instead of publishable public-surface work, the skill must either:

- label it explicitly as a draft for a named public surface
- or reroute immediately to the owner path that will apply it on that public surface
