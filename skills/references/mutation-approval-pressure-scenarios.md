---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: mutation-approval-pressure-scenarios
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - "Verbatim conditional sections extracted from mutation-plan-approval 1.17.0."
next_review: "2026-10-05"
next_step: none
---

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
