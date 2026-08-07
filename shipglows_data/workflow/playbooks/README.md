---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-13"
status: draft
source_skill: 300-sg-docs
scope: workflow-playbooks-index
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/README.md
  - shipglows_data/workflow/checklists/README.md
  - skills/references/canonical-paths.md
  - skills/300-sg-docs/references/core-governance.md
depends_on:
  - artifact: "shipglows_data/workflow/checklists/README.md"
    artifact_version: "1.2.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator decision on 2026-06-28: ShipGlows needs reusable transversal playbooks and checklists for business domains shared across many sites and applications."
  - "Current corpus already stores test checklists under shipglows_data/workflow/test-checklists but lacks a canonical home for reusable domain playbooks."
  - "Server disk hygiene and migration playbook added after the 2026-07-13 disk-pressure incident."
  - "Private design-inspiration-library server migration playbook added on 2026-08-07."
next_review: "2026-07-05"
next_step: "/300-sg-docs update playbook migration inventory"
---

# Workflow Playbooks

`shipglows_data/workflow/playbooks/` is the canonical library for reusable operational playbooks that can apply across multiple projects, sites, apps, or business surfaces.

Use this folder when the document answers:

- `how should we run this domain end-to-end?`
- `in what order should we execute the work?`
- `what inputs, decisions, outputs, and gates exist?`

## What Belongs Here

- transversal launch playbooks
- SEO, GTM, onboarding, release, migration, and growth playbooks
- project import playbooks for URL/repo-to-private-fiche imports
- domain operating sequences reused across multiple projects
- shared playbooks that one or more project-local checklists can instantiate
- `seo-charge-referencement-web-playbook.md`
- `project-import-playbook.md`
- `server-disk-hygiene-and-migration-playbook.md`
- `conversation-tracker-sync-playbook.md`
- `cybersecurity-project-readiness-and-maintenance-playbook.md`
- `performance-project-readiness-and-monitoring-playbook.md`
- `analytics-measurement-readiness-and-quality-playbook.md`
- `marketing-go-to-market-readiness-playbook.md`
- `copywriting-public-surface-quality-playbook.md`
- `content-publication-and-editorial-operations-playbook.md`
- `production-health-and-operations-playbook.md`
- `maintenance-freshness-and-dependency-operations-playbook.md`
  - `technical-project-readiness-and-operations-playbook.md`
  - `design-inspiration-library-server-migration-playbook.md`

## Transversal Domain Boundary

The playbook library is intended to cover the complete project lifecycle, not
SEO alone. A project can combine technical, cybersecurity, technical SEO,
performance, analytics, marketing, copywriting, content, launch, production,
and maintenance playbooks. Each domain remains independently instantiable so
its progress, cadence, owner and evidence can be followed without merging all
controls into one task list.

Current detailed playbooks include technical/site launch, cybersecurity,
technical SEO, performance, analytics, marketing, copywriting, content,
production and maintenance. The marketing, copywriting and content masters
are initial operating contracts and should be refined with their domain owner
when a real project instantiates them.

Technical SEO is limited to the technical surface: crawlability, indexation,
rendering, metadata, structured data, performance signals and technical
maintenance. Keyword research, search intent, editorial strategy and content
production belong to the separate content/marketing workflow.

## What Does Not Belong Here

- project-specific task trackers
- one-off audit reports
- manual test execution checklists with PASS/FAIL rows
- durable business or technical truth that belongs in `shipglows_data/business/` or `shipglows_data/technical/`

## Playbook Contract

Every canonical playbook should make these sections easy to find:

1. `Purpose`
2. `Applicability`
3. `Inputs`
4. `Execution Order`
5. `Decision Gates`
6. `Outputs`
7. `Linked Checklists`
8. `Failure Modes` or `Common Risks`

## Naming Rule

Use domain-first kebab-case names:

- `site-launch-playbook.md`
- `seo-launch-playbook.md`
- `content-refresh-playbook.md`
- `app-store-release-playbook.md`

## Relationship With Checklists

- `playbook` = operating method
- `checklist` = execution control surface

A playbook explains how the domain should run. A checklist proves whether a concrete run or project has completed the required steps.

## Layering Rule

When both are needed:

1. keep the shared reusable method here under `playbooks/`
2. keep the paired reusable checklist under `../checklists/`
3. keep project-run evidence under `../test-checklists/` only when it is an executed proof artifact

## Migration Rule

If a reusable playbook exists at the repository root or inside an ad hoc folder, migrate it here unless there is a stronger canonical location already declared.

Keep a short migration note in the final report when:

- the source path was legacy
- the filename changed
- the content was split into shared playbook plus checklist

## First Targets

The current architecture expects this folder to absorb shared documents such as:

- `site-launch-playbook.md`
- future `seo-launch-playbook.md`
- future `distribution-launch-playbook.md`
- future `app-release-playbook.md`
- `seo-charge-referencement-web-playbook.md`
- `project-import-playbook.md`
- `conversation-tracker-sync-playbook.md`

## Validation

```bash
python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/shipglows/shipglows_data/workflow/playbooks/README.md
```
