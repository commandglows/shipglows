---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-05-03"
created_at: "2026-05-03 10:04:53 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 11:40:29 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "As a ShipGlows operator managing bugs across sessions, I want one sg-bug entrypoint that routes intake, dossier state, fix attempts, retests, verification, and ship risk, so the professional bug loop is followed without manually remembering every command."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-bug/SKILL.md"
  - "skills/sg-bug/agents/openai.yaml"
  - "skills/sg-test/SKILL.md"
  - "skills/sg-fix/SKILL.md"
  - "skills/sg-verify/SKILL.md"
  - "skills/sg-ship/SKILL.md"
  - "skills/sg-help/SKILL.md"
  - "skills/references/chantier-tracking.md"
  - "docs/technical/skill-runtime-and-lifecycle.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "site/src/content/skills/sg-bug.md"
  - "skills/REFRESH_LOG.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/professional-bug-management.md"
    artifact_version: "1.0.0"
    required_status: "ready"
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "2.11.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "User request 2026-05-03: create sg-bug because the professional bug loop is already defined but not orchestrated."
  - "Professional Bug Management shipped the three-layer model: shipglows_data/workflow/TEST_LOG.md, shipglows_data/workflow/BUGS.md, shipglows_data/workflow/bugs/BUG-ID.md, and test-evidence/BUG-ID/."
  - "Existing skills own individual phases: sg-test logs/retests, sg-fix fixes, sg-auth-debug and sg-browser gather evidence, sg-verify gates closure, sg-ship reports bug risk."
next_step: "none"
---

# Spec: sg-bug Professional Bug Loop Orchestrator

## Title

sg-bug Professional Bug Loop Orchestrator

## Status

ready

## User Story

As a ShipGlows operator managing bugs across sessions, I want one `sg-bug` entrypoint that routes intake, dossier state, fix attempts, retests, verification, and ship risk, so the professional bug loop is followed without manually remembering every command.

## Minimal Behavior Contract

`sg-bug` is the bug lifecycle orchestrator. It must inspect the current bug context, choose the next correct existing skill, and preserve the professional bug model. It must not duplicate the internals of `sg-test`, `sg-fix`, `sg-auth-debug`, `sg-browser`, `sg-verify`, or `sg-ship`. It should make the loop easier to run, not weaker.

Canonical loop:

```text
sg-bug -> sg-test -> bug dossier -> sg-fix -> sg-test --retest -> sg-verify -> sg-ship
```

## Scope In

- Create `skills/sg-bug/SKILL.md`.
- Route bug intake from free text, `BUG-ID`, `--retest`, `--close`, `--ship`, and empty dashboard-like usage.
- Read `shipglows_data/workflow/BUGS.md` and `shipglows_data/workflow/bugs/BUG-ID.md` when present.
- Pick the next command based on bug status, severity, project development mode, and evidence needs.
- Preserve dossier-first behavior and redaction/security rules from Professional Bug Management.
- Update help, workflow doctrine, technical lifecycle docs, public skill page, and chantier taxonomy.
- Publish current-user Claude/Codex runtime links for `sg-bug`.

## Scope Out

- Replace `sg-test`, `sg-fix`, `sg-auth-debug`, `sg-browser`, `sg-verify`, `sg-ship`, or `sg-docs`.
- Build a UI, global bug registry, external tracker sync, or migration tool.
- Close bugs without retest evidence or explicit `closed-without-retest` exception.
- Store raw sensitive evidence or large logs inline.

## Ownership Boundaries

- `sg-test` owns manual QA, failed-test capture, retest history, and compact test logs.
- `sg-fix` owns diagnosis and fix attempts.
- `sg-auth-debug` owns auth/session/OAuth/browser-auth diagnosis.
- `sg-browser` owns one-off non-auth browser evidence.
- `sg-verify` owns final closure and coherence gates.
- `sg-ship` owns commit/push and bug-risk reporting.
- `sg-bug` owns orchestration, status interpretation, and next-step routing.

## Mode Contract

- Empty arguments: summarize actionable open bugs and recommend the highest-priority next command.
- `BUG-ID`: read `shipglows_data/workflow/BUGS.md` and `shipglows_data/workflow/bugs/BUG-ID.md`, interpret status, and route.
- Free text: route to `/sg-test [scope]` for observed failures needing durable capture, or `/sg-fix [summary]` only when the bug is already actionable enough for direct intake.
- `--retest BUG-ID`: route to `/sg-test --retest BUG-ID`.
- `--fix BUG-ID`: route to `/sg-fix BUG-ID`.
- `--verify BUG-ID`: route to `/sg-verify BUG-ID`.
- `--ship BUG-ID`: require verification-compatible state first, then route to `/sg-ship BUG-ID` or block with bug risk.
- `--close BUG-ID`: refuse direct closure unless dossier has passing retest or an explicit closure exception route is chosen.

## Stop Conditions

- Missing or malformed `BUG-ID` dossier when the requested mode depends on it.
- Conflicting `shipglows_data/workflow/BUGS.md` index and dossier status without enough evidence to reconcile safely.
- User asks to close a bug without retest evidence or visible exception.
- Evidence includes secrets, cookies, tokens, private payloads, production PII, raw headers, or unredacted screenshots.
- The next step would mutate production or run destructive reproduction without explicit approval.
- High/critical bug is still open and user asks to ship as clean.

## Acceptance Criteria

- [x] AC 1: Given no `sg-bug` skill exists, when the skill is created, then it has compact frontmatter and a clear orchestration mission.
- [x] AC 2: Given a `BUG-ID`, when `sg-bug` runs, then it reads the compact index and dossier before routing.
- [x] AC 3: Given a bug is `fix-attempted`, when `sg-bug` routes, then the next step is retest, not closure.
- [x] AC 4: Given a bug is `fixed-pending-verify`, when `sg-bug` routes, then the next step is verification before closure or ship.
- [x] AC 5: Given a high/critical bug is open, when `sg-bug --ship BUG-ID` runs, then it blocks clean shipping or reports partial risk.
- [x] AC 6: Given auth/session/OAuth evidence is needed, when `sg-bug` triages, then it routes to `sg-auth-debug`; non-auth browser proof routes to `sg-browser`.
- [x] AC 7: Given current-user runtime skill links are checked, then Claude and Codex symlinks for `sg-bug` resolve to the ShipGlows skill.
- [x] AC 8: Given public skill discovery changed, then help, README/workflow docs, technical lifecycle docs, chantier tracking, and the public skill page mention `sg-bug`.

## Validation Plan

- `tools/shipglows_sync_skills.sh --repair --skill sg-bug`
- `tools/shipglows_sync_skills.sh --check --skill sg-bug`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py specs/sg-bug-professional-bug-loop-orchestrator.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical skills/references/chantier-tracking.md`
- `pnpm --dir shipglows-site build`
- Focused `rg` checks for `sg-bug`, bug routing, and stale duplicate ownership wording.

## Security Notes

Bug orchestration touches evidence and may reference sensitive runtime failures. `sg-bug` must preserve the existing redaction rules and never persist raw secrets, cookies, tokens, private payloads, raw request headers, production PII, or screenshots that reveal sensitive data.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 10:04:53 UTC | sg-spec | GPT-5 Codex | Created ready spec for sg-bug professional bug loop orchestrator | ready | /sg-skill-build sg-bug |
| 2026-05-03 10:04:53 UTC | sg-ready | GPT-5 Codex | Readiness accepted from bounded user request and existing shipped Professional Bug Management contract | ready | /sg-skill-build sg-bug |
| 2026-05-03 10:12:30 UTC | sg-skill-build | GPT-5 Codex | Created sg-bug skill contract, public page, docs/help updates, runtime links, and validation pass | implemented | /sg-ship "add sg-bug professional bug orchestrator" |
| 2026-05-03 11:40:29 UTC | sg-ship | GPT-5 Codex | Closed trackers, reran validation, staged scoped sg-bug changes, and shipped the bug lifecycle orchestrator | shipped | none |

## Current Chantier Flow

- `sg-spec`: done, ready spec created.
- `sg-ready`: ready by bounded scope and existing professional bug loop doctrine.
- `sg-start`: implemented through `sg-skill-build`.
- `sg-verify`: passed by focused validation against this spec.
- `sg-end`: folded into full `sg-ship end` bookkeeping.
- `sg-ship`: shipped.

Next step: none
