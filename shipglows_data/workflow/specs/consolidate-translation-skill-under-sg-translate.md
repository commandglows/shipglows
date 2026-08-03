---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-08-03"
created_at: "2026-08-03 22:15:35 UTC"
updated: "2026-08-03"
updated_at: "2026-08-03 22:52:24 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "translation-skill-domain-mode-compaction"
owner: Diane
user_story: "En tant qu’opératrice ShipGlows, je veux une seule skill métier `407-sg-translate` avec des modes explicites et des playbooks ciblés, afin d’auditer ou synchroniser une localisation sans charger une activation monolithique ni chercher une commande nommée d’après une seule opération."
risk_level: medium
security_impact: none
docs_impact: yes
confidence: high
linked_systems:
  - "skills/407-sg-audit-translate/"
  - "skills/407-sg-translate/"
  - "skills/references/skill-code-index.md"
  - "skills/references/skill-invocation-registry.json"
  - "skills/302-sg-help/references/help-catalog.md"
  - "skills/400-sg-audit/references/audit-master-workflow.md"
  - "plugins/shipglows/assets/pack-catalog.json"
  - "plugins/shipglows/skills/shipglows/references/pack-catalog.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "/home/claude/shipglows_app/site/src/content/skills/"
  - "tools/shipglows_sync_skills.sh"
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.5.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Operator approval on 2026-08-03 to start the next compaction pass after the audit identified 407-sg-audit-translate as the highest-value remaining monolith."
  - "skills/407-sg-audit-translate/SKILL.md is 430 lines and contains activation, audit doctrine, sync doctrine, report templates, tracking writes, language-quality rules, and workspace orchestration in one file."
  - "skills/407-sg-audit-translate/ currently has no skill-local references or playbooks; only SKILL.md and README.md exist."
  - "The broader draft audit-skill-domain-mode-taxonomy-migration.md already records the approved domain-first mapping 407-sg-audit-translate -> 407-sg-translate; this spec isolates the translation tranche without modifying that historical broad draft."
  - "Active consumers currently expose the old identity in the skill code index, help catalog, audit master workflow, technical routing, quality pack catalogs, operator cheatsheet, shipglows_data/CLAUDE.md, and the public skill page sg-audit-translate.md."
next_step: "none"
---

# Title

Consolidate Translation Skill Under `407-sg-translate`

## Status

Closed and shipped after independent excellence verification. The public discovery update was isolated in its consumer repository before the canonical ShipGlows source, runtime, test, and closure records were published.

## User Story

En tant qu’opératrice ShipGlows, je veux une seule skill métier `407-sg-translate` avec des modes explicites et des playbooks ciblés, afin d’auditer ou synchroniser une localisation sans charger une activation monolithique ni chercher une commande nommée d’après une seule opération.

## Minimal Behavior Contract

`407-sg-translate` accepts an explicit localization intent, chooses exactly one mode, and loads only the doctrine needed for that mode: `audit` examines one path, one project, or the applicable multilingual workspace; `sync` adds clearly mapped missing localized entries and then verifies their safety. A bare invocation preserves the current project-audit behavior, and legacy input `apply [scope]` remains a documented alias of `sync [scope]` rather than a duplicate workflow. Invalid or materially ambiguous input produces the supported grammar and no file mutation; ambiguous or business-sensitive translations remain unchanged and observable for review.

## Success Behavior

- `407-sg-translate audit` audits the current project; `audit <path>` scopes the audit to a file, folder, page, or content surface; `audit global` preserves the current multi-project selection and audit behavior.
- A bare `407-sg-translate` invocation deterministically defaults to `audit` on the current project, preserving the old empty-argument behavior.
- `407-sg-translate sync [scope]` preserves missing-key/content synchronization, placeholder integrity, post-sync counts, technical i18n checks, and ambiguity safeguards.
- `407-sg-translate apply [scope]` resolves to the same `sync` playbook and is documented as an accepted compatibility alias, not as another mode or runtime skill.
- The activation contract becomes a compact dispatcher that loads one local playbook and only the conditional shared references required by the selected operation.
- Claude/Codex runtime discovery, plugin packs, help, public documentation, the audit master, and the numeric code index expose `407-sg-translate`; active surfaces no longer expose the retired identity.
- Historical specs, audits, reviews, changelogs, and fixtures that quote historical inventories keep the old name as evidence.

## Error Behavior

- If input cannot be classified safely as `audit`, `sync`, the `apply` alias, or a preserved shorthand, report the accepted grammar and make no changes.
- If a path shorthand is provided without an explicit mode, preserve current behavior by treating it as `audit <path>`; never infer `sync` from a path alone.
- If `global` is requested from a workspace whose applicable projects cannot be determined, report the evidence gap and do not launch arbitrary project work.
- If source locale, locale mapping, placeholders, terminology authority, or business meaning is ambiguous during `sync`, leave the affected entry unchanged, list it for review, and continue only with independent low-risk entries.
- If rename targets or runtime links conflict with non-symlink content, stop before overwriting and report the exact path.
- If active old-name references remain after migration, validation fails; historical evidence is allowlisted rather than rewritten.
- Never log secrets, rewrite non-empty translations by default, alter locale URL strategy, or broaden tracker writes beyond the selected project/scope.

## Problem

The current skill encodes the operation `audit` in its public identity even though it also performs controlled translation synchronization. Its 430-line `SKILL.md` mixes dispatcher logic, page/project/global audit procedures, mutation safeguards, report templates, language-quality doctrine, workspace orchestration, and operational tracking. This weakens domain-first discoverability and causes every activation to carry instructions that are irrelevant to the selected operation.

## Solution

Keep numeric code `407`, rename the domain to `407-sg-translate`, and reduce `SKILL.md` to the activation, routing, lifecycle, boundary, and validation contract. Define two canonical public modes—`audit` and `sync`—with `apply` as a documented alias to `sync`, then migrate detailed behavior into bounded skill-local playbooks and a reusable translation-quality reference. Update every active runtime, plugin, help, audit-router, operator, public-site, and test surface in the same migration; retire the old directory only after replacement proof passes.

## Scope In

- Rename `skills/407-sg-audit-translate/` to `skills/407-sg-translate/` while keeping numeric code `407`.
- Replace the frontmatter identity with `name: 407-sg-translate` and a domain-first description.
- Define exact routing grammar:
  - bare invocation -> `audit` current project;
  - `audit` -> current project;
  - `audit <path-or-scope>` -> scoped page/content audit;
  - `audit global` and preserved shorthand `global` -> workspace audit;
  - preserved shorthand `<existing-path>` -> `audit <existing-path>`;
  - `sync [path-or-scope]` -> controlled missing-translation synchronization;
  - `apply [path-or-scope]` -> alias to `sync [path-or-scope]`;
  - `help` -> grammar, mode boundaries, and examples without loading an execution playbook.
- Create skill-local layered doctrine:
  - `skills/407-sg-translate/references/audit-playbook.md` for page, project, and global audit flows, scoring, reporting, orchestration, and audit-specific proof;
  - `skills/407-sg-translate/references/sync-playbook.md` for source-locale selection, matrix building, safe mutation, ambiguity handling, and post-sync proof;
  - `skills/407-sg-translate/references/translation-quality-reference.md` for shared completeness, terminology, formatting, placeholders, cultural/brand rules, French typography, technical SEO/i18n invariants, and report fields used by both modes.
- Preserve conditional chantier tracking and the existing `source-de-chantier` role while keeping operational record writes concurrency-safe and project-local.
- Update the skill README and all active internal consumers identified by the migration inventory.
- Rename the public page `/home/claude/shipglows_app/site/src/content/skills/sg-audit-translate.md` to `sg-translate.md`, update slug/title/prompts/modes/related links, and validate the public collection/build.
- Update plugin pack catalogs, the numeric index, runtime links, help/catalog surfaces, operator docs, and the audit master route.
- Add a deterministic translation contract test covering grammar, reference loading, preserved rules, active surface alignment, retirement, and historical allowlisting.
- Record refresh/closure/changelog evidence through their owning lifecycle stages after implementation and verification.

## Scope Out

- Do not modify `shipglows_data/workflow/specs/audit-skill-domain-mode-taxonomy-migration.md`; it remains the broad historical/draft source from which this tranche was derived.
- Do not rename or compact `400-sg-audit`, `406-sg-seo`, `009-sg-marketing`, `007-sg-content`, or any other skill.
- Do not change code `407`, renumber adjacent skills, or create a second translation skill.
- Do not create a runtime compatibility wrapper or duplicate picker entry for `407-sg-audit-translate`.
- Do not redesign translation algorithms, add machine-translation providers, rewrite existing non-empty translations, or change project locale/slug strategy.
- Do not merge localized copy persuasion, SEO-domain ownership, editorial drafting, or documentation ownership into `407`; preserve handoffs to `009`, `406`, `007`/`200`, and `300`.
- Do not rewrite historical specs, audits, reviews, archives, changelogs, transcripts, or historical fixture strings solely to erase the old name.
- Do not use this migration to normalize unrelated ShipGlows naming or packaging debt.

## Constraints

- `SKILL.md` remains a short activation contract; mode procedure, matrices, examples, and report templates live in the three local references.
- Local playbooks may link to authoritative shared contracts but must not fork canonical paths, chantier tracking, reporting, operational record, question, or decision-quality doctrine.
- One invocation selects one mode. Audit must remain read-only unless a user or active chantier explicitly authorizes remediation; sync is the only localization mode that mutates project content by default.
- `apply` is an alias to `sync`, not a third public mode and not a second implementation path.
- Active current documentation must migrate; historical evidence must remain factually intact.
- Rename and retirement must be staged: create replacement, update consumers, prove parity, then retire the old directory/runtime link/public source.
- External documentation freshness is not required: this is an internal skill taxonomy and instruction-layering migration with no framework, API, SDK, provider, or localization-library contract change.
- Preserve unrelated dirty work and stage only reviewed files from this chantier.

## Test Contract

Profile: Markdown/YAML/JSON skill-runtime and public-content migration with filesystem/runtime links; no production data, auth, provider, or user-facing application logic changes.

- `surface`: canonical skill source, shared routing/index/help docs, plugin catalogs, current-user Claude/Codex runtime links, and the public ShipGlows skill collection.
- `proof_profile`: automated contract and migration checks first, followed by bounded manual review of public-page readability/discoverability and the source-to-target rule matrix.
- `proof_order`: dispatcher scenarios -> rule-parity matrix -> active-surface/runtime/package checks -> public collection validation -> final diff and historical allowlist review.
- `checklist_path`: none; the scenario table below is the bounded executable checklist and must be recorded by scenario ID.
- `required_scenario_ids`: `TR-AUDIT-BARE`, `TR-AUDIT-PATH`, `TR-AUDIT-GLOBAL`, `TR-SYNC-SAFE`, `TR-APPLY-ALIAS`, `TR-SYNC-AMBIGUOUS`, `TR-INVALID`, `TR-BOUNDARY`, `TR-ACTIVE-SURFACES`, `TR-HISTORY`, `TR-RUNTIME`.
- `required_results`: one recorded pass/fail result per required scenario, source-to-target coverage for every executable source rule, zero active stale identities, valid runtime links, valid plugin catalogs, and a passing public collection/build check.
- `exception_with_proof`: an unavailable public build may be reported only with the exact environment/toolchain failure plus successful content-schema/collection validation and direct source/slug/link evidence.
- `exception_without_proof`: not allowed for routing, mutation safety, identity retirement, runtime publication, plugin membership, or active-surface alignment.

Ordered proof path:

1. Run deterministic scenario tests against the dispatcher and exact mode-to-reference mapping.
2. Compare every current `407` rule against its target activation/playbook/reference location; no behavioral rule may disappear silently.
3. Run focused metadata, skill audit, budget, code-index, JSON/catalog, runtime-sync, stale-name, and filesystem-retirement checks.
4. Build or validate the public ShipGlows skill collection after the page rename.
5. Review the final diff and historical allowlist before independent `103-sg-verify`.

Pressure scenarios:

| ID | Given | When | Then | Proof |
| --- | --- | --- | --- | --- |
| `TR-AUDIT-BARE` | A multilingual project is the current root | `407-sg-translate` is invoked without arguments | Exactly `audit` project mode loads; no sync mutation occurs | Contract test asserts default and reference set |
| `TR-AUDIT-PATH` | A valid localized file/path exists | `audit <path>` or preserved `<path>` shorthand is used | Only the target surface is audited with completeness, quality, hardcoded-string, formatting, and technical-i18n checks | Dispatcher test plus rule matrix |
| `TR-AUDIT-GLOBAL` | Several applicable multilingual projects are discoverable | `audit global` or `global` is used | Project selection and bounded per-project read-only audit are preserved; no tracker/code mutation is delegated | Scenario test plus audit playbook review |
| `TR-SYNC-SAFE` | A source locale and unambiguous missing entries exist | `sync [scope]` is used | Missing entries are added, tokens/tags are preserved, and before/after counts plus touched files are reported | Sync fixture/contract assertions |
| `TR-APPLY-ALIAS` | The operator uses legacy input wording | `apply [scope]` is used | It resolves to the exact `sync` playbook without a duplicate mode or skill | Alias assertion |
| `TR-SYNC-AMBIGUOUS` | A translation is business-sensitive or mappings/terms conflict | sync reaches the entry | The entry stays unchanged and appears in the ambiguous-items report | Negative scenario assertion |
| `TR-INVALID` | Input is neither a supported mode nor a valid preserved shorthand | the dispatcher parses it | It reports grammar and loads no execution playbook | Negative dispatcher assertion |
| `TR-BOUNDARY` | The request is persuasion, SEO, drafting, or docs rather than translation/i18n | routing evaluates ownership | It hands off to the established owner and does not absorb the task | Boundary matrix assertion |
| `TR-ACTIVE-SURFACES` | The implementation is complete | active internal/public/plugin/runtime surfaces are scanned | All expose `407-sg-translate`/`sg-translate`; none expose the retired identity | Focused active scan |
| `TR-HISTORY` | Historical records contain the old factual name | the stale-name scan runs | Historical occurrences remain untouched and are classified through a reviewed allowlist | Allowlist review |
| `TR-RUNTIME` | Source directory and runtime links are synchronized | Claude/Codex discovery is checked | New links resolve to `407-sg-translate`; the retired link is absent | Runtime sync and link checks |

Manual proof is limited to public-page readability/discoverability and final source-to-target rule review; all routing, filenames, references, catalogs, and retirement requirements must have automated proof. No browser-auth, provider, production, or device proof applies because this migration has no such runtime surface.

## Dependencies

- `skills/references/skill-code-index.md` is the authoritative numeric/name registry.
- `skills/references/skill-invocation-registry.json` must accept the new explicit identity and reject the retired one before the skill-local grammar takes over.
- `skills/references/skill-instruction-layering.md` and `skills/references/skill-execution-fidelity.md` govern compact activation contracts and preservation of executable detail.
- `skills/references/canonical-paths.md`, `chantier-tracking.md`, `reporting-contract.md`, and `operational-record-format.md` remain shared authorities loaded conditionally by the new skill.
- `tools/shipglows_sync_skills.sh` owns current-user Claude/Codex runtime publication and stale-link repair.
- `plugins/shipglows/assets/pack-catalog.json` and the plugin-local pack catalog define quality-pack membership.
- `/home/claude/shipglows_app/site/src/content/skills/` is the observed canonical public skill-content surface for this environment.
- Fresh external docs: not needed; no external library or service behavior changes.

## Invariants

- Numeric code `407` and the translation/i18n domain remain stable.
- Directory basename, `SKILL.md` frontmatter `name`, index row, runtime link target, plugin membership, help invocation, and public slug agree.
- Canonical modes are exactly `audit` and `sync`; `help` is discovery-only and `apply` is an input alias to `sync`.
- Bare and valid path-only invocations preserve current audit behavior.
- All existing page, project, global, and sync safeguards remain reachable after compaction.
- Placeholder/token/HTML/component-marker integrity, brand-name preservation, project terminology/tone, French accents/typography, locale formatting, `lang`, `hreflang`, canonical, sitemap, and localized metadata rules remain present.
- Audit remains non-mutating unless remediation is separately authorized; sync never rewrites existing non-empty translations by default.
- Ambiguous translations require visible review rather than silent invention.
- Historical evidence keeps historical names; active routing does not.

## Links & Consequences

- `400-sg-audit` must load `407-sg-translate` in `audit` mode and its audit playbook, not depend on an obsolete monolithic section heading.
- `010-sg-technical` and its router must continue to exclude translation/i18n from technical ownership while naming the new domain owner.
- `302-sg-help`, `shipglows_data/CLAUDE.md`, and the operator cheatsheet must teach the exact new grammar, including the `apply` alias without presenting it as a separate mode.
- The quality plugin pack keeps translation capability under the renamed skill and must remain installable.
- The public site changes canonical skill slug from `sg-audit-translate` to `sg-translate`; current active internal links must point to the new page. No redirect is assumed or implemented unless an existing site route policy already generates one deterministically.
- Runtime sync removes the old picker identity; users may need a normal runtime reload after link repair, but reload does not justify retaining a wrapper.
- `009-sg-marketing copy`, `406-sg-seo`, `007-sg-content`/`200-sg-redact`, and `300-sg-docs` remain separate owners for persuasion, SEO, drafting/editorial lifecycle, and documentation.

## Documentation Coherence

Implementation must update these active surfaces where the focused inventory confirms an old-name occurrence:

- `skills/407-sg-translate/README.md`
- `skills/references/skill-code-index.md`
- `skills/references/skill-invocation-registry.json`
- `skills/302-sg-help/references/help-catalog.md`
- `skills/400-sg-audit/references/audit-master-workflow.md`
- `skills/010-sg-technical/SKILL.md`
- `skills/010-sg-technical/references/technical-router.md`
- `plugins/shipglows/assets/pack-catalog.json`
- `plugins/shipglows/skills/shipglows/references/pack-catalog.md`
- `shipglows_data/CLAUDE.md`
- `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
- `/home/claude/shipglows_app/site/src/content/skills/sg-translate.md` replacing `sg-audit-translate.md`
- `/home/claude/shipglows_app/site/src/content/skills/sg-technical.md` for its related-skill handoff
- any additional active, non-historical consumer discovered by the implementation-time focused scan

`skills/REFRESH_LOG.md`, `CHANGELOG.md`, task tracking, and spec history are updated only by their owning refresh/closure stages. Historical broad specs, audits, reviews, archived inventories, and historical test fixtures are not rewritten.

## Edge Cases

- A path begins with a token that resembles a mode; exact supported mode tokens take precedence, while path-only shorthand must resolve only when the path/scope is valid.
- A user writes `global` without `audit`; preserve it as shorthand for `audit global`.
- A user writes `apply` expecting mutation; preserve the behavior but report the canonical mode as `sync`.
- A project has locale routes but no translation files, or translation files but no locale routes; audit must classify the architecture instead of assuming a single i18n pattern.
- Source locale is not configured; sync may choose the highest-coverage locale only when evidence is unambiguous and must report the inference.
- Placeholders differ structurally across locales; the target entry must not be written as a low-risk sync.
- A content counterpart has no reliable locale ID/slug mapping; report it as ambiguous rather than fabricate a file or slug.
- Global audit runs in a workspace with concurrent project changes; workers remain read-only and do not update trackers or code.
- An old runtime link is a real directory or points outside the canonical source; stop rather than overwrite or delete it automatically.
- Public page rename succeeds but related links or generated collection indexes still use the old slug; public validation fails until active links agree.
- Old names remain inside the broad source spec, completed audits, reviews, or historical fixture strings; these are expected history, not active drift.

## Implementation Tasks

- [x] Task 1: Freeze the current-rule inventory and active/historical old-name classification.
  - Files: `skills/407-sg-audit-translate/SKILL.md`, `README.md`, all focused `rg` hits, and this spec for execution evidence only.
  - Action: map every executable rule to the future dispatcher, audit playbook, sync playbook, translation-quality reference, shared authority, or explicit retirement; classify every old-name occurrence as active or historical before renaming.
  - User story link: guarantees that compaction removes bulk without removing capability.
  - Depends on: none.
  - Validate with: reviewed source-to-target rule matrix and active/historical inventory.

- [x] Task 2: Build the compact domain dispatcher and layered local doctrine.
  - Files: `skills/407-sg-translate/SKILL.md`, `skills/407-sg-translate/references/audit-playbook.md`, `sync-playbook.md`, `translation-quality-reference.md`.
  - Action: implement the exact grammar, conditional loaders, boundaries, lifecycle behavior, stop conditions, and validation; migrate procedure/checklist/report detail into the correct local file without duplication.
  - User story link: makes one short domain skill capable of selecting the exact translation operation.
  - Depends on: Task 1.
  - Validate with: dispatcher pressure scenarios, reference-link checks, line/token budget, and source-to-target matrix.

- [x] Task 3: Add deterministic migration and behavior contract proof.
  - Files: `tools/test_407_sg_translate_contract.py`; narrowly update `tools/test_010_sg_technical_contract.py` only where assertions represent current active ownership rather than historical fixture text.
  - Action: assert exact modes/defaults/aliases, conditional playbooks, preserved safety and language rules, owner boundaries, active catalog/index/help/public alignment, old-directory retirement, and historical allowlisting.
  - User story link: proves the compacted skill remains behaviorally complete and discoverable.
  - Depends on: Task 2.
  - Validate with: `python3 tools/test_407_sg_translate_contract.py` and relevant existing contract tests.

- [x] Task 4: Migrate active internal, plugin, operator, and public surfaces.
  - Files: the exact active documentation/coherence list above, plus current-user runtime links managed by `tools/shipglows_sync_skills.sh`.
  - Action: replace the old runtime/public identity with `407-sg-translate`/`sg-translate`, add explicit `audit`/`sync` examples, preserve `apply` only as a sync alias, and update pack membership and adjacent-owner handoffs.
  - User story link: removes competing/stale discovery paths everywhere the operator or an agent searches.
  - Depends on: Tasks 2-3.
  - Validate with: code-index lint, catalog JSON/pack audit, help/public metadata checks, runtime sync check, and public collection/build.

- [x] Task 5: Retire old source and public identities after replacement proof.
  - Files: `skills/407-sg-audit-translate/`, `/home/claude/shipglows_app/site/src/content/skills/sg-audit-translate.md`, and old Claude/Codex runtime links.
  - Action: remove old identities only after Tasks 2-4 pass; keep no wrapper skill or duplicate public source.
  - User story link: ensures the picker and public catalog expose one translation métier.
  - Depends on: Task 4.
  - Validate with: filesystem/link absence and active stale-name scan with reviewed historical allowlist.

- [x] Task 6: Run independent excellence verification and close the bounded tranche.
  - Files: all changed chantier files, this spec history/status, owning trackers/changelog/refresh log as required by `103`, `104`, `005`, and `900` contracts.
  - Action: run the full Test Strategy, repair migration-scoped failures, review the final diff, then complete closure bookkeeping without absorbing unrelated work.
  - User story link: turns the architectural improvement into a verified, durable capability ready for bounded publication.
  - Depends on: Tasks 1-5.
  - Validate with: recorded `103-sg-verify` evidence, closed lifecycle state, aligned documentation reflection, and changelog wording bounded to verified local migration proof.

- [x] Task 7: Ship the bounded verified tranche.
  - Files: reviewed implementation and closure scope only.
  - Action: isolate the translation-consolidation changes from concurrent work, then commit and push without force.
  - User story link: publishes the verified capability without absorbing unrelated changes.
  - Depends on: Task 6.
  - Validate with: public consumer commit `66dd216` (`docs(skills): publish sg-translate`) pushed non-force to `shipglows_app/main`; bounded canonical commit/push, post-ship scope/status evidence, and preserved unrelated public-repository changes.

## Acceptance Criteria

- [x] CA 1: Given the migration is complete, when skills are discovered, then code `407`, directory name, `name:`, runtime link, index, plugin catalog, help command, and public slug all identify `407-sg-translate`/`sg-translate`.
- [x] CA 2: Given a bare invocation, when `407-sg-translate` routes it, then it selects project `audit` and performs no sync mutation.
- [x] CA 3: Given `audit`, `audit <path>`, `audit global`, `global`, or a valid path shorthand, when routing occurs, then exactly the matching audit scope runs through `audit-playbook.md`.
- [x] CA 4: Given `sync [scope]`, when localization gaps are unambiguous, then missing entries are added with placeholders/tags intact and before/after/touched/ambiguous proof is reported.
- [x] CA 5: Given `apply [scope]`, when routing occurs, then it uses exactly the `sync` implementation and is not exposed as a third canonical mode.
- [x] CA 6: Given an ambiguous, business-sensitive, terminology-conflicting, placeholder-unsafe, or unmapped entry, when sync evaluates it, then the entry remains unchanged and is reported for review.
- [x] CA 7: Given invalid or materially ambiguous input, when the dispatcher cannot select safely, then it reports the accepted grammar and loads no execution playbook or mutation path.
- [x] CA 8: Given any former executable rule in the 430-line source, when the source-to-target matrix is reviewed, then it has one authoritative destination or an explicit justified retirement; no audit/sync/language-quality/tracking safeguard disappears silently.
- [x] CA 9: Given persuasion, SEO, drafting/editorial, or docs intent, when ownership is evaluated, then `407` preserves the established adjacent-owner handoff instead of absorbing the task.
- [x] CA 10: Given active current surfaces after migration, when scanned for `407-sg-audit-translate` or `sg-audit-translate`, then no active occurrence remains; historical evidence remains intact and allowlisted.
- [x] CA 11: Given runtime synchronization after source retirement, when Claude/Codex skill links are checked, then `407-sg-translate` resolves to the canonical source and the old runtime identity is absent without a wrapper.
- [x] CA 12: Given the compacted skill corpus, when metadata lint, contract tests, skill audit, budget audit, code-index lint, runtime sync, plugin pack validation, stale-name checks, and public build/collection checks run, then every migration-scoped check passes.

## Test Strategy

Run scenario-first proof before broad mechanical checks:

```bash
python3 tools/test_407_sg_translate_contract.py
python3 -m unittest tools.test_010_sg_technical_contract
```

Run governed metadata and skill-quality checks over the exact changed Markdown set:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/consolidate-translation-skill-under-sg-translate.md skills/407-sg-translate/references
python3 tools/audit_shipglows_skills.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/skill_code_index_lint.py
```

Run runtime and packaging checks after the rename/repair:

```bash
tools/shipglows_sync_skills.sh --check --all
jq empty plugins/shipglows/assets/pack-catalog.json
python3 plugins/shipglows/scripts/audit_shipglows_packaging.py
```

Run the public-site check from `/home/claude/shipglows_app/site` using the repository-declared package command (inspect `package.json` first); record an environment/toolchain gap rather than substituting an unrelated build. Verify the new `sg-translate` source/slug and absence of the retired public source.

Run an active old-name scan that includes source skills, current shared references, plugin catalogs, operator/current technical docs, tests that assert current behavior, and public skill content, while excluding only reviewed historical specs, audits, reviews, archives, changelog entries, transcripts, and explicit historical fixtures. Review `git diff --check`, `git status --short`, and the final scoped diff before closure.

## Risks

- Compaction can silently drop a rare page/global/sync rule; mitigate with the complete source-to-target matrix and contract assertions before retirement.
- `apply` can accidentally become a duplicate public mode or disappear; mitigate by specifying and testing it only as a `sync` alias.
- A short dispatcher can eagerly load all references and recreate the context problem indirectly; mitigate by asserting one execution playbook per invocation and loading the shared quality reference only when required by that playbook.
- Splitting doctrine too finely can create an untraceable puzzle; mitigate by keeping exactly two operation playbooks and one cross-mode quality reference, each with one declared responsibility.
- Global audit currently mixes orchestration and historical tracker-writing wording; migration could cause concurrent writes or unauthorized mutation. Preserve audit workers as read-only and centralize any separately authorized operational record write after results return.
- Public, plugin, help, index, runtime, or adjacent-owner drift can leave dead commands after rename; mitigate with active-surface assertions and staged retirement.
- Blanket replacement could rewrite historical evidence or current fixture inputs that intentionally describe legacy inventories; mitigate with an explicit active/historical classification.
- Concurrent unrelated changes may overlap active docs; implementation must stop on unresolved overlapping hunks rather than overwrite them.

## Execution Notes

- Read first: `skills/407-sg-audit-translate/SKILL.md`, its `README.md`, `skills/references/skill-instruction-layering.md`, `skills/references/skill-execution-fidelity.md`, `skills/006-sg-design/SKILL.md` plus its local playbook layout as the compaction precedent, and the active consumers listed under Documentation Coherence.
- Implement in this order: freeze rule/reference inventory -> create renamed dispatcher and three local references -> add contract tests -> migrate internal/plugin/public/runtime consumers -> prove replacement -> retire old identities -> run full verification.
- Keep the activation body focused on mission, exact mode detection, conditional references, ownership boundaries, chantier/report contract, stop conditions, and validation. Do not copy checklists, matrices, phase procedures, or report templates back into `SKILL.md`.
- Preserve shared authorities by links/loaders, especially canonical paths, reporting, chantier tracking, decision quality, questions, and operational record format.
- Treat the current source as behavioral evidence, not as ideal doctrine: repair contradictions such as global read-only workers versus tracker mutations by enforcing the safer observable invariant without broadening product behavior.
- Before any removal, prove new runtime and public identities plus all active consumers. If parity proof fails, fix the new contract/playbook; do not add a wrapper.
- Stop and return to `100-sg-spec` if implementation discovers a material change to locale strategy, automated translation/provider use, public redirect policy, adjacent-owner boundaries, or the exact canonical mode set.

## Open Questions

None. The operator approved proceeding, the existing broad taxonomy draft already fixes the domain-first identity, and the current behavior supports the bounded decision: canonical modes `audit` and `sync`, bare/path/global audit compatibility, and `apply` as a documented alias to `sync`.

## Documentation Reflection

Documentation reflection: updated — implementation aligned active skill, plugin, help, operator, and public discovery surfaces; this closure aligns the canonical spec and changelog. Fresh external documentation is not needed because no provider, framework, API, or localization-library contract changed.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-03 22:15:35 UTC | 100-sg-spec | GPT-5 Codex | Inspected the 430-line translation skill, its README, active routing/help/index/plugin/operator/public surfaces, the broad domain-mode draft, and prior design/marketing compaction patterns; created the bounded translation tranche without modifying the broad draft or implementation files. | Draft spec created with exact modes, layered target files, migration inventory, scenario-first proof, staged retirement, and no unresolved product decision. | `/101-sg-ready consolidate translation skill under sg-translate` |
| 2026-08-03 22:19:35 UTC | 101-sg-ready | GPT-5 Codex | Independently reviewed mode grammar, alias policy, domain boundaries, active/public/plugin/runtime surfaces, staged retirement, task ordering, language doctrine, and adversarial proof; corrected only the spec's dependency, proof fields, and explicit public consumer inventory. | Ready; no unresolved product, security, scope, or implementation decision remains. | `/102-sg-start consolidate translation skill under sg-translate` |
| 2026-08-03 22:33:55 UTC | 102-sg-start | GPT-5.6 Sol (high) | Migrated the 430-line operation-named skill into the compact `407-sg-translate` dispatcher, exactly two mode playbooks plus one shared quality reference; updated active internal, plugin, runtime, operator, test, and public surfaces; retired the former source/page/runtime identity after replacement proof. | implemented; 10 translation scenarios pass, the adjacent technical suite passes (14 run, one optional-site skip), skill/metadata/audit/budget/index/runtime/JSON/packaging hard gates pass, and public frontmatter/schema shape passes. The declared Astro build is deferred to independent verification because the available Node 22 runtime violates the site's Node 24 engine and `dist`/`.astro` pre-existed. | `/103-sg-verify consolidate translation skill under sg-translate` |
| 2026-08-03 22:45:11 UTC | 103-sg-verify | GPT-5.6 Sol (high) | Ran `mode=excellence` over all 12 acceptance criteria, former-rule transfer, exact audit/sync/apply/help routes, negative paths, active/history classification, runtime/index/help/plugin/public coherence, context layering, reporting, and portability. Repaired the missing explicit-invocation registry entry, restored the argument hint, aligned user/agent file-evidence wording, and corrected the adjacent test command before rerunning the full proof. | excellent; 11 translation scenarios and 26 adjacent invocation/technical tests pass (one optional checkout skip), 55-skill fidelity/budget and 110 runtime links pass, metadata/index/JSON/package hard gates pass, and the declared `pnpm build` completes with Node 24 in an isolated copy, generating `/skills/sg-translate` without touching pre-existing `dist` or `.astro`. The planned quality pack still reports its existing source-tree portability reviews, with zero hard findings and no migration regression. | `/104-sg-end consolidate translation skill under sg-translate` |
| 2026-08-03 22:48:28 UTC | 104-sg-end | GPT-5.6 Terra (high) | Applied the closure guard, reconciled the verified local migration with the canonical spec and changelog, confirmed no exact active tracker row required mutation, and recorded the documentation reflection. | closed locally; all 12 acceptance criteria and the declared isolated Node 24 public build remain evidenced, while Git commit/push is intentionally pending. | `/005-sg-ship consolidate translation skill under sg-translate` |
| 2026-08-03 22:52:24 UTC | 005-sg-ship | GPT-5.6 Terra (high) | Re-ran focused translation, adjacent technical, metadata, index, runtime, packaging, skill-audit, budget, diff, bug-link, secret, and remote-divergence gates; isolated the public consumer update as `66dd216` before publishing the bounded canonical dispatcher, playbooks, routing, plugin, test, changelog, and closure records. | shipped; public and canonical commits were pushed non-force to their respective `main` branches, with no linked high/critical bug, secret, runtime drift, or unrelated public-repository file included. | none |

## Current Chantier Flow

`100-sg-spec` ✅ complete -> `101-sg-ready` ✅ ready -> `102-sg-start` ✅ implemented -> `103-sg-verify` ✅ excellent -> `104-sg-end` ✅ closed locally -> `005-sg-ship` ✅ shipped

Next command: none
