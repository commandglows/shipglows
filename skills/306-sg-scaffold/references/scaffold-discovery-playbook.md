---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 306-sg-scaffold
scope: scaffold-discovery
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: no
linked_systems:
  - skills/306-sg-scaffold/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted project-pattern discovery from the scaffold activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Scaffold Discovery Playbook

Load this reference after the scaffold type and name are known.

## Establish intent and risk

Identify the actor, user-facing outcome, surface visibility, surrounding flow, sensitive data, privileged actions, external services, and documentation surfaces. Ask only questions whose answers materially change behavior, scope, security, claims, or coherence.

## Read project evidence

Find and read 2-3 complete examples of the requested type. Also inspect the nearest owner files:

- page: layout, route group, navigation, metadata, loading and error states;
- component: parent surface, primitives, styles, tests, and stories;
- API: middleware, validators, service layer, neighboring endpoints, and contract tests;
- content: sibling entries, schema, listing surface, and SEO fields.

Extract extension, naming, imports, exports, framework conventions, typing, styling, design-system authority, validation, flow states, terminology, security enforcement, tenant ownership, and documentation pattern.

When Supabase is present, determine the browser/server/service-role boundary, RLS/tenant enforcement, and storage-row consistency before generation. Load only the reference for the boundary actually used.

## Decide

Project evidence overrides blueprint conventions. A loaded blueprint fills only genuine gaps unless the project is a clean slate. Inference is last resort and cannot supply security, claims, privileged behavior, or visual authority.

Produce a compact generation contract: destination, naming, imports/exports, adjacent integration, states, security controls, design authority, docs impact, and unresolved stops. Only then load the generation playbook.
