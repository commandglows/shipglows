---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-15"
status: active
source_skill: 005-sg-ship
scope: ship-report-evidence
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/005-sg-ship/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted ship-specific evidence fields from the activation contract."
  - "Operator clarification 2026-08-15: full-close ship reports expose documentation reflection even when not impacted."
  - "Operator decision 2026-08-15: full-close ship reports use the shared visual closure card and compact one-line evidence."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Ship Report Evidence

Load this reference only after the ship attempt has reached a terminal state. The shared reporting contract owns headers, user/agent visibility, continuation choices, timestamp, and general proof language; this file adds only ship-specific evidence.

## Evidence Set

Record, when applicable:

- terminal result: pushed, not pushed, blocked, nothing to commit, or checks skipped;
- short commit SHA and concise message only when a commit exists;
- remote and branch only when a push was attempted;
- final repository state and any intentionally remaining dirty scope;
- checks actually attempted, passed, failed, or explicitly skipped;
- bounded versus explicit whole-repository staging when scope needs clarification;
- linked bug result: `blocked`, `partial-risk`, or `not assessed`;
- docs/bookkeeping result in full mode;
- development mode and hosted validation still required;
- explicit risk acceptance without converting it into closure or safety proof.

## Quick Mode

Use `shared for iteration` or equivalent outcome language. State that quick mode performed commit/push only when relevant; it did not close trackers/changelog and does not establish product completeness. Omit empty evidence fields.

## Full Mode

Use `delivered` only when closure guards and required proof support it. Otherwise use `delivered with validation remaining`, `blocked`, or another bounded outcome. Mention tracker/changelog only when actually updated. Every full-close report uses the shared ordered card and keeps both `🧪 PREUVES` and `📚 DOCUMENTATION` evidence on one line separated by ` · `; a material `needs review` result forbids `delivered`.

## Failure And Limits

For a failed push, lead with the failure and preserve the local commit/repo/check state. For nothing to commit, say so without implying a push. Consolidate partial proof, unknown development mode, bug risk, docs gap, or security-sensitive limits into one compact limits line when possible.

Never expose internal skills, slash commands, spec paths, lifecycle phases, or owner routing in `report=user`. Never claim that green checks or a successful push prove recurrence prevention, production truth, security, or user-story completion.
