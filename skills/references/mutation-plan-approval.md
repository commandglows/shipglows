---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-15"
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
  - "Operator decision 2026-08-13: every intentional mutation requires visible consent and explicit approval after the consent message; the original decision used the full-plan form, which the 2026-08-14 two-tier refinement makes proportional."
  - "Operator decision 2026-08-13: approval plans share the chantier opening identity, Paris time, visual section markers, and contextual numbered choices."
  - "Operator decision 2026-08-13: material plan choices express business direction, while short Questionner and Réorienter controls trigger guided follow-up."
  - "Operator decision 2026-08-14: exact local routine reversible mutations may use a one- or two-sentence fast validation; remote or risky mutations retain the full plan."
  - "Operator decision 2026-08-15: approval of a bounded technical chantier grants cumulative authority for its ordinary local commits, avoiding a second approval ceremony."
  - "Operator clarification 2026-08-15: directly mapped project documentation required to close approved technical work truthfully is part of that bounded authority."
next_review: "2026-09-13"
next_step: "/103-sg-verify universal mutation-plan approval"
---

# Mutation Plan Approval

## Universal gate

Every intentional mutation requires one of the two approval paths below and explicit approval given after its message. Read-only inspection and diagnostics may run before approval. The initial imperative request does not count as approval for either path; this rule applies to both approval paths.

First evaluate the fast path. Use it only when every criterion below is established. If one criterion is missing, uncertain, or false, use the full plan.

## Fast validation

Use `🧭 VALIDATION RAPIDE` only when the mutation is:

- explicitly requested and unambiguous;
- aimed at a target that is exact and resolved;
- local-only;
- routine;
- readily reversible;
- guaranteed not to overwrite, discard, delete, force, publish, deploy, message another person or system, change a credential or permission, or affect unrelated changes.

Present `🧭 VALIDATION RAPIDE` in one or two sentences. State the exact action, exact target, and main safety guarantee, then ask for an explicit confirmation. Do not add the four full-plan sections or strategic-choice overhead.

Example:

```text
🧭 VALIDATION RAPIDE — Je crée le worktree `C:\worktrees\review` sur la branche `codex/review`, depuis `main`, sans toucher aux changements courants. Réponds « go ».
```

Wait for explicit approval given after this fast validation. The initial imperative request does not count as approval.

## Full plan

For every mutation that is not fast-eligible, present a compact user-facing block that opens exactly in this shape:

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

This full-plan path applies to ambiguous or unresolved mutations and to files, configuration, installation, package changes, generated persistent artifacts, processes, servers, deployments, publishing, messages, and other external writes unless every fast-path criterion is established. `git push` always requires the full plan because it changes remote state and may trigger CI, deployments, or notifications. Force push retains every stricter gate in addition to the full plan. Incidental caches produced by read-only diagnostics are not implementation.

No spec, tracker, plan file, branch, backup, or other persistent artifact may be created before approval merely to record the proposed work.

## Approval boundary

Approval covers only the displayed fast action/target/safety guarantee or full objective/scope/actions/proof path. If execution discovers a material change to behavior, scope, target, risk, data, permissions, destructive effects, external state, or validation strategy, stop before that change, present the newly appropriate fast validation or replacement full plan, and obtain new explicit approval.

Routine implementation details inside the approved scope do not require repeated approval. Destructive, privileged, production, credential, billing, publication, and irreversible actions keep their stricter existing gates in addition to this one.

## Cumulative local commit authority

Approval of a bounded technical implementation plan also authorizes its ordinary local commits by default. The agent may stage and commit silently, without a second approval message, when all of these conditions remain true:

- every staged path belongs to the already approved technical scope;
- unrelated and pre-existing changes remain unstaged;
- secret and sensitive-data checks pass before the commit;
- the commit is a new local commit on the current approved branch, with no amend, rebase, squash, reset, tag, push, force, hook bypass, or remote effect;
- the commit records a coherent completed slice after proportional validation, and its subject describes that slice accurately.

The same bounded approval includes updates to directly mapped canonical project documentation required to keep the approved technical behavior truthful at closure. It does not include substantive editorial rewriting, new public claims, broad documentation migration, or unrelated documentation cleanup.

This authority may cover multiple small coherent commits during the same approved chantier. Report their commit identifiers at the next natural checkpoint or final handoff; do not interrupt merely to ask permission to record work the operator already approved.

The cumulative authority does not apply when the operator says `no commit`, when staging would include an unresolved or unrelated path, or when the work is primarily substantive editorial judgment, a broad mixed-scope consolidation, closure, release preparation, or shipping. Those cases must have commit inclusion stated explicitly in the applicable approval plan. `git push` always remains a separate full-plan action.

## Small changes

Micro-edits and direct-execution paths still require explicit post-message approval. They use fast validation only when every eligibility criterion is established; otherwise they use the full plan. This gate changes approval ceremony, not authority or the proportionality of implementation and testing.

## Pressure scenarios

- `MAP-TECHNICAL-COMMIT`: after approval of a bounded technical implementation, stage only its exact paths, run secret and proportional checks, create coherent local commits silently, and report their identifiers at the next natural checkpoint; do not ask for duplicate commit approval.
- `MAP-COMMIT-BOUNDARY`: unrelated paths, substantive editorial judgment, mixed-scope consolidation, amend, rebase, squash, reset, tag, hook bypass, closure, release preparation, and shipping are outside implicit commit authority and require the applicable explicit approval.

- `MAP-LOCAL`: an imperative without a unique ready spec receives a `(local)` header, current Paris time, the four marked sections, and contextual choices; do not mutate.
- `MAP-SPEC`: a mutation owned by exactly one ready spec receives `(spec)` and its short title without exposing the spec path in the user-facing plan.
- `MAP-CONTEXTUAL-CHOICES`: a binary decision gets two useful choices; a genuine third outcome gets three. Do not append irrelevant pause, cancel, or reroute options merely to fill a template.
- `MAP-STRATEGIC-CHOICE`: material alternatives state distinct business outcomes, horizons, and trade-offs; technical execution variants remain agent-owned.
- `MAP-GUIDED-CONTROLS`: short `Questionner` and `Réorienter` labels are allowed, never approve mutation, and trigger useful guided questioning or concrete reorientation proposals on the next turn.
- `MAP-NUMBER-ONLY`: `1` authorizes mutation only when choice 1 is the plan's sole explicit approval action; any number mapped to questioning, adjustment, pause, cancellation, or an alternative does not.
- `MAP-REPLACEMENT`: a new material requirement stops execution and produces a fully replaced, newly timed plan. Approval given before that replacement does not approve it.
- `MAP-SMALL-CHANGE`: a typo or one-line edit uses `🧭 VALIDATION RAPIDE` only when every fast-path criterion is established; otherwise it uses the full `🧭 PLAN À VALIDER`. Both paths wait for explicit approval after the message.
- `MAP-SERVER`: starting or stopping a server includes the target project and expected process/port effect before approval.
- `MAP-FAST-SWITCH`: switching to an exact existing local branch may use `🧭 VALIDATION RAPIDE` only after confirming the switch is routine, readily reversible, and cannot overwrite, discard, or relocate current changes.
- `MAP-FAST-WORKTREE`: creating an exact local branch and worktree from a resolved base may use `🧭 VALIDATION RAPIDE` only after confirming exact branch availability, exact path availability, and the resolved base, while guaranteeing the current worktree remains untouched.
- `MAP-FAST-INELIGIBLE`: if any fast criterion is missing, uncertain, or false, use the full `🧭 PLAN À VALIDER`; never infer eligibility from the action being technically simple.
- `MAP-FAST-REPLACEMENT`: if an approved fast action gains a material new target, effect, or risk, prior approval is invalid; stop and present the newly appropriate fast validation or full replacement plan.
- `MAP-REMOTE-PUSH`: every `git push` uses the full `🧭 PLAN À VALIDER`; force push also retains all stricter force/destructive gates.
