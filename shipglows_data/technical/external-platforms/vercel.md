---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-09-04"
status: active
source_skill: 900-shipglows-core
scope: external-platform-vercel
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/405-sg-prod/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/109-sg-auth-debug/references/vercel-tooling.md
  - skills/references/project-development-mode.md
  - skills/references/vercel-cost-conscious-operations.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Operator decision 2026-09-04: use Pro for private organization repository deployment while keeping credit consumption measured, controlled, observed, and planned."
  - "Fresh official Vercel docs checked on 2026-09-04 for Pro plans, spend management, builds, deployment protection, WAF, observability, analytics, and MCP."
  - "Fresh external docs checked on 2026-05-24 against official Vercel deployment, CLI, logs, environment variables, system environment variables, and changelog pages."
next_review: "2026-10-04"
next_step: none
---

# Vercel Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Vercel-related freshness checks. Use it before relying on assumptions about preview deployments, production deployment triggers, environment variables, CLI behavior, deployment URLs, runtime logs, or hosted validation.

It does not replace Vercel documentation. It points agents to the official sources and records ShipGlows decision rules that are repeatedly relevant across projects.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Vercel docs entrypoint | https://vercel.com/docs |
| Git deployments, production branch, preview branches, custom environments | https://vercel.com/docs/deployments/git |
| CLI overview, auth, install/update, available operations | https://vercel.com/docs/cli |
| CLI deployments and stdout deployment URL behavior | https://vercel.com/docs/cli/deploying-from-cli |
| `vercel deploy` command details | https://vercel.com/docs/cli/deploy |
| Runtime/request logs via CLI | https://vercel.com/docs/cli/logs |
| Environment variables by Production, Preview, Development, Custom environments | https://vercel.com/docs/projects/environment-variables |
| System environment variables | https://vercel.com/docs/environment-variables/system-environment-variables |
| Pro plan and included credit | https://vercel.com/docs/plans/pro-plan |
| Spend alerts, webhooks, and pause actions | https://vercel.com/docs/spend-management |
| Build machines and concurrency | https://vercel.com/docs/builds/managing-builds |
| Deployment protection | https://vercel.com/docs/deployment-protection |
| Firewall and WAF | https://vercel.com/docs/vercel-firewall |
| Observability | https://vercel.com/docs/observability |
| Vercel MCP | https://vercel.com/docs/agent-resources/vercel-mcp |
| Changelog and release signals | https://vercel.com/changelog |

Freshness evidence on 2026-09-04:

- Pro includes a monthly flexible credit and allocations, then permits on-demand billing; unused credit and allocations reset rather than accumulating.
- Spend Management distinguishes notifications, webhooks, and an optional all-project production pause; setting a spend amount alone is not a hard stop.
- New Pro projects may default to Turbo build machines and on-demand concurrency, both of which can create metered build cost.
- Standard deployment protection can protect previews with Vercel Authentication; broader methods and scopes may require paid add-ons or Enterprise.
- WAF and rate limiting are configurable provider controls with their own usage and false-positive consequences.
- Vercel observability, Web Analytics, Speed Insights, and their Plus variants have different metering and add-on boundaries.
- Vercel MCP is a provider/account evidence surface with OAuth and a current-client support list; it does not replace ShipGlows authority or redaction rules.
- Vercel CLI docs were last updated February 10, 2026 and describe CLI access to logs, certificates, deployment environment replication, DNS records, and more.
- Vercel Git deployment docs describe production deployments from the configured production branch and preview deployments from other branches or custom environment branches.
- Vercel environment variable docs distinguish Production, Preview, Custom, and Development environments and describe `vercel env pull` for development variables.
- Vercel CLI deployment docs state that the `vercel` command's stdout is the deployment URL.
- Vercel logs docs describe `vercel logs`, `--follow`, and filtering request/runtime logs.
- Vercel changelog should be checked for CLI and platform behavior changes before major workflow assumptions.

## Freshness Gate Use

Use `fresh-docs checked` for Vercel decisions only after checking the relevant official source above or a current Vercel MCP/CLI source that directly proves the state.

Use `fresh-docs gap` when:

- Vercel behavior affects the task but the relevant docs, CLI state, MCP state, or dashboard-equivalent evidence was not checked.
- The project depends on preview/production behavior but lacks a local `shipglows_data/technical/platforms/vercel.md` usage note.
- The task depends on account configuration that is not visible from the repo, MCP, CLI, or user-provided evidence.

Use `fresh-docs conflict` when current Vercel docs or provider state contradict the project's documented assumptions.

## ShipGlows Decision Rules

- Load `skills/references/vercel-cost-conscious-operations.md` for plan, spend, build, WAF, preview-protection, analytics, or provider-agent decisions.
- Keep Hobby as the portable project baseline. A Pro account may be retained solely for private organization repository deployments without enabling other discretionary consumption.
- Default to Standard builds and one active build per branch. Enhanced/Turbo machines, unrestricted concurrency, and paid add-ons require measured need, expected benefit, and a cost boundary.
- Treat credits as a billing offset, never a consumption target. Prefer no spend over low-value speed or telemetry.
- Spend notifications are the baseline. Webhook side effects need a declared receiver, while all-project pause/resume and billing changes require explicit operator authority.
- Do not treat local success as hosted proof for projects whose validation surface is `vercel-preview-push`, hosted auth callbacks, hosted env vars, Edge/serverless behavior, CDN cache, or domain routing.
- `sg-prod` owns deployment truth: matching deployment URL, status, provider logs, runtime logs, and ready/failed/pending state.
- `sg-deploy` owns orchestration around release confidence and should route Vercel provider truth to `sg-prod`.
- `sg-auth-debug` must use hosted proof for auth issues involving OAuth callbacks, cookies, provider dashboards, deployment env, domain, Edge/serverless runtime, or preview/prod differences.
- Prefer Vercel MCP as the primary source for deployment state when available. Use Vercel CLI as a practical fallback or when the CLI provides more direct evidence for logs/env/deploy commands.
- A Vercel preview URL alone is not enough proof. Record whether the deployment is ready, which commit/branch it represents, and whether logs/runtime state were checked when relevant.
- Environment variable work must distinguish Production, Preview, Development, and Custom environments. Do not assume `.env.local` proves deployed environments.
- For project docs, name expected env var keys and environment categories, but never record secret values.

## Common Project-Local Fields

A project using Vercel should maintain `<governance-root>/shipglows_data/technical/platforms/vercel.md` with:

- Vercel project name or non-secret identifier if safe
- production branch
- validation surface: `local`, `vercel-preview-push`, or `hybrid`
- preview/prod domain policy
- environment variable keys by environment
- auth/callback/domain constraints
- build command and output expectations
- MCP/CLI availability
- verification commands or evidence route
- known provider-specific risks or exceptions

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store Vercel tokens, project secrets, raw runtime logs containing sensitive data, cookies, private deployment inspection output, or customer data in ShipGlows docs.
- Treat deployment logs as potentially sensitive. Summarize only the error category, relevant route/function, status, timestamp, and redacted identifiers.
- For auth projects, verify allowed callback domains and environment-specific secrets before concluding that code is at fault.
- For production work, do not mutate domains, aliases, env vars, or production deployments without explicit user approval.
- Treat protection-bypass values, billing identifiers, private preview URLs, and usage exports as sensitive evidence; never persist their raw values in governance.

## Validation

For global note changes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/vercel.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/vercel.md
```

For project-local Vercel notes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/platforms/vercel.md
rg -n "validation surface|production branch|Environment|Verification|Maintenance Rule" shipglows_data/technical/platforms/vercel.md
```

## Reader Checklist

- Vercel mentioned in project docs or config -> check for project-local Vercel usage note.
- Vercel deployment, env, logs, auth, or domain behavior affects the task -> run the Freshness Gate and check the relevant source.
- Dependency or framework upgrade may change Vercel build/runtime behavior -> check Vercel docs plus the framework migration guide.
- `sg-prod` or `sg-auth-debug` reports provider uncertainty -> update or create the local Vercel usage note after evidence is confirmed.

## Maintenance Rule

Update this note when Vercel deployment semantics, CLI behavior, environment model, logging model, MCP routing, or ShipGlows Vercel proof rules change. Review it at least monthly while Vercel remains a common deployment target.
