---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-04"
status: reviewed
source_skill: 900-shipglows-core
scope: decision-first-skill-contract-hardening
owner: Diane
user_story: "As the ShipGlows operator, I want skills to derive questions, report verdicts, and technical choices from evidence so historical corrections do not become misleading universal responses."
confidence: high
risk_level: high
security_impact: no
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/reporting-blocked-and-audit.md
  - skills/references/question-contract.md
  - skills/references/intent-to-outcome-autonomy.md
  - skills/references/operator-partnership-contract.md
  - skills/references/preferred-stacks.md
  - skills/105-sg-check/SKILL.md
  - skills/308-sg-status/SKILL.md
  - skills/705-sg-conversation-audit/SKILL.md
  - tools/test_decision_first_skill_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.3.1"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-04: context continuity answers whether carried context is sufficiently reliable for the proposed next task; recap value is a separate question."
  - "Operator correction 2026-09-04: a chantier can close completely while SUITE still identifies the next grounded business improvement."
  - "Operator approval 2026-09-04: start the cross-skill repair after a semantic audit found prefilled verdicts, artificial choice menus, over-constrained questions, and technician-facing prompts."
next_step: Validate the decision-first doctrine against the next real conversation finding that reaches semantic follow-through.
---

# Decision-First Skill Contract Hardening

## Status

Complete — decision-first doctrine, owner adaptations, and focused recurrence proof are implemented.

## Problem

Several contracts preserve the wording of historical corrections as universal output rules. They can make an agent copy a verdict, manufacture a choice, ask the operator for implementation mechanics, or expand a product footprint before the underlying decision has been made.

## Decision

Use `decision predicate -> evidence -> resolved value -> rendering` as the shared instruction shape. Absolute prohibitions remain appropriate for safety, authority, secrets, destructive effects, and capability truth. They are not the primary mechanism for ordinary judgment.

`🧭 SUITE` remains mandatory. A chantier first receives an independent, explicit completion verdict; SUITE then looks beyond that boundary to one grounded business improvement and never reopens the completed chantier by implication.

## Acceptance Criteria

- Reporting examples contain neutral resolved-value placeholders rather than preselected documentation, editorial, changelog, delivery, or context outcomes.
- An unfinished report offers numbered choices only when the operator owns a real decision with distinct consequences; otherwise the agent continues, reports one recovery fact/action, or states the blocker directly.
- Questions are asked only for operator-owned truth or a material unresolved decision. Numeric answers are used when the choices are genuinely enumerable; open product truth may be answered naturally.
- Empty `105-sg-check` invocation derives proportional checks from changed surface, project instructions, lockfiles, and risk rather than asking the operator to select commands.
- Empty `308-sg-status` invocation defaults to issues-only; explicit arguments select broader views. Its implementation guidance is shell-portable and user output contains no internal command routing.
- Preferred stacks remain strong defaults, while supported platform horizon is distinct from launch commitment and omitted platforms are not silently committed.
- Conversation-audit follow-through distinguishes structural validation from semantic proof and resolves the affected owner layer from evidence rather than category alone.
- Focused mechanical proof detects recurrence of these decision-preempting formulations.

## Pressure Scenarios

- `DFS-REPORT-01`: documentation was not changed; the reporting template cannot bias the agent toward `updated`.
- `DFS-CHOICE-01`: one external fact blocks progress; the report states that fact without inventing two alternative business directions.
- `DFS-QUESTION-01`: the operator owns open-ended audience nuance; the question permits a natural answer instead of forcing a false finite set.
- `DFS-CHECK-01`: a localized Python documentation change has an empty check invocation; the agent selects the repository-defined focused checks without asking which commands to run.
- `DFS-STATUS-01`: an empty status invocation immediately renders issues-only and remains read-only.
- `DFS-STACK-01`: a mobile launch request keeps Flutter's broader codebase capability visible without silently promising six launch artifacts.
- `DFS-AUDIT-01`: a conversation exposes a semantic reporting defect while the structure audit is green; follow-through remains open until a targeted semantic scenario is evaluated.

## Implementation Tasks

- [x] Repair shared reporting and question doctrine.
- [x] Repair owner-specific check, status, and conversation-audit contracts.
- [x] Clarify platform capability horizon versus launch footprint.
- [x] Add focused decision-first regression proof.
- [x] Run proportional metadata, contract, structure, graph, budget, and sync checks.

## Verification

- Focused decision/reporting/question/check/status/conversation tests: 111 passed.
- ShipGlows metadata lint: passed for all changed governed artifacts.
- Skill structure audit: 68 skills, no findings.
- Activation graph: valid, 86 edges, no resource cycle.
- Skill budget audit: no hard violations, warnings, or separate risks.
- Full tools suite: 924 tests ran; the chantier-related failures were removed. Six failures remain in untouched legacy contracts and one import error remains because PyYAML is unavailable. These are recorded as independent baseline debt, not hidden as successful proof.
- Runtime link check: source invocation/discovery did not change; expert-only runtime links are absent for the three locally adapted expert skills, so no installation or repair was performed.

## Current Chantier Flow

- 2026-09-04 — Audit completed; systemic failure class identified.
- 2026-09-04 — Operator corrected SUITE semantics and approved the remaining findings.
- 2026-09-04 — Spec created ready for implementation.
- 2026-09-04 — Shared doctrine and three owner skills repaired with decision-first predicates.
- 2026-09-04 — Focused proof passed; global unrelated baseline failures recorded; chantier closed.
