---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: product-iconography-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/602-sg-platform-parity/SKILL.md
  - tools/test_product_iconography_contract.py
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved provider-neutral product iconography theme with Iconoir as a conditional recommended candidate on 2026-08-15."
  - "Current official library and accessibility sources were consulted; adoption and conformance remain project- and proof-specific."
next_review: "2026-11-13"
next_step: "/103-sg-verify product iconography contract"
---

# Product Iconography Contract

## Purpose

Use this contract when product work selects, creates, replaces, maps, or audits icons. Build one semantic and visual language across product surfaces without making a vendor library, SVG filename, codepoint, or visual metaphor the product's source of truth.

## Meaning Before Glyph

Define a stable semantic icon key from the user-facing concept and context, for example `navigation.back`, `action.delete`, `status.success`, or `object.calendar`. Map that key to a provider component per platform. Do not expose provider names such as `ArrowLeft`, `Trash`, or `CheckCircle` as the durable domain contract when the product meaning is more specific.

Product meaning and accessible names remain stable when the underlying icon provider changes.

For every icon role, record as applicable:

- user intent or object represented;
- action, navigation, status, object, brand, or decorative role;
- visible label, accessible name, tooltip/help need, and consequence;
- default, hover, focus, pressed, selected, disabled, loading, error, success, and high-contrast behavior;
- directionality, locale, platform convention, and whether mirroring is valid;
- canonical size, stroke/fill family, optical adjustment, and token mapping;
- provider mapping, fallback, license/provenance, and proof state.

If a symbol is ambiguous without nearby text or learned product context, use a visible label. Familiarity is evidence to inspect, not permission to guess.

## Provider Decision

Continue the project's existing coherent icon family when it covers the required semantics, platforms, accessibility integration, visual grammar, imports, license, and maintenance posture. Replacement requires a measured gap and a migration contract; a newly discovered library is not sufficient reason.

Evaluate candidates in this order:

1. existing design-system icon components and platform-native symbols;
2. one maintained cross-surface family that fits the governed visual language;
3. a small documented extension set designed to the same grid and optical rules;
4. a second family only when a real semantic/platform gap cannot be resolved coherently and the exception is explicit.

Iconoir is a strong candidate when its outlined/solid language, available target packages, coverage, MIT license, and selective-import behavior fit the product and current stack. It is never an automatic dependency or universal visual direction. Lucide, Material Symbols, native Cupertino/Material icons, or another maintained family may be a better fit when the existing system, platform convention, fill/weight axis, or package/runtime constraints differ.

Do not mix libraries glyph by glyph for convenience. If an extension is necessary, normalize view box, baseline, optical size, cap/edge alignment, stroke caps/joins, weight, corner character, fill semantics, and apparent density; rendered review decides coherence, not matching numeric dimensions alone.

## Visual Grammar And Tokens

- Define a bounded icon-size scale and use semantic tokens for size, color, state, and surrounding control geometry.
- Preserve an optical family: consistent perceived weight, negative space, detail level, corner character, and alignment at the rendered size.
- Do not shrink a detailed icon until it becomes illegible; choose or design an optically appropriate small-size variant.
- Keep stroke and filled variants semantically intentional. If fill communicates selected/active state, do not use it randomly for decoration.
- Inherit `currentColor` when product state should control color, but never encode state or severity by color alone.
- Align icons optically with text and control centers rather than assuming the SVG bounding box produces visual alignment.
- Decorative icons remain subordinate to hierarchy and do not create repetitive noise, false affordance, or duplicate spoken content.

## Accessibility And Interaction

- Decorative icons are hidden from the accessibility tree and have no redundant accessible name.
- Meaningful non-interactive images receive an appropriate text alternative when surrounding text does not already provide it.
- Interactive controls use native buttons/links or equivalent mature primitives. The control owns the accessible name; the nested icon is normally hidden from assistive technology.
- An icon-only control requires an unambiguous accessible name. Add a visible label when recognition, consequence, audience, or context makes the glyph insufficient.
- A tooltip may supplement discovery for pointer/keyboard users but never becomes the sole accessible name, error message, instruction, or mobile explanation.
- Preserve visible focus, keyboard activation, disabled/pressed/expanded semantics, adequate contrast, and a target size appropriate to the governed accessibility/platform bar.
- Do not communicate success, warning, failure, selection, required state, or destructive consequence through icon shape or color alone; pair it with text, programmatic state, or another perceptible cue.
- Loading spinners and animated icons respect reduced motion and expose meaningful busy/progress state without trapping the user in an unlabeled animation.

## Direction, Locale, And Platform Adaptation

Classify each directional symbol before mirroring:

- **Reading/navigation direction:** back/forward, previous/next, indentation, reply, and progression may mirror in RTL when locale and platform conventions require it.
- **Physical or absolute direction:** compass, geographic, clockwise, device orientation, and real-world left/right must preserve their actual meaning.
- **Media and established symbols:** play, fast-forward, undo/redo, send, and other learned conventions require product/platform review; never mirror them from a blanket CSS transform.
- **Text-bearing or brand glyphs:** never mirror automatically.

Platform parity means equivalent product meaning and quality, not necessarily the same path data. A platform-native adaptation is acceptable when it is clearer or required, but record the mapping and prove labels, state, geometry, and behavior on every claimed platform.

## Performance, Packaging, And SVG Safety

- Prefer selective component imports or a proven tree-shaken entrypoint. Measure the built output; a package's tree-shaking claim alone is not proof.
- Do not ship a complete icon font, sprite, or library when a bounded subset suffices. Icon fonts also require explicit fallback, loading, codepoint stability, and accessibility review.
- Deduplicate repeated inline SVG only when the chosen sprite/component strategy preserves styling, accessibility, CSP, caching, and rendering behavior.
- Pin provider versions through the project's dependency policy and review renamed/removed glyphs before upgrades.
- Treat third-party or uploaded SVG as active untrusted content. Optimization is not sanitization; never inline it into trusted DOM without a security-purpose trust/sanitization boundary.
- Do not copy proprietary icons, trademarks, logos, or vendor assets outside their license. Record library license, attribution obligations, brand usage rules, and custom-icon provenance.

## Migration Contract

Before replacing a library, inventory semantic keys, rendered locations, aliases, custom extensions, unavailable replacements, filled/outlined state rules, platform mappings, public screenshots/docs, bundle effects, and visual baselines. Create the new semantic adapter first, migrate bounded families, keep rollback possible, and remove the old provider only after source, rendered, accessibility, and bundle proof show no remaining consumers.

Do not perform blind component-name substitution. Similar names can encode different direction, severity, state, or metaphor.

## Proof Contract

Source inspection, typecheck, successful rendering, matching view boxes, or a library showcase alone never proves a product icon system.

Prove representative:

- navigation, destructive action, status, selected/unselected, disabled, loading, empty/error, and decorative roles;
- visible and accessible names, focus, keyboard/touch operation, tooltip behavior, contrast, and non-color state cues;
- small/large sizes, dense controls, long/localized labels, zoom, high contrast, dark/light themes, and representative target densities;
- LTR/RTL and any symbol intentionally preserved or mirrored;
- Web and claimed native-platform mappings when parity is promised;
- selective imports/tree shaking, bundle delta, missing-glyph fallback, and provider-upgrade behavior;
- SVG trust boundary, license/provenance, and visual regression for custom or transformed assets.

Report untested platforms, assistive technologies, directionality, high contrast, package output, licenses, or migration edges as proof gaps. A recognizable icon is not automatically an accessible or product-correct icon.

## Sources And Adoption Limits

Consulted 2026-08-15. Recheck versions, packages, maintenance, platform support, and licenses at adoption time.

| Source | Role | Adoption limit |
| --- | --- | --- |
| [Iconoir](https://iconoir.com/) and [repository](https://github.com/iconoir-icons/iconoir) | Candidate open-source icon family with SVG and multiple framework/platform packages. | Recommended only after fit with the existing visual language, platform targets, imports, license, and rendered proof. |
| [Lucide guide](https://lucide.dev/guide/) | Alternative open-source icon family and implementation reference. | Candidate, not a reason to mix families or replace an existing coherent system. |
| [Material Symbols guide](https://developers.google.com/fonts/docs/material_symbols) | Reference for variable symbol axes and Material-oriented delivery. | Material/platform conventions do not automatically fit another product identity or package budget. |
| [WAI-ARIA APG: Button Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/button/) | Interaction and accessible-name expectations for button controls. | APG examples supplement native semantics and product testing; copying markup alone does not establish accessibility. |
| [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | Normative accessibility criteria for non-text content, contrast, focus, names, and target-related outcomes where applicable. | Conformance requires scoped implementation and manual/assistive proof, not library selection or automated checks alone. |

These sources are role-bounded references, not blanket endorsements. Avoid substantial copying and attribute closely derived material.

## Stop Conditions

Stop or narrow the claim when product meaning, accessible name, visual-system authority, platform/RTL behavior, provider/license, SVG trust, migration mapping, or representative proof is unknown. Do not install, replace, bulk-migrate, inline untrusted assets, or remove the previous provider without the matching project authority and rollback path.
