---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-15"
status: active
source_skill: 005-sg-ship
scope: ship-full-close
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/005-sg-ship/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted full-close bookkeeping from the ship activation contract."
  - "Operator clarification 2026-08-15: full-close shipping must expose documentation reflection and cannot hide a material docs gap."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Full-Close Playbook

Load this playbook only after explicit full-close intent and after the common execution playbook has cleared every pre-mutation stop. Also apply the shared closure archive guard and documentation reflection gate named by the activation contract.

## Reconfirm Closure

Summarize the session in terms of the user story or user-visible outcome. Reconcile implementation, checks, known bugs, documentation, protected surfaces, and remaining hosted/manual proof. If any material gap remains, use partial or in-progress status and do not manufacture `done`.

Git state and bookkeeping never substitute for functional, security, visual, auth, or production evidence.

## Tracker Update

Treat tracker content read at activation as informational only. Immediately before editing a project-local or master tracker:

1. re-read the authoritative file from disk;
2. locate the exact relevant row or section;
3. apply a minimal targeted update;
4. if it moved, re-read once and recompute;
5. if ownership or target remains ambiguous, stop and ask rather than rewriting broad content.

Do not mark closed when the closure/archive guard, bug risk, documentation reflection, or required proof prevents it.

## Changelog And Decisions

Update `CHANGELOG.md` only with meaningful grouped changes supported by the shipped scope. Preserve its established format. Record durable decisions only in the project's authorized memory or decision surface; do not invent a memory system.

Classify documentation as `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>`. Apply directly mapped impacted documentation updates before closure. Route material `updated`/`needs review` work through the documentation owner as required by the shared gate, retain any unresolved gap in the closing report, and visibly include the exact classification. A material `needs review` result forbids full-closure and `delivered` wording.

## Continue To Ship

Return to the common execution playbook for staged inspection, commit, and push. Full-close bookkeeping authorizes a closing report only when the remaining evidence supports it. If hosted validation remains after push, report `delivered with validation remaining` and keep the chantier open.
