---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-13"
status: reviewed
source_skill: 300-sg-docs
scope: opencode-runtime-docs
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - ".opencode/skills/shipglows/SKILL.md"
  - ".agents/skills/shipglows/SKILL.md"
  - "README.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
depends_on:
  - artifact: ".opencode/skills/shipglows/SKILL.md"
    artifact_version: "unknown"
    required_status: "unknown"
  - artifact: ".agents/skills/shipglows/SKILL.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes:
  - docs/opencode-shipglows.md
evidence:
  - "Repository-local OpenCode shim exists at `.opencode/skills/shipglows/SKILL.md`."
  - "Repository-local generic OpenCode-compatible shim exists at `.agents/skills/shipglows/SKILL.md`."
  - "README and runtime docs already distinguish manual user input from internal runtime calls."
next_step: "/300-sg-docs audit shipglows_data/technical/operator-guides/opencode-shipglows.md"
---

# ShipGlows in OpenCode

This page explains the repo-proven OpenCode path for using ShipGlows.

## What You Type

In OpenCode, ask for the ShipGlows skill in natural language or select it through the runtime skill picker when the UI exposes one.

Examples:

- `Use the ShipGlows skill to route this task`
- `ShipGlows: help me choose the right workflow`
- `ShipGlows: audit local packaging`

## What You Do Not Type

Do not type internal runtime calls such as `skill({ name: "shipglows" })`.

Those calls may appear in runtime implementations or logs, but they are runtime internals, not operator commands.

## How This Repository Exposes ShipGlows to OpenCode

The repository currently proves two relevant runtime surfaces:

- `.opencode/skills/shipglows/SKILL.md` is the explicit OpenCode repository shim.
- `.agents/skills/shipglows/SKILL.md` is the generic OpenCode-compatible fallback shim.

If your OpenCode setup supports repo-local skill import or repository skill discovery, point it at the explicit `.opencode/skills/shipglows/` surface first. Use `.agents/skills/shipglows/` only when your setup expects the generic compatible path. The regular ShipGlows runtime bootstrap intentionally omits both paths; use the explicit corpus surface when OpenCode needs them.

## What ShipGlows Does After Discovery

Once OpenCode resolves ShipGlows:

- the `shipglows` entrypoint explains or routes
- the selected owner skill carries execution
- runtime internals may invoke local skill calls after interpreting your request

This means the repo-level `shipglows` entrypoint is for choosing the right workflow, not for pretending that a helper page executes the whole task itself.

## Configuration Notes

This repository proves the skill shims above. It does not claim every OpenCode installation uses the same import UI or configuration screen.

Use this repo contract:

1. keep the repository checkout visible to OpenCode
2. prefer `.opencode/skills/shipglows/`
3. fall back to `.agents/skills/shipglows/` only when your runtime expects the generic compatible path
4. launch the visible `shipglows` skill or ask for it in natural language

## When You Need the Full ShipGlows Corpus

The OpenCode shim is a lightweight repository entrypoint. For a local checkout that includes the public skill corpus and OpenCode shim, request the explicit corpus surface:

```bash
curl -fsSL https://www.commandglows.com/shipglows-script | SHIPGLOWS_INSTALL_MODE=local SHIPGLOWS_INSTALL_SURFACE=corpus sh
```

Use that route only when the runtime surface is not enough. The Codex plugin remains a separate, no-clone installation path.

## Installer Note

When you use `ShipGlows`'s root installer on a server, `cli/install.sh` can also install the user-space `opencode` CLI via `pnpm` if the operator selects it. That installer choice is separate from the repository shim path described on this page.
