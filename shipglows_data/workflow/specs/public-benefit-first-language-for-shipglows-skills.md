---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-08"
created_at: "2026-08-08 18:18:23 UTC"
updated: "2026-08-08"
updated_at: "2026-08-08 18:26:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "Benefit-first public language across the ShipGlows website and public skill catalog"
owner: "Diane"
user_story: "As a solo founder evaluating ShipGlows, I want to understand what each workflow changes for my work before encountering its internal vocabulary, so that I can decide whether it fits my problem without losing access to the technical evidence behind it."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "shipglows_data/editorial/claim-register.md"
  - "shipglows_data/editorial/content-map.md"
  - "shipglows_data/editorial/page-intent-map.md"
  - "/home/claude/shipglows_app/site/src/i18n/ui.ts"
  - "/home/claude/shipglows_app/site/src/pages/why-not-just-prompts.astro"
  - "/home/claude/shipglows_app/site/src/pages/fr/pourquoi-pas-de-simples-prompts.astro"
  - "/home/claude/shipglows_app/site/src/pages/docs.astro"
  - "/home/claude/shipglows_app/site/src/pages/fr/docs.astro"
  - "/home/claude/shipglows_app/site/src/pages/faq.astro"
  - "/home/claude/shipglows_app/site/src/pages/fr/faq.astro"
  - "/home/claude/shipglows_app/site/src/pages/skill-modes.astro"
  - "/home/claude/shipglows_app/site/src/content/skills/"
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.1.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/claim-register.md"
    artifact_version: "1.2.0"
    required_status: reviewed
  - artifact: "shipglows_data/editorial/page-intent-map.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/zombies-edge-case-heuristic.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator direction 2026-08-08: familiar reader understanding comes before technical vocabulary; technical terms remain available as second-level proof."
  - "Public-site review 2026-08-08: the homepage, comparison page, docs, FAQ, skill modes, and public skill pages describe strong workflow mechanics but do not yet apply one benefit-first translation consistently."
  - "Public-site review 2026-08-08: why-not-just-prompts.astro still uses legacy sf-* examples while the current public catalog uses sg-* naming."
  - "Claim register 1.2.0 permits evidence-bounded wording for decision quality, ZOMBIES edge-case coverage, and OWASP/ASVS awareness while prohibiting guarantees, certification, complete coverage, and quantified gains without evidence."
next_step: "/102-sg-start Public benefit-first language for ShipGlows skills"
---

# Spec: Public Benefit-First Language for ShipGlows Skills

## Title

Public Benefit-First Language for ShipGlows Skills

## Status

ready

## User Story

As a solo founder evaluating ShipGlows, I want to understand what each workflow changes for my work before encountering its internal vocabulary, so that I can decide whether it fits my problem without losing access to the technical evidence behind it.

## Minimal Behavior Contract

When a visitor encounters a ShipGlows public promise, the page leads with a familiar work outcome, then briefly explains the supporting mechanism only when it helps confidence or action. Existing technical terms remain discoverable in the second sentence, a detail, or the linked skill/docs path. A claim that cannot be proved stays qualified, is removed, or names its limit; an internal mechanism must never become an unexplained marketing label. The easy-to-miss case is making the wording simpler by making it stronger: plain language must not turn proportional checks into guarantees, certifications, autonomous shipping, or measured gains that ShipGlows cannot prove.

## Success Behavior

- A newcomer can identify the practical result of the homepage, comparison page, skill hub, documentation, FAQ, and a public skill page before needing to know terms such as `spec-first`, `ZOMBIES`, `OWASP`, `ASVS`, `Execution Batches`, or `read-only parallel`.
- Technical vocabulary remains available as accurate supporting evidence where the reader needs it, and links retain a route toward fuller documentation or the public skill contract.
- Every changed claim uses the approved claim-register boundary: explicit and proportional quality/security checks are allowed; guarantees, certification, complete security coverage, flawless code, unattended ship, quantified savings, and invented proof are not.
- The English and French homepage, docs, FAQ, and skill-mode framing tell the same product story in their native language rather than translating a technical slogan literally.
- The public comparison pages and shared homepage/docs framing use current `sg-*` examples or reader-language examples, never obsolete `sf-*` identifiers on active visitor paths.
- Success proof includes a clean static-site build, focused claim and legacy-name scans, human review of the changed flows, and a documented per-surface outcome/limit ledger.

## Error Behavior

- If a proposed benefit needs unverified customer, conversion, speed, security, or commercial evidence, it is downgraded to an evidence-safe qualitative statement or is not published.
- If an internal term cannot be accurately translated into a reader benefit, retain it only in technical docs or append an explanatory phrase; do not manufacture an intuitive but false analogy.
- If English and French copy diverge in promise strength, the stronger version is downgraded to the common proven boundary before merge.
- If a public skill page describes legacy model names, commands, or behavior that conflicts with the current public owner contract, the page is corrected only after source-of-truth comparison; uncertainty is recorded rather than guessed.
- If the static build, route rendering, content schema, or claim scan fails, no public copy batch is considered complete.
- Must never happen: suppressing legitimate technical detail; presenting OWASP awareness as compliance; saying that ZOMBIES proves all edge cases; presenting Clean Code as a guarantee of maintainability; claiming every task is parallelized; claiming unreviewed speed, revenue, adoption, or security results; exposing internal-only operational details.

## Problem

ShipGlows has credible mechanics: context routing, explicit contracts, verification, quality/security gates, structured delegation, and server-aware delivery. Current public pages often introduce those mechanisms before the reader understands the immediate benefit. This makes the offer feel more like an internal framework description than a clear answer to a founder’s delivery problem. Some pages already translate the value well, but the approach is inconsistent; the comparison page also retains obsolete `sf-*` workflow examples.

## Solution

Create one evidence-safe public-language guide that maps each important ShipGlows mechanism to its familiar reader outcome, supporting explanation, allowed proof wording, and prohibited overclaim. Apply it to the declared high-intent public surfaces. Keep the product’s direct, technical, disciplined voice: benefit-first does not mean generic, beginner-oriented, or hype-driven. Use the guide for a governed, batch-safe rewrite of shared pages and public skill content, while preserving current routes, Astro schemas, public skill identifiers, and claim boundaries.

## Scope In

- Create a canonical editorial guide for benefit-first public language, including the mechanism → reader outcome → technical proof → claim limit pattern.
- Include the current high-value mechanisms: context map, task/spec contract, readiness, verification, decision quality, ZOMBIES, Clean Code, OWASP/selected ASVS awareness, read-only parallel investigation, write Execution Batches, and server-aware delivery.
- Update the English and French homepage framing in `/home/claude/shipglows_app/site/src/i18n/ui.ts`.
- Update the English and French comparison pages `/home/claude/shipglows_app/site/src/pages/why-not-just-prompts.astro` and `/home/claude/shipglows_app/site/src/pages/fr/pourquoi-pas-de-simples-prompts.astro`, including legacy `sf-*` terminology.
- Update the public docs, FAQ, and skill-mode surfaces in both available locales where they carry the changed product explanation.
- Update the public skill catalog so its tagline, summary, problem, outcome, founder angle, and limits lead with reader outcomes and retain technical detail secondarily.
- Produce an Editorial Update Plan and Claim Impact Plan for the shared promise changes.
- Validate copy truth, localization parity, public-skill schema compatibility, route rendering, and the static build.

## Scope Out

- Creating a new public pricing offer, pricing claim, checkout, newsletter, social channel, case study, testimonial, quantified ROI claim, or product-demo route.
- Changing skill runtime behavior, public invocation grammar, plugin packaging, model availability, delegation policy, or the underlying ZOMBIES, Clean Code, or OWASP contracts.
- Claiming compliance, certification, complete OWASP/ASVS coverage, a vulnerability-free product, bug-free code, all-case coverage, fully autonomous delivery, or measurable performance/business gains.
- A visual redesign, design-token changes, component architecture rewrite, analytics implementation, SEO strategy expansion, commit, push, deployment, or publication.
- Editing unrelated dirty files in either the ShipGlows repository or the site repository.

## Constraints

- Public source root for this chantier is `/home/claude/shipglows_app/site`; ShipGlows governance and the durable spec remain under `/home/claude/shipglows`.
- Keep the public site’s current English/French route policy and the English public-skill-body policy unless a localized skill-body change is explicitly approved separately.
- Use the established brand voice: direct, technical, disciplined, precise, and evidence-oriented—not simplistic, magical, or salesy.
- Each revised message follows this order when space allows: familiar outcome first; concise mechanism second; proof/limit where the claim is sensitive.
- Preserve public skill identifiers, content collection schema, routes, category taxonomy, and argument examples unless a source-of-truth audit proves a stale reference.
- Shared public surfaces and governance files are sequential write ownership. Parallel edits are permitted only through the ready `Execution Batches` below.
- Fresh external docs: `fresh-docs not needed`; no current provider/framework behavior is being claimed or changed.

## Test Contract

### Surface

- Stack/surface: governed Markdown editorial artifacts plus Astro static-site content in `/home/claude/shipglows_app/site`.
- Primary proof mode: content contract, static build, focused source scans, and human readability review.
- Proof order: claim/lexicon review → focused content/schema scans → static build → route inspection → final claim and legacy-name scans.

### Manual checklist

- Needed: yes.
- Proof profile: `static-site editorial change`.
- Checklist path: `shipglows_data/workflow/test-checklists/public-benefit-first-language.md`.
- Required scenario IDs: `PBL-FOUNDATION`, `PBL-PARITY`, `PBL-CLAIM`, `PBL-LEGACY`, `PBL-SKILL`, and `PBL-RENDER`.
- Required results: each scenario records `pass`, `fail`, or `not applicable` with route/page evidence; a `fail` on claim strength, source-contract drift, legacy naming, schema/build, or route rendering blocks integration.
- Required scenarios: first-time founder comprehension, technically experienced evaluator seeking mechanisms, English/French promise parity, an unsupported-security-claim attempt, and stale-command discovery.
- Manual proof: inspect `/`, `/fr/`, `/why-not-just-prompts`, `/docs`, `/fr/docs`, `/faq`, `/fr/faq`, `/skill-modes`, and a representative page from each public skill category at desktop and narrow viewport widths.
- Exception with proof: production/browser-hosted proof is not required for this copy-only chantier; local rendered route inspection plus the static build is sufficient unless local rendering reveals a layout regression.

### Required evidence stack

- Automated: Astro build and focused `rg` scans for legacy `sf-*`, disallowed absolute claims, and changed technical labels without an adjacent reader explanation.
- Contract/integration: Astro collection-schema validation through the build; English/French public-surface parity review; public skill source-of-truth comparison.
- Semantic: the surface ledger records the primary reader outcome, secondary mechanism, proof/limit, CTA continuity, and no-overclaim verdict for each changed page family.
- Provider, auth, data, device, and production evidence: not applicable; no behavior, credential, or external service changes occur.

## Dependencies

- `business.md` 1.2.0, `product.md` 1.2.0, `gtm.md` 1.2.0, and `branding.md` 1.1.0 define audience, promise, proof posture, and voice.
- `claim-register.md` 1.2.0 governs sensitive security, quality, AI reliability, automation, speed, savings, availability, pricing, and business-outcome wording.
- `page-intent-map.md` 1.3.0 preserves each public route’s job and prevents a copy rewrite from changing its role.
- `editorial-update-gate.md` governs the Editorial Update Plan and Claim Impact Plan.
- Current public owner skills and their public content files remain the source of truth for a skill’s actual outcome, inputs, limits, and supported modes.
- Runtime dependencies: Astro and the site’s locked package manager state; no new dependency is introduced.
- Fresh external docs: `fresh-docs not needed`.

## Invariants

- Familiar reader understanding precedes internal vocabulary; technical evidence remains available and accurate.
- No claim becomes stronger solely because it becomes shorter or easier to read.
- The site stays solo-founder-first while still recognizing the adjacent small technical-team audience.
- The public narrative remains about less ambiguity, stronger handoffs, explicit contracts, proportional verification, and delivery awareness—not generic AI coding speed.
- Public pages do not become the source of truth for skill behavior; they reflect reviewed contracts and verified local behavior.
- Public skill content remains schema-valid and does not disclose internal-only prompts, credentials, private URLs, logs, or operational details.
- A technical term must either be explained by its reader consequence or remain in an explicitly technical context.
- Every changed shared surface has one integration owner and one claim-boundary review before it is accepted.

## OWASP Security Gate

- Surface: publicly served static content; no authentication, authorization, API, payment, user data, upload, server-side action, tenant, or provider integration changes.
- Relevant OWASP Top 10:2025 lens: `A02 Security Misconfiguration` only insofar as public copy must not reveal secrets, internal-only endpoints, private paths, or misleading security posture; `A10 Mishandling of Exceptional Conditions` only insofar as broken build/schema/route evidence must block publication rather than fail silently.
- Trust and data boundaries: public reader → static site content. No new trust boundary or data flow is introduced.
- Selected OWASP ASVS v5.0.0 requirements: not applicable to this copy-only, static-content scope; no application control implementation is changed.
- Required controls/proof: secret/private-detail scan, claim-register review, static build, local route inspection, and stop on a schema/build/claim failure.
- Residual gap: this chantier does not assess the site’s hosting, headers, dependencies, runtime configuration, or application security. Those remain outside scope.
- Owner route: security/runtime findings discovered during copy work are recorded and routed separately; they must not be disguised as copy edits.

## Links & Consequences

- Upstream: product, business, GTM, branding, claim register, current public skill contracts, and current site source.
- Primary delivery surface: `/home/claude/shipglows_app/site`.
- Shared governance impact: add the public-language guide to the editorial content map and retain an Editorial Update Plan/Claim Impact Plan in this spec or its implementation evidence.
- Downstream: homepage, comparison, docs, FAQ, skills hub/detail pages, installation and future public pages can reuse the guide without restating the current conversation.
- Regression risk: a concise benefit may imply guarantees; claim review is mandatory before integration.
- Regression risk: catalog-wide wording changes can cause a skill page to diverge from its source skill; each batch must compare its owned pages to the matching contract.
- Regression risk: changing shared `ui.ts` can affect localized homepage rendering; build and both-locale review are mandatory.
- No data, auth, payment, provider, runtime behavior, deployment, or public pricing change is allowed.

## Documentation Coherence

- Create `shipglows_data/editorial/public-benefit-language.md` as the canonical editorial guide, scoped to public benefit-first wording and its evidence limits.
- Update `shipglows_data/editorial/content-map.md` and, only if route roles change, `page-intent-map.md`; the current intent is a copy-quality improvement, not a route-role change.
- Update `claim-register.md` only when needed to record a durable wording boundary not already covered by decision-quality/security claims; do not duplicate the full language guide there.
- Preserve the current public skill content schema; add no ShipGlows governance frontmatter to runtime content.
- README, internal technical docs, pricing, and installation flows receive no rewrite unless implementation discovers an actual public-promise mismatch. Such a mismatch must be documented and assigned, not silently expanded into this chantier.

## Edge Cases

### ZOMBIES coverage

- **Zero:** a page has no available proof beyond the mechanism itself; it must use qualitative, evidence-safe language and state the limit rather than adding a proof-like claim.
- **One:** a single concise hero/card must still convey one concrete outcome before its supporting mechanism.
- **Many:** a catalog of skills must remain distinct by reader job; benefits cannot be flattened into the same generic “better AI” promise.
- **Boundary Behaviors:** short cards, mobile layouts, meta descriptions, and CTA labels have limited space; they may omit secondary technical detail but cannot imply an unsupported stronger claim.
- **Interface definition:** public copy interfaces with source skills, the claim register, locale dictionaries, Astro content collections, route renderers, and readers with different technical depth.
- **Exceptional behavior:** legacy names, source-contract ambiguity, localization drift, missing proof, and build/schema failures stay visible and block the affected batch.
- **Simple Scenarios, Simple Solutions:** start from the simplest accurate reader outcome; add technical terminology only where it helps understanding, trust, or a next action.

## Implementation Tasks

- [ ] Task 1: Establish the canonical public-language guide and the update ledger.
  - File: `shipglows_data/editorial/public-benefit-language.md`, `shipglows_data/editorial/content-map.md`, and this spec’s Editorial/Claim plans.
  - Action: Define the approved benefit-first vocabulary for the named mechanisms, with reader outcome, supporting technical term, safe proof wording, prohibited overclaim, and examples in English and French where a shared surface needs both. Record the per-surface update and claim-impact plans.
  - User story link: Gives future copy work one durable source rather than repeated interpretation.
  - Depends on: None.
  - Validate with: metadata lint, duplicate/claim-boundary scan, and editorial review against business/product/GTM/branding/claim-register contracts.
  - Notes: This is a shared governance write and must complete before page-copy batches begin.

- [ ] Task 2: Rewrite homepage and shared navigation-level promise framing.
  - File: `/home/claude/shipglows_app/site/src/i18n/ui.ts` and only directly consumed homepage copy structures.
  - Action: Lead hero, feature, agent-loop, and related CTA explanations with founder-visible outcomes; retain mechanisms as second-level substantiation; preserve English/French parity and existing routes.
  - User story link: Lets a first-time visitor understand the product before learning the framework vocabulary.
  - Depends on: Task 1.
  - Validate with: focused locale-key/type scan, static build, `/` and `/fr/` rendered review, claim scan.
  - Notes: One exclusive shared-file owner; do not concurrently edit `ui.ts`.

- [ ] Task 3: Rewrite the public comparison and documentation explanations.
  - File: `/home/claude/shipglows_app/site/src/pages/why-not-just-prompts.astro`, `/home/claude/shipglows_app/site/src/pages/fr/pourquoi-pas-de-simples-prompts.astro`, `/home/claude/shipglows_app/site/src/pages/docs.astro`, `/home/claude/shipglows_app/site/src/pages/fr/docs.astro`, `/home/claude/shipglows_app/site/src/pages/skill-modes.astro`, and `/home/claude/shipglows_app/site/src/pages/fr/skill-modes.astro` if current content needs matching copy.
  - Action: Explain prompt limits, workflow value, and skill selection in reader language first; retain exact mechanisms or commands as secondary evidence; replace stale `sf-*` examples with current source-of-truth public wording.
  - User story link: Helps an evaluator understand why the framework exists and how it applies before entering detailed docs.
  - Depends on: Task 1.
  - Validate with: source-of-truth command scan, static build, route inspection, claim scan, and reader-first semantic review.
  - Notes: Keep route roles unchanged; stop if a stale command has no unambiguous source-of-truth replacement.

- [ ] Task 4: Rewrite FAQ objections and limits.
  - File: `/home/claude/shipglows_app/site/src/pages/faq.astro` and `/home/claude/shipglows_app/site/src/pages/fr/faq.astro`.
  - Action: Make recurring objections legible to a non-specialist while retaining honest limits on security, bugs, automation, speed, and proof.
  - User story link: Lets a skeptical reader evaluate the product without decoding jargon or receiving inflated reassurance.
  - Depends on: Task 1.
  - Validate with: English/French parity review, claim-register scan, static build, and FAQ route inspection.
  - Notes: No pricing or commercial claim expansion.

- [ ] Task 5: Apply the benefit-first pattern to public skill pages.
  - File: `/home/claude/shipglows_app/site/src/content/skills/*.md`, grouped only by exclusive file ownership in the ready execution batches.
  - Action: For each in-scope public skill, align `tagline`, `summary`, `problem`, `outcome`, `founder_angle`, and limits to a reader outcome first, then factual technical detail. Compare every page with its owner skill before editing; remove stale model/command claims only when source truth identifies the replacement.
  - User story link: Lets visitors select a skill from a concrete job and expected result rather than from internal taxonomy.
  - Depends on: Task 1.
  - Validate with: content-schema build, source-of-truth diff review, claim scan, one representative render per category, and complete catalog inventory.
  - Notes: Public skill bodies remain English under the current locale policy. Do not alter shared content schema, hub taxonomy, or unrelated skill behavior.

- [ ] Task 6: Integrate, validate, and record the final editorial result.
  - File: `shipglows_data/workflow/test-checklists/public-benefit-first-language.md` plus changed governance and site surfaces only.
  - Action: Create the execution checklist for the six named proof scenarios; reconcile all batches against the language guide and claim register; run full validation; record residual limits, any deferred stale-contract findings, and final Editorial/Claim plan statuses.
  - User story link: Ensures the new public language is coherent rather than a set of isolated copy edits.
  - Depends on: Tasks 2-5.
  - Validate with: metadata lint for governed docs, `corepack pnpm@11.15.0 --dir /home/claude/shipglows_app/site build`, focused `rg` scans, diff review, and manual route checklist.
  - Notes: One integration owner. No commit, push, deployment, or publication without separate authority.

## Acceptance Criteria

- [ ] AC 1: Given a visitor opens the English or French homepage, when they scan the hero and first feature/loop sections, then they encounter the founder-visible outcome before unexplained internal terms.
- [ ] AC 2: Given a reader wants evidence, when a page mentions context, contracts, verification, edge cases, quality, security, or delegation, then it supplies accurate supporting mechanism language or a path to it without overclaiming.
- [ ] AC 3: Given security, OWASP, ASVS, ZOMBIES, or Clean Code wording appears, when it is reviewed against the claim register, then it describes proportional awareness/checks and never guarantees security, compliance, all-case coverage, bug-free code, or maintainability.
- [ ] AC 4: Given the English and French shared surfaces discuss the same promise, when compared, then neither locale materially strengthens, weakens, or invents a claim relative to the other.
- [ ] AC 5: Given a public skill page is updated, when a visitor reads its card fields and limits, then they can identify the job, visible outcome, evidence/limit, and relevant technical detail without a source-contract mismatch.
- [ ] AC 6: Given the comparison pages and declared shared homepage/docs framing are rendered, when they illustrate a ShipGlows workflow, then they use current public `sg-*` terminology or reader-language equivalents and contain no stale `sf-*` workflow examples on those active visitor paths.
- [ ] AC 7: Given a short or mobile-constrained surface, when copy is shortened, then the primary reader outcome remains and no compressed phrase becomes a stronger unsupported promise.
- [ ] AC 8: Given the content collection and localized pages are built, when the production static build runs, then it succeeds without schema, rendering, or route failures.
- [ ] AC 9: Given the final diff is reviewed, when unrelated dirty work is present, then only the declared governance and public-copy surfaces are included in this chantier.
- [ ] AC 10: Given the implementation is complete, when the editorial ledger is reviewed, then every declared surface is marked complete, deferred with a truthful reason, or blocked with an owner and no hidden public-claim gap.

## Test Strategy

- Build the public site with the locked pnpm version after all site batches are integrated.
- Run focused `rg` scans for `sf-(spec|ready|start|verify)` in the declared homepage, comparison, docs, FAQ, and modes source files; do not treat deliberately archived historical transcript content as an active-route copy failure without first confirming its route.
- Validate governed Markdown with `python3 tools/shipglows_metadata_lint.py shipglows_data/editorial shipglows_data/workflow/specs/public-benefit-first-language-for-shipglows-skills.md`.
- Manually inspect declared routes locally at desktop and narrow width; confirm no CTA, link, locale, or visual overflow regression.
- Compare every changed public-skill page to its current public owner skill and record any mismatch outside the rewrite scope.

## Risks

- Simplification can accidentally turn “helps” into “guarantees.” Mitigation: claim-register review and explicit prohibited wording in the guide.
- Catalog-wide rewrites can introduce source-contract drift. Mitigation: exclusive ownership plus per-page source comparison.
- Translation can change the strength or warmth of a claim. Mitigation: bilingual review of all shared promise surfaces.
- The existing site worktree is dirty. Mitigation: inspect and preserve pre-existing changes; integrate only declared files and report overlap rather than overwrite it.
- Broad copy work can become a visual/product redesign. Mitigation: preserve routes, components, schemas, taxonomy, and layout; route visual changes separately.

## Execution Notes

- Read first: this spec; `shipglows_data/editorial/claim-register.md`; `shipglows_data/editorial/page-intent-map.md`; `shipglows_data/editorial/content-map.md`; `shipglows_data/business/{business,product,gtm}.md`; `shipglows_data/branding/branding.md`; then each exact site source file and its owner-skill source.
- Establish Task 1 before any public-page mutation. It is the claim and language source for later batches.
- Use read-only parallel discovery for independent surface/source audits. Do not edit during that phase.
- After readiness, use the defined write batches only. Every batch must leave shared files, schema files, route hubs, and other agents’ owned files untouched.
- Stop for an operator decision only if implementation discovers a new pricing/product promise, missing canonical sales surface, unsupported factual claim that materially changes the intended public promise, or an unavoidable public-behavior change.
- Before any ship action, obtain separate authority; this spec authorizes preparation and local validation only.

## Execution Batches

### Read-only Batch Matrix

| Mission | Owned read-only surface | Required evidence | Forbidden actions | Integration owner |
| --- | --- | --- | --- | --- |
| A | Homepage and shared localized-copy audit | mechanism/outcome inventory, locale divergence, existing dirty overlap | all edits, builds that write artifacts, tracker changes | content master |
| B | Docs, comparison, FAQ, and modes audit | stale names, reader-first gaps, claim-sensitive wording | all edits, tracker changes | content master |
| C | Public skill catalog audit | page-to-owner-skill outcome/limit matrix, stale command/model claims | all edits, schema changes | content master |
| D | Governance/claim audit | allowed wording, prohibited claims, map/ledger impact | all edits, site inspection beyond declared evidence | content master |

### Write Execution Batches

| Batch | Write ownership | Depends on | Per-batch proof | Integration owner |
| --- | --- | --- | --- | --- |
| 0 | `public-benefit-language.md`, `content-map.md`, required ledger/claim-register entries | ready spec | metadata lint and claim-boundary review | content master |
| 1 | `site/src/i18n/ui.ts` only | Batch 0 | build and bilingual homepage review | content master |
| 2 | comparison/docs/modes pages, each exact file exclusively assigned | Batch 0 | build, stale-name scan, route review | content master |
| 3 | English/French FAQ files only | Batch 0 | build, bilingual claim review, route review | content master |
| 4 | exclusive, pre-enumerated groups of `site/src/content/skills/*.md` | Batch 0 | schema build, owner-contract comparison, catalog inventory | content master |
| 5 | integration-only reconciliation of changed declared files | Batches 1-4 | full build, metadata lint, all scans, manual checklist | content master |

No batch may edit a file owned by another batch. If a discovery finding requires a shared hub, schema, navigation, pricing, layout, or product-contract change outside the declared owner set, stop the affected batch and add a bounded follow-up rather than widening ownership.

## Open Questions

- None. The existing business, product, GTM, brand, editorial, claim, and public-site evidence sufficiently define the audience, promise, limits, and declared surfaces for this copy-quality chantier.

## Editorial Update Plan

- Changed behavior or source: Operator decision 2026-08-08 to put familiar reader outcomes ahead of technical workflow vocabulary while retaining the latter as accurate proof.
- Impacted surface: homepage, comparison, docs, FAQ, skill modes, public skill pages, and editorial governance.
- Source of truth: business/product/GTM/branding contracts, claim register, page-intent map, current public owner skills, and this spec.
- Required action: update.
- Reason: public language currently describes mechanisms credibly but inconsistently leads with the user-visible benefit.
- Owner role: executor plus integration owner under `sg-content`.
- Parallel-safe: yes for read-only audit; write only through the Execution Batches above.
- Validation: claim review, public-skill source comparison, metadata lint, Astro build, focused scans, route inspection.
- Closure status: implementation in progress — Batch 0 governance guide and content-map routing are complete; public-copy batches remain pending.

## Claim Impact Plan

- Claim: ShipGlows gives solo founders clearer agent handoffs, explicit work framing, proportional quality/security checks, and more visible delivery proof.
- Claim family: AI reliability, decision quality, security, automation, speed.
- Affected surfaces: homepage, comparison, docs, FAQ, skill modes, public skill pages.
- Evidence: reviewed business/product/GTM/branding contracts; claim register 1.2.0; active ZOMBIES/Clean Code/OWASP awareness contracts; current public owner-skill behavior.
- Status: allowed with caveat — active and bounded for the pending public-copy batches.
- Allowed wording: “helps”, “gives”, “keeps”, “checks”, “makes visible”, and “proportional to the work” for supported mechanisms; retain explicit limits for security, bugs, automation, and measured outcomes.
- Required action: publish only after every changed statement passes the guide and source comparison; downgrade or remove unsupported assertions.
- Stop condition: any wording implying security/compliance/correctness/ROI/autonomy guarantee, complete OWASP coverage, or an unverified quantified result.

## Skill Run History

| Timestamp | Skill | Model | Summary | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-08 18:18:23 UTC | 100-sg-spec | GPT-5 Codex | Created the durable contract for evidence-safe, benefit-first public language across governed ShipGlows site and public skill surfaces; defined claim limits, proof, read-only discovery matrix, and non-overlapping write batches. | draft | /101-sg-ready Public benefit-first language for ShipGlows skills |
| 2026-08-08 18:26:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, user-story traceability, source roots, claim/security boundaries, ZOMBIES coverage, proof contract, execution batches, dirty-worktree boundary, locale parity, and adversarial failure paths. The static-content OWASP gate is proportionate and no material operator decision remains. | ready | /102-sg-start Public benefit-first language for ShipGlows skills |

## Current Chantier Flow

- `100-sg-spec`: complete — durable contract created; no public copy has been edited under this chantier.
- `101-sg-ready`: ready — source paths, task boundaries, claim limits, proof plan, existing dirty-file ownership, security posture, and Execution Batch non-overlap passed strict review.
- `102-sg-start`: next — establish the benefit-first guide, then dispatch only the ready read-only matrix and non-overlapping write batches.

Next step: `/102-sg-start Public benefit-first language for ShipGlows skills`
