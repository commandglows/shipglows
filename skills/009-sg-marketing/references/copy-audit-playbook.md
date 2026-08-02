---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-16"
status: active
source_skill: 009-sg-marketing
scope: copy-audit
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - skills/references/content-quality-rubric.md
  - skills/references/task-registry-routing.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes:
  - skills/206-sg-audit-copy/SKILL.md
  - skills/206-sg-audit-copy/references/copy-audit-workflow.md
evidence:
  - "Migrated from 206-sg-audit-copy during marketing-surface consolidation."
next_step: "/103-sg-verify consolidate marketing skills under sg-marketing"
---

# Copy Audit Playbook

Use only for `009-sg-marketing copy <page|file|project|global>`.

## Scope And Governance

Audit copy as a product interface: clear, credible, readable, usable, and coherent with product behavior, documentation, pricing, FAQ, onboarding, support, and real system states. It is not a persona/offer persuasion strategy audit; route materially different persuasion work to `copywriting` only after an explicit mode choice.

Read business, branding, and guidelines contracts when present. Report version/status/updated/confidence/next-review values; missing, stale, low-confidence, or unversioned context produces a proof gap and caps affected grades, but does not automatically block a bounded audit.

Load `content-quality-rubric.md` for every rubric-scored output and use its statuses rather than local score shortcuts. Before durable follow-ups, load `task-registry-routing.md`: editorial/copy findings normally belong in the editorial roadmap; genuinely technical work belongs in the execution tracker. For public content, mapped docs, runtime content, public docs, README, FAQ, pricing, support, or skill pages, apply the editorial and technical documentation corpora and report the required Editorial, Claim Impact, and Documentation Update Plans.

For sales/offer pages, CTA/proof/objection comparison, copy-pattern analysis, or explicit inspiration, use the bounded Inspiration Gate: inspect at most five private reference IDs, require operator selection before loading a bundle, record selections, and transfer principles rather than phrasing.

## Audit Flow

For a page/file, read the target, shared layout/CTA copy, translations where present, and the page's journey role. Check page intent and sensitive claims when governing corpora exist. Score only applicable domains:

1. value proposition, job-to-be-done, benefit framing, and product/documentation promise coherence;
2. clarity/readability, plain-language summary for long pages, jargon, active voice, and audience-appropriate reading level;
3. credible persuasion, authentic urgency, objections, and risk reversal without fabricated proof;
4. CTA specificity, next-step truth, hierarchy, mobile visibility, and nearby objection handling;
5. microcopy for form, error, success, empty, loading, permission, payment, and retry states;
6. tone, voice, register, terminology, grammar, French typography, and placeholder defects;
7. AI-voice, trust, answer-engine, and conversion-copy smells only when they materially reduce credibility or discoverability.

For a project/global scope, inventory voice and messaging hierarchy, scan representative pages and funnel states, identify repeated contradictions, and produce a bounded cross-project synthesis only after explicitly selecting projects. Do not silently turn an audit into a rewrite.

## Remediation, Tracking, And Report

Rewrite only when the user asks or an active chantier owns remediation. Preserve author voice, direct quotes, testimonials, UI constraints, factual limits, and French accents. Do not embellish unsupported product, security, privacy, compliance, AI, availability, savings, pricing, or outcome claims; classify them as proof gaps, claim mismatch, needs-proof, or blocked.

Before tracker writes, load `operational-record-format.md`, re-read the target immediately before mutation, and update only the intended traffic-first record. If an anchor is still ambiguous after one re-read, stop rather than rewriting shared state.

Report scope, business metadata versions, grades, priority findings with exact surfaces and consequences, documentation/claim outcomes, confidence limits, selected inspiration IDs when any, and the next owner action. Evaluate `Chantier potentiel` for multi-page conversion, legal, trust, or positioning work.

## Stops And Quality Bar

- Continue with named limits when business/brand context is missing; block when a required selected reference is missing or a safeguard would be weakened.
- Never invent guarantees, proof, testimonials, pricing, customer facts, legal claims, or system states.
- A recommendation for a blog/article without a declared surface is `surface missing: blog`, not a fabricated content plan.
- Preserve focused contract, metadata, and budget checks after playbook changes.
