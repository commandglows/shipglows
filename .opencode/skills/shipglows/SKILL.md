---
name: shipglows
description: Route ShipGlows workflows, packs, and packaging audits in OpenCode.
argument-hint: "<instruction | init [context|agents|memory|resume] | help | packs | audit packaging>"
---

# ShipGlows for OpenCode

Use this skill when working in the ShipGlows repository with OpenCode.

## Mission

ShipGlows is the public workflow entrypoint for ShipGlows tasks.

Use it when the operator wants to:

- understand what ShipGlows can do from the repository
- route a project-shipping request to the right ShipGlows capability
- inspect planned optional packs
- audit local ShipGlows packaging readiness
- bootstrap the complete ShipGlows corpus when the lightweight surface is not enough

## Default Scope

Default to read-only analysis unless the operator explicitly asks to edit, install, update, or publish a plugin or skill.

Prefer the local source tree for development audits; explicit `init` also uses
an already verified complete corpus without changing the installation channel:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}
```

If that path is missing, explain that the repository skill is available but local source-tree packaging checks cannot run.

## Routing

- `help`, `aide`, or empty: explain the public workflow surface.
- `init [context|agents|memory|resume]` with optional `role=<local|remote|consult|test>` and `lifetime=<persistent|ephemeral>`: use the workstation entry below; preserve arguments and posture tags.
- `packs`, `catalog`, `modules`, or `capabilities`: summarize the pack catalog.
- `audit packaging`, `audit packs`, `portability`, or `local ShipGlows packaging`: run the packaging audit when local ShipGlows source exists.
- `refresh pack`, `update pack`, or `pack maintenance`: explain pack refresh flow and point to the refresh script.
- `spec`, `ready`, `start`, `verify`, `check`, `fix`, or French equivalents: route conceptually to the matching ShipGlows workflow.
- `references`, `docs`, `site`, or `hosted docs`: explain the local-vs-hosted reference policy.
- `full ShipGlows`, `clone repo`, or `installation complète`: offer the sparse bootstrap route and ask before any networked change.

## Workstation Entry

Distinguish the operator device from this agent's execution host. Resolve intent
from the explicit/saved compatible role or task; ask one role question only if
needed. `context` is read-only; `#nolocal`/`#ci` defer writes. Reject conflicting
options before action. Do not initialize merely while discussing this mode.

Where filesystem access exists, resolve process `SHIPGLOWS_ROOT`, then on Windows
user environment and validated linked `development-channel.json`, then the
installed `$HOME/.shipglows/runtime`. Check the exact canonical engine and
`skills/references/workstation-initialization.md`; if valid, load the engine and
continue the original request through its init workflow. Never infer a nearby
checkout, scan drives or let cached pointers override authoritative roots.

Without that corpus, continue available consult/remote guidance and report exact
missing capabilities. Do not require local installation for consult, invent native
iOS/iPadOS setup, or claim a phone is the remote filesystem host. For a requested
local development host, use the existing bootstrap guidance
`https://shipglows.com/shipglows-script` (native Windows: `?format=powershell`),
without downloading or executing it implicitly. Installation, connections, account
access and restoration retain their own authority. Missing persistence is reported
as session-only; no fabricated root, cache, memory or readiness claims.

## Reference Strategy

ShipGlows uses local repository references for execution-critical behavior and hosted docs for support material.

Do not require browsing for core workflow execution.

For the complete corpus, prefer the sparse checkout helper:

```bash
scripts/bootstrap_shipglows_repo.sh
```

## Reporting

Keep the response in the operator's language. For packaging or portability questions, report:

- current plugin or repository status
- relevant pack or workflow id
- bundled/generated/planned state
- next automatic action or why it is blocked
