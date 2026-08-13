---
name: shipglows
description: Route ShipGlows workflows, packs, and packaging audits in OpenCode-compatible agents.
argument-hint: "<instruction | context | help | packs | audit packaging>"
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

Before any intentional mutation, obtain explicit approval given after the approval message. Use a one- or two-sentence `🧭 VALIDATION RAPIDE` naming the exact action, exact target, and main safety guarantee only when the request is explicit and unambiguous, the target is resolved, and the action is local-only, routine, readily reversible, and cannot overwrite, discard, delete, force, publish, deploy, message, change credentials/permissions, or affect unrelated changes. Otherwise present `🧭 PLAN À VALIDER` with Objective, Scope, Actions, Proofs, and contextual choices. The initial request is not approval; a material scope change requires a newly appropriate fast validation or replacement full plan. `git push` always uses the full plan, and force push retains stricter gates.

Prefer the local source tree only for development audits:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}
```

If that path is missing, explain that the repository skill is available but local source-tree packaging checks cannot run.

## Routing

- `context`, `contexte`, `env`, or `environment`: enter the direct runtime-context mode below. Do not route it to generic documentation or planning.
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

## Runtime Context Mode

For `$shipglows context`, inspect rather than infer:

1. Read `%USERPROFILE%\.shipglows\environment.md` on Windows, or the corresponding global environment file documented by the installed runtime.
2. Resolve the current ShipGlows-managed project root from the working directory, then read `<project-root>\ENVIRONMENT.md` and its matching Windows DevServer registry entry.
3. Report the host, shell, agent surface, server manager, live server status, and exact canonical local URL.
4. Use that URL for local browser, test, screenshot, or preview work. Never substitute Astro/Vite defaults such as `4321`, repository scripts, remembered ports, or another project's URL.
5. Report Playwright exactly as the global file states. If it is configured but no browser/Playwright tool is exposed in the current turn, say `Playwright configuré, outil non exposé dans ce tour`; never say that no browser is installed.
6. Treat the current turn's injected tool inventory as the authority for what can be called now. ChatGPT apps/connectors and Codex CLI tools are different surfaces.

This mode is read-only. A missing project document, missing registry entry, or inactive server blocks only server-dependent actions; it does not authorize launching a replacement server. End with a compact `Contexte actif` summary that subsequent work in the conversation must follow.

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
