---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: greenfield-platform-and-technology-decisions
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/question-contract.md
  - skills/references/preferred-stacks.md
depends_on: []
supersedes: []
evidence:
  - "Approved common-path loading pilot; existing requirements relocated without changing authority."
next_review: "2026-10-05"
next_step: "Verify question gates."
---

# Greenfield Decisions

Use before greenfield platform, blueprint or technology selection. This leaf owns
only those decisions; the question core already supplies question shape and authority.

## Greenfield Platform Footprint Rule

Before blueprint matching or technology recommendations for a greenfield
product, establish the intended platform footprint at the product level:

- public website or browser application
- installable web app / PWA when materially different from an ordinary site
- native iOS and Android applications
- desktop applications when relevant

Use explicit operator statements and existing product corpus first. If the
platform footprint is absent or ambiguous and it would materially change the
framework, architecture, delivery phases, cost, or maintenance model, ask one
numbered product question or bundle it into the greenfield technology decision.

Never treat `mobile-first`, `responsive`, `website`, or `on the Internet` as
proof that native mobile applications are unwanted. Never put a major platform
into `Scope Out` merely because it was not named in the first sentence. When a
platform is required later rather than at launch, record both the launch phase
and the durable target architecture so the first implementation does not block
the planned application.

Likewise, never treat an initial request for an iOS app, Android app, or mobile
app as a reason to recommend a single-platform codebase first. Unless the
operator states a durable platform restriction or a verified constraint rules
out a target, the first application recommendation is one Flutter codebase for
Web, iOS, and Android. This does not replace the separate Astro surface when
public SEO pages are part of the product.

Once the footprint is known, evaluate all professionally credible framework
directions that cover it. A request including iOS/Android must consider Flutter
or explain concretely why it is not suitable; a public SEO-sensitive website
must separately evaluate whether its web surface should use document-centric
web technology even when Flutter owns the mobile applications.

## Greenfield Technology Decision Rule

After the platform footprint is known, load
`skills/references/preferred-stacks.md`. An operator-approved preset counts as
an established direction for the surfaces it covers and must be applied before
blueprint matching or a broad technology comparison. Do not repeatedly ask the
operator to approve Astro for a public/SEO site, Flutter for application
surfaces, or Vercel for compatible web outputs when the preset applies.
Present these compatible presets as ShipGlows's recommended direction before
any alternatives; alternatives exist to explain a concrete exception, not to
make the operator reselect the habitual stack.

For a new product with material technology choices that remain uncovered by an
accepted preset or blueprint, the remaining direction is not a routine
implementation detail. Before freezing it, the agent must research the
professional options, recommend one direction in plain language, explain the
consequences that the operator owns (ongoing cost, hosting and data control,
payment or service providers, maintenance burden, portability, and material
lock-in), and ask one bundled numbered decision.

Do not turn this into a questionnaire about packages, folder structure, state
libraries, or other low-level mechanics the agent should choose. The operator
chooses the durable product direction; the agent owns the implementation
details inside that direction.

An existing project stack may be continued autonomously when the requested
work does not materially change its cost, risk, or operating model. A matched
blueprint is a recommendation, not consent: disclose its material technology
direction and obtain agreement unless the operator or project corpus has
already accepted that blueprint or equivalent stack.
