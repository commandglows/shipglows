---
artifact: conversation_audit
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-06-29"
status: active
source_skill: 705-sg-conversation-audit
scope: "300-sg-docs monorepo migration behavior in ContentGlowz conversation"
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
categories:
  - stale_skill_contract
  - weak_follow_through
  - user_friction
  - proof_gap
findings:
  - "300-sg-docs allowed facade-first migration without enforcing semantic preservation proof."
  - "300-sg-docs lacked a mandatory post-migration source-to-canonical consolidation pass."
  - "User had to restate the monorepo single-source contract and ask for preservation verification."
owner_routes:
  - 300-sg-docs
  - 009-sg-skill-build
  - 103-sg-verify
evidence:
  - "Conversation context from 2026-06-29 in /home/claude/contentglowz Codex session."
  - "User explicitly requested one documentation source under Shipglows Data with subfolders by system."
  - "Later consolidation of lab recovered backend/API/runtime details and planning items that had not been preserved in the first migration pass."
depends_on: []
supersedes: []
next_step: "/home/claude/shipglows/skills/300-sg-docs/SKILL.md hardening completed in same session"
---

# Conversation Audit

## Context

- Source transcript: interactive Codex session context, not exported as a standalone transcript file
- Audit mode: `report=agent`
- Audit scope: `300-sg-docs` behavior during ContentGlowz monorepo doc migration
- Reviewed at: `2026-06-29 18:59:25 UTC`
- cleaned_input_used: `true`

## Redaction / Safety Gate

- Unsafe-content detected: `false`
- Unsafe findings: `none`
- Evidence redacted for public report: `none`
- Block reason (if any): ``

## Findings

| category | severity | title | confidence | evidence | owner | route |
| --- | --- | --- | --- | --- | --- | --- |
| `stale_skill_contract` | high | Migration contract enforced canonical destination but not semantic preservation | high | User had to say that documentation should all live in `Shipglows Data`, then a later lab pass recovered durable backend/API/runtime content that had not been preserved in the first pass. | `300-sg-docs` | Harden migration doctrine and playbooks with preservation-first gates. |
| `weak_follow_through` | high | No mandatory consolidation audit after slimming local docs into facades | high | After facade conversion, the user asked for a lab consolidation pass to verify important documentation and task-planning content had not simply been deleted. | `300-sg-docs` | Require source-to-canonical preservation audit when local docs are slimmed or removed. |
| `user_friction` | medium | User had to restate the monorepo single-source contract | high | User message: local documentation still existed and the established contract was one durable source under `Shipglows Data`, scoped by `app/site/lab`. | `300-sg-docs` | Make compatibility-facade exceptions explicit and subordinate to canonical preservation rules. |
| `proof_gap` | medium | Existing validation proved structure and frontmatter, not preservation of meaning | high | Metadata lint and symlink checks passed, but they did not catch missing runtime/API sections and task-planning items until a manual recovery pass. | `103-sg-verify` | Add migration-specific proof expectations to `300-sg-docs` validation. |

## Aggregate Signals

- affected categories: `["stale_skill_contract", "weak_follow_through", "user_friction", "proof_gap"]`
- most repeated issue: `facade-first migration without preservation proof`
- owner concentration: `{"300-sg-docs": 3, "103-sg-verify": 1}`
- evidence quality: high

## Routing

- recommended_action: `reroute`
- recommended_chantier: `300-sg-docs migration-preservation hardening`
- suggested next command: `edit /home/claude/shipglows/skills/300-sg-docs/SKILL.md and references to require preservation-ledger and consolidation proof`
- shipglows_core_followup: `run`
- shipglows_core_followup_result: `python3 /home/claude/shipglows/tools/audit_shipglows_skills.py returned no generic execution-fidelity findings, so the gap is specific to 300-sg-docs contract coverage rather than broad skill packaging failures.`

## Next Step

- `Patch 300-sg-docs local contract, core governance reference, and mode playbooks to require semantic preservation before facade/deletion and to require consolidation proof after migration.`
