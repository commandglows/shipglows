---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-07-08"
status: active
source_skill: 300-sg-docs
scope: workflow-repurpose-packs-index
owner: Diane
confidence: high
risk_level: medium
security_impact: low
docs_impact: yes
linked_systems:
  - shipglows_data/README.md
  - skills/references/repurpose-pack-storage.md
  - skills/202-sg-repurpose/SKILL.md
depends_on:
  - artifact: "skills/references/repurpose-pack-storage.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-08: durable source-faithful packs should be versioned in the project repo."
next_review: "2026-07-22"
next_step: "/300-sg-docs update workflow repurpose packs index"
---

# Repurpose Packs

`shipglows_data/workflow/repurpose-packs/` stores durable source-faithful repurpose packs for this project.

These files are versioned project memory. They capture a source, its reusable truth, justified downstream surfaces, and the owner-skill handoffs that can turn that source into docs, FAQ, public content, notes, or other assets.

## What Belongs Here

- durable source-faithful packs created by `202-sg-repurpose`
- refreshed packs when the same source or thread evolves materially
- reusable source analyses that future content, docs, or email work should be able to consume without rereading the original conversation

## What Does Not Belong Here

- raw inbox dumps
- private secrets
- one-line notes too thin to justify a pack
- final public articles or docs pages
- test evidence better stored under `workflow/evidence/`

## Naming Rule

Use:

`YYYY-MM-DD-<project-or-topic-slug>-repurpose-pack.md`

## Relationship With Other Workflow Folders

- `workflow/repurpose-packs/` = reusable source-faithful memory
- `workflow/specs/` = implementation contracts and chantier history
- `workflow/evidence/` = proof artifacts
- `workflow/research/` = broader research reports
- `workflow/conversations/` = transcript-like conversation captures when needed

## Maintenance Rule

Prefer updating an existing same-source pack over creating near-duplicates.

If the pack contains source-sensitive material that should not be committed, do not store it here. Route it to an ephemeral response or an explicitly private storage path instead.
