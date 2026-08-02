---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
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
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against official Vercel deployment, CLI, logs, environment variables, system environment variables, and changelog pages."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
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
| Changelog and release signals | https://vercel.com/changelog |

Freshness evidence on 2026-05-24:

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
