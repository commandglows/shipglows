---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: draft
source_skill: sg-docs
scope: "[editorial-governance|surface-map|claim-register|page-intent|schema-policy|content-gate]"
owner: "[owner]"
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
content_surfaces:
  - "[public_site|repo_docs|public_skill_pages|faq_support|future_blog|runtime_content]"
claim_register: "[path/to/claim-register.md]"
page_intent: "[path/to/page-intent-map.md]"
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_review: "YYYY-MM-DD"
next_step: "/sg-docs audit"
---

# [Editorial Content Context Title]

## Purpose

Explain what public-content, claim, page-intent, or runtime content governance this artifact owns.

## Owned Surfaces

| Surface | Path | Role | Source of truth | Update trigger |
| --- | --- | --- | --- | --- |
| `[surface]` | `[path]` | `[public job]` | `[contract/spec/evidence]` | `[trigger]` |

## Claim Boundaries

State which public claims this artifact governs and where claim evidence must be checked before publication.

## Page Intent

State which page, route, README section, FAQ/support surface, or content collection this artifact maps.

## Runtime Content Policy

If this artifact references runtime content such as Astro, MDX, CMS entries, or app-rendered Markdown, preserve the framework schema. Do not force ShipGlows metadata into runtime content unless the local schema explicitly accepts it.

## Editorial Update Plan

```markdown
## Editorial Update Plan

- Changed behavior or source: `[source]`
- Impacted surface: `[route/file/surface]`
- Source of truth: `[contract/spec/evidence]`
- Required action: `[none|review|update|create|remove|surface missing|pending final copy]`
- Reason: `[why]`
- Owner role: `[Editorial Reader|executor|integrator|human decision]`
- Parallel-safe: `[yes|no]`
- Validation: `[check]`
- Closure status: `[complete|no editorial impact|pending final copy|blocked]`
```

## Maintenance Rule

Update this artifact when its owned public surfaces, claim boundaries, page intent, source contracts, or runtime content schema assumptions change.
