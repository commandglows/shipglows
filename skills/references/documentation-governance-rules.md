---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-06-30"
updated: "2026-07-13"
status: active
source_skill: 900-shipglows-core
scope: documentation-governance-rules
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/references/project-governance-rules.md
  - skills/references/canonical-paths.md
  - skills/references/technical-docs-corpus.md
  - skills/references/editorial-content-corpus.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/editorial/content-map.md
  - shipglows_data/technical/artifact-metadata-and-linter.md
  - shipglows_data/technical/metadata-migration-guide.md
depends_on:
  - artifact: "skills/references/project-governance-rules.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "shipglows_data/technical/artifact-metadata-and-linter.md"
    artifact_version: "1.0.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator clarification 2026-06-30: `#contract` is about operator-agent partnership, while documentation rules need their own stricter recentering tag."
  - "Operator clarification 2026-07-13: root compliance must distinguish canonical workflow records from explicitly owned operational, public-reference, and historical surfaces."
  - "Operator request 2026-06-30: add `#docs` for documentation architecture, metadata, and structure compliance."
  - "Operator decision 2026-07-13: classify root archive content, preserve useful history canonically, and delete content without durable value."
  - "Operator decision 2026-07-13: migrate docs, bug dossiers, bug triage, and QA logs into canonical shipglows_data families."
next_review: "2026-07-14"
next_step: "/300-sg-docs audit shared documentation-governance-rules reference"
---

# Documentation Governance Rules

Use this reference when the operator says `#docs` and wants strict documentation-governance compliance rather than general behavior guidance.

This reference is narrower than `#rules`. It is about documentation architecture, metadata, canonical placement, ownership, and update discipline.

## Core Rule

Documentation in a ShipGlows-governed project must live in the canonical place, use the right artifact contract, preserve one source of truth, and stay synchronized with code and public claims.

## Canonical Documentation Architecture

- Keep project governance docs in `shipglows_data/`, not in ad hoc root files.
- Keep technical documentation in `shipglows_data/technical/`.
- Keep editorial and public-content governance in `shipglows_data/editorial/`.
- Keep durable business, product, brand, GTM, competitor, and affiliate docs in `shipglows_data/business/`.
- Keep specs, audits, trackers, reviews, evidence, playbooks, and checklists in `shipglows_data/workflow/`.
- Keep `AGENT.md`, `CLAUDE.md`, and `README.md` as entrypoints or compatibility surfaces, not as the full canonical corpus.
- Keep the professional bug workflow's compact `shipglows_data/workflow/TEST_LOG.md`, optional `shipglows_data/workflow/BUGS.md`, and `shipglows_data/workflow/bugs/` records inside the canonical workflow corpus.
- Keep conversation captures and exploration reports under `shipglows_data/workflow/`, operator guides under `shipglows_data/technical/operator-guides/`, and useful inactive history under `shipglows_data/workflow/archives/`. Root `archive/`, `bugs/`, `docs/`, `specs/`, and `research/` are migration sources.

## Metadata Rules

- Active ShipGlows governance artifacts must use the ShipGlows frontmatter schema.
- Use versioned metadata for durable artifacts.
- Do not force frontmatter onto operational trackers such as `shipglows_data/workflow/TASKS.md` and `shipglows_data/workflow/AUDIT_LOG.md`.
- Do not add ShipGlows governance metadata to runtime content unless the runtime schema explicitly accepts it.
- Validate touched governance artifacts with `tools/shipglows_metadata_lint.py`.

## Placement Rules

- New governance docs should be created in the canonical corpus, not beside the nearest code file just because it is convenient.
- Legacy root governance files are migration sources, not destinations for new compliant work.
- In a monorepo, resolve governance docs from the monorepo root `shipglows_data/`.
- Do not create nested duplicate governance corpora under app/package folders unless the subproject is intentionally standalone.

## Ownership Rules

- Each documentation rule or explanation should have one canonical owner artifact.
- Prefer fixing the owner doc over patching duplicated derived surfaces first.
- `AGENT.md` stays a routing doc.
- `README.md` stays a public overview and operator-facing entrypoint, not the full internal doctrine layer.
- `content-map.md` owns public-content routing; `code-docs-map.md` owns technical doc mapping.
- behavior indexes own term-to-behavior recovery for complex technical domains; they do not replace `code-docs-map.md`.

## Technical Documentation Discipline

- For code-changing work, load `shipglows_data/technical/code-docs-map.md` first when it exists.
- A mapped code change requires either a `Documentation Update Plan` or an explicit no-impact justification.
- Major code areas should map to a primary technical doc or an explicit non-coverage reason.
- If a technical governance artifact is missing, report a bootstrap gap and route to `300-sg-docs technical`.
- Preserve the technical navigation layer roles:
  - `context.md` = system overview
  - `context-function-tree.md` = structural overview
  - `code-docs-map.md` = path routing
  - behavior index/domain model = term routing
- If one operator term maps to multiple technical meanings, the canonical owner is a behavior index or equivalent term-recovery artifact, not a comment thread or a spec note.
- High-cognitive-load code should carry source comments for contracts and invariants when a behavior index routes agents to those symbols.

## Editorial Documentation Discipline

- For public surfaces, load `shipglows_data/editorial/content-map.md` first.
- Public claims, page intent, and content-routing decisions should stay inside the editorial corpus, not scattered across random docs.
- If public or claim-bearing surfaces exist without editorial governance, report a bootstrap gap and route to `300-sg-docs editorial`.
- Preserve runtime schema boundaries for content collections and app-rendered content.

## Update Discipline

- If code, docs, and public copy diverge, repair the canonical owner layer first.
- Documentation updates should ship in the same workstream when behavior or public claims changed, unless there is an explicit no-impact decision.
- Missing docs should be classified precisely: bootstrap gap, migration debt, drift, or non-compliance.
- Missing or stale term-based recovery should be classified precisely: `technical navigation bootstrap gap` or `technical navigation drift`.
- Documentation fixes should state the owner artifact, not only the symptom.

## What `#docs` Should Trigger

When the operator uses `#docs`, the agent must:

1. reload this reference before answering, routing, auditing, or editing
2. treat documentation architecture and metadata compliance as first-class constraints
3. prefer `300-sg-docs` ownership logic when the request is ambiguous between implementation and governance repair
4. classify issues as placement, metadata, ownership, drift, bootstrap, or schema-boundary problems rather than generic “doc issue”

## Recommended Companions

- Use `#docs #rules` for strict documentation compliance inside broader project governance
- Use `#docs #canon` when the question is where the authoritative doc should live
- Use `#docs #owner` when the problem is duplicated documentation
- Use `#docs #public-docs` for public docs and editorial surfaces
- Use `#docs #internal-docs` for internal contracts, technical docs, and operator-facing governance artifacts

## Maintenance Rule

Update this reference when ShipGlows changes its documentation architecture, metadata obligations, canonical corpus boundaries, or docs update discipline.
