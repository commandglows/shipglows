---
artifact: editorial_content_context
metadata_schema_version: "1.0"
artifact_version: "1.5.1"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-23"
status: reviewed
source_skill: sg-start
scope: claim-register
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
content_surfaces:
  - public_site
  - repo_docs
  - public_skill_pages
  - faq_support
claim_register: docs/editorial/claim-register.md
page_intent: docs/editorial/page-intent-map.md
linked_systems:
  - BUSINESS.md
  - PRODUCT.md
  - BRANDING.md
  - GTM.md
  - README.md
  - skills/references/decision-quality-contract.md
  - site/src/pages/
depends_on:
  - artifact: "shipglows_data/business/business.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/product.md"
    artifact_version: "1.6.0"
    required_status: reviewed
  - artifact: "shipglows_data/branding/branding.md"
    artifact_version: "1.3.0"
    required_status: reviewed
  - artifact: "shipglows_data/business/gtm.md"
    artifact_version: "1.6.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Business, product, brand, and GTM contracts define public promise boundaries."
  - "Decision-quality contract defines the public-safe wording boundary for quality-first execution claims."
  - "OWASP Top 10:2025 awareness, selected ASVS v5.0.0 requirements, ZOMBIES edge-case coverage, and the pragmatic Clean Code gate are now explicit ShipGlows workflow controls."
  - "Positioning decision SG-BIZ-2026-08-13-01 establishes evidence-safe business-partner and outcome-ownership wording."
  - "Operator decision 2026-08-21 adds Git-backed persistence and recovery as public trust proof with explicit availability and deployment caveats."
  - "Operator decision 2026-08-22 establishes ShipGlows as a business framework shared by humans and agents, preserves business partnership as product behavior, and frames identity, impact, and technical execution as ambition rather than guaranteed outcome."
next_review: "2026-09-13"
next_step: "Verify public claims against the framework-category, partner-behavior, and non-guaranteed-impact hierarchy before publication"
---

# Claim Register

## Purpose

This register gives agents a safe boundary for sensitive public claims. It does not list every sentence in the site. It lists claim families that need evidence, careful wording, or a stop condition.

## Claim Statuses

| Status | Meaning |
| --- | --- |
| `allowed` | Supported by current reviewed contracts and visible repository behavior |
| `allowed with caveat` | Publish only with the stated constraint or scope |
| `needs proof` | Can be explored, but not presented as fact until evidence exists |
| `claim mismatch` | Conflicts with a current contract or implementation truth |
| `blocked` | Must not be published without an explicit product/business/security decision |

## Sensitive Claim Families

| Claim family | Allowed wording boundary | Evidence source | Status | Surfaces | Stop condition |
| --- | --- | --- | --- | --- | --- |
| Security | ShipGlows can say it uses explicit contracts, validation, and scope-based security gates, including OWASP Top 10:2025 awareness and selected ASVS requirements where relevant. It must not imply guaranteed security, OWASP compliance, or vulnerability prevention. | `skills/references/owasp-application-security-awareness.md`, current workflow docs | `allowed with caveat` | README, docs, FAQ, landing | Block claims of guaranteed security, complete OWASP coverage, zero leaks, or compliance certification |
| Privacy | ShipGlows can describe avoiding publication of private URLs, credentials, tokens, sensitive logs, and internal-only details. It must not claim privacy compliance or data protection guarantees. | `GUIDELINES.md`, public/private boundary docs | `allowed with caveat` | Docs, FAQ, remote MCP guide | Block compliance-style privacy claims without reviewed legal/security evidence |
| Compliance | ShipGlows has no compliance program claim. | No reviewed compliance contract | `blocked` | Any public surface | Block SOC2, GDPR, HIPAA, enterprise compliance, or audit-ready claims |
| AI reliability | ShipGlows can say it reduces ambiguity, strengthens handoffs, and gives agents clearer contracts. It must not promise agent correctness or fully autonomous reliability. | `PRODUCT.md`, `BRANDING.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | `allowed with caveat` | Landing, skills, FAQ, docs | Block guaranteed correctness, autonomous genius, or "agents always know what to do" claims |
| Decision quality | ShipGlows can say it directs agents to prioritize correctness, security posture, maintainability, relevant performance, edge cases, and proof before speed, cost, or convenience. It can describe explicit code-quality and edge-case gates without implying guaranteed code quality or zero defects. | `skills/references/decision-quality-contract.md`, `skills/references/clean-code-quality-contract.md`, `skills/references/zombies-edge-case-heuristic.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | `allowed with caveat` | Landing, docs, FAQ, skills, why-not-prompts | Block "maximum security", "maximum performance", "bug-free", "always best practice", or quantified gains without evidence |
| Automation | ShipGlows can say it orchestrates workflows and provides skills for execution, verification, docs, audits, and ship preparation. It must not imply unattended production shipping without gates. | `PRODUCT.md`, `specs/sg-build-autonomous-master-skill.md`, skill contracts | `allowed with caveat` | Skills hub, docs, README | Block "hands-free shipping" unless the exact gate sequence and limitations are stated |
| Git persistence and recovery | ShipGlows can say its governed workflow requires exact-scope commits and remote pushes at validated milestones and clean closure, checks for locally vulnerable work at existing lifecycle boundaries, and distinguishes local, backed-up, and deployed states. It must not guarantee GitHub availability, zero data loss, repository protection settings, or deployment from a push alone. | `skills/references/git-milestone-delivery-contract.md`, `skills/references/git-persistence-preflight.md`, focused contract tests | `allowed with caveat` | Landing, docs, FAQ, README, articles | Block guarantees, provider-state assumptions, or wording that treats remote backup as deployment proof |
| Speed | ShipGlows can say it reduces context reconstruction and handoff overhead. It must not state quantified speed gains without measured evidence. | `BUSINESS.md`, `PRODUCT.md`, repo workflow design | `needs proof` for numbers; `allowed with caveat` for qualitative wording | Landing, pricing, FAQ | Block percentage/time-saved claims without measurement |
| Savings | ShipGlows can discuss lower ambiguity and fewer weak handoffs. It must not claim cost savings or revenue impact without proof. | `BUSINESS.md`, `GTM.md` | `needs proof` | Pricing, landing | Block cost reduction, revenue lift, or ROI claims without data |
| Availability | ShipGlows can describe local tools and server operations, but must not claim service uptime, hosted availability, or SLA. | Runtime docs and current repo | `blocked` for SLA; `allowed with caveat` for local behavior | Pricing, docs, README | Block uptime, SLA, or hosted reliability claims |
| Pricing | ShipGlows can describe pricing as a hypothesis and state there is no final business model yet. It must not present packages as live offers unless a pricing decision exists. | `BUSINESS.md`, `GTM.md`, `site/src/pages/pricing.astro` | `allowed with caveat` | Pricing page, homepage pricing component, FAQ | Block fixed price, payment availability, or plan comparison claims without a reviewed pricing decision |
| Business and identity outcomes | ShipGlows can present itself as a business framework shared by humans and agents, with the ambition to create distinctive identities, build businesses that make an impact, and give ambitions solid technical execution. It can say the framework behaves like a business-aware delivery partner that connects governed truth to métier decisions, bounded chantiers, and visible proof. These are positioning and operating-model claims, not guarantees of distinctiveness, impact, technical success, market fit, launch, revenue, growth, or conversion. | `shipglows_data/business/business.md`, `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, `shipglows_data/branding/branding.md` | `allowed with caveat` | Landing, FAQ, docs, pitch | Block guaranteed identity quality, impact, technical outcome, judgment, launch, revenue, growth, conversion, or unattended business success claims |

## Claim Impact Plan

Use this format when a public claim is added, removed, or materially changed:

```markdown
## Claim Impact Plan

- Claim: `[exact or paraphrased claim]`
- Claim family: `[security|privacy|compliance|AI reliability|automation|speed|savings|availability|pricing|business outcome|other]`
- Affected surfaces: `[files/routes]`
- Evidence: `[contract, spec, behavior, source, or missing proof]`
- Status: `[allowed|allowed with caveat|needs proof|claim mismatch|blocked]`
- Allowed wording: `[safe wording or restriction]`
- Required action: `[publish|downgrade|mark pending proof|remove|block]`
- Stop condition: `[what must be resolved before close/ship]`
```

## Review Rules

- If the wording sounds stronger than the evidence, downgrade it.
- If a claim depends on a future feature, label it as future or do not publish it.
- If a claim would affect trust, money, safety, security, privacy, compliance, or user expectations, produce a Claim Impact Plan.
- If a public claim conflicts with `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, or `GTM.md`, mark it `claim mismatch`.

## Maintenance Rule

Update this register when product scope, business model, GTM proof, brand claim boundaries, pricing, security posture, or public promise language changes.
