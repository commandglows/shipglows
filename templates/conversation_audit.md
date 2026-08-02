---
artifact: conversation_audit
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-30"
updated: "2026-05-30"
status: draft
source_skill: sg-conversation-audit
scope: workflow
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
categories:
  - missed_action
  - over_reporting
  - wrong_owner_route
  - literalism_over_intent
  - proof_gap
  - stale_skill_contract
  - bad_question
  - user_friction
  - unsafe_ship_or_dirty_scope
  - weak_follow_through
findings: []
owner_routes:
  - sf-skill-build
  - sf-docs
  - sf-verify
  - sf-spec
evidence: []
depends_on: []
supersedes: []
next_step: "/sg-verify ShipGlows Conversation Audit And Auto-Evolution Loop"
---

# Conversation Audit

## Context

- Source transcript: `[]()`
- Audit mode: `default`
- Audit scope: `[]`
- Reviewed at: `YYYY-MM-DD HH:MM:SS UTC`

## Redaction / Safety Gate

- Unsafe-content detected: `false`
- Unsafe findings: `none`
- Evidence redacted for public report: `none`
- Block reason (if any): ``

## Findings

Each finding keeps the same structure:

- category: one of stable categories in frontmatter
- severity: low/medium/high/critical
- title: short operational summary
- evidence:
  - file: path
  - excerpt: short anonymized quote
  - line: optional
- user_impact: one-line impact
- affected_skills: `[]`
- confidence: low/medium/high
- recommended_owner: one skill route
- evidence_gap: `none` or short note

| category | severity | title | confidence | evidence | owner | route |
| --- | --- | --- | --- | --- | --- | --- |

## Aggregate Signals

- affected categories: `[]`
- most repeated issue: ``
- owner concentration: `{}`
- evidence quality: medium

## Routing

- recommended_action: `noop|create-spec|open-sg-conversation-audit|reroute`
- recommended_chantier: ``
- suggested next command: ``

## Next Step

- `[]`
