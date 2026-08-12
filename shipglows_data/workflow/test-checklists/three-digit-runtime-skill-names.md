---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-10"
updated: "2026-06-11"
status: active
source_skill: sg-start
scope: three-digit-runtime-skill-names
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/three-digit-runtime-skill-names.md
  - skills/
  - tools/shipglows_sync_skills.sh
depends_on:
  - artifact: "shipglows_data/workflow/specs/three-digit-runtime-skill-names.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Manual runtime picker confirmation is required before ship if the current agent cannot inspect Codex/Claude UI state."
  - "2026-06-11 user report: all manual picker scenarios pass."
next_step: "/103-sg-verify Three Digit Runtime Skill Names"
---

# Three Digit Runtime Skill Names Checklist

## Scenarios

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RTN-001 | Codex picker | Reload or open a fresh Codex session and search `001`. | yes | `001-sg-build` is visible or invocable. | PASS | User reported `all pass`. | shipglows_data/workflow/TEST_LOG.md | User confirmed live picker proof in chat. | |
| RTN-002 | Claude Code picker | Reload or open a fresh Claude Code session and search `000`. | yes | `000-shipglows` is visible or invocable. | PASS | User reported `all pass`. | shipglows_data/workflow/TEST_LOG.md | User confirmed live picker proof in chat. | |
| RTN-003 | Runtime duplicate cleanup | Search `sg-build` after reload/new session. | yes | No active old ShipGlows symlink entry remains unless the session is using a known runtime cache. | PASS | User reported `all pass`. | shipglows_data/workflow/TEST_LOG.md | Filesystem symlink cleanup was already proven; user confirmed live picker state. | |

## Evidence

2026-06-11: user reported `all pass` after the manual picker card for Codex, Claude Code, and duplicate cleanup.
