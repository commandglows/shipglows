---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-30"
updated: "2026-08-30"
status: ready
source_skill: 900-shipglows-core
scope: workflow
owner: Diane
user_story: "As a ShipGlows operator, I want every managed repository closure to classify changelog impact and retain significant context safely, so public progress is visible without exposing internal work."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
  - skills/references/reporting-pressure-scenarios.md
  - skills/references/context-history-and-head.md
  - skills/104-sg-end/SKILL.md
  - skills/104-sg-end/references/closure-bookkeeping-playbook.md
  - tools/test_reporting_contract.py
  - tools/test_context_history_contract.py
depends_on: []
supersedes: []
evidence:
  - "Operator approval on 2026-08-30 requires the closure changelog classification for every ShipGlows-managed repository rather than one application repository."
next_step: none
---

# Spec: Global Closure Changelog And Context History

## Status

ready

## Behavior Contract

Every successful ShipGlows closure report includes one compact `📰 CHANGELOG` classification after editorial impact and before delivery. The classification is one of `public-ready`, `internal-only`, `not applicable`, or `needs review`. It describes eligibility, never invents publication proof, and applies through the shared runtime to every managed repository.

When structured history is adopted, closure records at most one significant event. Public data remains allowlisted, bilingual, and evidence-backed; raw internal history never becomes public. A repository without a declared public changelog surface still receives an honest classification and may retain an internal event.

## Scope

- Shared closure reporting contract and pressure scenarios.
- `104-sg-end` activation and bookkeeping contract.
- Context-history classification and focused contract tests.
- No mass edit of managed repositories and no deployment of project changelog pages.

## Proof Path

Scenario-first: focused reporting and context-history contract tests, followed by metadata and skill-budget checks. `ZOMBIES coverage`: no event or public surface yields `not applicable`; one meaningful internal event yields `internal-only`; a complete bilingual allowlisted event yields `public-ready`; missing classification or unsafe/ambiguous copy yields `needs review`; multiple events are reduced to at most one significant closure event; public eligibility never implies deployed publication.

## Current Chantier Flow

| Skill | Status |
|-------|--------|
| 100-sg-spec | ready |
| 101-sg-ready | ready |
| 900-shipglows-core | implemented |
| 103-sg-verify | verified |
| 104-sg-end | closed |
| 005-sg-ship | shipped |

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-30 | 900-shipglows-core | GPT-5 Codex | Opened the approved global closure changelog and Context History integration. | in progress | focused contract implementation and proof |
| 2026-08-30 | 900-shipglows-core | GPT-5 Codex | Integrated Context History into the canonical runtime and added the global six-block closure contract. | implemented | 103-sg-verify focused checks |
| 2026-08-30 | 103-sg-verify | GPT-5 Codex | Verified reporting, history behavior, metadata, skill budget, runtime links, and scoped diff hygiene. | verified | 104-sg-end closure and 005-sg-ship delivery |
| 2026-08-30 | 104-sg-end | GPT-5 Codex | Closed the global runtime contract with one public-ready changelog classification and one significant delivery event. | closed | 005-sg-ship final bookkeeping delivery |
| 2026-08-30 | 005-sg-ship | GPT-5 Codex | Pushed the Context History and global closure contract commits to the canonical development branch. | shipped | none |
