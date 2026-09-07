---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "2.6.0"
project: ShipGlows
created: "2026-08-04"
updated: "2026-09-07"
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
  - skills/references/execution-posture-tags.md
depends_on:
  - artifact: skills/references/skill-code-index.md
    artifact_version: "2.10.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-08-04: sg-help mode must show one line per public métier with name and modes, while expert mode retains the internal engine catalog."
  - "Operator request 2026-08-05: show every public skill with exact invocation grammar, including nested mode arguments such as the animation actions."
  - "Operator decision 2026-08-20: mode help must distinguish owner workflows from transversal #local, #nolocal, and #ci execution tags."
next_review: "2026-10-07"
next_step: "/103-sg-verify sg-help mode catalog"
---

# Help — Skill Modes

Return only the lines below for exact `302-sg-help mode`, `302-sg-help modes`, `sg-help mode`, or `sg-help modes` requests. The order follows the six public navigation domains, then the universal router and the transversal execution tags. Each command line is directly reusable agent-invocation grammar: angle brackets are required choices or values, square brackets are optional.

`sg-development [default|feature|app|refactor|build|excellence] <goal>` — Build through verified implementation; `build` aliases construction and `excellence` reviews current-work quality (goal optional).
`sg-design identity [scope] | system [scope] | playground [route-path] | audit <ui|tokens|components|a11y> [scope] | animation <audit|design|implement|tune> [scope] | redesign [scope] | migration [scope] | library <add|retry|approve|list|status> ...` — Brand identity, design systems, interfaces, accessibility, inspiration, and motion.
`sg-experience <audit|flow|onboarding|recovery> <scope>` — Improve customer journeys, activation, trust, and recovery.
`sg-bug [default|reproduce|fix|retest|close] <defect-or-BUG-ID>` — Reproduce, repair, prove, and close product defects.
`sg-engineering <audit|architecture|deps|performance|migrate|github|sync|access|parity|verify|test|browser> [target]` — Own technical quality and proof; `github [audit|reconcile|clean|branches|dependabot|fix]` selects Git work and `verify` requires a target.
`sg-maintenance [quick|full|security|deps|docs|audits|global|hygiene] [scope] [no-ship]` — Default is full upkeep; `quick`/`global` inspect only, `hygiene` audits with separately authorized Git convergence, and `no-ship` suppresses delivery (also accepted alone).
`sg-release [default|preview|prod|verify|ship|deploy] [target]` — Prepare, deploy, and verify releases, with `ship` selecting Git delivery and `deploy` the deployment workflow.
`sg-content <plan|capture|clean-transcript|repurpose|draft|enrich|audit|editorial|apply|ship|publish|emailing> [source-or-target]` — Prepare and deliver audience content; `tmux`/`capture-full-conversation` alias capture, while `repurpose` requires a source and accepts `verbatim`.
`sg-marketing <market|gtm|copy|copywriting> <target>` — Define positioning, go-to-market strategy, messaging, and persuasive copy.
`sg-seo <audit|launch|monitoring|fix> [target] | <page|project|global> [target]` — Audit, launch, monitor, and repair SEO; `page`/`project`/`global` select audit scope rather than a different workflow.
`sg-docs <init|file|readme|api|components|auto|audit|update|metadata|migrate|migrate-layout|technical|editorial|duplicata|duplicates|add-project> [target]` — Maintain internal documentation; `auto` selects justified documentation work, not autonomous portfolio work.
`sg-planning <tasks|backlog|priorities|prio|review|sessions|explore|spec|status|resume> [arguments]` — Organize or recover work context; `prio` aliases `priorities`, `explore` clarifies an idea, and `spec` prepares a substantial work specification.
`sg-private <memory|data> <instruction>` — Remember private references or work in an explicitly declared durable private-data namespace without copying private content into public Git.
`sg-help [default|mode|modes|expert] [topic] | mode --expert` — Explain skills and workflows, list public modes, or show internal engines with `mode --expert`.
`shipglows <request> | context | update | auto [goal] | core <audit [scope|recent [N]|since <commit>]|build <goal>|refresh <skill>|packaging [scope]|help>` — Route work, inspect context, update the installed channel, run Auto under `#nolocal`, or maintain Core; recent audit defaults to 10 integrations and is read-only, and Core itself requires `build` instead of self-`refresh`.
Execution tags: `#local | #nolocal | #ci` — Compose proof posture with any agent command; `#ci` implies `#nolocal`, conflicts with `#local`, and authorizes no remote action.
