---
title: ShipGlows post-clone preparation diagnostics
status: active
version: 1.0.0
updated: 2026-08-26
owner: development
depends_on: shipglows-reproducible-environment-control-plane
---

# ShipGlows post-clone preparation diagnostics

## Objective

After a successful clone, diagnose missing, reduced, malformed, and conflicting project configuration without silently modifying project-owned files. Offer a deterministic and explicitly applicable repair only for the missing ShipGlows environment manifest.

## Scope

- Windows clone flow and shared Python environment CLI.
- Bounded monorepo discovery to depth three for Node, Astro, Flutter, Cargo, and Python surfaces.
- Read-only shipglows env prepare and digest-gated shipglows env prepare-apply.
- No dependency installation, deployment, publication, secret access, or remote mutation.

## Ownership and safety contract

- Project manifests, lockfiles, .env, secrets, and foreign configuration are never created, rewritten, normalized, or deleted.
- Existing shipglows.environment.json is validated and preserved byte-for-byte, including when invalid.
- A missing ShipGlows manifest may be created only after explicit apply, from trustworthy detected surfaces, with exclusive-create semantics.
- Hidden directories, dependency/build caches, symlinks, and paths deeper than three levels are excluded.
- Apply re-computes the complete source digest and rejects stale plans.

## Public classifications

| Classification | Meaning | Clone outcome |
| --- | --- | --- |
| healthy | Existing ShipGlows configuration validates | success |
| repairable | Missing ShipGlows manifest can be safely proposed | success with apply command |
| warning | Non-blocking project-owned gap requires attention | success with warning |
| blocked | Invalid trusted source prevents safe inference | clone preserved, preparation fails |
| manual | No trustworthy surface supports generation | success, no configuration invented |

## CLI contract

shipglows env prepare emits deterministic JSON containing classification, detected surfaces, findings, proposed operation, source records, and digest. shipglows env prepare-apply re-inspects the project, rejects stale plans, creates only the proposed ShipGlows manifest, and reports convergence without rewriting an existing valid manifest.

## Acceptance proofs

- Empty repository becomes manual.
- Invalid package manifest becomes blocked and is unchanged.
- Missing ShipGlows configuration in an Astro/Flutter monorepo becomes repairable with both surfaces detected.
- Apply creates one valid manifest; a fresh second apply is a no-op.
- Source changes invalidate a prior digest.
- Clone output reports classification and explicit application; blocking diagnosis preserves the clone and fails preparation.
- Existing environment and Windows contracts remain green.

## History

| Date | Change | Evidence |
| --- | --- | --- |
| 2026-08-26 | Spec created and readiness-reviewed | Approved local plan; ownership and stale-plan gates defined |
| 2026-08-26 | Implementation started | Engine, Windows integration, and contract fixture added |
| 2026-08-26 | Implementation verified | Environment contracts and full Windows DevServer contract passed; CommandGlows detected Flutter, Astro, Node, and pnpm without mutation |
