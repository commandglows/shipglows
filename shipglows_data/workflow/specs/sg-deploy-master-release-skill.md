---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: "shipglows"
created: "2026-05-03"
created_at: "2026-05-03 06:00:00 UTC"
updated: "2026-05-03"
updated_at: "2026-05-03 06:43:56 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "feature"
owner: "Diane"
user_story: "As a ShipGlows operator ready to release work, I want one master deploy skill to run the release confidence loop from checks through ship, deploy readiness, browser or manual proof, verification, and optional release notes, so I do not have to manually stitch together sg-check, sg-ship, sg-prod, sg-browser, sg-auth-debug, sg-test, sg-verify, and sg-changelog."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/sg-deploy/SKILL.md"
  - "skills/sg-deploy/agents/openai.yaml"
  - "skills/REFRESH_LOG.md"
  - "skills/sg-help/SKILL.md"
  - "skills/sg-check/SKILL.md"
  - "skills/sg-ship/SKILL.md"
  - "skills/sg-prod/SKILL.md"
  - "skills/sg-browser/SKILL.md"
  - "skills/sg-auth-debug/SKILL.md"
  - "skills/sg-test/SKILL.md"
  - "skills/sg-verify/SKILL.md"
  - "skills/sg-changelog/SKILL.md"
  - "skills/references/project-development-mode.md"
  - "skills/references/chantier-tracking.md"
  - "skills/*/SKILL.md"
  - "tools/shipglows_sync_skills.sh"
  - "tools/skill_budget_audit.py"
  - "docs/technical/skill-runtime-and-lifecycle.md"
  - "docs/technical/code-docs-map.md"
  - "site/src/content/skills/sg-deploy.md"
  - "README.md"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.9.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.4.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
  - artifact: "skills/references/project-development-mode.md"
    artifact_version: "1.1.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.2.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Wave 19 canonicalized exact dependency paths against the current repository resource graph."
  - "User request 2026-05-03: create sg-deploy with the proposed flow."
  - "Prior analysis identified release as the highest-priority missing master skill: sg-check -> sg-ship -> sg-prod -> sg-browser/sg-auth-debug/sg-test -> sg-verify -> sg-changelog."
  - "skills/sg-help/SKILL.md already listed /sg-deploy but no skills/sg-deploy/SKILL.md existed."
  - "Existing release primitives are present as sg-check, sg-ship, sg-prod, sg-browser, sg-auth-debug, sg-test, sg-verify, and sg-changelog."
  - "Implemented skills/sg-deploy/SKILL.md and public site content on 2026-05-03."
  - "Ran runtime skill sync for sg-deploy; Claude and Codex current-user symlinks resolve correctly."
  - "Skill budget audit passes after compacting selected existing skill descriptions; absolute estimate is 7985/8000."
  - "Site build generated /skills/sg-deploy successfully."
  - "skill-creator quick_validate.py was attempted and rejected ShipGlows's existing argument-hint frontmatter convention; the field was preserved to match local ShipGlows skill contracts."
next_step: "none"
---

# Spec: sg-deploy Master Release Skill

## Title

sg-deploy Master Release Skill

## Status

ready

## User Story

As a ShipGlows operator ready to release work, I want one master deploy skill to run the release confidence loop from checks through ship, deploy readiness, browser or manual proof, verification, and optional release notes, so I do not have to manually stitch together `sg-check`, `sg-ship`, `sg-prod`, `sg-browser`, `sg-auth-debug`, `sg-test`, `sg-verify`, and `sg-changelog`.

## Minimal Behavior Contract

`sg-deploy` is the release orchestrator. It must decide the deploy scope, run or route the appropriate pre-ship checks, ship the bounded change through `sg-ship`, wait for deployed truth through `sg-prod`, route the correct post-deploy proof skill, run `sg-verify` before declaring the release complete, and optionally route release-note generation through `sg-changelog`. It must not duplicate the internals of those skills or claim success from a push, build status, or `200 OK` alone.

## Success Behavior

- Preconditions: the repository has release-intended changes or a just-pushed commit; the deploy target is current project, a provided project, or a provided URL; the requested scope is bounded; and no unrelated dirty files are silently included.
- Trigger: the user invokes `/sg-deploy`, `$sg-deploy`, or asks ShipGlows to deploy and verify the current work end to end.
- User/operator result: the operator gets one release confidence loop with concrete phase results, evidence routing, and the next safe command.
- System effect: `sg-deploy` orchestrates existing skills instead of reimplementing their internals; it writes chantier history only when exactly one spec is in scope.
- Success proof: checks are passed or explicitly skipped, ship result is known, deploy/runtime state is confirmed or blocked by `sg-prod`, required browser/auth/manual proof is routed or completed, `sg-verify` verdict is named, and release notes are generated or explicitly skipped.
- Silent success: not allowed. The final report must name what was and was not proven.

## Error Behavior

- Expected failures: ambiguous deploy scope, unbounded dirty files, check failure, unresolved high or critical bug risk, failed push, deployment pending beyond the polling window, deploy failure, missing deploy URL, insufficient browser/manual proof, auth-specific flow routed to the wrong proof skill, or failed verification.
- User/operator response: ask one targeted question only when the answer changes scope, skip-check risk, environment target, destructive behavior, or release framing.
- System effect: stop at the failing gate and report the recovery skill or command; do not continue to later gates as if the release is healthy.
- Must never happen: stage unrelated files, bypass `sg-ship` for commit/push, bypass `sg-prod` for hosted deploy truth, treat `curl 200` as full release proof, mutate production data without approval, expose secrets from logs, or close a chantier with missing verification.
- Silent failure: not allowed.

## Problem

ShipGlows has strong release primitives, but an operator still has to remember the correct order and distinction between technical checks, git shipping, deployment truth, browser proof, manual QA, verification, and changelog. `sg-help` already advertises `/sg-deploy`, so the missing skill is a discoverability and workflow integrity gap.

## Solution

Create `skills/sg-deploy/SKILL.md` as a master lifecycle skill for releases. It should orchestrate the existing release skills with explicit gates, stop conditions, evidence routing, and chantier tracing.

## Scope In

- Create `skills/sg-deploy/SKILL.md`.
- Keep `sg-deploy` as an orchestrator, not a replacement for `sg-check`, `sg-ship`, `sg-prod`, `sg-browser`, `sg-auth-debug`, `sg-test`, `sg-verify`, or `sg-changelog`.
- Support arguments such as no argument, `skip-check`, project name, URL, `--prod`, `--preview`, `--local`, and release-note intent.
- Use project development mode to decide whether local checks are enough before hosted proof.
- Route auth/session/callback proof to `sg-auth-debug`, non-auth browser proof to `sg-browser`, durable manual QA to `sg-test`, and deployment truth to `sg-prod`.
- Update `skills/sg-help/SKILL.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/skill-runtime-and-lifecycle.md`, and public skill content.
- Sync current-user runtime skill links.
- Run skill budget, metadata, and site build validations.

## Scope Out

- Do not implement deploy-provider internals inside `sg-deploy`.
- Do not change `sg-ship`, `sg-prod`, or Vercel MCP behavior unless validation reveals a separate bug.
- Do not commit or push as part of this implementation run.
- Do not create a new rollback system in this skill.

## Constraints

- Internal contracts are English; user-facing reports follow the active user language.
- `description` must remain compact and argument syntax must stay in `argument-hint`.
- `sg-deploy` is a lifecycle skill with `Trace category: obligatoire`.
- Runtime symlinks for Claude and Codex must be repaired or checked before verification.
- Public skill content must match `site/src/content.config.ts`.

## Dependencies

- Runtime: existing ShipGlows skills and Vercel/Git tooling owned by `sg-ship` and `sg-prod`.
- Document contracts: see `depends_on`.
- Metadata gaps: `skills/references/project-development-mode.md` has unknown metadata version in this spec.

## Invariants

- A release is not complete just because code was pushed.
- A deployment is not healthy just because the homepage returns `200`.
- Auth proof and generic browser proof must stay separate.
- Manual QA evidence belongs to `sg-test`, not ad hoc chat memory.
- Changelog generation is optional release documentation, not proof of behavior.

## Links & Consequences

- Upstream systems: `sg-check`, `sg-ship`, project development mode, bug risk gate, current chantier spec.
- Downstream systems: `sg-prod`, `sg-browser`, `sg-auth-debug`, `sg-test`, `sg-verify`, `sg-changelog`, public skill catalog.
- Cross-cutting checks: deployment, browser proof, auth, manual QA, documentation coherence, bug risk, and ship scope.

## Documentation Coherence

- Update `sg-help` because it already lists `/sg-deploy`.
- Update workflow docs and README so release orchestration is discoverable.
- Update technical lifecycle docs for the new release entrypoint.
- Add public skill page under `site/src/content/skills/sg-deploy.md`.

## Edge Cases

- User wants a push only: route to `sg-ship`, not full deploy.
- User wants only live state: route to `sg-prod`.
- User wants page-level proof for an already confirmed URL: route to `sg-browser`.
- User wants login/callback/session proof: route to `sg-auth-debug`.
- User asks `skip-check`: allow only with explicit risk in the report.
- Deployment provider is unknown: report partial deployment proof and stop before browser/manual claims.
- Repo is dirty with unrelated files: block or ask for scoped staging.

## Implementation Tasks

- [x] Task 1: Create the skill contract
  - File: `skills/sg-deploy/SKILL.md`
  - Action: Add ShipGlows-style frontmatter, chantier tracking, release mission, phase gates, stop conditions, evidence routing, and final report.
  - User story link: Provides the missing `/sg-deploy` entrypoint.
  - Depends on: None
  - Validate with: `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - Notes: Keep the body under the skill budget threshold.

- [x] Task 2: Update discoverability and docs
  - File: `skills/sg-help/SKILL.md`, `README.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `docs/technical/skill-runtime-and-lifecycle.md`
  - Action: Replace stale deploy wording and name `sg-deploy` as the release orchestrator.
  - User story link: Operators can find the new release loop.
  - Depends on: Task 1
  - Validate with: `rg -n "sg-deploy|deploy" skills/sg-help/SKILL.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical/skill-runtime-and-lifecycle.md`
  - Notes: Do not overstate release safety.

- [x] Task 3: Add public skill content
  - File: `site/src/content/skills/sg-deploy.md`
  - Action: Add schema-compatible public skill page.
  - User story link: Public catalog includes the release orchestrator.
  - Depends on: Task 1
  - Validate with: `pnpm --dir shipglows-site build`
  - Notes: No ShipGlows governance metadata in runtime content.

- [x] Task 4: Sync runtime links and validate
  - File: `tools/shipglows_sync_skills.sh`, runtime symlinks
  - Action: Repair and check current-user Claude/Codex links for `sg-deploy`.
  - User story link: The skill is discoverable by current operator runtimes.
  - Depends on: Task 1
  - Validate with: `tools/shipglows_sync_skills.sh --repair --skill sg-deploy`; `tools/shipglows_sync_skills.sh --check --skill sg-deploy`
  - Notes: A new Claude/Codex session may still be needed for runtime list refresh.

- [x] Task 5: Verify the chantier
  - File: `specs/sg-deploy-master-release-skill.md`
  - Action: Run metadata, skill, and site validations; update this spec run history.
  - User story link: Proves the implementation meets the release orchestration contract.
  - Depends on: Tasks 1-4
  - Validate with: `python3 tools/shipglows_metadata_lint.py specs/sg-deploy-master-release-skill.md README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md docs/technical`; `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`; `pnpm --dir shipglows-site build`
  - Notes: `quick_validate.py` rejects ShipGlows's `argument-hint` field; keep `argument-hint` for local skill consistency and record the validator incompatibility instead of weakening the local contract.

## Acceptance Criteria

- [x] AC 1: Given ShipGlows has no `skills/sg-deploy/SKILL.md`, when the skill is created, then `sg-deploy` has valid frontmatter and a compact trigger description.
- [x] AC 2: Given the operator invokes `sg-deploy`, when release scope is valid, then the skill routes through `sg-check`, `sg-ship`, `sg-prod`, evidence proof, `sg-verify`, and optional `sg-changelog`.
- [x] AC 3: Given a release touches auth/session/callback behavior, when post-deploy proof is required, then the skill routes to `sg-auth-debug`, not generic `sg-browser`.
- [x] AC 4: Given a release needs only non-auth page proof, when the deployment URL is confirmed, then the skill routes to `sg-browser`.
- [x] AC 5: Given public skill discovery changed, when the site builds, then `sg-deploy` has a schema-valid public skill page.
- [x] AC 6: Given current-user runtime links are checked, then Claude and Codex symlinks for `sg-deploy` resolve to the ShipGlows skill.

## Test Strategy

- Unit: ShipGlows skill budget/frontmatter review; `quick_validate.py` was attempted but is incompatible with ShipGlows's `argument-hint` convention.
- Integration: `skill_budget_audit.py`, `shipglows_sync_skills.sh --check --skill sg-deploy`, metadata lint, and site build.
- Manual: inspect final report against this spec.

## Risks

- Security impact: yes, because deployment logs and production proof can expose sensitive information; mitigated by routing log ownership to `sg-prod` and keeping redaction rules explicit.
- Product/data/performance risk: medium, because an overly broad deploy orchestrator could overclaim release readiness; mitigated by explicit limits and stop conditions.

## Execution Notes

- Read first: `skills/sg-ship/SKILL.md`, `skills/sg-prod/SKILL.md`, `skills/sg-browser/SKILL.md`, `skills/sg-test/SKILL.md`, `skills/sg-help/SKILL.md`.
- Validate with: commands named in Implementation Tasks.
- Stop conditions: failed validation, missing runtime links, stale public docs, unrelated dirty files, or verification mismatch.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-03 06:00:00 UTC | sg-spec | GPT-5 Codex | Created ready spec for sg-deploy master release skill | ready | /sg-skill-build sg-deploy |
| 2026-05-03 06:43:56 UTC | sg-skill-build | GPT-5 Codex | Created sg-deploy skill contract, public page, docs/help updates, runtime links, and validation pass | implemented | /sg-ship "add sg-deploy release orchestrator" |
| 2026-05-03 09:55:58 UTC | sg-ship | GPT-5 Codex | Closed tracking, changelog, bug gate, staged scoped release changes, and shipped the sg-deploy lifecycle skill | shipped | none |

## Current Chantier Flow

- `sg-spec`: done, ready spec created.
- `sg-ready`: ready by direct spec gate for this bounded skill request.
- `sg-start`: implemented through `sg-skill-build`.
- `sg-verify`: passed by focused validation against this spec.
- `sg-end`: folded into full `sg-ship end` bookkeeping.
- `sg-ship`: shipped.

Next step: none
