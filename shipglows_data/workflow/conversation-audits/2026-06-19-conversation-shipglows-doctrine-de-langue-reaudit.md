---
artifact: conversation_audit
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-19"
updated: "2026-06-19"
status: reviewed
source_skill: 705-sg-conversation-audit
scope: "conversation-shipglows-doctrine-de-langue-20260530-203004"
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
categories:
  - stale_skill_contract
findings:
  - stale_skill_contract
owner_routes:
  - 100-sg-spec
evidence:
  - "shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md"
  - "skills/800-tmux-capture-conversation/scripts/capture_tmux_conversation.sh"
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/actionable-failure-contract.md"
    artifact_version: "1.0.0"
    required_status: draft
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
next_step: "/100-sg-spec transcript-title-inference-dominant-scope"
---

# Conversation Audit

## Context

- Source transcript: `shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md`
- Audit mode: `default`, latest canonical transcript
- Audit scope: transcript-title fidelity versus dominant conversation scope
- Reviewed at: `2026-06-19 00:00:00 UTC`
- cleaned_input_used: `yes`
- raw_line_count: `3029`
- cleaned_line_count: `1868`

## Redaction / Safety Gate

- Unsafe-content detected by helper: `true`
- Unsafe findings: repeated local absolute paths in the raw transcript
- Evidence redacted for report: exact local path values beyond canonical ShipGlows references
- Block reason: none, private governance storage only

## Findings

| category | severity | title | confidence | evidence | owner | route |
| --- | --- | --- | --- | --- | --- | --- |
| stale_skill_contract | medium | Transcript title no longer reflects the dominant captured scope | high | The stored transcript is titled `Conversation ShipGlows - doctrine de langue`, but the cleaned body is dominated by `sg-spec -> sg-ready -> sg-start -> sg-verify` work for SocialGlowz processor-agnostic LTD commerce, and the current capture script still contains a hard-coded `doctrine de langue` title shortcut before it tries to infer from the prompt. | 100-sg-spec | Harden transcript-title inference so stored ShipGlows conversations prefer the dominant active scope or latest explicit prompt over stale keyword matches in the pane history. |

## Aggregate Signals

- affected categories: `stale_skill_contract`
- most repeated issue: naming fidelity, not execution quality
- owner concentration: `{ "100-sg-spec": 1 }`
- evidence quality: high
- cleaned_input_used: `yes`
- shipglows_core_followup: `run`; local ShipGlows Core skill audit found no hard findings, with one unrelated review note on `skills/101-sg-ready/SKILL.md` body size.

## Current Contract Coverage

The earlier reporting/proof findings for this transcript are already covered by current ShipGlows contracts and previous audits.

What remains uncovered is the transcript naming rule itself: current capture behavior can preserve or re-infer an outdated title that no longer matches the dominant conversation scope, which weakens later retrieval and audit trust.

## Routing

- recommended_action: `create-spec`
- recommended_chantier: `transcript-title-inference-dominant-scope`
- suggested next command: `/100-sg-spec transcript-title-inference-dominant-scope`

## Chantier potentiel

Chantier potentiel: oui
Titre propose: `transcript-title-inference-dominant-scope`
Raison: a private governance transcript should stay findable and semantically trustworthy; stale title inference degrades auditability and future reuse.

## Next Step

- `/100-sg-spec transcript-title-inference-dominant-scope`
