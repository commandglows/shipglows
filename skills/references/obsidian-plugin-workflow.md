---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-09-02"
updated: "2026-09-03"
status: active
source_skill: 900-shipglows-core
scope: obsidian-plugin-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/ShipGlows.ObsidianLab.js
  - cli/windows/shipglows-devserver.ps1
  - shipglows_data/technical/operator-guides/obsidian-plugin-lab.md
depends_on: []
supersedes: []
evidence:
  - "The specialized classifier, declared-vault watch workflow, disposable Lab, and focused Windows tests were delivered on 2026-09-02."
  - "DreamGlows loaded and executed its dashboard command in a disposable Obsidian profile and vault without modifying personal Obsidian state."
  - "Operator-approved greenfield creation preset added on 2026-09-03: official TypeScript and esbuild-compatible foundation, desktop-plus-mobile support, native UI first, and Vue 3 for rich UI."
next_review: "2026-12-02"
next_step: none
---

# Obsidian Plugin Workflow

Use this workflow when ShipGlows classifies the target as `obsidian-plugin` or repository evidence includes an Obsidian `manifest.json`, the `obsidian` package, a plugin entry point, and a declared build or development script. Do not apply it to an ordinary website merely because the project uses Vite.

## Greenfield creation contract

For a new Obsidian plugin with no accepted technical direction, apply the Obsidian preset in `preferred-stacks.md`: the official `obsidian` TypeScript API, strict TypeScript, pnpm, and an esbuild-compatible artifact build. Support desktop and mobile by default; `isDesktopOnly: true` requires an essential verified Node.js or Electron dependency.

Use Obsidian components, DOM helpers, views, settings patterns, icons, and CSS variables for simple host-native interfaces. Use Vue 3 for a rich dashboard, complex settings, multi-step modal, or substantial reactive view; React is not a default. Mount Vue only inside an Obsidian-owned container, retain its application handle, and unmount it when the view or modal closes and again defensively during plugin unload. Commands, vault access, persistence, events, and registration remain owned by the Obsidian plugin lifecycle.

## Agent contract

1. Inspect the manifest, package scripts, entry point, output configuration, and local artifact set before running a repository command. Inspection never authorizes dependency installation or package scripts.
2. Treat `build-required` as a stop. Use the reviewed project build command, obtain its ordinary execution authority, run that exact command, and inspect the produced artifacts before retrying the Lab. Never invent a generic Vite command.
3. Use `s start -ProjectPath <path>` only for the declared development/watch workflow. Persistent copy synchronization requires one absolute `SHIPGLOWS_OBSIDIAN_VAULT` in `.shipglows.env`; ShipGlows must not scan, infer, rank, create, or select a personal vault. Only `SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy` is supported.
4. Use `s obsidian-lab -ProjectPath <path> -Headless -Json` to prove an already-built approved plugin in a disposable profile and vault. Add `-InteractionCommand <plugin-id:command-id>` when one registered command is part of the claim, `-ClickSelector <css>` for one exact rendered target, `-VisualSelector <css>` for bounded DOM/computed-style evidence, and `-Screenshot` only when visual evidence is useful.
5. Keep the proof states separate: detection, configuration, build freshness, artifact copy, actual host load, requested interaction, diagnostics, and cleanup. A build or copy never proves that Obsidian loaded the plugin; a loaded plugin may still have failed diagnostics.
6. Treat BRAT as a later distribution channel. The Lab checks local BRAT-compatible artifacts but never creates a release, tag, GitHub publication, BRAT installation, or community-store submission.

## Development vault and Lab vault

- The development vault is an operator-declared persistent target used by `s start` for copy synchronization. Missing or invalid configuration is actionable `detected`, not `ready`.
- The Lab vault and profile are disposable ShipGlows runtime data. The Lab does not use the configured development vault and must clean up its exact process tree and run directory.
- Multiple personal vaults are irrelevant: never enumerate them to choose a default.

## Trust boundary

The Lab protects personal Obsidian data through profile and vault path separation. It is not an OS sandbox: approved plugin code still runs with the Windows account's permissions. Stop if isolation cannot be proven, if the requested action would target a personal profile or vault, or if publication is being inferred from local validation.

## Proof vocabulary

- `detected`: the specialized plugin evidence is valid, but required configuration or fresh artifacts may still be missing.
- `configured`: one valid development vault and supported copy mode are declared.
- `build-required`: required artifacts are missing or stale; review and run the project's explicit build before further proof.
- `running`: the declared watch process is live; this does not prove host loading.
- `ready`: the declared development workflow has fresh artifacts and completed its configured copy step.
- `validation-unavailable`: build/copy succeeded but actual loading in Obsidian has not been observed.
- `artifact=passed`: the local BRAT-compatible artifact set is coherent and hashed.
- `hostLoad=passed`: the isolated Obsidian instance contains the plugin instance.
- `interaction=passed`: the requested registered command completed in the isolated host.
- `diagnostics=passed`: no bounded runtime diagnostic was captured; report failures separately from host loading.
- `cleanup=passed`: the exact Lab process tree stopped and disposable data was removed.

Never describe the plugin as tested, ready for users, or published from detection, compilation, copying, or artifact conformity alone.
