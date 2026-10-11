---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-22"
status: active
source_skill: 900-shipglows-core
scope: intent-to-outcome-execution
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/intent-to-outcome-autonomy.md
depends_on:
  - artifact: skills/references/intent-to-outcome-autonomy.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/master-workflow-lifecycle.md
    artifact_version: "1.6.0"
    required_status: active
  - artifact: skills/references/master-delegation-semantics.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-22 separates universal Git persistence from outcome-specific activation and includes identity, strategy, content, workflow, and code artifacts."
  - "Wave 15 extracted post-selection execution procedure from the mandatory autonomy core."
next_review: "2026-09-12"
next_step: none
---

# Intent-to-Outcome Execution

Load this leaf only after the actionable owner and execution route are resolved.

## Establish The Contract

Record the user outcome, target context, scope, invariants, failure behavior, proof path, affected documentation, authority boundary, and stop conditions. Resolve material questions before implementation unless a bounded evidence-gathering spike owns them.

Before spec or readiness work that changes product direction, scope, or promised behavior, check governance sufficiency. Continue when canonical truth is sufficient. Recover safely inferable gaps through `300-sg-docs update`. If missing truth is material, ask exactly one recommended decision, persist it, and resume automatically. Never ask the operator to start `sg-docs`.

## Execute A To Z

Continue through every applicable stage:

`discover -> specify/plan -> ready -> create/implement -> check -> test/prove -> verify -> update affected docs/content -> commit/push -> activate/publish/deploy when authorized -> close`

- Invoke internal engines without asking the operator to select or schedule them.
- Continue automatically after a successful internal stage.
- Repair in-scope failures and rerun relevant proof before reporting a block.
- Preserve `project -> business/brand/product -> outcome -> surface -> work item`, the accepted intent, authorization, and proof obligations across handoffs.
- Keep one public outcome owner; collaborators remain internal.
- Persist durable repository-representable artifacts through the approved commit/push path, including identity, strategy, content, documentation, workflow, and code artifacts.
- Treat provider-native sources as external authorities: record canonical links and proportionate exports or manifests in Git, without pretending an export is the editable native source.
- Apply the authority actually granted to commit, push, publication, adoption, application, rollout, deploy, communication, billing, production mutation, and destructive actions.

## Return Control

Return only when the outcome has proportional evidence, one genuine operator-owned decision remains, authority or inaccessible manual proof is required, or safe diagnosis and alternatives leave a real block. Lead the final report with outcome, evidence, residual risk, and the one remaining operator action when applicable. Never expose internal lifecycle commands as required micromanagement.
