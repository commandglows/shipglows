---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.7.1"
project: ShipGlows
created: "2026-08-04"
updated: "2026-09-03"
status: active
source_skill: 302-sg-help
scope: help-modes-expert-catalog
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
    artifact_version: "2.10.0"
    required_status: active
supersedes: []
evidence:
  - "The métier-first public catalog keeps numeric runtime identities available through an explicit expert view."
  - "Operator decision 2026-08-16: document current-project hygiene and its safe Git cleanup specialization."
  - "Operator decision 2026-08-20: include internal 708-sg-auto while documenting execution posture as public tags rather than expert modes."
  - "Operator decision 2026-08-27: describe 900 as the internal DX-system owner while retaining its existing expert modes and shipglows_app boundary."
next_review: "2026-09-04"
next_step: "none"
---

# Help — Expert Runtime Modes

Return the owner-bound alias lines first, followed by the runtime-engine lines
below, for exact expert/internal catalog requests. These aliases are Codex-only
router syntax; they are not shell CLI commands and own no behavior separately
from the named public skill mode.

`shipglows core` -> `shipglows core` -> `900-shipglows-core`
`shipglows explore` -> `sg-planning explore` -> `700-sg-explore`
`shipglows spec` -> `sg-planning spec` -> `100-sg-spec`
`shipglows status` -> `sg-planning status` -> `308-sg-status`
`shipglows resume` -> `sg-planning resume` -> `303-sg-resume`
`shipglows capture` -> `sg-content capture` -> `800-tmux-capture-conversation`
`shipglows tmux` -> `sg-content capture` -> `800-tmux-capture-conversation`
`shipglows build` -> `sg-development build` -> `001-sg-build`
`shipglows fix` -> `sg-bug fix` -> `106-sg-fix`
`shipglows verify` -> contextual specialist owner, otherwise `sg-engineering verify` -> `103-sg-verify`
`shipglows test` -> `sg-engineering test` -> `107-sg-test`
`shipglows browser` -> `sg-engineering browser` -> `108-sg-browser`
`shipglows git` -> `sg-engineering github` -> `010-sg-technical`
`shipglows hygiene` -> `sg-maintenance hygiene` -> `002-sg-maintain`
`shipglows hygiene git` -> `sg-engineering github clean` -> `010-sg-technical`
`shipglows ship` -> `sg-release ship` -> `005-sg-ship`
`shipglows deploy` -> `sg-release deploy` -> `004-sg-deploy`
`shipglows prod` -> `sg-release prod` -> `405-sg-prod`

`000-shipglows` — default
`001-sg-build` — default | spark | codex | mini | agents | sous-agent | no-agents
`002-sg-maintain` — quick | full | security | deps | docs | audits | global | no-ship
`003-sg-bug` — default | reproduce | fix | retest | close
`004-sg-deploy` — default | preview | prod
`005-sg-ship` — default | end | skip-check | all-dirty
`006-sg-design` — identity | interface | system | playground | audit | animation | redesign | migration | library
`007-sg-content` — plan | capture | tmux | capture-full-conversation | clean-transcript | repurpose | draft | enrich | audit | marketing | seo | editorial | apply | ship
`008-sg-customer` — audit | flow | onboarding | recovery
`009-sg-marketing` — market | gtm | copy | copywriting | help
`010-sg-technical` — audit | architecture | deps | performance | migrate | github | sync | access | parity | help
`011-sg-pilotage` — tasks | backlog | priorities | review | sessions
`100-sg-spec` — default
`101-sg-ready` — default
`102-sg-start` — default
`103-sg-verify` — standard | excellence
`104-sg-end` — default
`105-sg-check` — fix | nofix
`106-sg-fix` — default
`107-sg-test` — default | retest | prod | preview | local
`108-sg-browser` — default
`109-sg-auth-debug` — default
`200-sg-redact` — default
`201-sg-enrich` — default
`202-sg-emailing` — write | sequence | template | deliverability | provider | audit
`203-sg-research` — default
`205-sg-veille` — triage | help
`300-sg-docs` — init | file | readme | api | components | auto | audit | update | metadata | migrate | migrate-frontmatter | migrate-layout | technical | editorial | duplicata|duplicates | add-project
`301-sg-context` — default
`302-sg-help` — mode | modes | expert | default
`303-sg-resume` — default | court | ultra-court
`304-sg-changelog` — default | since-tag | since-date | all
`305-sg-init` — default
`306-sg-scaffold` — page | component | layout | api | content | hook | util
`308-sg-status` — default | all | issues | dirty
`400-sg-audit` — default | file | global
`405-sg-prod` — default | project | URL
`406-sg-seo` — audit | launch | monitoring | fix | page | project | global
`407-sg-translate` — audit | sync | apply | help | path | global
`600-sg-local-cloud-sync` — default
`601-sg-product-entitlements` — default
`602-sg-platform-parity` — default | platforms=web,android,ios,windows,macos,linux
`603-sg-private` — memory <instruction> | data <namespace> <operation>
`700-sg-explore` — default
`704-sg-model` — default
`705-sg-conversation-audit` — default | latest | path | export shipglows
`706-continue` — default
`707-name` — default
`708-sg-auto` — internal engine for public `shipglows auto`; effective `#nolocal` is mandatory
`800-tmux-capture-conversation` — default | --tab
`801-clean-conversation-transcript` — default
`900-shipglows-core` — audit | build | refresh | packaging | help

`900-shipglows-core` maintains the internal ShipGlows DX system across skills/doctrine, CLI/DevServer/TUI runtime, cross-surface coherence, and packaging. `shipglows_app` site/SaaS work remains outside Core.
`emailing` — compatibility alias for `202-sg-emailing`
