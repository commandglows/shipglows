---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-09-01"
status: active
source_skill: 305-sg-init
scope: bootstrap-entrypoint-and-development-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/305-sg-init/SKILL.md]
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-09-01: bootstrap records main integration for non-live projects and canonical dev integration/staging for live projects, then converges Git without validation prompts."
  - "CLAUDE and development-mode extraction."
  - "Operator decision 2026-08-21: bootstrap records delivery posture separately from validation surface and never treats development as local-only."
next_step: "/103-sg-verify compact monolithic skill references"
---

# Bootstrap Entry Point And Development Mode

Detect framework/runtime/package manager/UI/CSS/content/i18n/auth/backend/storage/hosting/payment from actual project files. Create or update `CLAUDE.md` only after confirmation; it records project overview, commands, architecture, conventions, and development mode. Product delivery posture belongs only in canonical business context. If absent, `SHIPGLOWS.md` may carry the development-mode section.

Choose `local`, `vercel-preview-push`, or `hybrid` from the real validation surface. Record hosting, preview source, production URL, observability, diagnostics/log-copy ownership, review date and explicit unknowns. A runtime project needs Sentry and safe diagnostics unless it documents the strict static-site exception. Do not leave pipe-delimited placeholders.

Load `skills/references/project-delivery-policy.md` and run its read-only resolver. Read `delivery_posture` only from `shipglows_data/business/business.md`; never infer it from pitch, environment/runtime state, local scripts, branch names, repository visibility, or provider signals. A missing or invalid value is an unresolved product decision: present one evidence-backed question and do not derive a branch until it is answered and recorded in that canonical field. Then derive `production_branch: main`; non-live `development` uses `integration_branch: main` with no staging branch, while live `published` and `sensitive-production` use `integration_branch: dev` and `staging_branch: dev`. Keep `development_mode` and observed provider state separate. This resolver chooses targets only; it grants no Git, execution, environment, deployment, or production authority. Follow the applicable `AGENTS.md`, execution-posture, and mutation-approval rules.

Before considering creation of a temporary task branch or worktree, run `tools/project_git_policy.py` against the selected repository. Missing or invalid policy defaults each creation lane independently to `forbidden`; do not infer actual project values. `allowed` is permission, never a requirement or preference, and all other action-specific safety and approval gates still apply.

For an active GitHub-managed project, load `skills/references/managed-project-ci-policy.md`. Run the local required-gate audit before reporting bootstrap complete. Generate the canonical workflow only inside the approved bootstrap scope; do not enable branch protection until the workflow exists on the production branch and the exact `ShipGlows required gate` has succeeded there. A missing provider permission or unproven check remains visible bootstrap follow-up, never silent success.
