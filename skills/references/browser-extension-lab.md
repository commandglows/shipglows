---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-29"
updated: "2026-08-29"
status: active
source_skill: 300-sg-docs
scope: browser-extension-lab
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/ShipGlows.ExtensionLab.js
  - cli/windows/shipglows-devserver.ps1
depends_on: []
supersedes: []
evidence:
  - "Chrome BRAT loaded through the ShipGlows Extension Lab in temporary Chromium on 2026-08-29."
next_review: "2026-11-29"
next_step: none
---

# Browser Extension Lab

Use the Extension Lab when the target is a browser extension rather than a website URL.

## Agent contract

1. Run `s extension-inspect -ProjectPath <path> -Json` before any repository script.
2. Treat `static` and `built` as directly testable. Treat `build-required` as a stop: inspect the repository and obtain the authority required for its declared build command.
3. Run `s extension-lab -ProjectPath <path> -Headless -Json` for deterministic proof, or omit `-Headless` for an interactive isolated Chromium window. Add `-Screenshot` when retained visual evidence is required.
4. When content-script behavior is in scope, add `-TargetUrl <explicit-http-or-https-url>`. Never invent a target or navigate to an authenticated/private page without authority. With `-Screenshot`, the Lab captures that target after the bounded content-script wait; without `-TargetUrl`, it captures the declared popup.
5. Record the manifest version, resolved artifact path, returned extension id, popup status, service-worker status, content-script status, `visual.screenshotStatus`, `visual.screenshotPath`, viewport and bounded errors. Never infer success from a build alone.
6. Close Chromium after interactive work. The Lab uses a temporary profile and must never target Chrome, Edge or another personal profile directory.

## Trust boundary

Inspection parses bounded local manifests and does not install dependencies or execute package scripts. Multiple candidate artifacts fail closed. Manifest V2 is reported as obsolete and is not loaded. Repository commands, dependency installation, CI dispatch, publication and store submission retain their own authority.

## Proof vocabulary

- `static`: `manifest.json` is at the selected project root.
- `built`: a supported output directory contains the sole valid manifest.
- `build-required`: a reviewed CRXJS build contract exists but no loadable artifact is present.
- `loaded`: isolated Chromium accepted the unpacked artifact and ShipGlows resolved its extension id through an observed worker or the bounded CDP fallback.
- `opened`: the declared popup reached `domcontentloaded` in the isolated context without a captured console, page or request error.
- `opened-with-errors`: the popup opened, but the bounded probe captured at least one console, page or failed-request diagnostic.
- `open-failed`: Playwright could not open the declared popup URL.
- `declared-not-awake`: the manifest declares a service worker, but no live worker target was observed during the bounded probe.
- `observed`: Playwright or CDP observed a live service worker belonging to the loaded extension.
- `not-requested`: content scripts are declared, but no explicit target URL was supplied, so ShipGlows did not navigate.
- `observed` (content scripts): Chromium parsed at least one script belonging to the extension on the explicit target page.
- `not-observed`: content scripts are declared but none were parsed on the explicit target; check manifest match patterns and page eligibility.
- `temporary`: the browser profile is disposable and separate from personal browser state.
- `captured`: the requested PNG was written outside the disposable profile at the returned absolute path.
- `not-captured`: visual proof was requested, but neither an explicit target nor a declared popup produced an image.
- `not-requested`: no screenshot was requested; viewport metadata remains available for interpreting other evidence.

Do not describe an extension as tested when only detection or compilation passed. Popup, content-script and service-worker behavior require their own observed proof.
