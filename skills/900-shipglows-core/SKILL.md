---
name: 900-shipglows-core
description: "Internal ShipGlows skill maintenance: audit, build, refresh, packaging, and help."
argument-hint: "<audit [scope]|build <target>|refresh <target>|packaging [scope]|help>"
---

# ShipGlows Core

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` and apply its ShipGlows-Owned Tool Preflight before any owned file or tool. Never infer owned paths from the project cwd or ask the operator to run an agent-runnable preflight.

CLI/TUI work targets `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/shipglows.sh`, `cli/lib.sh`, `cli/config.sh`, `cli/install.sh`, `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/install-shipglows.ps1`, `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/windows/`, or `tui/` as applicable.

## Chantier And Report Modes

Trace category: `obligatoire`. Process role: `lifecycle`.

Attach to one unique spec and update its flow; otherwise use `(local)` and require `100-sg-spec` for non-trivial build work. Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final report. Default to concise `report=user`; details and blockers use `report=agent`.

## Mission

`900-shipglows-core` is the sole internal owner for improving ShipGlows skills, shared doctrine, validation tooling, registry/activation graph, and packaging boundaries. Invocation targets the ShipGlows system under `$SHIPGLOWS_ROOT`, never the current project by default.

## Mode And Invocation Preflight

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`. It validates both syntax and the registry-owned activation graph; invalid or ambiguous preflight never activates this skill.

Supported modes are `audit [scope]`, `build <target>`, `refresh <target>`, `packaging [scope]`, and `help`. Bare or invalid input lists these modes or asks one targeted question. `build` and `refresh` without a target are invalid; retired `009-sg-skill-build` / `307-sg-skills-refresh` names as aliases are forbidden. A mode uniquely owned elsewhere may receive its exact public correction but is never auto-executed.

`core` is a hard ShipGlows-system context: every remaining word is ShipGlows work, never to the current project. An operator critique authorizes a bounded repair: select the narrowest internal
`build` target and continue without asking the operator to choose a mode. Project names, quoted routes, or desired project outcomes are failure evidence only. A critique such as “pourquoi il propose d’auditer ShipGlows ? je veux le projet courant” repairs the core routing rule; it does not audit either repository.

No later project name, repository path, request, or quoted outcome overrides the hard context.

## Progressive Mode Packs

Local packs load directly and never chain.

- `audit`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/core-audit-and-improvement.md`.
- `build`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-maintenance-playbook.md`; non-trivial work uses spec-first lifecycle and `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` plus `master-delegation-semantics.md` only after this route is selected.
- `refresh`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-refresh-playbook.md`.
- `packaging`: load `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/core-packaging.md`.
- `help`: explain modes only; load no procedural pack.

Load at most one local playbook before the first substantive action. Missing local playbook, target, graph/runtime path, or proof blocks the mode rather than falling back to memory or a retired command.

Conditional authorities: `skill-execution-fidelity.md` for obedience/audit; `skill-instruction-layering.md` for placement; `resource-discovery.md` for resolver work; `spec-driven-development-discipline.md` before contract edits; `codex-plugin-packaging.md` for plugin bundles; `$SHIPGLOWS_ROOT/skills/references/windows-bootstrap-development-workflow.md` for Windows bootstrap, installer, runtime-path, migration, wrapper, or self-update work.

## Scope And System-Improvement Gate

Audit, packaging, and help are read-only unless edits are requested. `build`/`refresh` follow their packs; non-trivial behavior requires a ready spec. An operator critique of ShipGlows execution authorizes a bounded repair unless explicitly restricted to read-only.

For confirmed non-style failures, report exactly once: `Observed problem`, `System cause`, `Prevention rule`, and `Contract/tooling improvement proposal`. Before editing, name the pressure scenario, apply the shared `Followability Gate`, and choose the narrowest owner layer. A passing generic audit is not completion proof. Require focused mechanical or pressure-scenario proof.

Prefer one local contract for one owner, shared doctrine for repeated ownership, and tooling when recurrence should be caught mechanically. Every material skill edit receives conservative `refresh <target>` review before final budget and `103`; the lifecycle is `100 -> 101 -> 102 -> 900 refresh -> 103 -> 104 -> 005`. Ordinary self-refresh stays prohibited and requires independent spec-backed review.

## Internal And Packaging Boundary

Keep `shipglows` as the canonical public plugin, `$shipglows` as its public entrypoint, and `shipglows` is a compatibility alias only. Keep `900-shipglows-core` internal and repo-synced; `shipglows-core` remains a deprecated historical pilot, never canonical or public.

## Stop Conditions

Stop when `$SHIPGLOWS_ROOT/skills` or a requested tool/pack is absent; the activation graph preflight fails; an owned tool would run before path/tool confirmation; broad edits lack authorization/readiness; internal core would become public; packaging would expose secrets/private context/dependencies/caches/machine paths; or proof requires secrets, destructive action, private access, or user-only hardware.

## Validation

Run `python3 -m unittest tools.test_900_shipglows_core_contract tools.test_skill_activation_graph tools.test_skill_invocation_check`, `python3 tools/skill_invocation_check.py --audit-graph`, `python3 tools/audit_shipglows_skills.py`, the budget audit, metadata lint, and runtime sync.
