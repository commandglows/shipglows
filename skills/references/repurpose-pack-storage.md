---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-07-08"
status: active
source_skill: 009-sg-skill-build
scope: repurpose-pack-storage
owner: Diane
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - shipglows_data/workflow/repurpose-packs/
  - shipglows_data/README.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-08: source-faithful repurpose packs should be versioned in the project repo instead of stored only in chat or in a private cache."
next_review: "2026-07-22"
next_step: "/103-sg-verify repurpose-pack-storage"
---

# Repurpose Pack Storage

## Purpose

Define the canonical versioned storage location for durable source-faithful repurpose packs inside a project repository.

## Canonical Path

Store durable repurpose packs under:

`shipglows_data/workflow/repurpose-packs/`

This folder belongs to the governed project repo. It is versioned, reviewable, and shareable with future agent runs working on the same project.

## When To Write

Write a pack there when all of these are true:

- the run produced a real source-faithful pack
- the current repository is the governed project that should remember the source
- the operator did not explicitly ask for an ephemeral or chat-only result

Do not default to private-home storage when the operator explicitly chose versioned project storage.

## When Not To Write

Do not write a durable pack when one of these is true:

- the operator explicitly asks for ephemeral output only
- the source contains secrets or private material that should not enter the repo
- the repo is not the correct governed destination
- the source is too thin to justify a durable pack

In those cases, report `ephemeral only`, `unsafe to store`, `wrong repo`, or `signal too weak`.

## File Naming

Use one Markdown file per durable pack.

Preferred filename:

`YYYY-MM-DD-<project-or-topic-slug>-repurpose-pack.md`

Examples:

- `2026-07-08-shipglows-emailing-repurpose-pack.md`
- `2026-07-08-mail-intake-repurpose-pack.md`

When refreshing the same source thread or source asset in the same day, update the existing pack instead of creating duplicates unless the angle or source materially differs.

## Minimum Frontmatter

Each durable pack should include:

- `artifact: repurpose_pack`
- `metadata_schema_version`
- `artifact_version`
- `project`
- `created`
- `updated`
- `status`
- `source_skill`
- `scope`
- `owner`
- `confidence`
- `risk_level`
- `security_impact`
- `docs_impact`
- `source_type`
- `source_ref`
- `linked_systems`
- `next_step`

## Body Contract

The body should preserve the same section logic as the source-faithful pack:

1. `Best Next Actions`
2. `Source-Faithful Pack`
3. `Existing Content Opportunities`
4. `Owner Skill Handoffs`
5. `Evidence Ledger`

Optional article or email-specific appendices are allowed only when they are justified by the source.

## Ownership

- `007-sg-content repurpose <source>` owns writing and refreshing durable repurpose packs.
- Other skills may read these packs as source memory, but they should not silently rewrite them unless they become the clear owner through an explicit handoff.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py skills/references/repurpose-pack-storage.md shipglows_data/workflow/repurpose-packs/README.md
rg -n "repurpose-pack-storage|repurpose-packs" skills/007-sg-content/SKILL.md skills/007-sg-content/references/repurpose-playbook.md shipglows_data/README.md
```
