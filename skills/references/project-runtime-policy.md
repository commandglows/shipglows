---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-10-16"
status: active
source_skill: 300-sg-docs
scope: project-runtime-policy
owner: unknown
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - cli/windows/ShipGlows.DevServer.psm1
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
  - skills/102-sg-start/SKILL.md
  - skills/105-sg-check/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/107-sg-test/SKILL.md
  - skills/405-sg-prod/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "cli/lib.sh::project_runtime_settings_load implements a data-only closed schema."
  - "cli/lib.sh::env_restart preserves PM2 logs and the Codex repair offer when automatic recovery is disabled."
  - "tests/cli/flox-runtime-launch.sh covers disabled recovery and unknown-setting rejection."
  - "cli/windows/ShipGlows.DevServer.psm1::Get-SgRuntimeSettings implements the Windows closed schema; tests/windows/devserver-readiness-logs.ps1 covers SHIPGLOWS_READY_TIMEOUT_SECONDS and per-path log folders."
next_review: "2026-11-02"
next_step: "Update this reference whenever the project runtime policy schema or recovery behavior changes."
---

# Project Runtime Policy

Use this reference for a ShipGlows-managed local environment (Linux PM2 or the
native Windows DevServer) that is being started, restarted, diagnosed, tested,
or verified.

## Contract

- `.shipglows.env` is optional, committed, data-only project policy; never
  source it, execute it, or use it for secrets.
- Its schema is closed: unknown or malformed lines fail the launch.
  - Linux PM2 permits comments, blank lines, `SHIPGLOWS_ENV_PORT`, and
    `SHIPGLOWS_AUTO_REPAIR=true|false` only.
  - The native Windows DevServer also permits
    `SHIPGLOWS_READY_TIMEOUT_SECONDS=<30-1800>`, `SHIPGLOWS_FLUTTER_DEVICE`,
    `SHIPGLOWS_FLUTTER_DEVICE_ID`, `SHIPGLOWS_DART_DEFINE_FILE`,
    `SHIPGLOWS_OBSIDIAN_VAULT` and `SHIPGLOWS_OBSIDIAN_SYNC_MODE=copy`.
- Windows readiness defaults to 300 s for web projects and 90 s for browser
  extensions and Obsidian plugins. A project whose first start is slower (for
  example Astro 7 content sync) declares `SHIPGLOWS_READY_TIMEOUT_SECONDS`
  instead of being retried; a readiness timeout stops the launch and repeated
  retries can discard warm caches. Flutter keeps its own supervision.
- Without the file, ShipGlows allocates a port and enables automatic recovery.
- `SHIPGLOWS_AUTO_REPAIR=false` means that a failed PM2 restart or crash loop
  must show bounded PM2 logs, offer Codex repair, return failure, and must not
  call `env_start` as automatic recovery.

## Skill Decision Rule

Read the policy before proposing, executing, or validating restart recovery.
When a Windows web surface fails with `Application readiness timed out.` while
its log shows the server still starting, propose or apply (within authorized
project-configuration work) a bounded `SHIPGLOWS_READY_TIMEOUT_SECONDS` value;
never bypass the CLI by launching the dev server manually.
When automatic recovery is disabled, diagnose and preserve evidence; do not
recommend or perform an automatic runtime regeneration. A deliberate operator
repair remains a separate action after diagnosis.

## Validation Rule

For a runtime-policy change, prove the closed parser rejects unknown settings
and that the disabled-recovery path does not call `env_start`. On Windows, prove
out-of-range readiness values are rejected (`tests/windows/devserver-readiness-logs.ps1`).

## Maintenance Rule

Update this reference, its consumer skills, `runtime-cli.md`, and focused
runtime tests together whenever the schema, defaults, precedence, or recovery
semantics change.
