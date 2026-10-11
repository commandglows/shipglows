---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-18"
status: active
source_skill: 900-shipglows-core
scope: interactive-3d-experience-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/001-sg-build/SKILL.md
  - skills/references/design-system-token-contract.md
  - skills/108-sg-browser/SKILL.md
  - tools/test_interactive_3d_experience_contract.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved ShipGlows Core plan 2026-08-13: turn the Awwwards 3D-tool watch into a provider-neutral execution reference."
  - "Khronos glTF specification and official tool documentation listed in Sources."
next_review: "2026-11-13"
next_step: "/103-sg-verify interactive 3D experience contract"
---

# Interactive 3D Experience Contract

## Purpose

Make 3D a deliberate product and experience decision with bounded technical cost, accessible fallbacks, and rendered proof. This contract applies when work proposes, audits, designs, implements, or materially changes WebGL, an interactive 3D scene, a configurator, a product viewer, spatial storytelling, or an immersive experience.

It is provider-neutral. The tools below are candidates discovered during watch work, not default dependencies, endorsements, or permission to install a package or upload project assets.

## Classify The Experience First

Record one dominant class before selecting a tool:

1. **Decorative depth**: non-essential atmosphere, illustration, parallax, or a pre-rendered visual. It must never block content or navigation.
2. **Interactive object**: user-controlled rotation, inspection, or bounded manipulation of one object.
3. **Product scene**: one or more objects communicate product form, material, assembly, or spatial context.
4. **Configurator**: user choices change variants, materials, parts, price, availability, or another consequential state. The application state and accessible controls remain authoritative; the canvas is a view, not the sole interface.
5. **Immersive experience**: navigation, narrative, or task completion occurs substantially within a rendered environment. This has the highest accessibility, performance, interaction, and recovery burden.

If an effect can deliver the intended comprehension, feedback, or brand value with semantic HTML/CSS, video, a responsive image sequence, or interactive 2D, prefer that lower-cost medium. Visual novelty alone does not justify 3D.

## Decision Tree

Use this order and retain the answers in the spec or implementation note:

1. **Is depth essential to the user outcome?** If no, use static or interactive 2D. If yes, continue.
2. **Is the content essential without WebGL?** If yes, design semantic controls and a complete non-WebGL path before the scene. If no, still provide meaningful alternate content and recovery.
3. **Does the experience require custom rendering, physics, complex scene state, or deep application integration?** If yes, evaluate a programmable engine such as Three.js. If no, a bounded authored embed such as Spline may be enough after export, runtime, privacy, accessibility, and lock-in checks.
4. **Does a tool choice change cost, control, supported platforms, asset custody, licensing, portability, or maintenance?** If yes, present that as a material operator decision. Never select or install automatically.
5. **Can the target devices meet an explicit budget?** If unknown, prototype the riskiest representative scene and measure before committing architecture.

Do not use a brand name as the requirement. Specify the experience class, interaction, state ownership, fidelity, target platforms, asset pipeline, budgets, fallback, and proof first.

## Asset And Material Contract

- Prefer glTF 2.0 interchange and `.glb` when a single portable binary is operationally simpler. Keep the editable source asset separately when future revision is expected.
- Validate scene scale, axes, origins, transforms, camera framing, animation clips, material channels, texture color spaces, and naming before integration.
- Use fit-for-purpose mesh and texture compression only after compatibility and visual-quality checks. A smaller artifact that silently loses required material or animation behavior fails.
- Keep texture dimensions, geometry complexity, draw calls, shader variants, animation data, and optional environment maps inside the recorded budget.
- Record asset author, source, license, attribution requirements, modification rights, redistribution rights, and any model-release or trademark constraints. Unknown provenance blocks use.
- Do not upload confidential, unreleased, customer, biometric, or licensed source assets to hosted authoring or processing services without explicit authorization and an accepted data-handling path.

## Tool Watch Candidates

Recheck current official documentation, pricing, export/runtime limits, platform support, data handling, and license immediately before adoption.

- **Three.js** (`https://threejs.org/`): evaluate for programmable Web 3D when the product needs custom scene state, rendering, interaction, loading, or framework integration. It increases engineering ownership; it is not a default merely because the target is WebGL.
- **Spline** (`https://spline.design/`, `https://docs.spline.design/`): evaluate for rapid authored scenes and bounded embeds. Confirm runtime weight, export/hosting terms, accessibility integration, event/state integration, offline or self-host requirements, and provider portability.
- **Womp** (`https://womp.com/`): evaluate as a browser-based creation surface for compatible stylized assets. This describes access through a browser, not accessibility conformance. Export fidelity, topology, materials, commercial rights, and downstream optimization must be proven before production use.
- **Physically Based** (`https://physicallybased.info/`): use as a reference candidate for physically based material values, not as automatic truth for art direction or a substitute for rendered validation in the target engine.
- **pmndrs market** (`https://market.pmnd.rs/`): evaluate individual assets only after provenance, license, attribution, file quality, optimization, and project-fit review. Marketplace availability never establishes production readiness.
- **Plask** (`https://plask.ai/`): evaluate only when character motion capture materially serves the experience. Confirm consent, biometric/privacy implications, retargeting quality, cleanup cost, export rights, and hosted-data handling.
- **Rive** (`https://rive.app/`, `https://rive.app/docs/`): Rive is an interactive 2D vector animation and state-machine alternative when depth is not essential. Rive is not a 3D engine and must not be represented or selected as one.

## Performance And Resilience Budget

Define numeric budgets from the product, audience, devices, networks, route criticality, and existing performance envelope before implementation. Do not copy universal thresholds into every project. At minimum record and measure:

- initial-route bytes and the separately lazy-loaded 3D payload
- model, texture, environment, runtime, and decoder bytes
- largest texture dimensions, triangle or vertex scale, draw calls, shader/material count, and concurrent animated objects
- loading time on a representative constrained network and device
- frame pacing, sustained frame rate, main-thread blocking, memory pressure, GPU pressure, thermal behavior where relevant, and recovery after navigation/remount
- Core Web Vitals or platform-equivalent impact on the surrounding product surface

Load non-essential 3D after primary content and interaction are usable. Use explicit loading, timeout, error, context-loss, retry, and low-quality states. Pause or reduce rendering when hidden, offscreen, backgrounded, or idle where behavior permits. Clean up animation loops, event handlers, observers, GPU resources, and framework mounts.

Adaptive quality must preserve the outcome: lower texture resolution, effects, shadows, reflections, antialiasing, particle count, or model detail before allowing a device to stall or fail. Performance acceptance requires measurement on representative hardware; a desktop development machine is not sufficient proof.

## Non-WebGL And Accessibility Contract

- Essential information, controls, selections, prices, validation, and task completion must remain available without WebGL and without interpreting a canvas.
- Provide a useful fallback such as semantic product controls, structured text, responsive images, a poster, a video with an equivalent description, or a non-3D configurator. A blank rectangle, perpetual loader, or generic "unsupported" message is not a fallback.
- Keyboard and assistive-technology users receive equivalent operation through semantic controls outside or alongside the canvas, with visible focus, understandable names, status announcements, and deterministic focus order.
- Do not encode essential state only through color, perspective, spatial position, texture, motion, hover, drag, or pointer precision.
- Respect `prefers-reduced-motion`. Remove non-essential camera movement, autoplay, parallax, orbit, particles, and vestibular effects; provide a meaningful stable outcome rather than merely slowing animation.
- Support zoom, responsive reflow, orientation changes, coarse pointers, touch, and loss of hover. Avoid trapping scrolling, gestures, keyboard focus, or browser navigation.
- If motion, flashing, audio, or spatial navigation is essential, document the applicable accessibility review and recovery control before implementation.

## Browser Proof Gate

A build, lint, unit test, source inspection, asset preview, or successful canvas initialization alone never proves a 3D experience. Use the canonical assigned URL and collect rendered browser evidence on representative devices, widths, inputs, states, and constrained conditions.

Proof must cover, as applicable:

- first load, progressive loading, success, empty, timeout, decoding failure, WebGL unavailable, context loss, retry, and navigation/remount
- pointer, touch, keyboard, screen-reader-facing semantic controls, focus order, zoom/reflow, orientation, reduced motion, and fallback equivalence
- representative content extremes, variant changes, rapid repeated input, background/foreground transitions, and slow network
- visual fidelity for camera, scale, materials, lighting, animation, clipping, occlusion, responsive framing, and surrounding layout
- measured bytes, loading, frame pacing, main-thread work, memory/GPU behavior, cleanup, and product performance impact against the recorded budgets

Visible defects and inaccessible or unavailable outcomes override passing numeric or source-level checks. Report untested devices, browsers, provider behavior, and fallback states as proof gaps; do not convert them into completion claims.

## Stop Conditions

Stop before implementation or adoption when the experience class or essential outcome is unclear; the tool choice is being assumed; asset provenance or license is unknown; hosted asset handling lacks authorization; target platforms or fallback are unspecified; budgets are absent; essential behavior exists only in the canvas; reduced-motion behavior is undefined; or representative browser/device proof cannot be collected.

## Sources

- Khronos glTF 2.0 specification: `https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html`
- Three.js documentation: `https://threejs.org/docs/`
- Spline documentation: `https://docs.spline.design/`
- Womp: `https://womp.com/`
- Physically Based: `https://physicallybased.info/`
- pmndrs market: `https://market.pmnd.rs/`
- Plask: `https://plask.ai/`
- Rive documentation: `https://rive.app/docs/`
