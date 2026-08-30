---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: sg-docs
scope: external-platform-doppler
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.Auth.psm1
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - skills/references/documentation-freshness-gate.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "1.0.2"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh official Doppler CLI, Windows, secrets-access, service-token, configuration, MCP, and release documentation checked on 2026-08-26."
  - "Doppler CLI 3.76.5 was the latest stable release checked on 2026-08-26 and published Windows archives, checksums, and signatures."
next_review: "2026-09-26"
next_step: "/sg-docs technical audit Doppler"
---

# Doppler Platform Note

## Purpose

Use this note before installing Doppler, changing secret injection, selecting a project/config/environment, adding service or identity tokens, configuring CI, enabling the Doppler MCP, or diagnosing a secret-backed runtime. Doppler is a privileged secret provider: CLI availability, authentication, project setup, secret visibility, process injection, and agent tool access are separate capabilities.

## Source Map

| Need | Primary source |
| --- | --- |
| CLI installation, auth, commands, and flags | https://docs.doppler.com/docs/cli |
| Native Windows support | https://docs.doppler.com/docs/windows-support |
| Local CLI install and project setup | https://docs.doppler.com/docs/install-cli |
| Secret access and process/file injection | https://docs.doppler.com/docs/accessing-secrets |
| Project/config scope resolution | https://docs.doppler.com/docs/secrets-setup-guide |
| Environment and CLI configuration precedence | https://docs.doppler.com/docs/environment-based-configuration |
| Service-token least privilege | https://docs.doppler.com/docs/service-tokens |
| Official MCP server and restrictions | https://docs.doppler.com/docs/mcp |
| CLI releases, checksums, and signatures | https://github.com/DopplerHQ/cli/releases |

## Freshness Gate Use

Use `fresh-docs checked` only after identifying the current CLI/version, credential type, exact project/config/environment, runtime target, and whether values enter environment variables or ephemeral files. Use `fresh-docs gap` when a command would depend on inherited `DOPPLER_TOKEN`, implicit directory scope, unobserved dashboard permissions, or an undocumented environment mapping. Use `fresh-docs conflict` when repository declarations, local CLI scope, CI configuration, or provider state disagree.

## ShipGlows Decision Rules

- Long-lived native Windows installs use Doppler's recommended `Doppler.Doppler` WinGet package. ShipGlows verifies `doppler --version`, creates no token, and never invokes `doppler update`.
- Local operator login uses `doppler login`; on Windows the provider stores the CLI token in the OS keychain. ShipGlows never retrieves it with `doppler configure get token --plain`.
- Agents may use `doppler run -- <project-declared command>` only when the project and current dev/staging scope are explicit. The child command must already be authorized; Doppler is not a generic command-authorization bypass.
- Agents must not print, list with values, download, copy, persist, or echo secrets. Use injection into the intended child process and keep diagnostics value-free.
- Never infer dev, staging, or production from a filename, current directory, token, or previous conversation. Production use requires explicit authority and exact target evidence.
- Service tokens belong to one project/config with least privilege and an appropriate lifetime. Prefer provider integrations or OIDC identities for CI when supported; never place tokens in command arguments, Git, docs, logs, or conversations.
- The official Doppler MCP can read and modify secrets. CLI flags and read-only mode reduce accidental operations but do not replace token permissions; it is excluded from ordinary ShipGlows agent setup and SaaS capabilities.

## Common Project-Local Fields

A material Doppler usage note should record, without values:

- declared Doppler manifest path and monorepo scope;
- Doppler project/config identifiers only when safe and operationally necessary;
- mapping from local development, shared development, staging, and production;
- commands allowed to run under Doppler and their runtime owner;
- credential type by environment: local keychain login, service token, integration, or OIDC identity;
- secret-name ownership without values, rotation owner, and recovery path;
- fallback-file policy, ephemeral-file policy, and process-environment exposure;
- CI/provider validation surface and audit-log ownership.

## Security Notes

- Never use or expose `--token`, `DOPPLER_TOKEN`, `configure get token --plain`, secret values, downloaded secret JSON, fallback files, keychain contents, or value-bearing MCP output in ShipGlows state or evidence.
- Environment-variable injection can expose values to child processes and diagnostics. Prefer the narrowest child process and provider-recommended ephemeral-file mechanisms when environment inheritance is too broad.
- `--no-verify-tls` is forbidden. Debug and config-printing flags require separate review because they may disclose sensitive scope or environment information.
- Status checks use `--no-read-env` so an inherited service token cannot silently become the identity inspected by `s a`.
- Secret access is authoritative at Doppler's API/token boundary; local file presence or successful CLI installation proves no permission.

## Validation

```powershell
pwsh -NoLogo -NoProfile -File tests/windows/auth-playwright.ps1
pwsh -NoLogo -NoProfile -File tests/windows/agent-instructions.ps1
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File tests/windows/mobile-toolchain.ps1
python tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/doppler.md
```

Real installation, login, project setup, dev/staging execution, CI identity, or production proof always requires separate authorization on the exact environment.

## Reader Checklist

- `doppler.yaml`, `.doppler.yaml`, `doppler run`, or Doppler CI integration changed -> inspect the project-local usage note and exact environment mapping.
- Installer changed -> verify official package ID, executable probe, wrapper target, no login/setup, and failure isolation.
- Agent wants a secret value -> stop and reformulate the task as value-free injection or an operator-owned secret action.
- MCP proposed -> inspect current official operations and enforce a least-privileged token; never rely on client-side read-only flags as the authorization boundary.
- Runtime fails -> distinguish missing CLI, missing auth, missing scope, provider denial, child-command failure, and secret-name absence without printing values.

## Maintenance Rule

Update this note when Doppler changes its Windows install path, keychain behavior, CLI flags, project/config scope, secret injection, service/identity tokens, MCP operations, restricted-secret behavior, release integrity, or CI recommendations.
