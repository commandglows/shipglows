---
artifact: checklist_instance
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
project_id: "[stable-project-id]"
checklist_id: "[master-checklist-id]"
checklist_version: "[master version]"
cycle_id: "[project-id:checklist:YYYY-MM-DD]"
cycle_kind: "initial | recurring | release | migration | event"
cadence_kind: "daily | weekly | monthly | quarterly | cycle | event"
cadence_anchor: "YYYY-MM-DD or event name"
timezone: "Europe/Paris"
trigger_events: []
next_review: "YYYY-MM-DD"
scope: project-checklist-instance
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: 001-sg-build
owner: "[owner]"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
evidence: []
depends_on: []
supersedes: []
next_step: "[next review or action]"
---

# Checklist instance — [master checklist] — [project name]

## Identity

- Project: `[stable-project-id]`
- Master checklist: `[path to reusable checklist]`
- Master version: `[version]`
- Cycle: `[cycle_id]`
- Cycle kind: `initial | recurring | release | migration | event`
- Cadence: `daily | weekly | monthly | quarterly | cycle | event`
- Cadence anchor: `YYYY-MM-DD` or the event that starts the cycle
- Timezone: `Europe/Paris`
- Trigger events: `-` or a comma-separated list of exceptional triggers
- Started: `YYYY-MM-DD`
- Due or review date: `YYYY-MM-DD`
- Reset policy: `archive this cycle, then create a new instance`

## Progress

- Status: `not_started | in_progress | waiting_for_evidence | verified | blocked | retired`
- Completed controls: `0 / 0`
- Current phase: `[phase]`
- Current blocker: `-`
- Next action: `[next unchecked control]`

## Controls

Copy the ordered controls from the master checklist. Keep their stable IDs unchanged.

| Control ID | Phase | Control | Required | Status | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `[master-control-id]` | `[phase]` | `[control text]` | yes/no | `not_started` | `-` | `-` |

## Cycle Closure

- Completion decision: `open | verified | blocked | incomplete_by_design`
- Verification evidence: `-`
- Closed at: `-`
- Archived instance: `-`
- Next cycle instance: `-`

## Rules

- This file records checklist progress; it is not a task tracker.
- A concrete implementation problem may be referenced in `shipglowz_data/workflow/TASKS.md` without duplicating every control there.
- Archive the completed instance before resetting it.
- Never copy a completed cycle over a new cycle; create a new `cycle_id`.
- Do not place secrets, tokens, cookies, private logs, or unredacted security evidence here.
