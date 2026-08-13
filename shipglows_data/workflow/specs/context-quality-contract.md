---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-13"
created_at: "2026-08-13 16:55:00 UTC"
updated: "2026-08-13"
updated_at: "2026-08-13 17:42:36 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: context-quality-contract
owner: Diane
confidence: high
user_story: "As a ShipGlows operator, I want every skill to decide from sufficient, authoritative, fresh, and transferable context so excellent execution solves the right problem."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/context-quality-contract.md
  - skills/301-sg-context/SKILL.md
  - skills/101-sg-ready/SKILL.md
  - skills/102-sg-start/references/execution-contract.md
  - skills/103-sg-verify/references/verification-baseline.md
  - skills/references/reporting-agent-handoff.md
  - tools/test_context_quality_contract.py
depends_on:
  - artifact: skills/references/intent-to-outcome-autonomy.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval 2026-08-13: context quality should become a shared lifecycle contract with portable fallback when contextual MCP tools are unavailable."
next_step: "/005-sg-ship context quality contract"
---

# Title

Context quality contract

# Status

Reviewed.

# Minimal Behavior Contract

Every material decision uses the minimum sufficient context for its risk, qualifies evidence by authority/freshness/certainty, preserves one compact capsule across handoffs, and revalidates only invalidated claims. Memory accelerates discovery but never overrides canonical truth.

# Success Behavior

- Context resolves `project -> product -> surface -> feature`, accepted outcome, invariants, sources, constraints, evidence, gaps, and next action.
- Material statements retain one of `confirmed`, `evidence_backed`, `hypothesis`, `unknown`, `stale`, or `conflict`.
- Readiness, execution, verification, and handoff consume the same context capsule without silently upgrading certainty.
- `301-sg-context` uses contextual MCP tools only when callable and otherwise performs an equivalent focused native fallback.
- Repository/runtime changes invalidate only dependent claims and trigger targeted revalidation.

# Error Behavior

Wrong target, stale or conflicting material truth, memory promoted above canonical sources, lost certainty during handoff, unavailable-tool assumptions, or exhaustive context loading block a clean `context_ready` verdict.

# Scope In

- shared doctrine and capsule vocabulary
- conditional integration at routing, readiness, execution, verification, and agent handoff
- portable `301-sg-context` behavior
- scenario-first tests, docs, refresh, budgets, graph, and runtime proof

# Scope Out

- This is not a new durable truth registry.
- a new public skill or command
- mandatory persistence of ephemeral capsules
- installation or startup of the codebase MCP
- exhaustive repository indexing

# Acceptance Criteria

- [x] Context verdicts and evidence states are mechanically defined.
- [x] Source precedence and invalidation rules fail closed without making caches authoritative.
- [x] Five lifecycle boundaries consume the shared contract proportionally.
- [x] `301-sg-context` has truthful MCP and native fallback paths.
- [x] Focused/full tests, metadata, graph, audit, budget, diff, and public runtime checks pass.

# Implementation Tasks

- [x] Define pressure scenarios and failing contract tests.
- [x] Add shared context doctrine and lifecycle integrations.
- [x] Repair `301-sg-context` runtime portability.
- [x] Update technical documentation and refresh trace.
- [x] Verify and close.

# Pressure Scenarios

- `CONTEXT-001 RELEVANCE`: abundant context is ranked; only decision-changing sources are loaded.
- `CONTEXT-002 AUTHORITY`: cache contradicts canonical project/runtime truth; canonical truth wins and conflict stays visible.
- `CONTEXT-003 STALE`: an invalidation signal triggers targeted revalidation rather than full reload.
- `CONTEXT-004 HANDOFF`: target, outcome, invariants, evidence states, proof, and gaps survive owner transfer.
- `CONTEXT-005 COMPACTION`: confirmed facts do not become hypotheses and hypotheses do not become facts.
- `CONTEXT-006 MCP-ABSENT`: native fallback reaches an honest verdict without inventing contextual tool availability.
- `CONTEXT-007 WRONG-TARGET`: unresolved project/product/surface/feature blocks dependent mutation.
- `CONTEXT-008 STAGE-FIT`: an explicit prototype gets stage-appropriate context, not production ceremony.
- `CONTEXT-009 OUTCOME-MISMATCH`: verification rejects technically valid work that answers the wrong accepted outcome.

# Risks

The primary risk is turning useful context discipline into eager reading or a parallel memory system. Activation remains conditional; durable truth remains in existing owners; the capsule carries pointers and qualified working state.

# Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-08-13 16:55:00 | 100-sg-spec | create | Defined capsule, verdicts, source authority, invalidation, lifecycle integrations, portable fallback, and pressure scenarios. |
| 2026-08-13 16:55:00 | 101-sg-ready | review | Ready: target, success/error behavior, scope, interfaces, fallback, proof, and non-registry boundary are explicit. |
| 2026-08-13 17:42:36 | 102-sg-start | implement | Added the shared doctrine, lifecycle loaders, portable 301 behavior, activation gate, documentation, and tests. |
| 2026-08-13 17:42:36 | 900-shipglows-core | refresh | Independent review repaired partial-context mutation, versioned dependency, report heading, and negative-test gaps; final verdict approved. |
| 2026-08-13 17:42:36 | 103-sg-verify | verify | Focused/full tests, metadata, graphs, audit, activation/discovery budgets, diff, and public runtime checks passed. |
| 2026-08-13 17:42:36 | 104-sg-end | close | Closed as reviewed; commit and push remain the ship gate. |

# Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 900 refresh -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (next)`
