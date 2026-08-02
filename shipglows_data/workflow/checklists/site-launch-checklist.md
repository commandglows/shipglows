---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-06-28"
status: draft
source_skill: 300-sg-docs
scope: site-launch-checklist
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/checklists/README.md
  - shipglows_data/workflow/playbooks/site-launch-playbook.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/site-launch-playbook.md"
    artifact_version: "1.0.0"
    required_status: draft
supersedes: []
evidence:
  - "Legacy source recovered from /home/claude/site-launch-agent-checklist.md on 2026-06-28."
  - "Checklist normalized into reusable transversal form and detached from project-specific notes."
next_review: "2026-07-05"
next_step: "/300-sg-docs migrate additional launch checklists into workflow/checklists"
---

# Site Launch Checklist

## Purpose

Reusable checklist for launching a public site into Google Search Console without canonical, sitemap, robots, or indexation mistakes.

## Applicability

Use for a first launch, relaunch, domain migration, SEO recovery launch, or any production cutover that changes the public canonical surface.

## Required Before Start

- [ ] Root domain identified as `<domain>`
- [ ] Final canonical origin chosen as `<canonical-origin>`
- [ ] Production site deployed on the intended public domain
- [ ] Search Console access available

## Checklist

### 1. Canonical Strategy

- [ ] Root domain identified without protocol or path
- [ ] One final canonical origin chosen
- [ ] Code/config inspected for declared origin
- [ ] Hosting behavior compared with declared origin
- [ ] All absolute public origins aligned: sitemap, robots, `llms.txt`, canonical tags, `hreflang`, `og:url`, JSON-LD

### 2. Live Redirects

- [ ] `https://<domain>/` tested
- [ ] `http://<domain>/` tested
- [ ] `https://www.<domain>/` tested
- [ ] `http://www.<domain>/` tested
- [ ] All variants converge to the same final canonical origin
- [ ] Final page returns `200`
- [ ] No redirect loop or conflicting origin behavior remains

### 3. Public SEO Files

- [ ] `robots.txt` returns `200`
- [ ] `sitemap.xml` returns `200`
- [ ] `llms.txt` returns `200` when part of the standard
- [ ] `robots.txt` does not accidentally block the whole site
- [ ] `robots.txt` excludes private surfaces where needed
- [ ] `sitemap.xml` contains only public production URLs
- [ ] `sitemap.xml` uses the canonical origin consistently
- [ ] `llms.txt` contains no private or non-production links

### 4. Canonical HTML Checks

- [ ] Home page canonical verified
- [ ] One localized page checked if multilingual
- [ ] One category or hub page checked
- [ ] One detail page checked
- [ ] One guide/article page checked
- [ ] One alternatives/comparison page checked if relevant
- [ ] One archived/discontinued page checked if relevant
- [ ] Every sampled page exposes a canonical tag
- [ ] Every canonical target returns `200`
- [ ] No canonical target still redirects to another origin
- [ ] Localized pages canonicalize to themselves

### 5. Search Console Property

- [ ] Search Console property created or confirmed
- [ ] `Domain` property used when possible
- [ ] URL-prefix fallback used only when necessary
- [ ] Property verification completed

### 6. Sitemap Submission

- [ ] Sitemap preconditions validated
- [ ] Sitemap submitted in Search Console
- [ ] Submission status recorded
- [ ] No sitemap error reported by Search Console

### 7. Priority URL Inspection

- [ ] Home inspected in URL Inspection
- [ ] 3 to 5 priority URLs inspected
- [ ] Google can fetch the inspected URLs
- [ ] Inspected URLs are indexable
- [ ] Declared canonical is coherent
- [ ] Google-selected canonical is coherent when shown

### 8. Early Indexation Monitoring

- [ ] Coverage/indexation report reviewed
- [ ] Server errors reviewed
- [ ] Soft 404 reviewed
- [ ] Robots exclusions reviewed
- [ ] `noindex` exclusions reviewed
- [ ] Duplicate/canonical conflicts reviewed
- [ ] Important pages marked explored or crawled but not indexed are listed for follow-up

### 9. Post-Launch Follow-Up

- [ ] `J+1` key URL inspection scheduled or completed
- [ ] `J+3` error review scheduled or completed
- [ ] `J+7` coverage and impressions review scheduled or completed
- [ ] `J+14` canonical/sitemap/robots stabilization review scheduled or completed

## Completion Rule

This checklist is complete only when all blocking items are checked and no unresolved `500`, sitemap failure, or canonical-origin conflict remains.

## Linked Playbook

- [site-launch-playbook.md](/home/claude/shipglowz/shipglows_data/workflow/playbooks/site-launch-playbook.md)

## Exceptions

Record exceptions directly below the relevant item with:

- reason
- proof path
- owner
- next action

## Validation

```bash
python3 /home/claude/shipglowz/tools/shipglows_metadata_lint.py /home/claude/shipglowz/shipglows_data/workflow/checklists/site-launch-checklist.md
```
