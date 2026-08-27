---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-08-27"
updated: "2026-08-27"
status: active
source_skill: sg-development
source_model: "GPT-5 Codex"
scope: "native-windows-browser-extension-projects"
owner: "Diane"
confidence: high
user_story: "En tant qu'operatrice ShipGlows sous Windows, je veux cloner et piloter une extension Chrome moderne depuis le menu GitHub sans qu'elle soit assimilee a un site Vite, afin de conserver un environnement, un lancement et des preuves adaptes aux extensions navigateur."
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "cli/windows/ShipGlows.DevServer.psm1"
  - "cli/windows/shipglows-devserver.ps1"
  - "tests/windows/"
  - "shipglows_data/technical/runtime-cli.md"
  - "shipglows_data/technical/context-function-tree.md"
depends_on:
  - artifact: "shipglows_data/technical/runtime-cli.md"
    required_status: reviewed
supersedes: []
evidence:
  - "ToolGlows uses Manifest V3, CRXJS 2.7, Vite 8 and a dedicated dev:chrome script."
  - "The current Windows detector classifies ToolGlows as vite, so it applies a generic web URL, launch command and HTTP readiness contract."
  - "CRXJS upstream documents @crxjs/vite-plugin 2.7.1 as its current Vite-based Manifest V3 and HMR toolchain, with Vite 8 in its declared peer range."
  - "Chrome's official extension tutorial keeps unpacked loading as an explicit developer-mode action against the generated extension directory."
next_step: "Run the installed Windows menu flow against ToolGlows, including Chrome unpacked loading, then decide whether to push the ShipGlows commit."
---

# Native Windows browser-extension projects

## Status

Implemented and verified on the local source/fixture surfaces. Installed-runtime and real Chrome proof remain intentionally pending for the operator's later test.

## Behavior contract

ShipGlows detects a Node project as `browser-extension` before generic Vite when its package metadata declares a supported extension toolchain and an explicit Chrome development script. Clone and registration preserve the repository, assign the HMR port, and write durable environment guidance that distinguishes the extension surface from an ordinary web URL.

Starting the project installs dependencies with the repository's existing lockfile and declared package-manager version, launches only the explicit Chrome development script, and marks the project ready only while the managed process is alive, its HMR port is listening and a valid Manifest V3 package exists in a supported unpacked-output directory. Open directs the operator to Chrome's extension manager and the generated unpacked directory; it never silently installs an extension into a personal browser profile.

## Scope

- Detect CRXJS projects only when `@crxjs/vite-plugin` and an explicit `dev:chrome` script are present.
- Preserve Astro and generic Vite precedence outside that bounded extension signature.
- Support pnpm lockfiles while honoring a valid exact `packageManager: pnpm@x.y.z` declaration through Corepack.
- Add extension-specific dependency artifact, launch, readiness, environment and open behavior.
- Add regression coverage and align the Windows runtime documentation.

## Exclusions

- Automatic Chrome Web Store publication or browser-profile mutation.
- Automatic Firefox loading or cross-browser test execution.
- Migration of an extension's own dependencies or source code.
- Push, deployment or installed-runtime replacement.

## Acceptance criteria

- ToolGlows is classified as `browser-extension`, not `vite`.
- A generic Vite fixture remains `vite`.
- A package merely depending on an extension toolchain without `dev:chrome` is rejected as an extension launch surface.
- A pinned pnpm package manager produces a Corepack-backed frozen install plan.
- Extension launch selects `dev:chrome` and receives the reserved host and port.
- Readiness rejects missing, stale or non-MV3 manifests and accepts a fresh valid unpacked manifest with a live process and listening port.
- Durable environment data does not present the extension as an ordinary local website.
- Existing unrelated worktree changes remain untouched.

## Proof contract

- Focused PowerShell regression suite for browser-extension behavior.
- Existing Windows project detection, dependency setup and environment schema suites.
- PowerShell parser proof and `git diff --check`.
- Real read-only classification of the ToolGlows checkout.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-08-26 22:02 UTC | sg-development | GPT-5 Codex | Resolved the approved ToolGlows clone follow-up into an explicit Windows browser-extension adapter contract. | Ready; current detector reproduced as `vite`. | Implement regression-first and verify locally. |
| 2026-08-26 22:20 UTC | sg-development | GPT-5 Codex | Implemented the bounded CRXJS adapter, pinned Corepack/pnpm execution, Manifest V3 readiness, extension environment/open behavior, regression coverage and mapped documentation. | Implemented locally. | Verify focused behavior and the real ToolGlows command plans. |
| 2026-08-26 22:20 UTC | 103-sg-verify | GPT-5 Codex | Passed focused extension, project catalog, monorepo, dependency, environment, start/stop, clone-filter, parser, metadata, skill-budget and diff checks; real ToolGlows is classified correctly and produces the expected Corepack and dev:chrome plans. | Partial: installed runtime and Chrome unpacked loading were not run. | Operator tests the installed Windows menu flow later. |
| 2026-08-27 09:31 UTC | sg-release | GPT-5 Codex | Ran the published full/runtime installer against the development branch and reproduced registry/environment drift: ToolGlows environment migrated to browser-extension while its registry entry remained vite. Added installer re-registration through the current detector and a focused stale-kind regression. | Repair implemented; republish, reinstall and replay required. | Commit and push the ShipGlows repair, rerun the official installer, then exercise ToolGlows through the installed CLI. |
| 2026-08-27 09:45 UTC | sg-release | GPT-5 Codex | Reinstalled the published registry repair, synchronized ToolGlows as browser-extension, pushed its modernization and environment commits, then started it through the installed `s` command. Dependency installation and MV3 generation succeeded; runtime tracing exposed a redundant pnpm option separator that left Vite on IPv6 loopback. | Second CLI repair implemented with focused regression. | Publish, reinstall and replay start/open/stop with the corrected IPv4 binding. |

## Current Chantier Flow

| Stage | Status | Evidence / next action |
| --- | --- | --- |
| Specification | complete | Behavior, exclusions and proof contract are bounded. |
| Readiness | complete | Target, authority, dirty-file exclusions and technical contract are resolved. |
| Implementation | complete | CRXJS detection, package-manager, launch, readiness, environment and open behavior are implemented with regression coverage. |
| Verification | partial | Official installation reproduced and repaired one stale-registry defect; republished installer and installed-CLI execution proof remain pending. |
| Closure | partial | Technical documentation is aligned; final runtime/browser evidence remains deferred to the operator. |
| Delivery | complete | Bounded local commit only; push and deployment remain explicitly excluded. |
