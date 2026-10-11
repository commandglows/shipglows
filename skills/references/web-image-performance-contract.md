---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-18"
status: active
source_skill: 900-shipglows-core
scope: web-image-performance-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/010-sg-technical/references/performance-audit-playbook.md
  - tools/test_web_image_performance_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved framework-native, Sharp/libvips, SVGO, and Squoosh role split on 2026-08-15."
  - "Current official tool and platform sources were consulted for supported roles; adoption remains project-specific and evidence-gated."
next_review: "2026-11-13"
next_step: "/103-sg-verify web image performance contract"
---

# Web Image Performance Contract

## Purpose

Use this contract when web work creates, imports, transforms, serves, or audits raster images or SVGs. Optimize the complete delivery pathâ€”source, transformation, markup, cache, rendering, accessibility, and proofâ€”not only the encoder's file-size result.

## Classify Before Selecting Tools

Record the asset's role before choosing a format or processor:

- content image, product media, editorial photo, illustration, UI chrome, icon, logo, screenshot, texture, poster/fallback, or animation;
- critical/LCP candidate, above-fold supporting, or deferred content;
- required intrinsic detail, transparency, sharp edges/text, color fidelity, animation, zoom, and accessibility behavior;
- expected rendered widths, densities, viewports, networks, browsers, devices, update frequency, and cache lifetime;
- source provenance, license/attribution, privacy-sensitive metadata, and whether the input is trusted.

Do not use the filename extension or a tool brand as the requirement.

No format, quality setting, or encoder wins without representative visual and performance evidence.

## Tool Selection Order

1. **Framework-native pipeline first.** Prefer a maintained image service or component already owned by the target framework when it produces correct dimensions, responsive candidates, formats, markup, cache behavior, deployment output, and reproducible builds.
2. **Sharp/libvips for a programmable raster gap.** Use a pinned, code-owned Sharp/libvips pipeline when the framework cannot supply required transforms, batch processing, metadata/color policy, deterministic outputs, or non-framework integration. Treat native binaries, deployment compatibility, resource use, and transitive licensing as adoption checks.
3. **SVGO for controlled SVG optimization.** Use versioned configuration and review semantic IDs, `viewBox`, paint inheritance, masks, filters, animation, accessibility, and visual output. Optimization is not sanitization; never inline untrusted SVG merely because SVGO processed it.
4. **Squoosh for calibration and diagnosis.** Use its side-by-side visual workflow to compare codecs, quality settings, resize filters, and artifacts on representative assets. Record the chosen settings in the production pipeline; a manual Squoosh export is not a reproducible build step or CI proof.
5. **Specialist encoder or managed image service only after a measured gap.** Require a concrete quality, throughput, runtime-transformation, storage, delivery, or operational benefit. Provider cost, lock-in, privacy, remote-source authorization, cache semantics, outage behavior, and migration remain material decisions.

Do not install a processor or service from this reference alone. Continue an existing compatible stack when it satisfies the contract; otherwise make the smallest complete project-specific decision.

## Format And Quality Decisions

- Keep SVG for appropriate vector content after controlled optimization; do not rasterize merely for convenience.
- Compare AVIF, WebP, JPEG, PNG, and any platform-native candidate against the actual content and supported delivery path. There is no universal AVIF-first rule.
- Provide a compatible fallback when the supported audience or delivery surface requires one; use `<picture>` only when alternate sources deliver a real benefit.
- Preserve alpha, animation, HDR/wide-gamut intent, sharp text/edges, and required color fidelity or record the deliberate loss.
- Normalize orientation before removing EXIF orientation data. Strip GPS and unnecessary metadata by default, while preserving required ICC/color information, attribution, copyright, or operational metadata through an explicit policy.
- Never choose one universal quality number. Calibrate by asset class and inspect representative low-detail, high-detail, gradient, skin-tone, text/screenshot, alpha, and dark-mode cases as applicable.
- Preserve the highest-quality authorized source outside the delivery bundle so outputs can be regenerated without recompressing already lossy derivatives.

## Responsive Delivery And Loading

- Set intrinsic `width` and `height` or an equivalent stable aspect ratio to reserve layout space and prevent avoidable CLS.
- Generate a bounded set of widths from real layout breakpoints, rendered sizes, density needs, and source resolution. Avoid both one oversized universal asset and combinatorial variant generation.
- Use correct `srcset` and `sizes`; confirm the browser selects an appropriate candidate at representative viewport and density combinations.
- Make the actual LCP image discoverable in initial markup. Use eager loading or high fetch priority only when evidence identifies the real critical candidate; applying them broadly creates contention.
- Lazy-load genuinely deferred images without postponing content needed for first success or accessibility.
- Prefer semantic `<img>`/`<picture>` for meaningful content. CSS backgrounds do not provide equivalent responsive selection, alternative text, intrinsic sizing, or content semantics by default.
- Keep placeholders and transitions dimensionally stable and ensure failure produces useful content or fallback rather than a permanent blank region.

## Budgets And Cache Contract

Define budgets from the target product, page, device, and network rather than importing universal thresholds. Record as applicable:

- transferred bytes for the LCP candidate, each asset role, and the representative page total;
- intrinsic-versus-rendered dimensions and candidate-selection waste;
- variant count, generated storage, build time, encoder CPU/memory, and cache hit behavior;
- LCP and CLS contribution, decode/render timing, and main-thread or memory pressure on representative devices;
- acceptable visual loss for each asset class and any explicit fidelity exception.

Cache immutable content-addressed derivatives for a long lifetime when the deployment supports it. Source changes must produce a new identity or invalidate all affected variants. Do not cache private, tenant-specific, permissioned, or mutable media under public immutable semantics.

## Safety, Privacy, And Provenance

- Treat remote URLs and uploaded images as untrusted. Allowlist remote origins, prevent internal-network and credential-bearing fetches, bound redirects/timeouts/bytes/pixels/frames/dimensions, and fail safely on malformed or decompression-bomb inputs.
- Process untrusted SVG as active content. Sanitize with a security-purpose mechanism or serve it as a non-executable image under an appropriate policy; SVGO alone does not establish safety.
- Do not upload confidential, private, embargoed, customer, or unreleased assets to a hosted optimizer without authorization and a reviewed data/retention contract.
- Verify source rights, transformation rights, attribution, trademark constraints, and redistribution terms before producing or publishing derivatives.
- Keep temporary originals and derivatives out of commits, logs, caches, or public build output unless their retention and destination are intentional.

## Proof Contract

A build, encoder success, Lighthouse score, smaller byte count, or Squoosh preview alone never proves a production image pipeline.

For the affected representative pages and states, prove as applicable:

- generated dimensions, formats, variant bounds, deterministic regeneration, cache identity, and fallback markup;
- actual browser-selected resource, transferred bytes, priority/loading behavior, LCP/CLS effect, and failure behavior;
- rendered comparison at representative widths/densities, including gradients, text, transparency, cropping, color, animation, and dark/light contexts where relevant;
- keyboard/screen-reader semantics and alternative text for meaningful images;
- slow network, disabled/failed image request, missing modern-format support where applicable, and representative lower-power device behavior;
- security/resource bounds for remote or uploaded inputs.

Report untested formats, devices, browser selection, hosted transformations, color pipelines, animation, or fallbacks as proof gaps. A smaller file with visible unacceptable degradation is a failed optimization, not a success.

## Sources And Adoption Limits

Rechecked 2026-08-18. Recheck versions, platform support, pricing, licenses, and deployment constraints at adoption time.

| Source | Role | Adoption limit |
| --- | --- | --- |
| [Squoosh](https://github.com/GoogleChromeLabs/squoosh) | Browser-based visual comparison and codec experimentation. | Calibration tool; manual output does not define a reproducible production pipeline. |
| [Sharp documentation](https://sharp.pixelplumbing.com/) | Programmable Node.js raster transformation and format output. | Project dependency only after runtime, native-binary, deployment, resource, and license fit. |
| [libvips](https://www.libvips.org/) | High-performance processing engine underlying Sharp and available independently. | Low-level engine; packaging and operational responsibility remain project-specific. |
| [SVGO](https://svgo.dev/) | Versionable Node.js/CLI optimization for SVG. | Optimizer, not a sanitizer or automatic guarantee of semantic/visual preservation. |
| [Astro Images](https://docs.astro.build/en/guides/images/) | Framework-native image components, transforms, responsive behavior, and authorized remote-source processing for Astro projects. | Applies to Astro surfaces only; verify adapter/deployment behavior and do not reproduce it in another stack by assumption. |
| [MDN: Image file type and format guide](https://developer.mozilla.org/en-US/docs/Web/Media/Guides/Formats/Image_types) | Cross-format capabilities and web-use orientation. | Compatibility and format guidance must still match the governed browser/device audience. |
| [MDN: Responsive images](https://developer.mozilla.org/en-US/docs/Web/HTML/Guides/Responsive_images) | `srcset`, `sizes`, density, and art-direction semantics. | Correct markup still requires browser/network and rendered proof on the target layout. |
| [OWASP: Server-Side Request Forgery Prevention](https://cheatsheetseries.owasp.org/cheatsheets/Server_Side_Request_Forgery_Prevention_Cheat_Sheet.html) | Threat model and layered controls for server-side remote image fetching. | Apply project-specific URL, DNS, redirect, network, and destination validation; a hostname allowlist alone is insufficient. |
| [OWASP: File Upload](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html) | Defense-in-depth for uploaded and transformed files. | Image decoding still needs implementation-specific byte, pixel, frame, time, and memory limits. |
| [W3C: SVG Integration](https://www.w3.org/TR/svg-integration/) | Security restrictions vary with the SVG embedding mode. | Treat inline or executable SVG differently from SVG loaded as an image; optimization never substitutes for the selected security policy. |

These sources are candidates and authorities for their stated roles, not blanket endorsements. Avoid substantial copying; preserve attribution for closely derived material.

## Stop Conditions

Stop or narrow the claim when the asset role, target widths, authorized source, privacy/licensing posture, framework/deployment path, visual acceptance bar, fallback, or representative proof route is unknown. Do not introduce a dependency, hosted service, destructive recompression, source deletion, bulk conversion, or public upload without the corresponding project authority and rollback path.
