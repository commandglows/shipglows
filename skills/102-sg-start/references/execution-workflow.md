---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipflow"
created: "2026-05-16"
updated: "2026-06-10"
status: draft
source_skill: 102-sg-start
scope: "102-sg-start-workflow"
owner: "unknown"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/102-sg-start/SKILL.md"
  - "skills/references/canonical-paths.md"
  - "skills/references/chantier-tracking.md"
  - "skills/references/reporting-contract.md"
  - "skills/references/task-application-loop.md"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Extracted during compact-shipflow-skill-instructions-phase-4 to preserve lifecycle workflow detail outside the activation body."
  - "Added bounded local auto-verify follow-through for 102-sg-start while preserving proof-owner routing."
next_step: "none"
---

# Execution Workflow

This reference preserves the detailed lifecycle workflow for `102-sg-start`. Load it after the compact `SKILL.md` activation contract when this skill is invoked.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git branch: !`git branch --show-current 2>/dev/null || echo "unknown"`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipGlowz development mode: !`rg -n "ShipGlowz Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPFLOW.md 2>/dev/null || echo "No project development mode documented"`
- Project-local TASKS.md: !`cat shipglowz_data/workflow/TASKS.md 2>/dev/null || cat TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Available specs: !`find shipglowz_data/workflow/specs docs specs -maxdepth 2 -type f -name "*.md" 2>/dev/null | sort | head -40`

## Your task

`102-sg-start` is an execution skill. It should implement, not only plan.

Goal: execute from an explicit contract in one pass, not rediscover intent while coding.

The contract starts from the user story. Implementation must preserve the promised user outcome, not only complete technical tasks.

Routing rule:
- **Small/local/clear** task: execute directly
- **Non-trivial or ambiguous** task: require a ready spec before implementation

### Step 1 — Identify the task

If `$ARGUMENTS` is provided, use it as the task description.

If `$ARGUMENTS` is empty, look at TASKS.md from context and use **AskUserQuestion**:
- Question: "Quelle tâche veux-tu commencer ?"
- `multiSelect: false`
- Options: top 5-7 uncompleted tasks from TASKS.md (highest priority first), each with its priority emoji as prefix
- Add a final option: "Autre — je décris ma tâche"

### Step 2 — Scope triage

Classify as `direct` or `spec-first`.

Signals for `spec-first`:
- multiple files or subsystems
- unclear expected behavior
- auth/data/migration/API contract implications
- likely edge cases or cross-domain impact

If the task includes a known auth bug or a browser flow that is failing in reality:
- keep `102-sg-start` as the execution owner
- pull in `109-sg-auth-debug` logic before patching when browser evidence is needed to avoid coding blind
- do not assume static code reading is enough for Clerk/OAuth/session issues

If the task needs browser evidence but does not touch auth, sessions, callbacks, tenants, protected routes, or provider behavior, route non-auth browser proof through `108-sg-browser` instead of `109-sg-auth-debug`.

If any unresolved question could change permissions, data exposure, tenant boundaries, money movement, destructive behavior, external side effects, or workflow integrity, force `spec-first`.

If the triage is borderline (signals are mixed), use **AskUserQuestion**:
- Question: "Le scope est ambigu. Quelle stratégie ?"
- `multiSelect: false`
- Options:
  - **Exécuter directement (recommandé si local)** — "Tu avances maintenant avec scope limité"
  - **Passer par spec-first** — "Tu formalises avant d'implémenter"
  - **Clarifier d'abord** — "Tu fais un court détour d'exploration avant de coder"

If user picks **Clarifier d'abord**, route to `/700-sg-explore [task]` and stop execution.

If `spec-first` and no matching `Status: ready` spec exists:
- stop execution
- route to:
  1. `/100-sg-spec [task]`
  2. `/101-sg-ready [task/spec]`
  3. `/102-sg-start [task]`

### Step 3 — Load context, derive execution contract, and track task (silent)

- Read `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/documentation-freshness-gate.md` when the task depends on framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior. Preserve the gate verdict in the execution contract.
- Read `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/project-development-mode.md`, then inspect the project-local `## ShipGlowz Development Mode` section in `CLAUDE.md` or `SHIPFLOW.md`.
  - Add the development mode to the execution contract: `local`, `vercel-preview-push`, `hybrid`, or `unknown`.
  - If the section is missing and Vercel signals exist (`.vercel/project.json`, `vercel.json`, Vercel dependency, or Vercel deployment status), classify as `unknown-vercel` and do not run preview-dependent browser/manual validation until the mode is clarified or documented.
  - If the user explicitly says this project uses Vercel previews as the development/test surface, treat the current run as `vercel-preview-push` and update or request the project section before the next validation step.
  - If no hosting signal exists, default to `local` for this run and recommend adding the section during project setup.
- If Supabase is in the stack and the task touches auth, storage, uploads, DB, or RLS, load only the relevant references among `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/supabase-auth.md`, `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/supabase-storage.md`, `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/supabase-db.md` before editing.
- If the task touches runtime error handling, crash reporting, error boundaries, jobs, webhooks, auth/payment/data failures, diagnostics/log-copy UI, or a deployed bug with a Sentry/support event ID, load `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/sentry-observability.md` and preserve Sentry plus diagnostics/build-header expectations in the execution contract.
- Si la tâche est `spec-first`, préférer une exécution sur contexte frais :
  - lancer un subagent sans historique si c'est possible
  - sinon demander explicitement à l'utilisateur d'ouvrir un nouveau thread avant de continuer
- If a `ready` spec exists, read it fully before touching code
- If the task changes behavior, fixes a bug, changes a skill contract, or needs evidence before completion, read `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/spec-driven-development-discipline.md` and choose a proof path before editing:
  - `test-first` for behavior with a reasonable automated test surface
  - `regression-first` for bugs
  - `scenario-first` for skill, prompt, routing, or governance contract changes
  - `evidence-first` for UI, docs, auth, deployment, operational, visual, content, or integration work
  - `exception-with-proof` when the strongest path is impractical; record why and name the alternate evidence
- Choose validation proportionality before check selection:
  - `bounded`: small-risk, scoped edits with a tight evidence requirement
  - `full`: cross-surface, auth/data, release-risky, or high-impact behavior changes
  - if uncertainty remains after task analysis, use `bounded` by default and escalate explicitly in the execution contract
- Derive an execution contract:
  - spec metadata: `metadata_schema_version`, `artifact_version`, `status`, `updated`
  - minimal behavior contract: what the feature accepts/triggers, what it produces/returns, what happens on failure, and the easiest edge case to miss
  - success behavior: observable success result, expected system effect, and proof to validate
  - error behavior: expected response for invalid input, missing permissions/resources, partial failure, retry/rollback/timeout, and forbidden bad states
  - dependency/version context from `depends_on`
  - user story and promised outcome
  - target files
  - read-first files / entry points
  - invariants and non-goals
  - linked systems / consequences to revalidate
  - Sentry observability, safe diagnostics/log-copy, and commit/build + Paris/UTC build-time header expectations when runtime evidence or instrumentation is relevant
  - documentation surfaces to update or explicitly leave unchanged
  - chosen proof path, exception reason if any, and validation/evidence expected before completion
  - task application loop state: target work item, required context files, active slice, progress semantics, durable progress target, and proof route
  - checklist strategy: when manual proof remains, include `shipglowz_data/workflow/test-checklists/<scope>.md` and required scenario IDs
  - project development mode and validation surface: whether success must be proven locally or through `005-sg-ship` -> `405-sg-prod` on a Vercel preview
  - for Flutter mobile/UI work: the proof ladder expected before APK/device testing, starting with widget tests when practical, then agent-run Flutter Web smoke for shared UI behavior via `108-sg-browser` or `109-sg-auth-debug`, then APK/device proof only for native-only behavior
  - fresh external docs verdict when the task depends on external documented behavior: dependency/service, local version when available, Context7 or official docs source, and whether the implementation path is supported
  - abuse cases / misuse cases and security constraints when present
- validation commands and stop conditions
- auto-verify eligibility: whether `102-sg-start` may run local verification itself, the exact `auto-verify: run` or `auto-verify: skipped` report value, and any out-of-scope proof owner route
- For every business or technical contract listed in `depends_on` (`shipglowz_data/business/business.md`, `shipglowz_data/branding/branding.md`, `shipglowz_data/business/product.md`, `shipglowz_data/business/gtm.md`, `shipglowz_data/technical/architecture.md`, `shipglowz_data/technical/guidelines.md`, docs API, pricing, personas, onboarding/support docs):
  - preserve the referenced `artifact_version` and `required_status` in the execution context
  - read the current file when it is present and its version/status may affect the implementation
  - stop and route back to `/101-sg-ready` if the current document is `stale`, has a newer incompatible `artifact_version`, or contradicts the spec
  - ask the user or reroute if a missing version would change product promise, permissions, pricing, data behavior, API contract, architecture, security posture, or documentation obligations
- If a direct task has no spec but clearly depends on business or technical docs, record a mini-contract with the document names and current versions/status when available.
- If a direct task has no spec but triggers the Documentation Freshness Gate, record the dependency/version, Context7 or official docs source, relevant rule, and verdict before editing.
- If a direct task has no spec, still form a lightweight mini-contract before editing:
  - one behavioral paragraph: accepted input/trigger, output/result, failure behavior, likely missed edge case
  - success behavior: what must be observable when the change works
  - error behavior: what must happen when expected failure modes occur
  - one short adversarial pass: what is missing, what assumption could break, what edge case is not covered
  - one implementation plan: files/areas to touch and validation to run
  - explicit constraints: packages to use or avoid, existing patterns to follow, data flow, abstractions to avoid, scope limits
  - keep this silent unless it reveals ambiguity that changes product behavior, security, data handling, destructive behavior, or external side effects
- If a `ready` spec exists, also identify the likely execution topology:
  - implementation groups
  - files owned by each group
  - shared files that must stay with the main agent
  - groups that can run in parallel vs groups that must wait
- Read `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/decision-quality-contract.md` before selecting direct mode, model, topology, implementation path, or fallback
- Read `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/704-sg-model/references/model-routing.md` before choosing execution model(s)
- If the spec is missing any of the above, stop and route back to `/101-sg-ready` or `/100-sg-spec`
- If a non-trivial spec lacks `Minimal Behavior Contract`, `Success Behavior`, `Error Behavior`, implementation approach, adversarial gaps, or explicit constraints, stop and route back to `/101-sg-ready` or `/100-sg-spec`
- If the spec is missing required metadata/version context, treat it as a contract gap. Continue only for trivial/local work where the missing metadata cannot change product or security semantics; otherwise route back to `/101-sg-ready`.
- If the spec names root legacy governance files such as `BUSINESS.md`, `CONTEXT.md`, or `GUIDELINES.md`, treat them as legacy references and add a layout migration note. Do not create new root governance files.
- If the implementation path would satisfy the listed tasks but miss the user story outcome, stop and reroute instead of coding the wrong thing efficiently
- If the implementation path is merely the fastest/easiest patch and would weaken correctness, security, performance, maintainability, durability, excellence, or proof quality, stop and choose the bounded professional path instead
- If the remaining ambiguity is product-meaningful or security-meaningful, ask the user instead of "picking a sensible default"
- Read only the files needed to implement plus the linked systems that must be sanity-checked
- Include associated tests or entry points
- If the task touches auth, redirects, protected pages, callback flows, or browser session state, include the relevant login/callback entrypoints and the minimum routes needed for `109-sg-auth-debug`
- If the task touches non-auth browser behavior, visual state, console errors, network failures, or page-level assertions, include the minimum routes and validation objective needed for `108-sg-browser`
- If the task touches Flutter UI that can run on Web, include agent-run Flutter Web smoke scenarios before APK testing; use `108-sg-browser` for non-auth UI objectives and `109-sg-auth-debug` for auth/session/callback/protected-route objectives. Reserve APK/device proof for IME, permissions, overlays, native plugins, platform channels, notifications, storage, install/update, or real-device performance
- If the task touches Supabase, include the matching schema/policy/migration files, storage path conventions, and the exact client split (`browser`, `server`, `service-role`) in the read-first set
- Update task tracking to `🔄 in progress` in legacy master TASKS.md when explicit coordination mode is enabled.
- Update local TASKS.md too when present
- Before creating or mutating task operational records, load `$SHIPFLOW_ROOT/skills/references/operational-record-format.md` and follow its traffic-first writer obligations.
- Treat the TASKS content loaded in Context as informational only.
- Immediately before editing either TASKS file, re-read it from disk and use that version as authoritative.
- Apply a minimal targeted edit (status row / task line only), never a whole-file rewrite from stale context.
- If the expected row or section moved, re-read once and recompute; if it is still ambiguous, stop and ask the user.

### Step 4 — Model routing

Choose the execution model before coding.

Use `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/704-sg-model/references/model-routing.md` as the shared provider-aware source of truth, bounded by `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/decision-quality-contract.md`.

Pick:
- `Runtime/provider` (`Codex/OpenAI` or `Claude Code`)
- `Primary execution model`
- `Reasoning effort` for Codex/OpenAI, or Claude Code alias behavior
- optional `Per-group model overrides`

Prefer simple Codex/OpenAI defaults:
- `gpt-5.4-mini` for small, clear, local, low-risk work where it remains quality-equivalent
- the `codex` implementation profile from `704-sg-model` for long agentic implementation, multi-file coding, refactors, hard debugging, and terminal-heavy execution; do not pin this profile to a deprecated slug
- `gpt-5.5` for ambiguity, architecture, cross-project governance, transverse audits, task prioritization, prompt/docs migrations, business-risk synthesis, and high error cost, with `low`, `medium`, `high`, or `xhigh` reasoning calibrated to the task
- `gpt-5.4` for bounded premium architecture or tradeoffs where `gpt-5.5` is likely overkill
- `gpt-5.3-codex-spark` for Spark-eligible summaries, text-only handoffs, micro-code, highly local fast-iteration work, and UI-focused deltas when it does not replace necessary reasoning and credits/availability permit
- `gpt-5.4-mini` as the default for small bounded subagent missions only when the mission risk is low enough for the quality bar

Treat `spark`, `codex`, `sous-agent`/`subagent`/`agents`, and `mini` arguments as delegated subagent requests using the model-topology alias rules from `704-sg-model/references/model-routing.md`.

Prefer simple Claude Code defaults:
- `haiku` for tiny triage, classification, and quality-equivalent side work
- `sonnet` for daily coding, debugging, and balanced implementation
- `opusplan` for plan-heavy tasks that should execute efficiently after planning
- `opus` for high-risk reasoning, architecture, security, or adversarial review
- `sonnet[1m]` only when extended context is the main constraint

Only use per-group overrides when:
- the task is materially non-trivial
- groups have clearly different profiles
- the gain in speed, cost, or reliability is obvious and the lower-cost route remains quality-equivalent

If the task is simple, keep one model and continue.

### Step 5 — Choose execution topology

Decide whether to run in `single-agent` or `multi-agent`.

Prefer `single-agent` when:
- the task is small or medium
- most changes converge on the same 1-3 files
- the work is tightly coupled and sequencing matters more than parallelism
- the integration overhead would outweigh the gain

Prefer `multi-agent` when:
- the spec is `ready` and materially non-trivial
- there are multiple implementation groups with mostly disjoint write sets
- backend, frontend, tests, docs, ops, or migrations can be separated cleanly
- the main agent can keep ownership of integration and final validation

Guardrails for `multi-agent`:
- create at most 2-4 groups
- each group must have explicit file ownership
- do not assign the same writable file to multiple subagents
- keep cross-cutting files, final wiring, and conflict resolution with the main agent
- if boundaries are fuzzy, fall back to `single-agent`

If `multi-agent` is chosen:
- define each group with:
  - goal
  - owned files
  - model
  - reasoning effort
  - fast or cheap fallback
  - whether the model override is applied by the runtime or only recommended
  - read-only context files
  - validations to run
  - dependency order if not parallel-safe
- launch subagents only for groups that materially advance the task without overlapping writes
- keep working locally on integration-critical or shared-file work while subagents run
- integrate returned changes, then run focused validation across the combined result

### Step 6 — Implement

Follow `${SHIPFLOW_ROOT:-$HOME/shipglowz}/skills/references/task-application-loop.md` during implementation:
- confirm target state and remaining slices before editing
- load all context files required by the execution contract
- implement one bounded slice at a time
- update durable progress only after the slice is actually complete
- stop or reroute when a slice exposes a contract, design, security, data, or proof gap

Execute the changes directly.

Implementation constraints:
- implement the user story outcome, not a narrow proxy metric
- implement the smallest safe path: the smallest complete, excellent, professional, best-practice implementation that satisfies the contract and preserves security, performance, maintainability, and future evolution
- make successful actions observable to the user/operator unless the contract explicitly justifies silent success and provides another verification path
- make failures observable or recoverable unless the contract explicitly justifies silent failure and provides a recovery/observation path
- preserve Sentry/error instrumentation, diagnostics/log-copy surfaces, and build identity/timestamps when the project has them; do not swallow exceptions only to report them, and do not remove release/environment/user-safe context needed for runtime diagnosis
- follow existing project conventions
- keep the change inside the declared task scope
- preserve the invariants and linked systems named in the execution contract
- preserve the spec's dependency/version context while coding; do not silently implement against a newer or stale canonical `shipglowz_data/` decision contract, legacy root fallback contract, API doc, or architecture doc than the spec names
- keep documentation coherent with feature behavior: update docs, README, guides, examples, FAQ, onboarding, pricing or support copy when the contract names them
- preserve abuse-case and security constraints named in the spec
- preserve fresh external docs constraints from the execution contract; if current docs contradict the intended implementation, stop and reroute instead of coding from memory
- avoid speculative refactors unrelated to the task
- if a new side effect appears outside the contract, stop and reroute instead of improvising
- if scope expands materially, stop and reroute to spec-first
- if a missing answer changes authorization, failure handling, visibility, retention, tenant isolation, or retry behavior, stop and ask

### Step 7 — Quick validation

Run focused validation relevant to the modified area only at an explicit
checkpoint, at the end-of-conversation handoff, when `SGEND`/`104-sg-end` or
`SGSHIP`/`005-sg-ship` owns the next step, when the operator requests it, or
when an immediate high-risk focused check is necessary. Do not run this section
after every message or small intermediate correction. Otherwise report
`validation deferred: intermediate work` and continue implementation.

At the applicable checkpoint:
- include at least one validation that the main user story outcome is actually delivered
- include proof that matches the chosen proof path, or record the explicit exception and alternate evidence
- validate `Success Behavior` and `Error Behavior` when the contract names them; if an error path cannot be exercised, state the gap explicitly
- include a sanity check that success is not silent and failure is not silent unless explicitly justified by the contract
- when the user story depends on a browser auth flow or protected app path, run or emulate `109-sg-auth-debug` logic to confirm the observable flow in a real browser
- when the user story depends on non-auth browser proof, route to or emulate `108-sg-browser` logic after the Playwright MCP runtime preflight
- targeted tests if available
- If the task produces or updates a manual checklist, create or update it before validation so `107-sg-test` can run against concrete rows.
- quick lint/type check for touched modules when practical
- syntax check for touched shell scripts if relevant
- run the validation commands named in the spec when present
- include at least one sanity check on each linked system / consumer impacted by the change
- include a documentation coherence check when the user-visible feature behavior changed
- include abuse-case / security sanity checks when the contract names them
- if runtime errors, Sentry instrumentation, or diagnostics/log-copy UI are in scope, include a sanity check that errors remain visible to the user/operator and that Sentry or copied diagnostics can be correlated without exposing secrets

Project development mode gate:
- If `development_mode` is `local`, run the focused validation normally with the local dev server or local tooling when needed.
- If `development_mode` is `vercel-preview-push`, local static checks are allowed, but browser/manual/integration/user-flow validation must be deferred until after `005-sg-ship` pushes the change and `405-sg-prod` confirms the matching Vercel deployment. Do not ask the user to test a local URL as proof for this mode.
- If `development_mode` is `hybrid`, use local validation only for purely local unit/static/UI checks. For auth, OAuth, webhooks, hosted env vars, serverless/edge runtime, Vercel routing, or anything that differs by deployment environment, require the `005-sg-ship` -> `405-sg-prod` sequence before the manual or browser test.
- When preview-push validation is required, stop after implementation and quick local checks with next step `/005-sg-ship [task]`. The next action after that successful push must be `/405-sg-prod [project or URL]`; testing follows only after `405-sg-prod` returns the ready preview/deployment URL.

If checks fail, report clearly and include next repair action.

### Step 7.5 — Local auto-verify follow-through

After the applicable checkpoint checks pass, decide whether `102-sg-start` may
continue into local verification before the final report. Check eligibility by
itself does not authorize mid-conversation validation.

Use `auto-verify: run` only when all criteria are true:

- one unique ready spec owns the work
- implementation and required local checks in `102-sg-start` scope passed
- the remaining verification is local, tool-backed, read-only or non-destructive, and does not require a user decision
- no preview, production, hosted runtime, auth/browser flow, Sentry dashboard, device-only behavior, manual QA, secret access, commit, push, ship, deployment, billing, data mutation, external provider action, or other external side effect is required
- the verification command or owner route is already clear from the spec and changed surface

When eligible, run the local verification or the local equivalent of `103-sg-verify` checks for the changed contract. Record the validation evidence and include `auto-verify: run` in the report. If that local verification fails because the implementation or contract is broken, do not claim lifecycle success; continue to a correction when safe, otherwise report `partial` or `blocked` with the concrete failed check.

Use `auto-verify: skipped` when any criterion is false. The skip reason must name `owner_skill`, `scenario`, and `target_or_environment`:

- preview or hosted proof: `005-sg-ship -> 405-sg-prod`, then `108-sg-browser`, `109-sg-auth-debug`, or `107-sg-test` as needed
- production truth or deployment health: `405-sg-prod`
- non-auth browser proof: `108-sg-browser`
- auth/session/provider proof: `109-sg-auth-debug`
- durable manual QA or retest: `107-sg-test`
- broader lifecycle/adversarial verification: `103-sg-verify`

Local auto-verify is not closure, ship, or full lifecycle orchestration. It must not run `104-sg-end`, `005-sg-ship`, commits, pushes, deployments, provider actions, destructive tests, manual prompts, or secret-bearing proof. `001-sg-build` remains the full lifecycle owner when the operator invokes a master build flow.

### Step 8 — Report

For `report=agent` only, output the detailed execution report below. In
`report=user`, follow the shared reporting contract and omit file names, paths,
counts, agent groups, and other handoff-only detail.

```text
## Started and Implemented: [task name]

Mode: [direct / spec-first]
Primary execution model: [model]
Reasoning effort: [low / medium / high / xhigh]
Execution topology: [single-agent / multi-agent]
Development mode: [local / vercel-preview-push / hybrid / unknown-vercel]
Validation surface: [local / preview after 005-sg-ship -> 405-sg-prod / mixed]
Contract: [ready spec path / direct mini-contract]
Fresh context: [used fresh subagent / user asked to open new thread / not necessary]
User story: [one-line promise]

Agent groups:
- [group] — [model] — [owned files or scope]

Files changed:
- [file] — [what changed]

Validation:
- [check] -> [pass/fail]

Auto-verify:
- [run/skipped] -> [local evidence or exact owner route]

Proof path:
- [test-first / regression-first / scenario-first / evidence-first / exception-with-proof] -> [evidence or exception]

Linked checks:
- [area] -> [pass/fail]

Documentation coherence:
- [docs updated / not impacted because ... / gap]

Fresh external docs:
- [checked / not needed / gap / conflict] — [dependency/version/source]

Metadata / version context:
- Spec: [metadata_schema_version / artifact_version / status]
- Depends on: [artifact@version status, ...]
- Drift: [none / outdated dependency / unknown version / rerouted]

User story validation:
- [main promised outcome] -> [pass/fail]

Success / error behavior:
- Success behavior -> [pass/fail/not checked]
- Error behavior -> [pass/fail/not checked]
- Observability -> [success visible / error visible / justified silent / gap]
- Sentry -> [instrumentation preserved / supplied pointer correlated / no pointer supplied / not applicable]

Security / abuse checks:
- [check] -> [pass/fail]

Next step:
- [/103-sg-verify [task] | /005-sg-ship [task] when preview-push validation is required]

## Chantier

Skill courante: 102-sg-start
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- 100-sg-spec: [status]
- 101-sg-ready: [status]
- 102-sg-start: [implemented | partial | blocked | rerouted]
- 103-sg-verify: [status]
- 104-sg-end: [status]
- 005-sg-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [/103-sg-verify [task] | /005-sg-ship [task] puis /405-sg-prod si le mode impose une preview Vercel]

Place the shared chantier header immediately before `🎯 VERDICT (HH:mm) : [implemented | partial | blocked | rerouted]`; do not append a verdict after this body.
```

### Rules

- Implement by default (do not stop at planning)
- Do NOT commit or push
- Exception: when the documented project mode requires Vercel preview-push validation, `102-sg-start` still must not run raw git commands itself, but it must route the immediate next action to `005-sg-ship`, followed by `405-sg-prod`, before any preview/browser/manual test is treated as proof.
- Do NOT update CHANGELOG.md (handled by end/ship flow)
- For non-trivial tasks, block without a `ready` spec
- If request and spec conflict, surface the conflict before coding
- Do not silently compensate for a weak spec during implementation; reroute instead
- Do not silently drop or reinterpret `depends_on` metadata from the spec; version context must survive from read -> implementation -> report -> 103-sg-verify
- Do not treat tests as the product contract; the spec, bug file, release scope, or mini-contract remains the source of truth.
- Do not claim completion without a proof path and matching evidence.
- Do not reduce a user story to UI behavior only when the contract implies workflow, permission, data, or system guarantees
- Do not ship a feature behavior change while leaving known docs, examples, onboarding, pricing, FAQ or support copy stale
- When ambiguity affects security or product semantics, ask the user before proceeding
- If a fresh context is required and cannot be created inside the current environment, ask the user to create it before proceeding
- Use subagents only when write ownership is clear and the coordination overhead is justified
- Reuse the `704-sg-model` routing reference rather than inventing ad hoc model choices
