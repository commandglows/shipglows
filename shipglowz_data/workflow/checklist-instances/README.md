---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlowz
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
scope: checklist-instance-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - templates/project_checklist_instance.md
  - skills/references/project-lifecycle-checklist-contract.md
  - tui/src/sources/checklistInstances.ts
depends_on: []
supersedes: []
evidence:
  - "Project-specific checklist cycles are stored as Markdown instances and projected read-only by ShipGlowz."
next_review: "2026-08-28"
next_step: "/001-sg-build create the first real project checklist instance"
---

# Checklist Instances

This directory contains project- and cycle-specific copies of reusable
checklist masters, across all applicable lifecycle domains. SEO is only one
possible instance; a project may have separate technical, cybersecurity,
performance, analytics, marketing, copywriting, launch, production and
maintenance instances.

Each instance must:

- reference a master `checklist_id` and `checklist_version`;
- have a unique `cycle_id`;
- preserve the ordered controls and their evidence;
- be archived when the cycle closes instead of being reset in place.

Instances describe progression. Concrete implementation follow-ups remain in the project's `TASKS.md` and must reference the originating control.

An applicable domain without a defined reusable master is reported as
`needs_review`; no instance is fabricated and no progress is inferred from
tasks. Content SEO, keyword research and editorial production use their own
workflow rather than being folded into the technical SEO instance.
