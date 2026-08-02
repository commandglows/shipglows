---
artifact: project_lifecycle
metadata_schema_version: "1.0"
artifact_version: "0.3.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: 100-sg-spec
scope: project-lifecycle
owner: "[owner]"
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_step: "/101-sg-ready [project] lifecycle"
---

# Project Lifecycle: [Project name]

## Project Identity

- Project ID: `[stable-project-id]`
- Repository: `[absolute or canonical repository path]`
- Lifecycle phase: `discovery | build | launch | operate | paused | retired`
- Product surfaces: `[site, app, API, content, other]`
- Last review: `YYYY-MM-DD`
- Next review: `YYYY-MM-DD`
- Operator timezone: `Europe/Paris`

## Domain Applicability

Declare only domains that apply to this project. An omitted domain is `needs_review`, not complete.

| Domain | Applies | Owner role | Review cadence | Status |
| --- | --- | --- | --- | --- |
| technical | yes/no | `[role]` | `[cadence]` | `not_started` |
| cybersecurity | yes/no | `[role]` | `[cadence]` | `not_started` |
| seo | yes/no | `[role]` | `[cadence]` | `not_started` |
| marketing | yes/no | `[role]` | `[cadence]` | `not_started` |
| copywriting | yes/no | `[role]` | `[cadence]` | `not_started` |
| content | yes/no | `[role]` | `[cadence]` | `not_started` |
| performance | yes/no | `[role]` | `[cadence]` | `not_started` |
| analytics | yes/no | `[role]` | `[cadence]` | `not_started` |
| launch | yes/no | `[role]` | `[cadence]` | `not_started` |
| production | yes/no | `[role]` | `[cadence]` | `not_started` |
| maintenance | yes/no | `[role]` | `[cadence]` | `not_started` |

Cadences use `daily`, `weekly`, `monthly`, `quarterly`, `cycle` or `event`. A
cadence change applies only to future instances; historical cycles remain
unchanged. Optional event triggers are declared per domain.

## Linked Definitions

| Item ID | Type | Domain | Title | Playbook | Checklist | Required |
| --- | --- | --- | --- | --- | --- | --- |
| `[stable-item-id]` | `one_time` | `[domain]` | `[title]` | `[path]` | `[path]` | yes/no |

## Checklist Instances

Progress for an ordered domain checklist belongs in a project checklist instance, not in `TASKS.md`. Create one instance per cycle and preserve completed instances as history.

| Checklist ID | Master Version | Instance Path | Cycle ID | Cadence | Next Review | Status | Progress | Current Phase | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `seo-technical` | `1.1.0` | `shipglows_data/workflow/checklist-instances/seo-technical-YYYY-MM-DD.md` | `[project:checklist:period]` | `monthly` | `YYYY-MM-DD` | `not_started` | `0/0` | `[phase]` | `[next unchecked control]` |

## Lifecycle Items

This table is the canonical project-local source consumed by readers and app adapters. Keep one row per active definition or dated instance. Use ISO-8601 timestamps for `Due At`; separate recurring instances remain historical records.

| Item ID | Instance ID | Type | Domain | Title | Required | State | Due At | Cadence | Timezone | Evidence | Tracker Route | Next Action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `[stable-item-id]` | `[project:item:period]` | `one_time` | `[domain]` | `[title]` | yes/no | `not_started` | `YYYY-MM-DDTHH:MM:SS+00:00` | `-` | `UTC` | `-` | `technical_task` | `[next action]` |

## Current Projection

This section is derived by a reader or app adapter. It is not a replacement for the source definitions or trackers.

- Today: `[derived items]`
- This week: `[derived items]`
- Next week: `[derived items]`
- Overdue: `[derived items]`
- Blocked: `[derived items]`
- Next review: `[date and reason]`
- Domain progress: `[reader-generated cards for every applicable domain]`
- Missing masters: `[applicable domains whose reusable master is not yet defined]`
- Overall readiness: `[ready / needs_review / blocked / not_applicable]`

## Routing Rules

- Technical implementation follow-up goes to `shipglows_data/workflow/TASKS.md`.
- Public/editorial follow-up goes to `shipglows_data/editorial/ROADMAP.md`.
- Spec-first multi-file work goes to `shipglows_data/workflow/specs/`.
- Concrete manual/provider/device proof goes to `shipglows_data/workflow/test-checklists/`.

## Maintenance Rules

- Keep stable IDs unchanged when titles or translations change.
- Do not mark recurring definitions complete; close only their dated instances.
- Preserve historical instances when cadence or applicability changes.
- Record evidence pointers without secrets, tokens, cookies, or raw private logs.
