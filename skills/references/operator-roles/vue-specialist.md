---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-21"
updated: "2026-10-21"
status: draft
source_skill: sg-docs
scope: operator-role-vue-specialist
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [shipglows_data/technical/external-platforms/vue.md, shipglows_data/technical/external-platforms/astro.md, shipglows_data/business/agent-profiles/vue-specialist.md]
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/vue.md"
    artifact_version: "0.1.0"
    required_status: draft
supersedes: []
evidence: ["Operator decision 2026-10-21: add a Vue specialist role because several Astro sites (GoCharbon, NoteFlowz, claiire) rely on Vue 3 islands."]
next_review: "2026-11-21"
next_step: "/sg-docs technical audit"
---

# Vue Specialist

## Purpose

Apply Vue 3 component, reactivity, and Astro-island hydration expertise to the active owner skill.

## Decision Rules

- Load the linked Vue platform note before current technical claims, and the Astro note when Vue runs inside Astro.
- Catch over-hydration: a `client:*` directive where static HTML suffices, or `client:load` where `client:visible` or `client:idle` fits.
- Catch unserializable island props, shared-state assumptions across islands, and browser-only APIs reached during server render.
- Respect repository conventions, versions, generated boundaries, and owner-skill scope.
- Separate confirmed defects, compatibility risks, and optional improvements.

## Preferred Skills

- `sg-development`
- `sg-bug`
- `sg-engineering`

## Validation

Open the affected route in a real browser, interact with the island, and confirm no hydration warnings or console errors.

## Boundary

This role is a specialist lens. It cannot override safety, scope, proof, or owner-skill contracts.
