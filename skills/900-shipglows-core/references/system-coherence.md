---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-27"
updated: "2026-08-27"
status: active
source_skill: 900-shipglows-core
scope: shipglows-dx-system-coherence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - skills/references/skill-invocation-registry.json
  - cli/
  - local/
  - tui/
  - plugins/shipglows/
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/code-docs-map.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-27: skills, CLI, TUI, and DevServer must evolve as one coherent ShipGlows DX system without absorbing the separate shipglows_app site/SaaS product."
next_step: none
---

# ShipGlows DX System Coherence

Use for a bare Core system audit or a scoped `audit|build` target that crosses at least two ShipGlows DX planes. Core remains the integration owner; each plane keeps one canonical implementation and proof owner.

## DX planes

| Plane | Canonical surface | Truth and proof |
| --- | --- | --- |
| Agent behavior | `skills/`, shared references, activation registry, skill tools | Activation contract, registry graph, scenario-first checks, runtime skill visibility |
| Runtime behavior | `cli/`, `local/`, `tui/`, root installers | Runtime code, mapped tests, installed/active-state proof when applicable |
| Distribution | `plugins/shipglows/`, bootstrap and skill-sync tooling | Manifest/package validation, bootstrap contract, runtime-link proof |
| Governance | architecture, context, code-doc map, lifecycle and help docs | Metadata lint, source-of-truth links, stale-contract scans |

`shipglows_app` is outside every plane in this contract. It owns the public site and SaaS. A quoted product goal may explain why DX behavior should change, but it never grants Core authority to edit that repository.

## Coherence gate

Before mutation, record one compact impact map:

1. operator trigger and observable DX outcome;
2. canonical owner plane and integration owner;
3. every secondary consumer whose behavior or instructions change;
4. exact proof per affected plane;
5. documentation, help, packaging, install/reload, and active-runtime consequences;
6. explicit non-impacted planes with a concrete reason.

Prefer one canonical rule with direct consumers. Do not copy runtime procedure into skills, encode agent-only aliases in the shell CLI, or let documentation override executable code. Runtime behavior is decided by code plus tests; agent behavior by the activation contract plus registry; repository/product boundaries by canonical terms plus architecture; code-to-doc consequences by the code-doc map.

## Lifecycle

- Bare `audit` is read-only and uses the smallest drift scan that covers all declared planes; it never implies a full repository health audit.
- Non-trivial `build` requires one ready spec, one integration owner, ordered tasks, scenario-first cross-plane proof, and the ordinary verification/closure/delivery route.
- A single-plane finding exits this pack and uses the skill or DX runtime playbook instead of retaining cross-surface ceremony.
- A material new plane, public promise, security boundary, installation effect, or external write stops for refreshed scope and authority.

## Pressure scenarios

- `CORE-DX-SKILL`: one skill/doctrine target loads only skill maintenance.
- `CORE-DX-RUNTIME`: one CLI/TUI/DevServer/installer target loads only DX runtime maintenance.
- `CORE-DX-COHERENCE`: one behavior spanning agent and runtime surfaces has one integration owner and proof for both planes.
- `CORE-DX-APP-BOUNDARY`: `shipglows_app` site/SaaS language remains evidence only and never becomes a Core edit target.
- `CORE-DX-MISSING-PACK`: a missing direct pack blocks; no sibling or deprecated-pilot fallback is allowed.

## Validation

Use focused contract tests for the impact map and boundary scenarios, then run only the mapped checks for planes actually changed. Activation graph, skill/runtime sync, package validation, CLI/Windows suites, metadata lint, and installed-runtime proof are conditional evidence, not an eager bundle.
