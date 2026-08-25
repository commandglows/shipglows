---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-24"
created_at: "2026-08-24 19:23:00 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 21:28:38 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: gpt-5
scope: extensible-ux-reference-intelligence
owner: Diane
user_story: "As a ShipGlows operator building applications for varied audiences, I want agents to compare familiar real-world UX conventions across replaceable reference sources, so each product is immediately understandable without becoming generic or copying another product."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/ux-reference-intelligence.md
  - skills/references/ux-reference-connectors.md
  - skills/references/resource-discovery.md
  - skills/references/design-inspiration-library.md
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - plugins/shipglows/skills/shipglows/references/public-help-catalog.md
  - /home/claude/shipglows_app/site/src/content/skills/sg-design.md
  - /home/claude/shipglows_app/site/src/content/skills/sg-customer.md
  - tools/test_ux_reference_intelligence_contract.py
depends_on:
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "2.0.0"
    required_status: active
  - artifact: skills/references/documentation-freshness-gate.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-24: ShipGlows will build applications for many audiences and needs common, already-understood usage conventions."
  - "Operator decision 2026-08-24: the system must accept additional inspiration sources later rather than binding the design workflow to Mobbin."
  - "Mobbin official documentation reviewed 2026-08-24: its remote MCP exposes screen, flow, and website-section search to AI agents on paid plans."
  - "Operator decision 2026-08-24: Checklist Design will be used as an indicator among other evidence, never as an exhaustive requirement source."
  - "Checklist Design public catalog reviewed 2026-08-24: it groups UX/UI checklist items by pages, components, flows, topics, brands, and design-system concerns."
  - "Operator decision 2026-08-24: cross-skill activation must make relevant external experience tools and references discoverable according to availability and current chantier fit."
  - "Collect UI public pages were reachable on 2026-08-24, but its statistics reported zero shots published yesterday and during the previous week; it remains ineligible by default for current-pattern claims."
next_step: "Deliver the validated editorial alignment in both governed repositories."
---

# Extensible UX Reference Intelligence

## Title

Extensible UX Reference Intelligence

## Status

ready

## User Story

As a ShipGlows operator building applications for varied audiences, I want agents to compare familiar real-world UX conventions across replaceable reference sources, so each product is immediately understandable without becoming generic or copying another product.

## Minimal Behavior Contract

When construction, specification, design, or customer-experience work changes a product journey, navigation model, common interaction, or visual direction, ShipGlows classifies the UX question, discovers the shared source contract, and queries only sources whose capabilities, availability, freshness, eligibility, and rights fit it. If a source is unavailable, unauthorized, contradictory, stale, or rights-restricted, the system reports that state and continues through another eligible source, platform guidance, project evidence, or the private library without inventing evidence. The easily missed case is an accessible visual archive whose current maintenance is unproven: reachability never promotes it into evidence of current conventions.

## Success Behavior

- Trigger: a material UX convention, flow, interaction, or visual-direction decision needs external reference evidence.
- Operator result: a short comparison explains which conventions are common, why they fit the product, which differences matter, and what must remain original.
- System effect: sources are replaceable adapters; normalized observations feed the existing Inspiration Gate and project specification without making a provider a source of truth.
- Success proof: focused pressure scenarios cover zero, one, and multiple providers; conflicting evidence; rights restrictions; accessibility conflict; and provider outage.

## Error Behavior

- Expected failures: no callable source, expired authorization, paywall, rate limit, unsupported query, stale catalog, conflicting patterns, or unusable rights terms.
- Operator response: receive the limitation and the strongest available fallback, without being asked to debug provider mechanics.
- System effect: preserve provenance, never fabricate a screen or convention, and never silently downgrade from comparison to imitation.
- Must never happen: scrape authenticated content, expose tokens or sessions, redistribute protected captures, copy distinctive interfaces or assets, claim frequency as usability proof, or make one vendor mandatory for ShipGlows design work.

## Problem

The provider-neutral contract exists, but only the design engine activates it directly and its connector catalog is design-local. Construction, specification, and customer-experience skills can therefore miss the shared source system, while an accessible but stale public gallery lacks a machine-followable ineligibility decision.

## Solution

Promote the connector catalog to the shared reference layer, keep Mobbin as the first documented connector, add exact cross-skill activation for construction, specification, design, and customer experience, and separate availability, freshness, and eligibility. Retain Checklist Design and the private corpus within their existing boundaries; catalogue Collect UI as accessible but freshness-unverified and ineligible by default.

## Scope In

- Provider-neutral source capabilities and lifecycle states.
- A normalized reference observation schema covering provenance, platform, task, pattern, evidence, limits, accessibility, and anti-copy guidance.
- Source selection, bounded comparison, confidence, conflict resolution, fallback, and operator selection.
- Connector classes for MCP, API, public web, manual URL, platform guidance, and private corpus.
- Mobbin as the first documented external connector, without installation or authentication.
- Cross-skill activation through `sg-development`, `sg-design`, `sg-experience`, and specification, plus the private design-inspiration library.
- Collect UI as a documented `public-web` archive that is ineligible by default until dated maintenance evidence improves.
- Focused scenario-first tests and metadata/dependency validation.

## Scope Out

- No subscription purchase, billing, OAuth authorization, API key, MCP configuration, dependency installation, or remote account mutation.
- No automated connector implementation or network client in this chantier.
- No bulk screenshot import, authenticated scraping, redistribution, or provider-content mirroring.
- No redesign of a current product and no replacement of project research, accessibility, platform guidance, or user analytics.
- No promise that every catalog supports agent access.
- No installation of Checklist Design agent/Figma skills, plugins, packages, or
  provider integrations.
- No claim that Collect UI is currently maintained or representative of current product conventions.

## Constraints

- Product intent, user evidence, accessibility, platform conventions, and the project design system outrank inspiration frequency.
- A provider must declare capabilities, access method, availability state, provenance, rights boundary, and fallback behavior before use.
- Discovery never grants permission to copy or persist source-derived media.
- The core contract must remain provider-neutral; vendor details stay in the shared connector catalog.
- Existing projects must remain fully operable when no external connector is callable.

## Test Contract

### Surface

- Stack/surface: ShipGlows shared UX doctrine, shared connector catalog, cross-skill activation contracts, and private inspiration corpus contract.
- Primary proof mode: scenario-first contract tests.
- Proof order: focused Python contract test, metadata lint, activation/followability checks, diff review.

### Required evidence stack

- Automated: focused contract assertions for source neutrality, cross-skill activation, Mobbin, Checklist Design, Collect UI freshness ineligibility, normalization, fallback, and rights boundaries.
- Integration: metadata lint and the affected build, design, experience, and spec contract tests.
- Provider: official documentation URLs and dated capability statements only; no live account call is required.
- Browser/auth/device: not applicable because this chantier configures no provider and changes no product runtime.

## Dependencies

- Existing private design-inspiration library contract and Inspiration Gate.
- Existing development, design, experience, and specification owners.
- Current official Mobbin MCP documentation for connector capability and plan availability.
- No runtime package or paid service dependency.

## Invariants

- Source adapters are replaceable and independently available.
- Normalized evidence retains source, retrieval time, access method, confidence, and limitations.
- Common does not mean correct; evidence hierarchy is explicit.
- References inform product-native design and never become foreign implementation specifications.
- Missing sources degrade evidence depth, not the ability to continue safely.
- Operator selection remains required before detailed private or protected references become design direction.

## Links & Consequences

- Upstream: product intent, platform footprint, audience, critical journey, accessibility requirements, and design-system authority define the query.
- Downstream: specs, design decisions, reference-driven frontend work, browser proof, and the private inspiration library consume selected observations.
- Revalidation: connector capability or availability changes require official-document freshness review; provider addition must not change the core schema silently.

## Documentation Coherence

- Add the shared UX-reference intelligence contract.
- Promote the connector catalog to shared ownership with Mobbin as the first documented adapter.
- Update the private inspiration library to declare its adapter role and preserve its stricter storage/rights rules.
- Update construction, specification, design, and experience activation maps without adding a new public mode.
- Align the public design and experience skill pages plus shared help with the new source-discovery behavior, while keeping every provider optional and availability-dependent.
- No provider-specific marketing claim, guaranteed integration, or new operator command is introduced.

## Edge Cases

- No external provider is callable.
- Exactly one source returns one relevant flow.
- Several sources return materially different conventions.
- A popular pattern conflicts with accessibility or platform guidance.
- A provider is available in documentation but not exposed in the current agent session.
- A provider requires paid access or OAuth.
- A public URL disallows automated capture or requires authentication.
- A source returns screenshots without enough task or state context.
- The same screen appears through several aggregators and must not be counted as independent evidence.
- User analytics contradict gallery prevalence.
- A public gallery is reachable but its publication cadence is contradicted by its own statistics.

## Implementation Tasks

- [x] Task 1: Add the provider-neutral UX-reference intelligence contract.
  - Target: `skills/references/ux-reference-intelligence.md`
  - Action: define activation, source adapters, normalized observation schema, evidence hierarchy, comparison, fallback, rights, and stop conditions.
  - User story link: makes common UX conventions reusable without vendor lock-in.
  - Depends on: ready spec.
  - Validate with: `python3 tools/test_ux_reference_intelligence_contract.py`.
- [x] Task 2: Document the first connector and future adapter boundary.
  - Target: `skills/references/ux-reference-connectors.md` (promoted from its original design-local location by Task 6).
  - Action: document connector states and Mobbin MCP capabilities, access boundary, freshness evidence, safe use, and fallback; keep other providers as future adapters rather than promised integrations.
  - User story link: makes Mobbin useful now while preserving extensibility.
  - Depends on: Task 1.
  - Validate with: focused contract test and metadata lint.
- [x] Task 3: Integrate with design activation and the private corpus.
  - Target: `skills/006-sg-design/SKILL.md`, `skills/references/design-inspiration-library.md`
  - Action: load the shared contract for material UX-reference decisions and identify the private corpus as a stricter first-party adapter.
  - User story link: makes the capability reachable from ordinary design work.
  - Depends on: Tasks 1-2.
  - Validate with: focused contract test and `tools/test_sg_design_contract.py`.
- [x] Task 4: Add focused mechanical proof and complete lifecycle evidence.
  - Target: `tools/test_ux_reference_intelligence_contract.py`, this spec.
  - Action: assert provider neutrality, source-state distinction, evidence priority, fallback, anti-copy, connector facts, and fresh-agent followability.
  - User story link: prevents a Mobbin-only or inspiration-as-authority regression.
  - Depends on: Tasks 1-3.
  - Validate with: focused test, metadata lint, affected design test, and diff review.
- [x] Task 5: Admit Checklist Design as a bounded public-web indicator.
  - Target: `skills/references/ux-reference-intelligence.md`, the connector catalog, `tools/test_ux_reference_intelligence_contract.py`, this spec.
  - Action: define the checklist-source boundary, document the public-web adapter, prohibit exhaustive import and proof-by-checkbox, and pass only selected product scenarios into specification and verification.
  - User story link: expands functional scenario awareness without allowing a catalog to drive product scope or quality claims.
  - Depends on: Tasks 1-4 and operator approval on 2026-08-24.
  - Validate with: focused checklist pressure scenarios, metadata lint, affected design test, and diff review.
- [x] Task 6: Promote the connector catalog to shared ownership.
  - Target: shared UX connector catalog and every canonical reference to its former design-local path.
  - Action: move provider facts into one cross-skill catalog and preserve the existing source-neutral decision algorithm.
  - User story link: makes source knowledge discoverable beyond design without duplicating provider details.
  - Depends on: Tasks 1-5 and operator approval on 2026-08-24.
  - Validate with: focused path, metadata, dependency, and exact-resource discovery checks.
- [x] Task 7: Add cross-skill activation.
  - Target: construction, specification, design, customer-experience, and progressive resource-discovery contracts.
  - Action: load the shared intelligence and connector catalog only for material experience-reference decisions before implementation scope freezes.
  - User story link: makes ordinary app work use relevant sources without requiring a Mobbin-specific command.
  - Depends on: Task 6.
  - Validate with: fresh-agent activation pressure scenarios and affected skill contracts.
- [x] Task 8: Separate source availability, freshness, and eligibility.
  - Target: shared core, shared catalog, and focused tests.
  - Action: classify Collect UI as accessible, freshness-unverified, and ineligible by default after public statistics showed no recent publication activity.
  - User story link: proves the system can discover a source and correctly decide not to use it.
  - Depends on: Task 6.
  - Validate with: `UXREF-ACCESSIBLE-STALE` and Collect UI profile assertions.
- [x] Task 9: Verify and close the cross-skill extension.
  - Target: focused tests, metadata, resource graph, budgets, runtime sync, this spec, and exact-scope Git delivery.
  - Action: prove followability, record the final lifecycle evidence, commit, and push the bounded change.
  - User story link: leaves the architecture remotely durable and usable by fresh agents.
  - Depends on: Tasks 6-8.
  - Validate with: the complete proof stack declared for this extension.
- [x] Task 10: Align declared public skill behavior.
  - Target: public design and experience skill pages, shared public help, and this spec.
  - Action: explain bounded cross-source convention evidence without naming or guaranteeing a provider; preserve product truth, user evidence, accessibility, platform guidance, and verified behavior as higher authorities.
  - User story link: makes the capability understandable to operators without overstating availability or turning reference catalogs into requirements.
  - Depends on: Tasks 7-9 and operator approval on 2026-08-24.
  - Validate with: Astro content/schema checks, focused wording assertions, and public-surface diff review.

## Acceptance Criteria

- [x] AC 1: A fresh agent can resolve a UX question through zero, one, or several eligible sources without requiring Mobbin.
- [x] AC 2: Mobbin is represented as one external MCP connector with documented plan/auth boundaries and no implied installation.
- [x] AC 3: Every normalized observation retains provenance, task context, platform, states, confidence, accessibility notes, limitations, and anti-copy guidance.
- [x] AC 4: Product/user evidence, accessibility, platform guidance, and project design authority outrank pattern prevalence.
- [x] AC 5: Unavailable, unauthenticated, rate-limited, rights-restricted, or conflicting sources produce explicit fallback behavior rather than fabricated evidence.
- [x] AC 6: The private inspiration library remains separately stored and governed by its stricter capture, rights, approval, and takedown contract.
- [x] AC 7: A new provider can be added by documenting one adapter profile without rewriting the shared decision algorithm or public skill surface.
- [x] AC 8: Focused tests and metadata lint pass, and no account, dependency, provider, deployment, or provider-specific availability claim is mutated.
- [x] AC 9: Checklist Design is represented as one `public-web` connector and one indicator among other evidence.
- [x] AC 10: Checklist items remain candidates until tied to a concrete product responsibility and filtered through higher authorities.
- [x] AC 11: No full-list import, proof-by-checkbox, unsupported claim promotion, or external skill/plugin installation occurs.
- [x] AC 12: Cross-skill activation makes the shared contract and catalog reachable from construction, specification, design, and customer-experience work.
- [x] AC 13: Availability, freshness, and eligibility remain separate; an accessible but stale source can be rejected without disabling the architecture.
- [x] AC 14: Collect UI remains ineligible by default and can be used only as an explicitly labelled manual visual archive, never as evidence of current conventions or real-product flows.
- [x] AC 15: Implementation consumes selected observations from the ready contract rather than reopening unbounded inspiration discovery during coding.
- [x] AC 16: Public design, experience, and help surfaces describe optional, availability-dependent reference evidence without promising a provider or weakening higher product authorities.

## Test Strategy

- Unit: focused textual contract tests for normative markers and source state semantics.
- Integration: affected build, design, experience, and spec contract tests plus metadata/dependency validation for changed artifacts.
- Manual: inspect the diff for provider leakage into the core, duplicated Inspiration Gate rules, unsupported provider promises, and weak rights boundaries.

## Risks

- Vendor lock-in: mitigated by provider-neutral core and adapter-local details.
- Generic design convergence: mitigated by explicit product/brand authority and anti-copy translation.
- False consensus: mitigated by source deduplication and prevalence-not-proof rules.
- Copyright/terms: mitigated by provenance, no authenticated scraping, no redistribution, and provider-specific access boundaries.
- Credential/session exposure: no credentials are configured; future connectors must use provider-supported authorization and never persist secrets in design artifacts.
- Staleness: provider claims carry official source URLs and review dates.
- Reachability bias: mitigated by separate availability, freshness, and eligibility decisions and Collect UI's ineligible-by-default profile.

## OWASP Security Gate

- Categories considered: A02 Security Misconfiguration, A05 Injection, A06 Insecure Design, A07 Authentication Failures, A08 Software or Data Integrity Failures, A10 Mishandling of Exceptional Conditions.
- Trust/data boundaries: agent to external source; OAuth/API credentials; untrusted query/result content; protected screenshots; project/private corpus boundary.
- ASVS: not applicable at requirement level because no application integration or credential handling is implemented in this chantier.
- Proof: contract scenarios prohibit secret persistence, authenticated scraping, untrusted-source authority, silent fallback, and protected-content redistribution.
- Residual gap: a future live connector requires its own provider-specific security and runtime proof before activation.

## ZOMBIES Coverage

- Zero: no available sources uses project truth, platform guidance, and the private approved index without fabricating consensus.
- One: one eligible source yields a labelled observation, not a universal convention claim.
- Many: several sources are deduplicated and compared; disagreement remains visible.
- Boundaries: provider count, result limit, authorization, rights, freshness, and confidence boundaries are explicit.
- Interfaces: MCP/API/web/manual/platform/private-corpus adapters normalize into one observation contract.
- Exceptions: outage, auth expiry, rate limit, unsupported query, partial result, stale evidence, and accessibility conflict fail safely.
- Simple scenarios: Mobbin, Checklist Design, Collect UI, and the existing private corpus exercise callable, candidate-only, accessible-but-ineligible, and private-corpus paths without making any one source mandatory.

## Execution Notes

- Read first: the existing design-inspiration library, construction/specification/design/experience activation contracts, progressive resource discovery, documentation freshness, rights/private-data contracts, current Mobbin documentation, and current public evidence for checklist/gallery sources.
- Topology: main-only; the change is one cohesive contract stream and delegation would add handoff cost without independent coverage gain.
- Proof path: scenario-first with one focused contract test, metadata lint, affected design test, and diff review.
- Stop if implementation would configure an external account, add a dependency, expose credentials, broaden public promises, duplicate the private corpus, or require provider-specific behavior unsupported by official evidence.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-24 19:23:00 UTC | 100-sg-spec | gpt-5 | Created the provider-neutral UX reference intelligence contract | draft | 101-sg-ready |
| 2026-08-24 19:24:32 UTC | 101-sg-ready | gpt-5 | Reviewed scope, source boundaries, failure semantics, security, documentation consequences, and proof contract | ready | 102-sg-start |
| 2026-08-24 19:27:00 UTC | 102-sg-start | gpt-5 | Added the shared source-neutral contract, Mobbin connector profile, private-corpus bridge, design activation, and focused scenarios | implemented | 103-sg-verify |
| 2026-08-24 19:29:22 UTC | 103-sg-verify | gpt-5 | Verified source-neutral scenarios, design activation, metadata, dependency graph, budgets, runtime visibility, and official provider evidence | verified | 104-sg-end |
| 2026-08-24 19:29:22 UTC | 104-sg-end | gpt-5 | Closed the bounded contract chantier; canonical documentation is aligned and public editorial surfaces are unaffected | closed | 005-sg-ship |
| 2026-08-24 19:29:22 UTC | 005-sg-ship | gpt-5 | Prepared exact-scope final delivery to the configured branch upstream | shipped | Pilot a live connector only after provider selection and authorization |
| 2026-08-24 19:52:13 UTC | 102-sg-start | gpt-5 | Added the checklist-source boundary and Checklist Design public-web adapter profile | implemented | 103-sg-verify |
| 2026-08-24 19:52:13 UTC | 103-sg-verify | gpt-5 | Verified candidate-only semantics, product-responsibility filtering, no proof-by-checkbox, no third-party installation, metadata, and design activation | verified | 104-sg-end |
| 2026-08-24 19:52:13 UTC | 104-sg-end | gpt-5 | Closed the adapter extension with no account, dependency, runtime, or public-surface mutation | closed | 005-sg-ship |
| 2026-08-24 19:52:13 UTC | 005-sg-ship | gpt-5 | Prepared the verified Checklist Design adapter extension for the configured branch upstream | shipped | Recheck public pages at the scheduled freshness review |
| 2026-08-24 20:26:08 UTC | 102-sg-start | gpt-5 | Promoted the connector catalog, added cross-skill activation, and separated availability, freshness, and eligibility | implemented | 103-sg-verify |
| 2026-08-24 20:26:08 UTC | 103-sg-verify | gpt-5 | Verified 97 focused scenarios, metadata, resource graph, invocation graph, budgets, skill audit, exact resource IDs, and public runtime routes | verified | 104-sg-end |
| 2026-08-24 20:26:08 UTC | 104-sg-end | gpt-5 | Initially closed the cross-skill extension before the public-skill behavior impact was reclassified | superseded | Align declared public skill surfaces |
| 2026-08-24 20:26:08 UTC | 005-sg-ship | gpt-5 | Prepared exact-scope final commit and ordinary push to the configured main upstream | shipped | Revalidate source eligibility when dated evidence or runtime callability changes |
| 2026-08-24 21:26:06 UTC | 007-sg-content | gpt-5 | Reclassified the behavior change as editorially relevant and aligned design, experience, and shared-help promises without guaranteeing providers | implemented | Validate both public-content delivery surfaces |
| 2026-08-24 21:28:38 UTC | 103-sg-verify | gpt-5 | Verified Astro schema, 42 site tests, the public build, 29 focused contracts, metadata, packaging, provider-neutral wording, and the 749-artifact dependency graph | verified | Deliver exact-scope commits in both repositories |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready; the contract is autonomous, provider-neutral, and implementation-safe.
- `102-sg-start`: implemented; all ten bounded tasks are complete.
- `103-sg-verify`: verified; the original contract proof plus Astro schema, 42 site tests, public build, packaging, provider-neutral wording, metadata, and dependency graph pass.
- `104-sg-end`: pending re-closure until both validated editorial commits are remotely durable.
- `005-sg-ship`: the prior technical milestone is shipped; the editorial alignment still requires exact-scope delivery in both governed repositories.
- Checklist Design extension: shipped as a bounded `public-web` indicator; no
  provider package, skill, plugin, account, or runtime connector was installed.

Next step: Deliver the validated editorial alignment in both governed
repositories, then resume source-eligibility review only when dated provider
evidence or current runtime callability changes. Any connector installation
still requires separate approval.
