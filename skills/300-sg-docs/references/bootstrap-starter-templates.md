---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.2.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-06-28"
status: draft
source_skill: 009-sg-skill-build
scope: 300-sg-docs-bootstrap-starter-templates
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/300-sg-docs/references/mode-playbooks.md
  - shipglows_data/technical/
  - shipglows_data/workflow/
depends_on:
  - artifact: "skills/300-sg-docs/references/core-governance.md"
    artifact_version: "0.4.0"
    required_status: "draft"
  - artifact: "skills/300-sg-docs/references/mode-playbooks.md"
    artifact_version: "0.5.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Operator decision on 2026-06-28: docs init for empty repositories needs stable starter templates, not only a routing/playbook note."
  - "Operator decision on 2026-06-28: docs init should guide the operator with precise bootstrap questions instead of treating missing framing as blocked."
next_review: "2026-07-12"
next_step: "/103-sg-verify 300-sg-docs init bootstrap templates"
---

# Bootstrap Starter Templates

Use these templates when `300-sg-docs init` bootstraps an empty or near-empty repository.

The goal is not to fake a product. The goal is to create a stable governance shell that says exactly what is known, what is unknown, and what should be defined next.

When materially useful facts are still missing, `300-sg-docs init` should ask precise numbered questions and use the answers to fill these templates. Missing framing is not, by itself, a blocked state.

## Bootstrap Question Set

Ask at most one question at a time. Use the shared question contract.

Preferred questions:

1. project intent
2. target surface
3. primary runtime/platform

Example intents:

- personal tool
- client portal
- internal admin surface
- content/documentation workspace
- experimental prototype

Example target surfaces:

- web app
- API/backend
- CLI/tooling
- documentation-only
- unknown

Example runtime/platforms:

- Node.js
- Python
- static site
- mixed / undecided
- unknown

If the operator answers partially, write known facts and keep the rest as `unknown`.

## Root `AGENT.md`

Required sections:

- `Project Scope`
- `Governance`
- `Current State`

Required content rules:

- state that the repository is in bootstrap if no code exists yet
- state that durable decisions belong under `shipglows_data/`
- avoid feature promises, stack assumptions, or runtime claims unless observed

## Root `README.md`

Required sections:

- project title
- `Current Intent Status`
- `Current Implementation Status`
- `Known Target Surface`
- `Next Step`

Required content rules:

- if the project goal is unknown, say `unknown`
- if no code exists, say so explicitly
- do not include generic sections like install, API, env vars, or scripts unless they are observed
- keep the next step as a framing action, not a fake build instruction

## `shipglows_data/technical/README.md`

Required sections:

- `Purpose`
- `Owned Files`
- `Entrypoints`
- `Invariants`
- `Validation`
- `Reader Checklist`
- `Maintenance Rule`

Bootstrap rule:

- describe the technical layer as a governance shell when no code exists yet

## `shipglows_data/technical/code-docs-map.md`

Required sections:

- `Status`
- `Scope`
- `Path Patterns`
- `Non-Coverage`
- `Documentation Update Plan`

Bootstrap rule:

- `Status` should be `bootstrap`
- path patterns should stay generic until source files exist
- non-coverage must explain that no source files were detected
- the update plan must point to mapping real code areas once implementation begins

## `shipglows_data/workflow/TASKS.md`

Required sections:

- title
- legend
- `Setup`

Bootstrap rule:

- tasks must be real bootstrap actions
- do not add filler tasks disconnected from the repository state
- at minimum include:
  - define project intent
  - add first source files or module layout
  - update technical mapping after code appears

## `shipglows_data/editorial/ROADMAP.md`

Required sections:

- title
- `Active`
- `Backlog`

Bootstrap rule:

- create this file only when public/editorial surfaces are detected or the editorial governance layer is otherwise applicable
- keep it operational; do not add governance prose, frontmatter, or fake tasks
- include at most short orienting comments that point public/editorial follow-up here and technical implementation work to `shipglows_data/workflow/TASKS.md`
- leave the sections empty by default unless real editorial follow-up is already known during bootstrap

## Empty-Repo Guardrail

For empty or near-empty repositories, these starter templates are the default output. Do not replace them with a normal product README or subsystem docs until observed code or explicit project framing justifies that move.
