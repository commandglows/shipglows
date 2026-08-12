---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 400-sg-audit
scope: audit-scope-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/400-sg-audit/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from audit-master-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify audit scope routing"
---

# Audit Scope And Routing

## Modes

- `global`: discover projects from explicit roots and project governance markers, present the project and domain selections, then run only selected, applicable cells.
- empty arguments: audit the current project across applicable domains.
- file path: audit that file across relevant domains; do not inflate to a project audit without evidence.

Determine applicability from project structure, manifests, public surfaces, business metadata, and operator selection. Missing or stale `BUSINESS.md`, `BRANDING.md`, or `GUIDELINES.md` lowers confidence; it never silently removes a lane.

## Direct Domain Owners

- code/security/architecture/tests: `010-sg-technical audit` plus its protocol and one target branch
- dependencies/licenses/supply chain: `010-sg-technical deps`
- performance/CWV/bundles/rendering/data/database: `010-sg-technical performance`
- migration: `010-sg-technical migrate`
- design/UI/system authority: `006-sg-design audit ui`
- copy or GTM: matching `009-sg-marketing` audit playbook
- SEO: `406-sg-seo audit` plus one target branch
- translation/i18n: `407-sg-translate audit`
- live deployment/runtime truth: `405-sg-prod`

Read each selected owner's activation contract and exact playbook directly. Do not search for retired generic headings.

## Read-Only Cell Contract

Each project × domain cell receives the exact path, date, selected owner contract, evidence scope, and these requirements: inspect consumers and downstream consequences; report file/line evidence where possible; surface product-story drift, workflow bypass, documentation mismatch, unsupported public claims, and security proof gaps; state assumptions and confidence limits; do not edit any file or durable state. Independent cells may run concurrently only under the shared delegation contract.
