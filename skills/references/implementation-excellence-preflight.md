---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-08-23"
status: active
source_skill: 900-shipglows-core
scope: implementation-excellence-preflight
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/references/reporting-contract.md
  - skills/references/design-system-token-contract.md
  - skills/references/clean-code-quality-contract.md
  - skills/references/owasp-application-security-awareness.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: skills/references/clean-code-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/owasp-application-security-awareness.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-21: mandatory implementation rules must be explicit before code starts and mechanically enforced again at the end."
  - "Bento review demonstrated that conditional design-token guidance can be skipped when scope recognition remains implicit."
  - "Operator directive 2026-08-21: the frontend preflight must guarantee that essential homepage content remains visible if JavaScript or animation fails."
  - "Operator directive 2026-08-21: the frontend preflight must prefer semantic HTML and native CSS and require a functional justification for JavaScript."
  - "Recovery verification 2026-08-23: focused frontend-gate tests and repository-governance checks passed on the current main baseline."
next_review: "2026-11-21"
next_step: "Apply the preflight before the next substantive authored-code chantier."
---

# Implementation Excellence Preflight

## Purpose And Trigger

Apply this contract to every authored or materially modified code surface, including features, refactors, repairs, migrations, scripts, tests, and infrastructure code. It is a mandatory phase gate, not an optional quality reminder.

Branch-free copy, comment, formatting, metadata, or documentation-only micro-edits use `IEP-MICRO-EDIT`: record that no executable surface changes and do not add ceremony. Generated or vendored code is classified but may use its established generator or upstream authority instead of product-code conventions.

## Phase 1 — Classify Before The First Write

Inspect the repository's existing architecture, conventions, design authority, shared components, data boundaries, and relevant tests. Classify the intended write set as one or more of:

`frontend · backend · shared/domain · infrastructure · documentation-only`

Retain the classification and applicable gates in the execution record. For a substantive code chantier, emit the compact start receipt defined by the reporting contract:

```text
🛡️ GARDE-FOUS ✅ <applicable mandatory rules> · ➖ <non-applicable class and concrete reason, only when useful>
```

Do not write code while a mandatory applicable authority is unknown or contradictory. Resolve it from the repository and canonical ShipGlows references; ask the operator only when the unresolved choice would materially change product behavior, risk, cost, or authority.

## Frontend Gate

For any UI, layout, component, theme, motion, interaction, responsive, or visual surface:

- identify and use the project's canonical design-system authority before choosing visual values
- consume semantic tokens for color, type, spacing, sizing, radius, elevation, motion, breakpoints, and related visual decisions; raw one-off values require the existing literal-exception proof
- inspect and reuse maintained shared components, variants, utilities, and native/headless primitives before creating a new control
- keep behavior and semantics in maintained primitives while project wrappers own composition and tokenized visuals
- prove keyboard/focus behavior, accessible names/states, contrast, target sizes, reduced motion, responsive/adaptive behavior, text scaling, and supported themes when applicable
- keep essential content and primary actions present in the initial semantic document; JavaScript, observers, hydration, transitions, and animation may enhance presentation but must not be required to reveal or unlock them
- use semantic HTML and native CSS by default for structure, layout, responsive behavior, visual states, themes, transitions, and decorative motion; add JavaScript only for a concrete need involving state, data, complex interaction, coordination, or runtime measurement that HTML/CSS cannot express robustly
- record the functional justification for presentation-layer JavaScript and keep its client-owned behavior as small as practical; framework convenience, visual novelty, or library availability alone does not pass the gate
- prove content visibility with failed or disabled JavaScript/animation initialization on public and product-critical pages when applicable; build success or source inspection alone does not prove this fallback
- keep reusable state and domain decisions outside screen-specific presentation code when that improves reuse and proof

Load the design-system token contract directly from the activating skill and apply its drift scan to changed UI files. A local component or raw literal is not justified merely because it is faster.

## Backend Gate

For any API, persistence, synchronization, authentication, authorization, job, webhook, migration, or privileged surface:

- validate untrusted input at the authoritative boundary and keep errors actionable without leaking sensitive data
- enforce authentication, authorization, tenant/resource ownership, and data isolation server-side; client checks are UX only
- reason explicitly about stale writes, duplicate delivery, replay, races, ordering, transactions, idempotence, retries, and partial failure where applicable
- preserve deterministic error behavior, recovery/rollback, observability, auditability, and safe defaults
- make schema and data migrations additive, bounded, recoverable, backward-compatible for the declared window, and proven before destructive retirement
- keep secrets and privileged operations out of clients, logs, generated artifacts, and user-facing diagnostics

Load the OWASP contract directly for internet-facing or privileged work. No passing client test can substitute for authoritative server-boundary proof.

## Shared/Domain And Infrastructure Gate

- Separate domain rules and pure decisions from framework, UI, storage, transport, and provider adapters when the rule has multiple consumers or independent test value.
- Keep adapters stack-native; stack-agnostic means portable domain meaning, not a custom lowest-common-denominator framework.
- Inspect existing abstractions before adding one. Reuse canonical knowledge, follow DRY/AHA and the Rule of Three, and avoid both copy-paste drift and speculative generalization.
- Keep configuration validated, least-privileged, reproducible, observable, and free of embedded secrets. Infrastructure changes retain rollback and environment-boundary proof.
- Apply the clean-code contract to all authored code: intent, cohesion, controlled complexity, explicit side effects, behavior-focused tests, no dead/debug residue, and production-ready finish.

## Phase 2 — Reclassify During Implementation

If the write set or behavior crosses a new class or trust boundary, stop before the new write, update the classification, load the newly applicable direct contracts, and extend the proof path. `IEP-SCOPE-GROWTH` forbids carrying a frontend-only receipt into backend mutation or a local-only receipt into hosted/external effects.

Prefer existing shared authority over a local workaround. When an exception is genuinely required, record the constraint, why the canonical path cannot apply, the narrowest safe alternative, and the proof that prevents drift.

## Phase 3 — Enforce Before Completion

Re-run every applicable gate against the actual diff, not the initial intention. Retain an `Implementation Excellence Gate` verdict covering:

`classification · existing-authority reuse · frontend tokens/primitives/a11y/responsive/themes · backend validation/authz/isolation/concurrency/recovery/migrations · shared boundaries/DRY · focused proof`

Use `pass`, `partial`, `fail`, or `not applicable`, with evidence for exceptions and every non-pass. A declaration, green lint, or passing build is supporting evidence only. `IEP-FINAL-ENFORCEMENT` forbids a clean verification or completion claim while a material applicable obligation remains unresolved.

## Pressure Scenarios

- `IEP-FRONTEND-TOKENS`: raw visual values outside the canonical design authority fail or require the existing narrow exception proof.
- `IEP-FRONTEND-PRIMITIVE`: a bespoke control that duplicates a maintained shared or accessible primitive fails until reused or explicitly justified and proven.
- `IEP-FRONTEND-CONTENT-AVAILABILITY`: essential content or primary actions hidden until JavaScript, observers, hydration, or animation initializes fail the frontend gate until the initial semantic document and failure-path proof preserve access.
- `IEP-FRONTEND-CSS-FIRST`: presentation-layer JavaScript without a recorded functional need that HTML/CSS cannot robustly meet fails the frontend gate; retain the smallest justified behavior over a JavaScript-free dogma when state, data, complex interaction, coordination, or runtime measurement is genuinely required.
- `IEP-BACKEND-AUTHZ`: client-only permission checks fail the backend gate.
- `IEP-BACKEND-CONCURRENCY`: mutation or autosave code must address applicable stale-write, replay, idempotence, partial-failure, and recovery behavior.
- `IEP-SHARED-BOUNDARY`: reusable domain decisions stay independent of presentation or provider adapters when that boundary has concrete value.
- `IEP-SCOPE-GROWTH`: newly crossed surfaces trigger classification and proof updates before writing.
- `IEP-FINAL-ENFORCEMENT`: unresolved applicable obligations prevent a clean verdict even when technical checks pass.
- `IEP-MICRO-EDIT`: non-executable branch-free edits remain proportional and skip the start receipt.
