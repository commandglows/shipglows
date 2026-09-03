---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-29"
updated: "2026-09-03"
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
  - "Operator-approved greenfield creation preset added on 2026-09-03: WXT, strict TypeScript, pnpm, Manifest V3, multi-browser output, native UI first, and Vue 3 for rich UI."
next_review: "2026-11-29"
next_step: none
---

# Browser Extension Lab

Use the Extension Lab when the target is a browser extension rather than a website URL.

## Greenfield creation contract

For a new browser extension with no accepted technical direction, apply the browser-extension preset in `preferred-stacks.md`: WXT, strict TypeScript, pnpm, Manifest V3, and Chromium-family plus Firefox output. Keep simple interface entrypoints native. Use Vue 3 for rich, stateful, multi-step, or component-heavy interface entrypoints; do not introduce React as a default or add Vue to background logic. The standard WXT configuration disables its own browser startup so ShipGlows retains isolated-profile ownership. Ask only when a product consequence such as supported browsers, permissions, authenticated access, remote services, or store distribution remains materially unresolved.

## Agent contract

1. Run `s extension-inspect -ProjectPath <path> -Json` before any repository script.
2. Treat `static` and `built` as directly testable. WXT resolves production `.output/<browser>-mv3` before its development output; CRXJS and static layouts retain ambiguity refusal. Treat `build-required` as a stop: inspect the repository and obtain the authority required for its declared build command.
3. Run `s extension-lab -ProjectPath <path> -Browser <Chromium|Edge|Vivaldi|Firefox> -Headless -Json` for deterministic proof, or omit `-Headless` for an interactive isolated window. Add `-Screenshot` when retained visual evidence is required. The default remains managed Chromium.
4. When content-script behavior is in scope, add `-TargetUrl <explicit-http-or-https-url>`. Never invent a target or navigate to an authenticated/private page without authority. With `-Screenshot`, the Lab captures that target after the bounded content-script wait; without `-TargetUrl`, Chromium-family browsers capture the declared popup.
5. Add `-ClickSelector <css>` to click exactly one element and `-VisualSelector <css>` to return bounded DOM text, visibility, bounds and the fixed computed-style allowlist. A selector matching zero or several elements fails visibly.
6. Record the manifest version, browser product, engine, executable path, binary and runtime versions, isolated-profile flag, resolved artifact path, returned extension id, popup/background/content-script status, click status, visual evidence and bounded errors. Never infer browser identity from the requested label or success from a build alone.
7. Close the browser after interactive work. Every backend uses a newly created temporary profile and must never target a personal browser profile directory.

## Trust boundary

Inspection parses bounded local manifests and does not install dependencies or execute package scripts. Browser-specific `dist/chrome` and `dist/firefox` outputs are selected only for their requested backend; remaining ambiguity fails closed. Manifest V2 is reported as obsolete and is not loaded. Edge and Vivaldi use their allowlisted machine executables with CDP; Firefox uses the managed Playwright Firefox binary and temporary WebDriver BiDi installation. Repository commands, dependency installation, CI dispatch, publication and store submission retain their own authority.

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
- `installed-via-bidi`: Firefox accepted the browser-specific artifact as a temporary WebExtension and returned its Gecko id.
- `observation-unavailable`: Firefox loaded the artifact, but the current Playwright protocol cannot enumerate injected script URLs; use a specific DOM selector as the behavioral proof.
- `not-probed`: a Firefox target-page run intentionally did not claim popup proof.
- `not-captured`: visual proof was requested, but neither an explicit target nor a declared popup produced an image.
- `not-requested`: no screenshot was requested; viewport metadata remains available for interpreting other evidence.

Do not describe an extension as tested when only detection or compilation passed. Popup, content-script and service-worker behavior require their own observed proof.
