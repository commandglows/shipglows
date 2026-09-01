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

Detect framework/runtime/package manager/UI/CSS/content/i18n/auth/backend/storage/hosting/payment from actual project files. Create or update `CLAUDE.md` only after confirmation; it records project overview, commands, architecture, conventions, delivery policy, and development mode. If absent, `SHIPGLOWS.md` may carry both sections.

Choose `local`, `vercel-preview-push`, or `hybrid` from the real validation surface. Record hosting, preview source, production URL, observability, diagnostics/log-copy ownership, review date and explicit unknowns. A runtime project needs Sentry and safe diagnostics unless it documents the strict static-site exception. Do not leave pipe-delimited placeholders.

Load `skills/references/project-delivery-policy.md` and keep its axis separate. Recover `development`, `published`, or `sensitive-production` from governed product truth; never infer maturity from local scripts or one provider signal. When a product-status question is materially required, recommend the safest evidence-backed posture in plain language. Set `production_branch: main`; non-live `development` uses `integration_branch: main` with no staging branch, while live `published` and `sensitive-production` use canonical `integration_branch: dev` and `staging_branch: dev`. Remote persistence remains `milestone-and-final`. Create or converge the appropriate Git/GitHub branch structure under standing stewardship authority without a validation prompt. Record declared policy separately from observed provider state, preserve legacy development mode during migration, and report contradictory or unknown policy instead of silently rewriting product status.

For an active GitHub-managed project, load `skills/references/managed-project-ci-policy.md`. Run the local required-gate audit before reporting bootstrap complete. Generate the canonical workflow only inside the approved bootstrap scope; do not enable branch protection until the workflow exists on the production branch and the exact `ShipGlows required gate` has succeeded there. A missing provider permission or unproven check remains visible bootstrap follow-up, never silent success.
