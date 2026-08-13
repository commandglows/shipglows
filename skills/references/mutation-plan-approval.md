---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
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
  - skills/references/strategic-choice-contract.md
depends_on:
  - artifact: "skills/references/strategic-choice-contract.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-13: every intentional mutation requires a visible plan and explicit post-plan approval."
  - "Operator decision 2026-08-13: approval plans share the chantier opening identity, Paris time, visual section markers, and contextual numbered choices."
  - "Operator decision 2026-08-13: material plan choices express business direction, while short Questionner and Réorienter controls trigger guided follow-up."
next_review: "2026-09-13"
next_step: "/103-sg-verify universal mutation-plan approval"
---

# Mutation Plan Approval

## Universal gate

Before any intentional state change, present a compact user-facing block that opens exactly in this shape:

```text
🧭 PLAN À VALIDER (<local|spec>) : <short plan name>
🎯 VALIDATION (HH:mm) : en attente
```

Use `(spec)` only when exactly one ready spec owns the proposed mutation; otherwise use `(local)`. Render `HH:mm` in current Paris time when the plan is presented. Then include these four required sections in the operator's active language and with this visual hierarchy:

- `🎯 **Objectif**`
- `📂 **Périmètre**`
- `🔨 **Actions**`
- `✅ **Preuves**`

Before composing `📌 **Choix**`, load `skills/references/strategic-choice-contract.md`. End with two or three numbered choices adapted to the actual decision the operator can make now. Material alternatives express business directions and their consequences; routine low-impact approval remains proportional. Short `Questionner` or `Réorienter` labels are valid only because selecting them triggers the contract's active guided follow-up. The choices must not be a fixed menu copied into every context. Exactly one choice may grant approval; every other choice must clearly withhold approval or request a different outcome.

Wait for explicit approval given after that plan, such as `validé`, `vas-y`, `applique ce plan`, or an equally unambiguous confirmation. The initial imperative request does not count as approval.

A number-only reply is explicit approval only when it maps unambiguously to the single approval choice in the immediately preceding plan. A question, adjustment, alternative, pause, cancellation, or any number mapped to one of those outcomes never authorizes mutation.

This gate applies to files, configuration, installation, package changes, generated persistent artifacts, processes, servers, deployments, publishing, messages, and other external writes. Read-only inspection and diagnostics may run before approval. Incidental caches produced by read-only diagnostics are not implementation.

No spec, tracker, plan file, branch, backup, or other persistent artifact may be created before approval merely to record the proposed work.

## Approval boundary

Approval covers only the displayed objective, scope, actions, and proof path. If execution discovers a material change to behavior, scope, risk, data, permissions, destructive effects, external state, or validation strategy, stop before that change, present a replacement plan, and obtain new explicit approval.

Routine implementation details inside the approved scope do not require repeated approval. Destructive, privileged, production, credential, billing, publication, and irreversible actions keep their stricter existing gates in addition to this one.

## Small changes

Micro-edits and direct-execution paths still require the same compact plan and explicit approval. They may use four single-line fields rather than a full spec. This gate changes authorization timing, not the proportionality of implementation or testing.

## Pressure scenarios

- `MAP-LOCAL`: an imperative without a unique ready spec receives a `(local)` header, current Paris time, the four marked sections, and contextual choices; do not mutate.
- `MAP-SPEC`: a mutation owned by exactly one ready spec receives `(spec)` and its short title without exposing the spec path in the user-facing plan.
- `MAP-CONTEXTUAL-CHOICES`: a binary decision gets two useful choices; a genuine third outcome gets three. Do not append irrelevant pause, cancel, or reroute options merely to fill a template.
- `MAP-STRATEGIC-CHOICE`: material alternatives state distinct business outcomes, horizons, and trade-offs; technical execution variants remain agent-owned.
- `MAP-GUIDED-CONTROLS`: short `Questionner` and `Réorienter` labels are allowed, never approve mutation, and trigger useful guided questioning or concrete reorientation proposals on the next turn.
- `MAP-NUMBER-ONLY`: `1` authorizes mutation only when choice 1 is the plan's sole explicit approval action; any number mapped to questioning, adjustment, pause, cancellation, or an alternative does not.
- `MAP-REPLACEMENT`: a new material requirement stops execution and produces a fully replaced, newly timed plan. Approval given before that replacement does not approve it.
- `MAP-SMALL-CHANGE`: a typo or one-line edit still uses the compact visual contract and waits for approval.
- `MAP-SERVER`: starting or stopping a server includes the target project and expected process/port effect before approval.
