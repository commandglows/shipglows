---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-24"
updated: "2026-10-24"
status: draft
source_skill: sg-docs
scope: external-platform-e2b
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/workflow/explorations/2026-10-24-remote-native-app-testing-agents.md
  - shipglows_data/technical/external-platforms/doppler.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Vendor docs read on 2026-10-24: billing & limits, pricing, desktop sandbox use case."
  - "Installed on the Windows host on 2026-10-24: @e2b/cli 2.22.3 (global npm); @e2b/desktop 2.5.0 available on npm."
next_review: "2026-11-24"
next_step: "/sg-docs technical audit"
---

# E2B Platform Note

## Purpose

E2B provides Firecracker-isolated Linux sandboxes billed per second, including a Desktop variant with an
Xfce session, screenshot and mouse/keyboard API, and a VNC stream. ShipGlows uses it as the Linux desktop
lane: build and run Flutter Linux (or Tauri Linux) inside the sandbox and let an agent drive the window.

## Source Map

| Need | Source |
| --- | --- |
| Billing and limits | https://docs.e2b.dev/billing |
| Pricing | https://e2b.dev/pricing |
| Desktop sandbox / computer use | https://docs.e2b.dev/use-cases/computer-use |
| Desktop template example | https://docs.e2b.dev/template/examples/desktop |
| Desktop SDK (JS) | https://www.npmjs.com/package/@e2b/desktop |
| Desktop SDK (Python) | https://pypi.org/project/e2b-desktop/ |
| CLI | https://docs.e2b.dev/cli |

Freshness evidence on 2026-10-24:

- Hobby plan: 0 $/month, 100 $ one-time credit, 20 concurrent sandboxes, 1 h max continuous runtime (pause resets it), 10 GiB storage, no card required.
- Usage: 0.0504 $ per vCPU-hour, 0.0162 $ per GiB-hour; a 2 vCPU / 4 GiB sandbox costs about 0.17 $/h.
- Custom templates are built from a Dockerfile with `e2b template build`; the Flutter Linux toolchain (clang, cmake, ninja, GTK 3 dev) must be baked into the template.

## Secrets and Boundaries

- `E2B_API_KEY` lives in Doppler `dotfiles/dev`; run `doppler run --project dotfiles --config dev -- e2b …` or SDK scripts the same way. Never print it.
- Account creation and API key generation are operator-only (console.e2b.dev).
- Sandboxes are billed while running: always kill or pause them when the check is done; set a timeout at creation.

## ShipGlows Decision Rules

- Use E2B Desktop only for GUI proof (screenshots, interaction). Pure `flutter analyze`/`flutter test` on Linux do not need a desktop sandbox.
- Keep one ShipGlows-owned template (`shipglows-flutter-linux`) so every project reuses the same toolchain; project source is uploaded or cloned per session.
- Attach the Flutter VM Service when possible (`flutter run -d linux` inside the sandbox, forwarded port) so agents tap via widget tree rather than pixels.
- Proof language: a desktop screenshot proves the window state only; auth and protected-access evidence follow the usual rules.

## Typical agent sequence

```bash
doppler run --project dotfiles --config dev -- e2b auth info
doppler run --project dotfiles --config dev -- e2b template list
# desktop session from a script using @e2b/desktop: create -> stream.start -> screenshot/click -> kill
```
