---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.1"
project: ShipGlows
created: "2026-06-29"
created_at: "2026-06-29 09:42:00 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:20:26 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "skill taxonomy migration"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows, je veux que les skills de domaine ne portent plus un mode comme audit ou debug dans leur identite principale mais exposent ces intentions comme des modes, afin que le routing soit plus clair et que les playbooks, checklists et references portent la doctrine metier."
risk_level: high
security_impact: none
docs_impact: yes
confidence: high
linked_systems:
  - "skills/"
  - "skills/references/skill-code-index.md"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/content-quality-rubric.md"
  - "skills/302-sg-help/references/help-catalog.md"
  - "skills/109-sg-auth-debug/SKILL.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "plugins/shipglows/assets/pack-catalog.json"
  - "plugins/shipglows/skills/shipglows/references/pack-catalog.md"
  - "shipglows-site/src/content/skills/"
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.2.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "User decision 2026-06-29: audit-seo should become sg-seo with audit as a mode."
  - "User decision 2026-06-29: auth-debug should become sg-auth with debug as a mode."
  - "First tranche already migrated 406-sg-audit-seo to 406-sg-seo and public page sg-audit-seo to sg-seo."
  - "Subagent inventory identified the remaining audit-named skills and warned not to rename invocation keys without updating runtime links, docs, pack catalogs, and public skill pages."
  - "ShipGlows governance now separates skills as activation routers from references, playbooks, checklists, and test-checklists as doctrine/control/proof artifacts."
next_step: "/101-sg-ready audit-skill-domain-mode-taxonomy-migration"
---

# Title

Skill Domain-Mode Taxonomy Migration

## Status

Draft. First SEO tranche is partially implemented and must be verified as part of this chantier before continuing with the remaining audit-named skills.

## User Story

En tant qu'operatrice ShipGlows, je veux que les skills de domaine ne portent plus un mode comme `audit` ou `debug` dans leur identite principale mais exposent ces intentions comme des modes, afin que le routing soit plus clair et que les playbooks, checklists et references portent la doctrine metier.

## Minimal Behavior Contract

ShipGlows must rename domain skills whose runtime identity contains a mode name, such as `audit` or `debug`, to domain-first runtime names while preserving their numeric code, converting the mode word from identity to mode, and moving any remaining long doctrine out of `SKILL.md` into references, playbooks, or checklists. Existing live routing, public skill pages, plugin pack catalogs, help docs, code index, runtime symlinks, and content/governance references must point to the new names. Historical specs, changelogs, archives, and audit reports may keep old names as historical evidence.

## Success Behavior

- A fresh agent can invoke the domain skill name, for example `406-sg-seo` or `109-sg-auth`, then choose or infer modes such as `audit`, `debug`, `setup`, `verify`, `fix`, `launch`, or `monitoring`.
- Domain routers keep compact activation contracts with `Mission`, `Scope Gate` or `Mode Detection`, `Required References`, `Stop Conditions`, and `Validation`.
- Long checklists, scoring matrices, mode playbooks, report templates, and audit phase detail live in references, playbooks, or checklists.
- Runtime skill links for Claude and Codex resolve to the renamed directories.
- Public skill pages and plugin pack catalogs use the new names.
- Old names no longer appear in active docs, routing, public site content, plugin pack catalogs, or runtime skill symlinks, except where an explicit legacy alias policy is documented.

## Error Behavior

- If a rename would create duplicate runtime skills or stale non-symlink runtime targets, stop and report the exact blocked target.
- If a renamed skill is still referenced from active routing or public docs, fail validation and update the reference before proceeding.
- If a domain is already owned by a lifecycle master, do not create a competing domain skill; route audit mode through the existing domain skill or document a migration/deprecation plan.
- If the old name appears only in historical specs, changelog, archives, or completed audit evidence, do not rewrite history.

## Problem

Several skills still encode a mode directly in their runtime identity. That made sense when those skills were mostly one-off helpers, but ShipGlows is moving toward domain routers backed by playbooks, checklists, and references. Names such as `406-sg-audit-seo` make SEO look like an audit-only function even though it now owns launch readiness, monitoring, fix routing, and domain doctrine loading. `109-sg-auth-debug` has the same structural problem: auth is the domain, while debug is only one operating mode.

## Solution

Migrate audit-named skills in controlled batches. Keep numeric codes stable, rename only the suffix and public slug, update all active consumers, publish runtime symlinks, and validate with metadata lint, skill budget audit, skill code index lint, runtime sync, stale-name scans, and public site build when site content changes.

## Scope In

- Rename domain-oriented audit skills so `audit` becomes a mode:
  - `406-sg-audit-seo` -> `406-sg-seo` (already started)
  - `407-sg-audit-translate` -> `407-sg-translate`
  - `408-sg-audit-gtm` -> `408-sg-gtm`
  - `409-sg-audit-a11y` -> `409-sg-a11y`
  - `503-sg-audit-design-tokens` -> `503-sg-design-tokens`
  - `504-sg-audit-components` -> `504-sg-components`
- Decide and implement the correct design lane treatment:
  - preferred target: `006-sg-design` owns mode `audit`
  - `502-sg-audit-design` must either become `502-sg-design-review` as a specialist mode helper or be deprecated/absorbed through a documented route
- Decide and implement the correct code lane treatment:
  - canonical target: `$010-sg-technical audit <target>` through `skills/010-sg-technical/SKILL.md` and its technical-audit playbook
  - keep `400-sg-audit` as the cross-domain audit master only if the word `audit` is still semantically the product identity; otherwise rename to `400-sg-review` or `400-sg-quality`
- Re-evaluate content/copy lanes separately:
  - `206-sg-audit-copy`
  - `207-sg-audit-copywriting`
  These need naming decisions because `copy`, `copywriting`, `review`, `audit`, and `content quality` overlap.
- Rename non-audit skills that still encode a mode in the runtime identity:
  - `109-sg-auth-debug` -> `109-sg-auth`
  - expected modes: `debug`, `audit`, `setup`, `verify`, and `fix`
  - expected doctrine locations: auth debug workflow, auth setup checklist, auth verification checklist, and security/session references as needed
- Update active references:
  - `skills/references/skill-code-index.md`
  - `skills/302-sg-help/references/help-catalog.md`
  - `skills/*/README.md`
  - `skills/*/SKILL.md`
  - skill-local references
  - `README.md`
  - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
  - `shipglows_data/editorial/*`
  - `plugins/shipglows/assets/pack-catalog.json`
  - `plugins/shipglows/skills/shipglows/references/pack-catalog.md`
  - `shipglows-site/src/content/skills/*`
- Repair current-user runtime links under `$HOME/.claude/skills` and `$HOME/.codex/skills`.

## Scope Out

- Do not rewrite historical changelog, completed specs, completed audits, retired archives, or conversation transcripts unless a live routing page consumes them.
- Do not change numeric skill codes.
- Do not create wrapper skills for old names unless a later ready spec explicitly accepts duplicate picker entries.
- Do not rename `900-shipglows-core` because its audit meaning is internal governance and not a domain-router issue.
- Do not rename `705-sg-conversation-audit` in this tranche unless the operator explicitly decides conversation audit should also become a broader domain skill.
- Do not use the `109-sg-auth` rename to broaden auth behavior into destructive account, provider, or production-data mutation without explicit approval.

## Constraints

- Keep runtime names lowercase with numbers and hyphens only.
- Preserve `Trace category`, `Process role`, chantier behavior, report modes, stop conditions, validation, and canonical path loading.
- Preserve public site schema when renaming `shipglows-site/src/content/skills/*.md`.
- Preserve plugin pack semantics and all pack references.
- Do not use search/replace over historical evidence directories.
- Dirty worktree exists from the current SEO/domain-router migration; implementation must not revert unrelated changes.
- Fresh external docs are not needed because this is an internal ShipGlows taxonomy and documentation migration.

## Test Contract

Proof path: scenario-first plus mechanical validation.

Pressure scenarios:

- `SEO-DOMAIN-ROUTER`: `$406-sg-seo audit <page>` routes to SEO audit detail, while `$406-sg-seo launch` loads the launch playbook/checklist.
- `PUBLIC-SKILL-PAGE`: public site builds and exposes `/skills/sg-seo/` without the old `/skills/sg-audit-seo/` content source.
- `PACK-CATALOG`: plugin pack catalog points to renamed skills and does not list missing directories.
- `RUNTIME-SYNC`: current-user Claude/Codex symlinks resolve for renamed skills and stale old symlinks are absent or explicitly allowed as legacy aliases.
- `STALE-ACTIVE-REFERENCE`: active docs and skill references do not contain old names after each tranche, while historical dirs may.
- `AUTH-DOMAIN-ROUTER`: `$109-sg-auth debug <flow>` preserves current auth-debug behavior, while `$109-sg-auth verify <flow>` can route auth smoke proof without implying a bug investigation.

## Dependencies

- `skills/references/skill-code-index.md` defines code/name policy and must be updated for each rename.
- `skills/109-sg-auth-debug/SKILL.md` currently owns auth debug behavior and must become the source for the new `109-sg-auth` router contract.
- `tools/shipglows_sync_skills.sh` publishes runtime symlinks.
- `tools/skill_budget_audit.py` validates compact skill activation bodies.
- `tools/skill_code_index_lint.py` validates the code table after renames.
- `shipglows-site` Astro build validates public skill page slugs.
- `plugins/shipglows/assets/pack-catalog.json` and `plugins/shipglows/skills/shipglows/references/pack-catalog.md` define plugin pack membership.

## Invariants

- Numeric code remains stable.
- `name:` in `SKILL.md` must match the directory basename.
- Public `slug:` must match the new public skill name without numeric prefix.
- Long audit doctrine must not move back into top-level `SKILL.md`.
- Domain skills must choose a mode; audit is one possible mode, not the domain identity.
- Domain skills must choose a mode; debug is one possible mode, not the auth domain identity.
- Historical evidence may keep historical names.

## Links & Consequences

- `000-shipglows` and `302-sg-help` discoverability may need updates so users see domain-first commands.
- `007-sg-content`, `202-sg-repurpose`, `200-sg-redact`, and `201-sg-enrich` routing must use `406-sg-seo` for SEO review.
- Design routes must avoid duplicate ownership between `006-sg-design` and any renamed `502` helper.
- Public skill category labels may need a later review because `Audit & Improve` will contain fewer `sg-audit-*` names.
- Plugin packs must remain installable and not reference missing skill directories.

## Documentation Coherence

Update these live documentation surfaces during implementation:

- `README.md`
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
- `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- `shipglows_data/editorial/content-map.md`
- `shipglows_data/editorial/README.md`
- `skills/302-sg-help/references/help-catalog.md`
- `skills/references/skill-code-index.md`
- role references under `skills/references/operator-roles/`
- public skill content under `shipglows-site/src/content/skills/`
- plugin pack catalog files

Do not update:

- `CHANGELOG.md` as part of spec creation
- historical `shipglows_data/workflow/specs/**`
- historical `shipglows_data/workflow/archives/**`
- historical completed reviews/audits unless they are active routing inputs

## Edge Cases

- Old runtime symlink exists but source dir was renamed.
- Public page slug is renamed but related skills still link to the old slug.
- A skill directory is renamed but `name:` remains old.
- A reference frontmatter `linked_systems` still points to the old skill path.
- A pack catalog lists a missing skill after rename.
- Old name scan fails because historical specs contain old names; validation must distinguish active surfaces from history.
- Copy/copywriting names may need a separate naming decision rather than blind rename.
- Auth rename may touch auth-proof routing from browser, prod, deploy, and content docs; those references must be updated as active surfaces, not treated as history.

## Implementation Tasks

1. Finalize naming policy and mapping.
   - Files: this spec, `skills/references/skill-code-index.md`
   - Action: record which audit-named skills become domain routers, specialist review helpers, or historical exceptions.

2. Complete and verify SEO migration.
   - Files: `skills/406-sg-seo/**`, `shipglows-site/src/content/skills/sg-seo.md`, active docs and pack catalogs.
   - Action: ensure all active references use `406-sg-seo` / `sg-seo`; remove stale runtime symlinks; validate site build.

3. Migrate GTM.
   - Files: `skills/408-sg-audit-gtm/**`, `shipglows-site/src/content/skills/sg-audit-gtm.md`, active references.
   - Action: rename to `skills/408-sg-gtm`, update `name:`, public slug `sg-gtm`, references, pack catalogs, help docs, runtime symlinks; keep mode `audit` in the skill.

4. Migrate i18n/translation.
   - Files: `skills/407-sg-audit-translate/**`, public skill page, active references.
   - Action: rename to `407-sg-translate`, expose modes `audit`, `sync`, `apply` as appropriate, and move long workflow detail into references if still top-heavy.

5. Migrate accessibility.
   - Files: `skills/409-sg-audit-a11y/**`, public skill page, active references.
   - Action: rename to `409-sg-a11y`, expose mode `audit`, preserve accessibility proof and WCAG references.

6. Migrate design-token and component specialists.
   - Files: `skills/503-sg-audit-design-tokens/**`, `skills/504-sg-audit-components/**`, public pages, active references.
   - Action: rename to `503-sg-design-tokens` and `504-sg-components`; keep audit/deep-audit as modes or references.

7. Decide and implement the design audit lane.
   - Files: `skills/006-sg-design/**`, `skills/502-sg-audit-design/**`, public pages, help docs.
   - Action: either absorb `502` into `006-sg-design audit` or rename `502` to a non-audit specialist helper such as `502-sg-design-review`; document the final route.

8. Align the already-consolidated code lane and decide the copy lanes.
   - Files: `skills/010-sg-technical/SKILL.md`, `skills/010-sg-technical/references/technical-audit-playbook.md`, `skills/206-sg-audit-copy/**`, `skills/207-sg-audit-copywriting/**`, public pages, routing docs.
   - Action: preserve `$010-sg-technical audit <target>` as the exact code/security audit route; choose domain-first or review-helper names only for the separate copy lanes, then migrate those lanes after their route is unambiguous.

9. Migrate auth debug to auth domain router.
   - Files: `skills/109-sg-auth-debug/**`, public skill page if present, help docs, routing docs, skill code index, runtime symlinks.
   - Action: rename to `109-sg-auth`, keep current auth debug behavior as mode `debug`, add mode routing for `audit`, `setup`, `verify`, and `fix` only where existing doctrine or owner routing supports it, and move long auth debug detail to references if needed.

10. Update runtime and plugin packaging.
   - Files: runtime symlinks, pack catalogs.
   - Action: run `shipglows_sync_skills.sh --repair --skill <new-name>` for each rename, remove stale old symlinks, then run `--check --all`.

11. Validate and close the tranche.
    - Files: all changed files.
    - Action: run validation commands listed below, fix failures, then route to `/103-sg-verify`.

## Acceptance Criteria

- [ ] Every renamed skill directory, `name:` field, public slug, help entry, pack catalog entry, and code-index row agrees.
- [ ] Active docs and references use the new domain-first names.
- [ ] Historical specs/changelog/archives are left intact unless they are active routing inputs.
- [ ] Each renamed audit-domain skill exposes `audit` as a mode or clearly routes audit intent through a domain router.
- [ ] `109-sg-auth` exposes `debug` as a mode and preserves the current auth-debug behavior contract.
- [ ] Long mode detail is in skill-local references, shared references, playbooks, or checklists, not in the activation body.
- [ ] `tools/skill_code_index_lint.py` passes.
- [ ] `tools/skill_budget_audit.py --skills-root skills --format markdown` passes with 0 hard violations and 0 warnings.
- [ ] `tools/shipglows_sync_skills.sh --check --all` passes.
- [ ] `pnpm --dir shipglows-site build` passes after public skill page changes.
- [ ] A stale-name scan over active surfaces finds no old names for the completed tranche.

## Test Strategy

Run after each tranche:

```bash
python3 tools/skill_code_index_lint.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
python3 tools/shipglows_metadata_lint.py <changed-frontmatter-docs-and-references>
pnpm --dir shipglows-site build
```

Run a stale active-name scan, excluding historical evidence:

```bash
rg -n "<old-name>|<old-public-slug>" . \
  --glob '!CHANGELOG.md' \
  --glob '!skills/REFRESH_LOG.md' \
  --glob '!shipglows_data/workflow/specs/**' \
  --glob '!shipglows_data/workflow/archives/**' \
  --glob '!shipglows_data/workflow/reviews/**' \
  --glob '!shipglows_data/workflow/audits/**' \
  --glob '!conversation-*.md' \
  --glob '!node_modules/**' \
  --glob '!*.lock'
```

## Current Chantier Flow

100-sg-spec ✅ -> 101-sg-ready ⏳ -> 102-sg-start ⏳ -> 103-sg-verify ⏳ -> 104-sg-end ⏳ -> 005-sg-ship ⏳

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-29 09:42:00 UTC | 100-sg-spec | GPT-5 Codex | Created migration spec for renaming audit-named domain skills and extracting audit doctrine into references/playbooks/checklists. | draft | `/101-sg-ready audit-skill-domain-mode-taxonomy-migration` |
