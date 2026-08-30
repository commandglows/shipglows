---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-27"
updated: "2026-08-27"
status: active
source_skill: 900-shipglows-core
scope: shipglows-dx-runtime-maintenance
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - cli/
  - local/
  - tui/
  - install-shipglows.sh
  - install-shipglows.ps1
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/runtime-cli.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-27: Core owns maintenance of the ShipGlows DX repository, including CLI, TUI, and DevServer, while shipglows_app remains the separate site/SaaS product."
next_step: none
---

# ShipGlows DX Runtime Maintenance

Use for a scoped `900-shipglows-core audit|build` target under the ShipGlows DX runtime. Core owns the lifecycle and integration boundary; executable behavior remains canonical in runtime code and its mapped tests.

## Boundary and target map

- Unix CLI/DevServer: `cli/shipglows.sh`, `cli/lib.sh`, `cli/config.sh`, `cli/install.sh`, and the Bash/gum menu frontends.
- Native Windows DevServer and installer: `cli/windows/` plus `install-shipglows.ps1`; load `skills/references/windows-bootstrap-development-workflow.md` for bootstrap, staging/active-runtime, wrapper, migration, or self-update work.
- Reproducible environment control plane: `cli/environment/` and its runtime, environment, and Windows adapter tests.
- Local DX helpers: `local/` and their mapped tunnel/login contracts.
- Terminal cockpit: `tui/` and its source-specific tests and documentation.
- Unix bootstrap: `install-shipglows.sh`; packaging of the public Codex plugin remains the separate `packaging` mode.

`shipglows_app` is never a runtime target here. Its public site and SaaS belong to that product repository. If a DX change must alter product behavior there, stop and require a separate product-owned route and authority.

## Resolve and contract

1. Resolve one exact runtime surface beneath `$SHIPGLOWS_ROOT`; reject sibling checkout inference, generated active-runtime copies as source, or an unbounded whole-runtime rewrite.
2. Read `shipglows_data/technical/code-docs-map.md`, the mapped primary technical contract, adjacent implementation, focused tests, and recent relevant history.
3. For `audit`, remain read-only and return evidence-backed findings plus the narrow build target. For `build`, require a ready spec for non-trivial behavior and apply the shared lifecycle, mutation, implementation-excellence, and proof contracts.
4. Select `test-first`, `regression-first`, `scenario-first`, or `evidence-first` from the changed behavior. Starting a server or running an installer is never implicit proof authority.

## Implementation and proof

- Preserve platform boundaries: Flox/PM2/Caddy remain Unix-server concerns; native Windows behavior remains PowerShell and registry based.
- Use the code-doc map to choose the smallest focused syntax, contract, unit, integration, or installed-runtime proof. Run the complete CLI or Windows suite only when the changed surface materially requires it.
- Keep process lifecycle explicit for any server, watcher, tunnel, emulator, or interactive command; retain an exact handle and prove termination before closure.
- Treat runtime copies, staged installer payloads, and active installed binaries as distinct. Source changes are not deployed or installed behavior until the applicable workflow proves convergence.
- Update mapped technical documentation or record a concrete no-impact result before closure.

## Escalate to system coherence

Stop this single-surface pack and select `system-coherence.md` when the same behavior changes an agent contract, invocation/alias, public plugin/bootstrap promise, runtime command, and canonical governance surface together. Do not maintain two independent descriptions of one behavior.

## Stop conditions

Stop for an unresolved runtime surface, missing mapped contract/test, required `shipglows_app` mutation, production or credential effect, destructive runtime operation, unapproved install/server execution, unrelated dirty-file overlap, or proof that cannot distinguish source, staged, installed, and active state.

## Validation

Run one focused mapped proof by default. Add broader CLI, TUI, Windows, environment, packaging, metadata, or documentation checks only when the actual diff crosses those surfaces or a focused failure demonstrates the need.
