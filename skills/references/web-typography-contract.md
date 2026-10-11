---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: web-typography-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/010-sg-technical/references/performance-audit-playbook.md
  - tools/test_web_typography_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved provider-neutral web typography theme on 2026-08-15."
  - "Current official CSS Fonts, WCAG, MDN, web.dev, Google Fonts, and Fontsource sources were consulted; adoption and proof remain project-specific."
next_review: "2026-11-13"
next_step: "/103-sg-verify web typography contract"
---

# Web Typography Contract

## Purpose

Use this contract when web product work selects, implements, migrates, or audits typography. Govern the complete system—semantic roles, files, scripts, loading, fallback, rendering, accessibility, privacy, licensing, and proof—rather than treating a typeface preview or a smaller font file as the outcome.

## Semantic Roles Before Families

Define stable product roles such as `type.body`, `type.heading`, `type.label`, `type.code`, and `type.data` before naming a family or provider. Each role records its user purpose, hierarchy, weight/style needs, responsive behavior, measure, line height, language coverage, and fallback. Product meaning and semantic type roles remain stable when the font source, family, or delivery provider changes.

Use shared design tokens for family, size, weight, style, line height, letter spacing, and measure. Components consume semantic roles rather than copying provider family names or raw font values. A provider substitution updates role mappings and verified metrics; it does not rename the product hierarchy.

Choose a bounded type scale that supports hierarchy without turning every viewport into an independent composition. Fluid values may use `clamp()` or an equivalent project-native mechanism, but minimum, preferred, and maximum behavior must be checked at representative viewport, zoom, locale, and content extremes. Do not import a universal modular ratio.

Set readable measure by content role and script. Long-form prose, dense data, short labels, code, and display text do not share one line-length rule. Validate actual comprehension and wrapping with representative content; do not turn a generic character count into an absolute threshold.

## Face, Variant, And Variable-Font Integrity

- Declare the actual `font-weight`, `font-style`, and when applicable `font-stretch` ranges provided by each `@font-face`. Do not label a regular file as several weights.
- Ship real bold and italic faces when those distinctions carry hierarchy, emphasis, quotations, identifiers, or language-specific meaning. Use `font-synthesis` controls when synthetic bold, oblique, small caps, or positions would be unsafe; never disable synthesis blindly without confirming that every required real face exists.
- Inspect the shipped variable font, not only the family marketing page. Record the axes and ranges actually included, such as `wght`, `wdth`, `slnt`, `ital`, or `opsz`, plus defaults, named instances, and any custom axes.
- Prefer high-level CSS properties such as `font-weight`, `font-style`, and `font-optical-sizing` where they express the intent. Use `font-variation-settings` only for axes or values that require the lower-level control.
- Provide a static face or system fallback when required browsers, renderers, documents, email surfaces, or native wrappers cannot consume the variable file correctly.
- Compare variable and static delivery using the actual axes, styles, subsets, compression, cache, and page use. A variable font is not automatically smaller when a page needs only one face.

## Unicode, Languages, Subsets, And Emoji

Inventory supported locales and real product content before subsetting. Include letters, diacritics, combining marks, punctuation, numerals, currency, mathematical and technical symbols, arrows, user-generated names, and brand/product glyphs as applicable. Test shaping, joining, kerning, vertical forms, bidirectional text, fallback boundaries, and line breaking for each supported script.

`unicode-range` can prevent unnecessary downloads, but it is a routing declaration, not proof that a generated subset is complete. A subset must not drop localized glyphs. Exercise representative strings and edge cases for every supported locale after the final subset step, and retain a reproducible source-to-subset command or configuration.

Do not subset unpredictable user-generated content to a fixed marketing corpus. Choose broader coverage, an authorized dynamic strategy, or a deliberate fallback. Keep subset identities and cache keys tied to the source version and configuration.

Treat emoji as a separate rendering decision. System color emoji, bundled monochrome symbols, text presentation selectors, and branded artwork have different semantics and platform behavior. Do not assume the primary text font supplies equivalent emoji across platforms; test fallback, baseline, color, accessibility, and missing-glyph behavior.

## Loading, Fallback, And Layout Stability

Prefer WOFF2 for modern web delivery when it meets the governed audience and deployment requirements. Keep source font binaries and generated web files distinct, versioned, licensed, and reproducible. Do not ship TTF/OTF merely because they were the design source when a suitable WOFF2 output is authorized.

Load only the families, styles, weights, axes, and subsets used by the representative product path. Make critical declarations discoverable early through project-native CSS or framework tooling. Preload only proven critical faces whose late discovery materially harms the initial render; indiscriminate preload competes with other critical resources and can bypass `unicode-range` selection.

Select `font-display` from the product's content priority, fallback quality, expected cache state, network profile, and tolerance for invisible text or late swaps. `swap`, `fallback`, and `optional` are contextual strategies, not universal winners. Prove behavior on cold and warm loads, slow and failed font requests, and representative text-LCP pages.

Build fallback stacks by language, platform, style, and metrics. Compare glyph coverage, x-height, cap height, average advance width, ascent, descent, line gap, weight, and style so fallback text remains usable and spatially compatible. Where supported and justified, `size-adjust`, `ascent-override`, `descent-override`, and `line-gap-override` may reduce mismatch; verify browser support and rendered results rather than assuming numeric equivalence.

An unacceptable fallback swap layout shift is a failed typography change. Measure actual CLS and inspect wrapping, truncation, control size, navigation, headings, data tables, and content below the swap. Do not hide a mismatch by blocking text for an excessive period.

Use immutable caching for content-addressed font files when deployment supports it. A changed binary, subset, axes, or hinting policy requires a new identity or explicit invalidation. Verify cache headers, compression, duplicate requests, cross-origin behavior, and service-worker/offline semantics where applicable.

## Provider And Hosting Decision

Continue the project's existing maintained font path when it satisfies product, accessibility, language, license, privacy, performance, security, deployment, and proof requirements. Otherwise compare the smallest complete options:

1. **Self-hosted files:** strongest direct control over version, headers, privacy, availability, and subsetting, with explicit responsibility for licensing, updates, processing, storage, CDN behavior, and security headers.
2. **Google Fonts CSS API:** convenient hosted discovery and delivery with selectable families, styles, variable axes, subsets, and display behavior. Review external requests, privacy/legal posture, regional availability, CSP/CORS, cache ownership, outage behavior, and provider changes before adoption.
3. **Fontsource:** versioned packages for self-hosted open-source fonts and variable/static imports. Review package size, exact import path, subset/axis contents, transitive build behavior, update policy, license, and whether package-managed files fit the framework and deployment.
4. **Another licensed foundry or managed provider:** require current webfont rights, permitted domains/users, data terms, operational behavior, performance proof, version control, and an exit path.

Self-hosting, Google Fonts, and Fontsource are contextual options, not automatic defaults. Do not install a package, call a hosted API, upload proprietary files, or change provider based on this reference alone.

FontJoy and Font Brief may help explore family pairing or visual direction. They are exploration aids only: neither establishes font quality, originality, license, language coverage, accessibility, performance, privacy, production compatibility, or adoption authority.

## Accessibility And Content Resilience

- Preserve text as real text; do not replace headings, labels, or body content with images merely to lock typography.
- Maintain the governed contrast bar and verify antialiasing-sensitive thin or variable weights on representative platforms; a nominal weight name is not legibility proof.
- Allow browser zoom and user font preferences. Text must reach the applicable WCAG resize expectation without loss of content or functionality.
- Test the WCAG text-spacing overrides for line, paragraph, letter, and word spacing. User text spacing and zoom must not clip, overlap, hide, truncate without recovery, or make controls unusable.
- Prove reflow for the governed accessibility target. Fixed heights, viewport-only font sizes, absolute positioning, and single-line controls must not create two-dimensional reading or inaccessible content when text grows.
- Recheck visible focus, error/help text, data density, placeholders, long translations, mixed scripts, bidirectional runs, and dynamic status messages with the final font stack.
- Do not claim WCAG conformance from type tokens, automated checks, or a font choice alone; conformance requires the governed page-level evaluation.

## Privacy, Security, Licensing, And Provenance

- Record the font source, foundry/author, version or commit/release, file hashes where useful, modification/subsetting rights, embedding and web-use rights, attribution, redistribution limits, trademark restrictions, and renewal obligations.
- Treat downloaded or supplied font binaries as untrusted inputs in conversion and subsetting pipelines. Pin tools, bound processing resources, retain provenance, and do not execute opaque installers or scripts merely to obtain a face.
- For cross-origin delivery, verify CORS headers and credential behavior. Keep CSP `font-src`, `style-src`, and any provider origins as narrow as the chosen delivery path allows.
- External font requests can disclose visitor network metadata and add dependency on another service. Review privacy notices, consent/legal basis where applicable, regional restrictions, retention, and outage behavior.
- Never upload proprietary, customer, unreleased, or restricted fonts to an online converter or preview tool without authorization.

## Budgets And Proof Contract

Define budgets from the product's pages, scripts, devices, networks, traffic, cache state, and visual requirements. Do not invent absolute universal thresholds. Record as applicable:

- number and transferred bytes of font files on cold and warm representative paths;
- families, faces, axes, subsets, preload entries, duplicate downloads, and unused glyph/face cost;
- font discovery, request, download, decode, and ready timing relative to FCP/LCP;
- fallback duration, swap behavior, CLS contribution, wrapping changes, and interaction availability;
- rendered legibility, hierarchy, measure, weights/styles, locale coverage, and missing-glyph results;
- CSP/CORS/cache/offline behavior and failed/slow-request recovery.

Network success or a build artifact alone is not enough. Use browser network evidence and rendered proof on representative pages and states. Cover cold cache, warm cache, blocked/failed font requests, critical text, long/localized content, each required weight/style, variable-axis extremes actually exposed by the product, zoom, text spacing, reflow, and supported platform rendering.

Report untested locales, glyph sets, providers, font-display states, browsers, devices, cache paths, privacy/legal review, or hosted behavior as proof gaps. A visually pleasing specimen is not production proof.

## Migration And Rollback

Inventory current semantic roles, family declarations, files, providers, weights/styles, axes, subsets, preload/CSS entries, fallback stacks, licenses, and representative screenshots/network traces before migration. Map old roles to new roles; never perform a blind family-name replacement across raw CSS.

Stage the smallest representative surface first. Compare hierarchy, line breaks, component dimensions, page length, localization, font requests, Core Web Vitals contribution, and accessibility states. Keep the previous mappings and assets recoverable until the new path passes proof and license/privacy review. Define rollback triggers for missing glyphs, unacceptable shift, loading regression, policy failure, rendering defects, or provider outage before broad rollout.

## Sources And Adoption Limits

Consulted 2026-08-15. Recheck specification status, browser support, packages, licenses, provider terms, privacy posture, and deployment constraints at adoption time.

| Source | Role | Adoption limit |
| --- | --- | --- |
| [W3C CSS Fonts Module Level 4](https://www.w3.org/TR/css-fonts-4/) | Normative model for font selection, loading, variations, synthesis, and font-face descriptors. | Current publication is a Working Draft; verify implementation support and use stable higher-level properties where appropriate. |
| [WCAG 2.2: Resize Text](https://www.w3.org/WAI/WCAG22/Understanding/resize-text) | Accessibility intent and failure modes when text enlarges. | Page-level behavior, not a font-family endorsement or automatic conformance proof. |
| [WCAG 2.2: Text Spacing](https://www.w3.org/WAI/WCAG22/Understanding/text-spacing) | Required resilience when users override text spacing. | Test the implemented content and controls; token inspection alone is insufficient. |
| [WCAG 2.2: Reflow](https://www.w3.org/WAI/WCAG22/Understanding/reflow) | Reflow intent and loss-of-content boundary under magnification. | Apply the criterion and its exceptions to the governed product surface. |
| [MDN: `@font-face`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/%40font-face) | Practical descriptors for sources, ranges, axes, metrics, subsets, and display. | Check the compatibility data for every descriptor used. |
| [MDN: `font-display`](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/%40font-face/font-display) | Browser display-period behavior for font loading. | A keyword choice still requires cold/slow/failure and layout proof. |
| [web.dev: Best practices for fonts](https://web.dev/articles/font-best-practices) | Loading, delivery, rendering, preload, and layout-shift guidance. | Performance guidance must be measured on the target page; preload is not automatic. |
| [Google Fonts CSS2 API](https://developers.google.com/fonts/docs/css2) | Hosted family/style and variable-axis request model. | External-service adoption still requires privacy, legal, CSP/CORS, availability, and performance review. |
| [Fontsource introduction](https://fontsource.org/docs/getting-started/introduction) | Versioned package-based self-hosting model. | A package is a delivery candidate, not automatic license, subset, axis, or bundle proof. |
| [Fontsource variable fonts](https://fontsource.org/docs/getting-started/variable) | Variable package and axis import guidance. | Inspect each font's actual files, axes, ranges, fallbacks, and output. |

These sources are authorities or candidates only for their stated roles. Preserve attribution for closely derived material and avoid substantial copying.

## Stop Conditions

Stop or narrow the claim when semantic roles, supported locales/content, required faces/axes, font rights, provider/privacy posture, CSP/CORS path, deployment/cache behavior, accessibility target, representative pages, budgets, or rollback are unresolved. Do not introduce a dependency, hosted request, font upload, destructive conversion, broad family replacement, or public delivery change without matching project authority and proof.
