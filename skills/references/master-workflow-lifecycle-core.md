---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
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
  - "Wave 12 measured the detailed lifecycle reference as too costly for an ordinary route decision."
next_review: "2026-11-12"
next_step: none
---

# Master Workflow Lifecycle Core

Use this core to select and guard a multi-stage route. Load the detailed `skills/references/master-workflow-lifecycle.md` only when work-item reconciliation, blueprint/readiness interpretation, owner sequencing, bug-state rules, or closure orchestration needs detail not resolved here.

## Decision Contract

Pilot one current work item: ready spec, bug file, bounded mini-contract, release scope, audit finding set, content surface, or skill-maintenance target. Existing durable truth wins; several plausible work items require one targeted choice. Non-trivial, cross-surface, security/data/deployment/public-claim work requires a ready durable contract. A mini-contract is only for narrow, local, low-risk work verifiable now.

Use this order, omitting inapplicable gates:

```text
intake -> work item -> readiness -> topology -> owner execution
-> proportional evidence -> verification -> documentation reflection
-> closure -> bounded ship/deploy
```

Master skills orchestrate; specialist owners retain their internals. Checks, hosted deployment, browser, auth, manual QA, verification, closure, and ship remain with their named owners. Validation is checkpoint-based, not message-based. Intermediate work may defer validation visibly, but completion, closure, and ship claims require proportional evidence.

## Stop And Escalation Gates

Stop or load the detailed lifecycle when no single work item is safe, readiness is ambiguous, an owner gate would be bypassed, evidence does not match the promised outcome, verification fails, unrelated dirty files enter scope, or the next action changes material scope, security, data, permissions, destructive behavior, public claims, staging, closure, or release semantics.

Never treat a green check, push, deployment state, HTTP response, generated changelog, or locally rendered surface as sufficient outcome proof by itself.

## Handoff Receipt

Record the selected work item, route, topology status, owner sequence, validation/evidence result, verification state, and only real blockers. Detailed lifecycle history belongs in agent/handoff reporting, not the concise user result.

