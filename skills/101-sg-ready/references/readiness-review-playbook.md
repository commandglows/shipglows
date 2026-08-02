---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-07-18"
status: active
source_skill: 009-sg-skill-build
scope: 101-sg-ready-review-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/101-sg-ready/SKILL.md
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/guidelines.md
depends_on:
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-06-27 targeted hardening pass moved long readiness heuristics out of the 101-sg-ready activation contract while preserving local readiness gates."
  - "2026-06-26 batch A hardening audit identified 101-sg-ready body-size pressure as the clearest execution-fidelity risk in the current corpus."
  - "Operator correction 2026-07-17: readiness must prove that compatible preferred stack presets were applied before blueprint or provider decisions."
  - "Operator correction 2026-07-18: user-mode readiness reports hide lifecycle internals and end with plain-language choices when the chantier remains open."
next_review: "2026-07-04"
next_step: "/103-sg-verify 101-sg-ready execution-fidelity compaction"
---

# 101-sg-ready Readiness Review Playbook

## Purpose

This reference holds the detailed readiness heuristics for `101-sg-ready`.
The top-level `SKILL.md` stays focused on the activation contract, while this
playbook carries the longer review checklist, report templates, and reviewer
rules that do not need to remain on the first screen.

## Structure Review

The spec must contain:

- `Title`
- `Status`
- `User Story`
- `Minimal Behavior Contract`
- `Success Behavior`
- `Error Behavior`
- `Problem`
- `Solution`
- `Scope In`
- `Scope Out`
- `Constraints`
- `Dependencies`
- `Invariants`
- `Links & Consequences`
- `Documentation Coherence`
- `Edge Cases`
- `Implementation Tasks`
- `Acceptance Criteria`
- `Test Contract`
- `Test Strategy`
- `Risks`
- `Execution Notes`
- `Open Questions`

If a required section is missing, the verdict is `not ready`.

## User-Story Alignment Review

Before looking at implementation detail, verify that the spec clearly links:

- the user problem
- the actor
- the trigger
- the expected behavior
- the business or operational value
- the explicit scope limits
- the declared launch and roadmap platform footprint for greenfield products when it affects architecture
- the compatible presets from `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md`, or a documented reason each applicable preset is unsuitable

Refuse the spec if a fresh reader cannot answer without hesitation:

- who wants what, and why?
- what does the feature accept or trigger?
- what does it produce or make observable?
- what happens when it fails?
- what does observable success look like?
- what does correctly handled failure look like?
- which major edge case must be covered?
- what changes concretely for the user or operator?
- what does not change?
- how will we know the user story is satisfied?

`Solution`, `Implementation Tasks`, and `Acceptance Criteria` must stay
traceable to the user story. A purely technical task with no explainable link to
the promised result is a readiness gap.

## Real Readiness Review

Check:

- frontmatter exists or an equivalent metadata convention is present
- `artifact: spec`, `metadata_schema_version`, `artifact_version`,
  `source_skill`, `created`, `updated`, `status`, `scope`, `risk_level`,
  `security_impact`, and `docs_impact` are filled
- `depends_on` lists the versions of business and technical docs used by the
  spec, or explicitly records `unknown` during migration
- no business or technical dependency used by the spec is known stale without
  explicit review
- the Documentation Freshness Gate is satisfied when the spec depends on a
  framework, SDK, service, API, auth, build, migration, or integration
  behavior
- if the spec requires manual proof, `Test Contract` includes `surface`,
  `proof_profile`, `proof_order`, `checklist_path` when applicable,
  `required_scenario_ids`, `required_results`, and an explicit
  `exception_with_proof` or `exception_without_proof`
- every required scenario is actionable and linked to implementation tasks
- `Status` is `draft` or `reviewed`, not already `ready` without verification
- no `TBD`, `TODO`, placeholder, or vague critical wording remains
- `Open Questions` is `None`
- the spec does not hide dependencies on conversation history
- it names important business preconditions, postconditions, and invariants
- `Minimal Behavior Contract` is a non-technical behavioral paragraph that
  covers trigger/input, result, failure, and a primary edge case
- `Success Behavior` and `Error Behavior` define observable behavior and proof
- successful actions produce an observable state change, or the spec justifies
  why success may stay silent and how it remains verifiable
- failing actions produce an observable explanation or recoverable state, or the
  spec justifies why failure may stay silent and how it remains recoverable
- `Execution Notes` gives an implementation approach, file-reading order,
  validation commands, stop conditions, and constraints such as packages,
  patterns, data flow, abstractions to avoid, and scope boundaries
- each task has a target file, explicit action, coherent dependency order, and a
  validation check
- `Links & Consequences` names upstream/downstream systems, consumers, and
  cross-validations
- `Documentation Coherence` names impacted docs or explicitly explains `None,
  because ...`
- acceptance criteria cover `Success Behavior`, `Error Behavior`, and edge cases
- UI/design specs name the project's canonical design-system contract or the
  prerequisite task that creates it
- data, auth, permission, feature flag, migration, and config prerequisites are
  explicit when relevant
- runtime diagnostics requirements are explicit, or a valid static exception is
  recorded
- operator autonomy is preserved: diagnostics, tests, verification, and proof
  say what to collect before asking the user
- `Scope Out` meaningfully bounds the work
- greenfield `Scope Out` does not exclude native mobile, web, PWA, or desktop solely because the initial request omitted that surface; platform exclusions are operator-backed, and `mobile-first` is not treated as equivalent to iOS/Android apps
- when the spec touches ShipGlows artifacts, skills, reports, technical docs,
  prompts, or user-facing product copy, it respects ShipGlows language doctrine

If a point materially changes behavior, scope, or security and is neither proven
by existing code nor resolved by the spec, the verdict is `not ready`.

## Adversarial Review

Run a real adversarial pass, not a cosmetic one.

Critique the spec as if you wanted to:

- provoke an implementation that is incorrect but plausible
- bypass the business flow
- force an inconsistent state
- exploit a hidden assumption
- break an adjacent system without detection

Questions to ask:

- could a fresh agent misread a requirement?
- does the minimal contract hide an assumption on input, output, failure, or an
  edge case?
- can `Success Behavior` be validated by a test, sanity check, log, or final
  observable state?
- does `Error Behavior` leave retries, rollbacks, timeouts, duplicates, or
  partial failures undefined?
- can success appear to do nothing?
- can failure disappear without a useful message, recoverable state, or action?
- would the planned approach choose the wrong package, abstraction, or data flow?
- is an important edge case missing?
- is a task ordered too early?
- is an action too vague to implement without another decision?
- could a linked system break without revalidation?
- is a cross-file or cross-surface consequence missing?
- would docs, FAQ, onboarding, pricing, screenshots, examples, or support copy
  become false after the change?
- can language doctrine confusion make the spec or related artifact easier to
  misread?
- does the test plan really let `103-sg-verify` judge compliance?
- does `Test Contract` distinguish required, optional, and exceptional proof?
- does the spec depend on recent external behavior without current official-doc
  proof?
- can the flow be bypassed by step skipping, replay, duplicate submission, stale
  state, or concurrent input?
- is there a false assumption that UI alone provides security?
- is there a false assumption that a local style patch is acceptable instead of a
  design-system source-of-truth change?
- does the spec assume honest actors, valid identifiers, clean external data, or
  a perfect event order?
- are non-nominal actors covered: no-rights user, malicious user, failing third
  party, admin, async job, legacy system?

If yes, the spec is not ready.

## Security Review

Perform a proportional security review guided at minimum by OWASP ASVS / Top 10
families and NIST SSDF habits.

For any spec touching auth, permissions, sensitive data, uploads, HTML/Markdown
rendering, APIs, webhooks, payments, admin, secrets, external integrations,
action execution, files, search, prompts, or automations, verify explicitly:

- Authentication: who can initiate the action and how identity is established
- Authorization: who can read, create, modify, delete, approve, or retry, and
  whether server-side controls are required
- Input validation: which inputs are untrusted and which bounds, formats,
  allowlists, or sanitization rules apply
- Workflow integrity: whether business steps can be bypassed, replayed, or
  injected into forbidden states
- Data exposure: which sensitive data exists and where it travels, stores, logs,
  caches, or exports
- Secrets and configuration: which tokens, keys, webhooks, env vars, machine
  permissions, or third-party accesses need protection
- External integrations: which trust assumptions exist on APIs, webhooks,
  incoming files, generated content, retrievers, or third-party services
- Logging and errors: what must be traced for audit/incident response and what
  must never be logged
- Availability and abuse: rate limits, quotas, size caps, spam/brute-force
  protection, loops, cost explosions, and uncontrolled fan-out
- Multi-tenant boundary: whether one tenant, user, org, or project can see or
  act on another's resources

Refuse the spec if a material security blind spot remains untreated.
For small local changes, require at least:

- `Security impact: none, because ...`
- or `Security impact: yes, mitigated by ...`

If security depends on an unresolved product decision, the spec stays
`not ready`.

## Report Templates

In `report=user`, use this compact shape unless the run is blocked or the user
asks for detail:

```text
🧱 CHANTIER (spec) : [titre]
🎯 VERDICT (HH:mm) : [prêt | non prêt | bloqué]

[Résultat et preuve, en une ou deux lignes]
[Blocages en langage clair, seulement lorsqu'ils changent la décision]

[Si le chantier reste ouvert, terminer par deux ou trois choix numérotés en
langage simple. Ne jamais exposer un chemin de spec, une commande, un skill,
un propriétaire interne, un flux ou une étape de cycle de vie.]
```

Use the detailed form only in `report=agent`, blocked runs, handoffs, or
explicit verbose requests:

```text
## Readiness: [spec title]

Spec: [path]
Checklist:
- Structure: [ok / fail]
- Metadata: [ok / fail]
- User story alignment: [ok / fail]
- Ambiguity: [ok / fail]
- Task ordering: [ok / fail]
- Links & consequences: [ok / fail]
- Acceptance criteria: [ok / fail]
- Success behavior: [ok / fail]
- Error behavior: [ok / fail]
- Documentation coherence: [ok / fail]
- Language doctrine: [ok / fail / not applicable]
- Execution notes: [ok / fail]
- Minimal behavior contract: [ok / fail]
- Adversarial review: [ok / fail]
- Security review: [ok / fail]
- Test contract: [ok / fail / not applicable]

Not ready because:
- [issue]

Adversarial gaps:
- [missing abuse case / bypass / bad state / cross-system consequence]

Security gaps:
- [missing auth/authz/input validation/data protection/logging/abuse control]

Language doctrine gaps:
- [internal contract not English / user-facing output not in active language / French accents missing / casual language mixing]

Verdict:
- ready
- not ready

Next step:
- /102-sg-start [title] if ready
- /100-sg-spec [title] if not ready
## Chantier

Skill courante: 101-sg-ready
Chantier: [spec path | non trace]
Trace spec: [ecrite | non ecrite]
Flux:
- 100-sg-spec: [status]
- 101-sg-ready: [ready | not ready | blocked]
- 102-sg-start: [status]
- 103-sg-verify: [status]
- 104-sg-end: [status]
- 005-sg-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [/102-sg-start title | /100-sg-spec title | explicit action]

Place the shared chantier header immediately before `🎯 VERDICT (HH:mm) : [ready | not ready | blocked]`; do not append a verdict after this body.
```

## Reviewer Rules

- Do not implement from `101-sg-ready`.
- Be strict on blocking ambiguity.
- Prefer `not ready` over a weak approval.
- In user mode, translate gates into user consequences and avoid the full
  checklist when it does not change the decision.
- Reason against the user story, then do a "how does this break?" pass before
  concluding `ready`.
- Make the cyber-security risk level explicit.
- Check active docs, ShipGlows language doctrine, design-system authority, and
  the Documentation Freshness Gate when their gate applies.
- If a missing question changes the contract or security, block instead of
  assuming.
- Give actionable corrections, not vague criticism.
- Refuse a spec that depends on future clarifications to be implemented cleanly.
- If a fresh context is needed for the next step and the skill cannot create it
  itself, ask the user to do so.
- Remain the canonical gate before the first implementation of non-trivial work.
