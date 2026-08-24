---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: ShipGlows
created: "2026-08-24"
updated: "2026-08-24"
status: active
source_skill: 900-shipglows-core
scope: ux-reference-connectors
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/ux-reference-intelligence.md
  - skills/references/resource-discovery.md
  - skills/references/design-inspiration-library.md
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/100-sg-spec/SKILL.md
depends_on:
  - artifact: skills/references/ux-reference-intelligence.md
    artifact_version: "1.2.0"
    required_status: active
supersedes:
  - skills/006-sg-design/references/ux-reference-connectors.md
evidence:
  - "Mobbin Docs, MCP Introduction, reviewed 2026-08-24: https://docs.mobbin.com/mcp/introduction"
  - "Mobbin Docs, MCP Features, reviewed 2026-08-24: https://docs.mobbin.com/mcp/features"
  - "Checklist Design public catalog, reviewed 2026-08-24: https://www.checklist.design/"
  - "Checklist Design browse index, reviewed 2026-08-24: https://www.checklist.design/browse"
  - "Collect UI public catalog and categories were reachable on 2026-08-24: https://collectui.com/ and https://collectui.com/categories"
  - "Collect UI statistics observed 2026-08-24 reported zero shots published yesterday and during the previous week: https://collectui.com/stats"
next_review: "2026-09-24"
next_step: "Recheck provider evidence before promoting any unverified or stale source to eligible-by-default."
---

# UX Reference Connectors

## Purpose

This shared catalog owns provider-specific facts for the UX-reference
intelligence contract. Construction, specification, design, and customer
experience use the same entries and eligibility vocabulary. A catalog entry
documents a source; it does not prove that the source is configured, callable,
fresh, relevant, or eligible in the current agent session.

Before live use, apply the documentation freshness gate and current runtime
awareness. Availability, freshness, task fit, authority, rights, and eligibility
remain separate fields. An entry is eligible only when every field required for
the current question is sufficient.

## Mobbin MCP

### Identity And Evidence

- Source ID: `mobbin-mcp`
- Adapter class: `mcp`
- Provider: Mobbin
- Official MCP introduction: `https://docs.mobbin.com/mcp/introduction`
- Official feature reference: `https://docs.mobbin.com/mcp/features`
- Remote endpoint documented by Mobbin: `https://api.mobbin.com/mcp`
- Last reviewed: `2026-08-24`
- Freshness verdict: `fresh-docs checked`
- Eligibility: conditional on current-session callability and task fit.

### Documented Capabilities

Mobbin documents natural-language tools for UI screens, multi-step user flows,
and website sections. Its MCP responses can include screen images for agent
consumption. The documented tool surface is:

- `search_screens`: UI screens;
- `search_flows`: journeys such as onboarding and checkout;
- `search_sections`: website sections such as pricing pages and footers.

Mobbin documents MCP availability for Pro, Team, and Enterprise plans, with
OAuth handled by compatible MCP clients. The REST API is a different adapter;
do not silently substitute it for MCP.

### Access And Runtime Boundary

- Documentation state: `documented`.
- Repository configuration state: not configured by this contract.
- Current-session state: inspect exposed tools, apps, and MCP connectors; never
  inherit `callable` from this catalog.
- Authentication: provider-supported OAuth in compatible MCP clients.
- Billing: subscription choice and payment remain operator-owned external actions.

### Safe Use And Fallback

Use Mobbin for bounded discovery and comparison of real product screens and
flows. Retain result links, provider identity, observed patterns, limitations,
and selected principles. Do not bulk download, mirror, redistribute, publish,
or commit provider screenshots without an explicit rights and persistence basis.

For `not-exposed`, `auth-required` or `paywalled`, `rate-limited`, timeout,
provider error, or zero relevant results, record the exact state and continue through
another eligible source, platform guidance, project evidence, or the approved
private index. Do not request credentials or scrape a browser session.

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
- Eligibility: conditional on corpus presence, record status, task fit, and any
  operator-selection boundary.
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
- Eligibility: candidate-scenario discovery only.

### Observed Capabilities

The public catalog groups practical UX/UI checklist items by website page,
component, flow, topic, brand, and design-system concern. It can suggest states
or details worth considering for a bounded product question.

Use it as an indicator among other evidence. Never import a full checklist,
convert every item into scope, claim consensus, or use completed checkboxes as
usability or quality proof. Claims and statistics remain unverified until
independently sourced. Only selected scenarios tied to a concrete product
responsibility may enter a specification or verification contract.

### Access And Fallback

- Access method: bounded public-web inspection without authentication bypass,
  bulk capture, or automated mirroring.
- Current-session state: determine at runtime; this entry does not imply browsing
  is exposed or that a page was inspected for the current task.
- Provider skills, agent packages, Figma skills, and plugins are not installed.
- Unavailable pages, zero relevant candidates, unclear provenance, or conflict
  with higher authority cause omission or fallback, never scope expansion.

## Collect UI Public Web

### Identity And Evidence

- Source ID: `collectui-public-web`
- Adapter class: `public-web`
- Provider: Collect UI
- Public catalog: `https://collectui.com/`
- Category index: `https://collectui.com/categories`
- Statistics: `https://collectui.com/stats`
- Last reviewed: `2026-08-24`
- Availability state: `accessible`.
- Freshness state: `unverified`.
- Eligibility: `ineligible-by-default`.

### Observed Capabilities And Limits

Collect UI exposes a large category-based archive of curated Daily UI and
Dribbble-derived visual shots, including onboarding, checkout, settings,
loading, empty-state, navigation, and component themes. It is useful only as a
manual visual archive for bounded aesthetic exploration when an operator or
designer deliberately selects it.

Its public pages still describe daily updating, but the observed statistics
reported zero shots published yesterday and during the previous week. Visible
entries do not provide reliable current publication dates. Reachability and a
large archive therefore do not establish current maintenance.

Collect UI is not evidence of a current convention, not a real-product flow
source, and not usability or accessibility proof. One gallery result remains
one attributed visual example. Do not infer unseen states, product success, or
frequency from its ordering or category counts.

### Safe Use And Fallback

- Do not select it automatically for current-pattern, common-flow, market-trend,
  accessibility, or platform-convention claims.
- Permit a manual URL only for visual ideation when its age limitation is stated
  and a higher-authority source governs behavior.
- Preserve the original designer attribution and source link; do not persist,
  mirror, or redistribute images through this catalog.
- Reconsider eligibility only after dated evidence demonstrates renewed
  publication activity and the rights boundary remains acceptable.
- Otherwise prefer eligible project evidence, platform guidance, Mobbin when
  callable, Checklist Design for candidate scenarios, or the approved private
  corpus according to the current task.

## Future Connector Admission

Additional MCP, API, public-web, manual, platform-guidance, or private-corpus
sources may be added as separate entries after capability, freshness, runtime,
and rights review. Each entry must declare availability, freshness, eligibility,
task fit, evidence, failure behavior, and fallback. A reachable source may remain
catalogued but ineligible; catalog presence is never a recommendation.

## Validation

```bash
python3 tools/test_ux_reference_intelligence_contract.py
python3 tools/shipglows_metadata_lint.py skills/references/ux-reference-connectors.md
```
