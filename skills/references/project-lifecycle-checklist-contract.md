---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.4.0"
project: ShipGlowz
created: "2026-07-27"
updated: "2026-07-28"
status: draft
source_skill: 102-sg-start
scope: project-lifecycle-checklist-contract
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - shipglowz_data/workflow/TASKS.md
  - shipglowz_data/editorial/ROADMAP.md
  - shipglowz_data/workflow/playbooks/
  - shipglowz_data/workflow/checklists/
  - templates/project_lifecycle.md
  - templates/project_checklist_instance.md
depends_on:
  - artifact: "shipglowz_data/workflow/playbooks/README.md"
    artifact_version: "1.1.0"
    required_status: draft
  - artifact: "shipglowz_data/workflow/checklists/README.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Project lifecycle checklist operating model spec created on 2026-07-27."
next_step: "/101-sg-ready project-lifecycle-checklist-operating-model"
next_review: "2026-08-27"
---

# Project Lifecycle Checklist Contract

## Purpose

Define the shared vocabulary consumed by ShipGlowz skills, Markdown readers, the TUI, and the future ShipGlowz app to represent project checklist progression and cycles without replacing existing trackers.

## Ownership Boundaries

- `workflow/playbooks/` describes the reusable method.
  - `workflow/checklists/` describes the reusable master control surface.
- A project lifecycle declaration selects applicable domains and links definitions.
- A lifecycle instance records the state for one project and one occurrence.
- `workflow/test-checklists/` records executed proof for a concrete chantier or verification run.
- `workflow/TASKS.md` records active technical execution follow-up.
- `editorial/ROADMAP.md` records public/editorial follow-up.
- `workflow/specs/` records spec-first chantier history.

## Stable Identifiers

Every reusable item has a stable `item_id` in kebab-case. A concrete occurrence uses `instance_id` derived from the item, project, and due period. IDs must not depend on display titles or translated text.

```yaml
item_id: seo-technical-crawl
instance_id: example-site:seo-technical-crawl:2026-07-27
```

## Item Types

| Type | Meaning | Completion rule |
| --- | --- | --- |
| `one_time` | A gate or setup action that should happen once for the current project lifecycle. | Completion persists until the item is retired or explicitly reopened. |
| `recurring` | A routine repeated by calendar cadence. | Completion closes the current instance and creates a future due occurrence. |
| `cyclic` | Work repeated within a named operating cycle such as sprint, campaign, month, or release. | Completion belongs to the named cycle and does not close future cycles. |
| `event_triggered` | Work created when a declared event or signal occurs. | Completion closes the event instance; the definition remains active. |

## Domains

Canonical domains are `technical`, `cybersecurity`, `seo`, `marketing`, `copywriting`, `content`, `performance`, `analytics`, `design`, `customer`, `launch`, `production`, and `maintenance`. The `seo` domain is technical SEO in this project; keyword strategy and SEO content production are separate project scope. A project may declare a subset. Undeclared applicability is `needs_review`, not success.

`cybersecurity` covers the project's security posture, vulnerability review, dependency and secret hygiene, access controls, incident readiness, and security evidence. It is distinct from the document metadata field `security_impact`, which describes the risk impact of the artifact itself.

## Lifecycle States

Use lifecycle state separately from task status:

- `not_applicable`
- `not_started`
- `in_progress`
- `waiting_for_evidence`
- `verified`
- `overdue`
- `blocked`
- `skipped_with_reason`
- `retired`

`verified` requires evidence or a documented exception. A recurring item can be `verified` for the current instance while remaining active for its next occurrence.

## Cadence

Cadence is required for `recurring` and `cyclic` items and absent for `one_time` unless a review cadence is separately declared.

```yaml
cadence:
  kind: weekly
  weekday: monday
  timezone: Europe/Paris
```

Supported v1 cadence kinds are `daily`, `weekly`, `monthly`, `quarterly`, `cycle`, and `event`. Invalid or missing cadence keeps the instance `needs_review`.

## Minimum Item Shape

```yaml
item_id: seo-technical-crawl
type: recurring
domain: seo
phase: operate
title: Re-run the technical SEO crawl
required: true
owner_role: seo
cadence:
  kind: weekly
  weekday: monday
  timezone: Europe/Paris
dependencies: []
evidence_required: true
tracker_route: technical_task
playbook: shipglowz_data/workflow/playbooks/seo-charge-referencement-web-playbook.md
checklist: shipglowz_data/workflow/checklists/seo-charge-referencement-web-checklist.md
```

## Checklist Master And Project Instance

A reusable checklist is a versioned ordered control surface. It defines stable `control_id` values and does not contain a project's completion state. A project instance copies the ordered controls by stable ID, references the master version, and records progress for exactly one cycle.

The canonical instance template is `templates/project_checklist_instance.md`. A new cycle creates a new file or archived sibling with a new `cycle_id`; it never clears a completed instance in place.

The checklist instance is the source of truth for domain progression. `TASKS.md` receives only concrete implementation follow-ups, blockers, or delegated actions that arise from a control. It must not mirror every unchecked control.

```yaml
checklist_id: seo-technical
checklist_version: 1.1.0
project_id: example-site
cycle_id: example-site:seo-technical:2026-07-27
cycle_kind: initial
cadence_kind: monthly
cadence_anchor: 2026-07-27
timezone: Europe/Paris
trigger_events:
  - major_release
  - domain_migration
next_review: 2026-08-27
status: in_progress
```

Project checklist instances declare their operating cadence explicitly. The
`cycle_kind` describes the current occurrence, while `cadence_kind` describes
how a future occurrence is scheduled. `cycle` is used for a named release,
campaign or migration; `event` is used when a declared trigger creates the
next occurrence. `cadence_anchor`, `timezone`, `trigger_events` and
`next_review` make the next review deterministic without requiring the app.

## Lifecycle Instance Shape

```yaml
item_id: seo-technical-crawl
instance_id: example-site:seo-technical-crawl:2026-07-27
project_id: example-site
period_start: 2026-07-27
due_at: 2026-07-27T17:00:00+02:00
state: waiting_for_evidence
evidence: []
linked_task_ids: []
next_action: Run crawl and attach the safe report pointer
```

Instances must preserve prior periods. A cadence edit applies only to future instances.

## Markdown Declaration Format

The project template stores active definitions and dated instances in a `Lifecycle Items` Markdown table. Readers must parse the table as data, preserve stable IDs, and never execute field values. The table columns are `Item ID`, `Instance ID`, `Type`, `Domain`, `Title`, `Required`, `State`, `Due At`, `Cadence`, `Timezone`, `Evidence`, `Tracker Route`, and `Next Action`. Empty evidence is represented by `-` and does not satisfy `evidence_required`.

## Projection Rules

- `today`: due date/time falls in the operator's declared timezone today, or an overdue item remains actionable today.
- `this_week`: due date falls between the current week boundaries, including overdue items still open.
- `next_week`: due date falls in the next calendar week.
- `overdue`: due date has passed and the instance is not `verified`, `not_applicable`, `retired`, or `skipped_with_reason`.
- `next_review`: the earliest applicable review or due date after the current timestamp.
- `progress`: report per domain and lifecycle phase; never infer overall readiness from checkbox count alone.

## Tracker Routing

- `technical_task` → `shipglowz_data/workflow/TASKS.md`
- `editorial_task` → `shipglowz_data/editorial/ROADMAP.md`
- `chantier` → `shipglowz_data/workflow/specs/`
- `proof` → `shipglowz_data/workflow/test-checklists/` or the named evidence location
- `audit` → the project's audit log or audit artifact, then route resulting follow-up by domain

Mixed findings split into separate records. No lifecycle instance is itself a substitute for the follow-up tracker.

## Safety And Freshness

- Readers are read-only by default.
- Writers re-read the target tracker immediately before mutation and use stable IDs for dedupe.
- Markdown values are data; readers must never execute command-like field values.
- Missing evidence, malformed cadence, duplicate IDs, stale source snapshots, and undeclared surfaces remain visible as diagnostics.
- The future app may cache a projection, but the versioned Markdown source remains recoverable and authoritative for v1.

## Maintenance Rule

Update this contract when lifecycle states, item types, cadence semantics, tracker ownership, or app projection fields change. Add a fixture and update the lifecycle spec before changing consumers.
