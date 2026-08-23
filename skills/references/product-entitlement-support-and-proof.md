---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-22"
status: active
source_skill: 601-sg-product-entitlements
scope: product-entitlement-support-and-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/601-sg-product-entitlements/SKILL.md
  - skills/references/product-entitlements-playbook.md
  - skills/references/progressive-clarity-and-agency-contract.md
depends_on: []
supersedes: []
evidence:
  - "Wave 12 made the previously named SPE-001 through SPE-010 scenario family explicit."
  - "Operator decision 2026-08-22: preserve the CommunityGlows trial-expiry learning as reusable suite doctrine without copying product-specific claims."
  - "Operator decision 2026-08-22: the reusable pattern is the full value-led trial transition, not only the blocked state after expiry."
next_review: "2026-11-12"
next_step: none
---

# Product Entitlement Support And Proof

## UI And Support Contract

Distinguish signed out, lookup unavailable, recognized/no entitlement, active, expired/refunded/revoked, and pending-review states. Only verified active access unlocks product behavior. Use product-safe recovery language and expose marketplace/provider branding only when intentionally public.

Support documentation must explain safe user lookup, entitlement inspection, grant/revoke/refund/expire/reissue, duplicate identity handling without silent merge, wrong-account code recovery, provider reconciliation, and retention after access removal. Redact tokens, raw codes, cookies, provider secrets, raw webhook payloads, and unnecessary personal data.

## Value-Led Trial Transition Contract

Treat the end of a trial as a continuous, trust-sensitive product journey rather than a last-minute paywall. The entitlement state remains authoritative; the interface anticipates the transition, showcases value already experienced, explains access consequences, and offers valid next actions without manufacturing fear, scarcity, debt, or access truth.

This is the entitlement-specific application of `progressive-clarity-and-agency-contract.md`; the access doctrine below remains authoritative for trial states, restarts, purchase, and recovery.

The goal is recognition, not intimidation: help the person notice what the product has already made easier before asking whether they want to preserve that workflow. Increase information and decision clarity as expiry approaches; never increase emotional pressure.

### Transition Timeline

| Moment | Experience role | Required tone and boundary |
|--------|-----------------|----------------------------|
| Active trial before the reminder window | Let product value speak through use | No premature conversion interruption. |
| First reminder, commonly J-7 | Establish awareness of the real end date | Calm orientation, data-safety boundary, easy dismissal or bounded snooze. |
| Consideration reminder, commonly J-3 | Recap the strongest evidenced capabilities | Value recognition and offer clarity, without inflated loss language. |
| Decision reminder, commonly J-1 | Explain exactly what will pause and what remains | Direct and specific, with valid purchase, restart, postpone, or recovery choices as governed. |
| Expiration | Confirm the verified access state | Stable reassurance, concrete paused value, governed offer, and every valid alternative. |
| Post-expiry recovery | Restore access or resolve exceptional states | Purchase, eligible restart, recheck, support, export, privacy, account/purchase recovery, and sign-out as applicable. |

Milestones such as J-7, J-3, and J-1 are product-configured examples, not universal invented urgency. They must derive from trusted trial timestamps, remain bounded per real trial cycle and milestone, and avoid repeated interruption. A snooze changes reminder visibility only; it never mutates or extends entitlement.

### Value Showcase

Showcase a small set of the product's best shipped capabilities that the person could genuinely use during the trial. Prefer capabilities tied to the product's core job, repeated workflow, organization, speed, continuity, or avoided context switching. Product telemetry may personalize this recap only when its collection and use are already governed, transparent, privacy-safe, and non-sensitive; otherwise use evidenced product-level benefits without claiming individual usage.

Frame each capability as value the product made available, not property being confiscated. Avoid exhaustive feature dumps, generic superlatives, roadmap promises, unsupported outcomes, or claims that the person relied on a feature when no evidence establishes that. The showcase should answer “what useful workflow am I deciding whether to keep?”

For an expired or exhausted trial, sequence the experience as follows:

1. State the access consequence plainly: protected product behavior is paused or unavailable.
2. State the retention boundary plainly: identity and retained user data are not deleted merely because access expired. Never imply deletion, corruption, lock-in, or irreversible loss unless a separate evidenced retention policy actually requires it.
3. Make suspended value concrete with only shipped, evidenced capabilities. Describe what the person can no longer actively do; do not invent outcomes, metrics, testimonials, urgency, or roadmap features.
4. Present the governed offer exactly: verified price, billing cadence, provider path, renewal terms, and any material limitation. Never hide a subscription behind lifetime language or use a countdown unrelated to real entitlement state.
5. Preserve every valid entitlement action. An eligible trial restart, purchase recovery, refresh/recheck, export, privacy control, account recovery, support route, and sign-out must remain discoverable when the product contract provides it. Conversion hierarchy may emphasize purchase, but it must not conceal or misrepresent a server-authorized restart.
6. Keep failure states distinct. Lookup unavailable, pending review, refund, revocation, and provider reconciliation are recovery/support states, not expired-trial sales opportunities. Do not promote purchase as the remedy for an unverified, refunded, revoked, wrong-account, or technically unavailable state unless the verified contract makes purchase the actual remedy.

A founder note may express long-term care, personal commitment, gratitude, and how support funds continued improvement. Keep it visually and semantically separate from entitlement truth and the purchase action. It must not imply that the user owes a purchase, has wasted the founder's effort, is abandoning a person or community, or is responsible for the product's survival.

The preferred emotional arc is calm awareness, recognition of experienced value, clear anticipation of a paused workflow, and confidence in the available decision or recovery. Avoid panic about data, shame, guilt, false urgency, punitive language, or obstruction of recovery. Strong conversion copy is acceptable only inside the same evidence and access boundaries as calm copy.

## Scenario Family

- `SPE-001`: suite product adapts to the canonical ledger; no duplicate ledger.
- `SPE-002`: explicitly standalone product uses the minimum server-owned model.
- `SPE-003`: authenticated identity or client claim alone is denied.
- `SPE-004`: verified provider event grants once; replay is idempotent.
- `SPE-005`: malformed, cross-environment, unknown-product/provider event denies or remains pending review.
- `SPE-006`: activation code is protected, same-user retry is idempotent, and unintended second-user reuse is denied.
- `SPE-007`: backend premium read/write and quota gates ignore client-supplied authorization fields.
- `SPE-008`: mirror/cache becomes non-granting when missing, stale, divergent, revoked, refunded, or expired.
- `SPE-009`: sync and auth failures route to their owners without weakening entitlement truth.
- `SPE-010`: support grant/revoke/refund/expiry path is useful, auditable, and redacted.

## Trial Transition Experience Scenarios

- `TEX-001`: one restart remains; purchase may be prominent, but the server-authorized restart and its exact duration remain clearly available.
- `TEX-002`: all trial cycles are exhausted; the UI explains paused capabilities, retained data, the governed purchase offer, and recovery paths without false urgency.
- `TEX-003`: entitlement lookup is unavailable or pending review; the UI offers retry/support/recovery and does not frame the technical uncertainty as trial expiry.
- `TEX-004`: access is refunded or revoked; the UI explains the verified state and support/reconciliation path without reusing expiry persuasion as a substitute for diagnosis.
- `TEX-005`: a founder message communicates care and gratitude while remaining separate from access truth, price, CTA semantics, and the user's valid alternatives.
- `TEX-006`: before the reminder window, the active trial is not interrupted by premature expiry conversion.
- `TEX-007`: the first real milestone creates calm awareness, states the data boundary, and permits bounded dismissal or snooze without changing entitlement.
- `TEX-008`: the consideration milestone showcases a small set of shipped core capabilities without claiming unsupported personal usage.
- `TEX-009`: the final reminder increases specificity about what pauses and which choices remain, but does not increase guilt, fear, or artificial urgency.
- `TEX-010`: milestone suppression is scoped to the verified trial cycle and reminder; a new legitimate milestone may appear, while repeated interruption inside the same bounded window is prevented.

## Completion Proof

Exercise the smallest representative grant lifecycle with a realistic test account: ingest/grant, query normal backend access, deny unauthorized reuse/cross-user access, revoke/refund/expire, confirm protected denial, replay the event, and inspect redacted support diagnostics. For trial-transition UI, also exercise pre-window silence, each configured milestone, bounded snooze/dismissal, the next milestone, eligible-restart, exhausted, lookup-unavailable, refunded/revoked, retained-data, and recovery-action states. Review showcased claims against shipped product truth and founder copy separately for guilt or debt framing. State untested provider, production, device, UI, or backend surfaces explicitly. UI-only work never proves backend authorization or revocation propagation.
