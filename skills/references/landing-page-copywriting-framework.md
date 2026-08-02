---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 009-sg-marketing
scope: landing-page-copywriting-framework
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/009-sg-marketing/SKILL.md
  - skills/009-sg-marketing/references/copywriting-audit-playbook.md
  - skills/references/design-inspiration-library.md
  - skills/references/content-quality-rubric.md
  - skills/references/editorial-content-corpus.md
depends_on:
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-inspiration-library.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/content-quality-rubric.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/editorial-content-corpus.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Ready reusable-framework spec requires one project-neutral doctrine for landing-page sequence, repetition, and claim safety."
  - "Scenario-first pressure coverage defines loader, sequence, deduplication, and unsupported-claim behavior."
next_review: "2026-08-17"
next_step: "/103-sg-verify Reusable Landing-Page Copywriting Framework"
---

# Landing-Page Copywriting Framework

## Purpose And Owner Boundary

This shared doctrine helps `009-sg-marketing copywriting` audit the argument and decision flow of a landing, sales, or offer page. It is a decision system, not AIDA, not a mandatory section template, and not a second local playbook. The existing copywriting playbook owns application and reporting; this reference owns the reusable sequence, ledger, repetition, and claim-safety rules.

Use it for strategic persuasion structure. Sentence-level clarity, grammar, microcopy, or bounded rewriting remains owned by `009-sg-marketing copy`. Editorial lifecycle, page implementation, publishing, visual design, market research, and product-truth decisions remain with their established owners.

The framework transfers principles only. Do not import project-specific copy, claims, testimonials, page text, or distinctive source expression into shared doctrine or another project.

## Activation

Load this framework only after the operator has selected `copywriting` and its local playbook, and at least one condition is true:

- the bounded target is a landing page, sales page, or offer page;
- the request explicitly concerns section order, section flow, reading flow, repetition, proof placement, objection placement, or CTA sequence on the bounded target.

A non-landing target without an explicit page-section-flow need does not load this framework merely because it contains persuasive or marketing copy. An ambiguous request such as “improve the landing copy” does not choose between `copy` and `copywriting`; the public dispatcher must ask its focused routing question.

## Required Inputs

Establish these inputs before recommending a sequence:

- intended buyer and the buying context;
- awareness level and funnel stage;
- page goal and conversion event;
- offer, terms, and CTA destination;
- current product truth: shipped capabilities, constraints, onboarding, pricing, and downstream experience;
- proof inventory with evidence state and provenance;
- material objections, anxieties, alternatives, and decision risks;
- governing business, product, brand, GTM, and editorial contracts, including the page-intent and claim records when present;
- the existing page inventory when auditing a current page.

Missing intended buyer, offer, page goal, product truth, or governing claim context prevents an authoritative plan. Missing or weak proof may still permit a confidence-limited structural plan, but only with visible proof gaps and claim-safe placeholders.

## Reader-Question Argument Spine

Build the argument from the reader’s unresolved questions, not from a fixed list of blocks. The spine is intentionally flexible: select, combine, omit, or reorder questions according to awareness, offer complexity, risk, evidence, and conversion goal.

Typical questions include:

- Is this for someone in my situation?
- What meaningful outcome or problem is in scope?
- Why should I consider action now, without manufactured urgency?
- What is the proposed approach or mechanism?
- Why this offer rather than the status quo or a credible alternative?
- What exactly do I receive, and how does it work?
- What evidence supports the promise and the mechanism?
- Will it fit my constraints, and what could prevent success?
- What are the terms, tradeoffs, and risk boundaries?
- What is the appropriate next commitment?

Convert the selected questions into an argument spine. Each step must resolve uncertainty, add decision value, or prepare the next question. Do not create a section because a familiar framework expects one. A highly aware buyer may need offer, proof, terms, and action with little problem education; a complex or unfamiliar offer may need mechanism and objection work before an ask.

## Section Role Ledger

Inventory existing and proposed sections before reordering them. Use one row per meaningful section.

| Field | Contract |
| --- | --- |
| Section identity | Stable current or proposed label; distinguish repeated instances. |
| Reader question | The material question this section answers now. |
| Unique job | The one decision role that justifies the section. |
| New information | What the reader learns here that was not authoritative earlier. |
| Claim IDs | IDs from the Claim/Proof Ledger used by the section. |
| Proof | Current evidence shown here, its state, and provenance. |
| Objection handled | The specific objection reduced or resolved. |
| Transition | Why the reader is ready for the next section or decision. |
| CTA role | None, orientation, micro-commitment, primary CTA, or secondary CTA. |
| Recommended action | One of `keep`, `move`, `merge`, `delete`, or `create`, with rationale. |

A retained or created section needs a distinct reader question and Unique job. If two sections perform the same job with no material new information, proof, objection, or decision function, they compete rather than compound.

## Claim/Proof Ledger

Assign a stable claim ID to every material promise, price, capability, guarantee, outcome, comparison, urgency statement, testimonial, user count, or conversion result. Record:

| Field | Contract |
| --- | --- |
| Claim ID | Stable identifier used by section rows. |
| Proposed claim | The bounded meaning, not a strengthened rewrite. |
| Claim type | Product, outcome, price, capability, social proof, guarantee, comparison, urgency, or other. |
| Current source | Product/business/editorial contract, verified behavior, approved evidence, or none. |
| Evidence state | Supported, partial, stale, needs proof, or claim mismatch. |
| Safe treatment | Use, qualify, replace with supported truth, placeholder, or omit. |
| Sequence role | Where the supported claim or proof affects a reader decision. |

The framework must not invent any testimonial, user count, conversion result, guarantee, urgency, price, capability, or business outcome, and it must not strengthen one beyond its evidence. Reordering cannot repair a claim mismatch. Record `needs proof` or `claim mismatch`, then build the strongest honest sequence supported by current evidence.

Proof is not repeated wording. A paraphrased promise without new evidence remains the same unsupported claim.

## Repetition Ledger

Create one row for each recurring message, benefit, mechanism, differentiator, objection answer, or CTA promise.

| Field | Contract |
| --- | --- |
| Message ID | Stable identifier for the underlying meaning. |
| First authoritative exposition | The section that explains the message completely enough to become its source on the page. |
| Later occurrence | Every later section that repeats or depends on the message. |
| Added material value | Named proof, specificity, contrast, objection handling, recap value at a real decision point, decision value, or distinct CTA function. |
| Decision | Retain, merge, move, delete, or narrow. |
| Evidence | Claim/proof IDs or reader-decision rationale supporting retention. |

Treat a cosmetic paraphrase as duplication, not progress. Retain a later occurrence only when the ledger names its added material value. Recap alone is not enough unless it appears at a real commitment point and changes comprehension or action. When no added value exists, merge it into the first authoritative exposition or delete it.

## Proof, Objection, And CTA Sequence

- Put proof before the claim-dependent ask. Place it close enough to the claim or risk it supports that the reader need not remember an unsupported promise across the page.
- Address each material objection before the decision it blocks. Do not create a generic FAQ when the objection belongs next to mechanism, fit, terms, price, or risk.
- Use CTA progression that matches awareness and commitment. An early orientation or micro-commitment may be appropriate; the primary CTA belongs after the minimum honest case is established.
- A secondary CTA must serve a distinct uncertainty or readiness state, not compete with the primary CTA or disguise the same action under different wording.
- Risk reversal follows verified policy and evidence. Never manufacture guarantees, scarcity, deadlines, urgency, or social proof.
- Long pages may repeat a CTA when the Repetition Ledger names a distinct CTA function or real decision point; repeated buttons do not justify repeated promises.

## Landing Sequence Plan

Produce an ordered plan after completing the three ledgers. The plan is the visible audit output, not a hidden reasoning artifact.

For every current or proposed section, include:

- order and section identity;
- action: `keep`, `move`, `merge`, `delete`, or `create`;
- reader question and Unique job;
- new information and transition;
- claim/proof IDs and evidence state;
- objection handled;
- CTA role;
- rationale and confidence.

Action meanings:

- `keep`: the section already performs a distinct job in the right place;
- `move`: the section is useful but answers a question too early or too late;
- `merge`: its useful material belongs with another authoritative section;
- `delete`: it adds no material reader or decision value, or depends on an unusable claim;
- `create`: a material reader question, proof bridge, objection, transition, or decision step is absent and supported content can fill it.

The output must also show the selected framework path, the argument spine, proof gaps and claim mismatches, material repetitions retained with reasons, and any confidence limit. When no safe plan can be completed, report the exact missing input and safest next owner action instead of returning an improvised template.

## Error Behavior

- Missing audience, offer, page goal, product truth, brand, editorial intent, claim context, or material evidence produces a visible blocked or confidence-limited result. Name the missing contract or evidence and the concrete owner route.
- A missing shared framework or required local playbook blocks the landing-specific pass. Report the canonical missing path and route the ShipGlows-owned gap to `900-shipglows-core`; the auditor must not improvise a generic sequence.
- Unsupported content stays `needs proof`, `claim mismatch`, qualified, placeholder-only, or omitted. Persuasive language must not conceal the gap.
- A non-landing target without an explicit page-section-flow need does not load the framework; continue with the selected copywriting playbook’s existing audit contract.
- Inspiration remains optional. If the operator selects none, continue from project evidence; never choose or load a private bundle silently.
- Never force a rigid universal order, create a public marketing mode, run `copy` and `copywriting` together, use fake urgency or social proof, or treat repetition as evidence.
- Success and failure are both observable: return the Landing Sequence Plan or the failed precondition plus its concrete owner route.

## Reference Boundaries

- `design-inspiration-library.md` owns the page/section/copy-pattern taxonomy, rights boundary, at-most-five shortlist, and operator selection before bundle loading. Transfer patterns, not source phrasing.
- `editorial-content-corpus.md` owns public page intent, claim impact, and documentation update plans.
- `content-quality-rubric.md` owns optional rubric scoring when explicitly requested. The sequence plan does not add a new scoring surface.
- `decision-quality-contract.md` owns the excellence, structure-replacement, and anti-shortcut bar.

Do not reproduce those contracts here. Load them only when their existing gates apply.

## Pressure Scenarios

### LPF-LOAD

Given a `copywriting` target that is a landing, sales, or offer page—or an explicit request about its section flow—the already selected local playbook loads this shared doctrine. A non-landing target without that explicit need continues without it. Exactly one public mode and one local playbook remain active.

### LPF-SEQUENCE

Given known audience, awareness, goal, offer, objections, and proof, build the Reader-Question Argument Spine and ordered Landing Sequence Plan. Every retained or created section must have a distinct reader question, Unique job, transition, evidence role, and CTA role; omit any conventional section that does not advance the decision.

### LPF-DEDUPE

Given one promise repeated across hero, benefit, feature, pricing, or final-CTA sections, select its first authoritative exposition. Merge, move, narrow, or delete later cosmetic paraphrase; retain a later mention only when the Repetition Ledger names added proof, specificity, contrast, objection handling, recap value, decision value, or a distinct CTA function.

### LPF-CLAIMS

Given a desired testimonial, user count, conversion result, guarantee, urgency, price, or capability without current evidence, record `needs proof` or `claim mismatch`. Do not invent or strengthen it. Preserve the strongest honest sequence using supported product truth, qualified language, or a visible placeholder or omission.
