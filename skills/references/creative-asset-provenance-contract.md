---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: creative-asset-provenance-contract
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/007-sg-content/SKILL.md
  - tools/test_creative_asset_provenance_contract.py
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator-approved provider-neutral creative-asset provenance theme on 2026-08-15."
  - "Current Creative Commons, SPDX, Unsplash, Drawkit, C2PA, WIPO, OWASP, and IPTC primary sources were consulted with explicit adoption limits."
next_review: "2026-11-13"
next_step: "/104-sg-end creative asset provenance integration review"
---

# Creative Asset Provenance Contract

## Purpose And Authority Boundary

Use this contract before adopting, transforming, publishing, redistributing, migrating, or retiring a creative asset. It establishes operational evidence and escalation discipline; it is not legal advice. When material rights, releases, ownership, jurisdiction, provider terms, or downstream permissions remain unresolved, stop and obtain qualified legal or rights-holder review rather than asking an agent to infer clearance.

Unsplash, Drawkit, Shapefest, stock libraries, foundries, marketplaces, generators, optimizers, and AI providers are candidate sources or tools only. Availability, downloadability, payment, attribution, or a public URL is not permission. One provider's license does not automatically clear depicted people, private property, trademarks, moral/personality rights, privacy, or every downstream use.

## Classify Before Adoption

Classify each asset as one or more of:

- original/internal;
- commissioned;
- customer-supplied;
- stock or library;
- open-licensed;
- claimed public domain;
- proprietary, foundry, or marketplace;
- brand or trademark;
- AI-generated or AI-edited.

Classification selects questions; it does not answer them. A commissioned work still needs the relevant assignment or license evidence. A customer-supplied asset still needs authorization, handling constraints, and an accountable customer/ShipGlows decision. A public-domain claim needs its basis and jurisdiction. Brand assets require trademark and usage-guideline review even when file access is unrestricted.

## Mandatory Adoption Record

Create a durable record before production adoption. Record, as applicable:

- stable asset ID, title, and plain-language description;
- creator and rights holder, keeping unknown distinct from assumed;
- provider and canonical source URL;
- acquisition date, source version/item identifier, and license or terms version;
- evidence snapshot or durable reference to the actual license, terms, invoice, permission, assignment, release, or public-domain basis reviewed;
- intended product, channel, territory, and term where relevant;
- reviewed allowances and constraints for modification, commercial use, redistribution, sublicensing, and attribution;
- model-release, property-release, privacy/PII, and brand/trademark review status;
- original file hash before transformation;
- transformation lineage, tools/versions where material, and derived file hashes;
- accountable owner and reviewer;
- replacement, rollback, quarantine, and takedown route.

Keep evidence outside volatile provider pages when permitted, with access controls appropriate to invoices, releases, customer materials, private identities, and contractual terms. Never place secrets, private prompts, private customer data, or unnecessary PII in a public manifest. A checksum proves byte identity, not rights or safety.

## Licenses, Terms, And Redistribution

Read the actual terms applicable at acquisition and recheck them before publication or redistribution. Record changes and decisions without rewriting historical evidence. A current provider summary cannot silently replace the acquired license version.

For Creative Commons material, distinguish the applicable conditions: BY attribution, SA sharing adaptations under compatible terms, NC noncommercial restrictions, and ND restrictions on distributing adaptations. Also review database, publicity, privacy, moral, trademark, and other rights that a copyright license may not cover. Do not treat attribution as a substitute for permission.

SPDX identifiers and expressions help normalize recognized license information; they do not grant rights or settle compatibility. For non-software assets, custom marketplace terms, foundry licenses, releases, or bespoke permissions, retain and review the actual applicable text rather than forcing an approximate SPDX identifier.

Separate use in an end product from redistribution of source material. Permission to place an asset in a website, video, application, or flattened composition does not automatically permit shipping a source kit, template, editable scene, font file, library, standalone asset, or extractable derivative. Review sublicensing, seat/domain/project limits, client transfer, print/digital scope, territory, term, and attribution placement where applicable.

## People, Property, Privacy, Customers, And Brands

Copyright permission does not resolve every right. For identifiable people, private property, artwork within images, voices, signatures, locations, personal data, screenshots, testimonials, customer interfaces, logos, product trade dress, and trademarks, record the applicable model/property release, privacy basis, customer authorization, brand guideline, and rights-holder review.

Apply jurisdiction-aware review for publicity, personality, privacy, moral, consumer-protection, and trademark questions. Do not infer a release from a photographer's copyright license or provider warranty. Do not expose customer or private assets to an external optimizer, generator, model, marketplace, or analysis service unless the governing authorization and data-handling terms allow that exact transfer.

Screenshots inherit the rights and privacy concerns of everything visible in them. Redact or replace credentials, private URLs, personal data, third-party content, private messages, and customer details before any approved external use; redaction itself does not clear remaining brands or copyrighted content.

## AI, C2PA, And IPTC Boundaries

For AI-generated or AI-edited assets, preserve the provider/model and version when known, generation/edit date, permitted non-secret prompt summary where useful, input-asset IDs, output IDs or hashes, edits, and applicable provider terms. Do not preserve secrets, private prompts, customer content, or personal data merely for completeness.

A prompt, model output, account payment, provider term, or generation record does not automatically establish copyright, ownership, exclusivity, non-infringement, or permission for inputs and depicted subjects. Review training/input constraints, output terms, similarity or brand/person risks, required disclosure or labeling, and jurisdiction/project policy. Disclose or label only where applicable; never invent a universal AI-label rule.

C2PA Content Credentials provide signed provenance assertions and tamper-evidence across a claim chain. They do not prove that an assertion is true, that the signer owns the work, that the content is legal, that all permissions exist, or that an asset conforms to project policy. Verify the signer/trust context and retain the separate rights record.

IPTC photo metadata can carry creator, source, credit, copyright, rights, and descriptive fields. Metadata may be stale, incorrect, absent, or stripped during export, optimization, social delivery, or screenshotting. Preserve useful metadata where allowed, but keep external evidence and lineage independent of embedded fields.

## Untrusted Files And Safe Handling

Treat SVG, 3D files, archives, office/source files, fonts, images, audio/video, sidecars, and metadata as untrusted inputs. Conversion, transcoding, rasterization, optimization, or metadata removal is not sanitization.

Apply handling proportional to risk: allowlist expected types and verified signatures; set size, dimension, duration, decompression, nesting, and external-resource limits; reject or isolate active content, scripts, macros, event handlers, embedded executables, unexpected links, path traversal, and dangerous archive entries; use renamed generated storage identifiers; keep uploads outside executable/public paths until cleared; scan where appropriate; and process risky formats with patched, least-privileged, isolated tooling under time and resource limits. Preview or parse only through a controlled path and never trust a filename extension or client-provided MIME value alone.

Keep original evidence immutable and access-controlled. A sanitized delivery derivative remains linked to the original record and receives its own hash; do not replace the evidence file with the derived output.

## Transformation Lineage And Lifecycle

Inventory existing assets before adoption, migration, optimization, provider replacement, or bulk format conversion. Map every production use to a stable adoption record. Preserve `original -> conversion -> optimization -> crop/edit -> delivery derivative` lineage, including hashes and material tool/version information. Make transformations reproducible and reversible where practical; never rewrite history or delete evidence because terms changed.

Monitor material provider-term, license, release, brand-guideline, expiration, and source-availability changes according to product risk. A changed term does not automatically rewrite already acquired rights, nor does an old acquisition automatically authorize a new use: retain both histories and escalate the interpretation when material.

Define fast unpublish or distribution-stop capability, quarantine, impact inventory, notification/escalation ownership, replacement, cache/CDN purge where authorized, and rollback. For revocation, takedown, dispute, expired permission, security finding, or lost provenance, stop new use, preserve evidence, isolate the asset and derivatives, locate all uses, then apply the accountable decision. Never destroy the history needed to explain the action.

## Tool And Provider Boundary

Tools can help discover, inspect, optimize, transform, or record assets; they cannot turn unclear rights into permission. Before using Unsplash, Drawkit, Shapefest, a foundry, marketplace, generator, optimizer, or stock provider, bind the exact item and intended use to the current provider terms and the additional rights review above.

Do not upload customer/private work merely because a tool is convenient. Verify confidentiality, retention, training, subprocessors, geography, deletion, and account/workspace requirements before any authorized external processing. When those facts or authorization are missing, keep the asset local or use an approved isolated path.

## Proof Contract

Evidence is proportional to asset and use, and includes as applicable:

- complete adoption-record fields and durable rights evidence;
- original and derived hashes plus reproducible transformation lineage;
- attribution rendered in the required location and retained across surfaces/exports;
- license-condition and end-product-versus-redistribution review;
- model/property/privacy/customer/brand review status and accountable escalation;
- safe-file handling results without exposing private content;
- representative publication, download, package, template, and migration checks;
- takedown/quarantine, replacement, rollback, and cache-removal rehearsal for critical assets;
- known gaps, jurisdictions, territories, terms, channels, providers, and derivatives not reviewed.

An asset inventory, provider badge, invoice, metadata field, C2PA manifest, malware scan, optimization report, visual preview, or automated license classifier is supporting evidence only. None alone proves clearance, safety, conformance, or publication readiness.

## Sources And Adoption Limits

Consulted 2026-08-15. Recheck source status, license/terms versions, jurisdiction, and intended downstream use at acquisition and publication time.

| Source | Role | Adoption limit |
| --- | --- | --- |
| [Creative Commons license types](https://creativecommons.org/share-your-work/cclicenses/) | Overview of BY, SA, NC, ND, and public-domain tools. | Confirm the exact license/version and all applicable conditions; the overview is not project-specific clearance. |
| [Creative Commons FAQ](https://creativecommons.org/faq/) | Operational limits concerning attribution, adaptations, other rights, and license behavior. | CC licenses do not cover every privacy, publicity, moral, trademark, database, or third-party right. |
| [SPDX License List](https://spdx.org/licenses/) | Standard identifiers and recognized license texts. | An identifier normalizes information; it does not grant rights or replace actual custom/non-software terms. |
| [SPDX: handling license information](https://spdx.dev/learn/handling-license-info/) | Expressions and structured handling of license information. | Machine-readable expressions still require correct source evidence and contextual compatibility review. |
| [Unsplash License Help Center](https://help.unsplash.com/en/collections/1463188-unsplash-license) | Provider-specific license and FAQ entrypoint for Unsplash items. | Recheck current item/provider terms and third-party depicted rights; availability is not universal downstream authorization. |
| [Drawkit License](https://www.drawkit.com/license) | Provider-specific terms for Drawkit assets. | Bind the exact asset and acquired/current terms to the intended use; do not generalize to other providers or redistribution. |
| [C2PA specification 2.2](https://c2pa.org/specifications/specifications/2.2/index.html) | Technical model for signed manifests, assertions, ingredients, and provenance validation. | Signed provenance is not truth, authorship, legality, permission, or policy conformance. |
| [C2PA FAQ](https://c2pa.org/faq/) | Plain-language scope and limitations of Content Credentials. | A credential supplements rather than replaces rights, identity, trust, and content review. |
| [WIPO Copyright](https://www.wipo.int/copyright/en/) | International orientation for copyright and related rights. | Rights and exceptions vary by jurisdiction; material uncertainty requires qualified review. |
| [WIPO Trademarks](https://www.wipo.int/trademarks/en/) | International orientation for trademarks and source identifiers. | Copyright permission does not clear trademark use, endorsement implications, or local rules. |
| [OWASP File Upload Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html) | Defense-in-depth guidance for type, filename, storage, scanning, authorization, and resource handling. | Apply controls to the actual architecture and threat model; conversion or extension checks alone are insufficient. |
| [IPTC Photo Metadata](https://iptc.org/standards/photo-metadata/) | Standard fields for descriptive, creator, source, credit, and rights metadata. | Embedded metadata can be missing, stale, false, or stripped; retain independent evidence. |

These sources are authorities only for their stated roles. Preserve attribution for closely derived material and avoid substantial copying.

## Stop Conditions

Stop adoption, external upload, transformation, publication, migration, redistribution, or clearance claims when the asset class, source, rights holder, applicable terms/version, intended use, redistribution boundary, attribution, release, privacy, customer authority, trademark/brand status, AI/input rights, file safety, lineage, accountable reviewer, or recovery route is materially unresolved. Escalate material legal or rights ambiguity to qualified legal counsel or the relevant rights holder; never fill the gap with agent inference.
