---
name: shipglows
description: Route ShipGlows workflows, packs, and packaging audits in OpenCode-compatible agents.
argument-hint: "<instruction | help | packs | audit packaging>"
---

# ShipGlows for OpenCode-compatible agents

Use this skill when working in the ShipGlows repository with an OpenCode-compatible agent runtime.

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

Prefer the local source tree only for development audits:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}
```

If that path is missing, explain that the repository skill is available but local source-tree packaging checks cannot run.

## Routing

- `core <instruction>`: treat every remaining word as ShipGlows-system work.
  Project routes, paths, and outcomes are failure evidence; never audit or
  modify the cited project. Leave `core` before requesting project work.
- `help`, `aide`, or empty: explain the public workflow surface.
- `packs`, `catalog`, `modules`, or `capabilities`: summarize the pack catalog.
- `audit packaging`, `audit packs`, `portability`, or `local ShipGlows packaging`: run the packaging audit when local ShipGlows source exists.
- `refresh pack`, `update pack`, or `pack maintenance`: explain pack refresh flow and point to the refresh script.
- Expert aliases resolve through their canonical public owner mode before an
  internal workflow: planning owns `explore`, `spec`, `status`, and `resume`;
  development owns `build`; bug owns `fix`; engineering owns generic
  `verify`, `test`, and `browser`; release owns `ship`, `deploy`, and `prod`.
  Content owns `capture` and its `tmux` alias; both export the tmux conversation
  through the same internal capture engine.
  Explicit design, SEO, release, or bug verification retains that specialist
  owner. The aliases contain no independent workflow behavior.
- `references`, `docs`, `site`, or `hosted docs`: explain the local-vs-hosted reference policy.
- `full ShipGlows`, `clone repo`, or `installation complète`: offer the sparse bootstrap route and ask before any networked change.

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
