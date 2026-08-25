---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-24"
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
  - "Operator correction 2026-08-21: useful context becoming insufficiently reliable is the trigger; an independent outcome alone is never sufficient."
  - "Operator approval 2026-08-22: context health checks stay lightweight at transitions and refresh only affected sources when a degradation signal exists."
  - "Operator approval 2026-08-24: the active contract was reduced from 1,055 to 706 words while preserving behavior and CCR-001 through CCR-009."
next_review: "2026-11-21"
next_step: Review this contract against observed restart handoffs after three uses.
---

# Conversation Continuity Contract

## Purpose

Continue the current conversation while useful context remains reliable. Recommend an operator-started handoff only after evidenced degradation survives a targeted refresh. Conversation length alone, elapsed time, message count, compaction, or an independent outcome alone is never sufficient.

## Decision Sequence

Run a lightweight transition check at the end of a chantier, after compaction, or on a major subject change. Silently inspect carried outcome, target, durable owner, repository, accepted decisions, authority, and next action. It requires no full conversation reread and does not trigger a handoff.

Use a signal-driven refresh of only the affected sources when one material signal appears:

- mixed targets or mixed products make ownership unreliable;
- contradictory decisions remain unresolved;
- repeated reconstruction is needed for settled scope;
- a stale source is treated as current;
- repository confusion, branch confusion, or cross-project leakage appears;
- resolved questions repeat, constraints disappear, or no trustworthy `Context Capsule` can be produced.

A new subject may prompt this cheap check but never a handoff by itself. If targeted rereading restores reliable useful context, continue. Recommend a handoff only when material unreliability remains. Never use restart to avoid difficult work, verification, documentation, or delivery.

## Stabilization Gate

Codex cannot restart, close, reset, or replace its active conversation; only the operator starts a new one. Before recommending that action:

1. Finish safe authorized work when possible.
2. For intentional Git mutations, commit and push validated milestones and closure.
3. Persist decisions, proof, blockers, and unresolved work in their existing durable spec, tracker, audit, bug, or documentation owners.
4. Mark work incomplete with its recovery condition when it cannot be secured; never call local-only, failed-push, conflicting, or unknown state a clean handoff.
5. Recheck the durable sources and current Git state used below.

This advisory recommendation grants no new chantier, mutation, or external-action authority.

## Handoff

Provide one concise, self-contained copyable restart prompt in the operator's language. Call it a `handoff`: a complete passage-of-relay message without sensitive data. A fresh agent must not need the old transcript. Include:

- target and work item;
- accepted outcome and scope;
- canonical source pointers;
- branch and last delivered commit when applicable;
- material evidence states and proof;
- constraints, blockers, authority boundaries, and unresolved work;
- first verification action and one concrete next outcome.

Exclude secrets, cookies, tokens, credentials, personal data, private logs, raw payloads, hidden reasoning, unnecessary transcript excerpts, and speculative memory presented as truth. Prefer redacted source pointers.

Tell the operator to open the new conversation, then show the handoff in one fenced text block. Never claim that Codex created, closed, or restarted it without observed platform evidence.

## Pressure Scenarios

- `CCR-001 LENGTH-ONLY`: long, coherent context continues.
- `CCR-002 INDEPENDENT-OUTCOME`: a new outcome alone never triggers handoff.
- `CCR-003 CONTEXT-DRIFT`: evidenced drift triggers targeted refresh, then handoff only if unresolved.
- `CCR-004 UNSAFE-ABANDONMENT`: unsecured or undocumented work blocks clean-handoff language.
- `CCR-005 CAPABILITY-TRUTH`: the operator starts the new conversation; Codex never claims self-restart.
- `CCR-006 RESUMABLE-PROMPT`: governed sources plus the prompt suffice for a fresh agent.
- `CCR-007 REDACTION`: sensitive or hidden context stays excluded.
- `CCR-008 OPERATOR-CONTROL`: recommendation creates no authority or external effect.
- `CCR-009 PROPORTIONAL-CHECK`: transitions get a carried-state check; only evidenced drift permits affected-source refresh.
