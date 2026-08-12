---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-02"
status: reviewed
source_skill: 700-sg-explore
scope: "Project-local .shipglows.env runtime policy"
owner: unknown
confidence: high
risk_level: medium
security_impact: medium
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - tests/cli/flox-runtime-launch.sh
  - shipglows_data/technical/runtime-cli.md
evidence:
  - "cli/lib.sh::project_runtime_settings_load parses .shipglows.env as data via an explicit allowlist."
  - "cli/lib.sh::env_restart prints PM2 logs and offers Codex repair before skipping env_start when SHIPGLOWS_AUTO_REPAIR=false."
  - "tests/cli/flox-runtime-launch.sh proves disabled auto-repair does not call env_start."
  - "shipglows_data/technical/runtime-cli.md documents port pinning and restart-recovery opt-out."
  - "2026-08-02 implementation makes the .shipglows.env schema closed and regression-tested."
depends_on: []
supersedes: []
next_step: "Apply .shipglows.env only to projects with durable non-default runtime policy."
---

# Exploration Report: Project Runtime Policy File

## Starting Question

Should ShipGlows generalize ContentGlowz's project-local `.shipglows.env` and make it part of the operating doctrine?

## Context Read

- `CLAUDE.md` — establishes PM2 lifecycle and observable recovery as core runtime behavior.
- `cli/lib.sh` — confirms the file is already read as data, never sourced, and the `false` branch preserves logs and the Codex repair option while preventing `env_start` recovery.
- `tests/cli/flox-runtime-launch.sh` — proves the opt-out prevents runtime regeneration.
- `shipglows_data/technical/runtime-cli.md` — already records the two supported settings but has no adoption policy.

## Problem Framing

Some projects should preserve a broken runtime state for diagnosis rather than let ShipGlows regenerate PM2 configuration or reinstall/re-detect through `env_start`. A project-local, versioned policy makes that operator intent durable across sessions and contributors.

## Option Space

### Option A: No shared policy

- Summary: keep the file as an undocumented per-project escape hatch.
- Pros: no new doctrine or template burden.
- Cons: behavior remains discoverable only from code; teams will apply inconsistent recovery policies.

### Option B: Require `.shipglows.env` in every managed project

- Summary: create the file at project onboarding, even when it contains defaults.
- Pros: uniform, visible configuration surface.
- Cons: boilerplate and false precision; most projects do not need a pinned port or recovery opt-out.

### Option C: Standardize the contract; create the file only when a project deviates from defaults

- Summary: make `.shipglows.env` the canonical project-runtime policy surface, with default behavior unchanged when it is absent.
- Pros: durable and reviewable intent without mandatory noise; preserves backwards compatibility; fits the existing implementation.
- Cons: the absence of a file means readers must know the global defaults.

## Comparison

Option C best matches ShipGlows's explicit-default and low-surprise principles. `SHIPGLOWS_AUTO_REPAIR=true` stays the platform default. A project writes `false` only when automatic runtime regeneration is unsafe, destructive to diagnosis, or repeatedly counterproductive. ContentGlowz is an appropriate early adopter because its `45000` port and no-repair behavior are intentional, durable project policy.

## Emerging Recommendation

Adopt Option C. Generalize the *contract*, not compulsory file creation.

- `.shipglows.env` is a committed, data-only project policy file; it is never a secrets file and never an executable dotenv file.
- The supported schema remains allowlisted: `SHIPGLOWS_ENV_PORT` and `SHIPGLOWS_AUTO_REPAIR`.
- Document defaults explicitly: absent file means dynamically allocated port and automatic recovery enabled.
- `SHIPGLOWS_AUTO_REPAIR=false` means: show the relevant PM2 logs, offer the Codex repair workspace, return failure, and never call `env_start` from the failure/crash-loop recovery path.
- Process-level `SHIPGLOWS_ENV_PORT` may remain a one-shot override. Process-level `SHIPGLOWS_AUTO_REPAIR` should not silently override durable project safety policy unless a future spec explicitly defines precedence.

## Non-Decisions

- No automatic creation of `.shipglows.env` for existing projects.
- No arbitrary dotenv syntax, interpolation, command substitution, secrets, or framework-specific startup commands.
- No change to the current default of automatic recovery.

## Rejected Paths

- Sourcing the file as shell code — rejected because configuration metadata must not execute project-controlled commands.
- Adding every conceivable runtime switch now — rejected to keep the schema auditable and avoid replacing project configuration with a second generic configuration system.

## Risks And Unknowns

- Unknown keys now fail the load. A future schema extension must add parsing, documentation, and regression coverage atomically.
- The file's repository hygiene must be stated explicitly: commit it when it contains durable non-secret policy; never place credentials in it.
- Pinning a port remains subject to collision validation, so a copied configuration may still legitimately fail to start.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none required
- Notes: No logs, credentials, or project secrets were persisted.

## Decision Inputs For Spec

- User story seed: As an operator, I can declare durable, non-executable runtime policy per project so ShipGlows handles failures in a way that matches the project.
- Scope in seed: doctrine, supported-schema reference, onboarding/template guidance, unknown-key policy, tests for parsed-as-data and recovery semantics.
- Scope out seed: generic dotenv execution, secret management, automatic migration of every project, arbitrary framework options.
- Invariants/constraints seed: data-only parsing; strict value validation; logs and Codex option before return; false recovery policy never calls `env_start` on restart failure/crash loop.
- Validation seed: shell tests for default, false behavior, invalid values, unknown keys, precedence, and no code execution; documentation review.

## Handoff

- Recommended next command: no further implementation required.
- Why this next step: the doctrine, runtime enforcement, and regression coverage are aligned.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
| --- | --- | --- | --- | --- |
| 2026-08-02 21:31:13 UTC | Generalize ContentGlowz runtime policy file | Reviewed implementation, test coverage, and runtime doctrine | Recommend standardizing the optional contract, not mandatory file creation | Formalize policy after operator decision |
| 2026-08-02 21:31:13 UTC | Operator approved formalization | Updated runtime enforcement and doctrine | Closed-schema policy adopted; optional file with safe defaults | Complete |
