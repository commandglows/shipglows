---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-18"
updated: "2026-08-18"
status: active
source_skill: 601-sg-product-entitlements
scope: product-access-and-license-ui
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/references/product-entitlements-playbook.md
  - skills/references/product-entitlement-support-and-proof.md
  - skills/references/authenticated-experience-ui-contract.md
  - skills/references/portfolio-commercial-catalog-contract.md
depends_on:
  - artifact: skills/references/product-entitlements-playbook.md
    artifact_version: "2.1.0"
    required_status: active
  - artifact: skills/references/authenticated-experience-ui-contract.md
    artifact_version: "1.0.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/portfolio-commercial-catalog-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-18: ShipGlows products need a reusable customer-facing component contract for purchased plan, features, quotas, and activation usage, linked to but distinct from authentication UI."
next_review: "2026-11-18"
next_step: "none — active shared reference; apply conditionally through 006 or 601"
---

# Product Access And License UI Contract

## Purpose And Authority

Use this contract when a product displays purchased access, plan, license term, feature availability, quotas, activations, devices, expiry, renewal, or recovery actions. It governs presentation and interaction around resolved entitlement truth.

- `601-sg-product-entitlements` owns field meaning, lifecycle status, provenance, freshness, authorization boundaries, and support proof.
- `006-sg-design` owns component anatomy, progressive disclosure, responsive behavior, accessibility, tokens, and rendered proof.
- `authenticated-experience-ui-contract.md` owns who is signed in and how account/private navigation is represented.
- `portfolio-commercial-catalog-contract.md` owns project-approved product, offer, plan, feature, quota, activation, term, price, decision-status, and customer-label meaning.
- The server-owned entitlement ledger and backend guards remain authoritative. UI, client claims, provider branding, purchase copy, and local mirrors never authorize premium behavior.

## Truth Model

Keep these layers visible in architecture and invisible as accidental ambiguity for customers:

1. **Identity:** who is signed in.
2. **Provider event:** purchase, renewal, refund, cancellation, or marketplace event that happened.
3. **Canonical entitlement:** server-resolved product, plan, status, term, features, quotas, activation policy, and ownership that authorize access.
4. **Mirror/cache:** a bounded availability optimization with explicit freshness and non-granting failure behavior.
5. **Presentation:** a read-only explanation plus approved recovery/actions.

The component consumes a server-derived view model. It may format dates, labels, and already-resolved counts; it must not infer access from identity, price, receipt, provider response, marketing copy, or client arithmetic.

Resolve customer labels and commercial explanations through the owning project-local catalog. When a catalog field is `undecided`, `planned`, `historical`, or `missing_authority`, the UI must not promote it to an active offer or substitute a generic free/unlimited value.

## Required States

| State | Customer meaning | UI behavior |
| --- | --- | --- |
| Loading | Access truth is resolving | Reserve stable space; do not show a false free/active plan |
| Lookup unavailable | Truth cannot currently be verified | Say access details are unavailable; retry safely; do not unlock |
| No entitlement | Identity is recognized but no granting record exists | Explain purchase, restore, account-switch, or support routes appropriate to the product |
| Trialing | Verified trial currently grants access | Show trial label, expiry, meaningful limits, and next-step expectations |
| Active | Verified entitlement grants current access | Show plan, term, features, quotas, activations, and relevant management actions |
| Pending review | Evidence exists but is not authorizing | Explain review/reconciliation without promising access |
| Expired | Term ended | Show the ended date and approved renewal/reactivation route |
| Revoked or refunded | Access was removed | Do not retain active styling or features; provide product-safe support context |
| At limit | Current usage equals the allowed activation/quota limit | Show the limit honestly and the permitted management or upgrade action |
| Over limit or inconsistent | Usage exceeds limit or fields disagree | Do not recompute authorization; show reconciliation/support state and refresh |
| Stale or offline | A cached view exists beyond its authoritative freshness | Label freshness and follow the product's fail-closed/offline policy |

Unknown, unlimited, not applicable, and zero are different values:

- `0` is a known numeric value.
- `unlimited` is an explicit server-owned policy, never inferred from a missing limit.
- `not applicable` means the dimension does not govern this plan.
- `unknown` means truth is unavailable and must not be presented as unlimited, zero, or active.

## View Model

Expose only fields that help the customer understand access or take a safe action:

- stable product display name and optional product icon from project authority;
- customer-facing plan name and access status;
- license/term type such as trial, subscription, lifetime, perpetual-with-maintenance, or another governed product term;
- start, expiry, renewal, or maintenance end dates only when meaningful and verified;
- authorized feature entries with stable machine keys kept behind the adapter and customer-facing labels/descriptions in the UI;
- quota entries with server-resolved `used`, `limit`, optional `remaining`, unit, period, and reset time;
- activation entries with server-resolved `used`, `limit`, optional `remaining`, policy, and last refresh;
- optional minimized device entries when device management is supported and privacy-approved;
- source-safe recovery actions and a redacted last-updated/freshness indicator.

Do not expose raw license or activation codes, tokens, secrets, webhook data, receipts, full provider/customer/order/subscription/license IDs, internal plan/feature keys, database identifiers, or unnecessary device fingerprints.

## Component Anatomy

Use progressive disclosure rather than one dense billing console:

1. **Access summary:** product, plan, status, and the most important term/date.
2. **Usage summary:** activations and only quotas that materially affect current use.
3. **Included capabilities:** concise feature list, grouped when large.
4. **Details:** optional devices, periods/reset dates, provenance/freshness, and support context.
5. **Actions:** only actions valid for the current state and product policy.

Possible actions include manage plan, restore purchase, redeem through an approved secure flow, activate this device, deactivate a selected device, renew, upgrade, switch account, refresh status, or contact support. An action's presence never proves the user is authorized to complete it; the server revalidates every mutation.

Provider/account management and product license management may be separate destinations. Name them distinctly so `Manage account` does not unexpectedly open billing or device revocation, and `Manage license` does not imply identity/security settings.

## Plans, Features, And Quotas

- Use the canonical customer-facing plan label, not an unreviewed provider price nickname or internal ID.
- Separate entitlement-backed feature state from temporary product availability. A feature can be included by plan yet unavailable because of outage, platform limitation, rollout, dependency, or policy; name the actual cause owner.
- Do not turn marketing comparison copy into authorization keys. Map stable backend feature keys to localized UI labels through a governed adapter.
- Show gated features only when this helps comprehension, upgrade choice, or recovery. Avoid a wall of disabled controls that makes purchased access feel broken.
- Quota meters include textual values and units. Color, arc length, or progress fill alone is insufficient.
- When `remaining` is displayed, prefer the server-resolved value. If the client verifies arithmetic for presentation, inconsistent `used`, `limit`, and `remaining` becomes an error state rather than a silently corrected claim.
- Period-based quotas state the period and reset time. Lifetime totals, rolling windows, calendar periods, and one-time allowances are not interchangeable.

## Activations And Devices

- Display activation usage as an explicit phrase such as `2 of 3 devices activated`; do not rely on an unlabeled fraction.
- `used = limit` means at limit, not over limit. `used > limit` is inconsistent/over-limit and requires server reconciliation.
- Concurrent activation/deactivation is resolved server-side and refreshed after every action. Disable duplicate submission while pending and do not optimistically promise the slot until confirmed.
- The current device may be identified with a local label such as `This device` only when the server/device mapping is trustworthy.
- Device rows reveal the minimum useful description: customer-assigned label or coarse device/platform name, optional approximate last activity when authorized, and state. Hide hardware IDs, fingerprints, serials, full IPs, raw installation IDs, and unnecessary location.
- Device deactivation states its effect and requires confirmation when it can interrupt another active installation or lose unsynced local work.
- If device details cannot be exposed safely, show counts and route management to a secure dedicated surface.

## Dates, Renewal, And Lifetime Access

- A lifetime/perpetual entitlement has no invented renewal date. Distinguish access lifetime from update/support/maintenance duration when the commercial contract does.
- Trials show the exact governed end date and timezone-safe customer rendering; avoid ambiguous countdown-only urgency.
- Subscriptions distinguish next renewal, cancellation-at-period-end, past due, grace period, and expiry when those states exist in canonical truth.
- Avoid predicting renewal success. Label scheduled dates and current state, not future payment guarantees.
- Localize dates, numbers, pluralization, units, currency references, and relative time; retain an unambiguous absolute date where consequences are material.

## Freshness, Offline, And Failure

- Show `last updated` only when the timestamp helps interpret potentially changing access, activation, device, or quota state.
- A cache beyond its TTL is stale even if it contains a formerly active entitlement. Follow the canonical fail-closed or explicitly governed offline-grace policy.
- Refresh actions are observable, idempotent, and preserve the last safe explanatory state without presenting it as current authorization.
- Distinguish entitlement lookup failure from auth expiry, provider outage, sync failure, product-feature outage, and network offline state; route each to its owner.
- Cross-account, cross-product, cross-environment, malformed, or partially missing data fails non-authoritatively and is not patched in the UI.

## Accessibility And Responsive Behavior

- Status uses text plus optional icon/color. Never encode active, expired, limited, or error state by color alone.
- Counts, meters, and progress expose meaningful accessible names, current value, limit, unit, period, and reset when applicable.
- Tables become labeled lists/cards on narrow surfaces without losing relationships between feature, inclusion, usage, and action.
- Interactive targets meet project minimums and at least 44 CSS pixels where applicable; focus remains visible and restored after dialogs/menus.
- Support 200% zoom, text-spacing overrides, reflow, RTL, long plan/feature names, plural forms, large dynamic type, forced colors, and reduced motion.
- Large feature/device sets use headings, grouping, search/filter only when justified, and progressive disclosure that remains keyboard and assistive-technology operable.
- Skeletons/placeholders do not announce every visual pulse; meaningful state resolution and failure may be announced once.

## Privacy And Security

- Backend guards revalidate product, plan, feature, quota, activation, owner, environment, and status for every protected read/write.
- Minimize identity and commercial data in shared/screenshottable surfaces. A support export requires its own redaction contract.
- Never log or display bearer codes, secrets, tokens, receipts, provider payloads, full external IDs, device fingerprints, or writable grant state.
- Do not expose other users' seats, devices, names, emails, or activity without an explicit organization/tenant role and privacy contract.
- Purchase, restore, activation, deactivation, upgrade, refund, and support actions use the relevant entitlement/provider workflows; this component does not invent mutations.

## Proof Matrix

1. Active plan with finite features, quotas, and activation allowance.
2. Zero used, one used, exactly at limit, over limit/inconsistent, and explicitly unlimited activation/quota values.
3. Trial, lifetime/perpetual, subscription, expired, revoked, refunded, pending-review, no-entitlement, unavailable, stale, and offline states.
4. Many features and devices at narrow/wide widths, zoom/reflow, RTL, long localization, forced colors, reduced motion, and keyboard navigation.
5. Server denial despite a polished active-looking client fixture; the UI must not unlock access.
6. Refresh after another device activates/deactivates; stale counts do not remain authoritative.
7. Redaction scan proves absence of raw codes, tokens, receipts, provider IDs, internal keys, and device fingerprints.
8. Action proof uses mocked/disposable/explicitly authorized state for activation, deactivation, purchase, restore, refund, or revoke; no real commercial mutation is implicit.

UI-only evidence never proves backend authorization, provider ingestion, revocation/refund/expiry propagation, activation concurrency, or cross-user isolation. Combine this matrix with the `SPE-001` through `SPE-010` entitlement scenarios when claiming end-to-end completion.

## Pressure Scenarios

### LICENSE-UI-STALE-ACTIVE

A cached active plan remains on screen after refund or revoke. If the cache is beyond its freshness policy or backend refresh fails, the component must not present that state as current authorization or keep premium behavior unlocked.

### LICENSE-UI-ACTIVATION-BOUNDARY

The server returns `used=3, limit=3`, then another context changes the count. The UI labels the first state `at limit`, refreshes after action/state change, treats `used>limit` as inconsistent, and never manufactures a remaining slot.

### LICENSE-UI-UNLIMITED-UNKNOWN

A missing limit is not displayed as unlimited. Only an explicit server-owned unlimited policy receives that label; unknown or malformed values show unavailable/recovery state.

### LICENSE-UI-FEATURE-SEMANTICS

A marketing page says a plan includes an AI feature, but the backend feature key is absent or denied. The component may explain the discrepancy, but neither marketing copy nor the displayed feature list unlocks it.

### LICENSE-UI-PRIVACY

A device-management view is captured for support. It contains useful customer labels and states but no raw activation code, license ID, order ID, token, receipt, fingerprint, serial, full IP, or unrelated user data.

### LICENSE-UI-AUTH-ENTITLEMENT-SEPARATION

A user is signed in but has no active entitlement. The global account UI remains valid, the access component explains no entitlement, and protected product behavior stays denied. Signing in never silently upgrades the plan.

## Stop Conditions

Stop or narrow the claim when canonical ledger ownership, field semantics, plan/feature keys, quota periods, activation policy, device privacy, freshness/TTL, offline grace, renewal meaning, support route, or mutation authorization is unknown. Route identity/session state to `109-sg-auth-debug`, entitlement truth to `601-sg-product-entitlements`, UI composition/proof to `006-sg-design`, sync/mirror behavior to `600-sg-local-cloud-sync`, and provider-specific current semantics through the freshness gate.
