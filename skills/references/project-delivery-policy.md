---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.6.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-09-03"
status: active
source_skill: 900-shipglows-core
scope: project-delivery-policy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/business/business.md
  - shipglows_data/technical/guidelines.md
  - templates/business_context.md
  - templates/technical_guidelines.md
  - tools/project_delivery_policy.py
  - tools/project_git_policy.py
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
  - "Operator decision 2026-09-03: each repository controls task-branch and worktree creation independently, both initialize to forbidden, remain configurable, and are visible through shipglows context."
  - "Implementation proof 2026-09-01: required CI workflows target both production main and resolved live integration dev."
  - "Operator correction 2026-09-01: product delivery posture belongs in canonical business context, never in pitch, runtime environment state, or agent instructions."
  - "Operator decision 2026-09-01: non-live projects integrate directly to main; live projects use canonical dev for integration/staging and retain main for production."
  - "Operator decision 2026-08-21: use development, published, and sensitive-production as human-facing project delivery postures."
  - "Operator correction 2026-08-21: development never means local-only; remote Git persistence remains mandatory."
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

This business fact is the only authority for whether a product is non-live or live. `PITCH.md` summarizes identity and never owns operational truth. `ENVIRONMENT.md` and the DevServer registry describe runtime assignment and whether a process is currently active; runtime `live` never means product `published`. `CLAUDE.md`, `SHIPGLOWS.md`, and `AGENT.md` carry agent constraints or compatibility guidance and never own delivery posture.

Run `$SHIPGLOWS_ROOT/tools/project_delivery_policy.py --project <root> --format json` at bootstrap, context recovery, and before resolving a Git integration branch. The read-only result is `resolved`, `missing`, or `invalid`. Missing or invalid posture requires one product question with an evidence-backed recommendation; never infer it from public repository visibility, a production URL, running process, deployment provider, branch names, or local scripts.

When the question states that the selected posture will be recorded in this exact canonical field, the operator's answer is authority for that one factual persistence under the active bootstrap/context refresh. It grants no unrelated mutation. Resume the original workflow automatically after recording it.

## Postures And Derived Defaults

| Posture | Canonical integration branch | Preview | Staging | Production delivery |
| --- | --- | --- | --- | --- |
| `development` (non-live) | `main` | optional unless validation mode or changed behavior requires it | not required | disabled by default |
| `published` (live) | `dev` | required before promotion to production | canonical `dev` | gated `dev -> main` |
| `sensitive-production` (live) | `dev` | required | canonical `dev` plus required isolation evidence | gated `dev -> main` with stronger evidence |

All branch and release fields are derived rather than duplicated in another governance file. All postures use `production_branch: main`. Non-live `development` derives `integration_branch: main`, `staging_branch: not-required`, and may work directly on the integration branch. Live `published` and `sensitive-production` derive the exact canonical branch `dev` for integration and staging; short-lived task branches reconcile continuously into `dev`. ShipGlows creates or converges the derived integration branch and remote tracking without a validation prompt when safe.

## Dev/Live Launch Protection Projection

Status surfaces render `development` as `Dev` and both live postures as
`Live`. Every Dev project exposes a compact launch-protection review reminder;
the reminder alone never claims that a public surface is protected.

When a Dev project has a public URL, its observed state belongs in
`shipglows_data/workflow/launch-protection.md`: URL, protection state, email
capture state, provider, verification date, evidence, release condition and a
pointer to the detailed handoff. The status view keeps only this compact
reference. Email capture uses `inactive`, `configured`, or `verified`;
configured email capture never claims verified collection without hosted
submission evidence.

Git/GitHub stewardship is continuous and autonomous. At project or chantier start, coherent milestones, and chantier end, fetch/prune and reconcile safe owned branches, pull requests, upstreams, and worktrees; commit and push coherent validated work to the canonical integration branch at the earliest safe opportunity. Promotion to `main` follows release/deployment gates but adds no separate Git approval.

Every derived posture retains `remote_persistence: milestone-and-final`; this invariant is not duplicated into each project's business context.

## Separate Axes

- `delivery_posture` answers how mature and operationally sensitive the product is.
- `development_mode` from `project-development-mode.md` answers where changed behavior can be validated authoritatively.
- `provider_state` answers what Git, process, URL, and hosting configuration has actually been observed and belongs in operational evidence surfaces, not in business posture.
- `task_branch_policy` and `worktree_policy` answer whether ShipGlows may silently create temporary task branches and worktrees. Read them from `shipglows_data/technical/guidelines.md` through `tools/project_git_policy.py`; each missing or invalid value resolves independently to effective `forbidden`. `forbidden` means ShipGlows does not create silently: if isolation is genuinely useful, explain why and discuss changing that repository policy with the user. `allowed` grants durable permission, never a requirement or preference; still prefer the current branch and checkout when safe.

One axis never overrides another. A local validation surface does not waive remote persistence. A successful push does not prove preview, staging, deployment, or production behavior. A detected provider does not authorize non-Git environment or deployment changes; ordinary Git/GitHub convergence retains its standing authority.

Before creating a task branch or any worktree, run the Git-policy resolver again against the selected repository. `task_branch_policy: allowed` permits a new temporary task branch under the normal safety gates; `worktree_policy: allowed` permits a worktree only when its branch and all other required Git actions are independently permitted. Neither value calls for one branch or worktree per agent. Canonical `main`/`dev` convergence, work on the current branch, ordinary commits and pushes, and inventory, task/PR linkage, integration, justified retention, or proven cleanup of existing artifacts are not creation and remain governed by their existing rules.

## Migration And Inference

Existing `ShipGlows Delivery Policy` blocks in `CLAUDE.md` or `SHIPGLOWS.md` are migration evidence only. Read them to formulate the recommendation, but do not treat them as authority or keep them synchronized. After the operator confirms current product status, write only `delivery_posture` to canonical business context and remove the legacy duplicated posture block when exact ownership and migration scope are proven. Existing `ShipGlows Development Mode` remains separate validation-surface truth.

If canonical business context or its field is absent, ShipGlows reports `delivery policy unknown` and asks the product question before choosing an integration branch. It may recommend `development` only when no published-product evidence exists. Published status, production sensitivity, revenue exposure, real-user data, payments, auth, webhooks, migrations, and production permissions are material evidence and must not be downgraded silently.

## Drift And Failure Rules

- Missing or unsupported canonical values fail visibly as `delivery policy unknown`, with `question_required: yes`; no Git integration branch is inferred until answered.
- `remote_persistence` other than `milestone-and-final` is non-compliant.
- `published` with optional preview is contradictory for deployable changes.
- `sensitive-production` without staging or documented equivalent isolation is contradictory.
- A missing declared branch, unavailable remote, failed push, or unobserved protection remains delivery pending; never claim clean closure.
- Deployment and environment creation require their own authority. Ordinary Git/GitHub configuration convergence, protection-preserving merges, reconciliation, and proven cleanup use standing Git stewardship authority; never weaken or bypass protection.

## Managed GitHub Protection

Every active ShipGlows-managed GitHub repository follows `managed-project-ci-policy.md`: protect the production branch with the exact always-on `ShipGlows required gate`, never directly require a routinely path-filtered job, and install plus prove the workflow before enabling its ruleset requirement. For live projects, required workflows trigger on both production `main` and canonical integration `dev`, and both branches retain the applicable required-check protection. This applies to `development`, `published`, and `sensitive-production`; maturity changes proof depth, not the existence of baseline protection. Non-GitHub, archived, generated-mirror, or intentionally unprotected repositories require an explicit reviewed exception.

## Pressure Scenarios

- `PDP-DEVELOPMENT-NOT-LOCAL-ONLY`: development retains milestone and final remote persistence.
- `PDP-SEPARATE-AXES`: posture, validation mode, and provider state remain independent.
- `PDP-PUBLISHED-PREVIEW`: published deployable changes require preview-backed review.
- `PDP-SENSITIVE-STAGING`: sensitive production requires staging or equivalent isolation.
- `PDP-NON-LIVE-MAIN`: non-live `development` integrates directly into `main`.
- `PDP-LIVE-DEV`: live `published` and `sensitive-production` integrate and stage through canonical `dev`, retaining `main` for production.
- `PDP-GIT-AUTONOMY`: ordinary commit, push, reconciliation, PR/worktree convergence, and proven cleanup require no validation prompt.
- `PDP-GIT-CREATION-POLICY`: missing, invalid, or `forbidden` repository policy prevents silent creation in the named lane and prompts a useful user discussion when isolation is justified; explicit `allowed` is permission, never preference or obligation, and never overrides execution-posture or Git safety gates.
- `PDP-CANONICAL-BUSINESS-SOURCE`: only `shipglows_data/business/business.md` owns `delivery_posture`; pitch, environment, registry, and agent instruction files cannot override it.
- `PDP-MISSING-ASK-AND-RESUME`: missing or invalid posture triggers one product question, records the selected value in canonical business context, derives the branch, and resumes without a second validation.
- `PDP-RUNTIME-LIVE-IS-NOT-PUBLISHED`: an active DevServer process or production-looking URL never proves product publication.
- `PDP-DECLARED-VS-OBSERVED`: detected state reports drift without mutating intent.
- `PDP-LEGACY-MODE`: legacy development mode remains valid while posture is unknown.
- `PDP-MANAGED-CI`: every active managed GitHub project retains an always-on protected gate without path-filter deadlock.
- `PDP-DEV-LAUNCH-PROTECTION`: Dev status keeps a separate protection review visible.
- `PDP-WAITLIST-PROOF`: configured capture never implies verified hosted collection.
