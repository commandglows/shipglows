---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: ready
source_skill: 900-shipglows-core
scope: conversation-closure-and-restart-handoff
owner: Diane
user_story: "As a ShipGlows operator, I want Codex to recognize when a conversation is no longer a reliable workspace, secure the current work, and give me a self-contained restart prompt, without pretending it can restart itself."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/context-quality-contract.md
  - skills/references/reporting-agent-handoff.md
  - skills/references/reporting-contract.md
  - skills/references/reporting-pressure-scenarios.md
  - tools/test_context_quality_contract.py
  - tools/test_reporting_contract.py
  - shipglows_data/workflow/TASKS.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.0.1"
    required_status: active
  - artifact: skills/references/reporting-contract.md
    artifact_version: "2.11.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: one conversation should retain one principal outcome and should end when that outcome is delivered or an independent outcome takes priority."
  - "Operator clarification 2026-08-21: Codex cannot restart its own active conversation; it must recommend a user-started new conversation truthfully."
  - "Operator approval 2026-08-21: before recommending restart, secure authorized work, persist durable state, and generate a self-contained continuation prompt."
next_step: Add scenario-first proof, then implement the bounded shared conversation-closure contract.
---

# Conversation Closure And Restart Handoff

## Status

ready

## Acceptance Criteria

- Conversation length alone never forces a restart; quality signals and outcome boundaries control the recommendation.
- Continue while one principal outcome remains coherent and the active context is reliable enough to finish it safely.
- Recommend a new conversation when an independent outcome becomes primary or context reliability materially degrades through mixed targets, contradictory decisions, repeated reconstruction, stale source use, or repository confusion.
- Codex never claims it can close, restart, reset, or replace its own active conversation.
- Before recommending restart, finish safe authorized work when possible; otherwise record the exact incomplete state, blockers, decisions, proofs, and next outcome in governed sources.
- Any intentional Git mutation is committed and pushed under the existing delivery contract before a clean handoff claim.
- The handoff contains one self-contained copyable restart prompt with target, accepted outcome, durable source pointers, last delivered commit when applicable, evidence state, unresolved work, constraints, and first verification action.
- Secrets, private payloads, transient reasoning, and unnecessary conversation transcript content never enter the restart prompt.
- The recommendation remains advisory: only the operator starts the new conversation.

## Pressure Scenarios

- `CCR-001 length-only`: a long but coherent, correctly grounded chantier continues; no restart is recommended merely because compaction occurred.
- `CCR-002 delivered-boundary`: a fully delivered principal outcome plus a new independent goal triggers a clean new-conversation recommendation.
- `CCR-003 context-drift`: mixed repositories, contradictory decisions, repeated already-answered questions, or stale-source reliance triggers stabilization and restart handoff.
- `CCR-004 unsafe-abandonment`: uncommitted or undocumented authorized work forbids a clean restart recommendation until secured or explicitly reported incomplete.
- `CCR-005 capability-truth`: Codex says the operator must open the new conversation and never claims self-restart capability.
- `CCR-006 resumable-prompt`: a fresh agent can identify the target, outcome, source of truth, last delivery, constraints, remaining work, and first check without reading the old transcript.
- `CCR-007 redaction`: restart prompts exclude secrets, cookies, tokens, private logs, raw payloads, and hidden reasoning.
- `CCR-008 operator-control`: recommending a restart does not open, close, or mutate another conversation and does not authorize a new chantier.

## Implementation Tasks

- [x] Record the approved outcome, boundaries, and pressure scenarios.
- [ ] Add focused mechanical checks before changing shared doctrine.
- [ ] Define the conversation continuity and restart-recommendation decision rule.
- [ ] Define the stabilization checklist and copyable restart-prompt contract.
- [ ] Connect reporting and explicit agent handoff to the shared rule.
- [ ] Update tracker state without rewriting operational history.
- [ ] Verify metadata, topology, focused scenarios, and diff hygiene.
- [ ] Commit and push the implementation and closure milestones.

## Current Chantier Flow

`operator decision ✅ -> capability clarification ✅ -> approval ✅ -> spec ready ✅ -> scenario-first proof -> doctrine -> verification -> commit/push`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-21 | 900-shipglows-core | ready | The operator approved a lightweight conversation-end and restart-handoff contract after confirming that Codex cannot restart its own conversation. | add focused scenarios before doctrine edits |
