---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-21"
status: active
source_skill: 011-sg-pilotage
scope: pilotage-priorities-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/011-sg-pilotage/SKILL.md
  - shipglows_data/workflow/TASKS.md
  - skills/references/next-outcome-selection.md
depends_on:
  - artifact: skills/references/operational-record-format.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Transferred from 702-sg-priorities under the approved pilotage consolidation."
  - "Operator correction 2026-08-21: the mandatory SUITE uses tracker priority only after current conversation, proof, delivery, and active-chantier continuity are resolved."
next_step: "$011-sg-pilotage priorities"
---

# Priorities Mode Playbook

## Outcome

Rank credible active tasks by impact, effort, blockers, dependencies, and risk, then recommend the next execution target. This mode does not capture vague ideas, perform retrospective review, or execute the selected work.

## Inputs And Grammar

Use `shipglows_data/workflow/TASKS.md` as the project source of truth; root `TASKS.md` is a legacy fallback only. A portfolio view is derived from project-local trackers and does not recreate a central master dashboard.

- `priorities impact` emphasizes customer/business value.
- `priorities effort` uses bounded effort only as a tie-breaker after strategic value and risk.
- `priorities blockers` emphasizes work that unlocks credible dependent tasks.
- `priorities high-roi` or `priorities quick-wins` favors high impact with bounded effort without lowering correctness or durability.
- bare `priorities` applies the balanced model.

If task state is too vague or stale to score credibly, route to `tasks` for reconciliation or `700-sg-explore` for problem framing before ranking.

At a workspace root or when several projects are credible targets, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and ask for the project or explicit portfolio scope. A portfolio ranking remains a derived view; it does not mutate a central dashboard.

## Ranking Model

For every active candidate, state:

- impact: user, business, product, or operational value;
- effort: realistic delivery cost, not convenience for the agent;
- blockers: whether it unblocks other confirmed work;
- dependencies: prerequisites that determine valid ordering;
- risk: security, reliability, trust, release, or opportunity cost of delay.

Use `P0` for a true blocker, incident, security/data risk, or urgent high-impact bounded work; `P1` for important high-impact work; `P2` for meaningful but non-blocking work or high effort without urgency; and `P3` for low-value optional work. Do not inflate urgency to produce a decisive answer.

## Tracker Write Protocol

Load `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before changing task records. Treat the initial tracker as informational, authoritatively re-read immediately before a bounded priority-field or section patch, preserve unknown fields, and verify the result. If the anchor moved, re-read once and recompute; if it stays ambiguous, keep the ranking in the report and write nothing.

When the tracker is mutated, record the prioritization criteria and current date without converting canonical traffic-first records into a legacy checklist/table format.

## Execution Boundary

Return the ranked active set, the chosen next target, reasoning, dependencies, and evidence gaps. Route an already-active current chantier to `706-continue`; route a new ready implementation to `102-sg-start`. The priorities mode does not execute, verify, close, commit, or push the target.

When priorities feed a chantier report's mandatory `🧭 SUITE`, apply `skills/references/next-outcome-selection.md`. Current conversational work, pending proof or delivery, and active chantiers outrank the tracker. Within the tracker, preserve `P0 -> P1 -> P2 -> P3`; if no actionable task remains, fall through to audit freshness rather than returning no next action.
