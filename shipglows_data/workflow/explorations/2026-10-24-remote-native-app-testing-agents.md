---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-24"
updated: "2026-10-24"
status: draft
source_skill: 700-sg-explore
scope: remote-native-app-testing-agents
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/external-platforms/appetize.md
  - shipglows_data/technical/external-platforms/e2b.md
  - shipglows_data/technical/flutter-configured-launch.md
  - cli/windows/ShipGlows.DevServer.psm1
depends_on: []
supersedes: []
evidence:
  - "Operator request 2026-10-15: find agent-drivable services to port and test native apps on Linux and iOS without a local environment."
  - "Operator decision 2026-10-24: persist the exploration and start implementing the services that offer a free tier."
  - "Windows host has no Mac; iOS Simulator builds (.app) can only be compiled on macOS, so iOS always needs a cloud Mac builder in front of a cloud simulator."
next_step: "Operator creates Appetize + E2B accounts/tokens into Doppler dotfiles/dev; then sg-development wires s remote-device commands"
---

# Exploration Report: Remote native-app testing for agents (iOS, Linux)

## Context

ShipGlows runs on a Windows host with Flutter and Tauri projects. The operator wants to port and test
these apps on iOS and Linux desktop without owning a Mac or a Linux workstation, and wants coding agents
(Claude Code, Codex) to drive the remote device themselves: build, install, tap, screenshot, read logs.

Two separate problems hide behind "iOS without a Mac":

1. Compiling an iOS build (`.app` for simulator, `.ipa` for devices) requires macOS + Xcode.
2. Running it requires an iOS Simulator, which also only runs on macOS.

Cloud services solve each half independently. Linux is simpler: any cloud Linux VM with a desktop and an
agent-facing screenshot/input API works, and Flutter Linux builds can be produced inside that same VM.

## Methods

- Web search through `shipglows-search` / `shipglows-parallel` (Firecrawl then Parallel), 2026-10-15 and 2026-10-24.
- Direct reads of vendor docs in Markdown (Appetize, Expo, E2B).
- Local checks: Node 24 available, `@appetize/cli` 0.25.1 and `@e2b/cli` 2.22.3 installed globally, Appetize Claude skill installed at user scope.

## Alternatives compared

### iOS: cloud simulator the agent can drive

| Service | Agent surface | Builds accepted | Free tier | Price after | Verdict |
| --- | --- | --- | --- | --- | --- |
| Appetize.io / Appetize AI | `appetize` CLI (headless, JSON), REST API, Claude skill via `appetize skill install`; iOS + Android | iOS simulator `.app` zipped, Android `.apk` | Free: 1 user, 2 devices, 30 min/month | Starter 59 $/mo (500 min then 0.06 $/min) | Start here |
| Expo EAS Simulator | `eas simulator:*`, `agent-device`, Argent, REST | any simulator `.app` / `.apk` (not Expo-only) | Limited-access preview, waitlist only | n/a | Join waitlist, revisit |
| Argent Cloud (Software Mansion) | `sim-remote` CLI (Linux/macOS), raw `simctl` over network | any simulator `.app` | none | 299 $/mo for 6 simulators | Later, when parallel CI needs it |
| Rented Mac (MacStadium, EC2 mac) + `serve-sim` / `ios-agent-cli` | SSH + Tailscale, full Xcode | anything, incl. native debugging | none | from ~109 $/mo | Only if native Swift debugging is required |

### iOS: cloud Mac builder (needed in front of any simulator service)

| Service | Flutter support | Free tier | Note |
| --- | --- | --- | --- |
| Codemagic | first-class Flutter workflows, macOS M-series runners | 500 build min/month free (to re-verify) | Simplest for Flutter, YAML in repo |
| EAS Build | any native project (Expo-first) | 15 iOS builds/month on Free | Pairs naturally with EAS Simulator |
| GitHub Actions macOS runner | generic | macOS minutes cost 10x | Operator policy: CI is manual and cost-controlled |
| Bitrise | Flutter steps | limited free credits | Not evaluated further |

### Linux: cloud desktop the agent can drive

| Service | Agent surface | Free tier | Price after | Verdict |
| --- | --- | --- | --- | --- |
| E2B Desktop sandbox | `@e2b/desktop` / `e2b-desktop` SDK: screenshot, click, type, VNC stream; `e2b` CLI for templates | Hobby: 100 $ one-time credit, 20 concurrent, 1 h continuous runtime | ~0.17 $/h for 2 vCPU + 4 GiB | Start here |
| Scrapybara | Ubuntu desktops for agents, similar API | credits on signup (not verified) | usage-based | Fallback |
| Self-hosted VM + xdotool/VNC | full control | none (VM cost) | VM cost | Later |

Flutter-specific helpers that work on any of the above once the app runs: `flutter-devtools-mcp`,
`fluttersdk/dusk` (VM Service driven tap/screenshot/hot reload, no pixel guessing).

## Evidence

- [You don't need a Mac to develop iOS apps](https://expo.dev/blog/build-ios-apps-on-windows-with-cloud-simulators) - Accessed 2026-10-15 - EAS Simulator accepts any simulator build (Flutter included) and is driven by `agent-device`; limited-access preview.
- [Expo Simulators usage, limits, and billing](https://docs.expo.dev/preview/eas-simulator/reference/usage-and-billing.md) - Accessed 2026-10-24 - confirms waitlist-only access, 40 min max session on Free.
- [How to test an iOS app without a Mac or an iPhone](https://expo.dev/articles/testing-and-previewing/test-ios-app-without-mac) - Accessed 2026-10-15 - frames the build/simulator split and the rented-Mac option.
- [Argent Cloud](https://argent.swmansion.com/cloud) and [Getting started](https://docs.swmansion.com/argent/docs/cloud/fundamentals/getting-started) - Accessed 2026-10-15 - 299 $/mo blocks, `sim-remote` CLI for Linux hosts.
- [Appetize AI](https://appetize.io/ai), [Appetize pricing](https://site.appetize.io/pricing) - Accessed 2026-10-15 - agent CLI/REST, Flutter listed, Free plan 30 min/month.
- [Appetize AI agents: getting started](https://docs.appetize.io/ai-agents/getting-started.md) and [Sessions](https://docs.appetize.io/ai-agents/sessions.md) - Accessed 2026-10-24 - CLI commands, `APPETIZE_API_TOKEN`, iOS flags, session logs.
- [E2B billing & limits](https://docs.e2b.dev/billing) and [E2B pricing](https://e2b.dev/pricing) - Accessed 2026-10-24 - Hobby 100 $ credit, 1 h continuous runtime, per-second billing.
- [E2B Desktop sandbox docs](https://docs.e2b.dev/use-cases/computer-use) - Accessed 2026-10-15 - desktop sandbox with screenshot/input API for computer-use agents.
- [harness](https://github.com/awizemann/harness), [ios-agent-cli](https://github.com/neoforge-dev/ios-agent-cli) - Accessed 2026-10-15 - open-source agent drivers that require a Mac; not applicable here.

## Risks and Unknowns

- Appetize CLI is in beta: commands and output may change between releases; the installed version is recorded in the platform note.
- iOS simulator builds cannot be produced on the Windows host; without Codemagic (or similar) the iOS lane is blocked at step one. Codemagic free minutes come from vendor pricing memory, not re-verified in this run.
- Free quotas are small (30 min/month Appetize, 100 $ one-time E2B). Agents must stop sessions explicitly; idle sessions burn quota.
- Secrets: `APPETIZE_API_TOKEN` and `E2B_API_KEY` must live in Doppler `dotfiles/dev` and be injected with `doppler run`, never exported in shell profiles or printed.
- Flutter desktop Linux needs the Linux toolchain inside the E2B template (clang, GTK, ninja); first template build time is unknown.
- Operator rules forbid local `flutter build` unless explicitly requested; Android APK uploads to Appetize therefore need an explicit build request or a cloud build.

## Recommendation

Phase 1 (free, started 2026-10-24): Appetize for iOS/Android device sessions, E2B Desktop for Linux.
CLIs and the Appetize Claude skill are installed. Remaining operator-only steps: create both accounts,
generate tokens, store them in Doppler `dotfiles/dev` as `APPETIZE_API_TOKEN` and `E2B_API_KEY`.

Phase 2: Codemagic free workflow producing a zipped iOS simulator `.app` per Flutter project, uploaded with
`appetize build upload`. Phase 3: `s` commands (`s remote-device start|screenshot|stop`) wrapping these CLIs
through the DevServer registry so sessions, logs and quotas are tracked like local sessions.

No implementation proof is included in this report; tool installation is recorded as environment evidence only.
