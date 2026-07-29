---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipFlow
created: "2026-06-28"
updated: "2026-07-13"
status: draft
source_skill: 300-sg-docs
scope: workflow-checklists-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglowz_data/README.md
  - shipglowz_data/workflow/playbooks/README.md
  - shipglowz_data/workflow/test-checklists/
  - shipglowz_data/workflow/checklist-instances/
  - skills/references/canonical-paths.md
depends_on:
  - artifact: "shipglowz_data/workflow/playbooks/README.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator decision on 2026-06-28: ShipFlow needs reusable transversal checklists for business domains shared across many sites and applications."
  - "Current corpus only has test-checklists for execution proof, not a canonical reusable checklist library."
  - "Server disk hygiene and migration checklist added after the 2026-07-13 disk-pressure incident."
next_review: "2026-07-05"
next_step: "/300-sg-docs update checklist migration inventory"
---

# Workflow Checklists

`shipglowz_data/workflow/checklists/` is the canonical library for reusable non-test checklist masters. A project-specific copy of the ordered controls belongs in a checklist instance, where progress and cycle history are recorded.

Use this folder when the document answers:

- `what must be checked before we call this domain complete?`
- `where are we in this transversal process for this project?`

## What Belongs Here

- reusable launch checklists
- SEO readiness checklists
- migration readiness checklists
- content publication checklists
- business-domain checklists paired to shared playbooks
- technical, cybersecurity, SEO technique, marketing, copywriting, performance, analytics, launch, production, and maintenance checklists
- `seo-charge-referencement-web-checklist.md`
- `seo-content-strategy-a-migrer-plus-tard-checklist.md` (archive de migration, hors SEO technique actif)
- `project-import-checklist.md`
- `server-disk-hygiene-and-migration-checklist.md`
- `cybersecurity-project-readiness-and-maintenance-checklist.md`
- `performance-project-readiness-and-monitoring-checklist.md`
- `analytics-measurement-readiness-and-quality-checklist.md`
- `marketing-go-to-market-readiness-checklist.md`
- `copywriting-public-surface-quality-checklist.md`
- `content-publication-and-editorial-operations-checklist.md`
- `production-health-and-operations-checklist.md`
- `maintenance-freshness-and-dependency-operations-checklist.md`
- `technical-project-readiness-and-operations-checklist.md`

## Domain Coverage

The lifecycle model is transversal. Each project may declare several applicable
domains, and each applicable domain gets its own master checklist and project
instances. The model does not imply that every master is already written.

| Domain | Meaning in this model | Master status |
| --- | --- | --- |
| technical | architecture, integrations, code and technical readiness | available through site launch, import, and technical operations controls |
| cybersecurity | security posture, secrets, access, dependencies and incident readiness | available |
| seo | technical crawl, indexation, rendering, metadata, performance signals and maintenance | available; content SEO and keyword strategy are separate |
| performance | measurable speed, resource use, runtime and regression follow-up | available |
| analytics | measurement plan, instrumentation, consent and data-quality checks | available |
| marketing | positioning, offer, acquisition and go-to-market readiness | available as a first master; validate with the marketing owner |
| copywriting | clarity, persuasion, claims, CTAs and public-surface copy | available as a first master; validate with the marketing/content owner |
| content | editorial production and publication operations | available as a separate content workflow; not technical SEO |
| launch | release gates and publishability decision | available through the site-launch controls |
| production | deployed health, observability and operational truth | available |
| maintenance | recurring upkeep, freshness, dependencies and technical hygiene | available as a consolidated first master |

`Master status` is intentionally explicit: an applicable domain with no master
is `needs_review`, never silently complete. This matrix is a catalog, not a
second tracker.

## What Does Not Belong Here

- detailed manual QA proof with PASS/FAIL/BLOCKED rows
- one-off spec acceptance criteria
- ad hoc TODO lists

Executed QA proof stays in `shipglowz_data/workflow/test-checklists/`.

Project checklist instances use `templates/project_checklist_instance.md` as their starting shape and live under `shipglowz_data/workflow/checklist-instances/` when a project adopts the convention. They are progression records, not task trackers.

## Checklist Contract

Every reusable checklist should make these sections easy to find:

1. `Purpose`
2. `Applicability`
3. `Required Before Start`
4. `Checklist`
5. `Completion Rule`
6. `Linked Playbook`
7. `Exceptions`

## Naming Rule

Use domain-first kebab-case names:

- `site-launch-checklist.md`
- `seo-launch-checklist.md`
- `content-refresh-checklist.md`
- `seo-charge-referencement-web-checklist.md`
- `project-import-checklist.md`

## Relationship With Playbooks

- `playbook` explains sequence, roles, decisions, and method
- `checklist` tracks completion against that method

If a checklist starts to explain too much rationale or branching execution logic, move that logic back to the paired playbook.

## Relationship With Test Checklists

Use the three layers explicitly:

- `workflow/playbooks/` = shared method
- `workflow/checklists/` = shared master control surface
- `workflow/checklist-instances/` = project/cycle progression and history
- `workflow/test-checklists/` = executed proof artifact for one concrete chantier or verification run

## Validation

```bash
python3 /home/claude/shipglowz/tools/shipglowz_metadata_lint.py /home/claude/shipglowz/shipglowz_data/workflow/checklists/README.md
```
