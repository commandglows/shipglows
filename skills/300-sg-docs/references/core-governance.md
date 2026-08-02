---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.6.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-06-28"
status: draft
source_skill: 102-sg-start
scope: 300-sg-docs-core-governance
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - shipglows_data/technical/
  - shipglows_data/editorial/
  - shipglows_data/business/
  - shipglows_data/technical/metadata-migration-guide.md
depends_on:
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.5.0"
    required_status: "active"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: "active"
supersedes: []
evidence:
  - "Extracted from 300-sg-docs SKILL.md during compact-skill pilot."
  - "Governance corpus now distinguishes global external provider notes from governance-root provider usage docs."
  - "Operator decision on 2026-05-24: provider usage notes are conditional on risk and project-specific behavior."
  - "Operator decision on 2026-05-24: monorepos use one root shipglows_data corpus instead of per-app/package copies."
  - "Operator decision on 2026-06-28: throwaway build and verification artifacts must be cleaned after use and never treated as durable project assets."
  - "Operator decision on 2026-06-28: duplicate governance artifacts should be audited explicitly and merged into shared theme-first files unless a real surface-specific divergence justifies separation."
next_review: "2026-06-16"
next_step: "/103-sg-verify Compact ShipGlows Skill Instructions"
---

# 300-sg-docs Core Governance

## Documentation Coherence Doctrine

Documentation is an active product surface. When behavior changes, check impacted docs (README, guides, onboarding, API docs, FAQ, pricing, support copy, examples, screenshots, `.env.example`, changelog).

Never document capabilities that are not proven by code, specs, or verified behavior.

Use explicit behavior labels when relevant: `implemented`, `verified`, `assumed`, `deprecated`, `removed`.

Treat stale docs as product risk, especially for security, permissions, billing, migration, public API, destructive actions, or sensitive-data workflows.

## Governance Corpus Ownership

`300-sg-docs` is the owner for project governance corpus creation, update, and audit.

- `300-sg-docs technical` owns technical governance layer bootstrapping/auditing.
- `300-sg-docs editorial` owns editorial/public-content governance bootstrapping/auditing.
- `300-sg-docs update` aligns docs drift and can route to technical/editorial bootstrap or audit.
- `300-sg-docs update` must preserve the execution-vs-editorial tracker split when a project declares both `shipglows_data/workflow/TASKS.md` and `shipglows_data/editorial/ROADMAP.md`.
- `300-sg-docs migrate-layout` owns legacy root ShipGlows artifact migration to canonical `shipglows_data/` paths.
- `300-sg-docs metadata` owns frontmatter migration/compliance for active ShipGlows artifacts.

`AGENT.md` is canonical. `AGENTS.md` must be a compatibility symlink only.

## Metadata And Artifact Rules

ShipGlows-generated governance artifacts require frontmatter with versioned contracts. Keep `metadata_schema_version: "1.0"` unless schema changes.

Use semantic versioning for `artifact_version`:

- `0.x.y` draft/inferred/migration state
- `1.0.0+` reviewed contract state
- patch: non-decision corrections
- minor: compatible decision updates
- major: decision-breaking changes

When bumping artifact version:

- update `updated`
- keep `created`
- keep metadata coherence (`status`, `confidence`, `risk_level`, `evidence`, `next_review`, `depends_on`, `supersedes`)

## Canonical Artifact Families

Preferred governance locations live under the canonical governance root. In a single-project repo this is the repo root. In a monorepo this is the monorepo root.

- `shipglows_data/business/*`
- `shipglows_data/branding/*`
- `shipglows_data/product/*`
- `shipglows_data/gtm/*`
- `shipglows_data/technical/*`
- `shipglows_data/technical/design-system-authority.md` for project UI design-system authority when the project has a UI
- `shipglows_data/technical/external-platforms/*` for global external provider source notes
- `shipglows_data/technical/platforms/*` for provider usage when local risk or complexity justifies a dedicated note
- `shipglows_data/editorial/*`
- `shipglows_data/workflow/specs/*`
- `shipglows_data/workflow/playbooks/*`
- `shipglows_data/workflow/checklists/*`

Monorepo rule:

- keep one canonical `shipglows_data/` at the monorepo root
- inside that root, prefer theme-first folders and add surface scopes under the theme, for example `shipglows_data/business/site/business.md`, `shipglows_data/product/app/product.md`, or `shipglows_data/technical/site/*`
- do not create `shipglows_data/` inside every app/site/lab/package
- treat nested `shipglows_data/` directories as migration debt unless the nested folder is intentionally a standalone project with its own repo lifecycle

Legacy root files (`BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, root `specs/`) are migration sources.

Reusable transversal operating documents follow this split:

- `shipglows_data/workflow/playbooks/*` for method and execution order
- `shipglows_data/workflow/checklists/*` for reusable control surfaces
- `shipglows_data/workflow/test-checklists/*` for executed proof artifacts

## Duplicate Governance Decision Rule

Duplicate governance files are migration debt by default, not a neutral layout choice.

When multiple files appear to carry the same governance intent across shared and surface-scoped paths, classify them before keeping or deleting anything:

- `merge-to-shared`: same project truth, same branding, same business model, or materially overlapping content that should live once in a shared theme-first artifact
- `keep-surface-specific`: surface-specific implementation, runtime, UX flow, API, channel strategy, or other real divergence that would become misleading if merged
- `split-shared-and-surface-delta`: a shared core truth exists, but one or more surfaces need a smaller scoped delta or extension
- `collision-needs-review`: overlap exists but ownership, freshness, or truth cannot be resolved safely from repo evidence alone

Decision heuristics:

- branding is shared by default across a monorepo unless the project explicitly declares multiple brands
- business is shared by default when the same product family, value proposition, or revenue logic applies across surfaces
- product, GTM, technical, and editorial docs may diverge by surface, but only when the divergence changes operator decisions or user truth
- if two files differ only by phrasing, formatting, stale fragments, or copy-pasted structure, merge them
- if one file is a strict subset of another, prefer the stronger canonical file and absorb the subset where useful
- if two files are mostly identical with a few meaningful surface deltas, extract the common core into a shared file and keep only the scoped delta

Deletion rule:

- do not delete a duplicate until the canonical merged destination exists and any non-redundant content has been preserved or intentionally rejected

Reporting rule:

- duplicate audits should report each reviewed artifact set with `classification`, `canonical target`, `action`, and `reason`

## Migration Preservation Rule

Monorepo normalization and doc consolidation are preservation work first, cleanup work second.

Before turning a local doc into a compatibility facade, deleting it, or replacing it with a pointer:

1. inventory the source artifact and choose the canonical target
2. compare the source against the canonical target or planned target
3. preserve non-redundant technical, product, planning, QA, or operational content
4. record any intentional rejection when content is stale, duplicated, or explicitly deprecated
5. only then slim the source into a facade or remove it

Preservation proof must be semantic, not only structural. Metadata lint, symlink checks, and path normalization do not prove that meaningful content survived the migration.

Minimum preservation ledger per migrated source:

- `source artifact`
- `canonical target`
- `content preserved`
- `content intentionally rejected`
- `tracker/task extraction`
- `final local state` (`kept as facade|deleted|kept scoped`)

Facade rule:

- local compatibility docs may remain when canonical-path doctrine allows them, but they must be clearly marked as facades and must not remain the durable source of truth

Failure rule:

- if the migration cannot prove where important source content went, treat the migration as incomplete rather than reporting the cleanup as done

## Tracker Exception Rule

Do not enforce frontmatter on operational trackers:

- `shipglows_data/workflow/TASKS.md`
- `shipglows_data/editorial/ROADMAP.md`
- `shipglows_data/workflow/AUDIT_LOG.md`
- Legacy central `PROJECTS.md` files are migration evidence only.
- `shipglows_data/workflow/TEST_LOG.md`
- `shipglows_data/workflow/BUGS.md`

If a tracker contains durable decision content, extract that decision into a versioned ShipGlows artifact and keep the tracker as pointer/task.

If a tracker contains active planning or execution work that still matters, migrate that work into the canonical workflow trackers before slimming the local tracker. Do not collapse a tracker into a facade until its actionable tasks, QA history, or planning signals have been preserved.

## Disposable Artifact Hygiene Rule

Generated local artifacts are not source assets and must not be kept as durable project state just because a tool produced them.

Treat at least these paths as disposable by default unless a project documents an explicit exception:

- `node_modules/`
- `dist/`, `build/`, `.output/`
- `.vercel/` and `.vercel/output/`
- `.playwright-mcp/`
- `.astro/`
- generated test-output folders such as `test-results/`

Rules:

- never version disposable artifacts
- keep them ignored in `.gitignore`
- delete them after the validation, preview, deploy-proof, or local troubleshooting step that required them
- do not cite them as canonical evidence or documentation sources
- if a tool recreates them automatically on each run, that is still not a reason to keep them in the repo

If a workflow genuinely requires a generated artifact to persist, that persistence must be documented as a bounded exception in project governance instead of being implied by the tool.

## Bug Workflow Documentation Rule

Documentation must preserve the professional bug model:

- `shipglows_data/workflow/bugs/BUG-ID.md` is source of truth
- `shipglows_data/workflow/BUGS.md` is optional/generated triage view
- `shipglows_data/workflow/TEST_LOG.md` is compact QA tracker
- heavy proof belongs in `test-evidence/BUG-ID/` with redaction

## Design-System Governance Rule

Projects with a UI need a declared design-system authority before agents change visual implementation.

- `shipglows_data/branding/branding.md` owns the shared brand root, bundle boundaries, and brand direction.
- Optional shared brand bundle files may extend it when the project needs stronger normalization:
  - `shipglows_data/branding/voice-and-tone.md`
  - `shipglows_data/branding/messaging-pillars.md`
  - `shipglows_data/branding/visual-identity.md`
  - `shipglows_data/branding/brand-rules.md`
  - `shipglows_data/branding/assets/README.md`
- `shipglows_data/technical/<surface>/design-system-authority.md` owns the code-level design-system authority when the UI technology or token carrier differs by surface.
- In monorepos, keep brand identity shared at `shipglows_data/branding/branding.md` and scope technical design-system authority by surface when site/app runtimes diverge.
- If the authority is missing or split across competing files, `300-sg-docs technical` should create or flag the declaration before UI implementation proceeds.

## Language Doctrine

- Internal ShipGlows contracts stay in English.
- User-facing content/reporting stays in active user/project language.
- Stable machine labels can stay in English.
- For French user-facing text, accents are mandatory unless the token is an identifier/command/ASCII-only format.

## Security And Redaction

- Never expose secrets, tokens, private keys, cookies, or sensitive private logs.
- Never strengthen public claims beyond verified product/system truth.
- Never mutate runtime content schemas (`site/src/content/**` etc.) in ways that break app parsers.

## Validation Minimum

Always run metadata lint on changed frontmatter artifacts and add focused path checks for migrated canonical references.

For migration or consolidation passes, add a preservation audit:

- compare each slimmed or removed local source against the updated canonical target
- verify that planning/task content moved into canonical workflow trackers when relevant
- verify that the local replacement clearly states its compatibility-only role
