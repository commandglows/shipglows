---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-09-01"
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
  - "Operator decision 2026-09-01: non-live projects integrate directly to main; live projects use canonical dev for integration/staging and retain main for production."
  - "Operator decision 2026-08-21: use development, published, and sensitive-production as human-facing project delivery postures."
  - "Operator correction 2026-08-21: development never means local-only; remote Git persistence remains mandatory."
next_review: "2026-11-21"
next_step: /103-sg-verify project-delivery-policy
---

# Project Delivery Policy

## Purpose

Every governed project declares its product maturity separately from its validation surface and observed provider state. A development posture can use local validation while still requiring remote Git persistence. Never interpret `development` as `local-only`.

## Canonical Project Section

Store this data-only section in project `CLAUDE.md`, or `SHIPGLOWS.md` when no `CLAUDE.md` exists:

```markdown
## ShipGlows Delivery Policy

- delivery_posture: development | published | sensitive-production
- production_branch: main | [documented alternative]
- integration_branch: main | dev
- staging_branch: not-required | dev
- work_branch_strategy: direct-integration | short-lived | [documented exception]
- remote_persistence: milestone-and-final
- preview_policy: optional | required
- staging_policy: not-required | required | equivalent-isolation
- production_delivery: disabled | gated
- provider_state: observed | partially-observed | unknown
- last_reviewed: YYYY-MM-DD
- notes: [short project-specific exception or unknown]
```

This section contains no secret, token, executable command, provider credential, or machine-specific path. The declared policy is durable intent; provider APIs, repository settings, and deployment evidence are observed state. Detection may report drift but never silently rewrite declared intent.

## Postures And Derived Defaults

| Posture | Canonical integration branch | Preview | Staging | Production delivery |
| --- | --- | --- | --- | --- |
| `development` (non-live) | `main` | optional unless validation mode or changed behavior requires it | not required | disabled by default |
| `published` (live) | `dev` | required before promotion to production | canonical `dev` | gated `dev -> main` |
| `sensitive-production` (live) | `dev` | required | canonical `dev` plus required isolation evidence | gated `dev -> main` with stronger evidence |

All postures use `production_branch: main`. Non-live `development` uses `integration_branch: main`, `staging_branch: not-required`, and may work directly on the integration branch. Live `published` and `sensitive-production` use the exact canonical branch `dev` for integration and staging; short-lived task branches reconcile continuously into `dev`. ShipGlows creates or converges the declared integration branch and remote tracking without a validation prompt when safe.

Git/GitHub stewardship is continuous and autonomous. At project or chantier start, coherent milestones, and chantier end, fetch/prune and reconcile safe owned branches, pull requests, upstreams, and worktrees; commit and push coherent validated work to the canonical integration branch at the earliest safe opportunity. Promotion to `main` follows release/deployment gates but adds no separate Git approval.

## Separate Axes

- `delivery_posture` answers how mature and operationally sensitive the product is.
- `development_mode` from `project-development-mode.md` answers where changed behavior can be validated authoritatively.
- `provider_state` answers what Git and hosting configuration has actually been observed.

One axis never overrides another. A local validation surface does not waive remote persistence. A successful push does not prove preview, staging, deployment, or production behavior. A detected provider does not authorize non-Git environment or deployment changes; ordinary Git/GitHub convergence retains its standing authority.

## Migration And Inference

Existing projects with only `ShipGlows Development Mode` remain valid. Treat their delivery posture as `unknown`, preserve their existing mode, and propose the smallest explicit policy update during bootstrap or the next delivery-policy review. Never infer `published` merely from a production URL, or `development` merely from local scripts.

If no policy exists, ShipGlows may recommend `development` only as a provisional operator-visible default when no published-product evidence exists. Published status, production sensitivity, revenue exposure, real-user data, payments, auth, webhooks, migrations, and production permissions are material evidence and must not be downgraded silently.

## Drift And Failure Rules

- Missing or unsupported values fail visibly as `delivery policy unknown`.
- `remote_persistence` other than `milestone-and-final` is non-compliant.
- `published` with optional preview is contradictory for deployable changes.
- `sensitive-production` without staging or documented equivalent isolation is contradictory.
- A missing declared branch, unavailable remote, failed push, or unobserved protection remains delivery pending; never claim clean closure.
- Deployment and environment creation require their own authority. Ordinary Git/GitHub configuration convergence, protection-preserving merges, reconciliation, and proven cleanup use standing Git stewardship authority; never weaken or bypass protection.

## Managed GitHub Protection

Every active ShipGlows-managed GitHub repository follows `managed-project-ci-policy.md`: protect the production branch with the exact always-on `ShipGlows required gate`, never directly require a routinely path-filtered job, and install plus prove the workflow before enabling its ruleset requirement. This applies to `development`, `published`, and `sensitive-production`; maturity changes proof depth, not the existence of baseline protection. Non-GitHub, archived, generated-mirror, or intentionally unprotected repositories require an explicit reviewed exception.

## Pressure Scenarios

- `PDP-DEVELOPMENT-NOT-LOCAL-ONLY`: development retains milestone and final remote persistence.
- `PDP-SEPARATE-AXES`: posture, validation mode, and provider state remain independent.
- `PDP-PUBLISHED-PREVIEW`: published deployable changes require preview-backed review.
- `PDP-SENSITIVE-STAGING`: sensitive production requires staging or equivalent isolation.
- `PDP-NON-LIVE-MAIN`: non-live `development` integrates directly into `main`.
- `PDP-LIVE-DEV`: live `published` and `sensitive-production` integrate and stage through canonical `dev`, retaining `main` for production.
- `PDP-GIT-AUTONOMY`: ordinary commit, push, reconciliation, PR/worktree convergence, and proven cleanup require no validation prompt.
- `PDP-DECLARED-VS-OBSERVED`: detected state reports drift without mutating intent.
- `PDP-LEGACY-MODE`: legacy development mode remains valid while posture is unknown.
- `PDP-MANAGED-CI`: every active managed GitHub project retains an always-on protected gate without path-filter deadlock.
