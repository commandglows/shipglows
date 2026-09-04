---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "3.9.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-09-04"
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
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "2026-09-04: a Rio-hosted standalone Codex CLI exposed the Computer Use skill and Node REPL but no native pipe; process presence and discovery did not prove Desktop transport reachability."
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

## Execution Envelope

Every `$shipglows context` report begins by resolving the current **execution envelope**. When the read-only shell is callable, run `$SHIPGLOWS_ROOT/tools/agent_runtime_envelope.py --format json`; otherwise derive only fields supported by current-turn evidence and retain `unknown` explicitly. Report:

- operating system;
- agent surface, such as `codex-desktop`, `codex-cli`, IDE, cloud, or unknown;
- terminal host, such as Rio, Windows Terminal, VS Code, Codex Desktop, or unknown;
- session location: local, remote, WSL, CI, or unknown;
- machine kind: physical-or-undetected, virtual-machine, container, or unknown.

Process names are evidence, not capability proof. A running `codex.exe` launched through Node from Rio or another terminal is a **standalone Codex CLI**, not Codex Desktop. A packaged Desktop ancestor is required before classifying the session as Desktop-hosted. Never infer a VM or local session merely from Windows being installed.

Computer Use has an additional transport boundary. Keep `plugin installed`, `skill discovered`, `Node REPL exposed`, `native transport reachable`, and `safe probe succeeded` as separate facts. A standalone Codex CLI can expose the skill and `@oai/sky` while the Desktop native pipe is absent. In that case classify Computer Use as `failed — native transport not provided by this agent surface`; restarting the same CLI or terminal is not a recovery. The supported recovery is to run the GUI-dependent task from Codex Desktop, where the Computer Use server and skill toggles can create the native pipe, or to select another task-appropriate proof surface. Even in Codex Desktop, report only `expected-but-must-probe` until a safe call such as `list_apps` succeeds.

Before work depends on a local server or runtime-specific tool on Windows:

1. Read `%USERPROFILE%\.shipglows\environment.md` for the global development environment.
2. Resolve the registered project and **managed surface** from the current directory and requested target. Read the selected entry's `launchPath\ENVIRONMENT.md` when present; otherwise read its `rootPath\ENVIRONMENT.md`. Do not claim that the project lacks `ENVIRONMENT.md` when the selected managed surface owns one.
3. Read the matching entry in `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json` for live `running`, `starting`, `stopped`, or `error` status.
4. Use the assigned URL only while that registry entry is `running` or `starting`.

The registry entry's current `status` is authoritative for live state. `flutterStartupState`, retained daemon IDs, PIDs, start times, cached observations, and earlier conversation reports are supporting evidence only. They never override `status: stopped` or `status: error`. Re-read the matching registry entry immediately before a runtime-dependent verdict and after any start, stop, restart, reload, failed probe, or contradictory observation.

Do not derive the URL from `package.json`, framework defaults such as Astro/Vite `4321`, a remembered port, or another project. `.shipglows.env` remains the optional committed runtime-policy file; it is not the environment summary or live-state authority.

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

`FLUTTER-LIVE-DEVELOPMENT`: ordinary Flutter implementation and debugging use the managed `flutter run` session for the selected target. It is the normal development loop because it keeps logs and reload available. On Android, honor an explicitly configured connected device; otherwise reuse a ready Android emulator or start the provisioned `ShipGlows_API_36` AVD and wait for Flutter device readiness. Do not create a release build merely to expose an iterative correction. Use a standalone build only for an explicit release checkpoint or targeted proof that depends on packaging, native plugins or DLLs, installation, production-mode behavior, performance, or startup without Flutter attached.

`LATEST-BUILD-ACCESS`: after a successful Windows release or Android APK build,
or after observing a successful trusted CI build with a named complete artifact,
load `skills/references/latest-build-artifact-access.md`. Publish the validated
output through `cli/windows/shipglows-build-artifacts.ps1`, keep Local and CI
lanes separate, and report the refreshed shortcut name. A failed build or unsafe
artifact keeps the prior last-known-good lane; never launch or install it
automatically. Linux, macOS, and iOS outputs retain their host-specific limits.

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
- `transport reachable`: the native pipe, socket, browser service, MCP connection, or equivalent provider channel accepted a safe connection;
- `callable`: a safe probe or requested call succeeded in this turn;
- `failed`: discovery succeeded but the call failed; retain the exact runtime error;
- `not exposed`: configuration is known but neither direct nor deferred discovery found a callable surface.

Absence from the first visible tool list is not proof of `not exposed`. If Chromium is installed and the Playwright MCP is configured but remains undiscovered after all host-supported discovery, report `Playwright configuré, outil non exposé dans ce tour`; never call Python, Chromium, or Playwright absent solely because no matching tool was visible initially.

## Targeted Refresh And Recovery

An observed contradiction, runtime state transition, native pipe/socket failure, stale snapshot, missing selected-surface file, or failed safe probe invalidates the dependent claims. Perform a **targeted refresh** of the execution envelope, selected managed surface, matching registry entry, and affected tool transport before reporting; do not reload unrelated repository context. If the refreshed evidence still conflicts, stop only the dependent action and report the exact layers and values.

Exhaust safe read-only diagnosis before returning work to the operator. Never use a vague restart instruction such as "restart Codex" or "reactivate the connector". Name the exact host or service that owns recovery, explain why that action can recreate the missing transport, and do not recommend restarting a standalone Codex CLI when the required native pipe belongs to Codex Desktop. Do not launch a second server to guess the URL. Durable assignment comes from the selected managed surface's `ENVIRONMENT.md`; live state comes from the registry.

Operator redirect:

```text
Lance `$shipglows context`. Lis %USERPROFILE%\.shipglows\environment.md,
<racine-projet>\ENVIRONMENT.md et l'état live du registre ShipGlows. Utilise
uniquement l'URL attribuée à ce projet et les outils exposés par le tour courant.
```
