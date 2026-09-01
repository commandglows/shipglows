---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.17.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-09-01"
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
  - skills/708-sg-auto/SKILL.md
  - skills/references/no-local-execution-policy.md
  - skills/references/execution-posture-tags.md
  - skills/references/git-milestone-delivery-contract.md
depends_on:
  - artifact: "skills/references/strategic-choice-contract.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-01: ordinary Git/GitHub stewardship is permanently autonomous; no validation is requested for commit, push, safe reconciliation, or proven cleanup."
  - "Operator correction 2026-08-27: approval classification depends on request clarity, a few enumerable actions and targets, and directional discretion rather than local/remote location or model reasoning effort; explicit bounded file edits, commits, and ordinary pushes execute directly."
  - "Operator correction 2026-08-27: an explicit exact micro-modification request is itself authority for that mutation, but never for a chantier; ordinary exact-scope local commits never receive a separate approval prompt."
  - "Contract-suite repair 2026-08-23 aligns the authority name and focused tests with the approved milestone commit-and-push policy introduced on 2026-08-21."
  - "Operator decision 2026-08-13: every intentional mutation requires visible consent and explicit approval after the consent message; the original decision used the full-plan form, which the 2026-08-14 two-tier refinement makes proportional."
  - "Operator decision 2026-08-13: approval plans share the chantier opening identity, Paris time, visual section markers, and contextual numbered choices."
  - "Operator decision 2026-08-13: material plan choices express business direction, while short Questionner and Réorienter controls trigger guided follow-up."
  - "Operator decision 2026-08-14: exact local routine reversible mutations may use a one- or two-sentence fast validation; remote or risky mutations retain the full plan."
  - "Operator decision 2026-08-15: approval of a bounded technical chantier grants cumulative authority for its ordinary local commits, avoiding a second approval ceremony."
  - "Operator clarification 2026-08-15: directly mapped project documentation required to close approved technical work truthfully is part of that bounded authority."
  - "Operator decision 2026-08-15: standalone `v` is an explicit approval shortcut only for one unambiguous pending proposal; the 2026-08-16 correction preserves a narrowly framed mapping across non-material clarification."
  - "Operator correction 2026-08-16: non-material clarification and neutral acknowledgement must not cause repeated approval prompts; later explicit approval may authorize the still-current unchanged proposal."
  - "Operator correction 2026-08-17: a supplied public-link append to an exact internal reference register is already explicit authority when it is factual, local-only, and has no side effect beyond the new entries."
  - "Operator decision 2026-08-20: an explicit shipglows auto invocation grants one bounded current-project local edit session so useful reasoning-intensive work can continue without repeated approval, while nolocal alone grants no authority and every destructive, privileged, external, production, credential, permission, billing, commit, push, deploy, build, test, and installation effect remains forbidden."
  - "Operator decision 2026-08-20: the bounded auto authority includes useful delegated subagents, always inherits nolocal, and remains confined to the root captured when auto starts."
  - "Operator decision 2026-08-20: #local, #nolocal, and #ci alter execution posture only and never grant mutation or external-write authority."
  - "Operator decision 2026-08-21: every explicit validated milestone requires an exact-scope commit, and every clean chantier end requires its final commit and ordinary push."
  - "Operator clarification 2026-08-21: every validated milestone also requires an ordinary push so development work is remotely protected."
next_review: "2026-09-13"
next_step: "/103-sg-verify universal mutation-plan approval"
---

# Mutation Plan Approval

## Universal gate

Every intentional mutation requires authority. Clear bounded-request authority, Git/GitHub stewardship authority, supplied-link register authority, and Auto-session authority below are standing or request-derived authority paths. Every mutation outside those named paths requires one of the two approval paths below and explicit approval given after its message. Read-only inspection and diagnostics may run before approval.

## Git/GitHub stewardship authority

ShipGlows has standing authority to manage ordinary Git/GitHub state for in-scope work without asking for validation. At project or chantier start, each coherent validated milestone, and chantier end, refresh remote truth and converge safely: fetch/prune, inspect branch/upstream/PR/worktree relationships, stage only owned paths, create accurate commits, push them, reconcile merge-ready owned branches or pull requests into the canonical integration branch, and remove proven-integrated temporary branches and worktrees.

Resolve the target from `project-delivery-policy.md`: non-live `development` projects integrate directly into `main`; explicitly live `published` and `sensitive-production` projects integrate into canonical `dev`, while `main` remains production. Promotion `dev -> main` is a release/deployment transition: when its applicable release, CI, preview, security, and production-authority gates are satisfied, perform the Git reconciliation without a separate Git validation.

This standing authority includes safe local and remote branch creation, ordinary commits and pushes, fast-forward or policy-approved merge-ready reconciliation, pull-request lifecycle operations, pruning, and deletion of temporary local/remote branches or worktrees only after exact ownership and integration are mechanically proven. It never includes force push, history rewriting, bypassing protection or required checks, choosing a non-trivial conflict resolution, discarding unique commits, weakening controls, merging an unreviewed or failing change, deploying without deployment authority, or touching unrelated dirty work. Preserve and diagnose uncertain state instead of asking for a Git validation.

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

An explicit `shipglows auto` invocation is authority for one bounded autonomous
session of safe, reversible, current-project local file creation and editing.
This is a narrow first-message exception so the credit-window mode can continue
without a plan/approval round trip for every selected candidate. Quoted text,
discussion about the mode, any execution posture tag alone, an implicit inference, or an
invocation aimed at an unresolved project does not activate it.

At activation, freeze the current Git top-level when available, otherwise the
already resolved managed project root. This authority covers only project edits
and ignored auto-coordination claims below that root. Reading canonical
ShipGlows contracts or current official sources outside it does not authorize
outside-project edits. Switching repositories, cloning, creating or entering a
different worktree, or following a roadmap item into another project is outside
the authority.

The authority applies only while every selected candidate:

- is grounded in existing roadmap, planning, spec, backlog, architecture,
  code-risk, security, or compliance evidence;
- has resolved current-project ownership and no collision with unrelated dirty
  work;
- is limited to non-destructive, readily reviewable local file edits;
- loads and obeys `skills/references/no-local-execution-policy.md`;
- remains inside the supplied scope or current project and preserves governed
  product, architecture, data, and security decisions;
- records its result as `implemented — unverified` with deferred proof.

The same invocation authorizes bounded subagents dispatched by `708-sg-auto`
when their mission is independently useful and explicitly carries the frozen
root, mandatory nolocal policy, owned paths, forbidden paths, reasoning choice,
and stop conditions. It does not authorize agents created merely to consume
credits. Parallel writes still require ready non-overlapping Execution Batches;
cross-conversation claims make ownership visible but never widen it.

This authority never permits destructive or irreversible changes; deletion;
credential, secret, permission, auth-policy, billing, payment, production,
tenant, or private-data mutation; dependency installation or upgrade; builds,
tests, lint, typechecks, servers, browsers, containers, migrations, or runtime
workloads; commits, branches, worktrees, tags, pushes, pull requests, releases,
deployments, publication, messages, or any external write. It also never permits
the auto run to modify its own authority, no-local policy, agent permissions, or
equivalent safety guardrails.

When one candidate reaches an excluded boundary, skip it and continue another
safe candidate. Stop the whole session when the project is unresolved, no safe
candidate remains, the platform/horizon ends, or continuing would require a
material product/security/data decision absent from governed truth. Never widen
the authority merely to keep the session busy.

`#local`, `#nolocal`, and `#ci` remain subject to the ordinary approval path and
grant no mutation authority. The legacy `shipglows nolocal <objective>` alias
does the same. `shipglows auto #nolocal` and legacy `shipglows auto nolocal` are
redundant spellings of the same bounded Auto-session authority; no `#local` or
legacy `local` override exists. `#ci` never authorizes push, dispatch, remote
execution, deployment, or another external write.

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

## Cumulative milestone persistence authority

Approval of a bounded technical implementation plan that disclosed milestone remote persistence also authorizes its ordinary milestone commits and pushes by default. Apply `git-milestone-delivery-contract.md`: every explicit coherent validated milestone must be committed and pushed before the next milestone starts. The agent may stage, commit, and push silently, without a second approval message, when all of these conditions remain true:

- every staged path belongs to the already approved technical scope;
- unrelated and pre-existing changes remain unstaged;
- secret and sensitive-data checks pass before the commit;
- the commit is new on the current approved branch and the push targets only its resolved unambiguous upstream, with no amend, rebase, squash, reset, tag, force, hook bypass, merge, deployment, or unrelated remote effect;
- the commit records a coherent completed slice after proportional validation, and its subject describes that slice accurately.

The same bounded approval includes updates to directly mapped canonical project documentation required to keep the approved technical behavior truthful at closure. It does not include substantive editorial rewriting, new public claims, broad documentation migration, or unrelated documentation cleanup.

This authority may cover multiple small coherent commits and their ordinary pushes during the same approved chantier and requires both at declared milestones. A milestone is a completed slice, not a message or arbitrary edit. Report commit identifiers and push results at the next natural checkpoint or final handoff; do not interrupt merely to ask permission to protect approved work remotely.

The cumulative authority does not apply when the operator says `no commit`, when staging would include an unresolved or unrelated path, or when the work is primarily substantive editorial judgment or a broad mixed-scope consolidation. Those cases require explicit commit scope in the approval plan. An explicitly requested ordinary push may use clear bounded-request authority; an approved full technical chantier plan may also authorize its ordinary milestone and final current-branch pushes upfront with no duplicate approval. Force, history rewriting, tags, releases, deployments, merges, and unrelated remote effects remain outside that authority.

## Mandatory final delivery authority

A full technical chantier plan includes exact-scope milestone commits and pushes plus ordinary final delivery by default. The plan must expose every remote persistence effect before approval. At completion, commit any remaining owned diff, or reuse the latest owned milestone commit when nothing remains, then confirm the resolved current branch/upstream contains every owned commit. Never manufacture an empty final commit.

Push failure, ambiguous remote/branch, missing authentication, rejected updates, suspected secrets, unrelated staged paths, or failed required proof preserves local commits and leaves the chantier `delivery pending`; it never becomes clean closure. Explicit `no push` or `local only` also leaves delivery pending/local-only rather than standard closed. Read-only and non-Git work are not applicable.

## Small changes

Apply clear bounded-request authority first. A qualifying file edit, deterministic micro-bug fix, commit, ordinary push, or small explicit sequence executes directly from the operator's request without a validation prompt. A small-looking request that expands beyond enumerable actions or requires a material direction uses the full plan. Use fast validation for bounded agent-proposed actions or almost-clear intent, not as a duplicate confirmation of an already clear request.

## Pressure scenarios

- `MAP-GIT-STANDING-AUTHORITY`: ordinary Git/GitHub status refresh, commit, push, safe reconciliation, PR lifecycle, pruning, and proven-integrated cleanup proceed without a validation prompt.
- `MAP-GIT-NON-LIVE-MAIN`: a `development` non-live project uses `main` as canonical integration target and persists every coherent validated slice there.
- `MAP-GIT-LIVE-DEV`: a `published` or `sensitive-production` live project uses canonical `dev` for integration/staging while `main` remains production.
- `MAP-GIT-PROMOTION`: `dev -> main` requires applicable release/deployment authority and passing gates, but never a separate Git validation.
- `MAP-GIT-CONTINUAL-CONVERGENCE`: project/chantier start, every coherent milestone, and chantier end refresh and safely reconcile branch, upstream, PR, and worktree state.
- `MAP-GIT-UNCERTAIN-PRESERVE`: conflicts, unique commits, failing checks, ambiguous ownership/integration, protected-state uncertainty, or unrelated dirt are preserved and diagnosed without force or an approval ceremony.

- `MAP-TECHNICAL-COMMIT`: after approval of a bounded technical implementation, stage only its exact paths, run secret and proportional checks, create coherent local commits silently, and report their identifiers at the next natural checkpoint; do not ask for duplicate commit approval.
- `MAP-BOUNDED-REQUEST`: the operator clearly requests a targeted file edit, exact-scope commit, ordinary push, or small coherent sequence whose actions and targets are few and enumerable and require no material directional choice; the initial request is the authority, execute directly with focused proof and no validation prompt.
- `MAP-BOUNDED-EXPANSION`: a clear bounded request expands materially into an unbounded file/action set, multiple material paths, or substantial agent proposal; stop before the expansion and present the full plan.
- `MAP-EFFORT-INVARIANT`: classify the same request identically at `low`, `medium`, `high`, and `xhigh`; reasoning depth may change, but request clarity, enumerable actions and targets, and directional discretion are the only approval classifiers.
- `MAP-MILESTONE-COMMIT`: cross an explicit coherent validated milestone only after its exact owned diff is committed and pushed; messages, partial edits, failing experiments, and arbitrary time intervals are not milestones.
- `MAP-FINAL-DELIVERY`: a full approved technical chantier plan authorizes its ordinary final current-branch push; commit remaining owned changes or reuse the latest owned milestone commit, never create an empty commit, and keep closure delivery pending until push succeeds.
- `MAP-COMMIT-BOUNDARY`: unrelated paths, substantive editorial judgment, mixed-scope consolidation, amend, rebase, squash, reset, tag, hook bypass, closure, release preparation, and shipping are outside implicit commit authority and require the applicable explicit approval.
- `MAP-V-SHORTCUT`: standalone `v` or `V` approves the immediately preceding pending approval message with one unambiguous approval outcome; it does nothing before an approval message, and after clarification it can approve the still-current unchanged proposal only when the agent explicitly preserved the `v` mapping to that exact proposal.
- `MAP-PENDING-CLARIFICATION`: when the operator asks a non-material question about a pending unchanged proposal, answer the question and do not repeat the validation or plan; the proposal stays pending without a new prompt.
- `MAP-NEUTRAL-ACK`: `ok`, `compris`, `merci`, or `thanks` alone neither approve mutation nor trigger another approval prompt; retain the unchanged proposal silently.
- `MAP-LATER-APPROVAL`: after clarification or neutral acknowledgement, a later explicit and unambiguous action approval authorizes the still-current unchanged proposal without restating it; discussion or politeness does not.
- `MAP-PENDING-MATERIAL-CHANGE`: any change to scope, behavior, target, risk, data, permissions, destructive or external effects, or proof strategy invalidates the pending proposal and requires a replacement approval message before mutation.

- `MAP-LOCAL`: an imperative without a unique ready spec receives a `(local)` header, current Paris time, the four marked sections, and contextual choices; do not mutate.
- `MAP-SPEC`: a mutation owned by exactly one ready spec receives `(spec)` and its short title without exposing the spec path in the user-facing plan.
- `MAP-CONTEXTUAL-CHOICES`: a binary decision gets two useful choices; a genuine third outcome gets three. Do not append irrelevant pause, cancel, or reroute options merely to fill a template.
- `MAP-STRATEGIC-CHOICE`: material alternatives state distinct business outcomes, horizons, and trade-offs; technical execution variants remain agent-owned.
- `MAP-GUIDED-CONTROLS`: short `Questionner` and `Réorienter` labels are allowed, never approve mutation, and trigger useful guided questioning or concrete reorientation proposals on the next turn.
- `MAP-NUMBER-ONLY`: `1` authorizes mutation only when choice 1 is the plan's sole explicit approval action; any number mapped to questioning, adjustment, pause, cancellation, or an alternative does not.
- `MAP-REPLACEMENT`: a new material requirement stops execution and produces a fully replaced, newly timed plan. Approval given before that replacement does not approve it.
- `MAP-SMALL-CHANGE`: when a typo or one-line edit meets clear bounded-request authority, execute it from the operator's exact request without an approval prompt; when it expands materially or becomes a chantier, use the newly appropriate fast validation or full plan.
- `MAP-SERVER`: starting or stopping a server includes the target project and expected process/port effect before approval.
- `MAP-FAST-SWITCH`: switching to an exact existing local branch may use `🧭 VALIDATION RAPIDE` only after confirming the switch is routine, readily reversible, and cannot overwrite, discard, or relocate current changes.
- `MAP-FAST-WORKTREE`: creating an exact local branch and worktree from a resolved base may use `🧭 VALIDATION RAPIDE` only after confirming exact branch availability, exact path availability, and the resolved base, while guaranteeing the current worktree remains untouched.
- `MAP-FAST-INELIGIBLE`: if any fast criterion is missing, uncertain, or false, use the full `🧭 PLAN À VALIDER`; never infer eligibility from the action being technically simple.
- `MAP-FAST-REPLACEMENT`: if an approved fast action gains a material new target, effect, or risk, prior approval is invalid; stop and present the newly appropriate fast validation or full replacement plan.
- `MAP-BOUNDED-PUSH`: when the operator explicitly requests an ordinary push, the current branch and upstream are resolved, the commits are in scope, and no force or history rewrite is involved, execute directly; force push retains all stricter force/destructive gates.
- `MAP-SUPPLIED-LINK-REGISTER`: an operator says to add supplied public URLs to an exact internal inspirations or references register. Resolve the register once, append only factual candidate rows, and verify duplicates/row shape; do not request a second approval. Any inference, broader category choice, claim, duplicate, or unresolved target exits this exception and uses the normal gate.
