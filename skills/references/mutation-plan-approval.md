---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: universal-mutation-plan-approval
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/operator-partnership-contract.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-13: every intentional mutation requires a visible plan and explicit post-plan approval."
next_review: "2026-09-13"
next_step: "/103-sg-verify universal mutation-plan approval"
---

# Mutation Plan Approval

## Universal gate

Before any intentional state change, present a compact user-facing block headed exactly `🧭 PLAN À VALIDER` with:

- `Objectif`
- `Périmètre`
- `Actions`
- `Preuves`

Wait for explicit approval given after that plan, such as `validé`, `vas-y`, `applique ce plan`, or an equally unambiguous confirmation. The initial imperative request does not count as approval.

This gate applies to files, configuration, installation, package changes, generated persistent artifacts, processes, servers, deployments, publishing, messages, and other external writes. Read-only inspection and diagnostics may run before approval. Incidental caches produced by read-only diagnostics are not implementation.

No spec, tracker, plan file, branch, backup, or other persistent artifact may be created before approval merely to record the proposed work.

## Approval boundary

Approval covers only the displayed objective, scope, actions, and proof path. If execution discovers a material change to behavior, scope, risk, data, permissions, destructive effects, external state, or validation strategy, stop before that change, present a replacement plan, and obtain new explicit approval.

Routine implementation details inside the approved scope do not require repeated approval. Destructive, privileged, production, credential, billing, publication, and irreversible actions keep their stricter existing gates in addition to this one.

## Small changes

Micro-edits and direct-execution paths still require the same compact plan and explicit approval. They may use four single-line fields rather than a full spec. This gate changes authorization timing, not the proportionality of implementation or testing.

## Pressure scenarios

- An imperative request arrives with no prior plan: inspect as needed, propose the plan, do not mutate.
- The operator approves the displayed plan: execute its bounded mutations and proofs.
- A new material requirement appears during execution: stop and replace the plan before mutating that extension.
- A typo or one-line edit is requested: show the compact four-field plan and wait.
- Starting or stopping a server is requested: include the target project and expected process/port effect in the plan and wait.
