---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-24"
created_at: "2026-08-24 19:23:00 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 19:29:22 UTC"
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
  - skills/006-sg-design/references/ux-reference-connectors.md
  - skills/references/design-inspiration-library.md
  - skills/006-sg-design/SKILL.md
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
next_step: "Pilot a live external connector when the operator chooses a provider plan."
---

# Extensible UX Reference Intelligence

## Title

Extensible UX Reference Intelligence

## Status

ready

## User Story

As a ShipGlows operator building applications for varied audiences, I want agents to compare familiar real-world UX conventions across replaceable reference sources, so each product is immediately understandable without becoming generic or copying another product.

## Minimal Behavior Contract

When a design task changes a product journey, navigation model, common interaction, or visual direction, ShipGlows classifies the UX question, queries only sources whose declared capabilities and current availability fit it, normalizes provenance and observations, and presents a bounded comparison before any reference becomes direction. If a source is unavailable, unauthorized, contradictory, stale, or rights-restricted, the system reports that state and continues through another eligible source, platform guidance, project evidence, or the private library without inventing evidence. The easily missed case is a popular pattern that conflicts with accessibility, platform conventions, product intent, or observed user behavior: popularity never overrides those authorities.

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

The private design-inspiration library preserves curated page and copy references, but ShipGlows has no provider-neutral contract for discovering and comparing common application flows across MCP, API, web, manual, platform-guideline, and private-corpus sources. Binding this capability directly to Mobbin would create vendor lock-in and make future sources expensive to add.

## Solution

Add one shared UX-reference intelligence contract, one design-owned connector catalog, and a narrow activation rule in the design engine. Treat Mobbin as the first documented connector and the private library as a first-party corpus adapter. Normalize evidence, not source payloads, and retain the existing operator-selection and anti-copy boundary.

## Scope In

- Provider-neutral source capabilities and lifecycle states.
- A normalized reference observation schema covering provenance, platform, task, pattern, evidence, limits, accessibility, and anti-copy guidance.
- Source selection, bounded comparison, confidence, conflict resolution, fallback, and operator selection.
- Connector classes for MCP, API, public web, manual URL, platform guidance, and private corpus.
- Mobbin as the first documented external connector, without installation or authentication.
- Integration with `sg-design` and the private design-inspiration library.
- Focused scenario-first tests and metadata/dependency validation.

## Scope Out

- No subscription purchase, billing, OAuth authorization, API key, MCP configuration, dependency installation, or remote account mutation.
- No automated connector implementation or network client in this chantier.
- No bulk screenshot import, authenticated scraping, redistribution, or provider-content mirroring.
- No redesign of a current product and no replacement of project research, accessibility, platform guidance, or user analytics.
- No promise that every catalog supports agent access.

## Constraints

- Product intent, user evidence, accessibility, platform conventions, and the project design system outrank inspiration frequency.
- A provider must declare capabilities, access method, availability state, provenance, rights boundary, and fallback behavior before use.
- Discovery never grants permission to copy or persist source-derived media.
- The core contract must remain provider-neutral; vendor details stay in the design-owned connector catalog.
- Existing projects must remain fully operable when no external connector is callable.

## Test Contract

### Surface

- Stack/surface: ShipGlows shared design doctrine, connector catalog, activation contract, and private inspiration corpus contract.
- Primary proof mode: scenario-first contract tests.
- Proof order: focused Python contract test, metadata lint, activation/followability checks, diff review.

### Required evidence stack

- Automated: focused contract assertions for source neutrality, Mobbin profile, normalization, priority, fallback, and rights boundaries.
- Integration: metadata lint and the affected design contract test.
- Provider: official documentation URLs and dated capability statements only; no live account call is required.
- Browser/auth/device: not applicable because this chantier configures no provider and changes no product runtime.

## Dependencies

- Existing private design-inspiration library contract and Inspiration Gate.
- Existing `sg-design` public owner and `006-sg-design` runtime engine.
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
- Add the design-owned connector catalog with Mobbin as the first documented adapter.
- Update the private inspiration library to declare its adapter role and preserve its stricter storage/rights rules.
- Update the design engine activation map without adding a new public mode.
- Public help and marketing claims are not impacted because no new operator command or guaranteed integration is exposed.

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

## Implementation Tasks

- [x] Task 1: Add the provider-neutral UX-reference intelligence contract.
  - Target: `skills/references/ux-reference-intelligence.md`
  - Action: define activation, source adapters, normalized observation schema, evidence hierarchy, comparison, fallback, rights, and stop conditions.
  - User story link: makes common UX conventions reusable without vendor lock-in.
  - Depends on: ready spec.
  - Validate with: `python3 tools/test_ux_reference_intelligence_contract.py`.
- [x] Task 2: Document the first connector and future adapter boundary.
  - Target: `skills/006-sg-design/references/ux-reference-connectors.md`
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

## Acceptance Criteria

- [x] AC 1: A fresh agent can resolve a UX question through zero, one, or several eligible sources without requiring Mobbin.
- [x] AC 2: Mobbin is represented as one external MCP connector with documented plan/auth boundaries and no implied installation.
- [x] AC 3: Every normalized observation retains provenance, task context, platform, states, confidence, accessibility notes, limitations, and anti-copy guidance.
- [x] AC 4: Product/user evidence, accessibility, platform guidance, and project design authority outrank pattern prevalence.
- [x] AC 5: Unavailable, unauthenticated, rate-limited, rights-restricted, or conflicting sources produce explicit fallback behavior rather than fabricated evidence.
- [x] AC 6: The private inspiration library remains separately stored and governed by its stricter capture, rights, approval, and takedown contract.
- [x] AC 7: A new provider can be added by documenting one adapter profile without rewriting the shared decision algorithm or public skill surface.
- [x] AC 8: Focused tests and metadata lint pass, and no account, dependency, provider, deployment, or public claim is mutated.

## Test Strategy

- Unit: focused textual contract tests for normative markers and source state semantics.
- Integration: existing design contract test and metadata/dependency validation for changed artifacts.
- Manual: inspect the diff for provider leakage into the core, duplicated Inspiration Gate rules, unsupported provider promises, and weak rights boundaries.

## Risks

- Vendor lock-in: mitigated by provider-neutral core and adapter-local details.
- Generic design convergence: mitigated by explicit product/brand authority and anti-copy translation.
- False consensus: mitigated by source deduplication and prevalence-not-proof rules.
- Copyright/terms: mitigated by provenance, no authenticated scraping, no redistribution, and provider-specific access boundaries.
- Credential/session exposure: no credentials are configured; future connectors must use provider-supported authorization and never persist secrets in design artifacts.
- Staleness: provider claims carry official source URLs and review dates.

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
- Simple scenarios: Mobbin plus the existing private corpus is the first representative multi-source path.

## Execution Notes

- Read first: the existing design-inspiration library, `006-sg-design`, reference-driven frontend playbook, documentation freshness gate, rights/private-data contract, and current official Mobbin MCP documentation.
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

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready; the contract is autonomous, provider-neutral, and implementation-safe.
- `102-sg-start`: implemented; all four bounded tasks are complete.
- `103-sg-verify`: verified; focused scenarios, design coherence, security boundaries, metadata, dependency graph, budgets, public runtime visibility, and official provider evidence pass.
- `104-sg-end`: closed; documentation updated and no declared public/editorial promise changed.
- `005-sg-ship`: shipped; exact-scope commits are present on the configured upstream.

Next step: Pilot a live external connector when the operator chooses a provider plan and authorizes account configuration.
