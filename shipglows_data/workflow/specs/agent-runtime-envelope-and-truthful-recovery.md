---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-09-04"
created_at: "2026-09-04 10:48:00 UTC"
updated: "2026-09-04"
updated_at: "2026-09-04 11:06:04 UTC"
status: completed
source_skill: 100-sg-spec
source_model: gpt-5.6
scope: agent-runtime-envelope-and-truthful-recovery
owner: Diane
confidence: high
user_story: "As the ShipGlows operator, I want context reports to identify the actual agent host and reconcile fresh runtime and transport evidence so an agent neither promises an unavailable proof nor sends diagnosis back to me prematurely."
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/agent-runtime-awareness.md
  - skills/000-shipglows/SKILL.md
  - skills/301-sg-context/SKILL.md
  - skills/shipglows/SKILL.md
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - tools/agent_runtime_envelope.py
  - tools/test_agent_runtime_envelope.py
  - tools/test_context_quality_contract.py
  - tests/windows/agent-instructions.ps1
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "2026-09-04: Rio-hosted standalone Codex CLI exposed the Computer Use skill and Node REPL but sky.list_apps failed because no native pipe existed."
next_step: none
---

# Agent runtime envelope and truthful recovery

## User story

As the ShipGlows operator, I want context reports to identify the actual agent host and reconcile fresh runtime and transport evidence so an agent neither promises an unavailable proof nor sends diagnosis back to me prematurely.

## Minimal behavior contract

`$shipglows context` reports the execution envelope, resolves the selected managed surface, reads authoritative live state at decision time, and qualifies every tool through transport reachability and a safe probe before calling it usable.

## Success behavior

- Reports operating system, agent surface, terminal host, local/remote session location, and physical/virtual/container machine kind.
- Distinguishes a standalone Codex CLI under Rio from Codex Desktop even when both expose the same skill and Node REPL.
- Treats the registry `status` as authoritative; `flutterStartupState` is supporting startup evidence and never overrides `stopped` or `error`.
- Resolves `ENVIRONMENT.md` for the selected managed surface, not only the repository root.
- Revalidates only invalidated runtime sources after an observed contradiction, state transition, or transport failure.
- Classifies Computer Use native-pipe absence as a host/transport failure and recommends Codex Desktop for standalone CLI sessions rather than a vague restart.

## Error behavior

Process presence alone must not prove Desktop hosting, plugin discovery must not prove transport reachability, stale Flutter startup fields must not prove a live session, and an agent must not stop while safe targeted diagnosis remains.

## Scope

In scope: shared runtime doctrine, context entrypoints, Windows projected instructions, deterministic host-envelope helper, and focused regression tests. Out of scope: changing OpenAI's Computer Use implementation, launching or configuring Codex Desktop, and product repository changes.

## Implementation tasks

- [x] Capture Rio/CLI, Desktop, VM/remote, stale Flutter, managed-surface, and native-pipe pressure scenarios.
- [x] Implement the runtime-envelope helper.
- [x] Harden shared doctrine and all context entrypoints.
- [x] Update projected Windows instructions and code-docs mapping.
- [x] Run focused validation and update this flow.
- [x] Deliver the exact owned change to `origin/dev` through protected PR #134.

## Acceptance criteria

- [x] Synthetic host classification tests pass.
- [x] Context contracts require all execution-envelope and transport states.
- [x] Windows instruction projection contains the same recovery invariant.
- [x] Existing context and instruction tests remain green.
- [x] The exact owned change is committed, protected by required checks, and delivered through PR #134.

## ZOMBIES coverage

Zero: missing ancestry yields `unknown`, not Desktop. One: one current registry entry wins. Many: multiple surfaces require an explicit selected managed surface. Boundaries: `starting`, `stopped`, and `error` remain distinct. Interfaces: plugin, tool catalog, transport, and probe stay separate. Exceptions: native-pipe failure triggers targeted refresh and host-specific recovery. Simplicity: one bounded JSON envelope, no durable machine-state registry.

## Risks

Process names vary across hosts, so the helper reports evidence and `unknown` rather than guessing. Runtime probing remains read-only and never starts applications or transports.

## Skill Run History

| Timestamp UTC | Skill | Mode | Outcome |
|---|---|---|---|
| 2026-09-04 10:48:00 | 100-sg-spec | create | Ready contract derived from the operator-approved structural repair and reproduced Rio/CLI native-pipe failure. |
| 2026-09-04 10:59:08 | 102-sg-start | implement | Added deterministic execution-envelope detection, managed-surface and registry precedence, transport qualification, targeted refresh, and host-specific recovery. |
| 2026-09-04 10:59:08 | 103-sg-verify | verify | Runtime-envelope, context, Windows projection, metadata, activation graph, budget, public runtime sync, and live Rio/CLI classification checks passed. |
| 2026-09-04 10:59:08 | 104-sg-end | close | Reviewed; exact-scope commit and push remain. |
| 2026-09-04 11:06:04 | 005-sg-ship | deliver | Protected PR #134 opened; required CI and the complete Windows repository gate passed before the final closure revision. |

## Current Chantier Flow

`100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship (completed via PR #134)`
