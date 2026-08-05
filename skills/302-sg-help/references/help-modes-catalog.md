---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.1.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-08-05"
status: active
source_skill: 302-sg-help
scope: help-modes-catalog
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems:
  - skills/302-sg-help/SKILL.md
  - skills/references/skill-code-index.md
  - skills/references/skill-invocation-registry.json
depends_on:
  - artifact: skills/references/skill-code-index.md
    artifact_version: "2.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-08-04: sg-help mode must show one line per public métier with name and modes, while expert mode retains the internal engine catalog."
next_review: "2026-09-04"
next_step: "/103-sg-verify sg-help mode catalog"
---

# Help — Skill Modes

Return only the lines below for exact `302-sg-help mode`, `302-sg-help modes`, `sg-help mode`, or `sg-help modes` requests. The order follows the six public navigation domains, then the universal router.

`sg-development` — default | feature | app | refactor
`sg-design` — system | playground | audit | animation | redesign | migration | library
`sg-experience` — audit | flow | onboarding | recovery
`sg-bug` — default | reproduce | fix | retest | close
`sg-engineering` — audit | architecture | deps | performance | migrate | github | sync | access | parity
`sg-maintenance` — quick | full | security | deps | docs | audits | global | no-ship
`sg-release` — default | preview | prod | verify
`sg-content` — plan | capture | repurpose | draft | enrich | audit | editorial | publish | emailing
`sg-marketing` — market | gtm | copy | copywriting
`sg-seo` — audit | launch | monitoring | fix | page | project | global
`sg-docs` — init | readme | api | components | audit | update | metadata | migrate | technical
`sg-planning` — tasks | backlog | priorities | review | sessions
`sg-help` — default | mode | expert
`shipglows` — default
