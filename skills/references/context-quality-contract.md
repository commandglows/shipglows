---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-30"
status: active
source_skill: 900-shipglows-core
scope: context-quality-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/301-sg-context/SKILL.md
  - skills/101-sg-ready/SKILL.md
  - skills/102-sg-start/references/execution-contract.md
  - skills/103-sg-verify/references/verification-baseline.md
  - skills/references/reporting-agent-handoff.md
  - skills/references/conversation-continuity-contract.md
  - tools/test_context_quality_contract.py
  - tools/context_history.py
  - skills/references/context-history-and-head.md
depends_on:
  - artifact: skills/references/intent-to-outcome-autonomy.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-22: context capsules resolve business, brand, product, outcome, surface, and work item rather than a software-only feature chain."
  - "Operator approval 2026-08-13: context quality is a shared lifecycle requirement and contextual MCP capabilities require a portable native fallback."
  - "Operator approval 2026-08-21: material context drift routes through the shared conversation-continuity and restart-handoff contract."
  - "Operator approval 2026-08-25: a bounded worktree-local Context Head may accelerate resume when derived from immutable significant events and revalidated against canonical truth."
next_review: "2026-09-13"
next_step: "/103-sg-verify context quality contract"
---

# Context Quality Contract

## Purpose

Use the minimum sufficient context for a correct decision, scaled by consequence. This contract qualifies working context; it does not create a new durable truth registry, require exhaustive reading, or make a cache authoritative.

## Context Capsule

Carry one compact `Context Capsule` across routing, readiness, execution, verification, compaction, and explicit agent handoff:

- `target`: `project -> business/brand/product -> outcome -> surface -> work item`;
- `accepted_outcome` (accepted outcome): observable result, stage, scope, invariants, and forbidden outcomes;
- `qualified_truth`: material claims with state, canonical source pointer, relevant version/date, and applicability boundary;
- `constraints`: product, security/data, architecture, design, runtime, external behavior, and proof surfaces that apply;
- `evidence`: inspected files/state, decisions, current official sources, and proof already obtained;
- `gaps`: material unknowns, stale claims, conflicts, proof limits, and their owner/action;
- `next_action`: the next safe decision or execution step.

The capsule is working state and may remain in a spec, mini-contract, or explicit handoff. Do not persist it separately when existing governed artifacts already contain the truth.

For material work in an adopted repository, lifecycle owners obtain or refresh one bounded capsule automatically through `301-sg-context`. Every selected item carries deterministic reason codes plus authority, certainty and freshness. Missing seeds, unsupported relationships and truncation remain explicit gaps. Small exact tasks retain a cheaper targeted retrieval path, and task text is never automatically persisted in graph caches or evaluation telemetry.

## Evidence States

Qualify every material statement as exactly one of:

- `confirmed`: explicitly accepted operator decision within its authority;
- `evidence_backed`: supported by an inspected canonical source or observed state;
- `hypothesis`: useful inference awaiting proof or confirmation;
- `unknown`: materially unresolved;
- `stale`: previously supported but invalidated or outside its freshness boundary;
- `conflict`: applicable authoritative sources disagree.

Preserve state through summaries and handoffs. Never upgrade a hypothesis, unknown, stale claim, or cache preview to confirmed/evidence-backed merely by repetition. A downstream owner may upgrade only with new evidence and must retain its source.

## Authority And Sufficiency

Resolve claims through the applicable owners, normally: canonical project truth; observed repository and runtime state; explicit operator decisions; current official documentation for external behavior; then memory and cache for discovery. Claim type matters: observed code cannot prove product intent, and a stale document cannot override current runtime behavior. A new operator decision that changes canonical truth triggers its owned update rather than silently creating two truths.

Memory and cache never becomes a source of truth. When it contradicts an applicable owner, keep `conflict` visible until the owner is reconciled. Private context stays redacted and follows its storage/retention authority.

Select sources by decision impact, authority, freshness, and risk. File count and token count are ceilings, not evidence of sufficiency. An explicit prototype uses stage-appropriate context; production-only ceremony is not added unless its risk or promised outcome requires it.

## Verdicts

- `context_ready`: target and outcome are resolved; all material claims are sufficiently authoritative and fresh for the next action.
- `context_partial`: bounded exploration or reversible diagnosis may continue, but a named gap blocks any dependent claim or mutation.
- `context_conflict`: applicable authoritative sources disagree; dependent decisions and mutation stop until reconciled.
- `context_stale`: an invalidation signal affects a material claim; revalidate it before dependent work.

An unresolved target blocks dependent mutation. Do not call context ready merely because a retrieval tool returned files.

## Invalidation And Refresh

Re-evaluate the capsule when relevant Git `HEAD`/branch or dirty state, spec/version/status, dependency/lockfile, environment/runtime, confirmed product decision, external source/version, or validation target changes. Revalidate only dependent claims and consumers; do not reload the whole repository. Preserve unaffected claims and their evidence.

When the selected project adopts `skills/references/context-history-and-head.md`, check its worktree-local `CONTEXT_HEAD` before broader reconstruction. A fresh head is a bounded discovery projection, never canonical truth. A stale or missing head is regenerated only with applicable mutation authority; otherwise render the same bounded view without persistence or use the native targeted fallback. Branch, `HEAD`, worktree, staged, unstaged, and untracked fingerprint changes invalidate the cache mechanically.

## Lifecycle Application

- Routing resolves the target/outcome and loads this contract only when sufficiency, authority, freshness, or conflict can change the route.
- Readiness blocks material `unknown`, `stale`, or `conflict` states and requires a capsule sufficient for a fresh agent.
- Execution revalidates invalidated claims before writes and preserves stage, invariants, authority, and proof boundaries.
- Verification compares the accepted capsule with actual implementation and evidence; technically valid work serving the wrong outcome is not verified.
- Explicit agent handoff carries the capsule or an exact pointer plus deltas; compaction preserves evidence states and source pointers.
- When context quality itself may justify ending the active conversation, load `conversation-continuity-contract.md`; length or compaction alone is never sufficient.

## Stop Conditions

Stop or downgrade when the target/outcome is unreliable; a material source is inaccessible, stale, or contradictory; private context would be exposed; available tools cannot establish equivalent evidence; or further reading no longer changes a decision. Ask only for an operator-owned truth that safe inspection cannot establish.
