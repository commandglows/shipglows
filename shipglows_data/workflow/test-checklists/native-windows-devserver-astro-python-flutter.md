---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.8.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-16"
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
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - cli/windows/install-devserver.ps1
  - tests/windows/devserver-project-catalog.ps1
  - tests/windows/mobile-toolchain.ps1
  - tests/windows/agent-instructions.ps1
  - shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
depends_on:
  - artifact: shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
    artifact_version: "0.6.4"
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
- [x] Zero/one/many service needs select Firebase, FlutterFire, Supabase, Convex, Vercel, Clerk and Android-native review only from bounded explicit manifests.
- [x] Interactive x64 emulator acceptance, refusal, proven acceleration and uncertain acceleration resolve deterministically; uncertainty warns without suppressing the question, while non-interactive installs never prompt or infer consent.
- [x] Android terms and `sdkmanager --licenses` remain explicit; tests never pre-answer or execute them, and refusal/non-interactive plans remain pending.
- [x] Bounded Flutter/Dart/JDK/sdkmanager/adb/doctor/devices diagnostics distinguish healthy, `[!]`, `[X]`, license-pending and timeout states; only Flutter's exact positive `✓` or Windows `√` Android-toolchain marker plus accepted-license evidence is ready.
- [x] Windows Developer Mode is detected read-only and never activated by the installer.
- [x] Interactive Developer Mode guidance can open only `ms-settings:developers`; it never writes the registry and non-interactive execution stays pending.
- [x] Missing Codex, Claude, OpenCode, Kilo and Gemini CLIs use one grouped consent gate, exact package versions and executable verification; non-interactive execution installs none.
- [x] Firebase and Convex MCP definitions use exact resolved CLI versions; Clerk uses its official remote endpoint and GitHub uses the official read-only endpoint. Readiness is recorded per agent rather than hard-coded false, and no authentication is started.
- [x] The installer resolver prefers an existing `.jsonc` over `.json`; comments, unrelated MCP data and secrets remain byte-identical, no secret-bearing backup is created and the result is explicitly pending.
- [x] OpenCode v2 plans exact `mcp.servers`; Kilo plans official `kilo` and detects `kilocode` compatibility; Playwright is omitted without proven Chromium and rejects mutable versions.
- [x] Fresh/existing/partial plans cover external-tool reuse, managed quarantine, x64 rejection before downloads, centralized Android 36 platform/build-tools/system-image coordinates and AVD.
- [x] Supply-chain fixtures cross-check the current SHA-1-only Android repository coordinate against the matching Windows filename and complete SHA-256 from the official Android Studio download table, fail closed on disagreement, and reject ZIP traversal and symlink/reparse entries before extraction; service CLI plans reject mutable versions.
- [x] Android archive download announces resolved version/size and checksum/extraction milestones, with a visible curl progress bar, three bounded retries and partial-transfer resume.
- [x] Real Shadow validation accepted all seven Android licenses and installed Android SDK/platform/build-tools 36; the exact Windows `√` marker, timing suffix and bullet-prefixed license evidence now produce `toolchain=True`, `licenses=True`, while no Android device correctly remains separate as `device=False`.
- [x] Real Shadow emulator validation installed the emulator, Android 36 Google APIs x86_64 image and `ShipGlows_API_36`; both `emulator -list-avds` and `flutter emulators` list it. `-accel-check` exits 3 because Shadow exposes no usable virtualization extensions, and two bounded software starts remained black/`offline` without `sys.boot_completed`, so the AVD is installed but honestly not device-ready on this host.
- [x] Complete/partial emulator fixtures require the executable, exact Android 36 image package, and named AVD together; a complete interactive rerun skips the emulator question and provisioning, while a partial state remains an explicit repair choice.
- [x] Real Shadow rerun from commit `979a160` detected the complete emulator/image/AVD state, printed that the emulator question was skipped, performed no emulator provisioning download, retained `toolchain=True`, `licenses=True`, `device=False`, and completed successfully.
- [x] Already accepted licenses converge through a bounded probe whose only fallback input is `n`; non-interactive reruns can continue without replaying or synthesizing consent.
- [x] PowerShell 5.1 transport preserves argument boundaries for EXE and CMD/BAT across spaces, Unicode, quotes, `&`, `%` and `;`; interactive execution and timeout/tree-stop paths are covered.
- [x] Service scanning excludes reparse directories and reports its bounded-directory limit.
- [x] Automated proof uses temporary fixtures only and performs no package download, elevation, registry mutation, Developer Mode change, authentication or user-project write.
- [x] Authentication fixtures cover five agents and supported services, redact status output, preserve project-scoped Convex, use native Gemini interaction, and forbid token/key/secret arguments.
- [x] Playwright planning keeps stable CLI, agent CLI and MCP ownership separate, pins exact versions, binds stable Chromium revision, and exposes motion readiness independently.
- [x] Real Shadow proof resolves stable Playwright `1.62.1` with Chromium revision `1234`, agent CLI `0.1.18`, MCP Chromium revision `1237`, launches and closes an agent-CLI browser session, and captures one synthetic no-network WebM with `motion_status=captured` before deleting the temporary corpus.
- [ ] Complete only operator-selected authentication flows through `s a`; ShipGlows must not infer an account choice, read credentials, or persist status-command output.
- [x] Multi-agent instruction fixtures prove the exact Codex, Claude, OpenCode, Kilo and Gemini global paths, detected-agent filtering, foreign Unicode/newline preservation, managed-block replacement, fail-closed malformed markers, atomic temp cleanup and byte-idempotent reruns.
- [ ] Run full installation on a fresh Windows target and record accepted/refused license outcomes, exact resolved versions and readiness fields.
- [ ] Validate `ShipGlows_API_36` through `adb` and `flutter devices` on a host that exposes nested virtualization; Shadow software-mode failure is already recorded.
- [ ] Validate MCP convergence in real Codex, Claude, OpenCode v2, Kilo and Gemini configs, including existing JSONC and Gemini settings files.

## Windows IDE and Firebase entry-point proof

- [x] Plan fixtures cover both IDEs absent, one present, both present, refusal and non-interactive execution; only missing outcomes are selected.
- [x] Android Studio detection requires a real `studio64.exe`; Visual Studio readiness requires both a Community instance and `Microsoft.VisualStudio.Workload.NativeDesktop` through `vswhere`.
- [x] Static contract pins the official WinGet package IDs, native desktop workload, recommended components and `--norestart`, and rejects Firebase login/auth automation.
- [x] Real Shadow installation provides Android Studio build `AI-261.26222.65.2613.15948027` and Visual Studio Community 2022 `17.14.38` with the native desktop workload.
- [x] Real `flutter doctor -v` reports Android, Visual Studio Community 2022, Chrome and connected Windows/web devices healthy, with `No issues found`.
- [x] Existing Flutter 3.44.9, JDK 17, Android SDK/build-tools 36, accepted licenses, emulator package and `ShipGlows_API_36` were preserved; Windows was not restarted automatically.
- [x] Published-main rerun resolved commit `2d354118770008df997eda57b19d7ca6299f087c`, skipped the complete Android Studio/Visual Studio question and heavy downloads, and recorded IDE readiness plus user-owned Firebase pending state in `%USERPROFILE%\.shipglows\environment.md`.
- [ ] Open Android Studio once, keep the existing SDK, sign in personally, choose a Firebase project and confirm the Firebase Device Streaming surface. No automation may accept billing or reserve a device.
