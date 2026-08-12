---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-08-12"
status: active
source_skill: 007-sg-content
scope: content-router
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 8 reduced the router to first-lane selection."
next_review: "2026-11-12"
next_step: none
---

# Content Router

Select one smallest viable lane; do not execute later lifecycle phases from this pack.

- `capture`, `tmux`, or legacy `capture-full-conversation`: normalize to `capture`, then use internal `800-tmux-capture-conversation`; do not clean or repurpose.
- `clean-transcript <path>`: use internal `801-clean-conversation-transcript`; do not capture a new pane.
- `plan`, `strategy`, `calendar`: content plan; durable/multi-surface work needs `100-sg-spec`.
- `repurpose <source>`: the SKILL loads `references/repurpose-playbook.md` directly. A bare `repurpose` asks for a source. `verbatim`, `mot pour mot`, and `copie exacte` preserve exact chronological order with no analysis.
- `draft`, `write`, `article`, `blog`, `guide`, `editorial`: `200-sg-redact` after surface/claim gates.
- `enrich`, `refresh`, `update @file`, `improve`: `201-sg-enrich`.
- `audit copy`, `copy`, `copywriting`, `market`, `gtm`: exact `009-sg-marketing` mode; `seo`: `406-sg-seo`.
- `docs`, `readme`, internal editorial governance: `300-sg-docs`.
- unsettled external trend/source: `205-sg-veille` or `203-sg-research`.
- `apply`, `publish`, `ship`: governance and proof first, then `103-sg-verify` and bounded `005-sg-ship`.

Source material with no settled downstream surface may use the bounded repurpose lane first. Never dispatches to a second public repurpose skill.
