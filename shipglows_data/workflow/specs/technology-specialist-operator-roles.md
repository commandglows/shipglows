---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: ready
source_skill: 100-sg-spec
scope: technology-specialist-operator-roles
owner: Diane
user_story: "As a ShipGlows operator, I want compact technology specialist profiles that load canonical technical references, so agents apply current stack-specific rules without duplicating workflows or vendor documentation."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/operator-roles/
  - skills/references/profile-activation.md
  - shipglows_data/business/agent-profiles/
  - shipglows_data/technical/external-platforms/
depends_on:
  - artifact: "skills/references/profile-activation.md"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-12: create a bounded catalog of technology specialist roles, exclude Supabase, and include TypeScript, JavaScript, Flutter, and Dart."
  - "Neovim specialist role, profile, and platform note provide the approved implementation pattern."
  - "Operator decision 2026-07-12: classify Turso and CrewAI as specialist roles; keep Hono and future candidates as reference-only until adopted."
next_step: "/103-sg-verify technology-specialist-operator-roles"
---

# Technology Specialist Operator Roles

## Status

ready

## Scope In

- Keep the existing `neovim-specialist` as the reference implementation.
- Add specialist roles and invokable profiles for Python, Bash, Astro, TypeScript, JavaScript, Flutter, Dart, Firebase, Convex, Vercel, Sentry, and grouped cloud integrations.
- Link each role to an existing canonical platform note when one exists.
- Keep roles compact: decision rules, preferred skills, validation expectations, and boundaries.
- Add missing platform notes only for technologies without canonical coverage.
- Register explicit profile aliases in `profile-activation.md`.

## Scope Out

- No Supabase specialist role.
- No new owner skills or workflow duplication.
- No copied vendor documentation or model-specific prompt tricks.
- No public site pages in this initial internal catalog pass.
- No specialist roles for Hono, PydanticAI, LangGraph, Cloudflare Workers, Drizzle, or TanStack Start until concrete recurring project use justifies decision posture.

## Acceptance Criteria

- Every specialist has one operator-role contract and one agent-profile reference.
- Every role points to a canonical platform note or an explicit shared technical owner.
- Roles cannot override safety, scope, proof, or owner-skill contracts.
- Profile aliases resolve through the existing activation contract.
- Metadata lint and skill budget audit pass.

## Implementation Tasks

- [x] Add missing platform notes for TypeScript/JavaScript and Flutter/Dart.
- [x] Add specialist role contracts.
- [x] Add matching agent profiles.
- [x] Register aliases in the profile activation contract.
- [x] Validate metadata, references, and skill budgets.
- [x] Add Turso platform note, specialist role, and profile.
- [x] Add CrewAI specialist role and profile using the existing platform note.
- [x] Add reference-only notes for PydanticAI, LangGraph, Cloudflare Workers, Hono, Drizzle ORM, and TanStack Start.
- [x] Register Turso and CrewAI activation aliases and validate the expanded catalog.

## Execution Batches

| Batch | Ownership | Write set | Dependency |
| --- | --- | --- | --- |
| A | Turso specialist | `external-platforms/turso.md`, `operator-roles/turso-specialist.md`, `agent-profiles/turso-specialist.md` | none |
| B | CrewAI specialist | `operator-roles/crewai-specialist.md`, `agent-profiles/crewai-specialist.md` | existing `crewai.md` |
| C | Python agent references | `external-platforms/pydanticai.md`, `external-platforms/langgraph.md` | none |
| D | Edge references | `external-platforms/cloudflare-workers.md`, `external-platforms/hono.md` | none |
| E | TypeScript data/framework references | `external-platforms/drizzle-orm.md`, `external-platforms/tanstack-start.md` | none |

## Current Chantier Flow

`100-sg-spec ✅ -> 101-sg-ready ✅ -> 009-sg-skill-build ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> 005-sg-ship ✅`

## Skill Run History

| Date | Skill | Result | Evidence | Next step |
| --- | --- | --- | --- | --- |
| 2026-07-12 | 100-sg-spec | ready | Scope and acceptance criteria derived from operator decisions and existing Neovim pattern. | 009-sg-skill-build |
| 2026-07-12 | 101-sg-ready | ready | Bounded file families, exclusions, proof path, and no duplicate workflow ownership. | 009-sg-skill-build |
| 2026-07-12 | 009-sg-skill-build | implemented | Added specialist contracts, profiles, platform notes, and activation aliases. | 103-sg-verify |
| 2026-07-12 | 103-sg-verify | verified | Metadata lint passed for 36 artifacts; role/profile pairing, activation aliases, skill audit, budget audit, and diff checks passed. | 005-sg-ship when requested |
| 2026-07-12 | 706-continue | implemented | Parallel workers hit usage limits; resumed locally and completed Turso/CrewAI roles plus six reference-only technology notes. | 103-sg-verify expanded catalog |
| 2026-07-12 | 103-sg-verify | verified | Metadata lint passed for 63 artifacts; role/profile pairing, reference-only boundaries, activation aliases, skill audit, budget audit, and diff checks passed. | 005-sg-ship when requested |
| 2026-07-12 | 104-sg-end | complete | TASKS and CHANGELOG aligned; spec and research retain durable decisions and proof. | 005-sg-ship end |
| 2026-07-12 | 005-sg-ship | shipped | Full-close scope validated and isolated from unrelated dirty files for commit and push. | none |
