---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.1"
project: ShipGlows
created: "2026-06-01"
created_at: "2026-06-01 00:00:00 UTC"
updated: "2026-06-12"
updated_at: "2026-06-12 03:36:35 UTC"
status: ready
source_skill: sg-spec
source_model: GPT-5 Codex
scope: skill-maintenance
owner: Diane
confidence: high
user_story: "As a ShipGlows operator, I want a reusable local-to-cloud sync skill, so that every project can implement account promotion, merge, UX, and security correctly without rebuilding the doctrine from chat memory."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-local-cloud-sync/SKILL.md
  - skills/sg-local-cloud-sync/references/
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/600-sg-local-cloud-sync/references/sync-guidance-overlay-and-merge-pattern.md
  - skills/sg-help/references/help-catalog.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
  - site/src/content/skills/sg-local-cloud-sync.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/master-workflow-lifecycle.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "WinFlowz local-to-cloud promotion chantier exposed repeatable risks: account creation must not erase local data, cloud seeding requires account association, secrets should be excluded by default, and conflict resolution needs reliable metadata."
  - "Project-local playbooks were created after the WinFlowz chantier, but their doctrine should become reusable across future projects."
  - "Existing ShipGlows skills do not own local/cloud data promotion and merge semantics."
next_step: "/103-sg-verify sync-guidance-overlay-and-merge-pattern"
---

# Title

sg-local-cloud-sync skill

## Status

ready

## User Story

As a ShipGlows operator, I want a reusable local-to-cloud sync skill, so that every project can implement account promotion, merge, UX, and security correctly without rebuilding the doctrine from chat memory.

## Minimal Behavior Contract

When an operator invokes `sg-local-cloud-sync` for a project or feature, the skill must turn the request into either a read-only sync contract, a `Chantier potentiel`, or a spec-first implementation route. It must cover local data promotion, remembered account association, cloud hydration, merge/conflict policy, tombstones, offline queues, sync status UX, settings-save state, sensitive-data exclusions, tenant boundaries, proof order, and documentation impact. It must refuse implementation from implicit chat memory or unsafe defaults when data loss, cross-account replay, secrets, or conflict semantics are unresolved.

## Success Behavior

Given a project that needs local-to-cloud sync, the skill produces a concrete Sync Contract or routes to `/sg-spec` with enough detail for an implementation agent to preserve local data during account creation/relogin, merge distinct local and cloud records safely, surface sync/save states to users, and validate the behavior through automated and manual proof. For ShipGlows discoverability, the new skill is visible in current-user Claude/Codex runtime links, documented in help and public skill surfaces, and mapped in technical docs.

## Error Behavior

If the project lacks clear ownership, auth identity, merge keys, durable local storage, conflict metadata, sensitive-data policy, or proof surface, the skill must report `blocked` or `Chantier potentiel: oui/incertain` instead of inventing a sync design. It must never recommend syncing secrets by convenience, deleting local data on account creation, trusting UI-only security, or claiming reinstall recovery without a durable remote proof path.

## Problem

Local-first products often let users try the app before creating an account. If account creation switches to a cloud store without promoting or merging existing local data, the user loses work and trust. The WinFlowz chantier showed this is not a one-off implementation detail: it combines data doctrine, UX status feedback, sensitive-data policy, conflict resolution, metadata, offline behavior, and proof obligations.

## Solution

Create `sg-local-cloud-sync` as a domain skill with compact activation rules and skill-local technical references. The skill should generate reusable sync contracts, raise spec-first chantiers for implementation work, and enforce security and UX gates before any project claims sync/reinstall recovery.

## Scope In

- New `skills/sg-local-cloud-sync/SKILL.md`.
- Skill-local references for sync doctrine, UX/security checklist, and Flutter implementation notes.
- Public skill page for discoverability.
- `sg-help` catalog, README, workflow, and technical map updates.
- Runtime symlink repair/check for current-user Claude/Codex skill discovery.
- Scenario-first proof for skill behavior and mechanical validation for changed docs.

## Scope Out

- Implementing sync inside WinFlowz or any product project.
- Migrating existing project-local playbooks out of WinFlowz.
- Provider-specific SDK code for Firebase, Supabase, Convex, iCloud, or custom backends.
- Promising secrets synchronization as a default.
- Rewriting existing master lifecycle skills.

## Constraints

- Internal skill contracts and technical references must be in English.
- User-facing reports from the skill should use the active user language.
- The skill must orchestrate `sg-spec`, `sg-ready`, `sg-build/sg-start`, `sg-verify`, `sg-docs`, and `sg-ship` rather than duplicating their internals.
- Sensitive data, account boundaries, tenant isolation, and destructive merges are high-risk gates.
- External SDK behavior must pass the Documentation Freshness Gate when a project implementation depends on provider details.
- Current runtime tool rules prevent subagent use unless the user explicitly requests it; this run records master-only execution as a degraded topology compared with the skill-build default.

## Test Contract

- surface: ShipGlows skill contract, skill-local references, help/public docs, runtime symlinks.
- proof_profile: scenario-first plus mechanical validation.
- proof_order: spec/readiness review -> skill contract rg checks -> runtime link check -> budget audit -> metadata lint -> site build -> targeted stale-name and leak checks -> sg-verify route.
- checklist_path: none; no manual product QA is required for this skill contract.
- required_scenario_ids:
  - LCS-001 local anonymous data plus new account must route to promotion/seed/merge instead of local wipe.
  - LCS-002 existing cloud account plus unassociated local data must require confirmation or safe import choice.
  - LCS-003 remembered different account must block cross-account replay.
  - LCS-004 same business key with conflicting payload must require deterministic conflict policy.
  - LCS-005 secrets or sensitive local content must be excluded by default unless a future spec explicitly designs a secure secret-sync system.
  - LCS-006 UI must expose sync/save/loading/success/error states and retry/recheck behavior.
  - LCS-007 Flutter projects must route durable local store, Riverpod/provider entrypoint, adapter/controller split, tests, and web/device proof in the right order.
- required_results: skill routes each scenario to a concrete sync contract, spec requirement, blocked condition, or proof obligation.
- exception_with_proof: product-level device/provider QA is not applicable because this chantier changes ShipGlows skill guidance, not a product sync implementation.
- exception_without_proof: none.

## Dependencies

- ShipGlows skill runtime and lifecycle references listed in frontmatter.
- Public site content schema already supports `site/src/content/skills/*.md`; no external framework freshness check is needed beyond local build validation because this chantier follows an existing content pattern.
- Runtime symlink helper: `tools/shipglows_sync_skills.sh`.

## Invariants

- Account creation must not silently discard local data.
- Cross-account replay must be blocked unless the user explicitly imports/export data through a designed flow.
- Merge policy must be domain-specific and testable; latest-wins is allowed only with reliable `updatedAt` and device/source metadata.
- Tombstones are required for delete-capable domains.
- Sensitive data and secrets are excluded by default.
- A sync UI state is not itself a security control.
- Reinstall/relogin recovery cannot be promised until durable remote write and hydration are proven.

## Links & Consequences

- `sg-build` and project implementation specs can route to this skill when local-first data sync appears.
- `sg-onboarding` remains responsible for broader first-success activation; this skill owns sync-specific UX states and data trust.
- `sg-docs` remains responsible for documentation corpus updates; this skill names the docs impact.
- Public skill pages and help catalog must mention the new entrypoint.
- Skill budget and runtime link checks are required because a new invocation directory is added.

## Documentation Coherence

- Update README and `shipglows_data/workflow/playbooks/spec-driven-workflow.md` to name the new skill in routing tables and lifecycle summaries.
- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` and `shipglows_data/technical/code-docs-map.md` for skill inventory and owned references.
- Update `skills/sg-help/references/help-catalog.md`.
- Add public page `site/src/content/skills/sg-local-cloud-sync.md`.
- No project product docs are changed by this ShipGlows skill work.

## Edge Cases

- Local store is not durable enough to claim reinstall recovery.
- Cloud store is empty but the user is signing into an existing account.
- Cloud store has records under the same business key with different payloads.
- Local data was previously associated with another remote account.
- Delete records need tombstones or a retention policy.
- Offline writes occur during promotion or conflict resolution.
- Settings changes appear saved locally but remote sync fails.
- Provider/auth config is unavailable or local fallback auth is active.
- A user asks to sync secrets for convenience.

## Implementation Tasks

1. Create `skills/sg-local-cloud-sync/SKILL.md` with canonical path, chantier, reporting, required references, mode detection, sync contract, security, proof, stop conditions, validation, and final report sections.
2. Create `skills/sg-local-cloud-sync/references/local-cloud-sync-doctrine.md` with the reusable decision matrix from the WinFlowz chantier.
3. Create `skills/sg-local-cloud-sync/references/ux-security-checklist.md` with user-visible sync/save states, sensitive-data policy, tenant/account boundaries, logging, retry, and abuse controls.
4. Create `skills/sg-local-cloud-sync/references/flutter-implementation-checklist.md` for Flutter/Riverpod/local-store/provider proof details.
5. Add `site/src/content/skills/sg-local-cloud-sync.md`.
6. Update `skills/sg-help/references/help-catalog.md`, `README.md`, and `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.
7. Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` and `shipglows_data/technical/code-docs-map.md`.
8. Repair/check current-user runtime symlinks with `tools/shipglows_sync_skills.sh --repair --skill sg-local-cloud-sync` and `--check`.
9. Run validation commands from the skill and spec, then update `Skill Run History`.

## Acceptance Criteria

- `sg-local-cloud-sync` exists and is discoverable as a current-user runtime skill.
- The skill describes distinct read-only, audit, spec-routing, and implementation-routing behavior.
- The skill blocks unsafe local wipe, cross-account replay, unresolved secrets sync, unproven reinstall claims, and vague conflict policies.
- The skill-local references cover account association, merge matrix, UX sync/save status, security/privacy, and Flutter implementation notes.
- Help, README, workflow, technical map, and public skill page are aligned.
- Skill budget audit, metadata lint, runtime link check, site build, and targeted `rg` checks pass or any blocker is reported.
- The final report includes Documentation Update Plan, Editorial Update Plan, Fresh external docs verdict, proof path, and compact chantier state.

## Test Strategy

Use `scenario-first` because this is a skill contract change. Validate the pressure scenarios mechanically with `rg` checks across the new skill and references. Run the skill budget audit for context size, metadata lint for changed governance docs, runtime sync helper for current-user availability, site build for public content schema, and `git diff --check`.

## Risks

- A too-broad skill could overlap `sg-build` or `sg-onboarding`; mitigated by making it a domain source/support skill that routes implementation and onboarding work instead of owning those internals.
- A too-short skill could omit the hard sync doctrine; mitigated by skill-local references.
- Public docs could imply guaranteed sync implementation; mitigated by wording the skill as a contract/routing/proof entrypoint.
- Secrets sync could be normalized accidentally; mitigated by default exclusion and explicit stop condition.

## Execution Notes

- Read `skills/sg-skill-build/SKILL.md`, `skills/references/decision-quality-contract.md`, `skills/references/spec-driven-development-discipline.md`, `skills/references/skill-context-budget.md`, and existing public skill page patterns before editing.
- Fresh external docs verdict: `fresh-docs not needed` for this skill creation because no external SDK behavior is implemented; future project implementations must use fresh provider docs.
- Preferred proof path: `scenario-first`.
- Stop if another existing skill materially owns the same operator trigger or if runtime symlink repair is blocked by non-symlink files.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-01 | sg-spec | GPT-5 Codex | Created skill-maintenance spec for reusable local-to-cloud sync skill. | ready | `/sg-start shipglows_data/workflow/specs/sg-local-cloud-sync-skill.md` |
| 2026-06-01 | sg-ready | GPT-5 Codex | Reviewed readiness criteria while creating the spec; no open questions remained. | ready | `/sg-start shipglows_data/workflow/specs/sg-local-cloud-sync-skill.md` |
| 2026-06-01 | sg-skill-build | GPT-5 Codex | Created `sg-local-cloud-sync`, skill-local references, runtime links, public page, help, router, README, workflow, and technical docs updates. | implemented | `/sg-verify shipglows_data/workflow/specs/sg-local-cloud-sync-skill.md` |
| 2026-06-01 | sg-skills-refresh | GPT-5 Codex | Refreshed new skill against local ShipGlows governance, context budget, runtime visibility, public surface, and routing coherence. | implemented | `/sg-verify shipglows_data/workflow/specs/sg-local-cloud-sync-skill.md` |
| 2026-06-01 | sg-verify | GPT-5 Codex | Verified scenario-first proof, metadata lint, budget audit, runtime links, site build, routing/docs coherence, and diff hygiene. | verified | `/sg-ship "Add sg-local-cloud-sync skill"` |
| 2026-06-12 03:36:35 UTC | 009-sg-skill-build | GPT-5 Codex | Added the SocialGlowz-inspired sync guidance overlay and merge pattern reference, connected it to `600-sg-local-cloud-sync`, updated the public skill page, and logged the refresh. | implemented | `/103-sg-verify sync-guidance-overlay-and-merge-pattern` |
| 2026-06-12 04:03:04 UTC | 103-sg-verify | GPT-5 Codex | Verified the SocialGlowz-inspired sync guidance overlay reference, skill routing, public page, refresh log, metadata, runtime sync, site build, scenario scans, secret scan, and diff hygiene. | verified | `/005-sg-ship "Add SocialGlowz sync guidance reference"` |
| 2026-06-12 04:19:44 UTC | 005-sg-ship | GPT-5 Codex | Quick-shipped the SocialGlowz-inspired sync guidance reference, `600-sg-local-cloud-sync` routing, `006-sg-design` cloud-sync bridge, public skill docs, and refresh log. | shipped | pushed to `origin/main` |

## Current Chantier Flow

sg-spec ✅ -> sg-ready ✅ -> 009-sg-skill-build ✅ -> 307-sg-skills-refresh ✅ -> local validation ✅ -> sg-verify ✅ -> sg-ship ✅🎯
