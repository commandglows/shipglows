---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-21"
status: active
source_skill: 900-shipglows-core
scope: conversation-continuity-and-restart-handoff
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/context-quality-contract.md
  - skills/references/reporting-agent-handoff.md
  - skills/references/reporting-contract.md
  - skills/references/reporting-pressure-scenarios.md
  - shipglows_data/workflow/TASKS.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: conversation boundaries follow outcome coherence and context reliability, not an arbitrary message count."
  - "Operator clarification 2026-08-21: Codex cannot restart its active conversation; only the operator can start a fresh one."
  - "Operator approval 2026-08-21: a restart recommendation follows stabilization and includes a self-contained copyable prompt."
next_review: "2026-11-21"
next_step: Review this contract against observed restart handoffs after three uses.
---

# Conversation Continuity Contract

## Purpose

Keep one principal outcome coherent for as long as the current conversation remains a reliable workspace, then provide a safe operator-started handoff when a fresh conversation will improve reliability. Conversation length alone, elapsed time, message count, or compaction never forces a restart.

## Continue Or Recommend Restart

Continue the current conversation when its principal outcome, target, accepted decisions, repository, authority, and proof path remain coherent. Compaction is a context-management mechanism, not evidence that the conversation has failed.

Recommend a new conversation when at least one material signal is evidence-backed:

- a new independent outcome has become primary and no unfinished work from the current outcome should be mixed into it;
- mixed targets or mixed products make ownership unreliable;
- contradictory decisions cannot be safely reconciled inside the active context;
- repeated reconstruction is needed to recover already-established scope or decisions;
- a stale source is repeatedly treated as current despite revalidation;
- repository confusion, branch confusion, or cross-project leakage creates a material risk;
- the agent repeats resolved questions, loses constraints, or cannot produce a trustworthy `Context Capsule` from governed sources.

Before recommending restart, attempt one bounded context refresh from canonical sources. If that restores a reliable capsule without material conflict, continue instead. Do not use restart as a shortcut around ordinary verification, documentation, delivery, or a difficult unresolved task.

## Stabilization Gate

Codex cannot restart, close, reset, or replace its own active conversation. Only the operator starts a new conversation. Before advising that action:

1. Finish safe work already authorized and agent-runnable when possible.
2. Apply the Git delivery contract to intentional mutations: commit and push each validated milestone and the clean chantier closure.
3. Persist decisions, current state, proof, blockers, and unresolved work in the existing durable spec, tracker, audit, bug, or documentation owners; do not create a duplicate memory registry.
4. If work cannot be secured or completed, label it incomplete and state the exact recovery condition. Never describe an uncommitted, local-only, failed-push, contradictory, or unknown state as a clean handoff.
5. Re-read the durable sources and current Git state used by the handoff so the prompt does not preserve stale conversational memory.

The recommendation is advisory and grants no authority for a new chantier, external write, destructive action, or scope expansion.

## Copyable Restart Prompt

Produce one concise, self-contained copyable restart prompt in the operator's active language. A fresh capable agent must be able to begin without reading the old transcript. Include:

- exact `target` and current work item;
- the accepted outcome and relevant scope boundaries;
- canonical source pointers, including the owning spec or tracker record;
- last delivered commit and branch when Git applies;
- material evidence states and proof already obtained;
- unresolved work, blockers, and authority boundaries;
- the first verification action before any new mutation;
- the one concrete next outcome selected by the shared continuity ladder.

The prompt must not contain secrets, cookies, tokens, credentials, personal data, private logs, raw provider payloads, hidden reasoning, speculative memory presented as truth, or unnecessary transcript excerpts. Use redacted source pointers instead of sensitive content.

## User-Facing Shape

State plainly that the operator must open a new conversation. Then provide the prompt in one fenced text block. Do not claim that a button was pressed, a conversation was created, or a runtime was restarted unless the platform provides explicit observed evidence of that external action.

## Pressure Scenarios

- `CCR-001 LENGTH-ONLY`: long and coherent continues, even after compaction.
- `CCR-002 DELIVERED-BOUNDARY`: a delivered outcome followed by an independent outcome receives a fresh-conversation recommendation.
- `CCR-003 CONTEXT-DRIFT`: mixed targets, contradiction, reconstruction, stale truth, or repository confusion triggers refresh then handoff if unresolved.
- `CCR-004 UNSAFE-ABANDONMENT`: unsecured mutations or missing durable state block clean-handoff language.
- `CCR-005 CAPABILITY-TRUTH`: only the operator starts the new conversation; Codex never claims self-restart.
- `CCR-006 RESUMABLE-PROMPT`: a fresh agent can act from the prompt and governed sources alone.
- `CCR-007 REDACTION`: sensitive or hidden context never enters the prompt.
- `CCR-008 OPERATOR-CONTROL`: recommendation creates no new authority or external side effect.
