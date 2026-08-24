---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-24"
updated: "2026-08-24"
status: active
source_skill: 006-sg-design
scope: ux-reference-connectors
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/references/ux-reference-intelligence.md
  - skills/references/design-inspiration-library.md
depends_on:
  - artifact: skills/references/ux-reference-intelligence.md
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Mobbin Docs, Overview, reviewed 2026-08-24: https://docs.mobbin.com/overview"
  - "Mobbin Docs, MCP Introduction, reviewed 2026-08-24: https://docs.mobbin.com/mcp/introduction"
  - "Mobbin Docs, MCP Features, reviewed 2026-08-24: https://docs.mobbin.com/mcp/features"
  - "Checklist Design public catalog, reviewed 2026-08-24: https://www.checklist.design/"
  - "Checklist Design browse index, reviewed 2026-08-24: https://www.checklist.design/browse"
next_review: "2026-09-24"
next_step: "Recheck provider documentation and public-page behavior before configuring or automating any connector."
---

# UX Reference Connectors

## Purpose

This catalog owns provider-specific facts for the shared UX-reference
intelligence contract. A catalog entry documents an adapter; it does not prove
that the adapter is configured or callable in the current agent session.

Before live use, apply the documentation freshness gate and current runtime
awareness. Distinguish `documented`, `configured`, `callable`, `failed`,
`not-exposed`, `auth-required`, `paywalled`, `rate-limited`, and `retired`.

## Mobbin MCP

### Identity And Evidence

- Source ID: `mobbin-mcp`
- Adapter class: `mcp`
- Provider: Mobbin
- Official overview: `https://docs.mobbin.com/overview`
- Official MCP introduction: `https://docs.mobbin.com/mcp/introduction`
- Official feature reference: `https://docs.mobbin.com/mcp/features`
- Remote endpoint documented by Mobbin: `https://api.mobbin.com/mcp`
- Last reviewed: `2026-08-24`
- Freshness verdict: `fresh-docs checked`

### Documented Capabilities

Mobbin documents natural-language tools for UI screens, multi-step user flows,
and website sections. Its MCP responses can include screen images for agent
consumption. The documented tool surface is:

- `search_screens`: UI screens;
- `search_flows`: journeys such as onboarding and checkout;
- `search_sections`: website sections such as pricing pages and footers.

Mobbin documents MCP availability for Pro, Team, and Enterprise plans, with
OAuth handled by compatible MCP clients. The REST API is a different adapter
and is documented for Team and Enterprise plans; do not silently substitute it
for MCP.

### Supported Query Dimensions

- platform when supported by the provider query;
- user task or flow such as onboarding, authentication, search, purchase,
  checkout, settings, subscription, or recovery;
- UI screen, multi-step flow, or web section;
- product/application category and natural-language qualifiers.

Provider results must be normalized through the shared observation contract.
Do not infer unreturned states, accessibility quality, product success, user
preference, or independent consensus from Mobbin ranking or catalog presence.

### Access And Runtime Boundary

- Documentation state: `documented`.
- Repository configuration state: not configured by this contract.
- Current-session state: determine at runtime; never inherit `callable` from this
  catalog.
- Authentication: provider-supported OAuth in compatible MCP clients.
- Secrets: no API key, OAuth token, browser profile, or session data belongs in
  ShipGlows contracts, specs, observations, logs, or the private corpus.
- Billing: subscription choice and payment remain operator-owned external actions.

### Safe Use And Persistence

Use Mobbin for bounded discovery and comparison. Retain result links, provider
identity, observed patterns, limitations, and selected principles. Do not bulk
download, mirror, redistribute, publish, or commit provider screenshots unless
Mobbin's current terms and a separately approved persistence contract explicitly
permit the exact use.

Mobbin is never the sole authority for accessibility, platform behavior,
product intent, brand expression, or user outcomes. Translate selected evidence
through the project design system and the reference-driven frontend contract.

### Failure And Fallback

- `not-exposed`: continue through other callable adapters, platform guidance,
  project evidence, and the approved private index.
- `auth-required` or `paywalled`: report the boundary; do not request credentials
  in conversation or use browser-session scraping.
- `rate-limited`, timeout, or provider error: retain the failed state and use
  another eligible source; do not retry without a bounded provider policy.
- no relevant results: state `zero relevant results`; do not broaden the claim or
  replace the product question with visual browsing.

## Private ShipGlows Corpus

- Source ID: `shipglows-private-inspiration`
- Adapter class: `private-corpus`
- Authority: `skills/references/design-inspiration-library.md`
- Query surface: the bounded `index.yaml` of approved or explicitly labelled
  candidate references.
- Runtime state: resolve the canonical private root and exact index; installed
  public tooling does not prove that the private corpus exists.
- Persistence and rights: governed exclusively by the stricter private-library
  contract, including attribution, approval, takedown, private Git, and Git LFS.
- Fallback role: first-party curated evidence when external providers are absent;
  an empty index is not a failure and never creates fabricated consensus.

## Checklist Design Public Web

### Identity And Evidence

- Source ID: `checklist-design-public-web`
- Adapter class: `public-web`
- Provider: Checklist Design
- Public catalog: `https://www.checklist.design/`
- Browse index: `https://www.checklist.design/browse`
- Last reviewed: `2026-08-24`
- Freshness verdict: `fresh-public-pages checked`

### Observed Capabilities

The public catalog groups practical UX/UI checklist items by website page,
component, flow, topic, brand, and design-system concern. It can suggest states
or details worth considering for a bounded product question, including
accessibility, search, checkout, maintenance, and coming-soon experiences.

This profile records only what was observed on public pages. It does not validate
every checklist item, provider claim, statistic, linked template, or implied best
practice, and it does not make catalog coverage evidence of completeness.

### Access And Runtime Boundary

- Documentation state: `documented` from public pages.
- Access method: bounded public-web inspection without authentication bypass,
  bulk capture, or automated mirroring.
- Current-session state: resolve at runtime; a catalog entry does not imply that
  browsing is available or that a page was inspected for the current task.
- Provider skills, agent packages, Figma skills, and plugins are not installed by
  this connector profile; installation requires a separate dependency, security,
  permission, and mutation review.

### Safe Use And Product Filter

Use Checklist Design as an indicator among other evidence. Extract only candidate
scenarios relevant to the current product responsibility, user task, surface,
and risk. Apply the shared Authority Order, retain the source URL, and keep one
catalog as one source regardless of its number of items.

Never import a full checklist, convert every item into scope, claim consensus,
or use completed checkboxes as usability or quality proof. Claims and statistics
remain unverified until independently sourced. Only selected scenarios that fit
the governed product may enter its specification and verification contract.

### Failure And Fallback

- unavailable or blocked public pages: record the limitation and continue with
  project evidence, platform guidance, other eligible adapters, or the private
  corpus;
- irrelevant or over-broad checklist: retain `zero relevant candidates` rather
  than expanding product scope;
- conflict with product truth, accessibility, safety, privacy, or platform
  guidance: reject or adapt the item through the higher authority;
- unclear provenance or unsupported claim: preserve it as unverified context or
  omit it; never promote it into an acceptance criterion.

## Future Connector Admission

Additional MCP, API, public-web, manual, platform-guidance, or private-corpus
sources may be added as separate entries after official capability and rights
review. Each entry must define the complete adapter profile, current evidence,
failure behavior, and fallback. A future source does not require a new public
mode or a change to the shared comparison algorithm unless it exposes a genuinely
new evidence dimension that the normalized observation contract cannot retain.

## Validation

```bash
python3 tools/test_ux_reference_intelligence_contract.py
python3 tools/shipglows_metadata_lint.py skills/006-sg-design/references/ux-reference-connectors.md
```
