---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-06-26"
updated: "2026-09-02"
status: active
source_skill: 000-shipglows
scope: shared-terminology
owner: unknown
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/302-sg-help/SKILL.md
  - skills/102-sg-start/SKILL.md
  - cli/shipglows.sh
  - cli/lib.sh
  - cli/config.sh
  - cli/install.sh
  - local/
  - tui/
  - skills/references/execution-posture-tags.md
depends_on: []
supersedes: []
evidence:
  - "Shared terminology was needed so ShipGlows can be referenced from other projects without repeating the definition in each skill."
  - "The package includes both server-side CLI scripts and the terminal UI, so the terminology must bind both to the same product family."
  - "Operator idea 2026-06-27: lightweight glossary tags should recenter the agent faster than invoking a full skill when the conversation drifts."
  - "Operator request 2026-06-29: add a #source tag for shared source intake, classification, project fit, and owner-skill routing."
  - "Operator approval 2026-06-29: add a private memory store for cached project pitches and approved reusable source material."
  - "Operator request 2026-06-29: add traffic-manager profile routing and acquisition-focused recentering tags."
  - "Operator decision 2026-06-29: name the traffic-manager profile Tariq."
  - "Operator decision 2026-08-20: add #local, #nolocal, and #ci as transversal execution posture tags while retaining nolocal mode syntax as compatibility only."
  - "Operator decision 2026-08-27: shipglows is the DX-system repository for skills, CLI/DevServer, TUI, local tooling, installers, and internal governance; shipglows_app separately owns the public site and SaaS."
  - "Operator decision 2026-09-02: #pitch opens the current project's root pitch before portfolio fallback."
next_review: "2026-07-11"
next_step: "/103-sg-verify shared terminology routing"
---

# ShipGlows Terms

Use these names consistently when users talk to ShipGlows through skills or other agent entrypoints.

## Canonical Terms

- `ShipGlows DX system` or `ShipGlows system` in Core/maintenance context: the `shipglows` repository package of skills and doctrine, CLI/DevServer, TUI, local tooling, environment control, installers, packaging, and internal governance.
- `shipglows_app`: the separate product repository that owns the public website and SaaS. It is not a Core DX mutation surface, even when its desired outcomes are quoted as evidence inside hard Core context.
- `ShipGlows Dev Server`: the cross-platform CLI/runtime layer that manages environments and development-server behavior. Unless the user says otherwise, this means:
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/shipglows.sh`
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/lib.sh`
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/config.sh`
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/install.sh`
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/windows/`
  - `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/install-shipglows.ps1`
- `ShipGlows TUI`: the terminal user interface under `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tui/`.
- `ShipGlows local tools`: the local connection and tunnel helpers under `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/local/`.
- `ShipGlows skills`: the skill system under `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/skills/`.

## Routing Rule

When a user says `Dev Server` while talking to ShipGlows, interpret it as `ShipGlows Dev Server` by default.

When a user mentions the terminal UI, interpret it as `ShipGlows TUI` by default.

If the user names another project explicitly, keep that project as the target and treat ShipGlows as the reference system only.

Inside explicit `$shipglows core` context, later project names cannot replace the hard DX target. `shipglows_app` language may describe evidence about DX behavior, but actual site/SaaS work exits Core and uses the product's normal owner route.

## Focus Tags

ShipGlows also accepts lightweight conversation recentering tags. These tags do not replace owner-skill routing. They tell the agent which canonical contract to reload before answering, routing, or editing.

### Execution posture tags

These three tags affect permitted proof execution rather than métier routing.
They are position-independent in agent invocations and load
`$SHIPGLOWS_ROOT/skills/references/execution-posture-tags.md`.

| Tag | Meaning | Canonical document |
| --- | --- | --- |
| `#local` | Permit proportional local workloads under normal authority; never force unnecessary execution | `$SHIPGLOWS_ROOT/skills/references/execution-posture-tags.md` |
| `#nolocal` | Forbid local/application/validation workloads and external effects while retaining static inspection and bounded edits | `$SHIPGLOWS_ROOT/skills/references/execution-posture-tags.md` |
| `#ci` | Imply `#nolocal` and identify existing CI as deferred proof, without authorizing push or workflow dispatch | `$SHIPGLOWS_ROOT/skills/references/execution-posture-tags.md` |

`#local` conflicts with the other two. `#nolocal #ci` is valid. These tags do
not grant mutation or external-write authority. In native Bash syntax an
unquoted `#` starts a comment; the forms above are agent-conversation tags.

### Recenter and navigation tags

If a tag is present, treat it as a high-priority context cue even when the rest of the prompt is short or fuzzy.

Explicit feature hints use the `#feature:<term>` form only. They are routing hints, not command language, and they keep the free-text request active.

| Tag | Meaning | Canonical document |
| --- | --- | --- |
| `#rules` | Recenter on the full rule set for what a ShipGlows-governed project must respect | `$SHIPGLOWS_ROOT/skills/references/project-governance-rules.md` |
| `#docs` | Recenter on strict documentation-governance compliance: architecture, metadata, placement, and update discipline | `$SHIPGLOWS_ROOT/skills/references/documentation-governance-rules.md` |
| `#partner` | Recenter on the agent as business partner, advisor, and growth-aligned associate | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#quality` | Recenter on quality bar, autonomy, bounded excellence, and anti-shortcut rules | `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` |
| `#vfbf` | Recenter on a quick, bounded, traceable execution pass: do it "vite fait bien fait" without turning it into the main focus | `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` |
| `#growth` | Recenter on business growth, distribution, conversion, and leverage | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#traffic` | Recenter on qualified traffic, channel-to-landing fit, tracking readiness, and conversion measurement | `$SHIPGLOWS_ROOT/skills/references/operator-roles/traffic-manager.md` |
| `#acquisition` | Recenter on acquisition-channel choice, source quality, funnel entry, and measurable learning | `$SHIPGLOWS_ROOT/skills/references/operator-roles/traffic-manager.md` |
| `#offer` | Recenter on the offer, promise, packaging, pricing logic, and commercial clarity | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#roi` | Recenter on expected impact versus effort, drag, and operating cost | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#funnel` | Recenter on acquisition, activation, conversion, and retention flow fit | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#positioning` | Recenter on differentiation, category framing, and market angle | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#distribution` | Recenter on channels, reach, SEO, affiliates, and partner-led growth | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#monetization` | Recenter on revenue fit, packaging, paywalls, upsell paths, and pricing pressure | `$SHIPGLOWS_ROOT/shipglows_data/business/business.md` |
| `#retention` | Recenter on repeat usage, stickiness, and product loops that keep users active | `$SHIPGLOWS_ROOT/shipglows_data/business/product.md` |
| `#decision-maker` | Recenter on what matters to the buyer, approver, or economic decision-maker | `$SHIPGLOWS_ROOT/shipglows_data/business/business.md` |
| `#end-user` | Recenter on first success, user usefulness, clarity, and beginner adoption | `$SHIPGLOWS_ROOT/skills/008-sg-customer/SKILL.md` |
| `#trust` | Recenter on trust, promise discipline, claim safety, and credibility | `$SHIPGLOWS_ROOT/shipglows_data/branding/branding.md` |
| `#cta` | Recenter on the next action the page, flow, or message should drive clearly | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#clarity` | Recenter on readability, explicit structure, and removal of vague language | `$SHIPGLOWS_ROOT/shipglows_data/branding/branding.md` |
| `#faq` | Recenter on objections, reassurance, pre-purchase friction, and direct answers | `$SHIPGLOWS_ROOT/shipglows_data/business/gtm.md` |
| `#voice` | Recenter on tone, wording, and brand-language discipline | `$SHIPGLOWS_ROOT/shipglows_data/branding/branding.md` |
| `#audience` | Recenter on persona fit, reader sophistication, and who the message is actually for | `$SHIPGLOWS_ROOT/shipglows_data/business/business.md` |
| `#source` | Recenter on classifying an incoming source, project fit, angle, risks, and owner-skill route | `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` |
| `#private-memory` | Recenter on the approved private runtime store for pitch caches and reusable private source memory | `$SHIPGLOWS_ROOT/skills/references/private-memory-store.md` |
| `#repurpose` | Recenter on transforming one source into the right downstream content surfaces | `$SHIPGLOWS_ROOT/shipglows_data/editorial/content-map.md` |
| `#pillar` | Recenter on pillar-page role, semantic architecture, and supporting-page structure | `$SHIPGLOWS_ROOT/shipglows_data/editorial/content-map.md` |
| `#seo-intent` | Recenter on search intent, query-to-surface fit, and discoverability usefulness | `$SHIPGLOWS_ROOT/shipglows_data/editorial/content-map.md` |
| `#scope` | Recenter on the narrowest justified owner layer and bounded execution scope | `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` |
| `#ship` | Recenter on ship readiness, checks, proof, closure, and release discipline | `$SHIPGLOWS_ROOT/skills/004-sg-deploy/SKILL.md` |
| `#leverage` | Recenter on compounding impact, operator leverage, and drag reduction | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#founder-mode` | Recenter on founder-level delegation: business decision surface, not technician micromanagement | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#founder` | Recenter on the user as a business owner who wants useful decisions, growth, and clarity | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#shipglows-owner` | Recenter on the operator as owner of ShipGlows and adjacent assets, with portfolio-level arbitration | `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` |
| `#pitch` | Recenter on the current project's root pitch and core identity; use the portfolio index only for cross-project lookup | `<project-root>/PITCH.md`, then `$SHIPGLOWS_ROOT/shipglows_data/business/portfolio-project-pitch-links.md` |
| `#portfolio` | Recenter on the portfolio pitch-links index and cross-project opportunity scanning | `$SHIPGLOWS_ROOT/shipglows_data/business/portfolio-project-pitch-links.md` |
| `#no-drift` | Recenter on staying on target, choosing, and acting without exploratory drift | `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` |
| `#canon` | Recenter on the canonical source of truth and avoid parallel doctrine copies | `$SHIPGLOWS_ROOT/shipglows_data/technical/code-docs-map.md` |
| `#drift` | Recenter on code-doc divergence, stale surfaces, and misaligned contracts | `$SHIPGLOWS_ROOT/shipglows_data/technical/code-docs-map.md` |
| `#owner` | Recenter on ownership of the artifact, source, or decision layer | `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` |
| `#freshness` | Recenter on whether the document or claim is still current enough to trust | `$SHIPGLOWS_ROOT/shipglows_data/editorial/content-map.md` |
| `#traceability` | Recenter on linking decision, source, implementation, and proof | `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/spec-driven-workflow.md` |
| `#entrypoint` | Recenter on the fastest correct documentation or workflow entrypoint | `$SHIPGLOWS_ROOT/AGENT.md` |
| `#contract` | Recenter on non-optional rules, invariants, and governing constraints | `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` |
| `#public-docs` | Recenter on public-facing docs, readability, and declared external surfaces | `$SHIPGLOWS_ROOT/shipglows_data/editorial/content-map.md` |
| `#internal-docs` | Recenter on internal docs, operator truth, and execution-facing artifacts | `$SHIPGLOWS_ROOT/shipglows_data/technical/context.md` |
| `#single-source` | Recenter on one authoritative artifact instead of duplicated explanation | `$SHIPGLOWS_ROOT/shipglows_data/technical/code-docs-map.md` |
| `#shipglows` | Recenter on the internal ShipGlows system rather than the current project repo | `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` |
| `#shupflow` | Alias for `#shipglows` when used as a fast recentering tag in conversation | `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` |
| `#feature:<term>` | Optional technical-navigation hint for behavior-index recovery before broad search; keep the free-text request active | `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` |
| `#onboarding` | Recenter on first success, setup order, recoverable states, and adoption guidance | `$SHIPGLOWS_ROOT/skills/008-sg-customer/SKILL.md` |
| `#routing` | Recenter on owner-skill selection and direct handoff rules | `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` |
| `#proof` | Recenter on proof paths, validation proportion, and evidence claims | `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` |
| `#shipglows-core` | Recenter on ShipGlows DX-system maintenance across skills, CLI/DevServer/TUI runtime, coherence, and packaging | `$SHIPGLOWS_ROOT/skills/900-shipglows-core/SKILL.md` |

## Tag Rule

When one or more focus tags appear:

- load the referenced canonical document before choosing the next action
- keep the tag meaning active as a conversation-level priority for the current turn
- do not ask the operator to restate the same doctrine in natural language when the tag already resolves it

If several tags appear, combine them in the narrowest coherent way rather than treating them as conflicting by default. The execution-posture conflicts defined above are the explicit exception and fail closed.
