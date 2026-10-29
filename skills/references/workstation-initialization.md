---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-29"
updated: "2026-10-29"
status: active
source_skill: 900-shipglows-core
scope: workstation-initialization
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/000-shipglows/SKILL.md, cli/windows/ShipGlows.AgentInstructions.psm1, shipglows_data/workflow/specs/shipglows-workstation-init.md]
depends_on: []
supersedes: []
evidence: ["Operator requested workstation initialization, persistent root, agent instructions, memory and context on 2026-10-29."]
next_step: none
---

# Workstation initialization

Load only for `$shipglows init [context|agents|memory]` or an explicit request to
initialize ShipGlows on this computer. The router owns this agent-executed workflow
directly. It is distinct from project scaffolding (`305-sg-init`) and shell commands.
Absent scope runs all three plus readiness inventory. Unknown scope asks one question.

## Authority and resolution

Explicit init authorizes the bounded local non-secret pointer/instruction repairs
below. `init context` is read-only. Host policies and posture remain binding:
`#nolocal`/`#ci` inspect and describe pending writes only. Discussing or implementing
this skill never initializes the current machine implicitly.

Resolve the root through `canonical-paths.md`: process environment, Windows
current-user environment and validated linked channel, then installed default.
Record the winning source/channel and verify the exact
`skills/000-shipglows/SKILL.md` and each helper before use. Conflicting explicit
environment and linked-channel roots block root-dependent writes; report both
sources and continue independent read-only inventory. Never guess a sibling
checkout, switch channels, scan drives or clone a maintainer repository.

Read `$HOME/.shipglows/workstation-context.json` if present as a hint only. Compare
to authoritative resolution and replace obsolete managed hints after verification.
Missing runtime: report the exact path and use the official installer guidance
from `installer-and-user-scope.md` if accessible; the public wrapper supplies the
bootstrap entry point when the runtime is absent. Installer local/full choices,
SDK proposals and licences remain explicit.

## Durable context and memory

For default, `memory` or `agents` scope, apply this same ownership/schema and
atomic-write contract to create/update
`$HOME/.shipglows/workstation-context.json` with this non-secret shape:

```json
{
  "schemaVersion": 1,
  "managedBy": "shipglows-init",
  "root": "<verified absolute root>",
  "rootSource": "<process-env|user-env|linked-channel|installed-default>",
  "channel": "<linked|installed>",
  "platform": "<current OS and architecture>",
  "environmentFile": "<absolute global environment report path>",
  "verifiedAt": "<current ISO-8601 timestamp>"
}
```

Reject malformed, foreign-owned or unsupported-schema context files. Stop a write
to symlink/reparse targets when ownership cannot be established. No-change reruns
leave files untouched except an explicitly refreshed verification timestamp.
Store no secrets, account identities, project inventories, ports, PIDs, tool
inventories or login/runtime claims. This file never overrides environment/channel.

Persist verified root/channel/environment pointers in current-agent memory only
through its discovered supported writer and current host policy. Include platform,
timestamp, authoritative resolution order and exact engine-existence check before
reuse. If policy requires a proposed-update note, use that permitted location;
never edit canonical memory registries. Distinguish saved from proposed memory.
If no permitted writer is available, report memory unavailable; the local context
file still persists. Do not search unrelated memory/private stores to compensate.

## Native agent files

For default or `agents` scope, detect installed agents using bounded command/config
evidence. Update only detected agents' native global instruction files:

| Agent | Path relative to actual user home |
| --- | --- |
| Codex | `.codex/AGENTS.md` |
| Claude | `.claude/CLAUDE.md` |
| OpenCode | `.config/opencode/AGENTS.md` |
| Kilo | `.config/kilo/AGENTS.md` |
| Gemini | `.gemini/GEMINI.md` |

Honor explicitly supported agent home/config overrides (including Codex home);
never create competing default files or configurations for absent agents.
Add/update exactly one separate block:

```text
# >>> ShipGlows workstation >>>
ShipGlows root: <verified absolute path>; channel: <linked|installed>.
Context pointer: <absolute workstation-context.json path>.
Environment report: <absolute environment.md path>.
Use this root for exact owned-file reads; verify skills/000-shipglows/SKILL.md exists.
Process/user SHIPGLOWS_ROOT and validated channel remain authoritative.
If absent/conflicting, resolve canonical paths; do not scan drives or guess.
Use $shipglows context for current evidence; $shipglows init refreshes these pointers.
# <<< ShipGlows workstation <<<
```

Before modifying a native file, inspect it and its parent path for symlinks/junctions
or other reparse points. Preserve links; stop that file's write unless an existing
supported writer establishes the owned target and updates it without replacing
the link. Continue independent files and report the exact blocked target.
This complements the installer's `ShipGlows development environment` block;
do not replace or rewrite its doctrine. Preflight all selected files for duplicated,
incomplete or reversed markers before writing. Preserve outside text byte-for-byte,
encoding and newline conventions. Use atomic replacement and local backups for
changes; re-read to confirm one correctly ordered block and unchanged outside
text. Reruns replace their own block. Contradictory standalone human instructions
are reported conflicts, never silently rewritten. Stop ambiguous writes.
For `init agents`, create the context pointer file too so the block never points
to a nonexistent cache; this does not authorize separate agent-memory writes.

## Readiness and context refresh

For default or `context` scope, execute the existing `shipglows context` skill
procedure in this conversation, not a shell command. Load
`agent-runtime-awareness.md` and `entrypoint-special-modes.md` for its context
branch. Read the global environment, bounded CLI snapshot where applicable, and
current-turn direct/deferred tools. Select a managed project/surface only when
identifiable; do not assume init's cwd is an application. Refresh selected registry
evidence before runtime verdicts.

Inventory shell/PATH, declared toolchain readiness, agent skill links/discovery,
CLI/MCP configuration versus callability, Git availability/identity presence, and
declared project configuration. Report missing SDK/browser/backend/auth/Doppler
requirements from existing evidence only. Missing environment reports or stale
readiness are gaps; never fabricate reports or infer login. No arbitrary project
setup hooks, builds, tests, package updates or application launches from init.

Continue authorized pointer repairs. For missing tools or stale generated global
environment reports, inspect the existing platform installer/repair recipe in
`installer-and-user-scope.md`. Never invoke an installer merely to inspect it.
Installation, authentication, licences, permissions, account linking and service
starts retain their own gates; init alone does not authorize them. Ask only for
actual operator choices/unavailable facts and continue independent work.

## Completion evidence

Report verified root/channel; pointer and agent files persisted; memory
saved/proposed/unavailable; context refreshed or exact gap; one concrete user step
if needed. Separate file reread from next-agent-session discovery and mention reload
when necessary. Do not claim fresh-computer installation, login, protected access
or live runtime from configuration/source review. Never commit machine-local
context, backups or memory into a project repository.
