---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.2.0"
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
  - "Operator request 2026-08-05: show every public skill with exact invocation grammar, including nested mode arguments such as the animation actions."
next_review: "2026-09-04"
next_step: "/103-sg-verify sg-help mode catalog"
---

# Help — Skill Modes

Return only the lines below for exact `302-sg-help mode`, `302-sg-help modes`, `sg-help mode`, or `sg-help modes` requests. The order follows the six public navigation domains, then the universal router. Each line is directly reusable invocation grammar: angle brackets are required choices or values, square brackets are optional.

`sg-development [default|feature|app|refactor] <goal>` — Build a feature, application, or refactor through verified implementation.
`sg-design system [scope] | playground [route-path] | audit <ui|tokens|components|a11y> [scope] | animation <audit|design|implement|tune> [scope] | redesign [scope] | migration [scope] | library <add|approve|list|status> ...` — Design systems, interfaces, accessibility, inspiration, and motion.
`sg-experience <audit|flow|onboarding|recovery> <scope>` — Improve customer journeys, activation, trust, and recovery.
`sg-bug [default|reproduce|fix|retest|close] <defect-or-BUG-ID>` — Reproduce, repair, prove, and close product defects.
`sg-engineering <audit|architecture|deps|performance|migrate|github|sync|access|parity> [target]` — Own technical quality, architecture, dependencies, migrations, access, and parity.
`sg-maintenance [quick|full|security|deps|docs|audits|global|no-ship] [scope]` — Run bounded or comprehensive project upkeep.
`sg-release [default|preview|prod|verify] [target]` — Prepare, deploy, and verify releases.
`sg-content <plan|capture|repurpose|draft|enrich|audit|editorial|publish|emailing> [source-or-target]` — Create and prepare public documentation and audience content.
`sg-marketing <market|gtm|copy|copywriting> <target>` — Define positioning, go-to-market strategy, messaging, and persuasive copy.
`sg-seo <audit|launch|monitoring|fix|page|project|global> [target]` — Audit, launch, monitor, and repair SEO.
`sg-docs <init|readme|api|components|audit|update|metadata|migrate|technical> [target]` — Maintain internal architecture, governance, metadata, and agent documentation.
`sg-planning <tasks|backlog|priorities|review|sessions> [arguments]` — Organize tasks, priorities, reviews, and portfolio work.
`sg-help [default|mode|expert] [topic]` — Explain skills, exact public modes, expert engines, workflows, and prompts.
`shipglows <request>` — Route any ShipGlows request to the correct public métier owner.
