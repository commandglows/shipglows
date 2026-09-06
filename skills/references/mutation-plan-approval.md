---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.18.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: universal-mutation-plan-approval
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: []
depends_on:
  - artifact: "skills/references/strategic-choice-contract.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "2026-09-05: conditional Auto, Git and pressure-scenario sections extracted without changing authority. Historical decisions remain in Git history."
next_review: "2026-09-13"
next_step: "/103-sg-verify universal mutation-plan approval"
---

# Mutation Plan Approval

## Universal gate

Every intentional mutation requires authority. Clear bounded-request authority, Git/GitHub stewardship authority, supplied-link register authority, and Auto-session authority below are standing or request-derived authority paths. Every mutation outside those named paths requires one of the two approval paths below and explicit approval given after its message. Read-only inspection and diagnostics may run before approval.

## Git/GitHub stewardship authority

Ordinary in-scope Git/GitHub stewardship has standing authority; no duplicate validation is needed. Before Git stewardship, drafting a technical plan that discloses Git persistence, milestone persistence or final Git delivery, load `mutation-git-authority.md`. Before selecting or promising an integration destination (including in a plan), load `project-delivery-policy.md`; before executing an approved milestone or final delivery, load `git-milestone-delivery-contract.md`. It preserves ownership, integration proof, required checks and production gates. Never infer force, history rewrite, non-trivial conflict resolution, unrelated-dirt disposal or deployment authority. Auto/nolocal prohibitions still apply.

## Clear bounded-request authority

The operator's initial imperative is authority when read-only resolution establishes every condition below. Execute the requested action or small action sequence without another approval message:

- the requested outcome is clear and unambiguous;
- the required actions and targets are few, coherent, and enumerable before execution;
- resolving implementation details does not require the agent to invent, propose, or select a material product, architecture, data, security, editorial, or operational direction;
- the action remains proportionate to the request, protects unrelated changes, and has focused proof.

Typical qualifying requests include a targeted file modification, a deterministic micro-bug fix, an ordinary exact-scope commit, an ordinary push to the resolved current upstream, or a small explicit sequence of these. Local versus remote is not an approval classifier. Classification depends on request clarity, enumerable action and target count, and directional discretion.

This authority covers only the clear bounded request. It does not create or approve a chantier, infer adjacent cleanup, or authorize materially independent work. A clear bounded request never authorizes a chantier. If inspection or execution reveals an unbounded file/action set, multiple material directions, or a need for substantial agent proposal and operator choice, stop before that expansion and present the full plan.

An ordinary exact-scope commit records authorized work and never requires a separate approval prompt. Stage only the authorized paths, keep unrelated and pre-existing changes unstaged, and run proportional checks. When the operator explicitly requests an ordinary push, the branch and upstream are resolved, and no history rewrite or materially different effect is involved, push directly under the same authority. Amend, rebase, squash, reset, tag, force, hook bypass, merge, deployment, destructive or irreversible changes, credential or permission changes, and unrelated effects retain their dedicated safety boundaries; they are not classified as chantiers merely because they affect remote state.

Classification is invariant across reasoning-effort settings. The same request must receive the same authority classification at `low`, `medium`, `high`, and `xhigh`: use request clarity, enumerable action and target count, and directional discretion, never the selected reasoning effort. A higher effort may deepen internal analysis but cannot manufacture a validation ceremony.

## Auto-session authority

An explicit `shipglows auto` invocation alone selects this authority. Before any Auto candidate or write, load `mutation-auto-authority.md` and `no-local-execution-policy.md`. It permits only bounded reversible edits under the frozen current-project root, with deferred proof. It never permits Git or external writes, execution workloads, installation, sensitive-data/security changes, deletion, or changing its own guardrails. Posture tags alone grant no mutation authority.

## Supplied-link register authority

Do not ask for a second confirmation when the operator explicitly asks to append supplied public links to one exact existing internal reference register and every condition is established:

- the exact register is resolved with one focused lookup;
- each new row is limited to the supplied name or URL, the category requested by the operator, `candidate` status, the current date, and a neutral use note;
- the update is append-only, local-only, readily reversible, and cannot overwrite, discard, delete, publish, deploy, message, change credentials or permissions, or affect unrelated entries;
- no market analysis, competitor claim, product claim, pricing, inferred capability, source-derived copy, metadata rewrite, or other editorial judgment is added.

This authority is only for the supplied links and their minimal factual rows. If a duplicate, ambiguity, missing target, broader classification, research, or any other material judgment appears, stop and use the normal approval path.

First evaluate the direct-authority exceptions above. Only when none applies, evaluate the fast path. Use it for an agent-proposed bounded action or an almost-clear operator intent when every criterion below is established; if one criterion is missing, uncertain, or false, use the full plan.

## Fast validation

Use `🧭 VALIDATION RAPIDE` only when the mutation is:

- clear, bounded, and unambiguous after stating the proposed action;
- aimed at a target that is exact and resolved;
- limited to actions and targets that are few and enumerable;
- free of any material direction the agent must choose for the operator;
- guaranteed not to overwrite, discard, delete, force, publish, deploy, message another person or system, change a credential or permission, or affect unrelated changes.

Present `🧭 VALIDATION RAPIDE` in one or two sentences. State the exact action, exact target, and main safety guarantee, then ask for an explicit confirmation. Do not add the four full-plan sections or strategic-choice overhead.

Example:

```text
🧭 VALIDATION RAPIDE — Je crée le worktree `C:\worktrees\review` sur la branche `codex/review`, depuis `main`, sans toucher aux changements courants. Réponds « go ».
```

Wait for explicit approval given after this fast validation. Reaching this path means clear bounded-request authority did not apply because the action was agent-proposed or the operator intent required compact confirmation.

A reply consisting only of `v` (case-insensitive, ignoring surrounding whitespace) is explicit approval when it directly answers this immediately preceding pending fast validation. After a non-material clarification, the bounded continuation rule below controls whether `v` still maps safely to the unchanged proposal.

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

Wait for explicit approval given after that plan, such as `validé`, `vas-y`, `applique ce plan`, or an equally unambiguous confirmation. The initial imperative request does not count as approval for a chantier or for another action outside its clear bounded-request authority.

A reply consisting only of `v` (case-insensitive, ignoring surrounding whitespace) is explicit approval when it directly answers the immediately preceding pending plan and that plan has exactly one approval outcome. It never authorizes a replaced, ambiguous, paused, materially changed, or cancelled proposal.

A number-only reply is explicit approval only when it maps unambiguously to the single approval choice in the immediately preceding plan. A question, adjustment, alternative, pause, cancellation, or any number mapped to one of those outcomes never authorizes mutation.

This full-plan path applies when the desired outcome or direction remains unknown, the actions or targets cannot be bounded and enumerated, multiple materially different paths require operator choice, or the agent must substantially analyze, propose, and select a direction. Configuration, installation, package changes, generated artifacts, processes, servers, deployments, publishing, messages, and other external writes use the same classifier; their separate safety policies still apply. An explicitly requested ordinary `git push` to a resolved upstream may use clear bounded-request authority. Force push retains every stricter gate because it rewrites history, not because it is remote. Incidental caches produced by read-only diagnostics are not implementation.

No spec, tracker, plan file, branch, backup, or other persistent artifact may be created before approval merely to record the proposed work.

## Pending approval across conversation turns

A displayed fast validation or full plan remains the current pending proposal until it is approved, cancelled, replaced, paused, or materially changed. Classify each intervening operator message by intent before deciding whether the proposal is still current:

- For a non-material clarification about the same proposal, answer it without reissuing or restating the unchanged approval message. State only when useful that the same proposal remains pending; do not append another approval request.
- Neutral acknowledgements such as `ok`, `compris`, `merci`, or `thanks` neither authorize mutation nor trigger another approval prompt. Acknowledge briefly if useful and leave the same proposal pending silently.
- A later explicit and unambiguous action approval such as `vas-y`, `applique ce plan`, or `continue avec cette proposition` may authorize the still-current unchanged proposal without restating it. Politeness, understanding, discussion, or topic continuation is not action approval.
- Standalone `v` keeps its immediate-answer meaning by default. After a non-material clarification, it may approve the still-current unchanged proposal only when the agent's intervening answer explicitly preserved the `v` mapping to that exact proposal; merely saying that a proposal is pending is insufficient. This bounded exception does not require reissuing the validation or plan.
- Any material change to scope, behavior, target, risk, data, permissions, destructive or external effects, or proof strategy invalidates the pending proposal. Present a newly appropriate fast validation or replacement full plan before mutation.

## Approval boundary

Authority covers only the clear bounded actions and targets contained in the request, the displayed fast action/target/safety guarantee, or the full objective/scope/actions/proof path. If execution discovers a material expansion, unbounded target set, new directional choice, or change to behavior, risk, data, permissions, destructive effects, external state, or validation strategy, stop before that change, present the newly appropriate fast validation or replacement full plan, and obtain new explicit approval.

Routine implementation details inside the approved scope do not require repeated approval. Destructive, privileged, production, credential, billing, publication, and irreversible actions keep their stricter existing gates in addition to this one.

## Small changes

Apply clear bounded-request authority first. A qualifying file edit, deterministic micro-bug fix, commit, ordinary push, or small explicit sequence executes directly from the operator's request without a validation prompt. A small-looking request that expands beyond enumerable actions or requires a material direction uses the full plan. Use fast validation for bounded agent-proposed actions or almost-clear intent, not as a duplicate confirmation of an already clear request.

## Pressure scenarios

Load `mutation-approval-pressure-scenarios.md` only for maintenance, audit or testing of this authority. It is cold evidence, never an additional source of permission.
