---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-08-12"
status: active
source_skill: 006-sg-design
scope: design-playground
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-token-migration-playbook.md
  - skills/references/design-system-token-contract.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "1.2.0"
    required_status: active
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
supersedes:
  - skills/501-sg-design-playground/SKILL.md
evidence:
  - "Migrated and revalidated from 501-sg-design-playground on 2026-07-15."
next_step: "/103-sg-verify design playground"
---

# Design Playground Playbook

## Activation

Use for `sg-design playground [route-path]`; default route is `/design-system`. This mode scaffolds a versioned UI over an existing canonical design-token source. It must never seed or become a parallel token store.

## Pre-Checks

1. Load the design-system token contract and identify the production-consumed authority. If no real authority exists, stop and route to `006-sg-design system`.
2. Detect the framework. Supported generation targets are Next.js App/Pages Router, Astro, SvelteKit, Nuxt 3, Remix, and Vite React/Vue/Svelte. Unsupported or native-only targets receive a documented manual route; do not generate ad-hoc code.
3. If multiple token sources exist, report split-brain risk and resolve the production authority before enabling save/export.
4. If the target route exists, ask one bounded decision: `augment`, `replace`, or `cancel`. Never overwrite silently.

## Token Manifest

Build a manifest for colors, typography, spacing, radius/elevation, and motion with source file, source format, token names, theme coverage, and production consumers. Support existing CSS custom properties, Tailwind theme values, typed JS/TS theme objects, and DTCG JSON. Preserve the project’s naming and serialization format.

## Page Contract

Generate one framework-native route using existing components and styles. It includes:

1. theme switcher for every supported mode, including system behavior
2. color groups with token name, computed value, live preview, and contrast against primary surface/text roles
3. typography samples with size, line-height, letter-spacing, loaded font roles, and adjacent modular ratios
4. spacing/radius/elevation visualization with adjacent ratios or scale position
5. motion demos with duration/easing and a reduced-motion simulation
6. sticky action/status bar with `Copy`, `Save` when allowed, `Export`, unsaved count, saved state, and safe error state

Live editing changes preview state only. Copy and client-side export serialize the canonical format. Playground-only token names, hidden parallel state, and unrelated component/icon galleries are forbidden.

## Production Access Gate

The route gate is server-side whenever the framework provides a server boundary:

```text
NODE_ENV != production -> local development access
production + existing auth -> reuse the existing admin authorization contract
production + no auth -> password from DESIGN_SYSTEM_PASSWORD
missing production password -> 404
```

- Reuse the project’s real admin role/claim; if it is unclear, stop and ask one targeted authorization question.
- Password comparison must be constant-time and the resulting session bounded (24 hours maximum by default).
- Return 404 when the production gate is not configured so the route is not advertised.
- Vite SPA has no trustworthy server gate. Mark production gating unsupported and require an external access layer; client-only gating is not security.

Use the native server surface: Next middleware/server component/SSR, Astro middleware, SvelteKit server layout, Nuxt server middleware, or Remix loader. Do not invent a second auth system.

## Dev-Only Save Endpoint

Direct file mutation is optional and must satisfy all conditions:

1. **Dev-only:** return 404 whenever `NODE_ENV === 'production'`, regardless of authentication.
2. **Path-locked:** hardcode the canonical token path server-side; accept no client-provided path.
3. **Format-validated:** parse and validate CSS, JSON/DTCG, or typed-object input before writing.
4. **Backup-first:** create a timestamped backup of the current authority before replacement.
5. **Bounded input:** reject unknown token names, unsupported types, oversized payloads, and values outside the declared domain.
6. **No secret exposure:** return bounded errors and never serialize environment values, internal paths beyond the declared project path, or stack traces.

Vite SPA cannot expose Save. Hide the control and keep Copy/Export. The endpoint may update the authority only; it must not update arbitrary files.

## Project Integration

Match existing language, module format, code style, routing, theme, auth, and component patterns. Update `.env.example`, README/operator guidance, and project conventions only when the generated gate or route introduces a real setup obligation. Do not write audit/task trackers unless the selected lifecycle owner explicitly permits it and the operational-record contract has been loaded.

## Proof Contract

Before claiming success:

- build/typecheck the affected site surface
- verify the route collision decision was honored
- prove theme switching, live preview, Copy, Export, reduced-motion simulation, and status/error states
- prove Save writes only the canonical source in development and returns 404 in production configuration
- prove a missing/invalid payload and forbidden token/path cannot write
- prove the production route is admin/password-gated or document the Vite external-gate requirement
- run browser proof for the generated route

Report framework, route, canonical source, supported token domains, production access strategy, Save availability, files changed, checks, and token-consumption status. The playground is not proof that pages/components consume the authority; route incomplete consumption through the token-migration playbook.

## Stop Conditions

Stop when the authority is missing or split, the framework is unsupported for safe generation, the route collision is unresolved, the production authorization contract is unclear, or any Save guarantee cannot be implemented and proven. Never weaken the gate to complete scaffolding.
