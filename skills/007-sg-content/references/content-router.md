---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-06-28"
status: active
source_skill: 007-sg-content
scope: content-router
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/references/source-intake-classification.md
  - skills/references/editorial-content-corpus.md
  - skills/references/content-quality-rubric.md
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "007-sg-content currently carries both lifecycle routing and detailed owner/delegation doctrine."
  - "Instruction layering calls for detailed matrices and long workflow detail to move into references."
next_review: "2026-07-05"
next_step: "/300-sg-docs update if the routing model changes"
---

# Content Router

## Purpose

Shared routing detail for `007-sg-content`.

Load `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md` for the canonical owner matrix and minimum handoff payload. This local reference keeps only the routing choices that are activation-critical for `007-sg-content`.

## Source Intake

When a pasted source, email, URL, transcript, note, article, or example arrives without a settled project, surface, angle, or owner route, load `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` before choosing the content lane.

## Mode Map

- `capture-full-conversation` -> delegate raw tmux scrollback export to the internal `800-tmux-capture-conversation` implementation; do not clean or repurpose the result.
- `clean-transcript <path>` -> delegate readability cleanup of the supplied Markdown transcript to the internal `801-clean-conversation-transcript` implementation; do not capture a new pane or create a content pack.
- `plan`, `strategy`, `calendar`, `content plan` -> content plan, use `100-sg-spec` when durable or multi-surface.
- `repurpose <source>` -> load `references/repurpose-playbook.md`; this self-owned lane first classifies source safety, then creates a source-faithful pack and governed durable memory when justified, before handing downstream work to the right owner. A bare `repurpose` asks for a source. `verbatim`, `mot pour mot`, and `copie exacte` select the exact-preservation archival branch, never analysis.
- `source`, `conversation`, `faq`, `release notes`, `site update` -> resolve whether the request is explicit repurposing; use the local `repurpose <source>` lane when it is, otherwise choose the smallest owner below.
- `draft`, `write`, `article`, `blog`, `guide`, `editorial` -> `200-sg-redact` after surface and claim gates.
- `enrich`, `refresh`, `update @file`, `improve` -> `201-sg-enrich`.
- `audit copy`, `copy`, `copywriting`, `market`, `gtm` -> `009-sg-marketing copy|copywriting|market|gtm` with the exact mode selected from the stated need; `seo` stays with `406-sg-seo`.
- `docs`, `readme`, `editorial`, `content governance` -> `300-sg-docs`.
- `veille`, URLs, pasted external trend/source content -> `205-sg-veille` or `203-sg-research`; use `009-sg-marketing market` only once a market, keyword, competitor, or demand study is the settled need.
- `apply`, `publish`, `ship` -> validate, then `103-sg-verify` and `005-sg-ship` when bounded.

## Spec Gate

Use spec-first when:

- multiple public surfaces are affected;
- a new content surface, route, collection, newsletter, social repository, or blog path is needed;
- sensitive public claims are added or strengthened;
- content strategy, SEO architecture, funnel narrative, pricing copy, or support copy changes materially;
- parallel content work would touch shared maps, public pages, shared components, `site/src/content.config.ts`, README, FAQ, docs overview, pricing, or claim register;
- the work needs validation or ship routing beyond one direct local edit.

Route to `/700-sg-explore <idea>` before `/100-sg-spec` when source truth or surface placement is fuzzy.

## Content Governance Gate

For public or potentially public content:

1. Read `shipglows_data/editorial/content-map.md` when present.
2. Read `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when available.
3. Check `public-surface-map`, `page-intent-map`, `claim-register`, `blog-and-article-surface-policy`, and `astro-content-schema-policy` when present.
4. Produce `Editorial Update Plan` and `Claim Impact Plan` when relevant.
5. Stop if no declared blog/article surface exists and the request needs one.

## Owner Skill Routing

Use `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md` as the owner matrix.

Local `007-sg-content` routing rule:

- when work starts from source material and its downstream surface is not fully resolved, run the bounded `repurpose <source>` lane first for a safe source-faithful pack and governed durable memory, then continue to the next owner if needed

## Operator Initiative Rules

Apply the shared `operator-partnership-contract.md` first. For content work, `007-sg-content` adapts that doctrine to editorial surfaces.

Required behavior:

- infer the most likely content sequence before asking for framing help
- propose the adjacent article/page/link opportunity when one article clearly needs a predecessor, successor, bridge, or internal-link target
- keep the public promise honest across title, slug, intro, headings, CTA, and body; if the title overpromises relative to the real workflow, fix the content instead of waiting for operator correction
- keep title, slug, H1, intro, H2, and H3 aligned with the true workflow; do not let SEO structure drift into a stronger promise than the body can support
- treat H2 and H3 as first-class editorial/marketing surfaces; they should carry promise, clarity, and reader value, not generic labels
- when title candidates are explored but not chosen, recycle the strongest unused variants into SEO-useful H2/H3 sections when they fit the article truthfully
- default to skill-led research, enrichment, and cross-linking; do not frame manual web research as the reader workflow when ShipGlows skills are the intended product path
- present review-source harvesting as a ShipGlows skill capability, not manual homework, when the workflow depends on competitor feedback from AppSumo, Play Store, Trustpilot, Reddit, or similar public review sources
- distinguish clearly between `the operator gives a competitor list` and `ShipGlows skills turn that list into user-feedback insights`; do not imply that manually provided competitor discovery was automated
- when the operator asks to promote ShipGlows, keep the public workflow centered on ShipGlows skills unless the operator explicitly wants a manual or third-party-tool workflow
- when a source or title suggests "without manual research", "automatic", or similar language, verify that the described workflow really removes that operator effort; otherwise tighten the promise immediately
- when the operator critique is about naming, positioning, or promise honesty, treat it as permission to tighten title, slug, intro, and section structure in the same pass

Ask the operator a targeted question only when the answer changes a material business decision that cannot be inferred safely, such as:

- which declared product or site surface owns the content
- whether a new public surface should exist at all
- whether two plausible article intents compete and both would materially change the funnel

Do not ask the operator to micro-manage:

- internal-link opportunities between obviously adjacent articles
- honest title/slug alignment after a promise mismatch is visible
- whether strong unused title candidates can become H2/H3 structure
- whether a skills-promoted workflow should replace a manual workflow in ShipGlows-owned public content
- whether competitor-review sources like AppSumo, Play Store, or Trustpilot should be woven into a ShipGlows-led feedback workflow when that connection is already explicit in the request

## Content Quality Guidelines

For content creation or content modification, prefer these positive defaults:

- align title, slug, H1, intro, H2, H3, CTA, and internal links around one honest promise
- write H2 and H3 with the same editorial and marketing care as the main title; they should be clear, specific, compelling, and worth reading on
- step back from the literal request wording when needed to improve the real article angle, funnel role, adjacency, or reader job to be done
- optimize for discoverability without weakening truthfulness, product fit, or requester intent
- make the SEO structure reinforce the real workflow instead of outgrowing it
- frame the reader workflow through ShipGlows skills when that is the intended product path
- state clearly what the requester provided and what ShipGlows skills transform, automate, or accelerate
- recycle strong unused title variants into truthful H2/H3 structure when they improve search coverage and clarity
- prefer substantial, meaning-rich H2/H3 wording over short placeholder subheads when longer phrasing better communicates value, intent, or outcome
- respond to content critique at the right layer: wording, angle, funnel placement, promise, or source strategy
- absorb routine editorial decisions inside the skill; ask only for business truth that materially changes the article

## Requester Relationship

In content work, the requester is the owner of business truth, audience nuance, positioning intent, and product emphasis. The requester is not the line editor for routine SEO structure or coherence cleanup.

Default behavior:

- ask for the smallest missing strategic fact when that fact materially changes the article
- ask for business nuance, positioning intent, or product emphasis when that conversation would genuinely improve the article and cannot be inferred confidently from the project
- do not ask for routine editorial arbitration the skill can resolve safely
- preserve the requester's true intent even when rewriting titles or structure for SEO
- if SEO and requester intent conflict, keep the truthful business intent and find the strongest honest search framing

## Validation

Use the content-quality rubric whenever `007-sg-content` emits or consumes a scored editorial output.
