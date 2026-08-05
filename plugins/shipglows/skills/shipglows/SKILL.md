---
name: shipglows
description: Route ShipGlows plugin workflows, inspect optional packs, and audit local packaging readiness.
argument-hint: "<instruction | help | packs | audit packaging>"
---

# ShipGlows

## Mission

ShipGlows is the public plugin entrypoint for ShipGlows workflows in Codex.
It presents a small métier-first surface: one router and thirteen outcome
owners. Numeric skill names are packaging engines, not the public vocabulary.

Use it when the operator wants to:

- understand which métier owns an outcome from the plugin
- route a project-shipping request to the right ShipGlows capability
- inspect the planned optional packs without installing many plugins manually
- audit a local ShipGlows source tree before packaging more skills
- install or update the complete ShipGlows corpus when the lightweight plugin is not enough

## Default Scope

Default to read-only analysis unless the operator explicitly asks to edit, install, update, or publish a plugin or skill.

This plugin is the distribution nucleus. It must not assume that the full private ShipGlows source tree exists on the user's machine.

Prefer the local source tree only for development audits:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}
```

If that path is missing, explain that the plugin is installed but local source-tree packaging checks cannot run.

## Required Reference

For empty, `help`, `aide`, capability, availability, or métier questions, load:

```text
references/public-help-catalog.md
```

For `packs`, `catalog`, `install`, or packaging questions, load:

```text
references/pack-catalog.md
```

For `references`, `docs`, `site`, `web docs`, or portability questions, load:

```text
references/reference-strategy.md
```

For `shipglows-main`, `portability matrix`, `bundle readiness`, or public-pack selection questions, load:

```text
references/shipglows-main-portability-matrix.md
```

For `pack maintenance`, `refresh pack`, `update pack`, `modify skills`, `publish pack`, or skill-to-pack update questions, load:

```text
references/pack-maintenance-playbook.md
```

For `spec`, `ready`, `start`, `verify`, `check`, `fix`, `vérifier`, `contrôle`, `corriger`, or `shipglows-main` workflow execution questions, load:

```text
references/shipglows-main-intents.md
```

Resolve this path relative to this skill directory inside the plugin.

## Mode Detection

Parse the operator instruction.

- Empty, `help`, `aide`, `métiers`, or `workflows`: answer from the bundled public help catalog and ask for the outcome to route when useful.
- `packs`, `catalog`, `modules`, or `capabilities`: summarize `references/pack-catalog.md`.
- `stage pack`, `generate pack`, `refresh pack`, `update pack`, `pack generation`, or `stager pack`: run `scripts/refresh_shipglows_pack.py <pack-id>` when a pack id is supplied and local ShipGlows source exists.
- `pack maintenance`, `modify skills`, `publish pack`, or skill-to-pack update questions: summarize `references/pack-maintenance-playbook.md`.
- `shipglows-main`, `portability matrix`, `bundle readiness`, or `public pack`: summarize `references/shipglows-main-portability-matrix.md`.
- `spec`, `ready`, `start`, `verify`, `check`, `fix`, or their French equivalents: route through `references/shipglows-main-intents.md`.
- `references`, `docs`, `site`, `web docs`, or `hosted docs`: summarize `references/reference-strategy.md`.
- `audit packaging`, `audit packs`, `portability`, or `local ShipGlows packaging`: run the packaging audit script when available.
- `installation complète`, `corpus complet`, `clone repo`, `install full repo`, or `full ShipGlows`: offer the complete ShipGlows corpus setup script and run it only with explicit operator approval.
- Requests to install optional packs: install only when the named pack exists as a plugin or skill source. Otherwise report that the pack is planned but not generated yet.
- Product, code, release, content, design, engineering, docs, or planning work: identify the matching public métier first, then resolve the matching pack and installed capability. Execute only with capabilities that are actually bundled or installed in the current session.
- For public `shipglows-main` intents, perform the portable gate, planning, checklist, command discovery, or bug triage that can be done from the current workspace. If the requested workflow needs unbundled ShipGlows references, tracking files, or tools, continue in partial mode and state the exact complete-corpus requirement instead of stopping early.

## Reference Strategy

ShipGlows uses a hybrid reference model:

- local plugin references for execution-critical contracts
- hosted docs for long examples, tutorials, public explanations, changelogs, and upgrade paths

Do not require browsing for core workflow execution. Hosted docs can enrich an answer, but the plugin must remain usable when the network is unavailable or browsing is disabled.

For users who want the complete ShipGlows corpus, prefer the complete-corpus setup route instead of bundling every private reference into the plugin:

```bash
scripts/bootstrap_shipglows_repo.sh
```

Resolve this script relative to the plugin root. It creates a sparse checkout of the public ShipGlows repository into `${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}`.

When the operator asks about docs links, inspect:

```text
assets/docs-links.json
```

Resolve this path relative to the plugin root. Treat entries marked `executionRequired: false` as optional supporting material, not as gates required to obey a skill.

## Packaging Audit

When local ShipGlows source exists and the operator asks for packaging readiness, run:

```bash
python3 ~/plugins/shipglows/scripts/audit_shipglows_packaging.py
```

Use this audit to find:

- missing source skills in the pack catalog
- missing shared or skill-local references
- source-tree assumptions that are not portable in a public plugin
- overlarge skill bodies that should move detail into references before packaging

Do not rewrite skills from this plugin unless the operator explicitly asks for an edit pass.

## Pack Staging

When the operator asks to generate or stage one optional pack, use:

```bash
python3 ~/plugins/shipglows/scripts/refresh_shipglows_pack.py <pack-id>
```

The refresh script runs staging and Codex plugin validation. The staging step reads `assets/pack-catalog.json`, copies cataloged source skills into a staged plugin directory, copies detected shared references outside `skills/`, copies cross-skill references into the referenced skill when available, writes `.codex-plugin/plugin.json`, and writes `shipglows-pack-report.json`.

Default output:

```text
~/.shipglows/staged-packs/<pack-id>/
```

Do not call a staged pack public-ready unless `shipglows-pack-report.json` has zero hard findings and zero review findings. If the output directory already exists, use `--force` only when the operator has asked to replace the previous staging result.

## Optional Pack Rule

The user should install one public plugin first: `shipglows`.

Optional packs are implementation modules behind that entrypoint. They may become additional plugin packages later, but the user-facing route should stay:

```text
$shipglows <what I want to accomplish>
```

If a task requires an optional pack that is not installed, report:

- required pack id
- whether it is bundled, generated locally, planned, or unavailable
- exact next action if it can be installed now
- that Codex may need a new session before newly installed skills are loaded

Do not present numeric engine names or a list of many manual installation steps
as the default user experience. Reveal engine names only for expert packaging,
portability, or complete-corpus troubleshooting.

## Complete ShipGlows Corpus Setup

The lightweight plugin is the default install surface. The full repo is an optional source corpus.

Use the complete-corpus setup script only when:

- the operator asks for the full ShipGlows source, all skills, or local packaging work
- a requested workflow needs references or tools that are not bundled in the plugin
- the operator approves network access and the target directory

Default target:

```text
${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}
```

Default source:

```text
https://github.com/commandglows/shipglows.git
```

The complete-corpus checkout includes only the skill/runtime corpus:

- `skills/`
- `templates/`
- `tools/`
- `shipglows_data/`
- `local/`

It intentionally excludes the public site, TUI app, generated builds, and dependency directories. Canonical archives, research, operator guides, and bug workflow records remain inside `shipglows_data/`.

If the target already exists and is a Git repo, update it by fetching and checking out the requested ref. If the target exists and is not a Git repo, stop and ask before changing anything.

## Operator-Last-Resort Rule

When safe local inspection or validation is possible, do it before asking the operator to continue or retest.

Ask the operator to act only when:

- the required pack does not exist yet
- installation needs credentials or approval
- the task requires private product judgment
- a newly installed skill requires a new Codex session to load

## Stop Conditions

Stop and report blocked if:

- the requested pack or source path does not exist
- a packaging audit would need to read private source outside the declared ShipGlows tree
- installation would overwrite an existing plugin, skill, or marketplace entry without explicit approval
- repo bootstrap would write into a non-empty non-Git directory
- the request needs full private ShipGlows workflows that are not bundled or installed

## Reporting

Keep the response in the operator's language.

For pack questions, report:

- current plugin status
- relevant pack id
- bundled/generated/planned state
- next automatic action taken or why it is blocked

For packaging audits, lead with findings and affected skills.
