---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-08"
updated: "2026-07-08"
status: draft
source_skill: 300-sg-docs
scope: project-import-playbook
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/references/private-memory-store.md
  - skills/references/source-intake-classification.md
  - shipglows_data/workflow/checklists/project-import-checklist.md
depends_on:
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-07-08: add-project should be a docs mode, not a standalone skill."
  - "User decision 2026-07-08: the private memory root is ~/.shipglows/data/."
next_review: "2026-07-22"
next_step: "/300-sg-docs update add-project playbook"
---

# Project Import Playbook

## Purpose

Import a project from a URL or repository into the private project memory store, then make it available for later source classification and routing.

## Use When

Use this playbook when the operator gives:

- a GitHub repository URL
- a website URL
- a pitch URL
- another project source URL that should become a private project fiche

Use the same playbook for refreshes of an existing fiche when the project evolved and the pitch or routing needs to be updated.

## Output Contract

The target artifact is one Markdown file per project:

```text
~/.shipglows/data/projects/<project-slug>.md
```

The file must stay short, stable, and reviewable.

## Execution Order

### 1. Identify the source

Classify the URL as one of:

- GitHub repo
- website
- pitch page
- other source

If the source type is unclear, ask one targeted question before proceeding.

### 2. Check for existing truth

Look for existing material in this order:

1. current private project file
2. public portfolio pitch index
3. source-intake classification hints
4. project-owned governed docs

Prefer existing governed truth over inferred summaries.

### 3. Extract stable project facts

Capture only durable facts:

- project name
- slug
- source URL
- pitch URL if known
- audience
- business angle
- owner skill candidate
- routing tags
- short internal framing note

Do not invent claims, numbers, outcomes, or positioning the source does not support.

### 4. Write the private project file

Create or update one file at:

```text
~/.shipglows/data/projects/<project-slug>.md
```

Use the schema from `skills/references/private-memory-store.md`.

### 5. Record provenance and uncertainty

Include:

- what source was scanned
- what was found
- what remains uncertain
- whether the file is a first import or an update
- what changed since the previous private file, if one exists

### 6. Route onward if needed

If the source is actually for:

- audience sequence work -> route to `sg-emailing`
- public repurposing -> route to `007-sg-content repurpose <source>`
- doc/governance updates -> route to `300-sg-docs`
- market or competitor analysis -> route to `203-sg-research`, `009-sg-marketing market`, or `205-sg-veille`

## Decision Gates

### Ready

Proceed when:

- the URL or repo is known
- the source type is identifiable
- the result will not leak private material into Git

### Blocked

Stop when:

- the source URL is missing
- the source type is ambiguous and changes the output materially
- the source contains private material that the operator has not approved for durable reuse
- the import would require writing outside the approved private memory root
