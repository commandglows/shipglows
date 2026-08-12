---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 300-sg-docs
scope: 300-sg-docs-private-project-playbooks
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - shipglows_data/workflow/playbooks/project-import-playbook.md
  - shipglows_data/workflow/checklists/project-import-checklist.md
depends_on: []
supersedes: []
evidence:
  - "Extracted from the 300-sg-docs activation body during wave-3 compaction."
next_step: "/103-sg-verify progressive skill activation compaction wave 3"
---

# Private Project Playbooks

Private project records live in the separate private Git repository under `~/.shipglows/data/projects/`. Public governance remains in project repositories; ephemeral review state belongs elsewhere. Apply the topology preflight before mutating the target project and the private-data contract before touching private storage.

The activation gate supplies the project-import playbook/checklist, source-intake classification, private-memory store, and private-data contract.

## ADD PROJECT MODE

Use a supplied URL or repository to create one private project fiche:

1. identify source type and project candidate
2. detect existing ShipGlows data, pitch, or governed docs
3. extract stable truth with provenance
4. create or update one private project file
5. record uncertainty and next action
6. hand off to source classification only when downstream routing remains

Never invent a public story. If the source is unavailable or ambiguous, request only the missing URL or material project truth.

## ADD PROJECT UPDATE MODE

Read the existing fiche first, compare it with current evidence, then refresh pitch, business angle, routing tags, owner candidate, and change notes. Prefer a bounded update note when only one claim changed. If the identity or core project truth changed, rewrite deliberately and retain an explicit change log. Remove old claims only when evidence shows they no longer hold.

## Result

Report which stable facts changed, provenance and uncertainty, private-write status, and the next useful outcome without exposing private content unnecessarily.
