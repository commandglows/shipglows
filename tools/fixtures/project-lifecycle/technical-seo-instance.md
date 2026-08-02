---
artifact: checklist_instance
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "Example Site"
project_id: "example-site"
checklist_id: "seo-technical"
checklist_version: "1.1.0"
cycle_id: "example-site:seo-technical:2026-07-28"
cycle_kind: "initial"
scope: project-checklist-instance
created: "2026-07-28"
updated: "2026-07-28"
status: draft
source_skill: 001-sg-build
owner: "seo"
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
evidence: ["reports/technical-seo-scope.md"]
depends_on: []
supersedes: []
next_step: "Complete crawl and indexation controls"
---

# Checklist instance — SEO technique — Example Site

## Identity

- Project: `example-site`
- Master checklist: `shipglows_data/workflow/checklists/seo-charge-referencement-web-checklist.md`
- Master version: `1.1.0`
- Cycle: `example-site:seo-technical:2026-07-28`
- Cycle kind: `initial`

## Progress

- Status: `in_progress`
- Completed controls: `2 / 5`
- Current phase: `Crawl et indexation`
- Current blocker: `Search Console access still pending`
- Next action: `Complete sitemap and indexation controls`

## Controls

| Control ID | Phase | Control | Required | Status | Evidence | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| technical-scope-environments | Périmètre et environnement | Environments are distinguished | yes | verified | reports/environment-matrix.md | |
| technical-scope-indexable-surfaces | Périmètre et environnement | Indexable surfaces are declared | yes | verified | reports/technical-seo-scope.md | |
| technical-crawl-robots | Crawl et indexation | robots.txt is valid | yes | in_progress | - | Review generated production file |
| technical-crawl-sitemaps | Crawl et indexation | Sitemaps are accessible | yes | waiting_for_evidence | - | Search Console access pending |
| technical-crawl-coverage | Crawl et indexation | Index coverage is checked | yes | not_started | - | |

## Cycle Closure

- Completion decision: `open`
- Verification evidence: `-`
- Closed at: `-`
- Archived instance: `-`
- Next cycle instance: `-`
