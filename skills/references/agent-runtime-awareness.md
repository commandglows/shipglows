---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "3.5.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-23"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.AgentInstructions.psm1
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
  - "The Windows installer writes the global development environment file."
  - "Each managed project exposes its durable assigned URL in a visible, versioned ENVIRONMENT.md file."
  - "The Windows DevServer registry remains the live status authority."
  - "A Playwright MCP false negative on 2026-08-14 showed that direct tool listings can omit callable tools retained in the host's deferred catalog."
  - "The Windows installer atomically projects this stable discovery contract into each detected agent's native global instruction file while dynamic facts remain in environment.md."
next_review: "2026-09-13"
next_step: "/103-sg-verify Windows runtime awareness"
---

# Agent Runtime Awareness

Before work depends on a local server or runtime-specific tool on Windows:

1. Read `%USERPROFILE%\.shipglows\environment.md` for the global development environment.
2. Resolve the registered project root from the current directory and read `<project-root>\ENVIRONMENT.md` for its durable ShipGlows-assigned URL.
3. Read the matching entry in `%LOCALAPPDATA%\ShipGlows\DevServer\registry.json` for live `running`, `starting`, `stopped`, or `error` status.
4. Use the assigned URL only while that registry entry is `running` or `starting`.

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

Absence from the first visible tool list is not proof of `not exposed`. If Chromium is installed and the Playwright MCP is configured but remains undiscovered after all host-supported discovery, report `Playwright configuré, outil non exposé dans ce tour`; never call Python, Chromium, or Playwright absent solely because no matching tool was visible initially.

If a source is missing or contradicts another source, stop only the dependent action and report the mismatch. Do not launch a second server to guess the URL. Durable assignment comes from `ENVIRONMENT.md`; live state comes from the registry.

Operator redirect:

```text
Lance `$shipglows context`. Lis %USERPROFILE%\.shipglows\environment.md,
<racine-projet>\ENVIRONMENT.md et l'état live du registre ShipGlows. Utilise
uniquement l'URL attribuée à ce projet et les outils exposés par le tour courant.
```
