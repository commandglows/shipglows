---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-30"
updated: "2026-10-30"
status: active
source_skill: sg-engineering
scope: project-tree-models
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
domains: ["cli", "devserver", "runner", "skills", "project-layout"]
linked_systems:
  - cli/windows/shipglows.ps1
  - cli/windows/ShipGlows.DevServer.psm1
  - skills/references/monorepo-governance-topology.md
  - skills/references/preferred-stacks.md
  - skills/305-sg-init/SKILL.md
  - shipglows_app/runner/src
depends_on: []
supersedes: []
evidence:
  - "Read-only survey on 2026-10-30 of 19 local repositories from shipglows-private/projects/registry.json (temuglowz has no local checkout)."
  - "DevServer registry %LOCALAPPDATA%\\ShipGlows\\DevServer\\registry.json read on 2026-10-30 (71 entries)."
  - "shipglows stack scan code at commit 16a1e51e."
next_step: "Finish the pending migrations listed under Status, one validated project at a time."
---

# Project Tree Models Audit

## Scope

Where ShipGlows defines or assumes the file tree of Astro, Flutter, browser extension, Obsidian plugin and Tauri projects, and how the real repositories compare.

## What the doctrine says today

- `monorepo-governance-topology.md`, `preferred-stacks.md` and `305-sg-init`: multi-surface repos use flat roots `site/`, `app/`, `backend/`, `ext/` (`extensions/<name>/` from the second extension), `packages/`. Nested `apps/*` needs a documented reason.
- `canonical-project-governance-placement.md`: one `shipglows_data/` at the repo root; `AGENT.md`, `README.md`, `ENVIRONMENT.md` may stay at the root.
- Inner layouts: Astro in `astro-site-playbook.md` (`src/content.config.ts`, `src/pages`, `src/i18n`, `public/`), Flutter in `flutter-engineering-playbook.md` (`lib/core|data|services|features|routing`), Obsidian `src/main.ts` in `preferred-stacks.md`.
- Silent: where a Tauri surface, an Obsidian plugin or an extra deployable service (`runner/`, `worker/`) lives in a multi-surface repo; whether a product may have several Flutter apps; library repos (`flutter/` versus `packages/`).

## What the tools assume

| Tool | Where it looks | Effect |
| --- | --- | --- |
| `shipglows stack scan` | repo root only | Empty stack for every multi-surface repo (`shipglows_app` case). |
| `shipglows stack scan` | `Cargo.toml` at the root for Tauri | Tauri is never detected: its `Cargo.toml` lives in `src-tauri/`. |
| `shipglows stack scan` | no extension or Obsidian rule | Extensions and plugins never enter a stack. |
| `s extension-inspect` | root, `dist/`, `build/`, `extension/` | Doctrine says `ext/`; `extension/` is a dead name. |
| DevServer discovery | any folder down to depth 3 | Registers vendored and public folders as surfaces (`app/vendor/analytics_actions_flutter`, `app/third_party/convex_flutter`, `ext/public`) and writes `ENVIRONMENT.md` into them. `replayglows/ext/public/ENVIRONMENT.md` is committed and ships inside the extension build. |
| Runner catalog, context generator, ai-readiness (`shipglows_app/runner`) | repo root only | Same blind spot as `stack scan` for platforms and context. |
| Installed CLI (`~/.shipglows/runtime/bin/shipglows.ps1`) | n/a | Not synced with the repo: `stack` is missing. |

Per-surface files are consistent: `.shipglows.flutter.json`, `.shipglows.backend.json`, `.shipglows.node.json`, `.shipglows.python.json`, `.shipglows.runtime.json` and `ENVIRONMENT.md` are read from the surface root (`launchPath`).

## Real trees by technology

| Technology | Conforms | Does not conform |
| --- | --- | --- |
| Astro (`site/`) | shipglows_app, notefinderz, gocharbon, bestfriedchicken, claiire, replayglows, contentglows, communityglows, beatglows | commandglows `commandglows_site/`, dreamglows `website/` |
| Flutter app (`app/`) | shipglows_app, bestfriedchicken, replayglows, contentglows, shipglows-email-engine | commandglows `commandglows_app/`, claiire `app_flutter/` (plus an empty `app/`), beatglows `app_flutter/`, communityglows `flutter/`, gocharbon `app_quiz/flutter_app/`, dreamglows `android_app/` and `windows_app/` (two apps) |
| Browser extension (`ext/`, or root when alone) | commandglows `ext/`, replayglows `ext/`, ToolGlows root, chrome-brat root | dreamglows `chrome_extension/`, contentglows `browser_extension/`, communityglows root (shared with Tauri) |
| Obsidian plugin | none to compare (no rule) | dreamglows `obsidian_plugin/` |
| Tauri | none to compare (no rule) | communityglows: Tauri and the extension share the root `src/` of a multi-surface repo |
| Backend | bestfriedchicken, replayglows `backend/` | gocharbon `app_quiz/backend/` and `app_quiz/convex/`; dreamglows `backend/` holds only `ENVIRONMENT.md` next to a root `convex/` |
| Library repos | shipglows-analytics-engine, shipglows-email-engine (`packages/`) | shipglows-ui-engine, shipglows-audio-engine, shipglows-window-engine (`flutter/<package>/`, referenced by path from consumer apps) |

## Constraints for migrations

- Uncommitted changes: communityglows (19), dreamglows (6), claiire (1, unrelated `AFR/`), contentglows (1, `app/pubspec.lock`), replayglows (1, generated `ENVIRONMENT.md`), shipglows_app (1, `app/pubspec.lock`).
- bestfriedchicken is on `develop`, not `main`; it already conforms.
- A renamed Astro folder changes the Vercel project Root Directory, a production setting outside the repo. Nothing breaks until a push.
- A deeper or shallower Flutter folder changes relative `path:` dependencies on the engines (gocharbon `app_quiz/flutter_app` to `app`).
- DevServer registry entries keep old paths until `s refresh`.

## Status (2026-10-30)

Validated by the operator. Done on `main`:

- Doctrine: `skills/references/project-tree-model.md`, with pointers from the topology, stacks, canonical paths and `305-sg-init`.
- CLI: `stack scan` follows the tool discovery rule and detects Tauri, browser extensions and Obsidian; `extension-inspect` and `extension-lab` select `ext/`; DevServer discovery skips `vendor`, `third_party`, `public` and `build`.
- Runner (`shipglows_app`): project catalog, context generator and AI readiness read every surface root.
- beatglows: `app_flutter/` moved to `app/`.

Pending, each waiting for the operator's validation:

- commandglows: `commandglows_app` is also the Dart package, the product id, the native channel prefix and the binary name, so only path forms may change. The Vercel Root Directory is `commandglows_site` (production setting). A running `commandglows_browser_bridge.exe` (Chrome native messaging host from the Debug build) locks the folder.
- gocharbon: `app_quiz/` is a self-contained sub-project (its own Vercel deployment, CI, Convex, Supabase, scripts); flattening it needs a layout decision, not only a rename.
- claiire, contentglows, replayglows, communityglows, dreamglows: uncommitted changes in progress.
- Stray DevServer `ENVIRONMENT.md` files committed in `replayglows/ext/public/`, `shipglows_app/app/vendor/analytics_actions_flutter/` and `contentglows/app/vendor/analytics_actions_flutter/`.
- Engines (`shipglows-ui-engine`, `shipglows-audio-engine`, `shipglows-window-engine`): `flutter/` to `packages/` changes the `path:` dependencies of every consumer app.
