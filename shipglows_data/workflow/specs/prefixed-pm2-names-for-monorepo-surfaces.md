---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-11"
created_at: "2026-07-11 00:00:00 UTC"
updated: "2026-07-11"
updated_at: "2026-07-11 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "runtime naming migration"
owner: "Diane"
user_story: "As a ShipGlows operator, I want every generic monorepo surface to carry its project prefix so PM2 identities never collide."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems: ["cli/lib.sh", "PM2", "ecosystem.config.cjs", "runtime CLI documentation"]
depends_on:
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.5.0"
    required_status: reviewed
supersedes: []
evidence: ["Operator decision on 2026-07-11", "Duplicate generic PM2 names app/site/lab found across projects"]
next_step: "/102-sg-start prefixed-pm2-names-for-monorepo-surfaces"
---

# Spec: Prefixed PM2 names for monorepo surfaces

## Title

Prefixed PM2 names for monorepo surfaces

## Status

ready

## User Story

As a ShipGlows operator, I want every generic monorepo surface to carry its project prefix so PM2 identities never collide.

## Minimal Behavior Contract

When ShipGlows receives a project directory named `app`, `site`, `lab`, or `worker`, it produces `<parent>_<role>` as the PM2 identity; already-specific directory names remain unchanged, and an invalid empty path fails instead of creating an ambiguous identity.

## Success Behavior

- Starting, stopping, restarting, querying, or viewing logs for the same path resolves the same prefixed PM2 name.
- Existing ecosystem files use the convention after migration.

## Error Behavior

- Empty or parentless input returns failure and does not mutate PM2.

## Problem

Using only the directory basename creates repeated `app`, `site`, and `lab` identities across monorepos.

## Solution

Centralize name derivation in one helper and use it throughout the environment lifecycle, then migrate existing generated configs.

## Scope In

- Generic roles `app`, `site`, `lab`, and `worker`.
- All lifecycle lookups in `cli/lib.sh`.
- Existing ecosystem files under `/home/claude`.

## Scope Out

- Renaming physical directories.
- Automatically starting or restarting PM2 applications.

## Constraints

- Preserve names that are already specific.
- Do not alter PM2 runtime state during file migration.

## Test Contract

- Shell syntax and focused naming regression tests.
- Static audit of every ecosystem config.

## Dependencies

- Local Bash, Node.js, and PM2 config format; fresh external docs not needed.

## Invariants

- Every lifecycle operation derives the same identity from a path.
- Generated config remains the runtime artifact, not a hand-maintained source of truth.

## Links & Consequences

- PM2 entries using legacy names require reconciliation on their next managed start.

## Documentation Coherence

- Update the runtime CLI doctrine with the naming rule.

## Edge Cases

- Root-level project names remain unchanged.
- Already-prefixed names such as `winglowz_app` remain unchanged.

## Implementation Tasks

- [x] Add and adopt centralized PM2 name derivation in `cli/lib.sh`.
- [x] Add focused regression coverage in `tests/cli/input-validation.sh`.
- [x] Migrate existing ecosystem configs and repair confirmed config defects.
- [x] Update runtime documentation and run validation.

## Acceptance Criteria

- [x] Given `/home/claude/contentglowz/app`, when identity is derived, then it is `contentglowz_app`.
- [x] Given `/home/claude/socialglowz`, when identity is derived, then it remains `socialglowz`.
- [x] No ecosystem config uses a bare generic role as its PM2 name.
- [x] Shell syntax and focused tests pass.

## Test Strategy

- Unit: focused shell assertions in `tests/cli/input-validation.sh`.
- Integration: load and audit all ecosystem configs with Node.js.
- Manual: none.

## Risks

- Stale PM2 entries retain legacy names until explicitly reconciled; migration must not start stopped apps.

## Execution Notes

- Validate with `bash -n cli/lib.sh tests/cli/input-validation.sh` and `bash tests/cli/input-validation.sh`.
- Do not restart PM2 apps as part of this migration.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-07-11 00:00:00 UTC | 100-sg-spec | GPT-5 Codex | Created implementation contract | draft | 101-sg-ready |
| 2026-07-11 00:00:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed deterministic naming contract | ready | 102-sg-start |
| 2026-07-11 00:00:00 UTC | 102-sg-start | GPT-5 Codex | Implemented centralized naming and migrated configs | implemented | 103-sg-verify |

## Current Chantier Flow

- `100-sg-spec`: done.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `103-sg-verify`: not launched.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: `/103-sg-verify prefixed-pm2-names-for-monorepo-surfaces`
