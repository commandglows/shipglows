---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: product-color-system-contract
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/602-sg-platform-parity/SKILL.md
  - tools/test_product_color_system_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved provider-neutral product color-system theme on 2026-08-15."
  - "Current official CSS Color, Color Adjustment, WCAG 2.2, WCAG 3, and MDN sources were consulted with explicit adoption limits."
next_review: "2026-11-13"
next_step: "/104-sg-end product color system contract integration review"
---

# Product Color System Contract

## Purpose

Use this contract when product work creates, replaces, migrates, or audits a color system. Govern color as semantic product behavior across themes, accessibility modes, color spaces, platforms, and states rather than as a palette-generator output.

## Semantic Roles Before Color Values

Define stable roles before raw values, hue names, swatches, or provider identifiers. Product meaning and semantic roles remain stable when a palette, provider, color space, or platform implementation changes.

At minimum, inventory applicable roles for:

- canvas and layered surfaces, including raised, sunken, selected, scrim, and overlay contexts;
- primary, secondary, muted, inverse, link, and placeholder text;
- subtle, default, strong, selected, and invalid borders or dividers;
- keyboard focus indicators and focus-within states;
- primary, secondary, destructive, and neutral actions across default, hover, active, selected, disabled, and visited states;
- informational, success, warning, error, pending, and unavailable statuses;
- data-visualization series, baselines, axes, grids, thresholds, annotations, selections, and comparisons.

Components consume semantic tokens such as `color.text.primary`, `color.action.destructive`, or `color.focus.visible`; they do not bind product meaning to `blue-500`, a provider swatch, or a tool-generated name. Define aliases and state mappings in the design-system authority, then resolve them per theme and platform.

Do not invent a universal palette size, hue count, step interval, color difference, gamut target, or contrast threshold. Choose the smallest coherent set that satisfies applicable standards, brand/product needs, supported states, media, and measured proof.

## Themes, User Preferences, And System Colors

Treat light, dark, high-contrast, and forced-colors as distinct resolved environments, not a mathematical inversion exercise. For each supported environment, verify semantic hierarchy, state distinction, focus, text, controls, images, charts, shadows, scrims, and elevation cues.

Use `color-scheme` to declare the schemes the surface actually supports so user-agent controls and system UI can render coherently. It does not generate a complete dark theme or prove contrast. Respect applicable system preferences without silently overriding explicit product/user settings; document precedence and persistence.

In forced-colors mode, user-agent color substitutions and system colors are authoritative. Prefer native semantics and system colors for controls and focus. Use `forced-color-adjust: none` only for a narrow essential visual whose meaning cannot survive substitution, and then prove its foreground, background, states, focus, and fallback. Do not broadly disable forced-color adaptation.

Use `prefers-contrast` only as progressive input because support and user-agent behavior vary. A high-contrast design must remain coherent without assuming one media-query value or one operating-system setting.

## Color Spaces, Gamut, And Fallbacks

sRGB remains the interoperability baseline for broad web support. Display-P3 may express colors beyond sRGB on capable displays. OKLCH can support perceptually organized authoring and interpolation, but neither modern syntax nor numeric regularity guarantees accessibility, branding fidelity, gamut safety, or browser/device equivalence.

Every wide-gamut or modern-color use has an explicit fallback strategy. Put a usable supported fallback before the enhanced declaration or use a project-supported feature-query/progressive-enhancement path. Decide whether an out-of-gamut color is clipped, locally adjusted, or mapped by a governed transformation; record the target space and inspect the rendered result. Do not assume source coordinates equal displayed pixels.

Validate representative colors on supported browsers, operating systems, panels, emulators/devices, and capture paths. Screenshots can be converted, tagged, or clipped, so retain source tokens plus resolved-style/browser/device evidence rather than judging wide gamut from a single unmanaged image.

## Contrast And Resolved Compositing

Use WCAG 2.2 as the normative conformance baseline for applicable current claims. Test the implemented content against the applicable text contrast, non-text contrast, use-of-color, focus, and other governed success criteria; token values or an isolated swatch do not prove page conformance.

Evaluate the final resolved foreground/background combination for each representative state. Transparency, opacity, disabled styling, scrims, gradients, shadows, blending, antialiasing, background images, video, and user-supplied media can change the actual result. Sample or calculate relevant worst-case regions after compositing, then inspect rendered states. If contrast cannot be guaranteed across dynamic media, add a governed backing surface, outline, shadow only when sufficient, media treatment, or layout alternative.

Visible focus must remain identifiable against adjacent colors and component states. Do not reuse a brand accent mechanically when the resulting focus indicator disappears on one theme or surface.

WCAG 3 is a draft and APCA is an emerging contrast evaluation approach. They may inform research and comparative design decisions, but APCA alone must never replace applicable WCAG 2.2 checks or support a current WCAG 2.2 conformance claim.

## Meaning, Interaction States, And Data Visualization

Never encode information, required action, status, selection, validation, or navigation through color alone. Pair color with text, iconography, shape, pattern, position, underline, border, or another perceivable cue suited to the task. The redundant cue must persist in light, dark, forced-colors, print/export, and relevant platform adaptations.

Specify and prove interactive default, hover, active/pressed, selected, focus-visible, disabled, visited, loading, invalid, error, warning, success, and recovery states as applicable. Disabled content is not an excuse for illegibility when users still need to understand state or recover. Links that rely on color need the applicable non-color distinction in context; visited styling must remain understandable and privacy-safe.

For charts and maps, use labels, direct annotations, shapes, strokes, patterns, ordering, or interaction cues in addition to hue. Check adjacent series, small marks, selected/deselected states, tooltips, axes, thresholds, and export/print. Color-vision simulators can reveal candidate collisions, but they are supporting heuristics only—not proof of perception, task success, or accessibility conformance. Use representative user tasks and rendered evidence.

## Tool And Provider Boundary

Huemint, Coolors, Adobe Color, Colorable, and Picular may support exploration, inspiration, palette comparison, or preliminary checking. They are aids only: none has automatic authority to define the product system, license an asset, establish originality, select a provider, prove platform rendering, or certify accessibility/conformance.

Continue an existing maintained token and theme system when it satisfies semantic, accessibility, platform, performance, governance, and proof requirements. When evaluating another library, generator, plugin, or provider, compare export fidelity, color-space handling, token semantics, privacy/data handling, license and terms, versioning, reproducibility, maintenance, platform output, and exit path. Do not install, upload private brand material, or adopt a service from this reference alone.

## Platform Parity

Define parity by product meaning and accessibility outcome, not identical color coordinates. Web CSS, iOS semantic/dynamic colors, Android theme attributes, desktop system colors, and document/export surfaces may require platform-native values or adaptation. Each mapping records the same semantic role, expected state, theme behavior, contrast obligation, system override behavior, and evidence.

Check platform-specific rendering pipelines, display profiles, opacity/compositing, native control substitution, dynamic type/settings, forced/high-contrast modes, and dark-mode scheduling. A screenshot match is supporting visual evidence, not proof that semantic states or assistive modes are equivalent.

## Migration And Rollback

Before migration, inventory semantic and raw tokens, aliases, themes, component references, hardcoded values, states, charts, gradients, images, platform mappings, CSS/native system hooks, screenshots, resolved styles, known exceptions, and current accessibility evidence. Map old roles to new roles; never perform a blind hue-name or provider-token substitution.

Migrate representative critical surfaces first. Compare every governed state in light, dark, forced/high-contrast, reduced-gamut, and platform contexts. Retain recoverable previous mappings until verification completes. Define rollback triggers for lost meaning, contrast regression, unreadable focus, indistinguishable states, gamut failure, broken system-color behavior, data-visualization collisions, or platform drift.

## Proof Contract

Proof is proportional to the product and claim, and includes as applicable:

- token/alias inventory and resolved computed styles for representative components and states;
- rendered screenshots in light, dark, high-contrast/forced-colors, reduced-gamut, and relevant color-vision review modes;
- browser and real-device/platform checks, because emulator and screenshot pipelines can hide gamut or system-color behavior;
- automated contrast checks as coverage aids plus manual inspection of focus, state, gradient, overlay, image, transparency, and dynamic-content cases;
- assistive-mode and keyboard proof for controls, focus, errors, selection, and recovery;
- chart task checks with labels/patterns and cross-platform semantic mappings;
- migration comparison, known proof gaps, rollback triggers, and accountable review.

Report untested themes, browsers, devices, displays, system preferences, charts, dynamic backgrounds, platform mappings, or assistive modes as proof gaps. A palette preview, simulator, source token scan, or automated score alone is not rendered or conformance proof.

## Sources And Adoption Limits

Consulted 2026-08-15. Recheck specification status, browser/platform support, user-agent behavior, tool terms, and project requirements at adoption time.

| Source | Role | Adoption limit |
| --- | --- | --- |
| [W3C CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/) | Color syntax, spaces, interpolation, conversion, and gamut model including Lab/LCH and OKLab/OKLCH. | Specification support and rendering vary; modern syntax needs a tested fallback and explicit gamut strategy. |
| [W3C CSS Color Adjustment Module Level 1](https://www.w3.org/TR/css-color-adjust-1/) | `color-scheme`, forced-color adjustment, and user-agent color adaptation model. | Do not disable adaptation broadly; verify the implemented user-agent and platform behavior. |
| [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | Normative current accessibility conformance baseline for governed claims. | Conformance applies to complete pages/processes and applicable criteria, not a palette or tool result alone. |
| [WCAG 2.2 Understanding: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) | Text and text-image contrast intent, thresholds, exceptions, and failures. | Evaluate resolved rendered content and the applicable criterion; do not generalize a token result to the whole product. |
| [WCAG 2.2 Understanding: Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html) | Contrast for essential UI component states and graphical objects. | Scope and exceptions are contextual; test components and required states, including focus where applicable. |
| [WCAG 2.2 Understanding: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html) | Requirement that color is not the only visual means of conveying information or action. | A simulator does not prove redundant meaning or task completion. |
| [MDN: `oklch()`](https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/oklch) | Practical syntax, alpha, examples, and compatibility orientation for OKLCH. | Check current target-browser data; perceptual organization does not guarantee contrast or in-gamut output. |
| [MDN: `forced-colors`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/forced-colors) | Practical forced-color media behavior, system colors, and author testing guidance. | Browser/OS substitutions differ; use actual forced-color evidence and narrow exceptions. |
| [MDN: `prefers-contrast`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-contrast) | User preference query for more or less contrast. | Support remains variable; it cannot be the only high-contrast strategy. |
| [MDN: `color-scheme`](https://developer.mozilla.org/en-US/docs/Web/CSS/color-scheme) | Practical declaration behavior for supported schemes and user-agent UI. | It does not create theme tokens or prove dark-mode accessibility. |
| [W3C WCAG 3.0 Working Draft](https://www.w3.org/TR/wcag-3.0/) | Emerging accessibility-guideline and evaluation direction, including evolving contrast work. | Draft and non-normative for current WCAG 2.2 conformance; APCA/WCAG 3 evaluation cannot replace applicable WCAG 2.2 claims alone. |

These sources are authorities only for their stated roles. Preserve attribution for closely derived material and avoid substantial copying.

## Stop Conditions

Stop or narrow the claim when semantic roles, design-system authority, supported themes/platforms, accessibility target, dynamic backgrounds, color spaces, fallback/gamut behavior, provider terms, migration inventory, proof environments, or rollback are unresolved. Do not adopt a provider, install a tool, upload private assets, replace a palette broadly, weaken system-color behavior, or claim accessibility from a generator, simulator, APCA result, or automated checker alone.
