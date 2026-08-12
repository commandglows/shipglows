---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 203-sg-research
scope: research-execution-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/203-sg-research/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-5 independent audit restored mandatory persistence and encoding integrity."
next_step: none
---

# Research Execution Playbook

Run this playbook only for bounded, owner-scoped research.

## Phase 1 — Source Intake

- Clarify topic, scope, geography, audience, and claim horizon.
- For technical or product decisions, require official or primary sources.
- Separate current/dated sources from historical ones.

## Phase 2 — Capture and classify

- Keep a short source ledger with:
  - source type (primary/secondary/official),
  - date,
  - relevance score,
  - claim coverage.
- For each source, keep one sentence of what it supports.
- Mark contradictory sources explicitly and preserve both lines of evidence.

## Phase 3 — Synthesis

- Compare approaches by the same objective function.
- Call out trade-offs and constraints before recommendation.
- Keep implementation claims separate from market/strategy claims.
- If no source supports a conclusion, return an uncertainty-based recommendation.

## Phase 4 — Output safety

- Route all factual claims to explicit evidence bullets.
- Add confidence and limits (`high|medium|low`).
- Never overclaim freshness or adoption.
- If a claim is for public content, add explicit editorial handoff.

## Phase 5 — Persist

- Every valid research run must save its report. Use:
  - `shipglows_data/workflow/research/<topic-slug>.md` for project-scoped research;
  - `$SHIPGLOWS_ROOT/shipglows_data/workflow/research/<topic-slug>.md` for ShipGlows-wide or portfolio research.
- Save only with:
  - clear slug,
  - source count,
  - evidence list,
  - explicit recommendation.
- Never write random scratch files for the final output.
- If persistence fails, report `blocked` with a recoverable synthesis; never claim completion.
