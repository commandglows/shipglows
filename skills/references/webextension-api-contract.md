---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-04"
status: active
source_skill: 900-shipglows-core
scope: webextension-api-design-and-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-development/SKILL.md
  - skills/references/preferred-stacks.md
  - skills/references/browser-extension-lab.md
  - skills/103-sg-verify/references/verification-security-ui-runtime.md
depends_on:
  - artifact: skills/references/browser-extension-lab.md
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "2026-09-04: repository audit found Manifest V3, stack, permission, and isolated-host proof guidance but no shared contract for WebExtension API selection, lifecycle, portability, and API-specific proof."
  - "2026-09-04: current Chrome and MDN references document converging promise/browser namespaces while preserving API and manifest differences across browsers."
next_review: "2026-12-04"
next_step: "/103-sg-verify WebExtension API contract"
---

# WebExtension API Contract

Use this contract when a browser extension reads or writes browser state, injects code, communicates across extension contexts, requests site access, intercepts traffic, or uses a browser-specific extension API. The stack preset remains in `preferred-stacks.md`; isolated host proof remains in `browser-extension-lab.md`.

## Compatibility Before Implementation

Define the supported browser set and minimum versions from the accepted product contract. For every selected API, manifest key, permission, event, and return shape, check current MDN browser compatibility plus the relevant vendor's official reference. Record unsupported or behaviorally different targets as an adapter, guarded fallback, explicit exclusion, or blocking product decision. A shared source tree does not prove runtime parity.

Prefer promise-based `browser.*` semantics in product logic when the declared minimum versions support them. Keep namespace/version compatibility in one typed adapter rather than scattering `chrome`/`browser` checks through entrypoints. Capability-check optional or uneven APIs at the call boundary; never infer support only from browser family or TypeScript definitions.

## Context And Lifecycle Boundaries

- Treat the Manifest V3 service worker as ephemeral. Persist durable state before returning, reconstruct listeners synchronously at module evaluation, and never rely on globals, timers, open ports, or an earlier event to remain alive.
- Keep popup, options, side panel, offscreen document, service worker, content script, user script, and page world as distinct trust and lifetime boundaries.
- Use typed, schema-validated messages with explicit request, response, and error forms. Authenticate the sender/context where the action or data is privileged; make retried mutations idempotent.
- Store durable extension state through the appropriate storage API. Handle quotas, concurrent writes, synchronization conflicts, unavailable storage, migration, and sensitive-data minimization explicitly.
- Use an offscreen document only for a justified DOM capability unavailable to the service worker. Keep it bundled, single-purpose, lifecycle-managed, and limited to `runtime` messaging.

## Permissions And Injection

Start with `activeTab`, optional permissions, and optional host permissions when the user can grant access at the moment of value. Request access only from a qualifying user gesture, explain the concrete benefit, handle denial and revocation, and keep the extension useful without optional access. Broad hosts, cookies, history, downloads, identity, debugger, native messaging, or enterprise APIs require an explicit trust justification.

Use static content scripts for stable declared behavior and `scripting` for bounded runtime injection. Validate tab URL, frame, document lifecycle, and restricted-page eligibility before injection. Keep isolated-world code as the default; crossing into the page's main world requires a concrete interoperability need and strict data validation.

User-provided code belongs to `userScripts`, never `eval`, remote code, or dynamically fetched executable content. Detect both manifest/browser support and the user-controlled availability state, then provide safe recovery.

Prefer `declarativeNetRequest` over blocking request interception when declarative rules express the outcome. Bound rule ownership, IDs, priorities, quotas, updates, and rollback; test conflicts between static, dynamic, and session rules. Never collect request contents merely to reproduce a declarative result.

## API-Specific Decision Rules

- `sidePanel`: require browser/version support and a fallback surface when it is not in the accepted browser set; opening must follow the browser's user-gesture rules.
- `alarms`: use for best-effort wake-up, not exact scheduling; reconcile missed, delayed, duplicate, and restarted work.
- `runtime` and `tabs`: handle missing/closed/frozen/discarded tabs, absent receivers, worker restart, disconnect, and `runtime.lastError` or rejected promises.
- `identity`, OAuth, cookies, and externally connectable messaging: load the applicable auth/security workflow; validate origins, redirect targets, account/tenant binding, and log redaction.
- native messaging: require an explicit desktop integration decision, allowlisted hosts, bounded schemas, least privilege, and separate installation/distribution proof.

## Proof Contract

Proof is capability-specific and browser-specific. At minimum:

1. statically verify manifest keys, permissions, host patterns, minimum versions, and absence of remote executable code;
2. test adapters, message schemas, permission denial/revocation, worker restart, duplicate delivery, unavailable API, and storage failure where applicable;
3. build the declared browser-specific artifacts through the reviewed project command;
4. use the Extension Lab on each materially supported engine for load and context evidence, adding an explicit target URL for content-script behavior;
5. exercise the actual API outcome and capture bounded diagnostics. A loaded extension, awake worker, open popup, or successful build alone does not prove API behavior.

When the Lab cannot observe the capability directly, record the exact behavioral selector, state transition, diagnostic, or manual/provider proof required. Do not downgrade a portability or permission gap into generic compilation success.

## Freshness And Stop Conditions

Recheck official documentation when browser versions, API availability, namespace behavior, permissions, store policy, or manifest support control the implementation. Stop before coding when the supported-browser promise, required permission, authenticated/private target, remote service, native host, or store-distribution consequence is unresolved.

## Pressure Scenarios

- `WEBEXT-API-PORTABILITY`: a Chromium-only API used for a declared Firefox target requires a guarded adapter/fallback, explicit exclusion, or product decision.
- `WEBEXT-API-WORKER-RESTART`: behavior that depends on service-worker globals, timers, or an earlier connection fails until restart-safe state and proof exist.
- `WEBEXT-API-PERMISSION-DENIAL`: optional access must have a user-gesture request, denial/revocation handling, and a usable reduced-capability state.
- `WEBEXT-API-MESSAGE-TRUST`: privileged messages without schema validation and sender/context checks fail the boundary.
- `WEBEXT-API-INJECTION`: broad host access or main-world injection without a bounded accepted need and validation fails.
- `WEBEXT-API-PROOF`: build/load/popup success cannot stand in for the selected API's observable outcome.
