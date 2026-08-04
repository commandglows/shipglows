---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-04"
updated: "2026-08-04"
status: active
source_skill: 900-shipglows-core
scope: "intent-to-outcome-autonomy"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/000-shipglows/SKILL.md"
  - "skills/001-sg-build/SKILL.md"
  - "skills/002-sg-maintain/SKILL.md"
  - "skills/003-sg-bug/SKILL.md"
  - "skills/004-sg-deploy/SKILL.md"
  - "skills/006-sg-design/SKILL.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/008-sg-customer/SKILL.md"
  - "skills/009-sg-marketing/SKILL.md"
  - "skills/010-sg-technical/SKILL.md"
  - "skills/011-sg-pilotage/SKILL.md"
  - "skills/300-sg-docs/SKILL.md"
  - "skills/302-sg-help/SKILL.md"
  - "skills/406-sg-seo/SKILL.md"
depends_on:
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.9.0"
    required_status: active
  - artifact: "skills/references/operator-partnership-contract.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.6.0"
    required_status: active
  - artifact: "skills/references/master-delegation-semantics.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-04: public métier owners must clarify only material unknowns and then carry the work from intent to proven completion without lifecycle micromanagement."
next_review: "2026-09-04"
next_step: "none"
---

# Intent-to-Outcome Autonomy

## Purpose

This contract turns a public métier invocation into one continuous outcome-owned run. It composes the Question Contract, Operator Partnership Contract, Master Delegation Semantics, and Master Workflow Lifecycle; it does not replace their detailed safety or proof rules.

## Public Owner Contract

A public métier skill owns the observable operator outcome. Internal skills are engines, lifecycle gates, specialists, or proof owners. The public owner selects and invokes them itself, preserves the objective across handoffs, and continues after each successful stage. It must not return internal slash-command choreography for the operator to schedule.

Helper-only requests may end with an answer. When a helper resolves an actionable owner and the user asked for work, it transitions into that owner in the same conversation instead of merely telling the operator what to type.

## 1. Resolve

Before asking a question:

1. Derive the observable desired outcome from the latest active request.
2. Resolve the target as `project -> product -> surface -> feature` from conversation, repository context, product registries, specs, trackers, and current state.
3. Keep these dimensions distinct. One project may contain several products, and one product may expose several surfaces.
4. Load the métier playbook and only the specialist references relevant to the outcome.
5. Classify unknowns as discoverable evidence, safe agent decisions, or operator-owned decisions.

Missing paths, commands, files, packages, tests, internal skills, or implementation mechanics are not operator questions when the agent can discover or decide them safely.

## 2. Clarify Progressively

Ask only when an unresolved operator-owned decision would materially change product behavior, public promise, scope, security, privacy, permissions, cost, destructive behavior, external effects, or acceptance.

- Ask one numbered decision at a time.
- Explain the consequence briefly and recommend the strongest professional default when one exists.
- Re-evaluate after each answer; never front-load a generic questionnaire.
- Stop questioning as soon as a fresh capable agent could execute and prove the outcome safely.
- Treat sparse prompts as delegated intent when local evidence resolves the missing detail.

Secrets, new authority, paid actions, destructive operations, external communications, provider/account access, and device/manual-only proof remain operator-owned when unavailable to the agent.

## 3. Establish the Execution Contract

- Material, risky, cross-surface, or behavior-changing work uses a durable spec and readiness gate.
- Narrow, already-clear work uses a silent mini-contract.
- The contract records the user outcome, target context, scope, invariants, failure behavior, proof path, affected documentation, authority boundary, and stop conditions.
- Open material questions must be resolved before implementation unless a bounded evidence-gathering spike explicitly owns them.

## 4. Execute A to Z

The public owner continues through every applicable stage:

`discover -> specify/plan -> ready -> implement -> check -> test/prove -> verify -> update affected docs/content -> close -> ship/deploy when authorized`

- Invoke internal engines without asking the operator to select or schedule them.
- Continue automatically after a successful internal stage.
- Repair in-scope failures and rerun relevant proof before reporting a block.
- Preserve `project -> product -> surface -> feature`, the user story, authorization, and proof obligations across every handoff.
- Keep one public outcome owner for cross-métier work; collaborators remain internal.
- Treat commit, push, deploy, external communication, billing, production mutation, and destructive actions according to the authority actually granted. Autonomy never expands authority.

## 5. Return Conditions

Return control to the operator only when:

- the outcome is complete with proportional evidence;
- one genuine operator-owned decision is required;
- new authority, a secret, a paid/destructive/external action, or inaccessible manual-only proof is required; or
- a real block remains after safe in-scope diagnosis and alternatives are exhausted.

The final report leads with outcome, evidence, residual risk, and the one remaining operator action when applicable. Internal lifecycle commands may appear in expert/debug evidence, never as required operator micromanagement in the default report.

## Boundary Rules

- Internal architecture, governance, code-adjacent, metadata, context, and agent documentation belong to `sg-docs`.
- Public README, help-center material, tutorials, guides, FAQ, landing pages, blog, editorial repurposing, and audience email belong to `sg-content`.
- Organic-search outcomes belong to `sg-seo`; content and marketing collaborate internally.
- Database architecture, local-cloud sync, entitlements/access, provider events, and platform parity belong publicly to `sg-engineering`; specialized `600-602` skills remain internal engines.

## Pressure Scenarios

- `MH-01`: a sparse request with discoverable context proceeds without a question.
- `MH-02`: unresolved multi-product ambiguity asks only for the material product or surface choice, then resumes.
- `MH-03`: missing business truth produces one numbered decision with a recommendation.
- `MH-04`: missing implementation mechanics are agent-owned and do not trigger a question.
- `MH-05`: after readiness, the owner continues through implementation and proof without another operator command.
- `MH-06`: cross-métier work exposes one public owner and internal handoffs remain invisible.
- `MH-07`: public documentation routes to `sg-content`; internal documentation routes to `sg-docs`.
- `MH-08`: sync, access/entitlements, provider events, and parity route to `sg-engineering` and an internal engine.
- `MH-09`: material scope expansion pauses for one decision instead of silently widening authority.
- `MH-10`: default help shows the public corpus; expert help reveals internal engines.
- `MH-11`: every capability has one public owner or explicit internal-engine status.
- `MH-12`: no capability has two competing public owners.

## Stop Conditions

Stop rather than infer when the remaining unknown changes authorization, security, destructive effects, money, public promise, tenant/data boundaries, or an irreversible product decision. Stop rather than claim completion when required proof is absent or when an internal handoff lost the active outcome or target context.
