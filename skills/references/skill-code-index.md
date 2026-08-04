---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.6.0"
project: ShipGlows
created: "2026-06-10"
updated: "2026-08-03"
status: active
source_skill: 102-sg-start
scope: skill-code-index
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/000-shipglows/SKILL.md
  - skills/302-sg-help/SKILL.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - tools/skill_code_index_lint.py
  - skills/900-shipglows-core/SKILL.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/three-digit-runtime-skill-names.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes:
  - artifact: "shipglows_data/workflow/specs/numeric-skill-code-index.md"
    artifact_version: "1.0.0"
evidence:
  - "User decision 2026-06-10: use three digits directly before the skill name for the real runtime-visible skill identity."
  - "User decision 2026-06-10: no symbol-heavy names; keep lowercase letters, numbers, and hyphens only."
  - "2026-06-11 900-shipglows-core added as an internal operator skill in the reserved meta band."
  - "2026-06-11 310-sg-github-hygiene added as the git/GitHub sync, stale branch, PR drift, and Dependabot hygiene skill."
  - "2026-07-15 design consolidation retired 409 and 500-504 as public skills; their capabilities now live as modes and playbooks under 006-sg-design."
  - "2026-07-15 skill-maintenance consolidation retired 009 and 307; their capabilities now live as modes under the internal-only 900-shipglows-core."
  - "2026-07-17 technical consolidation assigned 010 and retired 401-404; their capabilities now live as explicit modes under 010-sg-technical."
  - "2026-08-03 pilotage consolidation assigned 011 and retired 309 and 701-703; tasks, backlog, priorities, review, and sessions now live as explicit modes under 011-sg-pilotage."
next_review: "2026-08-15"
next_step: "/103-sg-verify consolidate pilotage skills under sg-pilotage"
---

# Skill Code Index

## Purpose

This is the canonical ShipGlows runtime skill-name map.

The code is now part of the runtime-visible skill identity. For example:

```text
old name: 001-sg-build
runtime name: 001-sg-build
operator invocation: $001-sg-build
```

## Resolution Rules

- Runtime skill names use `NNN-<old-name>`.
- The three-digit code is stable after ship.
- The suffix preserves the old skill name exactly.
- Old unprefixed names may appear only as legacy aliases, historical evidence, or natural-language route hints.
- Do not create wrapper skills for old names unless a future ready spec explicitly accepts duplicate picker entries.

## Family Bands

| Band | Family | Memory rule |
| --- | --- | --- |
| `000-099` | Master and high-frequency entrypoints | Most frequent and highest-level commands get the easiest codes; an entrypoint in this band is not necessarily a lifecycle master. |
| `100-199` | Lifecycle and proof | Spec, readiness, execution, verification, checks, fixes, browser/auth/test proof. |
| `200-299` | Content, research, and copy | Writing, enrichment, repurposing, market/research/watch, and copy audits. |
| `300-399` | Docs, context, and support | Docs, help, context, changelog, init, scaffold, status, and GitHub hygiene. |
| `400-499` | Audit, quality, and ops risk | Broad audit, production proof, SEO, and i18n; technical depth moved to high-frequency entrypoint 010. |
| `500-599` | Unassigned legacy band | Former design-specialist band; design now routes through `006-sg-design` modes. Reuse requires a ready taxonomy decision. |
| `600-699` | Data and activation | Local-cloud sync, entitlements, parity, and future account/data surfaces. |
| `700-799` | Pilotage-adjacent and session helpers | Explore, model choice, continuation, naming, and conversation-audit helpers. |
| `800-899` | Conversation and transcript helpers | Conversation capture and transcript tooling. |
| `900-999` | Reserved rare meta space | Reserved for future rare or migration-only skills. |

Frequency wins over family when a skill belongs to both. For example `007-sg-content` stays in the master band.

## Code Table

| Code | Old name | Runtime skill | Family |
| --- | --- | --- | --- |
| `000` | `shipglows` | `000-shipglows` | Master |
| `001` | `sg-build` | `001-sg-build` | Master |
| `002` | `sg-maintain` | `002-sg-maintain` | Master |
| `003` | `sg-bug` | `003-sg-bug` | Master |
| `004` | `sg-deploy` | `004-sg-deploy` | Master |
| `005` | `sg-ship` | `005-sg-ship` | Master |
| `006` | `sg-design` | `006-sg-design` | Master |
| `007` | `sg-content` | `007-sg-content` | Master |
| `008` | `sg-customer` | `008-sg-customer` | Master |
| `009` | `sg-marketing` | `009-sg-marketing` | Research/strategy/source |
| `010` | `sg-technical` | `010-sg-technical` | Audit/technical/source |
| `011` | `sg-pilotage` | `011-sg-pilotage` | Master/pilotage |
| `100` | `sg-spec` | `100-sg-spec` | Lifecycle/proof |
| `101` | `sg-ready` | `101-sg-ready` | Lifecycle/proof |
| `102` | `sg-start` | `102-sg-start` | Lifecycle/proof |
| `103` | `sg-verify` | `103-sg-verify` | Lifecycle/proof |
| `104` | `sg-end` | `104-sg-end` | Lifecycle/proof |
| `105` | `sg-check` | `105-sg-check` | Lifecycle/proof |
| `106` | `sg-fix` | `106-sg-fix` | Lifecycle/proof |
| `107` | `sg-test` | `107-sg-test` | Lifecycle/proof |
| `108` | `sg-browser` | `108-sg-browser` | Lifecycle/proof |
| `109` | `sg-auth-debug` | `109-sg-auth-debug` | Lifecycle/proof |
| `200` | `sg-redact` | `200-sg-redact` | Content/research/copy |
| `201` | `sg-enrich` | `201-sg-enrich` | Content/research/copy |
| `202` | `sg-emailing` | `202-sg-emailing` | Content/research/copy |
| `203` | `sg-research` | `203-sg-research` | Content/research/copy |
| `205` | `sg-veille` | `205-sg-veille` | Content/research/copy |
| `300` | `sg-docs` | `300-sg-docs` | Docs/context/support |
| `301` | `sg-context` | `301-sg-context` | Docs/context/support |
| `302` | `sg-help` | `302-sg-help` | Docs/context/support |
| `303` | `sg-resume` | `303-sg-resume` | Docs/context/support |
| `304` | `sg-changelog` | `304-sg-changelog` | Docs/context/support |
| `305` | `sg-init` | `305-sg-init` | Docs/context/support |
| `306` | `sg-scaffold` | `306-sg-scaffold` | Docs/context/support |
| `308` | `sg-status` | `308-sg-status` | Docs/context/support |
| `310` | `sg-github-hygiene` | `310-sg-github-hygiene` | Docs/context/support |
| `400` | `sg-audit` | `400-sg-audit` | Audit/quality/ops |
| `405` | `sg-prod` | `405-sg-prod` | Audit/quality/ops |
| `406` | `sg-seo` | `406-sg-seo` | Audit/quality/ops |
| `407` | `sg-translate` | `407-sg-translate` | Audit/quality/ops |
| `600` | `sg-local-cloud-sync` | `600-sg-local-cloud-sync` | Data/activation |
| `601` | `sg-product-entitlements` | `601-sg-product-entitlements` | Data/activation |
| `602` | `sg-platform-parity` | `602-sg-platform-parity` | Data/activation |
| `700` | `sg-explore` | `700-sg-explore` | Pilotage/session |
| `704` | `sg-model` | `704-sg-model` | Pilotage/session |
| `705` | `sg-conversation-audit` | `705-sg-conversation-audit` | Pilotage/session |
| `706` | `continue` | `706-continue` | Pilotage/session |
| `707` | `name` | `707-name` | Helper/Claude statusline |
| `800` | `tmux-capture-conversation` | `800-tmux-capture-conversation` | Conversation/transcript |
| `801` | `clean-conversation-transcript` | `801-clean-conversation-transcript` | Conversation/transcript |
| `900` | `shipglows-core` | `900-shipglows-core` | Meta/internal |

## Maintenance

Run this after adding, removing, or renaming a skill:

```bash
python3 tools/skill_code_index_lint.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
```

The linter must fail when:

- a code is duplicated
- a runtime skill appears twice
- a listed runtime skill directory is missing
- a `skills/*/SKILL.md` directory has no active code row
- the runtime skill does not equal `<code>-<old-name>`
