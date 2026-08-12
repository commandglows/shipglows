---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: "ShipGlows"
created: "2026-05-04"
created_at: "2026-05-04 06:03:39 UTC"
updated: "2026-08-12"
updated_at: "2026-08-12 20:11:48 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
confidence: high
user_story: "En tant qu'utilisatrice ShipGlows qui gere des contenus publics, docs, pages skill, FAQ, articles futurs et assets de repurposing avec des agents, je veux une master skill de gestion du contenu qui orchestre les skills contenu existantes, afin que l'intention, les surfaces, les claims, la production, l'audit, la validation et le ship restent coherents sans dupliquer les lanes specialisees."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-content/SKILL.md
  - skills/sg-repurpose/SKILL.md
  - skills/sg-redact/SKILL.md
  - skills/sg-enrich/SKILL.md
  - skills/sg-audit-copy/SKILL.md
  - skills/sg-audit-copywriting/SKILL.md
  - skills/sg-audit-seo/SKILL.md
  - skills/sg-docs/SKILL.md
  - skills/sg-veille/SKILL.md
  - skills/sg-market-study/SKILL.md
  - skills/sg-help/SKILL.md
  - skills/references/editorial-content-corpus.md
  - CONTENT_MAP.md
  - docs/editorial/
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - site/src/content/skills/sg-content.md
  - site/src/pages/skill-modes.astro
depends_on:
  - artifact: "shipglows_data/editorial/README.md"
    artifact_version: "1.0.0"
    required_status: reviewed
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.14.0"
    required_status: draft
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.9.0"
    required_status: reviewed
  - artifact: "shipglows_data/technical/public-site-and-content-runtime.md"
    artifact_version: "1.3.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "Historical migration-source provenance (legacy root documents): BRANDING.md, CONTENT_MAP.md, GTM.md, PRODUCT.md."
  - "User request 2026-05-04: create the master skill for content management."
  - "Existing content skills already cover repurposing, long-form drafting, enrichment, copy audits, copywriting audits, SEO audits, docs, veille, and market studies."
  - "CONTENT_MAP.md and docs/editorial/ already define content surfaces, public claims, page intent, Astro runtime schema policy, and missing blog/article stop conditions."
  - "site/src/content.config.ts defines the public skills content collection schema used by site/src/content/skills/*.md."
next_step: "/sg-start sg-content Master Content Lifecycle Skill"
---

# Spec: sg-content Master Content Lifecycle Skill

## Title

sg-content Master Content Lifecycle Skill

## Status

Ready.

The skill placement decision is explicit: create a new master skill named `sg-content` because the request is not another writing, repurposing, SEO, or docs lane. It needs a durable orchestrator that routes to existing content owner skills and public-content governance gates without duplicating their internals.

## User Story

En tant qu'utilisatrice ShipGlows qui gere des contenus publics, docs, pages skill, FAQ, articles futurs et assets de repurposing avec des agents, je veux une master skill de gestion du contenu qui orchestre les skills contenu existantes, afin que l'intention, les surfaces, les claims, la production, l'audit, la validation et le ship restent coherents sans dupliquer les lanes specialisees.

## Minimal Behavior Contract

`sg-content` accepts a content goal, source, mode, surface, or audit request, loads the content map and editorial governance layer, identifies whether the work is planning, repurposing, drafting, enriching, auditing, docs alignment, or ship-ready publication, then routes to the owner skills in order; if the work is ambiguous, multi-surface, claim-sensitive, or needs a new content surface, it requires `sg-explore` or `sg-spec` before edits, and if a declared surface is missing, such as the blog surface, it reports the missing surface instead of inventing a path. The easy-to-miss edge case is content work that seems like "just copy" but changes public claims, page intent, site schema, README truth, FAQ answers, or skill promises.

## Success Behavior

- Given a user asks for content management broadly, when `sg-content` runs, then it identifies a mode and routes to the correct owner skills instead of drafting everything inside the master skill.
- Given a source idea or build conversation exists, when the user wants reuse, then `sg-content` routes through `sg-repurpose` and checks `CONTENT_MAP.md` plus `docs/editorial/` before public output.
- Given the user wants a new article, guide, or blog-style content, when no blog/article surface is declared, then `sg-content` reports `surface missing: blog` and routes to a spec or explicit surface decision.
- Given existing public content needs improvement, when `sg-content` is invoked with `enrich`, `audit`, `seo`, or a file path, then it routes to `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo`, or `sg-docs` as appropriate and preserves runtime content schemas.
- Given content changes are applied, when validation runs, then skill budget audit, runtime skill sync, metadata lint, public site build, and targeted `rg` checks pass or the blocker is reported.

## Error Behavior

- If the content target is unclear and one targeted question cannot settle mode, surface, or public promise, route to `sg-explore` before a spec or edits.
- If the work changes multiple public surfaces, claims, skill promises, or content strategy, require `sg-spec` and `sg-ready` before implementation.
- If the work would create an undeclared blog, newsletter, social, support, or article path, stop with `surface missing` and request a surface decision.
- If a public claim lacks evidence in product, business, brand, GTM, spec, or claim-register sources, mark `needs proof`, `claim mismatch`, or `blocked`.
- If the public site build, metadata lint, runtime skill sync, or skill budget audit fails, stop before ship routing.
- If unrelated dirty files would enter ship scope, do not call `sg-ship` without explicit user authorization.

## Problem

ShipGlows already has strong content lanes, but no single master entrypoint for content management. The operator has to know whether to start from `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo`, `sg-docs`, `sg-veille`, or `sg-market-study`, then remember the content map, editorial gate, claim register, missing blog policy, Astro schema boundary, validation, and ship routing.

That creates two risks: duplicate content behavior in random skills, and public drift when content work bypasses the governance layer.

## Solution

Create `skills/sg-content/SKILL.md` as a lifecycle master skill. It owns intake, content-mode detection, surface and claim gates, spec/readiness routing, owner-skill orchestration, validation, docs/help/public-page coherence, and ship routing.

Do not move writing, repurposing, enrichment, audit, SEO, docs, market study, or veille internals into this skill. `sg-content` remains the planner/orchestrator and uses the specialist skills as owner lanes.

## Scope In

- Create the new `sg-content` skill contract.
- Create a public skill page for `sg-content`.
- Update help, workflow, README, skill launch cheatsheet, public skill modes page, content map, and skill runtime technical docs for discoverability.
- Define content-mode routing to `sg-repurpose`, `sg-redact`, `sg-enrich`, `sg-audit-copy`, `sg-audit-copywriting`, `sg-audit-seo`, `sg-docs`, `sg-veille`, `sg-market-study`, `sg-build`, `sg-verify`, and `sg-ship`.
- Enforce content map, editorial corpus, claim register, page intent, missing blog surface, Astro runtime schema, validation, and ship gates.
- Sync current-user Claude/Codex runtime skill links for `sg-content`.

## Scope Out

- Rewriting existing specialist content skills from scratch.
- Creating a blog, newsletter, CMS, RSS, social content repository, or article collection.
- Changing the Astro content schema.
- Creating new research/provider integrations.
- Running a full content calendar or backlog migration.
- Shipping unrelated dirty files.

## Constraints

- Internal skill contracts, workflow rules, validation notes, stop conditions, and stable section headings use English.
- User-facing interaction and final report follow the active user language; this run reports in French.
- `CONTENT_MAP.md` remains the canonical content routing map.
- `docs/editorial/` remains the public-content governance layer.
- Runtime content under `site/src/content/**` must keep `site/src/content.config.ts`; do not add ShipGlows governance metadata there.
- `sg-content` must ask targeted questions only when the answer changes mode, surface, public claim, security, scope, or ship posture.
- A master skill routes owner lanes; it must not duplicate their full internal prompt contracts.

## Dependencies

- `CONTENT_MAP.md`, `docs/editorial/`, and `skills/references/editorial-content-corpus.md` for content surface and claim governance.
- `skills/sg-repurpose/SKILL.md`, `skills/sg-redact/SKILL.md`, `skills/sg-enrich/SKILL.md`, `skills/sg-audit-copy/SKILL.md`, `skills/sg-audit-copywriting/SKILL.md`, `skills/sg-audit-seo/SKILL.md`, `skills/sg-docs/SKILL.md`, `skills/sg-veille/SKILL.md`, and `skills/sg-market-study/SKILL.md` for owner lanes.
- `site/src/content.config.ts` and public skill page examples for public page schema.
- `tools/shipglows_sync_skills.sh`, `tools/skill_budget_audit.py`, and `tools/shipglows_metadata_lint.py` for lifecycle validation.
- Fresh external docs verdict: `fresh-docs not needed` because the work adds local skill and content contracts, reads the existing Astro schema, and validates through the local site build without changing framework behavior.

## Invariants

- `sg-content` owns orchestration only.
- Specialist skills keep their domains: source-faithful repurposing, long-form drafting, enrichment, copy audit, conversion copy audit, SEO audit, docs governance, veille, and market studies.
- Public content work starts with `CONTENT_MAP.md` and the editorial corpus.
- Missing content surfaces are blockers, not permission to invent paths.
- Sensitive public claims require evidence or downgrade.
- Public runtime content schema stays intact.
- Multi-surface or claim-sensitive content work uses spec-first.
- Ship routing happens only after validation and dirty-scope review.

## Links & Consequences

Upstream systems:

- Business/product/brand/GTM contracts, content map, editorial governance layer, specialist content skills, public skill page schema, and skill runtime lifecycle docs.

Downstream systems:

- Public skill catalog, skill launch cheatsheet, README workflow docs, `sg-help`, public site build, runtime skill discovery, and future content workstreams.

Consequences:

- Operators get one content-management entrypoint.
- Existing specialist content skills become easier to discover without gaining duplicate responsibilities.
- Public-content governance is applied earlier in content work.
- New content surfaces remain explicit decisions instead of accidental paths.

## Documentation Coherence

Required updates:

- `skills/sg-content/SKILL.md`: new master skill contract.
- `site/src/content/skills/sg-content.md`: public skill page.
- `skills/sg-help/SKILL.md`: skill list, lifecycle matrix, examples, and routing hints.
- `README.md` and `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: official workflow doctrine and launch cheatsheet.
- `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` and `site/src/pages/skill-modes.astro`: public launch reference.
- `CONTENT_MAP.md`: add the content lifecycle entrypoint and routing rule.
- `docs/technical/skill-runtime-and-lifecycle.md`: add the master content lifecycle to skill runtime docs.

No update required:

- `docs/technical/code-docs-map.md` already maps `skills/**/SKILL.md`, `site/**`, `CONTENT_MAP.md`, and specs.
- `docs/editorial/public-surface-map.md` already covers public skill content generically.
- `docs/editorial/page-intent-map.md` already covers `/skills/[slug]` generically.

## Edge Cases

- The user asks for "blog" but the repo has no blog surface: report `surface missing: blog`.
- The user asks to "write content" from no source and no goal: ask for the source or route to `sg-explore`.
- The user asks to update a public page with a sensitive claim: require claim-register review.
- The user asks to update `site/src/content/skills/*.md`: preserve the Astro content schema and run the site build.
- The user gives a URL or market trend: route to `sg-veille`, `sg-research`, or `sg-market-study` before drafting.
- The work changes many shared content surfaces: require spec/readiness and sequential integration.
- The work is an internal-only docs note: allow `no editorial impact` with reason.

## Implementation Tasks

- [x] Task 1: Create the ready chantier spec.
  - File: `specs/sg-content-master-content-lifecycle-skill.md`
  - Action: Capture placement, behavior, gates, tasks, validation, and run history.
  - User story link: Gives the master content skill a durable contract.
  - Depends on: Existing content governance and skill inventory scan.
  - Validate with: `python3 tools/shipglows_metadata_lint.py specs/sg-content-master-content-lifecycle-skill.md`
  - Notes: `sg-content` is a new master skill, not a specialist duplicate.

- [x] Task 2: Create the internal skill contract.
  - File: `skills/sg-content/SKILL.md`
  - Action: Add lifecycle gates, mode detection, owner-skill routing, stop conditions, validation commands, and compact reporting.
  - User story link: Gives operators one content-management entrypoint.
  - Depends on: Task 1.
  - Validate with: `rg -n "Trace category|Process role|CONTENT_MAP|editorial-content-corpus|sg-repurpose|sg-redact|sg-enrich|sg-audit-copy|sg-audit-copywriting|sg-audit-seo|surface missing: blog|Editorial Update Plan|Claim Impact Plan|sg-ship" skills/sg-content/SKILL.md`
  - Notes: Keep internal contract language English.

- [x] Task 3: Publish the runtime skill links.
  - File: `~/.claude/skills/sg-content`, `~/.codex/skills/sg-content`
  - Action: Use the shared sync helper to repair and check current-user runtime symlinks.
  - User story link: Makes the skill discoverable in Claude/Codex runtimes.
  - Depends on: Task 2.
  - Validate with: `${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh --check --skill sg-content`
  - Notes: No `agents/openai.yaml` exists in this repo, so no display-name update is required.

- [x] Task 4: Create the public skill page.
  - File: `site/src/content/skills/sg-content.md`
  - Action: Add a schema-compatible public page summarizing the master content workflow.
  - User story link: Makes the new content entrypoint visible in the public skill catalog.
  - Depends on: Task 2.
  - Validate with: `pnpm --dir shipglows-site build`
  - Notes: Do not add ShipGlows governance frontmatter to runtime content.

- [x] Task 5: Update help and launch docs.
  - File: `skills/sg-help/SKILL.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `site/src/pages/skill-modes.astro`
  - Action: Add `sg-content` to master-skill and mode-routing surfaces.
  - User story link: Helps operators choose the new master entrypoint.
  - Depends on: Tasks 2 and 4.
  - Validate with: `rg -n "sg-content" skills/sg-help/SKILL.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md site/src/pages/skill-modes.astro`
  - Notes: Keep public wording short.

- [x] Task 6: Update workflow and content doctrine.
  - File: `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `CONTENT_MAP.md`
  - Action: Add the content lifecycle entrypoint and routing rule without duplicating skill internals.
  - User story link: Keeps the official workflow coherent.
  - Depends on: Task 5.
  - Validate with: `rg -n "sg-content|content lifecycle|content management" README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md CONTENT_MAP.md`
  - Notes: Shared files; edit sequentially.

- [x] Task 7: Update technical runtime docs.
  - File: `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Add `sg-content` to entrypoints, control flow, invariants, and validation references.
  - User story link: Keeps code-proximate docs aligned with skill runtime behavior.
  - Depends on: Task 6.
  - Validate with: `rg -n "sg-content|content lifecycle|content management" docs/technical/skill-runtime-and-lifecycle.md`
  - Notes: `docs/technical/code-docs-map.md` needs no change because path coverage already exists.

- [x] Task 8: Run validation and verification.
  - File: changed skill/docs/site/spec files
  - Action: Run runtime sync check, skill budget audit, metadata lint, site build, targeted stale-name and secret scans, and `sg-verify` against this spec.
  - User story link: Proves the lifecycle is coherent and ready to route to ship.
  - Depends on: All previous tasks.
  - Validate with: required validation commands in the Test Strategy.
  - Notes: Stop before ship if unrelated dirty files remain in scope.

## Acceptance Criteria

- [x] AC 1: Given the operator asks for content management, when `sg-content` exists, then it offers one master entrypoint without duplicating specialist content lanes.
- [x] AC 2: Given content work affects public surfaces or claims, when `sg-content` runs, then it requires `CONTENT_MAP.md`, editorial corpus, `Editorial Update Plan`, and `Claim Impact Plan` where relevant.
- [x] AC 3: Given the user asks for a blog/article and no surface is declared, when `sg-content` evaluates the target, then it reports `surface missing: blog`.
- [x] AC 4: Given the new skill is created, when runtime sync runs, then Claude and Codex current-user skill links point to `skills/sg-content`.
- [x] AC 5: Given public skill content is added, when the Astro build runs, then the skill content collection still validates.
- [x] AC 6: Given help/workflow/public launch docs are read, when looking for content lifecycle work, then `sg-content` is discoverable.
- [x] AC 7: Given verification runs, when it checks modified `skills/*/SKILL.md`, then `sg-content` exposes `Trace category` and `Process role`.
- [x] AC 8: Given ship routing is considered, when unrelated dirty files exist, then the run stops before committing or pushing.

## Test Strategy

Structural checks:

- `test -f skills/sg-content/SKILL.md`
- `test -f site/src/content/skills/sg-content.md`
- `rg -n "Trace category|Process role|CONTENT_MAP|editorial-content-corpus|surface missing: blog|Editorial Update Plan|Claim Impact Plan" skills/sg-content/SKILL.md`
- `rg -n "sg-content" README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md skills/sg-help/SKILL.md docs/technical/skill-runtime-and-lifecycle.md CONTENT_MAP.md site/src/pages/skill-modes.astro site/src/content/skills/sg-content.md`

Validation commands:

- `${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_sync_skills.sh --check --skill sg-content`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py specs/sg-content-master-content-lifecycle-skill.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md CONTENT_MAP.md docs/technical docs/editorial shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
- `pnpm --dir shipglows-site build`
- `rg -n "secret|token|credential|private key|BEGIN .*KEY" skills/sg-content/SKILL.md site/src/content/skills/sg-content.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md CONTENT_MAP.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md docs/technical/skill-runtime-and-lifecycle.md site/src/pages/skill-modes.astro`

Verification:

- Apply `sg-verify` against this spec.
- Confirm fresh external docs verdict is `fresh-docs not needed`.
- Confirm `Documentation Update Plan` is complete.
- Confirm `Editorial Update Plan` is complete for the public skill page and launch docs.

## Risks

- Duplicate responsibility risk: mitigated by making `sg-content` a master orchestrator only.
- Public claim risk: mitigated by claim register and editorial update gates.
- Surface sprawl risk: mitigated by `surface missing` stop conditions.
- Runtime visibility risk: mitigated by current-user skill sync.
- Public site build risk: mitigated by Astro build validation.
- Dirty worktree risk: mitigated by not calling `sg-ship` when unrelated dirty files exist.

## Execution Notes

Read first:

- `CONTENT_MAP.md`
- `skills/references/editorial-content-corpus.md`
- `docs/editorial/README.md`
- `skills/sg-repurpose/SKILL.md`
- `skills/sg-redact/SKILL.md`
- `skills/sg-enrich/SKILL.md`
- `skills/sg-audit-copy/SKILL.md`
- `skills/sg-audit-copywriting/SKILL.md`
- `skills/sg-audit-seo/SKILL.md`
- `skills/sg-docs/SKILL.md`
- `site/src/content.config.ts`

Implementation order:

```text
spec -> SKILL.md -> runtime sync -> public skill page -> help/launch docs -> workflow/docs/content map -> validation -> verify -> ship route
```

Fresh external docs:

- `fresh-docs not needed`: the change uses local ShipGlows contracts and an existing Astro schema; no external framework behavior is changed.

Stop conditions:

- Stop if target name is not `sg-content` or violates skill-name policy.
- Stop if a new specialist content skill would duplicate existing owner lanes.
- Stop if runtime symlink sync is blocked by non-symlink entries.
- Stop if site build fails.
- Stop if metadata lint fails.
- Stop if skill budget audit has policy-blocking failures.
- Stop before ship if unrelated dirty files remain in scope.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-04 06:03:39 UTC | sg-spec | GPT-5 Codex | Created the `sg-content` master content lifecycle skill spec from the user's request and existing content governance evidence. | ready spec created | `/sg-ready sg-content Master Content Lifecycle Skill` |
| 2026-05-04 06:03:39 UTC | sg-ready | GPT-5 Codex | Evaluated structure, user-story alignment, placement, tasks, docs coherence, language doctrine, security, and freshness. | ready | `/sg-start sg-content Master Content Lifecycle Skill` |
| 2026-05-04 06:03:39 UTC | sg-skill-build | GPT-5 Codex | Created the `sg-content` skill contract, public skill page, runtime links, help/workflow/docs routing, and validation plan. | implemented | `/sg-verify specs/sg-content-master-content-lifecycle-skill.md` |
| 2026-05-04 06:09:58 UTC | sg-skills-refresh | GPT-5 Codex | Ran the required skill-refresh gate for the new `sg-content` skill and logged the local doctrine refresh. | completed: no additive findings beyond the new contract | `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` |
| 2026-05-04 06:09:58 UTC | sg-verify | GPT-5 Codex | Verified runtime skill sync, skill budget audit, metadata lint, public site build, structural checks, stale-placeholder scan, and public skill page generation. | verified; ship blocked until unrelated dirty scope is bounded | `/sg-ship "Add sg-content master content lifecycle skill"` |
| 2026-05-04 06:18:12 UTC | sg-ship | GPT-5 Codex | Shipped a scoped commit that stages only `sg-content` files and deliberately excludes unrelated dirty worktree changes. | shipped | None |

## Current Chantier Flow

```text
sg-spec: done
sg-ready: ready
sg-start: implemented via sg-skill-build
sg-verify: verified
sg-end: completed
sg-ship: shipped
```

Current state:

- Chantier identified: yes.
- Spec path: `specs/sg-content-master-content-lifecycle-skill.md`.
- Required next step: None.
