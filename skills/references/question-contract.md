---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.6.0"
project: ShipGlows
created: "2026-05-05"
updated: "2026-09-01"
status: active
source_skill: 009-sg-skill-build
scope: skill-question-contract
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/*/SKILL.md
  - skills/references/preferred-stacks.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/decision-quality-contract.md
  - skills/references/entrypoint-routing.md
  - skills/references/reporting-contract.md
  - skills/references/strategic-choice-contract.md
  - skills/references/business-context-mesh.md
  - skills/references/guided-business-product-discovery.md
  - skills/references/mutation-plan-approval.md
  - docs/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/strategic-choice-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-01: an explicit product-status capture may persist its answer to the named canonical business field without a second validation ceremony."
  - "Operator correction 2026-09-01: product and experience questions are proactive partnership; technical validation is exceptional, and ordinary Git/GitHub stewardship never asks for validation."
  - "Operator decision 2026-08-15: do not ask a duplicate question before an exact-scope local technical commit already covered by chantier approval."
  - "User request 2026-05-04: skill questions should be numbered, explain why, include helpful icons, and identify the recommended answer."
  - "User clarification 2026-05-04: a default is acceptable only when it is compatible with the current technical/product/editorial context and current best practices."
  - "Operator correction 2026-08-17: recommended defaults should ship useful product value quickly while preserving coherent architecture and non-negotiable safety."
  - "User decision 2026-06-09: skills should be almost fully autonomous and professionally effective, asking fewer questions and only in plain decision language when the operator truly owns the decision."
  - "User decision 2026-06-10: autonomy and question rules should be compact enough to preserve the signal."
  - "User decision 2026-06-28: the operator is not here to code, but is happy to answer precise business-critical questions that the repository cannot answer."
  - "User decision 2026-07-15: a greenfield product stack must be chosen with the operator at the product-consequence level instead of being silently fixed by the agent."
  - "Operator correction 2026-07-17: greenfield platform scope must be established before stack options; ShipGlows must not silently exclude mobile applications and thereby omit Flutter from the decision."
  - "Operator correction 2026-07-17: ShipGlows must apply the established Astro-site and Flutter-app preference before proposing a broad greenfield stack comparison."
  - "Operator clarification 2026-07-17: Astro/Vercel and cross-platform Flutter are first recommendations; ShipGlows must not default a new app to one mobile platform when one codebase can cover Web, iOS, and Android."
  - "Operator correction 2026-07-18: unfinished-chantier choices stay at the outcome and priority layer; internal skills and commands remain agent-owned."
  - "Operator clarification 2026-08-13: short Questionner and Réorienter labels remain valid when the next agent turn actively guides the decision."
  - "Operator decision 2026-08-13: material gaps in governing context may trigger a guided authority question and authorized canonical update."
next_review: "2026-09-13"
next_step: "/104-sg-end greenfield platform footprint question contract"
---

# Question Contract

## Purpose

This reference defines how ShipGlows skills ask user-facing questions.

Product and experience questions are proactive partnership and should be asked readily when the operator's perspective can improve the promise, journey, audience, priority, positioning, or usefulness. Validation requests are different: they interrupt execution and must be rare. A question is a decision brief: why the decision matters, the recommended default when one exists, and the practical options.

The goal is not to avoid questions at all costs. The goal is to avoid useless technical supervision while still asking for operator-owned business truth when that truth materially improves the work.

Load `skills/references/decision-quality-contract.md` before recommending a default. Recommend the fastest, simplest path that meets the accepted product, architecture, and safety floor. Do not demand maximal excellence or proof when a smaller professional slice can ship sooner and teach more.

Load `skills/references/strategic-choice-contract.md` for material operator choices, every unfinished-chantier choice block, and useful completed-chantier continuation controls. It owns business-vision depth and the guided follow-up required after short `Questionner`, `Approfondir`, or `Réorienter` controls.

## Applies To

Load this contract before any user-facing:

- routing question
- clarification question
- product, persona, scope, or content-surface question
- security, data, permission, destructive, unapproved staging, closure, or ship-risk question; exact-scope local commits already covered by an approved bounded technical chantier do not create a new question
- blocked-state recovery question
- selection question for project, file, URL, domain, check set, package, market, or content source
- an unfinished-chantier choice block in a final user-facing report

Do not use it for internal analysis, routine in-flight progress updates, completed
final reports, or subagent instructions where the subagent is forbidden to ask
the user. For an unfinished final report, use the shared continuity-choice rule
from `reporting-contract.md`: its options concern product direction, priority,
or pause/continue, never an internal skill, command, owner, or lifecycle phase.

## Question Versus Validation

Never apply an approval-friction test to a useful product or experience question. It may sharpen the outcome without blocking the current chantier. Ask it when the operator owns relevant intent, taste, priority, audience nuance, experience judgment, or product truth that repository evidence cannot replace. Continue safe in-scope work while the answer is pending when possible.

For a purely technical question, first attempt a professional evidence-backed decision. Ask only when credible safe technical directions have materially different consequences and the repository, accepted architecture, tests, and current standards cannot resolve them. Never ask the operator to supervise implementation mechanics.

A question is not a validation request, and its answer never authorizes a mutation outside authority already granted. A bounded factual-capture question may state in advance that its selected answer will be persisted to one named canonical field; that answer authorizes only this exact record, not adjacent edits or implementation. Before asking for validation, apply `mutation-plan-approval.md`, including clear bounded-request and Git-stewardship authority. Ordinary Git/GitHub commit, push, synchronization, reconciliation, and proven cleanup never create a validation question.

## Ask Threshold

Ask a product or experience question whenever its answer can usefully sharpen one of these outcomes; blocking materiality is not required. Ask a technical question only when its answer changes at least one material outcome:

- owner skill, lifecycle path, or durable work item type
- user-visible behavior, product scope, audience, persona, or content surface
- security, privacy, data retention, permissions, auth, tenant boundary, money movement, or destructive behavior
- public claim, SEO target, brand promise, legal/compliance posture, or cost
- architecture, framework, dependency, provider, runtime behavior, or deployment mode
- staging, deployment, release, closure, ship scope, or bug risk
- validation strategy when the wrong proof would create false confidence

Business, product, audience, and framing facts often belong to the operator rather than the repository. When those facts materially change the output and are not safely inferable, asking is the correct autonomous behavior.

The standard is not "ask less no matter what". It is "ask at the partner layer". If a question sharpens business intent, audience nuance, positioning, or product usefulness that the agent cannot infer confidently from the project, asking is part of doing the job well.

Proceed without asking when the safe default is clear, in scope, low-risk or reversible, compatible with project context and current best practices, and verifiable in the current run.

## Governing Context Recovery

When `business-context-mesh.md` finds a material missing, unknown, stale, or conflicting claim, the agent may initiate a guided update pass instead of ending at `blocked` or inventing a default.

Before asking, show the relevant source, the gap, why it can change the current business outcome, the inspected evidence, and one proposed interpretation. Research facts the agent can establish; ask the ordering authority only for intent, priority, promise, appetite, or acceptance they own. Ask one decision at a time through `guided-business-product-discovery.md` and keep the original chantier active.

A question never authorizes mutation. Before writing the governing source, satisfy `mutation-plan-approval.md` unless the active approved scope already includes that exact document family. After confirmation and authorized persistence, resume the original work automatically. Do not interrupt for an irrelevant gap or a stale date that cannot change the decision.

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

If the obvious or requested option conflicts with project context, public/editorial claims, architecture, security posture, or current best practices, do not silently choose it. Either choose the safe compatible alternative when it is obvious and inside scope, or ask a numbered decision question that explains the conflict.

Never ask broad "anything else?" questions.

Autonomy is the default. Do not ask the operator to choose internal workflow mechanics, file-level implementation details, checklist preferences, or obvious reversible defaults. Report assumptions only when they affect trust or future review.

The operator should not be asked to do the agent's technical localization work. The operator may be asked to provide the smallest missing business, product, or framing fact they uniquely own.

Ask at most one user-facing decision question at a time unless several decisions are inseparable. If multiple low-level gaps exist, collapse them into the smallest operator-owned decision or choose safe defaults and continue.

Do not ask with internal jargon such as "gate", "lifecycle", "trace category", "fresh context", "metadata transition", or model names unless that literal term is the user's decision. Translate the consequence into plain operator language first.

Questions are also below contract when they ask the operator to choose between implementation layers the agent should arbitrate itself, such as:

- local skill patch versus shared-reference patch
- whether an obvious adjacent artifact, link, or follow-through should be created
- whether a visible honesty mismatch should be tightened
- whether a critique should be generalized into a reusable rule

Questions are above contract when they help the operator and agent reason together about:

- the most important business objective behind a content piece
- the audience nuance or objection that should dominate the framing
- the product emphasis that should win when several truthful angles exist
- the strategic priority that the repository cannot infer confidently

## Required Shape

Every user-facing question must be answerable by number. Start each question with a numeric marker and one semantic emoji:

```text
1. 🧭 [decision title]
```

Use the user's active language for labels and explanation. Stable commands, paths, IDs, and status values may stay literal.

Each question must include:

- decision title: the decision in plain language
- why: why the skill needs the answer now
- recommendation: the best default answer and why it is recommended, when a responsible default exists
- options: 2-3 practical choices when useful, with number-prefixed labels
- answer instruction: tell the user they can answer with the number or name another route

Use small semantic icons only as scanning aids. Icons never replace the text label. Use `🧭` for the decision heading, `✅` for the recommended option, and one meaningful distinct icon for each alternative. Use no more than one icon per labelled line.

Product and experience questions should feel like steering with a capable partner, not supervising the skill. Technical questions and validation requests remain rare. If a question would only make the operator approve routine professional execution, including ordinary Git/GitHub stewardship, do not ask it.

## Plain-Text Format

```text
1. 🧭 [Titre de decision]
Pourquoi: [ce qui est bloque, contradictoire ou risque]
Recommande: [option] - [pourquoi c'est le meilleur defaut dans ce contexte]

Options:
1. ✅ [Option recommandee] - [consequence]
2. [emoji pertinent] [Alternative] - [consequence]

Reponds avec le numero, ou precise une autre option.
```

For English users, use `Why`, `Recommended`, `Options`, and `Reply with the number`.

## Recommendation Rules

The recommended answer must be the most responsible default, not the easiest path for the agent.

Prefer recommendations that:

- preserve user trust, data safety, and reversibility
- match the current spec, product contract, and repo conventions
- respect technical docs, `docs/technical/code-docs-map.md`, `CONTENT_MAP.md`, editorial governance, and public claim boundaries when applicable
- follow current best practices for the stack, provider, security model, and deployment mode
- minimize lead time and coordination overhead while preserving the concrete product, architecture, security, performance, and maintainability needs of the accepted horizon
- keep implementation scope bounded enough to verify without lowering solution quality
- avoid premature shipping when proof is missing

When the operator owns the missing truth and no responsible default exists, recommend the question path itself instead of faking certainty.

Name the condition that would make another option better when that matters.

## Pressure Scenarios

- `SSRP-005 safe default`: when the safe professional default is clear, reversible, in scope, and verifiable, the skill proceeds and reports the assumption only if useful.
- `SSRP-006 required decision`: when the answer changes security, data, product behavior, validation confidence, closure, or ship risk, the skill asks one numbered plain-language question with a recommended option.
- `SSRP-007 operator-owned business truth`: when the missing fact is business, audience, product, or framing context that the operator uniquely knows and the repository cannot prove, the skill asks one precise numbered question and continues after the answer instead of calling the task blocked.
- `SSRP-008 greenfield stack partnership`: given the operator asks to create a new product with no accepted stack, when the framework, hosting, data, or provider direction affects ongoing cost, control, maintenance, portability, or lock-in, then the agent presents one recommended product-level stack direction with practical alternatives and obtains a numbered decision before the spec freezes it.
- `SSRP-009 greenfield platform footprint`: given the operator asks for a new Internet product and does not explicitly accept or reject native apps, when platform scope would change the credible framework options, then the agent establishes web/iOS/Android/desktop intent before blueprint matching or stack recommendation and does not silently place mobile apps in `Scope Out`.
- `SSRP-010 preferred stack preset`: given the established footprint includes a public SEO site plus web/iOS/Android application surfaces, when no project constraint contradicts the defaults, then the agent applies Astro plus Flutter with Vercel web hosting before blueprint matching and asks only about uncovered material providers or justified exceptions.
- `SSRP-011 cross-platform first`: given the operator asks for a new mobile or browser application without a durable single-platform restriction, then the agent first recommends one Flutter codebase for Web, iOS, and Android and keeps Astro on Vercel for any separate public SEO surface.
- `SSRP-012 guided short controls`: selecting `Questionner`, `Approfondir`, or `Réorienter` triggers the shared strategic contract's guided follow-up; no selection authorizes mutation or returns a blank question to the operator.
- `SSRP-014 governing-context recovery`: a material governing gap produces evidence, a proposed interpretation, one authority-owned question, an authorized canonical update, and automatic return to the original chantier; agent-researchable facts are never offloaded.
- `SSRP-015 proactive product experience question`: a non-blocking but useful audience, journey, promise, priority, or product nuance is asked precisely instead of suppressed by a generic ask-less rule.
- `SSRP-016 technical question restraint`: a purely technical question is asked only after evidence, architecture, tests, and standards fail to resolve materially different safe directions.
- `SSRP-017 question-is-not-validation`: asking or answering a product/experience question never authorizes a new mutation or expands an approved scope.
- `SSRP-018 no-git-validation-question`: ordinary commit, push, synchronization, safe reconciliation, and proven temporary-artifact cleanup are autonomous Git stewardship, never operator validation questions.
- `SSRP-019 bounded-product-fact-capture`: a missing canonical delivery posture asks one product question that announces exact persistence; the selected answer records only that field and resumes without a second validation.
