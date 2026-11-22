---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-11-21"
status: active
source_skill: 900-shipglows-core
scope: project-delivery-policy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-development-mode.md
  - skills/references/git-milestone-delivery-contract.md
  - skills/305-sg-init
  - skills/005-sg-ship
  - skills/references/managed-project-ci-policy.md
depends_on:
  - artifact: skills/references/project-development-mode.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Implementation proof 2026-09-01: required CI workflows target production main and resolved live integration dev."
  - "Operator decisions 2026-09-01: posture lives only in canonical business context; non-live projects integrate into main, live projects use canonical dev for integration/staging and keep main for production."
  - "Operator decisions 2026-08-21: development, published and sensitive-production are the human-facing postures; development never means local-only and remote Git persistence stays mandatory."
next_review: "2026-11-21"
next_step: /103-sg-verify project-delivery-policy
---

# Project Delivery Policy

## Purpose

Every governed project declares its product maturity separately from its validation surface and observed provider state. A development posture can use local validation while still requiring remote Git persistence. Never interpret `development` as `local-only`.

## Canonical Project Source

Store product maturity exactly once in the frontmatter of the governance-root `shipglows_data/business/business.md`:

```yaml
delivery_posture: development | published | sensitive-production
```

This business fact is the only authority for live versus non-live. `PITCH.md` never owns operational truth. `ENVIRONMENT.md` and the DevServer registry describe runtime assignment and active processes; runtime `live` never means product `published`. `CLAUDE.md`, `SHIPGLOWS.md` and `AGENT.md` never own delivery posture.

Never infer missing posture from a production URL, running process, provider, or branch name. Ask the product owner before choosing a branch.

## Postures And Derived Defaults

| Posture | Canonical integration branch | Preview | Staging | Production delivery |
| --- | --- | --- | --- | --- |
| `development` (non-live) | `main` | optional unless validation mode or changed behavior requires it | not required | disabled by default |
| `published` (live) | `dev` | required before promotion to production | canonical `dev` | gated `dev -> main` |
| `sensitive-production` (live) | `dev` | required | canonical `dev` plus required isolation evidence | gated `dev -> main` with stronger evidence |

All branch and release fields are derived rather than duplicated in another governance file. All postures use `production_branch: main`. Non-live `development` derives `integration_branch: main`, `staging_branch: not-required`, and may work directly on the integration branch. Live `published` and `sensitive-production` derive the exact canonical branch `dev` for integration and staging; short-lived task branches reconcile continuously into `dev`.

## Dev/Live Launch Protection Projection

Status surfaces render `development` as `Dev` and both live postures as `Live`; no reminder claims public protection without hosted evidence.

## Separate Axes

- `delivery_posture` answers how mature and operationally sensitive the product is.
- `development_mode` from `project-development-mode.md` answers where changed behavior can be validated authoritatively.
- `provider_state` answers what Git, process, URL, and hosting configuration has actually been observed and belongs in operational evidence surfaces, not in business posture.
- Repository frontmatter fields `task_branch_policy` and `worktree_policy`, read by `tools/project_git_policy.py`, govern temporary branch and worktree creation independently. Missing or invalid values resolve to `forbidden`; when policy forbids creation, ShipGlows does not create silently. `allowed` is permission, never a requirement or preference. A preexisting worktree remains governed by applicable safety rules.

One axis never overrides another. A local validation surface does not waive remote persistence. A successful push does not prove preview, staging, deployment, or production behavior. A detected provider does not authorize Git, non-Git environment, or deployment changes.

## Migration And Inference

Old `ShipGlows Delivery Policy` blocks in `CLAUDE.md` or `SHIPGLOWS.md` are migration evidence only, never authority. Existing `ShipGlows Development Mode` remains separate validation-surface truth.

If canonical business context or its field is absent, ShipGlows reports `delivery policy unknown` and asks the product question before choosing an integration branch. It may recommend `development` only when no published-product evidence exists. Published status, production sensitivity, revenue exposure, real-user data, payments, auth, webhooks, migrations, and production permissions are material evidence and must not be downgraded silently.

## Drift And Failure Rules

- Missing or unsupported canonical values fail visibly as `delivery policy unknown`.
- `remote_persistence` other than `milestone-and-final` is non-compliant.
- `published` with optional preview is contradictory for deployable changes.
- `sensitive-production` without staging or documented equivalent isolation is contradictory.
- A missing declared branch, unavailable remote, failed push, or unobserved protection remains delivery pending; never claim clean closure.
- Preserve branch protection and never bypass an action-specific safety gate.

## Managed GitHub Protection

Every active ShipGlows-managed GitHub repository follows `managed-project-ci-policy.md`: protect the production branch with the exact always-on `ShipGlows required gate`, never directly require a routinely path-filtered job, and install plus prove the workflow before enabling its ruleset requirement. Live projects trigger required workflows on production `main` and canonical `dev`, with protection on both. Every posture (`development`, `published`, `sensitive-production`) keeps baseline protection; maturity changes proof depth only. Non-GitHub, archived, generated-mirror or intentionally unprotected repositories need an explicit reviewed exception.

## Pressure Scenarios

- `PDP-DEVELOPMENT-NOT-LOCAL-ONLY`: development retains milestone and final remote persistence (`remote_persistence: milestone-and-final`) and pushes coherent validated work to the canonical integration branch at the earliest safe opportunity.
- `PDP-SEPARATE-AXES`: posture, validation mode, and provider state remain independent.
- `PDP-PUBLISHED-PREVIEW`: published deployable changes require preview-backed review.
- `PDP-SENSITIVE-STAGING`: sensitive production requires staging or equivalent isolation.
- `PDP-NON-LIVE-MAIN`: non-live `development` integrates directly into `main`.
- `PDP-LIVE-DEV`: live `published` and `sensitive-production` integrate and stage through canonical `dev`, retaining `main` for production.
- `PDP-GIT-AUTONOMY`: Git/GitHub stewardship at project or chantier start, coherent milestones, and chantier end follows `mutation-git-authority.md` and adds no separate Git approval.
- `PDP-DECLARED-VS-OBSERVED`: detected state reports drift without mutating intent.
- `PDP-LEGACY-MODE`: legacy development mode remains valid while posture is unknown.
- `PDP-MANAGED-CI`: every active managed GitHub project retains an always-on protected gate without path-filter deadlock.
