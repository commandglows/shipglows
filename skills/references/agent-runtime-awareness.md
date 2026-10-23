---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "3.14.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-10-23"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - tools/agent_runtime_envelope.py
  - tools/test_agent_runtime_envelope.py
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - cli/windows/shipglows-devserver.ps1
  - tests/windows/agent-instructions.ps1
  - cli/install.sh
  - skills/000-shipglows/SKILL.md
  - skills/301-sg-context/SKILL.md
  - skills/sg-development/SKILL.md
  - skills/sg-engineering/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/010-sg-technical/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - plugins/shipglows/skills/shipglows/SKILL.md
depends_on:
  - artifact: "skills/references/latest-build-artifact-access.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "The Windows CLI publishes a bounded shipglows.cli-capabilities.v1 snapshot that conversations may inspect without starting the CLI."
  - "The Windows installer writes the global development environment file."
  - "Each managed project exposes its durable assigned URL in a visible, versioned ENVIRONMENT.md file."
  - "The Windows DevServer registry remains the live status authority."
  - "A Playwright MCP false negative on 2026-08-14 showed that direct tool listings can omit callable tools retained in the host's deferred catalog."
  - "The Windows installer atomically projects this stable discovery contract into each detected agent's native global instruction file while dynamic facts remain in environment.md."
next_review: "2026-09-13"
next_step: "/103-sg-verify Windows runtime awareness"
---

# Agent Runtime Awareness

## Host Observation

When host identity affects a decision, record operating system, agent surface,
terminal host, session location and machine kind from current evidence. Keep
unknown values explicit. Only where script execution is authorized, the helper
`tools/agent_runtime_envelope.py --format json` can provide bounded ancestry
hints. Do not run it on a no-local-workload host; use available session evidence.
Its output is not proof of Desktop identity, native transport or tool callability.
It exports no process paths or command lines. A missing SSH or CI marker proves
neither a local session nor a physical machine. Transport reachability requires
separate authorized current-turn evidence; never recommend a restart solely
from a process-name hint. Helper tests and Windows observation remain subject
to validation in a separate development environment.

Before work depends on a local server or runtime-specific tool on Windows:

1. Read `%USERPROFILE%\.shipglows\environment.md` for the global development environment.
2. Resolve the registered project and selected managed surface from the current directory and requested target. Read that entry's `launchPath\ENVIRONMENT.md` when present, otherwise its `rootPath\ENVIRONMENT.md`; for legacy entries use the registered `path`. A missing root-level summary does not prove the selected surface lacks one. If multiple entries match and the requested target does not distinguish them, retain the ambiguity rather than using another surface's URL.
3. Read the matching entry in `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json` for live `running`, `starting`, `stopped`, or `error` status. An entry lists one record per run target in `sessions` (Tauri `windows`/`android`, Flutter `windows`/`android`/`chrome`/`web-server`, `web`, `chrome` or `obsidian` otherwise), each with its own `status`, `port`, `portRole`, `startedAtUtc`, logs and `lastEvent`; the entry's top-level fields mirror its primary session only. `s status -ProjectPath <path> [-Json]` shows the same per-target view.
4. Use the assigned URL only while the session of the requested target is `running` or `starting`.

Starting a target never replaces another one: Flutter and single-target surfaces run their targets side by side, and a second Tauri target refuses to start until the operator chooses `-Frontend shared` (attach to the running frontend), `-Frontend own` (its own port) or `-Replace`. Pass the target (`-TauriDevice`, `-FlutterDevice`) to `stop`, `restart`, `reload`, `logs` and `open`; without it they act on every target. A replaced or cascaded target keeps the reason in its `lastEvent`.

The matching entry's current `status` is the live-state authority. Retained
PIDs, daemon IDs, `flutterStartupState`, timestamps and earlier observations
never override `stopped` or `error`. Missing or unrecognized status remains
unknown. Re-read the matching entry before a runtime-dependent verdict and
after a state transition, failed probe or contradictory observation; reading
the registry must not start the CLI or an application.

Do not derive the URL from `package.json`, framework defaults such as Astro/Vite `4321`, a remembered port, or another project. `.shipglows.env` remains the optional committed runtime-policy file; it is not the environment summary or live-state authority.

For startup diagnostics, read the target session's `logPath` and `errorLogPath`
(plus `setupLogPath`). Each launch writes under
`%LOCALAPPDATA%\ShipGlows\DevServer\logs\<name>-<path-hash>\<target>\<yyyyMMdd-HHmmss>-<id>\`
(the five latest launches per target are kept), so two targets or two launches
never overwrite each other's logs; files directly under `<name>-<path-hash>\`
or a folder named after the bare display name belong to older sessions. A web readiness timeout is configured through `.shipglows.env`
(`SHIPGLOWS_READY_TIMEOUT_SECONDS`, see `project-runtime-policy.md`).

Report runtime capabilities from the global file before attempting tool discovery:

- report Python as available through `uv` when its detected version, manager, and `python` / `python3` commands are recorded;
- report Playwright Chromium as installed when its installation flag and executable path are recorded;
- report the Playwright MCP as configured and verified only when the global file records those facts, including its Codex config path.

## Mobile And Windows Toolchain Decisions

`MOBILE-RUNTIME-CONTEXT`: when work targets Flutter, Android, Windows desktop,
or Firebase Device Streaming, report the relevant recorded fields before
choosing a build, test, or device route:

- `Flutter and Dart installed`;
- `Android toolchain ready` and `Android licenses ready`;
- `Android device ready`;
- `Android emulator installed`;
- `Android virtual device ready` (the installed Android virtual device (AVD));
- `Android emulator acceleration ready`;
- `Android next action` as the Exact next action;
- `Android Studio installed`;
- `Visual Studio Desktop C++ workload ready`;
- `Flutter Windows desktop toolchain ready`;
- `Firebase Android Device Streaming configured`;
- `Firebase Android Device Streaming next action` as the Exact next action.

`FLUTTER-WINDOWS-CONSUMER`: a Flutter Windows desktop build is ready only when
`Flutter Windows desktop toolchain ready` is `yes`. That aggregate requires a
validated Flutter/Dart SDK, the Visual Studio Desktop C++ workload, and Windows
Developer Mode. Keep the separate Visual Studio field visible so host compiler
readiness is not confused with end-to-end Flutter build readiness. Android
readiness does not prove the Windows prerequisites.

`FLUTTER-CACHE-TRANSITION`: never classify a validated SDK as incomplete from
one missing `dart.exe` snapshot while Flutter may be replacing its cache. Treat
an active Flutter process, a changing cache stamp, or a held Flutter lock as a
transient cache replacement; wait for the bounded operation to settle, then
revalidate with the SDK's `flutter --version` and `dart --version`. Report
`failed` only when executable validation still fails after the transition, and
distinguish a persistent `PATH` omission from SDK corruption.

`ANDROID-DEVICE-DECISION`: distinguish SDK readiness, licenses, emulator
installation, AVD creation, acceleration, and a ready device.
An installed AVD without acceleration and without a ready device is not a runnable Android target.
Use the recorded `Android next action`; valid routes can include fixing local
acceleration, connecting a physical device, or using a hosted device.

`FIREBASE-DEVICE-STREAMING-BOUNDARY`: Android Studio being installed provides
an entry point; it does not mean Firebase Device Streaming is configured.
Firebase Device Streaming authentication, project selection, billing, and device reservation remain user-owned
and must never be automated. Report the recorded Firebase state and exact next
action without claiming a hosted device is callable until the current turn proves it.

`FLUTTER-LIVE-DEVELOPMENT`: ordinary Flutter implementation and debugging use the managed `flutter run` session for the selected target. It is the normal development loop because it keeps logs and reload available. On Android, honor an explicitly configured connected device; otherwise reuse a ready Android emulator or start the provisioned `ShipGlows_API_36` AVD and wait for Flutter device readiness. Do not create a release build merely to expose an iterative correction. For performance measurement with Flutter attached, use the managed profile session (`s start -ProjectPath <p> -FlutterDevice <device> -FlutterMode profile`; the registry records `flutterMode`, profile sessions support neither hot reload nor hot restart, so `s restart … -FlutterMode profile` rebuilds them) instead of a hand-run `flutter run --profile` or `flutter drive --profile`; debug-mode numbers are not performance evidence and no managed session uses `--release`. Use a standalone build only for an explicit release checkpoint or targeted proof that depends on packaging, native plugins or DLLs, installation, production-mode behavior, or startup without Flutter attached.

`FLUTTER-CONFIGURED-LAUNCH`: a short request such as "lance l'app Windows en mode dev" or "lance le build web" includes the project's declared authentication and service configuration. Resolve target and mode from durable evidence; use the project recipe and its declared Doppler scope without asking the operator to repeat technical setup. The Windows manager reads `.shipglows.flutter.json`, runs its allowlisted public configuration resolver through Doppler, transfers frontend parameters to Dart and native parameters to Gradle, and revalidates the configuration fingerprint before reusing a session. Missing configuration blocks before replacing a running session. Never replace the recipe with a bare Flutter command, a bypass or an older artifact. The project's build entrypoints must use the same resolver. See `cli/windows/ShipGlows.FlutterConfiguration.ps1` and `shipglows_data/technical/flutter-configured-launch.md` for the bounded recipe contract. Distinguish configuration checked, process running, interactive login verified and protected API access verified; compilation or `app.started` alone proves neither login nor product access.

## Required backend information

`APP-BACKEND-LAUNCH-GUARD`: before launching, restarting or reusing a managed
application session, or executing a test that needs its backend, inspect the
selected surface's `.shipglows.backend.json`, existing launch recipes and relevant
project documentation. Apply this to existing and future projects. Do not request
backend information for an unrelated documentation edit, static check or isolated
unit test that does not consume it.

Resolve the provider, local/remote mode, authorized local command, dependency
inputs and readiness check from current project evidence. A provider SDK in a
lockfile, a remembered URL or a running frontend does not establish that contract.
If required information remains absent, ambiguous or inaccessible after focused
inspection, ask the operator one concise question naming only the missing facts
and why the requested launch or test needs them. Do not ask for facts already
established or request secret values. Continue independent work while awaiting the
answer; block only the dependent launch, restart, reuse or test and preserve any
existing session.

Never invent a provider, command, environment, endpoint or implicit no-backend
exception. Under the Windows DevServer contract, the manifest must exist, validate
and establish readiness before any replacement stop. When project evidence fully
resolves a missing manifest, create it only within authorized configuration work;
otherwise explain that the declaration still needs to be written. An operator
answer supplies information, not permission for unrelated project changes, account
setup or provider operations. Projects genuinely without a backend require an
explicit `mode: none` manifest with a project-specific reason; absent files or
unavailable services do not justify that exception. A malformed manifest or an
unavailable declared backend requires diagnosis, not a fallback to `none`.

Use `shipglows_data/technical/operator-guides/windows-devserver.md` for the exact
manifest contract when preparing configuration. Revalidate the backend fingerprint
and readiness before session reuse. Report backend readiness, user login and
protected API access separately; none substitutes for either of the others.

`APP-AUTH-LAUNCH-GUARD`: existing project authentication is mandatory for normal launches and tests; never disable it, add a bypass, or use a stale artifact to make startup pass. An auth-free local development run is permitted only when project evidence establishes that authentication is not yet implemented and the tested surface exposes no protected data; state that exception explicitly. Missing, broken or misconfigured existing auth blocks the normal launch and requires diagnosis, not an automatic exception. A login screen proves only that the screen renders. When end-to-end validation is requested, continue through login and protected access using authorized test context, or report the exact remaining proof and user-only step without claiming the application fully verified.

`LATEST-BUILD-ACCESS`: after a successful Windows release or Android APK build,
or after observing a successful trusted CI build with a named complete artifact,
load `skills/references/latest-build-artifact-access.md`. Publish the validated
output through `cli/windows/shipglows-build-artifacts.ps1`, keep Local and CI
lanes separate, and report the cached artifact path. Once that registered build
has been tested, delete the raw release output left in the checkout
(`build\windows\x64\runner\Release`, `build\app\outputs`); the cache keeps the
last two validated generations per lane. Build publication never creates a
Desktop shortcut.

`DEV-SHORTCUT-OWNERSHIP`: only `shipglows-dev start` creates Desktop shortcuts,
named `<repository>-<surface> - Dev`, for live Tauri, web and Flutter dev servers
of a main checkout. Never create, copy or edit a Desktop shortcut by hand, and
never for a build artifact, a Python API or a Git worktree. A missing shortcut is
a DevServer gap to report, not a reason to improvise one.
A failed build or unsafe artifact keeps the prior last-known-good lane; never
launch or install it automatically. Linux, macOS, and iOS outputs retain their
host-specific limits.

Keep installation, configuration, discovery, and callability distinct. ChatGPT apps/connectors and Codex CLI tools are separate surfaces. The global file describes what ShipGlows installed or configured, while the current host turn decides what can be called.

Windows full projects this stable rule into bounded blocks in the native global
instruction files for detected Codex, Claude, OpenCode, and Kilo agents. It must
not copy the current tool inventory into those files: machine facts stay in
`%USERPROFILE%\.shipglows\environment.md`, while the current turn remains the
authority for discovery and callability. Existing instructions outside the
managed block are preserved.

## Current-Turn Capability Discovery

When the question depends on capabilities actually exposed by the native Windows CLI, read `%LOCALAPPDATA%\ShipGlows\DevServer\cli-capabilities.v1.json`, or the absolute `SHIPGLOWS_CLI_CAPABILITIES_FILE` override when one is explicitly present. Bound the read to 64 KiB; accept only `shipglows.cli-capabilities.v1`, canonical UTC timestamps, the closed capability identifiers and states, and snapshots no older than 15 minutes or more than one minute in the future. Missing, malformed, oversized, stale, or future evidence is unavailable. Reading the snapshot is the conversational path and must never start the CLI or infer a free-form command surface.

Before declaring a configured tool unavailable:

1. inspect tools exposed directly by the current turn;
2. inspect the host's deferred or searchable tool catalog when one exists, such as `ALL_TOOLS`, `tool_search`, or an equivalent discovery surface;
3. match the provider namespace and operation, not only a friendly display name; Playwright MCP tools normally use `mcp__playwright__*`;
4. when the dependent action is safe and the candidate was discovered, run the smallest read-only probe, such as listing browser tabs;
5. classify the result as `callable` only after a safe probe or the requested action succeeds; direct exposure or deferred discovery alone establishes only `discovered`.

Use these exact state meanings:

- `installed`: the executable/runtime evidence exists;
- `configured`: an integration entry exists and passed its configuration verification;
- `discovered`: the current host exposes the tool directly or through its deferred/searchable catalog;
- `callable`: a safe probe or requested call succeeded in this turn;
- `failed`: discovery succeeded but the call failed; retain the exact runtime error;
- `not exposed`: configuration is known but neither direct nor deferred discovery found a callable surface.

External web search follows `web-research-fallback.md`: a provider that fails or runs out of credits hands over to the next one, ending with the agent's native search.

Absence from the first visible tool list is not proof of `not exposed`. If Chromium is installed and the Playwright MCP is configured but remains undiscovered after all host-supported discovery, report `Playwright configuré, outil non exposé dans ce tour`; never call Python, Chromium, or Playwright absent solely because no matching tool was visible initially.

If a source is missing or contradicts another source, refresh only the selected
surface's summary, matching registry entry and affected current-turn capability
evidence. If the mismatch persists, stop only the dependent action and report
the conflicting sources. Do not launch a second server to guess the URL or
recommend a generic restart without evidence of the component that needs it.
Durable assignment comes from the selected surface's `ENVIRONMENT.md`; live
state comes from its registry entry.

Operator redirect:

```text
Lance `$shipglows context`. Lis %USERPROFILE%\.shipglows\environment.md,
le fichier ENVIRONMENT.md de la surface sélectionnée et son entrée live du registre ShipGlows. Utilise
uniquement l'URL attribuée à ce projet et les outils exposés par le tour courant.
```
