---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-02"
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
  - shipglows_data/technical/runtime-cli.md
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
next_review: "2026-11-02"
next_step: "Update this reference whenever the project runtime policy schema or recovery behavior changes."
---

# Project Runtime Policy

Use this reference only for a ShipGlows-managed local PM2 environment that is
being started, restarted, diagnosed, tested, or verified.

## Contract

- `.shipglows.env` is optional, committed, data-only project policy; never
  source it, execute it, or use it for secrets.
- Its closed schema permits comments, blank lines, `SHIPGLOWS_ENV_PORT`, and
  `SHIPGLOWS_AUTO_REPAIR=true|false` only. Unknown or malformed lines fail the
  launch.
- Without the file, ShipGlows allocates a port and enables automatic recovery.
- `SHIPGLOWS_AUTO_REPAIR=false` means that a failed PM2 restart or crash loop
  must show bounded PM2 logs, offer Codex repair, return failure, and must not
  call `env_start` as automatic recovery.

## Skill Decision Rule

Read the policy before proposing, executing, or validating restart recovery.
When automatic recovery is disabled, diagnose and preserve evidence; do not
recommend or perform an automatic runtime regeneration. A deliberate operator
repair remains a separate action after diagnosis.

## Validation Rule

For a runtime-policy change, prove the closed parser rejects unknown settings
and that the disabled-recovery path does not call `env_start`.

## Maintenance Rule

Update this reference, its consumer skills, `runtime-cli.md`, and focused
runtime tests together whenever the schema, defaults, precedence, or recovery
semantics change.
