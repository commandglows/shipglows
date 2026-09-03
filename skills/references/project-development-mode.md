---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.4.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-09-04"
status: active
source_skill: manual-doctrine-update
scope: project-development-mode
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-delivery-policy.md
  - skills/305-sg-init
  - skills/102-sg-start
  - skills/106-sg-fix
  - skills/109-sg-auth-debug
  - skills/103-sg-verify
  - skills/104-sg-end
  - skills/105-sg-check
  - skills/005-sg-ship
  - skills/405-sg-prod
  - skills/107-sg-test
  - skills/302-sg-help
  - skills/references/sentry-observability.md
  - skills/references/vercel-cost-conscious-operations.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-09-04: Vercel Hobby remains the portable baseline; Pro may exist only for private organization repository deployment while discretionary usage stays measured and economical."
  - "Operator decision 2026-09-01: validation surface stays separate from the non-live main versus live dev integration-branch policy."
  - "Some projects validate changes locally while others require Vercel preview deployments before meaningful tests."
  - "User directive 2026-06-11: runtime projects should document Sentry and a safe diagnostics/log-copy surface."
  - "User directive 2026-06-11: diagnostics/logs must start with commit/build identity and build time in Europe/Paris and UTC."
  - "Operator decision 2026-08-21: validation surface remains separate from product delivery posture and mandatory remote Git persistence."
next_review: "2026-06-25"
next_step: "/103-sg-verify project development mode doctrine"
---

# Project Development Mode

Every project should document how ShipGlows agents are expected to validate changes. The project-local source of truth is the `## ShipGlows Development Mode` section in `CLAUDE.md`. If a project has no `CLAUDE.md`, use `SHIPGLOWS.md` with the same section.

This contract answers where evidence is authoritative. It does not describe product maturity or choose the Git integration branch. Load `project-delivery-policy.md` separately: non-live status integrates into `main`, live status integrates/stages through canonical `dev`, and every validated milestone plus clean chantier end require autonomous remote persistence.

## Canonical Section

```markdown
## ShipGlows Development Mode

- development_mode: local | vercel-preview-push | hybrid
- validation_surface: local | vercel-preview | production | mixed
- ship_before_preview_test: yes | no | conditional
- post_ship_verification: 405-sg-prod | other | none
- deployment_provider: vercel | netlify | cloudflare | other | none
- vercel_plan: hobby | pro | enterprise | unknown | not-applicable
- vercel_build_machine_policy: standard-default | enhanced-measured | turbo-measured | unknown | not-applicable
- vercel_build_concurrency_policy: one-per-branch | on-demand-measured | provider-default-unknown | not-applicable
- vercel_spend_posture: team-owned | needs-review | unknown | not-applicable
- vercel_preview_protection: vercel-authentication | other | none | unknown | not-applicable
- preview_source: Vercel MCP deployment target_url | static URL | not applicable
- production_url: [URL or unknown]
- observability: sentry-required | sentry-static-exception | other
- diagnostic_surface: route/component/copy-action | missing | not applicable
- logs_copy_action: available | missing | not applicable
- diagnostic_log_header: commit/build + Paris/UTC build time | missing | not applicable
- notes: [short project-specific rule]
- last_reviewed: YYYY-MM-DD
```

## Modes

- `local`: run local dev servers, local browser checks, unit tests, and focused tooling before shipping. `005-sg-ship` is not required before manual QA unless the user explicitly wants remote validation.
- `vercel-preview-push`: local static checks are allowed, but browser, integration, auth, webhook, deployed-runtime, or manual user-flow tests are not authoritative until the change has been pushed and the matching Vercel deployment is ready. The required sequence is `005-sg-ship` -> `405-sg-prod` -> test the returned deployment URL.
- `hybrid`: use local validation for purely local UI, unit, and static checks. Use the `vercel-preview-push` sequence for anything that depends on hosted environment variables, OAuth/callback URLs, edge/serverless behavior, webhooks, production-like data, Vercel routing, or deployment configuration.

For Vercel projects, load `skills/references/vercel-cost-conscious-operations.md`. Keep Hobby compatible as the portable baseline. A declared Pro plan may be retained solely to deploy private organization repositories; it never implies Turbo builds, unrestricted concurrency, paid add-ons, or a goal to consume included credit.

## Agent Rules

- `102-sg-start` and `106-sg-fix` must read the project development mode before deciding how to validate a code change.
- If the mode is `vercel-preview-push`, the agent may run quick local checks before shipping, but must not ask the user to manually test or claim browser/user-flow validation until `005-sg-ship` has pushed and `405-sg-prod` has confirmed the matching deployment.
- After a successful `005-sg-ship` in `vercel-preview-push` or preview-required `hybrid` mode, the immediate next action is `405-sg-prod`.
- `405-sg-prod` must wait for the matching deployment with Vercel MCP when Vercel is the provider. GitHub commit statuses are fallback evidence, not the primary source when MCP is available.
- `107-sg-test --preview` should use the deployment URL confirmed by `405-sg-prod`. If code changes are still dirty or unpushed, route to `005-sg-ship` first.
- If the development mode section is missing and Vercel signals exist (`.vercel/project.json`, `vercel.json`, Vercel dependencies, or Vercel remote status), classify the mode as `unknown-vercel`, report the gap, and ask or document the mode before running preview-dependent tests.
- If no hosting signals exist, default to `local` with `confidence: medium` and recommend adding the section during the next `305-sg-init` or project setup pass.
- For runtime projects, missing `observability`, `diagnostic_surface`, `logs_copy_action`, or `diagnostic_log_header` is setup debt. Static sites may use `sentry-static-exception` and `not applicable` only when the Sentry static-site exception applies.
- For Vercel projects, missing plan, build-machine, build-concurrency, spend, or preview-protection policy is provider-governance debt, not permission to infer the dashboard state. Non-Vercel projects use `not-applicable` and do not load Pro requirements.

## Minimal Inference

Use this only when the project has no explicit section:

| Signal | Temporary mode | Required next step |
|--------|----------------|--------------------|
| `.vercel/project.json` or `vercel.json` | `unknown-vercel` | Ask whether validation is local, preview-push, or hybrid before manual/browser testing |
| User says "test on preview", "push to Vercel", or "Vercel preview is the dev env" | `vercel-preview-push` | Write or update the project section |
| No hosting provider and runnable local scripts | `local` | Recommend documenting the section |
| Auth/OAuth/webhook bug only appears on hosted URL | `hybrid` or `vercel-preview-push` | Use `005-sg-ship` -> `405-sg-prod` before retest |
