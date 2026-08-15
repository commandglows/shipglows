---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: native-windows-devserver-project-catalog-and-flutter-android
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/install-devserver.ps1
  - tests/windows/devserver-project-catalog.ps1
  - tests/windows/mobile-toolchain.ps1
  - shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
depends_on:
  - artifact: shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
    artifact_version: "0.5.0"
    required_status: draft
supersedes: []
evidence:
  - "Regression-first project catalogue test failed on the missing Get-SgProjectCatalog command before implementation."
  - "The Windows static contract and isolated catalogue fixtures passed on 2026-08-15."
  - "Final five-run workspace benchmark medians passed at 902.05 ms cold and 31.96 ms warm using temporary registry/index state."
next_step: "/103-sg-verify native Windows project catalogue on installed runtime after shipping"
---

# Native Windows DevServer project catalogue checklist

## Automated catalogue proof

- [x] Zero, one, many, and homonymous leaf-folder catalogues resolve deterministically.
- [x] One bounded linear scan discovers monorepo launch surfaces without rescanning descriptors at each boundary.
- [x] Canonical `launchPath` identity deduplicates root/launch entries across case and trailing-slash variants.
- [x] Workspace-relative `/` display names are unique; outside-workspace names remain canonical paths.
- [x] Navigation projects only `Name`; lifecycle menus retain action-relevant status, kind, and port fields.
- [x] Picker labels map to exact identities instead of selecting the first equal label.
- [x] A `package.json` without `scripts.dev`, including empty dependency blocks under StrictMode, is ignored.

## Cache and invalidation proof

- [x] In-process and fresh-module reads reuse the five-minute persistent index.
- [x] Refresh forces a rebuild; register and unregister invalidate memory and persistent state; clone uses the same invalidation API.
- [x] Schema, workspace, scanner-version, and exact TTL boundary mismatches rebuild the index.
- [x] Corrupt JSON and moved/deleted surfaces are rejected without becoming authoritative.
- [x] Concurrent forced writers leave one valid atomically replaced index.
- [x] Registry entries win discovery conflicts for status, port, logs, and process metadata.

## Performance and safety

- [x] Five cold scans: `894.72`, `920.59`, `942.56`, `894.90`, `902.05` ms; median `902.05` ms, target `<1000` ms.
- [x] Five warm reads: `31.96`, `31.96`, `31.81`, `31.80`, `36.09` ms; median `31.96` ms, target `<200` ms.
- [x] Fixtures and benchmark use temporary runtime, registry, logs, and project-index paths only.
- [x] No user server, installed runtime, live registry, install, bootstrap, commit, or push is part of this proof.

## Flutter Android full-install proof

- [x] Regression-first test failed on the missing mobile-toolchain module before implementation.
- [x] Zero/one/many service needs select Firebase, FlutterFire and Supabase only from explicit manifests.
- [x] Supported emulator acceptance, refusal, unsupported hosts and non-interactive installs resolve deterministically; unsupported/non-interactive paths never ask the emulator question.
- [x] Android terms and `sdkmanager --licenses` remain explicit; tests never pre-answer or execute them, and refusal/non-interactive plans remain pending.
- [x] Bounded Flutter/Dart/JDK/sdkmanager/adb/doctor/devices diagnostics distinguish healthy, `[!]`, `[X]`, license-pending and timeout states; only the exact positive Android toolchain marker plus accepted-license evidence is ready.
- [x] Windows Developer Mode is detected read-only and never activated by the installer.
- [x] The installer resolver prefers an existing `.jsonc` over `.json`; comments, unrelated MCP data and secrets remain byte-identical, no secret-bearing backup is created and the result is explicitly pending.
- [x] OpenCode v2 plans exact `mcp.servers`; Kilo plans official `kilo` and detects `kilocode` compatibility; Playwright is omitted without proven Chromium and rejects mutable versions.
- [x] Fresh/existing/partial plans cover external-tool reuse, managed quarantine, x64 rejection before downloads, centralized Android 36 platform/build-tools/system-image coordinates and AVD.
- [x] Supply-chain fixtures cross-check the current SHA-1-only Android repository coordinate against the matching Windows filename and complete SHA-256 from the official Android Studio download table, fail closed on disagreement, and reject ZIP traversal and symlink/reparse entries before extraction; service CLI plans reject mutable versions.
- [x] PowerShell 5.1 transport preserves argument boundaries for EXE and CMD/BAT across spaces, Unicode, quotes, `&`, `%` and `;`; interactive execution and timeout/tree-stop paths are covered.
- [x] Service scanning excludes reparse directories and reports its bounded-directory limit.
- [x] Automated proof uses temporary fixtures only and performs no package download, elevation, registry mutation, Developer Mode change, authentication or user-project write.
- [ ] Run full installation on a fresh Windows target and record accepted/refused license outcomes, exact resolved versions and readiness fields.
- [ ] Validate a real phone on Shadow; validate an emulator only on a host where nested virtualization and `-accel-check` succeed.
- [ ] Validate MCP convergence in real Codex, Claude, OpenCode v2 and Kilo configs, including an existing JSONC file.
