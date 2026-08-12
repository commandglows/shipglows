---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-08-12"
status: active
source_skill: 004-sg-deploy
scope: 004-sg-deploy-release-confidence-workflow
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/105-sg-check/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - skills/405-sg-prod/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/304-sg-changelog/SKILL.md
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from skills/004-sg-deploy/SKILL.md to keep the activation body compact."
  - "Wave 10 verified this pack as the post-scope release route in the explicit activation profile."
next_review: "2026-11-12"
next_step: none
---

# Release Confidence Workflow

## Purpose

Define the detailed phase workflow for `004-sg-deploy`. The top-level `SKILL.md` owns activation, routing, stop conditions, and validation visibility; this reference owns the long release-confidence playbook.

## Phase 1 - Scope And Risk Gate

Identify:

- release scope and changed files
- target environment: `local`, `preview`, `production`, or `unknown`
- project development mode from `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` plus `CLAUDE.md` or `SHIPGLOWS.md`
- whether the release touches auth, data, permissions, payments, webhooks, background jobs, migrations, public pages, docs, or external side effects
- linked open high or critical bugs from `shipglows_data/workflow/bugs/*.md`, using optional `shipglows_data/workflow/BUGS.md` only as triage context when present

Ask one targeted question only when the answer changes staging scope, target environment, skip-check risk, destructive side effects, or release framing.

Stop before shipping when:

- dirty files are unrelated or ambiguous
- high or critical linked bugs are still open and not explicitly accepted as release risk
- the project mode requires hosted validation but the deployment target is unknown
- the requested action would mutate production data without explicit approval

## Phase 2 - Pre-Ship Checks

Unless `skip-check` is present, run or route through:

```text
/105-sg-check nofix
```

Use `nofix` by default because deploy orchestration should not silently widen into an implementation pass.

If checks fail, stop and report:

- failed command
- failing summary
- repair route: `/105-sg-check fix`

If `skip-check` is present, continue only with a visible risk note. Skipping checks never means the release is safe.

## Phase 3 - Ship

Run or route through:

```text
/005-sg-ship [bounded release scope]
```

Do not stage or commit files directly inside `004-sg-deploy`.

If `005-sg-ship` blocks on checks, secrets, bug risk, unrelated dirty files, or push failure, stop at that gate.

After a successful push, record:

- commit SHA
- branch
- ship mode
- whether hosted validation is required by project development mode
- whether Sentry release/environment correlation is expected for post-deploy runtime proof

## Phase 4 - Deployment Truth

Run or route through:

```text
/405-sg-prod [project or URL]
```

For Vercel projects, `405-sg-prod` should use Vercel MCP as the primary deployment truth source when available. Do not continue to browser or manual proof until the matching deployment URL is known and ready, unless the report explicitly marks deployment proof as partial.

When Sentry is configured, deployment truth should include only Sentry evidence that `405-sg-prod` can see from a supplied or visible issue/event pointer, plus PM2/Doppler fallback evidence when no pointer exists. Skills must not assume direct Sentry dashboard access. Do not treat missing Sentry evidence as full product proof.

For projects whose deploy, APK, or release artifact is built through GitHub Actions on Blacksmith runners, `004-sg-deploy` must route Blacksmith log and SSH debugging to `405-sg-prod`; it should not duplicate Blacksmith internals. If `405-sg-prod` reports that Blacksmith SSH inspection is required but unavailable because the job already ended, keep the release verdict partial or blocked and recommend a failure-only keepalive step or Blacksmith Monitor VM retention.

If `405-sg-prod` finds a failed build, runtime error, pending deployment timeout, missing URL, or logs that require repair, stop and route to the appropriate repair path:

- `/105-sg-check fix` for local build/check failures
- `/106-sg-fix [deploy/runtime issue]` for narrow defects
- `/100-sg-spec [release incident]` for risky or cross-system incidents

## Phase 5 - Verify

Run or route through:

```text
/103-sg-verify [spec or release scope]
```

`103-sg-verify` must check the user story, success and error behavior, bug gate, documentation coherence, and project development mode implications.

If verification fails, stop and return the corrective next step.

## Phase 6 - Changelog Route

If the release is verified and `no-changelog` is absent, route to:

```text
/304-sg-changelog
```

Skip changelog only when:

- the change is internal or no meaningful user-facing release note exists
- the user passed `no-changelog`
- the release remains partial or blocked

Do not treat changelog generation as proof of release health.
