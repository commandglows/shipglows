---
name: 900-shipglows-core
description: "Maintain the internal ShipGlows DX system across skills, CLI/DevServer/TUI runtime, coherence, packaging, and help."
argument-hint: "<audit [scope]|build <target>|refresh <target>|packaging [scope]|help>"
---

# ShipGlows Core

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` and apply its ShipGlows-Owned Tool Preflight before any owned file or tool. Never infer owned paths from the project cwd or ask the operator to run an agent-runnable preflight.

DX runtime work targets `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/`, `local/`, `tui/`, `install-shipglows.sh`, `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/install-shipglows.ps1`, or `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/windows/` as applicable. `shipglows_app` is a separate product repository for the public site and SaaS; it is evidence only in hard Core context and never a Core mutation target.

## Chantier And Report Modes

Trace category: `obligatoire`. Process role: `lifecycle`.

Attach/update one unique spec; otherwise `(local)` and `100-sg-spec` for non-trivial builds.
Load canonical `reporting-contract.md` before final reporting. Default `report=user`.
Use `report=agent` only on explicit operator/orchestrator request; blockers do not select it.
Preserve required blocker, proof, and continuity disclosures.

## Mission

Core is the sole internal DX lifecycle owner; canonical runtime code, tests
and specialist owners retain their internals. Target `$SHIPGLOWS_ROOT`, never the
current project or `shipglows_app` by default.

## Mode And Invocation Preflight

Explicit invocation: load `skills/references/skill-invocation-preflight.md` from `$SHIPGLOWS_ROOT` for syntax and activation-graph checks; invalid or ambiguous preflight blocks activation.

Modes: `audit [scope]`, `build <target>`, `refresh <target>`, `packaging [scope]`, `help`. Bare or invalid input lists modes or asks one question. `build`/`refresh` without a target are invalid. Retired `009-sg-skill-build`/`307-sg-skills-refresh` names as aliases are forbidden. Uniquely owned modes get an exact public correction, never auto-execution.

`audit recent [N]` (default 10) / `audit since <commit>` → skill surface, `references/recent-loading-audit.md` instead of generic audit; read-only even for critiques. List both in help.

`core` is a hard ShipGlows-system context: every remaining word is ShipGlows work, never to the current project. An operator critique authorizes a bounded repair: select the narrowest internal
`build` target and continue without asking the operator to choose a mode. Project names, quoted routes, or desired project outcomes are failure evidence only. A routing critique repairs the core routing rule; it does not audit either repository.

Later project names, paths, requests or quotes cannot override this context.

## Surface And Mode Selection

First classify one target surface:

- `skill`: `skills/` (skills and doctrine), activation registry, skill validation tooling, or runtime skill links;
- `runtime`: `cli/`, `local/`, `tui/`, local helpers, Unix or Windows DevServer, environment control plane, wrappers, bootstrap, or installers;
- `coherence`: cross-surface coherence spanning two or more skill, runtime, distribution, or governance surfaces.

Resolve discoverable surfaces without asking. A missing or genuinely ambiguous surface blocks. Local packs load directly and never chain.

- `audit`: skill/doctrine scope loads `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/core-audit-and-improvement.md`; runtime scope loads `references/dx-runtime-maintenance.md`; bare or cross-surface scope loads `references/system-coherence.md`.
- `build`: skill/doctrine scope loads `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-maintenance-playbook.md`; runtime scope loads `references/dx-runtime-maintenance.md`; cross-surface scope loads `references/system-coherence.md`. Non-trivial work uses spec-first lifecycle and `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` plus `master-delegation-semantics.md` only after this route is selected.
- `refresh`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-refresh-playbook.md`.
- `packaging`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/core-packaging.md`.
- `help`: explain modes only; load no procedural pack.

Load at most one local playbook before acting. Missing local playbook, target, graph/runtime path or proof blocks; no memory or retired-command fallback.

Conditional authorities: `skill-execution-fidelity.md` for obedience/audit; `skill-instruction-layering.md` for placement; semantic ID `shared:resource-discovery` at `$SHIPGLOWS_ROOT/skills/references/resource-discovery.md` for resolver work; `spec-driven-development-discipline.md` before contract edits; `mutation-plan-approval.md` before any intentional mutation; `codex-plugin-packaging.md` for plugin bundles; `$SHIPGLOWS_ROOT/skills/references/windows-bootstrap-development-workflow.md` for Windows bootstrap, installer, runtime-path, migration, wrapper, or self-update work.

## Scope And System-Improvement Gate

Audit, packaging, and help are read-only unless edits are requested. `build`/`refresh` follow their packs; non-trivial behavior requires a ready spec. An operator critique of ShipGlows execution authorizes a bounded repair unless explicitly restricted to read-only.

For confirmed non-style failures, report exactly once: `Observed problem`, `System cause`, `Prevention rule`, and `Contract/tooling improvement proposal`. Before editing, name the pressure scenario, apply the shared `Followability Gate`, and choose the narrowest owner layer. A passing generic audit is not completion proof. Require focused mechanical or pressure-scenario proof.

Prefer one local contract for one owner, shared doctrine for repeated ownership, canonical runtime code/tests for executable behavior, and tooling when recurrence should be caught mechanically. Bounded low-risk corrections use focused pressure-scenario proof and applicable reporting/reflection gates directly; material semantics, routing, security or authority changes retain ready-spec lifecycle and independent review regardless of diff size. Broad skill, packaging, audit and release work retains conservative `refresh <target>` review. Runtime work uses mapped proof. Ordinary self-refresh stays prohibited and high-assurance self-work requires independent spec-backed review.

## Internal And Packaging Boundary

Keep `shipglows` as the canonical public plugin, `$shipglows` as its public entrypoint, and `shipglows` is a compatibility alias only. Keep `900-shipglows-core` internal and repo-synced; `shipglows-core` remains a deprecated historical pilot, never canonical or public.

## Stop Conditions

Stop when `$SHIPGLOWS_ROOT/skills` or a requested tool/pack is absent; the activation graph preflight fails; a target surface is unresolved; a request would mutate `shipglows_app` from Core context; an owned tool would run before path/tool confirmation; broad edits lack authorization/readiness; internal Core would become public; packaging would expose secrets/private context/dependencies/caches/machine paths; or proof requires secrets, destructive action, private access, or user-only hardware.

## Loading Preservation

Recent/since comparison loads `skill-context-budget.md` and `skill-refactor-verifier.md`.

Before changing references, triggers, shared doctrine or protections, load `skill-context-budget.md`.
Apply its Loading Change Gate even when files shrink: justify need/trigger/timing,
compare affected paths, and block unexplained regressions or lost protections.

## Validation

For a bounded daily repair, run only its focused contract or pressure-scenario test and affected-skill runtime sync when discoverability changed. Run activation/resource graphs, global skill audit, budget audits, metadata lint, broad suites, and all-skill sync only for explicit audit/release work or when the changed surface materially depends on them.
