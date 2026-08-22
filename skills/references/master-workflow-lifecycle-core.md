---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-22"
status: active
source_skill: 900-shipglows-core
scope: master-workflow-lifecycle-core
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/references/master-workflow-lifecycle.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-22: commit/push is the common persistence layer for durable representable artifacts, while activation varies across identity, content, workflow, and software outcomes."
  - "Wave 12 measured the detailed lifecycle reference as too costly for an ordinary route decision."
  - "Operator decision 2026-08-15: exact-scope local technical commits already covered by chantier approval are routine execution, not a new gate."
  - "Operator correction 2026-08-17: daily MVP construction defaults to bounded commit and push at clean completion, with zero or one focused check unless a material risk or release/audit mode justifies broader proof."
  - "Operator correction 2026-08-17: the lifecycle exists to ship business value quickly through coherent architecture; gates scale to real consequence rather than procedural completeness."
next_review: "2026-11-12"
next_step: none
---

# Master Workflow Lifecycle Core

Use this core to select and guard a multi-stage route. Load the detailed `skills/references/master-workflow-lifecycle.md` only when work-item reconciliation, blueprint/readiness interpretation, owner sequencing, bug-state rules, or closure orchestration needs detail not resolved here.

## Decision Contract

Pilot one current work item: ready spec, bug file, bounded mini-contract, release scope, audit finding set, content surface, or skill-maintenance target. Existing durable truth wins; several plausible work items require one targeted choice. Non-trivial, cross-surface, security/data/deployment/public-claim work requires a ready durable contract. A mini-contract is only for narrow, local, low-risk work verifiable now.

The lifecycle serves useful delivery, not itself. Select the smallest valuable slice, keep the relevant system coherent for the known horizon, minimize coordination and proof overhead, and reach commit/push plus real feedback as quickly as the actual risk permits. Git persistence applies to every durable repository-representable artifact; the activation destination then depends on the outcome: adoption for a decision, application for an identity, publication for content, rollout for a workflow, or deployment for software.

Use this order, omitting inapplicable gates:

```text
intake -> work item -> readiness -> topology -> owner creation/execution
-> proportional evidence -> verification -> documentation reflection
-> commit/push -> bounded activation/publication/deploy -> closure
```

Master skills orchestrate; specialist owners retain their internals. Checks, hosted deployment, browser, auth, manual QA, verification, closure, and ship remain with their named owners. Validation is checkpoint-based, not message-based. Intermediate work may defer validation visibly, but completion, closure, and ship claims require proportional evidence.

For ordinary daily construction, proportional evidence means the smallest proof that can catch the changed behavior: zero automated checks for a low-risk local edit when no focused check adds meaningful signal, or normally one focused regression/contract check for a behavior change. Full suites and broad lint/typecheck/build/test bundles are reserved for release preparation, explicit health/security audits, migrations, broad shared-runtime risk, or a concrete failure that makes broader proof necessary.

A clean completed daily chantier with durable repository artifacts proceeds to bounded commit and push by default. Include the intended push in the chantier approval plan early enough to avoid a second end-of-work ceremony. Do not leave completed commits local unless the operator explicitly requests local-only work, the remote gate was not approved, or a concrete push blocker exists. Commit/push proves persistence, not publication, adoption, application, rollout, or deployment.

## Stop And Escalation Gates

Stop or load the detailed lifecycle when no single work item is safe, readiness is ambiguous, an owner gate would be bypassed, evidence does not match the promised outcome, verification fails, unrelated dirty files enter scope, or the next action changes material scope, security, data, permissions, destructive behavior, public claims, unapproved staging, closure, or release semantics. Exact-scope local commits already covered by an approved bounded technical chantier are routine execution, not a new gate.

Never treat a green check, push, deployment state, HTTP response, generated changelog, or locally rendered surface as sufficient outcome proof by itself.

## Handoff Receipt

Record the selected work item, route, topology status, owner sequence, validation/evidence result, verification state, and only real blockers. Detailed lifecycle history belongs in agent/handoff reporting, not the concise user result.
