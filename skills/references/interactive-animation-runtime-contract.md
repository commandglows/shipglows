---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-08-15"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: interactive-animation-runtime-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/animation-playbook.md
  - skills/602-sg-platform-parity/SKILL.md
  - tools/test_interactive_animation_runtime_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/creative-asset-provenance-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved provider-neutral interactive-animation runtime contract on 2026-08-15."
  - "Current Rive, dotLottie, Motion, and W3C primary sources listed in Sources were consulted with platform and adoption limits."
next_review: "2026-11-15"
next_step: "/103-sg-verify interactive animation runtime contract"
---

# Interactive Animation Runtime Contract

## Purpose And Boundary

Use this contract when product work proposes, selects, integrates, migrates,
audits, or proves an interactive animation runtime or exported animation
format. It governs the choice among project-native motion, a code-driven
library, exported Lottie/dotLottie playback, and an authored Rive runtime.

This contract is provider-neutral. Motion, Lottie, dotLottie, Rive, their
players, renderers, editors, and hosted asset services are candidates, not
default dependencies or permission to install packages, upload assets, change
licensing, add remote requests, or adopt a provider. There is no universal
winner; choose only after product purpose, platform support, source authority,
accessibility, lifecycle, performance, security, provenance, and proof are
resolved.

## Classify The Need Before The Tool

Record the smallest class that satisfies the outcome:

1. **Native or code-driven motion.** Native CSS, Web Animations, or
   project-native motion is preferred for bounded transitions, layout changes,
   gestures, and feedback already owned by application components. Motion is a
   code-driven library candidate for Web animation on Astro sites or the Tauri
   Vue webview when its API and project fit replace real complexity; it is not a cross-platform asset
   format or an implicit dependency.
2. **Exported vector playback.** Lottie JSON or dotLottie is a candidate for
   authored timeline animation that should be exported and played by a target
   runtime. dotLottie can package multiple animations and related resources,
   but format capability does not prove player support or product fit.
3. **Authored interactive runtime.** Rive is an authored interactive runtime
   candidate when artboards, state machines, data binding, runtime inputs, or
   tightly coupled vector interaction materially reduce implementation cost
   while preserving application authority and target-platform support.

They are not interchangeable. A code library animates application-owned
elements, an exported playback format carries authored animation data, and an
interactive authored runtime carries its own rendering and state-machine
model. Do not use a brand name as the requirement or upgrade a simple
transition into a runtime integration for novelty.

## Source And State Authority

Before implementation, record:

- the canonical design-system and motion-token authority;
- the editable authoring source, exported artifact, runtime adapter, and
  event/input mapping, including their accountable owners and versions;
- the application state, animation state, and one-way or two-way synchronization
  boundary;
- the asset, font, image, audio, theme, locale, and fallback sources;
- the rebuild/export path and drift check that prevent hand-edited output from
  becoming an undocumented fork.

Application state remains authoritative for authentication, authorization,
purchase, entitlement, validation, persistence, navigation, or task completion.
A runtime state machine may present or mirror consequential state, but it never
becomes the sole source of truth and never grants permission, commits business
state, or silently navigates on its own. Runtime events are requests or
presentation signals handled by the application through typed, validated
mappings. Repeated, delayed, missing, or out-of-order animation events must not
duplicate or corrupt application actions.

Use stable semantic input and event names. Record defaults, allowed values,
direction, timing, error behavior, and ownership. Treat a renamed artboard,
state machine, animation, input, slot, theme, or asset as an interface change,
not merely a visual edit.

## Formats, Themes, Assets, And Compatibility

`.json`, `.lottie`, and `.riv` are different artifacts with different
authoring and runtime contracts. Do not rename, convert, or substitute them as
if they were equivalent.

- Lottie JSON carries an animation document and referenced or embedded assets.
- dotLottie 2.0 is a compressed container that can include animations, images,
  fonts, themes, and state machines. Theme rules target properties prepared
  with slot IDs; an exported theme cannot override arbitrary properties that
  were never made themeable.
- Rive files can contain authored artboards, animations, state machines, and
  assets interpreted by a Rive runtime. Feature availability can differ by
  runtime, renderer, package variant, and version.

Map runtime themes, slots, text, colors, and other visual properties to the
canonical design-system semantics. A dark-theme file, dynamic slot, or data
binding is an adapter, not a second design-token authority. Prove missing
glyphs, font behavior, text expansion, locale direction, image replacement,
high contrast, and resolved colors on the actual renderer.

Before choosing or upgrading a runtime, verify the exact runtime, renderer,
package variant, version, and target platform against current official feature
support. Web and Flutter parity is proven feature by feature for the exact
artifact and versions; a common source asset does not prove common behavior.
Record at least rendering backend, file-version support, state machines,
inputs/events, data binding, themes/slots, fonts, images, audio, hit testing,
layout/fit, loading, error APIs, accessibility integration, and disposal.
Unsupported or divergent features receive an intentional adaptation, a tested
fallback, or a blocked verdict.

## Loading, Failure, And No-Runtime Outcome

Define loading, ready, empty, timeout, decode or parse failure, missing asset,
unsupported feature, and retry states. Decide explicitly whether runtime,
WASM, animation, font, image, and audio assets are bundled, self-hosted,
cached, or remotely loaded. Remote delivery changes privacy, CSP, offline,
availability, cache, and supply-chain posture; it is never assumed from an
editor export or documentation example.

Essential content, controls, labels, focus order, status, and task completion
remain available without the animation runtime, JavaScript, canvas, or remote
asset host. Never hide essential content until runtime initialization succeeds.
Provide a useful static or semantic fallback, not a blank canvas, perpetual
loader, inaccessible gesture surface, or generic failure message. A decorative
animation may disappear; functional feedback must become an equivalent stable
state, text, icon, native control, or application-owned interaction.

Loading failure must not leave the application in a false success, false
disabled, or unclickable state. Timeouts and retries are bounded, observable,
and safe against duplicate initialization or duplicate business actions.

## Accessibility And Reduced Motion

Use semantic HTML or platform-native/Flutter semantics for interactive
controls. Canvas or vector hit regions do not replace accessible name, role,
value/state, focus, keyboard, switch, voice-control, touch-target, and status
semantics. The application remains operable when the rendered animation is
ignored by assistive technology.

Respect `prefers-reduced-motion` and the platform-equivalent preference with a
meaningful stable outcome. Define reduced-motion behavior per animation and
state-machine path before initialization, and respond safely when the
preference changes where the platform supports it. Preserve state, feedback,
reading order, focus, and task completion. Merely shortening every duration is
insufficient when translation, zoom, parallax, continuous motion, autoplay, or
rapid transitions remain disorienting.

For moving, blinking, scrolling, or auto-updating content, apply the relevant
WCAG pause, stop, or hide obligations and animation-from-interaction review.
Suppress non-essential interaction-triggered motion for users requesting
reduced motion. Do not make a runtime hook or framework helper the conformance
claim; rendered behavior and semantic operation are the proof.

## Lifecycle And Resource Ownership

Assign a single initialization owner for every runtime instance and shared
file/cache. Define behavior for mount, unmount, remount, route transition,
background, foreground, resize, and hot reload. Guard late asynchronous loads
from attaching to an obsolete component or overwriting newer application state.

Use the selected runtime's current cleanup or dispose API. Release owned
listeners, observers, render loops, state-machine instances, files,
controllers, canvases, workers, WASM, and GPU resources. Stop or reduce work
when hidden, offscreen, backgrounded, or settled where the product outcome
allows it. Reuse parsed files or shared render resources only with explicit
ownership, lifetime, eviction, and concurrency rules; caching is not permission
to leak a process-lifetime singleton.

Remount and navigation proof must show that duplicate listeners, timelines,
inputs, state machines, canvases, workers, or render loops are not created.
Cancellation and teardown must be safe during load, failure, retry, and rapid
route changes.

## Performance And Operational Budget

Set contextual budgets from the product, route criticality, target devices,
network, concurrency, and existing performance envelope. Do not invent one
universal byte, frame-rate, or instance threshold. Measure, as applicable:

- runtime, WASM, animation, image, font, audio, and remote-asset bytes;
- request count, cache behavior, download, parse/decode, initialization, and
  first-use latency;
- frame pacing, main-thread work, CPU, GPU, memory, and battery under
  representative interaction and concurrent-instance load;
- responsive resize cost, input latency, long tasks, surrounding product
  performance, background/offscreen behavior, and cleanup after navigation.

Prefer lazy loading when the animation is non-essential and below-the-fold,
but do not trade a delayed invisible control or layout shift for a smaller
initial bundle. Reduce complexity, concurrency, effects, asset size, renderer
cost, or runtime surface when budgets fail. A lite package, worker, shared
renderer, cached file, or alternative renderer is a candidate optimization
only after feature, lifecycle, browser/platform, CSP, and fallback proof.

## Security, Privacy, And Provenance

Treat animation files, archives, fonts, images, audio, scripts, and remote URLs
as untrusted inputs. Apply `creative-asset-provenance-contract.md` to source,
license, attribution, transformation, embedded content, redistribution, and
takedown evidence. Validate file type, size, archive structure, resource
limits, supported features, external references, and storage boundaries using
maintained parsers and runtimes; do not build an ad hoc archive extractor or
execute embedded/derived content blindly.

Review every remote asset request and runtime fetch against CSP, privacy,
offline, authentication, cache, and data-residency requirements. Never place
secrets, credentials, private customer data, or unnecessary PII in animation
inputs, text slots, URLs, telemetry, manifests, files, or hosted editor assets.
Do not upload confidential or licensed source material to a hosted authoring,
conversion, optimization, or asset service without explicit authorization and
accepted data handling.

Some animation formats or state machines can describe external URL actions or
remote image sources. The application must enforce allowlisted schemes and
destinations, explicit user activation, safe target/opener behavior, and its
normal navigation/authorization policy. Asset-authored actions never bypass
application routing, consent, or security checks.

## Proof Contract

A build, typecheck, source scan, editor preview, or successful first frame alone
does not prove an interactive animation runtime integration. Collect rendered
and behavioral evidence on supported Web browsers and Flutter targets with the
exact shipped artifact, runtime, renderer, and versions.

Proof covers, as applicable:

- loading and failure states, reduced motion, keyboard and assistive semantics,
  responsive resizing, touch/coarse pointer, theme, locale, high contrast, and
  static/semantic fallback;
- every state-machine transition and input boundary, application-state sync,
  rapid repeated input, delayed or missing events, navigation, and recovery;
- visual fidelity and feature support for the same source across Web and
  Flutter, with intentional adaptations recorded rather than hidden;
- bundle/network evidence, constrained-device performance, concurrent
  instances, background/offscreen behavior, and cleanup after remount or
  navigation;
- blocked remote actions, rejected untrusted assets, unavailable hosts, and
  redacted telemetry or logs where security/privacy paths apply.

Report untested platforms, runtimes, renderers, provider services, asset types,
and failure states as proof gaps. Do not turn a shared format, common editor
preview, or provider compatibility claim into a parity or completion claim.

## Stop Conditions

Stop before adoption or completion when the product need or authority boundary
is unclear; a dependency, editor, provider, renderer, hosted service, package,
license, or upload is assumed; exact Web/Flutter support is unknown; application
state would be delegated to the animation; fallback or reduced motion is
undefined; loading, disposal, performance, security, provenance, or external
actions are unbounded; or representative rendered proof cannot be collected.

## Sources

- Rive feature support: `https://rive.app/docs/feature-support`
- Rive state-machine playback: `https://rive.app/docs/runtimes/state-machines`
- Rive Web runtime: `https://rive.app/docs/runtimes/web/web-js`
- Rive Flutter runtime: `https://rive.app/docs/runtimes/flutter/flutter`
- Rive runtime asset loading: `https://rive.app/docs/runtimes/loading-assets`
- dotLottie 2.0 specification: `https://dotlottie.io/spec/2.0/`
- W3C reduced-motion technique C39: `https://www.w3.org/WAI/WCAG22/Techniques/css/C39`
- W3C Understanding SC 2.2.2: `https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html`
