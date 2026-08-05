---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-16"
updated: "2026-07-17"
status: active
source_skill: 009-sg-marketing
scope: copywriting-audit
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - skills/references/landing-page-copywriting-framework.md
  - skills/references/design-inspiration-library.md
  - skills/references/content-quality-rubric.md
  - skills/references/editorial-content-corpus.md
  - skills/references/task-registry-routing.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes:
  - skills/207-sg-audit-copywriting/SKILL.md
  - skills/207-sg-audit-copywriting/references/copywriting-audit-workflow.md
evidence:
  - "Migrated from 207-sg-audit-copywriting during marketing-surface consolidation."
  - "Reusable landing-page framework adds scenario-proven sequence, repetition, and claim-safety doctrine without changing the public mode."
next_step: "/103-sg-verify Reusable Landing-Page Copywriting Framework"
---

# Copywriting Audit Playbook

Use only for `009-sg-marketing copywriting <page|funnel|offer|project|global>`.

## Distinct Contract And Governance

Start with the intended buyer, not the text. This mode answers whether an offer persuades the right persona through a credible customer journey; it does not duplicate the clarity, grammar, microcopy, or rewrite contract of `copy`.

Read business and branding contracts and existing persona/customer-journey/strategy artifacts before scoring or persisting strategy. Report their version, status, freshness, and confidence; missing or stale contracts cap confidence and must appear as proof gaps. Public funnel/strategy changes require the editorial and technical-documentation corpus gates, including Editorial, Claim Impact, and Documentation Update Plans. Use `content-quality-rubric.md` for rubric statuses and `task-registry-routing.md` before follow-up writes.

For sales/offer, CTA/proof/objection comparison, or explicit inspiration, apply the bounded Inspiration Gate: present at most five private reference IDs, require operator selection before loading bundles, record selected IDs, and extract patterns/anti-copy constraints without reproducing source copy.

## Landing Framework Gate

After this one local playbook is selected, load `$SHIPGLOWS_ROOT/skills/references/landing-page-copywriting-framework.md` when the `copywriting` target is a landing, sales, or offer page, or when the request explicitly concerns its section flow, reading flow, repetition, proof placement, objection placement, or CTA sequence. A non-landing target without that explicit page-section need does not load the shared framework and continues through the existing Audit Flow.

For an existing page, collect the framework's required inputs, inventory its current sections, build the Section Role, Claim/Proof, and Repetition Ledgers, then return the ordered `Landing Sequence Plan`. Give every section one `keep|move|merge|delete|create` action and its reader question, unique job, transition, evidence state, objection, and CTA role. State the selected framework path in the report.

When differently presented sections may hide the same semantic role, or the sequence plan changes component families, proof composition, primary-versus-secondary placement, or continuous content behavior, load `$SHIPGLOWS_ROOT/skills/references/landing-page-experience-coherence.md`. Resolve semantic duplication through this copywriting sequence first, then preserve the design owner boundary for visual grammar and rendered proof.

Keep recommendations at strategic sequence level. Route sentence-level clarity, grammar, microcopy, or rewriting to `copy`; do not run both modes. Treat unsupported claims as visible `needs proof` or `claim mismatch` gaps and recommend the strongest honest sequence supported by current evidence. If the missing shared framework or required local playbook prevents the pass, block it, name the canonical path, and give the concrete owner route `/900-shipglows-core audit`; do not invent a generic template.

## Audit Flow

For a page, establish funnel stage and awareness level, then score:

1. persona alignment: customer vocabulary, real pain, desired outcome, trigger, alternatives, and appropriate awareness level;
2. value proposition: credible transformation, differentiation, proof, and coherence with product, pricing, onboarding, docs, emails, and support;
3. persuasion structure: hook, framework, section role, engagement progression, and appropriate length;
4. objections: the important objections before the primary CTA, empathetic treatment, relevant proof, and proportional risk reversal;
5. emotional path: empathy before solution, honest pain-to-hope-to-confidence-to-action sequence, and no coercion;
6. CTA strategy: buyer-appropriate next step, alternative for uncertainty, friction control, and proof before ask;
7. journey coherence: upstream promise, downstream handoff, micro-commitments, and no contradictions across marketing/product/docs.

For a project/global scope, validate or create a persona, map TOFU/MOFU/BOFU/retention surfaces, identify gaps/dead ends/orphan pages, assess positioning, pricing psychology, trust, and content-market fit, then prioritize strategic—not line-edit—recommendations. Select projects explicitly before global work.

## Durable Artifacts, Tracking, And Report

When the user asks for persistent strategy artifacts, maintain `docs/copywriting/persona.md`, `parcours-client.md`, and `strategie.md` as governed living references. Use ShipGlows frontmatter, source evidence, dependencies on business/brand versions, `0.1.0` for unreviewed work, and semantic bumps for changed persona, promise, funnel, pricing psychology, or strategy. Update existing files narrowly and retain history; do not duplicate the full audit report.

Before traffic-first audit/task writes, load `operational-record-format.md`, re-read the target before writing, use the editorial roadmap for editorial/copywriting follow-up and execution tasks only for genuine implementation, and stop if an anchor remains ambiguous after one re-read.

Report persona, funnel position and awareness, category grades, strategic recommendations and impact confidence, proof/docs gaps, governance-plan outcomes, and next action. Evaluate `Chantier potentiel` for material persona, positioning, legal, trust, pricing, or funnel decisions.

## Stops And Ethical Bar

- Do not invent testimonials, proof, conversion results, pricing, guarantees, product capabilities, or business outcomes.
- Never recommend fake urgency, fake social proof, dark patterns, fear, guilt, or unrealistic promises; vulnerable audiences require heightened empathy and honesty.
- Keep recommendations strategic; route sentence-level repair or full rewrites to `copy` when that is the actual request.
- Match output language to the user and preserve correct French accents.
- Preserve focused contract, metadata, and budget checks after playbook changes.
