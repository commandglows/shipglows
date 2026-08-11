---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-07-08"
status: draft
source_skill: 300-sg-docs
scope: project-import-checklist
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/project-import-playbook.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/project-import-playbook.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "User decision 2026-07-08: add-project should follow precise steps, but remain a mode rather than a standalone skill."
next_review: "2026-07-22"
next_step: "/300-sg-docs update project-import checklist"
---

# Project Import Checklist

## Before Start

- [ ] URL or repo is available
- [ ] Source type is known or can be resolved quickly
- [ ] Private memory root is available at `~/.shipglows/data/`

## Import

- [ ] Identify source type
- [ ] Check for existing project fiche
- [ ] Check for existing pitch or governed truth
- [ ] Extract stable project facts
- [ ] Write or update `projects/<project-slug>.md`
- [ ] Keep private material out of Git
- [ ] Record uncertainty and provenance

## After Import

- [ ] Decide whether downstream routing is needed
- [ ] Route to `sg-emailing`, `007-sg-content repurpose <source>`, `300-sg-docs`, `203-sg-research`, `009-sg-marketing market`, or `205-sg-veille` if applicable
- [ ] Confirm the file remains short and reviewable

## Update Pass

- [ ] Compare the current source against the existing private file
- [ ] Refresh the pitch if the project has evolved
- [ ] Update the business angle if it is materially different
- [ ] Update routing tags and owner skill candidate if needed
- [ ] Record what changed since the previous version
- [ ] Preserve old claims only when they still hold

## Completion Rule

This checklist is complete only when one private project file exists or has been refreshed, and no private source material has been written to a public repository.
