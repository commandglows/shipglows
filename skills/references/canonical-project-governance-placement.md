---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: canonical-project-governance-placement
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/canonical-paths.md
  - skills/references/monorepo-governance-topology.md
  - shipglows_data/
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "2.1.0"
    required_status: active
supersedes: []
evidence:
  - "Project governance decisions place one canonical shipglows_data corpus at the governance root."
  - "Historical root governance files remain migration inputs rather than compliant destinations."
next_review: "2026-09-03"
next_step: "/103-sg-verify project governance placement"
---

# Canonical Project Governance Placement

Load this leaf only when locating, creating, migrating, or auditing project-owned governance artifacts.

## Corpus Boundary

Keep exactly one `shipglows_data/` at the governance root. In a monorepo, code may resolve from a selected subdirectory, but governance still resolves from the monorepo root. A nested corpus is migration debt unless it belongs to a documented, separately cloned and shipped standalone repository.

Use theme-first families, scoped by surface only when truth differs:

- `shipglows_data/business/`, `product/`, `branding/`, and `gtm/` for commercial and product truth
- `shipglows_data/technical/` for architecture, context, guidelines, and operator guides
- `shipglows_data/editorial/` for public-content maps and claims
- `shipglows_data/workflow/` for specs, bugs, audits, reviews, research, verification, conversations, explorations, trackers, playbooks, checklists, and archived history

For detailed monorepo source layout and the `ext/` versus `extensions/<name>/` decision, load `skills/references/monorepo-governance-topology.md` directly from the core route; this leaf does not restate it.

## Root Exceptions And Migration

`AGENT.md`, `README.md`, optional `CLAUDE.md`, and optional public `CHANGELOG.md` may remain at repository root. When supported by the platform, `AGENTS.md` is the compatibility symlink to `AGENT.md`; inability to create it on Windows is a visible compatibility constraint, not permission to create an unnoticed divergent authority.

Root `archive/`, `bugs/`, `docs/`, `specs/`, `research/`, `BUGS.md`, and `TEST_LOG.md` are migration sources. The same applies to root `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `TASKS.md`, and `AUDIT_LOG.md`. Preserve useful content in its owning family; do not overwrite or delete ambiguous history during resolution.

Generated directories such as `node_modules/`, `dist/`, `.astro/`, `.vercel/`, `.vercel/output/`, and `.playwright-mcp/` are disposable outputs, never governance or proof sources.

## Common Destinations

| Legacy artifact | Canonical destination |
| --- | --- |
| business, product, brand, GTM | matching theme, shared or `<surface>/...` |
| inspiration, affiliates | `business/<surface>/project-competitors-and-inspirations.md` or `affiliate-programs.md` |
| context, function tree, architecture, guidelines | `technical/<surface>/...` |
| content map | `editorial/<surface>/content-map.md` |
| tasks, audit log | `workflow/TASKS.md` or `workflow/AUDIT_LOG.md` |
| specs | `workflow/specs/*.md` |

Reusable playbooks belong in `workflow/playbooks/`; reusable non-test checklists in `workflow/checklists/`; executed manual proof in `workflow/test-checklists/`; inactive history in `workflow/archives/<bounded-scope>/`.
