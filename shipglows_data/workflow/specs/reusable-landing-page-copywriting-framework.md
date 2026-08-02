---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: "ShipGlows"
created: "2026-07-17"
created_at: "2026-07-17 14:03:17 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 14:40:42 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "Reusable landing-page copywriting doctrine and 009-sg-marketing application"
owner: "Diane"
user_story: "As the ShipGlows operator, I want the effective landing-page copywriting structure identified through ReplayGlowz work to become a reusable, evidence-safe framework in 009-sg-marketing, so that future landing-page audits produce coherent reading flows without repeated sections, invented claims, or project-specific copy reuse."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/references/landing-page-copywriting-framework.md"
  - "skills/009-sg-marketing/SKILL.md"
  - "skills/009-sg-marketing/references/copywriting-audit-playbook.md"
  - "skills/references/content-quality-rubric.md"
  - "skills/references/design-inspiration-library.md"
  - "skills/references/editorial-content-corpus.md"
  - "skills/REFRESH_LOG.md"
  - "tools/test_landing_page_copywriting_framework_contract.py"
  - "tools/test_009_sg_marketing_contract.py"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/009-sg-marketing/references/copywriting-audit-playbook.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/design-inspiration-library.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator confirmation on 2026-07-17: capitalize the landing-page copywriting structure learned through ReplayGlowz as reusable doctrine for 009-sg-marketing."
  - "Operator boundary on 2026-07-17: do not create a new public mode and do not copy ReplayGlowz-specific text."
  - "Read-only discovery on 2026-07-17 found that copywriting-audit-playbook.md names persuasion structure, section roles, progression, objections, proof, and CTA strategy without defining a reusable section-sequencing or repetition-control method."
  - "Read-only discovery on 2026-07-17 confirmed that design-inspiration-library.md already owns page-type, section, copy-pattern, and inspiration-selection taxonomy, which the new doctrine must consume rather than duplicate."
next_step: none
---

# Spec: Reusable Landing-Page Copywriting Framework

## Title

Reusable Landing-Page Copywriting Framework

## Status

ready

## User Story

As the ShipGlows operator, I want the effective landing-page copywriting structure identified through ReplayGlowz work to become a reusable, evidence-safe framework in `009-sg-marketing`, so that future landing-page audits produce coherent reading flows without repeated sections, invented claims, or project-specific copy reuse.

## Minimal Behavior Contract

When `009-sg-marketing copywriting <target>` identifies a landing, sales, or offer page, or an explicit request about its section order, reading flow, repetition, proof, objections, or CTA sequence, it loads one reusable landing-page framework after the existing copywriting playbook and produces an evidence-backed `Landing Sequence Plan` that gives every section a distinct reader question and decision role. If audience, offer, product truth, or claim evidence is missing, the result remains blocked or confidence-limited and names the gap instead of inventing copy or proof. The easy-to-miss edge case is intentional repetition: a later mention is retained only when it adds proof, specificity, contrast, objection handling, or decision value rather than paraphrasing an earlier promise.

## Success Behavior

- Preconditions: The operator selects the existing `copywriting` mode with a bounded page, funnel, or offer target; the target can be classified as a landing, sales, or offer page, or the request explicitly concerns section flow.
- Trigger: `009-sg-marketing copywriting <target>` loads its one existing local playbook, which conditionally loads the shared landing-page framework.
- User/operator result: The report distinguishes the audience and awareness state, core argument spine, section sequence, proof and objection placement, CTA progression, and material repetitions to keep, merge, move, delete, or replace.
- System effect: No new public mode or marketing lifecycle is created. The shared doctrine becomes the canonical source for landing-page sequencing, while the local copywriting playbook owns its audit application.
- Success proof: Scenario-first contract tests prove `LPF-LOAD`, `LPF-SEQUENCE`, `LPF-DEDUPE`, and `LPF-CLAIMS`, plus dispatcher and documentation-layering compatibility.
- Silent success: Not allowed. The report must show the selected framework path and the resulting `Landing Sequence Plan` or the concrete evidence gap that prevented it.

## Error Behavior

- Unknown, missing, or ambiguous public mode behavior remains governed by the current `009-sg-marketing` dispatcher; the framework must not create an alias or silently choose between `copy` and `copywriting`.
- A non-landing target without an explicit section-flow need does not load the landing framework merely because it contains marketing copy.
- Missing audience, offer, product, brand, claim, or proof context produces a visible confidence limit, `needs proof`, `claim mismatch`, or blocked result according to existing contracts.
- Missing shared framework or required local playbook blocks the landing-specific pass with a concrete owner route; it must not fall back to an improvised generic template.
- Inspiration references remain optional and operator-selected under `design-inspiration-library.md`; the framework must not silently load private bundles or reproduce source phrasing.
- Must never happen: copying ReplayGlowz-specific text, inventing testimonials or conversion evidence, adding fake urgency, treating repeated wording as proof, forcing every page into one rigid sequence, running both `copy` and `copywriting`, or adding a fifth public marketing mode.
- Silent failure: Not allowed. The report must identify the failed precondition or unsupported claim and the safest next owner action.

## Problem

The current copywriting playbook correctly checks persona, awareness, value proposition, persuasion structure, objections, emotional path, CTA strategy, and journey coherence. It does not define how a fresh agent should turn those checks into a coherent landing-page sequence or determine when several benefit, feature, proof, pricing, and CTA sections repeat the same message. ReplayGlowz work exposed a useful structural pattern, but leaving it in one project conversation makes the learning non-reusable, while copying its final text would create project-specific drift and unsafe claims.

## Solution

Create one shared landing-page copywriting framework that defines a reader-question sequence, a section-role ledger, an evidence and claim ledger, a repetition budget, and a `Landing Sequence Plan` output. Adapt the existing `copywriting` playbook to load and apply that doctrine for landing-specific targets, then add one compact activation pointer in `009-sg-marketing/SKILL.md`. Preserve all current mode, inspiration, claim-safety, editorial, and owner boundaries.

## Scope In

- Create `skills/references/landing-page-copywriting-framework.md` as the canonical reusable doctrine.
- Define trigger conditions for landing, sales, and offer pages and explicit section-flow/repetition requests under existing `copywriting` mode.
- Define required inputs: intended buyer, awareness level, page goal, offer, product truth, proof inventory, objections, CTA destination, and governing business/brand/editorial contracts.
- Define a flexible argument spine based on reader questions rather than a fixed AIDA-style template.
- Define a `Section Role Ledger` with at least: section identity, reader question, unique job, new information, claim IDs, proof, objection handled, transition, CTA role, and recommended action.
- Define a `Repetition Ledger` with the first authoritative exposition of each message and the evidence-backed reason for any later mention.
- Define a `Landing Sequence Plan` with `keep`, `move`, `merge`, `delete`, or `create` actions for existing sections.
- Adapt `copywriting-audit-playbook.md` to use the shared doctrine without duplicating it.
- Add one compact conditional loader and owner boundary to `009-sg-marketing/SKILL.md` without changing public grammar.
- Add focused mechanical contract proof for the four accepted pressure scenarios and existing dispatcher invariants.
- Preserve integration with the existing inspiration, content-quality, editorial, and decision-quality contracts.

## Scope Out

- A new public marketing mode, alias, lifecycle, or standalone landing-page skill.
- Copying, embedding, publishing, or treating ReplayGlowz-specific copy as a template.
- A universal fixed section order that ignores audience awareness, offer complexity, proof availability, or conversion goal.
- Visual design, card styling, icon systems, layout implementation, component code, or design-system changes.
- Sentence-level rewriting, page implementation, publishing, or automatic execution of `copy` mode.
- Changes to `copy-audit-playbook.md`; this chantier keeps landing-sequence ownership in `copywriting` and leaves clarity/microcopy ownership unchanged.
- Changes to `content-quality-rubric.md` in this initial chantier. The framework produces a qualitative sequence plan, while any explicitly requested rubric score continues to use the existing shared schema independently. A first-class `landing-page` rubric surface requires a separate evidence-backed contract change.
- Changes to `design-inspiration-library.md`, `editorial-content-corpus.md`, public site copy, plugin packaging, business contracts, or project-specific landing pages.
- Commit, push, release, or deployment.

## Constraints

- Preserve exactly four public substantive modes: `market`, `gtm`, `copy`, and `copywriting`.
- Preserve the rule that one invocation selects exactly one local playbook.
- Keep the activation contract compact; detailed framework logic belongs in the new shared reference and application detail in the local copywriting playbook.
- The framework is a decision system, not a mandatory list of sections. A section exists only when it advances a material reader question or decision.
- Repetition is allowed only when the later occurrence adds proof, specificity, contrast, objection handling, recap value at a real decision point, or a distinct CTA function.
- Claims, testimonials, prices, guarantees, results, capabilities, user counts, and urgency require current project evidence; unsupported content remains a gap or placeholder, never generated fact.
- Inspiration remains bounded and operator-selected. Transfer principles, not wording, visual identity, or distinctive source expression.
- Internal contracts remain in English; user-facing reports use the operator's active language.
- No external behavior governs the change: `fresh-docs not needed`.

## Test Contract

### Surface

- Stack/surface: ShipGlows Markdown skill contract, shared reference, and Python text-contract tests.
- Primary proof mode: `contract_only`.
- Proof path: `scenario-first`.
- Proof order: focused contract tests -> metadata lint -> targeted routing/coherence scans -> skill budget -> runtime sync -> semantic review.

### Manual checklist

- Needed: no.
- Checklist path: None.
- Required scenario coverage: `LPF-LOAD`, `LPF-SEQUENCE`, `LPF-DEDUPE`, and `LPF-CLAIMS`.
- Exception with proof: Browser, device, and hosted proof are not applicable because the changed behavior is an instruction contract with mechanical and semantic evidence.

### Required evidence stack

- Automated: dedicated landing-framework contract tests and the existing `009-sg-marketing` dispatcher suite.
- Contract/integration: metadata lint, skill budget, runtime sync, and focused stale-wording/routing scans.
- Semantic: verify that a fresh agent can choose the loader, construct a non-repetitive sequence, and reject unsupported claims without reading ReplayGlowz project copy.
- Provider, browser, auth, device, and production evidence: not applicable.

## Dependencies

- `skill-instruction-layering.md` 1.1.0 defines shared-doctrine-first placement and compact activation rules.
- `decision-quality-contract.md` 1.2.0 preserves the professional quality, structure-replacement, and anti-shortcut bar.
- `copywriting-audit-playbook.md` 1.1.0 remains the one local application playbook and public mode owner.
- `design-inspiration-library.md` 1.2.0 remains the source of page-type, section, copy-pattern, rights, selection, and anti-copy constraints.
- `content-quality-rubric.md` 1.0.0 remains read-only in this scope; it may score output only when explicitly requested, independently from the sequence plan.
- `editorial-content-corpus.md` 1.4.0 remains the owner of page intent, public claims, and documentation impact plans.
- Runtime dependencies: None.
- Fresh external docs: `fresh-docs not needed`; the behavior is governed entirely by the local ShipGlows corpus.

## Invariants

- `009-sg-marketing` remains the sole public marketing entrypoint and an audit/source skill, not a drafting or implementation master.
- `copywriting` owns persona, offer, persuasion sequence, objections, proof strategy, and CTA progression; `copy` remains the owner of clarity, wording, grammar, microcopy, and bounded rewrites.
- Exactly one substantive mode and one local playbook are selected per invocation.
- Project-specific facts and wording never become shared doctrine.
- The shared framework does not duplicate the inspiration taxonomy, editorial corpus, content scoring schema, or generic decision-quality doctrine.
- Missing evidence cannot be disguised through persuasive language or section rearrangement.
- Existing dispatcher safety, chantier, report, documentation, and validation gates remain intact.

## Links & Consequences

- Upstream: operator intent, current `009-sg-marketing` mode detection, business/product/brand/GTM contracts, page-intent map, claim register, and optional selected inspiration references.
- Primary owner path: `009-sg-marketing copywriting` -> `copywriting-audit-playbook.md` -> shared landing-page framework.
- Downstream: strategic landing audit reports, optional bounded copy remediation, editorial follow-up, `103-sg-verify`, and future `104-sg-end`/`005-sg-ship` lifecycle stages.
- Regression risk: broad loader language could activate the framework for articles or microcopy; tests must keep the trigger landing-specific.
- Regression risk: a new shared reference could become a second playbook; tests and wording must preserve one local playbook plus one shared doctrine.
- Regression risk: changes could blur copy/copywriting ownership or public mode grammar; the existing dispatcher suite remains mandatory.
- No data, auth, payment, provider, runtime, SEO, performance, accessibility, or deployment behavior changes.

## Documentation Coherence

- The new shared reference is the canonical internal documentation for landing-page sequence and repetition control.
- The local copywriting playbook documents only when and how `009-sg-marketing` applies the shared doctrine.
- `009-sg-marketing/SKILL.md` exposes only the activation-critical loader and owner boundary.
- Do not copy the doctrine into `design-inspiration-library.md`, `content-quality-rubric.md`, `editorial-content-corpus.md`, or the copywriting playbook.
- Public documentation, operator guides, README, FAQ, pricing, onboarding, and support are not changed because the public mode grammar and user promise remain stable. If implementation discovers public discovery drift, stop and route a separate documentation update rather than expanding this chantier silently.
- The marketing migration evidence remains unchanged because the framework is additive doctrine, not a change to retired-contract preservation or public taxonomy.

## Edge Cases

- A page repeats the same benefit in the hero, benefit cards, feature cards, pricing, and final CTA with only cosmetic rewording.
- A later repetition is justified because it adds a testimonial, quantified product proof, objection answer, or pricing consequence.
- A sparse landing page has no separate problem or objection section because the intended buyer is already solution-aware and evidence is stronger than agitation.
- A long offer requires several proof points, but available proof is weak or unverified.
- A request says "improve the landing copy" without choosing `copy` or `copywriting`; the existing focused routing question remains authoritative.
- A `copywriting` target is an article, email, or persona document rather than a landing, sales, or offer page; the shared landing framework is not loaded automatically.
- The operator requests inspiration but selects no private reference; analysis continues from project/product/brand evidence without silently choosing one.
- A project lacks a brand or claim register; the result remains confidence-limited and routes the missing governance rather than inventing a voice or proof.
- ReplayGlowz source material is available locally; it may support provenance in the spec but must not be loaded as reusable wording or included in the shared reference.

## Implementation Tasks

- [x] Task 1: Create the canonical shared landing-page copywriting framework.
  - File: `skills/references/landing-page-copywriting-framework.md`
  - Action: Define triggers, required inputs, reader-question argument spine, section-role ledger, repetition and claim ledgers, CTA/proof/objection sequencing, `Landing Sequence Plan`, error behavior, owner boundaries, and the four pressure scenarios.
  - User story link: Converts project learning into reusable, project-neutral doctrine.
  - Depends on: None.
  - Validate with: `python3 -m unittest tools.test_landing_page_copywriting_framework_contract`
  - Notes: Link to the inspiration, editorial, scoring, and decision-quality contracts; do not reproduce their detailed taxonomies or ReplayGlowz copy.

- [x] Task 2: Apply the framework through the existing copywriting playbook.
  - File: `skills/009-sg-marketing/references/copywriting-audit-playbook.md`
  - Action: Add a bounded landing-framework gate, loader conditions, existing-page sequence analysis, `keep|move|merge|delete|create` output rules, evidence limits, and the distinction between strategic sequence recommendations and sentence-level copy work.
  - User story link: Makes the reusable doctrine followable from the existing public copywriting mode.
  - Depends on: Task 1.
  - Validate with: `python3 -m unittest tools.test_landing_page_copywriting_framework_contract tools.test_009_sg_marketing_contract`
  - Notes: Keep the local playbook concise and refer to the shared framework instead of repeating it.

- [x] Task 3: Add the compact activation pointer without changing public grammar.
  - File: `skills/009-sg-marketing/SKILL.md`
  - Action: Add one conditional shared-gate rule that loads the framework for landing/sales/offer copywriting targets or explicit section-flow/repetition requests, while preserving exactly four modes and one local playbook.
  - User story link: Lets a fresh agent discover the doctrine at the right activation point.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 -m unittest tools.test_landing_page_copywriting_framework_contract tools.test_009_sg_marketing_contract`
  - Notes: Do not add a mode, alias, drafting promise, or long framework summary to the activation body.

- [x] Task 4: Add focused scenario-first mechanical coverage.
  - File: `tools/test_landing_page_copywriting_framework_contract.py`
  - Action: Assert the canonical loader, one-playbook invariant, section-plan contract, repetition materiality, claim safety, ReplayGlowz-copy exclusion, reference layering, and `LPF-LOAD`, `LPF-SEQUENCE`, `LPF-DEDUPE`, and `LPF-CLAIMS` coverage.
  - User story link: Prevents future compaction from reducing the framework to vague persuasion advice.
  - Depends on: Tasks 1-3.
  - Validate with: `python3 -m unittest tools.test_landing_page_copywriting_framework_contract tools.test_009_sg_marketing_contract`
  - Notes: Inspect canonical text contracts; do not require product-specific ReplayGlowz fixtures.

- [x] Task 5: Run focused documentation, budget, and runtime-discovery validation.
  - File: `skills/references/landing-page-copywriting-framework.md`, `skills/009-sg-marketing/SKILL.md`, `skills/009-sg-marketing/references/copywriting-audit-playbook.md`, and the owner-written refresh trace in `skills/REFRESH_LOG.md`.
  - Action: Run metadata lint, targeted overlap/stale-wording scans, skill budget, runtime sync for `009-sg-marketing`, and `git diff --check`; run the required conservative refresh and record its trace without expanding the framework scope; record any non-blocking shared-rubric opportunity separately rather than editing it without evidence.
  - User story link: Proves the doctrine is valid, compact, discoverable, and bounded to the accepted owner path.
  - Depends on: Tasks 1-4.
  - Validate with: Commands in `Test Strategy`.
  - Notes: Conservative `900-shipglows-core refresh 009-sg-marketing` review precedes final `103-sg-verify`; no commit or push without explicit authorization.

## Acceptance Criteria

- [x] AC 1 — `LPF-LOAD`: Given `009-sg-marketing copywriting` targets a landing, sales, or offer page or explicitly asks about its section flow, when mode and scope are resolved, then exactly one local playbook loads the canonical shared landing framework and no new public mode or implicit second marketing pass is created.
- [x] AC 2 — `LPF-SEQUENCE`: Given a landing page with a known audience, awareness level, offer, conversion goal, objections, and available proof, when the framework analyzes it, then the output provides an argument spine and ordered `Landing Sequence Plan` in which each retained or created section has a distinct reader question, unique job, transition, evidence role, and CTA role.
- [x] AC 3 — `LPF-DEDUPE`: Given the same benefit or promise appears across hero, cards, features, pricing, or CTA sections, when the repetition ledger is built, then one occurrence becomes authoritative and each later occurrence is merged, deleted, moved, or retained only with an explicit added proof, specificity, contrast, objection, recap, or decision value.
- [x] AC 4 — `LPF-CLAIMS`: Given the desired sequence would benefit from a testimonial, user count, conversion result, guarantee, urgency, price, or capability that lacks current project evidence, when the framework builds recommendations, then it records a proof gap or claim mismatch, does not invent or strengthen the claim, and still proposes the strongest honest sequence supported by available evidence.
- [x] AC 5: Given ReplayGlowz source copy or page structure informed the original insight, when the shared framework is written, then it contains only transferable principles and synthetic or abstract examples, with no project-specific ReplayGlowz phrasing, testimonials, product claims, or section text.
- [x] AC 6: Given a `copywriting` target is not a landing, sales, or offer page and does not explicitly concern page-section flow, when the local playbook runs, then it follows its existing audit contract without loading or forcing the landing framework.
- [x] AC 7: Given a request is primarily sentence-level clarity, grammar, microcopy, or rewriting, when ownership is resolved, then `copy` remains the owner and `copywriting` does not duplicate a full copy audit or run both modes automatically.
- [x] AC 8: Given the framework needs inspiration patterns, when private references are considered, then the existing Inspiration Gate limits the shortlist to at most five IDs, requires operator selection before bundle loading, and transfers patterns without source phrasing.
- [x] AC 9: Given implementation completes, when focused validation runs, then the new contract tests and existing `009-sg-marketing` tests pass, metadata is valid, the activation contract stays within budget, runtime discovery resolves `009-sg-marketing`, and no forbidden fifth mode or content-rubric mutation appears.

## Test Strategy

- Scenario/unit contract: `python3 -m unittest tools.test_landing_page_copywriting_framework_contract tools.test_009_sg_marketing_contract`
- Metadata: `python3 tools/shipglows_metadata_lint.py skills/references/landing-page-copywriting-framework.md skills/009-sg-marketing/SKILL.md skills/009-sg-marketing/references/copywriting-audit-playbook.md`
- Focused overlap and loader scan: `rg -n -i "landing|copywriting|persuasion|flow|repetition|section|claim|proof|objection|cta|ReplayGlowz" skills/references/landing-page-copywriting-framework.md skills/009-sg-marketing/SKILL.md skills/009-sg-marketing/references/copywriting-audit-playbook.md`
- Forbidden public-mode scan: `rg -n "argument-hint|market <target>|gtm <target>|copy <target>|copywriting <target>|new mode|landing mode" skills/009-sg-marketing/SKILL.md tools/test_009_sg_marketing_contract.py tools/test_landing_page_copywriting_framework_contract.py`
- Budget: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- Runtime discovery: `tools/shipglows_sync_skills.sh --check --skill 009-sg-marketing`
- Diff hygiene: `git diff --check`
- Manual/browser/device/hosted: not applicable; semantic review of AC 1 through AC 9 is sufficient for the instruction contract.

## Risks

- Security impact: None, because the framework adds no external access, credential flow, persistence, or new private-data boundary; optional inspiration continues to read only the bounded index until the operator selects reference IDs, and source bundles, phrasing, and sensitive browser artifacts remain governed by the existing Inspiration Gate.
- A rigid framework could reduce conversion quality across audiences with different awareness or proof needs. Mitigation: reader-question and evidence-driven sequencing, not a mandatory section list.
- The shared doctrine could duplicate the design inspiration taxonomy or editorial/claim contracts. Mitigation: link those owners and mechanically check for compact reference boundaries.
- `copy` and `copywriting` ownership could blur further. Mitigation: explicit local owner boundaries plus existing dispatcher regression tests.
- Repetition control could remove useful proof or decision-stage recap. Mitigation: preserve later mentions when their added material value is named in the repetition ledger.
- Persuasion guidance could encourage unsupported claims, fake urgency, or fabricated social proof. Mitigation: `LPF-CLAIMS`, existing claim gates, and blocked/confidence-limited error behavior.
- Project-specific ReplayGlowz wording could leak into shared doctrine. Mitigation: no project fixtures, no copied text, synthetic/abstract examples only, and a mechanical exclusion assertion.
- The new reference could become an implicit second local playbook. Mitigation: keep it as shared doctrine, retain exactly one local playbook selection, and test loader order.
- Updating the shared content rubric without need could create cross-skill schema churn. Mitigation: keep it read-only and out of scope for this initial qualitative framework.

## Execution Notes

- Read first: `skills/009-sg-marketing/SKILL.md`, `skills/009-sg-marketing/references/copywriting-audit-playbook.md`, `skills/references/skill-instruction-layering.md`, `skills/references/design-inspiration-library.md`, `skills/references/content-quality-rubric.md`, and `skills/references/editorial-content-corpus.md`.
- Proof path: `scenario-first` with the four named pressure scenarios before contract edits.
- Implementation order: shared doctrine -> local copywriting adaptation -> compact activation pointer -> focused tests -> metadata/budget/runtime checks -> conservative refresh -> verification.
- Framework structure: activation and owner boundary stay in `SKILL.md`; landing-specific application stays in the local playbook; reusable sequence, ledger, materiality, and pressure scenarios stay in the shared reference.
- Content-quality decision: do not edit `content-quality-rubric.md` in this chantier. Its score is optional, its current `other` surface remains usable when explicitly requested, and the sequence plan does not require a new persisted scoring schema. Route a separate spec only if future evidence shows a first-class landing surface is needed across content skills.
- Do not load or reproduce ReplayGlowz page copy during implementation; the accepted learning is structural and already captured in this spec.
- Do not edit `copy-audit-playbook.md`, public docs, business contracts, project pages, site code, plugin packaging, or trackers.
- No new package, provider, migration, runtime service, browser surface, or external documentation is needed.
- Runtime model recommendation: `gpt-5.5` with high reasoning for the spec/readiness and shared-doctrine design; recommendation only because the current runtime cannot apply an override. Use the Codex implementation profile with medium reasoning for bounded implementation if the execution owner cannot apply the recommended model.
- Stop and reroute if implementation requires a new public mode, changes `copy` ownership, needs project-specific ReplayGlowz copy, introduces a shared rubric schema change, weakens claim or inspiration safeguards, or cannot prove all four pressure scenarios mechanically.
- After implementation, run `/900-shipglows-core refresh 009-sg-marketing`, then `/103-sg-verify Reusable Landing-Page Copywriting Framework` before closure.

## Open Questions

None. The operator confirmed the reusable-doctrine direction, owner skill, no-new-mode boundary, and no-copying constraint on 2026-07-17.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-07-17 14:03:17 UTC | 100-sg-spec | GPT-5 Codex | Created the durable contract for a reusable landing-page copywriting framework, 009-sg-marketing application, scenario-first proof, and project-copy exclusion. | draft | /101-sg-ready Reusable Landing-Page Copywriting Framework |
| 2026-07-17 14:08:08 UTC | 101-sg-ready | GPT-5 Codex | Ran the strict readiness gate across structure, user-story traceability, LPF scenario proof, owner and language boundaries, claim and inspiration safety, task order, documentation/runtime consequences, and adversarial failure paths; clarified the refresh trace and no-new-security-boundary rationale. | ready | /102-sg-start Reusable Landing-Page Copywriting Framework |
| 2026-07-17 14:28:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the shared framework, bounded marketing loader and playbook integration, focused LPF contract tests, and local validation without changing public mode grammar or project copy. | implemented | /900-shipglows-core refresh 009-sg-marketing |
| 2026-07-17 14:28:00 UTC | 900-shipglows-core | GPT-5 Codex | Ran conservative refresh, corrected and re-proved the explicit bounded-target loader boundary, recorded the refresh trace, and passed focused tests, metadata, budget, audit, and runtime sync checks. | clear | /103-sg-verify Reusable Landing-Page Copywriting Framework |
| 2026-07-17 14:31:46 UTC | 103-sg-verify | GPT-5 Codex | Ran `mode=standard` scenario-first verification against the implementation, user story, Success/Error Behavior, AC 1-9, task application, structure replacement, shortcut, decision-quality, closure, skill-coherence, language, claim/inspiration, metadata, documentation, local-runtime, and proof-surface gates. | verified | /104-sg-end Reusable Landing-Page Copywriting Framework |
| 2026-07-17 14:35:03 UTC | 104-sg-end | GPT-5 Codex | Closed the verified local chantier by synchronizing the canonical spec flow and adding one evidence-bounded changelog entry without changing trackers or claiming commit, push, deployment, or a production marketing outcome. | closed | /005-sg-ship Reusable Landing-Page Copywriting Framework |
| 2026-07-17 14:40:42 UTC | 005-sg-ship | GPT-5 Codex | Ran the quick ship gates, committed the exact seven-path chantier scope, and pushed the current branch to its upstream without force. | shipped | none |

## Current Chantier Flow

- `100-sg-spec`: ready contract created for the reusable doctrine, bounded 009 application, project-copy exclusion, and scenario-first proof.
- `101-sg-ready`: ready — structure, AC 1-9, LPF scenarios, owner boundaries, claim/inspiration safety, documentation/runtime consequences, and autonomous execution path passed.
- `102-sg-start`: implemented — all five task slices complete with scenario-first contract proof and no public-mode change.
- `900-shipglows-core refresh`: clear — one review finding corrected; no hard or review findings remain.
- `103-sg-verify`: verified (`mode=standard`) — AC 1-9, LPF and dispatcher contracts, claim/inspiration safety, metadata, skill audit/budget, local runtime sync, and diff hygiene passed; no excellence claim was made.
- `104-sg-end`: closed — verified implementation, spec flow, and bounded changelog framing are synchronized; no tracker, shipment, deployment, or production-outcome claim was added.
- `005-sg-ship`: shipped — exact seven-path scope committed and pushed to the current branch upstream without force; no deployment or production marketing outcome is claimed.

Next step: none
