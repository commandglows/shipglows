---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-07-16"
created_at: "2026-07-16 15:01:27 UTC"
updated: "2026-07-16"
updated_at: "2026-07-16 16:01:51 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: marketing-skill-surface-consolidation
owner: Diane
user_story: "As the ShipGlows operator, I use one public marketing skill with explicit modes for market study, GTM, copy, and copywriting without choosing among four overlapping skill entrypoints."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - skills/204-sg-market-study/SKILL.md
  - skills/206-sg-audit-copy/SKILL.md
  - skills/207-sg-audit-copywriting/SKILL.md
  - skills/408-sg-audit-gtm/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/references/content-owner-handoffs.md
  - skills/references/skill-code-index.md
  - plugins/shipglows/assets/pack-catalog.json
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows-site/src/content/skills/
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/content-owner-handoffs.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/task-registry-routing.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/design-inspiration-library.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "shipglows_data/technical/product-behavior-intelligence.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence:
  - "Operator decision 2026-07-16: apply the design-style compaction to the marketing tranche, with one skill and modes/playbooks."
  - "Current runtime exposes four public entrypoints: 204-sg-market-study, 206-sg-audit-copy, 207-sg-audit-copywriting, and 408-sg-audit-gtm."
  - "Each current specialist is already compact at its activation layer but duplicates discovery, routing, public pages, catalog entries, and operator choice."
  - "Current site contains four dedicated public skill pages; the plugin pack catalog, README, content router, help/runtime guidance, templates, and operator guides still name the retired skills."
next_step: "/005-sg-ship Consolidate Marketing Skills Under 009-sg-marketing"
---

# Spec: Consolidate Marketing Skills Under 009-sg-marketing

🟢 [ShipGlows] spec: Consolidate Marketing Skills Under 009-sg-marketing | status: ready | path: shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md | next: /005-sg-ship Consolidate Marketing Skills Under 009-sg-marketing

## Title

Consolidate Marketing Skills Under `009-sg-marketing`

## Status

Implementation, independent verification, and closure bookkeeping are complete. The local/runtime/public migration retains the explicit security/no-alias/old-URL requirements; bounded git shipping is the remaining lifecycle step.

## User Story

As the ShipGlows operator, I want one public marketing entrypoint with clear `market`, `gtm`, `copy`, and `copywriting` modes so that I can obtain the right strategic or audit workflow without memorizing four adjacent skills, while each mode keeps its own evidence, claim, routing, and follow-up safeguards.

## Minimal Behavior Contract

`009-sg-marketing` accepts one explicit mode—`market`, `gtm`, `copy`, or `copywriting`—plus its target, loads only the matching bounded playbook, and returns the same class of study or audit that its predecessor provided. Bare, invalid, or ambiguous input lists the four modes or asks one focused routing question; it must not guess between sentence-level copy and persuasion, or turn a market question into a GTM audit. Unsupported public claims, missing evidence, missing required context, or a missing playbook produce a visible blocked/limited result with no invented proof. The four retired skills have no permanent compatibility directories or aliases; active public, runtime, documentation, and routing surfaces use `009` mode syntax.

## Success Behavior

- `$009-sg-marketing market <niche|idea|question>` loads the market-study playbook for demand, competitors, keywords, monetization, brand/domain, AI visibility, and go/no-go reasoning.
- `$009-sg-marketing gtm <page|funnel|project>` loads the GTM playbook for positioning, offer, funnel, trust, analytics, launch readiness, and behavior-backed claims where applicable.
- `$009-sg-marketing copy <page|file|global>` loads the copy playbook for clarity, tone, readability, CTA, friction, claim evidence, trust, and public-surface coherence.
- `$009-sg-marketing copywriting <page|funnel|offer|project>` loads the copywriting playbook for persona, offer, objections, persuasive sequence, proof, conversion, and message-market fit.
- The `copy` / `copywriting` distinction stays explicit: `copy` answers “is this clear, credible, and usable?”; `copywriting` answers “does this offer persuade the intended buyer?” A target containing both concerns may be routed through the first mode named by the operator; only a genuinely material distinction triggers one question.
- Every mode preserves its conditional `source-de-chantier` posture, reporting contract, claim/proof stops, and durable-follow-up routing. Market and GTM modes retain conditional source-intake and product-behavior intelligence gates; copy and copywriting retain the rubric, task-registry, and bounded Inspiration Gate rules.
- `007-sg-content` remains the editorial lifecycle router. It routes marketing-quality work to the relevant `009` mode, not into a second marketing lifecycle or an implicit chain of all modes.
- Active public pages, runtime index, plugin pack catalog, help, launch guides, templates, README, technical workflow guidance, and related-skill references expose one public marketing identity. Historical evidence retains factual old names under a narrow allowlist.

## Error Behavior

- Bare `$009-sg-marketing`, an unknown mode, or `audit` without a `copy`, `copywriting`, or `gtm` subtype lists the valid modes and examples; it does not select a mode from the last task or silently audit all marketing layers.
- `market` stops or reports an evidence limit rather than inventing market size, keywords, competitors, pricing, revenue, demand, domains, customer feedback, or monetization facts.
- `gtm`, `copy`, and `copywriting` flag or block unsupported guarantees, testimonials, pricing, regulatory/security claims, conversion metrics, and product capabilities; they do not strengthen a public promise merely to improve persuasion.
- `copy` and `copywriting` route an actual writing, enrichment, docs, SEO, or email-sequence task to its existing owner when the requested action is outside the selected audit/remediation posture.
- `market` routes generic cited research to `203-sg-research`; `gtm`/`market` route raw URL/source triage to `205-sg-veille` when triage is the primary unmet need; SEO work stays with `406-sg-seo`; email sequence ownership stays with `emailing`.
- Missing migration evidence, missing local playbook, stale runtime link, unresolved active old invocation, invalid pack catalog, or incomplete public-page migration blocks retirement of the relevant source skill.
- Historical specs, audits, changelog records, evidence samples, archives, and source snapshots are not rewritten simply to remove factual old names; active instructions, runtime-visible names, and public discovery are the migration target.

## Problem

The operator’s marketing intent is fragmented across four public skills in two taxonomy bands: `204-sg-market-study`, `206-sg-audit-copy`, `207-sg-audit-copywriting`, and `408-sg-audit-gtm`. Their activation contracts are individually compact, but users must discover and choose among adjacent names before they can start. The public site, catalog, help, content router, operator guides, templates, technical lifecycle documentation, and related-skill links mirror that fragmentation. This is the same discoverability and maintenance burden already removed from the design surface, without a corresponding mode-based marketing owner.

## Solution

Create public `009-sg-marketing` as the single owner for the four adjacent marketing capabilities. Keep its `SKILL.md` as a compact mode dispatcher and migrate the four detailed procedures into one bounded playbook per mode. Update active routing and public discovery before retiring the four source directories and their runtime visibility. Preserve neighboring owners and shared doctrine rather than absorbing research, veille, SEO, email sequences, or the editorial lifecycle.

## Scope In

- New public `skills/009-sg-marketing/SKILL.md` with exact grammar: `market <target>`, `gtm <target>`, `copy <target>`, `copywriting <target>`, and `help`.
- Four local, separately loaded playbooks under `skills/009-sg-marketing/references/`, migrated from the market-study, GTM-audit, copy-audit, and copywriting-audit workflows.
- A source-to-mode completeness matrix covering source-specific gates, evidence expectations, reports, stop conditions, follow-up/chantier rules, validations, and conditional shared references.
- New mode routing in `007-sg-content`, `000-shipglows`, `302-sg-help`, `skills/references/content-owner-handoffs.md`, and other active handoff surfaces identified by the inventory.
- Replacement of the four source skill directories, code-index rows, current-user/runtime entries, catalog entries, public pages, public related-skill links, command examples, templates, and active technical/operator documentation with `009` modes.
- Active-reference scan policy and a narrow historical allowlist for existing specs, changelog entries, audits, evidence samples, archives, and one-time research records.
- New contract tests or extensions to existing tooling that prove the dispatcher grammar, mode/playbook selection, copy-vs-copywriting boundary, source completeness, no old runtime directory, active-stale-name policy, catalog validity, and public build integrity.

## Scope Out

- Absorbing `203-sg-research`, `205-sg-veille`, `406-sg-seo`, `emailing`, `007-sg-content`, `200-sg-redact`, `201-sg-enrich`, or `202-sg-repurpose` into `009`.
- Turning `009` into a general content lifecycle master: `007-sg-content` remains the editorial router and content-governance owner.
- Adding a generic `audit` mode that hides the meaningful `gtm`, `copy`, and `copywriting` decision.
- Inventing a fifth “strategy”, “research”, “SEO”, or “email” mode during this migration.
- Keeping permanent wrapper skills, duplicate picker entries, silent aliases, or compatibility directories for `204`, `206`, `207`, or `408`.
- Rewriting historical records merely to erase factual predecessor names.
- Changing the business, editorial, claim, rubric, source-intake, task-registry, Inspiration Gate, research, veille, SEO, or email-sequence policies beyond what is necessary to point active owners at `009` modes.

## Constraints

- The canonical public invocation owner is `009-sg-marketing`; the code reuses the retired, currently unassigned `009` slot and must be added as a valid runtime skill identity before deployment.
- Exact modes are `market`, `gtm`, `copy`, `copywriting`, and `help`; each substantive mode maps to exactly one local playbook.
- `009` must stay a compact activation contract and must not duplicate the four detailed workflow bodies, shared governance doctrine, provider trees, scoring tables, or templates.
- Preserve the distinction and boundaries of the four modes instead of simplifying by loss of capability. A new mode can route to existing shared references conditionally, but must not load all four playbooks for every request.
- Public invocation migration is sensitive: public pages, examples, related-skill references, plugin/catalog entries, help, routing docs, and operator guides must use canonical `009` syntax before source retirement.
- No public claim may become stronger, less evidenced, or less governed as a side effect of changing command names.
- `009` is public, unlike `900`; it must be included coherently in public catalog/site discovery and must not expose internal-only `900` maintenance semantics.
- Security impact is none because this change only relocates local skill contracts, runtime identities, and public documentation; it neither adds network calls, credentials, auth/authorization paths, telemetry, nor external data collection. Existing mode-level source, claim, redaction, and provider safeguards must be migrated intact, and no secret or private-source value may enter the new public page, catalog, examples, logs, or test fixtures.
- `009-sg-skill-build` remains factual historical evidence only. Its retired internal-maintenance identity must never become a `009-sg-marketing` alias, example, runtime entry, redirect, or active routing fallback.
- The four retired public skill pages are intentionally removed after the replacement page and inbound links validate. Their former URLs return the site’s normal not-found behavior; a redirect is out of scope unless an already-established site route policy requires one, in which case that policy must be recorded and validated without creating a runtime compatibility alias.
- Preserve clean, bounded staging: no unrelated dirty work, historical rewrite, or concurrent chantier artifact enters the later commit.

## Test Contract

Proof path: scenario-first, then source-completeness, active-surface, runtime/catalog, metadata, and public-site proof.

1. Dispatcher scenarios: valid `market`, `gtm`, `copy`, `copywriting`, and `help`; bare invocation; unknown mode; `audit` without subtype; missing target; and malformed code/name input.
2. Boundary scenarios: a clarity/CTA page selects `copy`; a persona/offer/objections request selects `copywriting`; a demand/competitor/monetization request selects `market`; a positioning/funnel/trust/launch request selects `gtm`; a generic research, raw source triage, SEO, and email-sequence request reroute to `203`, `205`, `406`, and `emailing` respectively.
3. Safety scenarios: unsupported claim, missing evidence, missing required business/brand context, absent selected reference, and public old invocation all fail visibly without invented facts or premature retirement.
4. Source-completeness comparison: every required source contract rule maps to the `009` dispatcher, exactly one local mode playbook, or a preserved shared reference. The comparison explicitly includes rubric/task-registry/Inspirational Gate differences and market/GTM source-intake/product-behavior conditions.
5. Active-surface proof: focused scans distinguish active execution/public references from approved historical evidence; no active occurrence of `204`, `206`, `207`, `408`, or the retired `009-sg-skill-build` identity remains after migration. The latter may remain only in the narrow historical allowlist and must never resolve as marketing compatibility.
6. Mechanical proof: metadata lint for all changed Markdown, `skill_budget_audit.py`, `audit_shipglows_skills.py`, `skill_code_index_lint.py`, `shipglows_sync_skills.sh --check --all`, JSON validation for the pack catalog, and relevant pack refresh/validation.
7. Public proof: direct Astro build plus the package build when its local toolchain permits; deleted public pages resolve out of collection/navigation while the new `sg-marketing` page, links, and examples build successfully. The former four public URLs use the site’s normal not-found behavior unless an established documented redirect policy applies.
8. Filesystem proof: four retired source directories and their runtime links are absent only after all migration and proof checks pass; `009` is present and listed exactly once.

## Dependencies

- `skills/references/skill-instruction-layering.md` — compact dispatcher/playbook placement rules.
- `skills/references/content-quality-rubric.md` — one scoring/status contract for `copy` and `copywriting`, preserving public-claim quality gates.
- `skills/references/source-intake-classification.md` — conditional source/competitor/marketplace and feedback classification for `market` and `gtm`.
- `skills/references/content-owner-handoffs.md` — shared owner matrix that must replace the four retired rows with mode-level routing.
- `skills/references/task-registry-routing.md` — correct editorial-roadmap versus execution-backlog follow-up behavior for audit findings.
- `skills/references/design-inspiration-library.md` — bounded Inspiration Gate for sales/offer/CTA/proof/objection work in `copy` and `copywriting`.
- `shipglows_data/technical/product-behavior-intelligence.md` — conditional behavior-to-value and GTM proof rules for `market` and `gtm`; it is draft, so implementation must preserve its confidence limitation rather than elevate it to a settled business claim.
- `skills/007-sg-content/references/content-router.md`, `skills/emailing/SKILL.md`, `skills/203-sg-research/SKILL.md`, `skills/205-sg-veille/SKILL.md`, and `skills/406-sg-seo/SKILL.md` — boundary and rerouting owners.
- Fresh external docs: `fresh-docs not needed`; this is a local skill-contract, documentation, runtime-index, and public-discovery migration. Future `market`, `gtm`, and claim-sensitive executions retain their existing source/freshness gates.

## Invariants

- One public marketing entrypoint: `009-sg-marketing`.
- Four explicit modes and four bounded playbooks: `market`, `gtm`, `copy`, and `copywriting`.
- `copy` and `copywriting` remain separate semantic decisions, not synonyms or two automatic passes.
- `007-sg-content` remains the editorial router; `203`, `205`, `406`, and `emailing` remain separate owners.
- No permanent compatibility source directory or hidden alias remains for `204`, `206`, `207`, or `408`.
- Historical evidence remains readable; active instructions and runtime/public discovery do not route to retired names.
- Claim evidence, product/brand/business coherence, source fidelity, scoring, task routing, and optional inspiration safeguards survive in the correct mode.
- A fresh agent can select and run the correct mode without reading a retired source directory.

## Links & Consequences

- Runtime and packaging: `skills/references/skill-code-index.md`, `plugins/shipglows/assets/pack-catalog.json`, `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, and current-user symlinks/manifests created by `tools/shipglows_sync_skills.sh` must replace four names with one public `009` entry.
- Primary routing/help: `skills/000-shipglows/SKILL.md`, `skills/302-sg-help/references/help-catalog.md`, `skills/007-sg-content/SKILL.md`, `skills/007-sg-content/references/content-router.md`, and `skills/references/content-owner-handoffs.md` must route to the exact mode rather than merely naming `009`.
- Adjacent owners: `skills/emailing/SKILL.md`, `skills/200-sg-redact/**`, `skills/201-sg-enrich/**`, `skills/203-sg-research/**`, `skills/205-sg-veille/**`, `skills/406-sg-seo/**`, `skills/407-sg-audit-translate/**`, and import/blueprint helpers may hold active handoffs or related-skill names and need inventory-driven migration where active.
- Public discovery: replace `shipglows-site/src/content/skills/sg-market-study.md`, `sg-audit-copy.md`, `sg-audit-copywriting.md`, and `sg-audit-gtm.md` with a canonical `sg-marketing.md`; update related-skill metadata in `sg-content`, `sg-redact`, `sg-research`, `sg-veille`, `sg-seo`, `sg-priorities`, and `sg-audit-translate` where they expose an active public route. Validate collection-derived navigation and direct links.
- Public workflow pages: inspect/update `shipglows-site/src/pages/skill-modes.astro`, `shipglows-site/src/pages/skills/index.astro`, and `shipglows-site/src/content/skills/shipglows.md` if their generated or curated descriptions list the old surface.
- Operator/docs surfaces: inspect/update `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `shipglows_data/editorial/content-map.md`, `shipglows_data/editorial/README.md`, `templates/competitive_intelligence.md`, and `shipglows_data/business/project-competitors-and-inspirations.md` where they contain active command examples or owner matrices.
- Historical-only candidates include `CHANGELOG.md`, previous specs, audits, evidence samples, research reports, and archive trees. They are scanned/classified but not mechanically renamed.

## Documentation Coherence

Documentation Update Plan:

1. Replace active runtime/catalog/help/routing identities with `009-sg-marketing` and exact mode examples.
2. Update public skill content and public navigation/related-skill metadata to one marketing page; remove the four retired public pages only after their replacements build and no active internal link targets them.
3. Update active technical, operator, editorial, template, and workflow references that instruct an operator or agent to launch one of the four old skills.
4. Preserve historical record names in the approved allowlist; do not present them as supported commands.
5. Update changelog and closure tracking only after verification/closure and do not claim shipment before `005-sg-ship`.

Editorial Update Plan:

1. Treat the public command migration as a public-content change: review the new page’s tagline, summary, prompts, limits, related skills, and category against the public skill schema and claim register.
2. Verify public wording distinguishes research, GTM, copy clarity, and persuasion without claiming market certainty, conversion gains, customer proof, or automated outcomes that the modes cannot evidence.
3. Preserve `007-sg-content` as the content-lifecycle explanation; it may describe `009` as a specialist marketing handoff but must not claim that it replaces drafting, SEO, research, veille, or email sequences.
4. Run applicable public-surface, page-intent, claim, schema, and link checks before considering the migration documentation-complete.

## Edge Cases

- `009 market` with no target asks for a niche, product idea, or market question; it does not infer a market from the current repository.
- `009 gtm` with a pricing or landing page checks product/claim evidence and may flag unresolved business/brand context rather than assign an unqualified grade.
- `009 copy` on an offer page can surface persuasion issues, but it does not silently switch into a full `copywriting` audit; it offers/reroutes only when the distinction materially changes the requested outcome.
- `009 copywriting` may report sentence-level clarity issues but retains the persona/offer/objection/conversion contract; it does not duplicate a full copy audit absent an explicit request or active chantier.
- A raw competitor link with no settled question routes through source intake/veille/research as required; it is not treated as market evidence solely because it reached `009`.
- A task that asks to draft, rewrite, enrich, publish, or send content routes to the existing content/email owner unless the active chantier explicitly owns remediation under the selected mode.
- A public old URL/bookmark may 404 after retirement unless the site’s route policy explicitly accepts a redirect; no skill-directory compatibility alias is allowed. Any web redirect decision must be documented as a public-route decision, not smuggled in as runtime compatibility.
- Stale runtime cache after filesystem sync is a reload-only proof gap, not justification to restore retired skill directories.
- An old invocation appearing in a spec, audit, historical source snapshot, sample evidence, or changelog is factual history; an old invocation in a current skill, catalog, template, public page, or operator guide is active drift.

## Implementation Tasks

- [x] Task 1: Freeze the migration inventory, semantic boundary matrix, and historical allowlist.
  - Files: this spec; all active hits found by the focused old-name scan.
  - Action: classify each occurrence as runtime, public, routing/help, active documentation/template, test/tooling, adjacent-owner handoff, or historical evidence; record the canonical replacement mode for every active occurrence.
  - User story link: the operator can discover one trustworthy entrypoint without losing a needed specialist path.
  - Depends on: none.
  - Validate with: reviewed inventory plus a source-to-mode completeness matrix and explicit historical exclusions.

- [x] Task 2: Create the compact `009` dispatcher and exact mode grammar.
  - Files: `skills/009-sg-marketing/SKILL.md`.
  - Action: define public identity, arguments, mode routing, conditional references, source-de-chantier behavior, error handling, boundaries, and validation without copying detailed workflows into the activation body.
  - User story link: reduces four competing commands to one explicit, safe choice.
  - Depends on: Task 1.
  - Validate with: scenario matrix for all valid, bare, invalid, missing-target, and boundary inputs.

- [x] Task 3: Migrate the four specialist procedures into bounded local playbooks.
  - Files: `skills/009-sg-marketing/references/market-study-playbook.md`, `gtm-audit-playbook.md`, `copy-audit-playbook.md`, `copywriting-audit-playbook.md`.
  - Action: migrate each predecessor’s detailed workflow, evidence/claim rules, output/report requirements, stop conditions, conditional shared-reference gates, follow-up routing, and validation details; deduplicate only where a shared reference is already canonical.
  - User story link: keeps the professional depth of each old specialist after compaction.
  - Depends on: Task 2.
  - Validate with: one pressure scenario per mode and source-to-target rule comparison including the copy/copywriting distinction.

- [x] Task 4: Migrate active routing, runtime, public documentation, catalogs, and adjacent-owner handoffs.
  - Files: active surfaces enumerated in Task 1, including code index, pack catalog, `000`, `007`, `302`, content-owner handoffs, technical/operator/editorial/template docs, `emailing`, and public skill content/pages.
  - Action: replace active old commands with `009` plus an exact mode; create the new public skill page; update generated/curated discovery and related links; retain historical evidence untouched.
  - User story link: makes public and internal discovery truthful and immediately usable.
  - Depends on: Tasks 2-3.
  - Validate with: active stale-key scan, code-index/catalog checks, public link/content checks, and Astro build.

- [x] Task 5: Retire the four source directories and runtime visibility.
  - Files: `skills/204-sg-market-study/`, `skills/206-sg-audit-copy/`, `skills/207-sg-audit-copywriting/`, `skills/408-sg-audit-gtm/`, current-user runtime links/manifests, and four public skill pages.
  - Action: remove each only after Task 4 has proven replacement completeness; do not leave wrappers, aliases, or hidden runtime directories.
  - User story link: prevents duplicate picker entries and future routing drift.
  - Depends on: Task 4.
  - Validate with: directory/link absence, `shipglows_sync_skills.sh --check --all`, code-index lint, and active-surface scan.

- [x] Task 6: Verify migration quality, close documentation, and prepare bounded ship scope.
  - Files: changed skills, playbooks, docs, public content, tests/tooling, and this spec.
  - Action: execute the Test Contract, record any runtime reload/toolchain limitation accurately, route through `103-sg-verify`, then `104-sg-end`, and stage only reviewed migration files for `005-sg-ship`.
  - User story link: proves that the smaller surface remains complete, public, and maintainable.
  - Depends on: Tasks 1-5.
  - Validate with: complete scenario-first and mechanical evidence set plus closure review.

## Acceptance Criteria

- [x] CA 1: Given an operator wants demand, competition, keywords, or monetization evidence, when they invoke `$009-sg-marketing market <target>`, then exactly the market-study playbook is selected and unsupported market facts are not invented.
- [x] CA 2: Given an operator wants positioning, offer, funnel, trust, analytics, or launch-readiness review, when they invoke `$009-sg-marketing gtm <target>`, then exactly the GTM playbook is selected and claim/product coherence checks remain enforced.
- [x] CA 3: Given an operator wants clarity, tone, CTA, readability, or friction review, when they invoke `$009-sg-marketing copy <target>`, then exactly the copy playbook is selected with rubric, claim, task-routing, and Inspiration Gate behavior intact.
- [x] CA 4: Given an operator wants persona, offer, objections, persuasion, or conversion-structure review, when they invoke `$009-sg-marketing copywriting <target>`, then exactly the copywriting playbook is selected with its distinct strategic contract intact.
- [x] CA 5: Given bare, invalid, or materially ambiguous mode input, when selection would change behavior, then `009` lists/asks for supported modes instead of silently choosing a mode or executing all four.
- [x] CA 6: Given an ordinary content lifecycle request, when `007-sg-content` routes a marketing-quality need, then it sends the request to the correct `009` mode and remains the editorial lifecycle owner.
- [x] CA 7: Given generic cited research, raw source triage, SEO work, or email sequence work, when the request reaches a marketing boundary, then it routes to `203`, `205`, `406`, or `emailing` respectively and is not absorbed by `009`.
- [x] CA 8: Given active help, runtime maps, public pages, catalogs, guides, templates, and adjacent-owner handoffs after migration, when scanned for the four old invocations, then no active reference remains outside the historical allowlist.
- [x] CA 9: Given a fresh runtime/public inventory after migration, when marketing skills are listed, then `009-sg-marketing` is the sole public entry from this consolidated family and its four modes are discoverable.
- [x] CA 10: Given historical records preserve former names, when validation scans run, then they remain intact and are classified as history rather than false active drift.
- [x] CA 11: Given the changed corpus, when contract tests, metadata, budget, audit, runtime, code-index, catalog, pack, and relevant public-site checks run, then they pass or a named proof gap blocks retirement/shipment.

## Test Strategy

- Scenario-first table with at least the eleven dispatcher, boundary, safety, and reroute cases listed in `Test Contract`.
- Source-to-playbook completeness matrix from all four source `SKILL.md` and `references/*-workflow.md` files.
- Focused active-reference scan with a reviewed historical allowlist; do not blanket-exclude all `shipglows_data/workflow/` because active workflow docs may need migration.
- A dedicated contract test under `tools/` or a focused extension to an existing executable contract test for grammar, mode mapping, old-directory absence, and required playbook links.
- `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/consolidate-marketing-skills-under-sg-marketing.md` before readiness, then lint all changed governed Markdown during implementation.
- `python3 tools/audit_shipglows_skills.py`.
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`.
- `python3 tools/skill_code_index_lint.py`.
- `tools/shipglows_sync_skills.sh --check --all` after runtime migration.
- `jq empty plugins/shipglows/assets/pack-catalog.json` plus the repository’s pack-refresh/validation command when the catalog changes.
- `pnpm --dir shipglows-site build` when its declared package-manager engine is available; otherwise run the project-local direct Astro build and record the engine mismatch separately rather than claiming the package command passed.

## Risks

- A single `009` could become a mega-router or load all marketing doctrine eagerly; mitigate with exact grammar, one playbook per mode, and bounded shared references.
- Collapsing `copy` and `copywriting` semantically could weaken either clarity/trust review or persona/offer/persuasion review; mitigate with explicit mode contracts and scenario tests.
- Deleting sources before their detailed procedures and conditional gates migrate could erase evidence, claim, rubric, task-routing, inspiration, source-intake, or product-behavior safeguards; mitigate with the completeness matrix before retirement.
- Public pages, examples, related-skill links, catalog, or runtime cache could direct users to deleted commands; mitigate with active scans, collection/link checks, sync proof, and public build.
- Reusing `009` after its previous internal maintenance identity could leave historical `009-sg-skill-build` references ambiguous; mitigate by treating old 009 references as history, adding exact code-index semantics, and never offering an alias.
- Public page removal could create an accidental redirect, stale inbound route, or a silently supported old command; mitigate with the explicit normal-not-found policy, inbound-link checks, exact 009 identity scans, and no-runtime-alias proof.
- A mass rename could alter factual historical artifacts or stage unrelated concurrent work; mitigate with inventory classification, hunk-aware staging, and review of the final cached diff.
- The draft product-behavior intelligence reference could be misrepresented as settled GTM proof; mitigate by preserving its conditional/draft status and confidence limits.

## Execution Notes

- Read first: the four source `SKILL.md` files and local workflow references; `skills/006-sg-design/SKILL.md` plus its playbook layout as the structural precedent; `skill-instruction-layering.md`; `content-owner-handoffs.md`; `007-sg-content/SKILL.md` and `content-router.md`; `skill-code-index.md`; pack catalog; and the four public skill pages.
- Implement in this order: freeze inventory/boundaries -> create dispatcher -> migrate playbooks -> add contract tests -> migrate active runtime/docs/public surfaces -> retire sources -> sync/check -> verify -> close -> ship.
- Preserve existing shared doctrine in its authoritative files. Local playbooks may point to it, but must not fork scoring, public claim, source-intake, task-registry, or inspiration rules.
- Use explicit `009` mode syntax in all active operator-facing instructions. Do not replace old names with a bare `009` where the user needs the mode to know what will happen.
- Treat source-directory removal as the final implementation act, not the first compaction act. If proof shows a missing migration, restore the contract in `009`/its playbook before considering retirement again; do not create a compatibility wrapper.
- Validate without external data collection for this migration. Actual market/GTM execution still uses its existing evidence and freshness gates.
- Stop and reroute to `100-sg-spec` for any newly discovered public-route redirect policy, taxonomy-wide renumbering, claim-governance change, or broadened owner merger that exceeds this approved four-skill scope.

## Open Questions

None. The operator approved the mode architecture: one public `009-sg-marketing` with `market`, `gtm`, `copy`, and `copywriting`, separate playbooks, no permanent compatibility skill directories, and explicit exclusions for research, veille, SEO, emailing, and the `007` editorial lifecycle. The fresh `101` pass confirmed the migration/security constraints are implementation-ready.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-16 15:01:27 | 100-sg-spec | GPT-5 Codex | Created durable scenario-first consolidation contract after operator approval; inspected source skills, local workflows, routing, runtime/catalog, public skill pages, and adjacent owners without modifying them. | Draft spec saved; no implementation started. | `/101-sg-ready consolidate marketing skills under sg-marketing` |
| 2026-07-16 15:06:47 | 101-sg-ready | GPT-5 Codex | Ran adversarial readiness and proportional security review; added explicit local-migration security posture, old-009 no-alias proof, and deterministic public-route handling. | Not ready: the material contract was strengthened during this gate and needs one clean re-review before implementation. | `/100-sg-spec consolidate marketing skills under sg-marketing` |
| 2026-07-16 15:09:57 | 101-sg-ready | GPT-5 Codex | Performed a fresh readiness pass against exact grammar, mode boundaries, public-route policy, retired-009 no-alias policy, security/no-secrets posture, staged retirement, historical treatment, and scenario-first proof. | Ready: a fresh agent can implement the bounded migration without a material decision. | `/102-sg-start Consolidate Marketing Skills Under 009-sg-marketing` |
| 2026-07-16 15:29:05 | 102-sg-start | GPT-5 Codex | Completed the staged migration and final retirement: migrated active surfaces were proven before removing the four source skill directories, then current-user runtimes were synchronized and stale retired symlinks removed. | Implemented: 009 contract, metadata, audit/budget, runtime, catalog, active-name, filesystem, diff, and direct public-build proof passed; the code-index lint retains its unrelated historical `sf-*` baseline. | `/103-sg-verify consolidate marketing skills under sg-marketing` |
| 2026-07-16 15:39:14 | 102-sg-start | GPT-5 Codex | Repaired the verification-proof gap with a maintenance-only source-to-mode matrix, a narrow retired-name policy, and contract assertions bound to the live dispatcher/playbooks and retired-directory absence. | Implemented: Tasks 1-5 and CA 1-10 now have durable local evidence; Task 6 and CA 11 remain pending independent verification. | `/103-sg-verify consolidate marketing skills under sg-marketing` |
| 2026-07-16 | 102-sg-start | GPT-5 Codex | Repaired active taxonomy coherence: `009-sg-marketing` is a conditional `source-de-chantier` in research/strategy/source, while `007-sg-content` remains the content lifecycle master. Added regressions for the code index, public taxonomy pages, and runtime lifecycle document. | Implemented: taxonomy repair returns the ready spec to independent verification; Task 6 and CA 11 remain pending. | `/103-sg-verify consolidate marketing skills under sg-marketing` |
| 2026-07-16 15:54:03 | 103-sg-verify | GPT-5 Codex | Independently reran the 009 contract suite, governed-metadata lint, skills audit and budget, runtime sync, code-index lint classification, catalog JSON validation, stale-name and retirement scans, diff check, direct Astro build, source-to-mode evidence review, and taxonomy regression. | Verified: all migration-scoped proof passed; `009` is conditionnel/source-de-chantier in research/strategy/source while `007` remains the lifecycle master. The code-index `sf-*`/`000` diagnostics and `205-sg-veille` size review are pre-existing, out-of-scope baselines. | `/104-sg-end Consolidate Marketing Skills Under 009-sg-marketing` |
| 2026-07-16 15:55:56 | 104-sg-end | GPT-5 Codex | Closed the verified local/runtime/public migration in the canonical spec, task registry, and changelog without claiming shipped or production marketing outcomes. | Closed: durable closure surfaces now match the verified scope; bounded git ship remains. | `/005-sg-ship Consolidate Marketing Skills Under 009-sg-marketing` |
| 2026-07-16 16:01:51 | 005-sg-ship | GPT-5 Codex | Re-ran the targeted marketing contract, metadata, audit/budget, runtime, index-baseline, catalog, retirement, active-name, diff, pack, and direct public-build checks; staged only the reviewed marketing migration scope. | Shipped: the bounded marketing consolidation commit is ready to publish on the current branch; pre-existing global packaging/index diagnostics remain outside this scope. | `git push` |

## Current Chantier Flow

- `100-sg-spec`: reviewed — durable migration contract includes explicit security, identity, public-route, and proof constraints.
- `101-sg-ready`: ready — fresh review confirmed exact mode grammar, bounded ownership, no-alias policy, and implementation proof contract.
- `102-sg-start`: implemented — staged migration, retirement, and durable source-completeness evidence completed; Tasks 1-5 and CA 1-10 are evidenced.
- `103-sg-verify`: verified — independent scenario, source-completeness, taxonomy, runtime, catalog, retirement, active-surface, and public-build proof passed; documented unrelated baselines remain outside this scope.
- `104-sg-end`: closed — canonical spec, task registry, and changelog now record the verified local/runtime/public migration without a ship or production-outcome claim.
- `005-sg-ship`: shipped — bounded marketing migration committed and pushed after fresh targeted validation; unrelated global packaging/index diagnostics remain documented baselines.

Next command: none
