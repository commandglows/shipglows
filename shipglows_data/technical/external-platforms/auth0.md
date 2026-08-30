---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: sg-docs
scope: external-platform-auth0
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - cli/windows/ShipGlows.Auth.psm1
  - cli/windows/install-devserver.ps1
  - skills/references/documentation-freshness-gate.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.0.1"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh official Auth0 CLI release, command, login, Flutter quickstart, and Deploy CLI documentation checked on 2026-08-26."
  - "Auth0 CLI v1.33.0 was the latest stable GitHub release on 2026-08-26 and published Windows x64/arm64 archives plus checksums."
next_review: "2026-09-26"
next_step: "/sg-docs technical audit Auth0"
---

# Auth0 Platform Note

## Purpose

Use this note before changing Auth0 SDK integration, Universal Login, callbacks, audiences, organizations, tenant automation, or the ShipGlows-managed Auth0 CLI. It separates four surfaces that must not be confused: application SDKs, the operator CLI, tenant deployment tooling, and optional agent/MCP integrations.

## Source Map

| Need | Primary source |
| --- | --- |
| Official Auth0 CLI overview and commands | https://auth0.github.io/auth0-cli/ |
| CLI releases and checksums | https://github.com/auth0/auth0-cli/releases |
| CLI login command | https://auth0.github.io/auth0-cli/auth0_login.html |
| Tenant-list status command | https://auth0.github.io/auth0-cli/auth0_tenants_list.html |
| Flutter SDK quickstart | https://auth0.com/docs/quickstart/native/flutter |
| Auth0 Deploy CLI | https://auth0.com/docs/deploy-monitor/deploy-cli-tool |
| Aqua registry package definition | https://github.com/aquaproj/aqua-registry/tree/main/pkgs/auth0/auth0-cli |

## Freshness Gate Use

Use `fresh-docs checked` only after verifying the relevant current SDK/CLI documentation, the project package version, callback/logout URLs, application type, API audience, and target validation surface. Use `fresh-docs gap` when Auth0 behavior is inferred from another provider, dashboard configuration is unobserved, or local success is used to claim a hosted callback works. Use `fresh-docs conflict` when current tenant/application settings contradict repository configuration or durable project docs.

## ShipGlows Decision Rules

- Application SDKs such as `auth0_flutter` and `@auth0/*` belong to each project. The machine CLI does not replace or inject them.
- The official Auth0 CLI is native on Windows and has no WSL dependency. ShipGlows installs it through the existing exact-version mise/Aqua toolbox and never authenticates during installation.
- `s a` may run only the closed status/login/logout definitions. Authentication, browser/device authorization, tenant selection, and consent remain operator-owned.
- Auth0 Deploy CLI is a separate tenant configuration import/export tool with mutation risk. Do not install or invoke it as a substitute for the operator CLI without a dedicated spec, rollback plan, tenant boundary, and approval.
- MCP or agent skills are optional interaction surfaces, not prerequisites for application auth or the CLI. Tool configuration never proves current-session callability.
- API audiences, callback/logout URLs, organizations, roles, permissions, and server-side authorization remain project configuration. Never infer them from CLI availability.

## Common Project-Local Fields

A material Auth0 integration should document, without values or private URLs:

- application type, platforms, SDK packages, and exact versions;
- expected environment-variable names for domain, client ID, and API audience;
- callback, logout, deep-link/custom-scheme, and allowed-origin policy;
- API identifier/audience and server-side JWT validation rules;
- organization, role, permission, SSO, and connection policy when used;
- local, preview, production, Windows, Android, and browser validation ownership;
- migration boundary from another provider and rollback/recovery expectations.

## Security Notes

- Never store access/refresh tokens, client secrets, session cookies, authorization codes, tenant exports, raw user profiles, or CLI command output in ShipGlows docs, reports, fixtures, or generated state.
- Public/native clients do not receive a client secret. Backend secrets and management credentials stay in provider-managed secret surfaces.
- UI sign-in state is not server authorization. APIs must validate issuer, audience, signature, expiry, and required permissions at the authoritative boundary.
- The managed wrapper scopes `AUTH0_CLI_ANALYTICS=false` to the Auth0 child process; it does not modify global user or machine environment variables.

## Validation

```powershell
pwsh -NoLogo -NoProfile -File tests/windows/auth-playwright.ps1
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File tests/windows/mobile-toolchain.ps1
python tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/auth0.md
```

A real login, callback, logout, API audience, organization, or SSO claim additionally requires separately authorized proof on the exact project and Auth0 tenant/environment.

## Reader Checklist

- `auth0_flutter`, `@auth0/*`, an Auth0 callback, audience, or custom scheme changed -> inspect the project-local Auth0 usage note and current provider configuration.
- CLI release or package authority changed -> verify the official release, architecture asset, checksum path, Aqua package, exact pin, wrapper, and failure isolation.
- Tenant import/export or Management API mutation proposed -> route to a separate high-risk spec; the installed operator CLI grants no mutation authority.
- Auth flow failed -> separate local SDK/deep-link behavior from hosted dashboard/domain/connection behavior before patching.

## Maintenance Rule

Update this note when the official CLI install/auth commands, release/checksum path, SDK quickstarts, Deploy CLI semantics, tenant model, Universal Login, organizations, SSO, or application callback requirements change.
