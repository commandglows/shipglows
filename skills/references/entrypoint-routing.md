---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.13.0"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-27"
status: active
source_skill: 009-sg-skill-build
scope: entrypoint-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/603-sg-private/SKILL.md
  - skills/900-shipglows-core/SKILL.md
  - skills/400-sg-audit/SKILL.md
  - skills/references/master-delegation-semantics.md
  - skills/references/question-contract.md
  - skills/references/skill-execution-fidelity.md
  - skills/references/execution-posture-tags.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
depends_on:
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-22: route business, identity, editorial expression, and software implementation as distinct outcomes instead of sending every site or business change to build."
  - "User decision 2026-05-04: create `000-shipglows` as the primary non-technical router across the existing skill taxonomy."
  - "User decision 2026-05-04: `000-shipglows` should use direct main-thread handoff to selected master skills instead of nested master-skill subagents."
  - "User decision 2026-05-04: ambiguous routing questions should be numbered decision briefs with a responsible recommendation."
  - "User decision 2026-05-06: design-related requests should route to a master `006-sg-design` lifecycle entrypoint."
  - "2026-06-11 ShipGlows Core natural-language routing added for internal 900-shipglows-core."
  - "Operator correction 2026-07-17: deterministic micro-edits must bypass domain and lifecycle routing."
  - "Operator decision 2026-08-14: exact local routine reversible mutations may use fast validation without loading strategic-choice overhead."
  - "Operator decision 2026-08-20: execution posture is expressed by transversal #local, #nolocal, and #ci tags rather than métier modes."
next_review: "2026-08-17"
next_step: "/104-sg-end shipglows-skill-execution-fidelity-plugin-pilot"
---

# Entrypoint Routing

## Purpose

This reference defines the shared routing rules for `000-shipglows`, the primary natural-language entrypoint for ShipGlows.

It does not replace lifecycle, bug, release, content, maintenance, audit, or skill-maintenance owner contracts. It decides which existing contract should own the request.

It defines only the routing-question rule. Load `skills/references/question-contract.md` for the shared question/default contract, then ask one concise numbered question when the route is materially ambiguous.

## Core Rule

Route to the smallest existing owner that can safely own the outcome.

Apply the Skill Selection Proportionality Gate from `skills/references/skill-execution-fidelity.md` before domain classification. A clear bounded request with a few coherent enumerable actions and targets, no material direction for the agent to choose, and focused proof stays in direct main-thread execution without another approval prompt. This includes targeted file edits, exact-scope commits, ordinary resolved pushes, and small explicit sequences; local versus remote and reasoning effort do not classify the request. That authority does not authorize a chantier; if the work expands materially or requires directional proposal, use the full approval path from `skills/references/mutation-plan-approval.md`. Do not load an owner skill merely because a bounded target belongs to its domain. An explicitly named skill remains authoritative and uses its smallest safe mode.

Before natural-language routing, check whether the user included one or more focus tags defined in `skills/references/shipglows-terms.md` such as `#partner`, `#offer`, `#growth`, `#traffic`, `#acquisition`, `#clarity`, `#source`, `#rules`, `#docs`, `#canon`, `#quality`, `#shipglows`, or `#proof`. When present, load the referenced canonical documents first and treat them as routing priorities for the current turn.

Execution posture tags are a distinct transversal family. When `#local`,
`#nolocal`, or `#ci` appears anywhere in the instruction, load
`skills/references/execution-posture-tags.md`, apply it after owner/mode
resolution, and keep the free-text objective active. These tags change allowed
proof effects, not ownership or authority. Reject conflicts rather than using
argument order as precedence.

Focus tags are not decorative reminders. They change execution posture, artifact preference, and route bias for the current turn. Do not merely acknowledge them; apply their routing implications below.

A `#feature:<term>` token is an optional technical-navigation hint, not a command language. Treat it as a high-priority cue for behavior-index recovery before broad search, keep the rest of the message active, and keep it distinct from `%Profile` or `profile=` routing.

Named profiles are a separate router-layer construct above focus tags. Load `skills/references/profile-activation.md` when a known profile activation such as `%Victoire`, `%Tariq`, `profile=victoire`, `profile=tariq`, or `profile=traffic-manager` appears. Skills still own execution; profiles bias arbitration and output posture.

If the instruction is about modifying, improving, auditing, or hardening ShipGlows behavior, contracts, routing, publishing, editing, governance, or skills, treat ShipGlows itself as the target system by default. Do not infer the current project repository as the edit target unless the user explicitly names that project.

An invocation of `900-shipglows-core` or another ShipGlows-maintenance skill is itself sufficient evidence that the intended target is ShipGlows unless the user explicitly names a different repository.

That inference must hold even when the user's message omits the words "ShipGlows" or describes the desired change only by behavior, outcome, or contract language.

An open project repository, a current working directory, or a nearby project discussion is not an explicit target override. Treat that context as background only until the operator explicitly says the requested change belongs to the project repository rather than ShipGlows itself.

If the request needs more than one phase, route to the relevant master skill. If the request clearly names one specialist phase, route to that focused owner skill. If no file work or lifecycle action is needed, answer directly.

An explicit `#feature:<term>` hint does not replace the free-text request. It only sharpens the first routing pass so the behavior-index layer is loaded before broad repository search.

Before natural-language routing, resolve three-digit skill-code prefixes through `skills/references/skill-code-index.md`. Accepted forms include `001`, `001-sg-build`, `001sfbuild`, and `001 sg-build`. Codes point to runtime skill names such as `001-sg-build`.

## Focus Tag Execution Priorities

When focus tags are present, merge them into the narrowest coherent route instead of treating them as passive flavor.

### Business Tags

Tags such as `#partner`, `#growth`, `#traffic`, `#acquisition`, `#offer`, `#roi`, `#funnel`, `#positioning`, `#distribution`, `#monetization`, `#retention`, `#decision-maker`, `#leverage`, `#founder-mode`, `#pitch`, and `#portfolio` imply:

- prefer routes that improve business leverage or end-user success over routes that only produce local technical cleanup
- when the task is ambiguous between generic implementation and public/business framing, inspect `shipglows_data/business/` before choosing
- if a stronger owner skill or ShipGlows route materially improves adoption or first success, surface it as the recommended path instead of stopping at neutral advice
- when several edits are possible, choose the smallest durable change that improves conversion, clarity, adoption, retention, or operator leverage
- when `#traffic` or `#acquisition` is present, bias toward channel-to-landing fit, tracking readiness, and measurable acquisition learning; use `Tariq` as the relevant profile when the user asks who should arbitrate
- when `#pitch` is present, reload `shipglows_data/business/portfolio-project-pitch-links.md` and prefer the active project's own pitch URL if the index points to one before answering or routing
- when `#portfolio` is present, reload `shipglows_data/business/portfolio-project-pitch-links.md` and scan the index for the most relevant cross-project opportunity before answering or routing

### Content Tags

Tags such as `#end-user`, `#cta`, `#clarity`, `#faq`, `#voice`, `#audience`, `#source`, `#repurpose`, `#pillar`, and `#seo-intent` imply:

- bias toward `007-sg-content`, `008-sg-customer`, or declared public content surfaces when the problem is mainly message quality, activation clarity, discoverability, or objection handling
- prefer public copy, onboarding flow, FAQ, or semantic-architecture fixes over isolated code edits when the friction is mostly comprehension or activation
- treat readability, user usefulness, and discoverability as owner concerns, not as optional polish
- when `#source` is present, load `skills/references/source-intake-classification.md` and classify source type, project/corpus fit, useful angle, risks, and owner skill before transforming the source

### Governance Tags

Tags such as `#rules`, `#docs`, `#canon`, `#drift`, `#owner`, `#freshness`, `#traceability`, `#entrypoint`, `#contract`, `#public-docs`, `#internal-docs`, and `#single-source` imply:

- prefer the full governed-project rule set before deciding whether a missing artifact is bootstrap, migration debt, or real non-compliance
- when `#docs` is present, bias toward documentation architecture, metadata, canonical placement, and `300-sg-docs` owner routing before treating the issue as generic project governance
- prefer the canonical owner artifact instead of editing duplicated surfaces first
- if code, docs, and public surfaces are potentially diverged, route to the owner path that can repair the source of truth and then propagate outward
- bias toward `002-sg-maintain`, `300-sg-docs`, `900-shipglows-core build`, or ShipGlows-internal docs work when the main issue is documentation truth, routing truth, or governance drift
- when `#public-docs` and `#internal-docs` conflict, ask one concise routing question only if the same edit cannot safely satisfy both

### Execution And System Tags

Tags such as `#quality`, `#vfbf`, `#scope`, `#ship`, `#routing`, `#proof`, `#no-drift`, `#shipglows`, `#shupflow`, and `#shipglows-core` imply:

- prefer the narrowest owner route that still preserves proof, verification, and closure
- when `#vfbf` appears, optimize for a quick, bounded, durable pass that leaves an explicit trace without expanding the conversation into a new main focus
- when the operator says `#shipglows` or `#shupflow`, default the target to ShipGlows internal files and doctrine even if a project repo is open
- when `#shipglows-core` appears, treat ShipGlows behavior, fidelity, or doctrine hardening as the primary route unless the operator explicitly redirects to another repo
- when `#proof` or `#ship` appears, do not end at recommendation-only output if ShipGlows can execute a proof or ship path in the current run

## Focus Tag Question Rule

Do not ask the operator to restate what a focus tag already resolved.

Ask a routing question only when:

- two or more tags create a real owner conflict with materially different artifacts
- the same request cannot be satisfied safely at one owner layer
- the tags imply different destructive, production, payment, auth, or public-claim posture

When asking, name the tag tension explicitly and recommend the narrowest safe route.

## Execution Topology

Use direct main-thread handoff for selected skills.

Do not launch selected master skills inside subagents. The selected master skill owns any delegated sequential execution after handoff through `skills/references/master-delegation-semantics.md`.

A read-only routing scout is allowed only for cheap classification evidence and must not edit, stage, commit, push, deploy, mutate trackers, invoke a master skill, or launch further subagents.

## Routing Matrix

### Public Target And Owner Resolution

Resolve every actionable request as `project -> business/brand/product -> outcome -> surface -> work item` before selecting an owner. A project may contain several businesses, brands, products, or public expressions. Inspect conversation and repository evidence before asking, and ask only when an unresolved choice materially changes the outcome; after the answer, continue under one public métier owner.

The public owner labels are `sg-development`, `sg-design`, `sg-experience`, `sg-bug`, `sg-engineering`, `sg-maintenance`, `sg-release`, `sg-content`, `sg-marketing`, `sg-seo`, `sg-docs`, `sg-planning`, `sg-private`, and `sg-help`. Numeric runtime skills remain internal engines and compatibility identities. Load `skills/references/intent-to-outcome-autonomy.md` and keep the original outcome active through internal routing.

| Operator intent | Primary route |
| --- | --- |
| Pure question, explanation, model/help clarification, or advice with no files | Direct answer |
| Clear bounded request with few enumerable actions/targets and no material directional choice, including a targeted edit, exact-scope commit, ordinary resolved push, or small explicit sequence | Direct main-thread execution with focused proof; no owner skill |
| Numeric skill code such as `001`, `001-sg-build`, or `001sfbuild` | Runtime skill from `skills/references/skill-code-index.md` |
| Build or change a user-facing feature and also think about end-user clarity, UX/UI friction, activation, beginner adoption, or first-success guidance | `001-sg-build` first; `001-sg-build` evaluates the post-implementation `008-sg-customer` gate |
| Software feature, application behavior, code implementation, technical site implementation, or broad code-like goal without durable bug state | `001-sg-build` |
| Business model, offer, market, positioning, message strategy, or verbal brand foundation | public `sg-marketing`; internal `009-sg-marketing` selects its bounded mode |
| Brand identity, visual identity system, art direction, logo system, palette, typography, or cross-surface visual expression | public `sg-design identity`; internal `006-sg-design identity` |
| Audience content, editorial expression, content site strategy, public documentation, or publication lifecycle | `007-sg-content` |
| Internal documentation, governed business truth, workflow contract, or agent documentation | `300-sg-docs` |
| Recurring upkeep, dependency posture, docs drift, checks, audits, migrations, project hygiene, security maintenance | `002-sg-maintain` |
| Observed defect, `BUG-ID`, retest, bug closure, bug fix state, bug ship risk | `003-sg-bug` |
| Release confidence, preview/prod deployment, deployed truth, runtime logs, production health, post-deploy proof | `004-sg-deploy` |
| Deploy-target recommendation for an app project | `004-sg-deploy` using `skills/references/deploy-target-matrix.md` as the canonical advisory source |
| Content strategy, repurposing, drafting, enrichment, SEO/copy audit, editorial governance, content apply/publish | `007-sg-content` |
| Source intake, pasted email/article/transcript/URL classification, project fit, useful angle, or owner-skill choice | Load `skills/references/source-intake-classification.md`, then route to the owner skill |
| Design request, identity work, UI/UX work, redesign, design tokens, design playground, accessibility design, component design, visual proof, or token migration | `006-sg-design` |
| End-user experience, UX/UI clarity, trust, friction, feature activation, onboarding, setup guidance, first-success path, permission/setup sequencing, or recoverable states | `008-sg-customer <audit|flow|onboarding|recovery> <target>`; ambiguous intent asks among the four modes |
| Local-first data promotion, cloud hydration, account sync, merge/conflict policy, reinstall recovery, or sync/save UX state | public `sg-engineering sync`; internal engine `600-sg-local-cloud-sync` |
| Product access, paid plans, premium gates, entitlement ledgers, provider events, activation codes, refunds/revokes, support access flows, or backend access gates | public `sg-engineering access`; internal engine `601-sg-product-entitlements` |
| Cross-platform behavior or capability parity | public `sg-engineering parity`; internal engine `602-sg-platform-parity` |
| Explicitly remember, retrieve, search, archive, or restore a private local path, URL, alias, or Vivaldi bookmark | public `sg-private memory`; internal `603-sg-private memory` |
| New skill, skill modification, skill runtime visibility, skill public page, skill docs/help coherence | `900-shipglows-core build` |
| ShipGlows Core execution-fidelity audit or public-plugin packaging readiness for ShipGlows itself | `900-shipglows-core audit <scope>` or `900-shipglows-core packaging <scope>` |
| One obvious audit domain only | relevant `400-sg-audit-*` or `400-sg-audit` |
| One obvious focused lane: checks, docs, browser proof, auth diagnosis, manual QA, dependency posture, migration, final ship | focused owner skill |
| Ambiguous material route | Ask one concise numbered routing question |

## Ambiguity Rules

Ask when the answer changes:

- owner skill
- durable work item type
- security, data, permission, or destructive posture
- public claim or content surface
- staging, deployment, closure, or ship semantics
- whether the run should mutate files or stay read-only

Do not ask when a best-practice route is clear, low-risk, reversible, already covered by an existing owner skill, compatible with current project context, and verifiable in the current run.

When a routing question is required, it follows `skills/references/question-contract.md`: numbered, concise, clear about why the route changes behavior or risk, and explicit about the recommended route when a responsible recommendation exists.

## Handoff Requirements

A direct handoff must preserve:

- the original user instruction
- selected skill argument
- report mode when explicit
- stop conditions and owner-skill gates
- active user language for user-facing questions and reports

The router may state the route briefly, then continue under the selected skill contract. It should not end with a manual command recommendation unless handoff is blocked or the user only asked which skill to use.

## Non-Goals

- Do not create a new master lifecycle.
- Do not duplicate specialist internals.
- Do not create specs, bug files, content, commits, deployments, or public claims directly.
- Do not treat direct handoff as parallelism.
- Do not use nested master-skill-in-subagent execution.
