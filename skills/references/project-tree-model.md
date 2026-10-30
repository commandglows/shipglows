---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-30"
updated: "2026-10-30"
status: active
source_skill: 300-sg-docs
scope: project-tree-model
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/windows/shipglows.ps1
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - skills/references/monorepo-governance-topology.md
  - skills/references/preferred-stacks.md
  - skills/305-sg-init/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-10-30: one tree model per technology so the CLI, the skills and the runner find the same files every time."
  - "Operator decision 2026-10-30: one Flutter app serves Android, iOS, web and Windows."
  - "Audit shipglows_data/workflow/audits/2026-10-30-project-tree-models.md."
next_review: "2027-01-30"
next_step: "/300-sg-docs migrate-layout for the projects listed in the audit"
---

# Project Tree Model

This reference is the single authority for where a project's surfaces and manifests live. Other references point here instead of restating it.

## Rule

- The repository root is the governance root. It holds `AGENT.md`, `README.md`, `PITCH.md`, `ENVIRONMENT.md` and `shipglows_data/` (with `stack.json`). It may also hold workspace files (`pnpm-workspace.yaml`, a root `package.json` with no `dev` script).
- A surface is one folder whose root holds its manifest, its `.shipglows.*.json` files and its `ENVIRONMENT.md`.
- Single-surface repository: the surface is the repository root.
- Multi-surface repository: each surface is a first-level folder named after its role, from the table below.

## Fixed Names

| Role | Folder | Surface root |
| --- | --- | --- |
| Astro site | `site/` | `package.json`, `astro.config.mjs`, `src/content.config.ts`, `src/pages/`, `public/` |
| Flutter app | `app/` | `pubspec.yaml`, `lib/`, `test/`, the platform folders (`android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/`), `.shipglows.flutter.json` |
| Browser extension | `ext/`; `extensions/<name>/` from the second shipped extension | `package.json` and `wxt.config.ts` (WXT), or `manifest.json` (static) |
| Obsidian plugin | `obsidian/` | `package.json`, `manifest.json`, `src/main.ts` |
| Tauri desktop app | `desktop/` | `package.json`, `src/` (frontend), `src-tauri/Cargo.toml`, `src-tauri/tauri.conf.json` |
| Backend authority | `backend/` | `convex/`, or `pyproject.toml` / `requirements.txt` |
| Other deployable service | its own name (`runner/`, `worker/`, `lab/`) | its manifest |
| Shared library | `packages/<name>/` | its manifest |

A library repository (an engine) keeps its libraries in `packages/<name>/` and its demo app in `demo/`.

## One Flutter App Per Product

One `app/` serves Android, iOS, web, Windows, macOS and Linux. Platform differences live in the native platform folders, in adaptive layout, in conditional imports, or in a dedicated entrypoint such as `lib/main_windows.dart`. The DevServer selects the target with `-FlutterDevice`.

A second Flutter app is allowed only for a distinct product with its own features and its own release, such as a tray companion. It gets its own first-level folder named after its role.

## Inner Layouts

- Astro: `astro-site-playbook.md`.
- Flutter: `flutter-engineering-playbook.md`.
- Browser extensions and Obsidian plugins: `preferred-stacks.md`.

## Forbidden Names

`<repo>_app/`, `<repo>_site/`, `app_flutter/`, `flutter_app/`, `flutter/` for an app, `website/`, `chrome_extension/`, `browser_extension/`, `extension/`, `obsidian_plugin/`, `apps/*` without a documented durable reason, a surface nested under a feature folder (`app_quiz/flutter_app/`), and one Flutter app per platform.

## Tool Discovery

Tools that read a project's technologies or context read the repository root, every first-level folder, and every `packages/*/` folder. They skip hidden folders, `shipglows_data` and `node_modules`, `build`, `dist`, `.output`, `target`, `vendor`, `third_party` and `public`. They never read deeper.

This applies to `shipglows stack scan`, `s extension-inspect`, `s extension-lab` and the runner (project catalog, context generator, AI readiness). DevServer surface discovery skips the same folders; it still descends to depth 3 so that layouts not yet migrated stay launchable.

## Migration

Rename a non-conforming folder with `git mv`, then update every path reference: configuration, CI, Vercel Root Directory, relative `path:` dependencies, `ENVIRONMENT.md`, documentation and registries. A Dart or npm package name is not a path and keeps its value. Run `s refresh` afterwards so the DevServer registry drops the old paths. The audit lists the projects still to migrate.
