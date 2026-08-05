---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-13"
status: reviewed
source_skill: 300-sg-docs
scope: kilocode-runtime-docs
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - ".agents/skills/shipglows/SKILL.md"
  - "README.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
depends_on:
  - artifact: ".agents/skills/shipglows/SKILL.md"
    artifact_version: "unknown"
    required_status: "unknown"
supersedes:
  - docs/kilocode-shipglows.md
evidence:
  - "Repository docs already state that KiloCode-style runtimes should use natural language or the runtime skill picker."
  - "The repository proves a generic OpenCode-compatible shim at `.agents/skills/shipglows/SKILL.md`, but no dedicated KiloCode shim path."
next_step: "/300-sg-docs audit shipglows_data/technical/operator-guides/kilocode-shipglows.md"
---

# ShipGlows in KiloCode

This page explains the current repo-visible KiloCode guidance for ShipGlows without claiming a dedicated KiloCode packaging path that the repository does not prove.

## What You Type

In KiloCode, ask for the ShipGlows skill in natural language or use the runtime skill picker when the runtime exposes one.

Examples:

- `Use the ShipGlows skill to route this task`
- `ShipGlows: help`
- `ShipGlows: verify this docs change`

## What You Do Not Type

Do not type internal runtime calls such as `skill({ name: "shipglows" })`.

Those are runtime internals, not manual operator commands.

## What the Repository Proves

This repository does **not** currently ship a dedicated `KiloCode`-named shim folder.

What it does prove is:

- a generic OpenCode-compatible shim at `.agents/skills/shipglows/SKILL.md`
- repo-visible guidance that OpenCode or KiloCode-style runtimes should use natural language invocation or the runtime skill picker

## Configuration Boundary

If your KiloCode setup supports repository-local compatible skills, use the generic `.agents/skills/shipglows/` shim as the repo-visible compatibility surface.

If your KiloCode build uses a different import or registration path, follow KiloCode's own runtime configuration flow, then expose the visible `shipglows` entrypoint to the operator. This repository does not claim a stronger KiloCode-specific install contract than that.

## What ShipGlows Does After Discovery

Once KiloCode resolves ShipGlows:

- the `shipglows` entrypoint explains or routes
- the selected owner skill carries execution
- the runtime may perform internal skill calls after interpreting your request

The operator boundary stays the same: ask for ShipGlows, then let the owner skill take over after routing.

## Practical Rule

Use this order:

1. ask for ShipGlows in natural language or pick it in the runtime UI
2. if repository-local compatible-skill import is needed, install the explicit public corpus with `SHIPGLOWS_INSTALL_SURFACE=corpus`, then use `.agents/skills/shipglows/`
3. treat internal runtime calls as implementation details only
4. do not assume a dedicated KiloCode repo shim unless the repo later adds one explicitly

## Installer Note

When you use `ShipGlows`'s root installer on a server, `cli/install.sh` can also install the user-space `kilocode` CLI via `pnpm` if the operator selects it. That does not change the repository boundary documented here: the repo still proves only the generic compatible shim path, not a dedicated KiloCode-named shim directory.
