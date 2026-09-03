---
name: 000-shipglows
description: "Execute clear bounded requests directly and route unknown, unbounded, or directional work."
argument-hint: <instruction>
---

Primary artifact type: `entrypoint-router`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows-owned tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running.

## Intent-to-Outcome Ownership

For non-trivial routing, load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`. Resolve `project -> business/brand/product -> outcome -> surface -> work item`, inspect discoverable evidence before asking, and transition into the selected public métier owner in the same conversation. Routing is not terminal: preserve the outcome while the selected owner continues it end to end.

When context sufficiency, authority, freshness, conflict, compaction, or handoff can change the route, load `$SHIPGLOWS_ROOT/skills/references/context-quality-contract.md`, retain its qualified `Context Capsule`, and never treat memory as canonical truth.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

`000-shipglows` does not write specs, bug files, release scopes, commits, or deployment state. The selected owner owns durable state and chantier tracing. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing a final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`. Default to `report=user`, concise and in the user's active language; use detailed evidence only when explicitly requested or routing is blocked.

## Explicit Invocation Preflight

Before handing off an explicit skill name or numeric skill command, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md` and obey its checker result. A valid invocation stays silent; an invalid or ambiguous one never activates a substitute skill.

## Bounded Direct-Execution Gate

Clear bounded request authority, supplied-link register authority, and bounded
Auto-session authority in `mutation-plan-approval.md` are the direct-authority
paths. A clear bounded request authorizes its few coherent enumerable actions
and targets when the agent need not choose a material direction; it does not authorize a chantier. The register exception accepts only an exact factual
append-only update; Auto activates only from explicit `shipglows auto` and is
constrained by the mandatory no-local-execution policy.

Before any direct or routed mutation, load `$SHIPGLOWS_ROOT/skills/references/mutation-plan-approval.md`. Apply clear bounded-request authority first: a qualifying targeted file modification, deterministic micro-fix, exact-scope commit, ordinary resolved push, or small explicit sequence executes from the operator's request without another prompt. Local versus remote and model reasoning effort do not change the classification. Use `🧭 VALIDATION RAPIDE` for a bounded agent-proposed action or almost-clear intent; use `🧭 PLAN À VALIDER` when actions or targets are unbounded or the agent must analyze, propose, or select a material direction.

Before loading routing, topology, or owner-skill references, keep the request in direct main-thread execution when the user supplied a clear bounded outcome, the few actions and targets are known or discoverable with focused lookup, no material direction must be selected, and focused validation is sufficient. Typical cases include a targeted file edit, an exact string replacement, an exact-scope commit, an ordinary push, or a small explicit sequence of them.

Do not load a domain or lifecycle skill for these requests: no owner skill is needed. Apply the bounded edit and run the smallest relevant check. An explicitly named skill still activates and uses its smallest safe mode; if that skill discovers a different safe owner, let that skill reroute explicitly. This is the activation-critical form of the shared Skill Selection Proportionality Gate in `$SHIPGLOWS_ROOT/skills/references/skill-execution-fidelity.md`.

### Bounded internal reference-register updates

For a supplied-link update that meets the shared direct-authority exception, the initial request is sufficient; do not present a second approval prompt.

Treat a supplied-link update as direct execution and original-request authority when its register needs one focused local lookup, the operator supplied the public URLs and requested category, `candidate` is the only added status, no market interpretation or public claim is needed, and focused duplicate/row-shape proof is sufficient. Append it factually without launching source intake, market study, or documentation topology work; do not add a second approval prompt. Otherwise use normal routing and the normal mutation gate.

Use one primary-source check per supplied reference.

`veille <URL>` analyzes without persistence and does not automatically persist the source. `concurrent <URL>` or `inspiration <URL>` updates the matching internal register. `veille` takes precedence.

## Delegation And Topology

For requests outside the Bounded Direct-Execution Gate, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`. `000-shipglows` routes in the main thread and never launches a selected master skill as a nested subagent; after handoff, the selected owner controls topology. A routing scout is read-only, cheap, cannot launch skills or mutate state, and returns only a route recommendation.

## Shared Routing Reference

Before classifying non-trivial work, load `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md` and `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`; they are the canonical routing matrix and quality bar. Load `shipglows-terms`, `source-intake-classification`, `profile-activation` plus its minimal profile context, or `operator-partnership-contract` only when their matching trigger is present. Focus tags are binding route-bias cues; three-digit commands resolve through `skill-code-index.md` before classification.

When routing or answering depends on a local server URL, browser, MCP, app,
connector, or runtime-specific tool, load
`$SHIPGLOWS_ROOT/skills/references/agent-runtime-awareness.md` first. Read the
global development environment and the selected project's CLI-managed server
file; the current host turn remains authoritative for callable tools.

## Mission

`000-shipglows` is the primary natural-language entrypoint for non-technical operators. It routes, answers, or selects bounded direct execution; it does not prime broad context for a known task, generate a portfolio dashboard, or continue a resolved chantier after owner selection is clear.

ShipGlows-maintenance work defaults to the ShipGlows system under `$SHIPGLOWS_ROOT`, not the current project, unless the operator explicitly names another target. A ShipGlows-maintenance skill invocation, including `900-shipglows-core`, is sufficient to bind that target.

## Mode Detection

Parse `$ARGUMENTS` as the operator instruction. Empty/help requests answer directly or route to `302-sg-help` for the full help surface. Named profiles load the matching profile contract; explicit skill names and numeric codes pass preflight, then hand off only when valid. Natural-language work applies the Bounded Direct-Execution Gate before the canonical routing matrix; a selected skill may reroute explicitly rather than being silently substituted.

An explicit request for the ShipGlows maintainer workstation, an editable full ShipGlows clone, or the "version dev de ShipGlows" preserves maintainer intent through technical installation ownership. Generic `full`, `all`, `development environment`, or `corpus` language never grants or implies that channel switch.

Before mode selection, extract registered `#local`, `#nolocal`, and `#ci`
execution posture tags from any argument position and load
`$SHIPGLOWS_ROOT/skills/references/execution-posture-tags.md`. Keep ordinary
focus tags in the instruction. Reject conflicts; preserve the selected owner
and its authority. `#ci` implies `#nolocal` and only names deferred proof.

`auto` is a global autonomous credit-window mode. Run explicit-invocation
preflight, then hand off the remaining scope or horizon to `708-sg-auto` in the
same main conversation. That owner always loads
`$SHIPGLOWS_ROOT/skills/references/no-local-execution-policy.md` implicitly,
freezes the current project root for parent and subagents, and recommends
delegation only for independent useful work. `auto #nolocal` and legacy
`auto nolocal` are redundant; `auto #local` and legacy `auto local` are
unsupported. `auto #ci` keeps nolocal and records CI only as deferred proof.
Do not classify `auto` as the unrelated
`300-sg-docs auto` mode.

`nolocal <objective>` is a legacy compatibility alias, not a mode, owner, or
authority bypass. Require a non-empty objective, normalize it to
`<objective> #nolocal`, load
`$SHIPGLOWS_ROOT/skills/references/no-local-execution-policy.md`, resolve the
ordinary public métier owner from the remaining instruction, and preserve its
normal mutation approval while forbidding workload and external-state
execution. Do not send bare `nolocal` to `708-sg-auto` or select work for it.

`context`, `contexte`, `env`, and `environment` are direct read-only modes. Load `agent-runtime-awareness.md`, read the global development-environment file, the current project's `ENVIRONMENT.md`, and the matching live registry entry, then report the active architecture, exact managed URL, Python version/`uv`/commands, Playwright Chromium installation path, MCP configuration and verification, relevant mobile and Windows toolchain state, its exact next action, and current-turn callable tools. Run `$SHIPGLOWS_ROOT/tools/project_git_policy.py` against the project and visibly report the effective task-branch and worktree creation policies plus their canonical source; missing or invalid values render independently as `forbidden` with the resolver reason. Always include the resolver guidance that `forbidden` prevents silent creation but can be changed after discussing a justified need with the user. For Flutter, also report the registry-backed active development target, managed session mode, logical `flutter run -d <device>` command and live state; list merely available targets separately and never infer that they are active. Inspect direct and deferred/searchable tool catalogs before classifying capability; distinguish installed, configured, discovered, callable, failed, and not-exposed states. Never start a server, substitute a framework default port, or describe configured Playwright or recorded Python as absent merely because its tool is missing from the first visible list.

When the first token is a Codex expert alias, load `$SHIPGLOWS_ROOT/skills/references/expert-mode-aliases.md`, resolve it through `public owner -> owner mode -> internal engine`, run explicit-invocation preflight, and hand off in the same conversation. Aliases are Codex routing syntax only, never CLI arguments.

`git` routes to `sg-engineering github`. `hygiene` routes to the current-project
read-only `sg-maintenance hygiene` audit; `hygiene git` specializes exactly to
`sg-engineering github clean`. Reject workspace or multi-project hygiene scope.

`core` is a hard ShipGlows-system context: all remaining text belongs to `900-shipglows-core`, including project names or quoted desired outcomes. Never redirect any part of a `core` instruction to the current project.

`verify` preserves an explicit specialist owner: design/accessibility/UI/animation -> `sg-design`; SEO/search -> `sg-seo`; release/deploy/preview/live/production -> `sg-release`; bug/regression/retest -> `sg-bug`; otherwise use `sg-engineering verify`. Generic verification never replaces a specialist audit.

Route away when the helper surface is already known: context priming -> `301-sg-context`; cross-project state -> `308-sg-status`; paused work -> `706-continue`.

## Handoff And Question Contract

Use the canonical routing matrix to choose one owner, then hand off in the same conversation with the original instruction and the owner’s report mode. Preserve onboarding or first-success intent through `sg-development`; never stop at a command recommendation when work is agent-runnable.

Before a routing question, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`. Ask one numbered, plain-language question only when the answer changes the route or safety posture; resolve operator-owned business truth precisely rather than calling it generic ambiguity.

## Stop Conditions

Stop and report `blocked` when no route can be chosen without a material product, data, security, permission, deployment, or ship decision; the selected contract is missing; nested master execution is requested; unapproved destructive/production/payment/auth/tenant/secret/dirty-file scope is requested; or routing would bypass evidence, verification, closure, or ship gates.

## Final Report

For a direct answer, report the answer and direct route. For a handoff, state the selected public owner and brief reason only when useful, then continue under its report contract. For a blocked route, state the reason and use the question contract.

## Rules

- Keep this skill thin; do not duplicate owner internals or the canonical routing matrix.
- Do not mutate files before the selected owner takes over.
- Do not launch selected master skills inside subagents or treat direct handoff as parallelism.
- Do not create specs, bug files, commits, deployments, or public-content changes directly from this router.
- Match user-facing language to the user's active language.
