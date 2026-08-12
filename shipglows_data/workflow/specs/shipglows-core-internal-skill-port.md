---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-11"
created_at: "2026-06-11 10:05:00 UTC"
updated: "2026-06-11"
updated_at: "2026-06-11 10:15:19 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "skill-maintenance"
owner: "Diane"
user_story: "As the ShipGlows operator, I want ShipGlows Core to become an internal ShipGlows skill with a versioned audit tool, so I can use it on future servers without publishing or maintaining a separate public Codex plugin."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/900-shipglows-core/SKILL.md"
  - "tools/audit_shipglows_skills.py"
  - "skills/references/skill-execution-fidelity.md"
  - "skills/302-sg-help/SKILL.md"
  - "shipglows_data/technical/codex-plugin-packaging.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "/home/claude/plugins/shipglows-core/"
  - "/home/claude/.agents/plugins/marketplace.json"
  - "/home/claude/.codex/config.toml"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.4.0"
    required_status: "active"
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.1.1"
    required_status: "active"
  - artifact: "shipglows_data/technical/codex-plugin-packaging.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "The operator decided that ShipGlows Core is useful internally but should not be packaged as the public user plugin."
  - "The local personal marketplace now lists only shipglows, not shipglows-core."
  - "Existing pilot plugin source remains at /home/claude/plugins/shipglows-core/ with one shipglows-core skill and audit_shipglows_skills.py."
  - "The public plugin strategy keeps shipglows as the user-facing entrypoint and uses sparse bootstrap for full corpus access."
  - "2026-06-11 implementation added skills/900-shipglows-core/SKILL.md and tools/audit_shipglows_skills.py."
  - "2026-06-11 validation passed: audit script, skill-code index lint, metadata lint, skill budget audit, runtime sync checks, marketplace JSON, and git diff check."
next_step: "/104-sg-end shipglows-core internal skill port"
---

# Title

ShipGlows Core Internal Skill Port

## Status

ready

## User Story

As the ShipGlows operator, I want ShipGlows Core to become an internal ShipGlows skill with a versioned audit tool, so I can use it on future servers without publishing or maintaining a separate public Codex plugin.

## Minimal Behavior Contract

ShipGlows must expose an internal operator skill named `900-shipglows-core` from the ShipGlows repo itself. The skill must audit and inspect local ShipGlows skills through a versioned `tools/audit_shipglows_skills.py` helper, preserve read-only behavior by default, and clearly separate internal operator usage from the public `shipglows` plugin. If the ShipGlows source tree or audit helper is unavailable, the skill reports a ShipGlows installation gap instead of relying on the deprecated plugin path. The easy edge case is leaving stale `~/plugins/shipglows-core/...` references that work only on Diane's current machine and break on a new server.

## Success Behavior

Given a machine with the ShipGlows repo installed and current-user skill links synced, when Diane invokes `$900-shipglows-core audit local ShipGlows skills`, Codex loads `skills/900-shipglows-core/SKILL.md`, resolves ShipGlows-owned paths from `${SHIPGLOWS_ROOT:-$HOME/shipglows}`, runs or points to `tools/audit_shipglows_skills.py`, reports audit findings in French for the operator, and does not require `shipglows-core@personal` to be installed from a marketplace.

## Error Behavior

If `${SHIPGLOWS_ROOT:-$HOME/shipglows}` is missing, `skills/` is missing, the audit helper is missing, or runtime skill links cannot be repaired because a non-symlink target blocks them, the run must stop with a concrete installation/runtime-link gap. It must not silently fall back to `/home/claude/plugins/shipglows-core`, scrape public docs for execution rules, or ask the operator to test before local validation paths have been attempted.

## Problem

`shipglows-core` started as a Codex plugin pilot. That proved local plugin packaging works, but it also created confusion: the operator thought ShipGlows Core might be a multi-skill bundle, while the actual pilot is one plugin-native skill plus one audit script. Keeping it as a public or marketplace plugin would make an internal maintenance surface look like a user-facing product and would be harder to recover on a new server.

## Solution

Promote the useful part of the pilot into the ShipGlows repo: create `skills/900-shipglows-core/SKILL.md`, move the audit helper into `tools/audit_shipglows_skills.py`, update references and docs away from `~/plugins/shipglows-core/...`, sync the new skill into current runtimes, and leave the old plugin source as deprecated local history until a later cleanup safely removes it.

## Scope In

- Create the internal `900-shipglows-core` skill under `skills/900-shipglows-core/`.
- Add the audit helper under `tools/audit_shipglows_skills.py`.
- Update ShipGlows references that instruct agents to run the old plugin script path.
- Update plugin packaging documentation to state that `shipglows-core` is internal-only and not a public marketplace/plugin surface.
- Update help/discovery surfaces enough that Diane can find `$900-shipglows-core`.
- Remove `shipglows-core` from the personal marketplace listing when still present.
- Keep current-user Codex/Claude skill runtime links discoverable through `tools/shipglows_sync_skills.sh`.

## Scope Out

- Publishing `shipglows-core` to OpenAI curated marketplace.
- Adding `shipglows-core` to the public `shipglows` plugin bundle.
- Deleting the old `/home/claude/plugins/shipglows-core/` source folder in this run.
- Removing installed plugin config from `~/.codex/config.toml` unless a later explicit cleanup is requested.
- Rewriting the audit algorithm beyond portability/path updates.
- Renaming existing public skill invocation keys.

## Constraints

- Internal contracts and skill bodies stay in English; final operator reports stay in the user's active language.
- `shipglows-core` is an internal operator tool, not a user-facing product claim.
- ShipGlows-owned paths must resolve from `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Public plugin users must not need or see `shipglows-core` to start using `shipglows`.
- No secrets, private transcripts, local caches, or customer context may be copied into the skill or tool.
- Any runtime sync must preserve existing user files and stop on non-symlink conflicts.

## Test Contract

- `surface`: ShipGlows skill/runtime portability and local audit tooling.
- `proof_profile`: scenario-first plus mechanical checks.
- `proof_order`: metadata lint -> audit helper run -> skill budget audit -> focused stale-path scans -> runtime skill sync check -> plugin list check.
- `checklist_path`: none; command evidence is sufficient.
- `required_scenario_ids`:
  - `core-internal-audit`: `$900-shipglows-core` can direct the agent to audit local skills through `tools/audit_shipglows_skills.py`.
  - `new-server-portability`: no required execution path depends on `/home/claude/plugins/shipglows-core`.
  - `public-plugin-separation`: `shipglows-core` is not listed in the personal marketplace and is not framed as a public plugin.
  - `runtime-discovery`: `tools/shipglows_sync_skills.sh --check --skill 900-shipglows-core` passes.
- `required_results`: all validation commands pass or report only accepted non-blocking review findings documented in the final report.
- `exception_with_proof`: no hosted/browser proof is required because this is local skill/tool packaging, not a website or app runtime change.
- `exception_without_proof`: none allowed.

## Dependencies

- Local ShipGlows repo at `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.
- Existing pilot plugin at `/home/claude/plugins/shipglows-core/` for source material only.
- `python3` for the audit script.
- Codex/Claude runtime skill link helper `tools/shipglows_sync_skills.sh`.
- Fresh external docs verdict: `fresh-docs not needed`; the change depends on existing local Codex plugin/skill behavior already observed in this workspace, not a new external API.

## Invariants

- `shipglows` remains the public user plugin.
- `900-shipglows-core` remains internal and operator-oriented.
- Audit execution is read-only by default.
- The audit script uses `SHIPGLOWS_ROOT` or `$HOME/shipglows`, not the old plugin directory, to locate skills.
- The old plugin can remain installed locally during transition, but it must not be required for the new skill path.
- Runtime links must be symlinks managed by ShipGlows tooling, not manual copies.

## Links & Consequences

- `skills/705-sg-conversation-audit/SKILL.md` currently points at the old plugin audit path and must route to the versioned tool instead.
- `skills/references/skill-execution-fidelity.md` must stop describing the plugin audit script as the active path.
- Specs that mention the old path should remain historical evidence unless they contain active validation commands.
- `shipglows_data/technical/codex-plugin-packaging.md` and `code-docs-map.md` must reflect that the public plugin is `shipglows`, while `shipglows-core` is internal.
- The personal marketplace should expose `shipglows` only; `shipglows-core` access comes from repo skill sync.

## Documentation Coherence

Update internal docs only. No public website skill page should be created for `shipglows-core` in this run because the operator explicitly wants it hidden from user-facing product packaging. README updates are only needed if current text still implies the pilot plugin is a user path.

## Edge Cases

- A future server has ShipGlows cloned but no `~/plugins/shipglows-core`; `$900-shipglows-core` must still work.
- The old plugin remains installed in current Codex config; this must not be mistaken for the canonical source.
- A runtime skill target exists as a real directory instead of a symlink; sync must block instead of overwriting.
- Audit script review findings are not automatic permission to batch-edit all skills.
- Public plugin packaging docs must not encourage users to install many plugins or install `shipglows-core`.

## Implementation Tasks

1. File: `skills/900-shipglows-core/SKILL.md`
   - Action: create a compact internal operator skill that loads canonical paths, reports through the shared contract, defaults to read-only audit/inspection, and points to `tools/audit_shipglows_skills.py`.
   - Validate with: `rg -n "Mission|Scope Gate|Required References|Stop Conditions|Validation|Report Modes|audit_shipglows_skills" skills/900-shipglows-core/SKILL.md`.
2. File: `tools/audit_shipglows_skills.py`
   - Action: add the pilot audit helper to the versioned ShipGlows toolset with neutral wording and canonical `SHIPGLOWS_ROOT` behavior.
   - Validate with: `python3 tools/audit_shipglows_skills.py`.
3. Files: `skills/705-sg-conversation-audit/SKILL.md`, `skills/references/skill-execution-fidelity.md`
   - Action: replace active old plugin script paths with `python3 ${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/audit_shipglows_skills.py` or equivalent canonical wording.
   - Validate with: `rg -n "plugins/shipglows-core|~/plugins/shipglows-core|audit_shipglows_skills" skills/705-sg-conversation-audit/SKILL.md skills/references/skill-execution-fidelity.md`.
4. Files: `shipglows_data/technical/codex-plugin-packaging.md`, `shipglows_data/technical/code-docs-map.md`
   - Action: document that `shipglows-core` is internal-only and the public plugin remains `shipglows`.
   - Validate with: metadata lint and focused `rg` checks for public/internal wording.
5. Runtime: current-user skill links
   - Action: run `tools/shipglows_sync_skills.sh --repair --skill 900-shipglows-core` and `--check --skill 900-shipglows-core`.
   - Validate with: the sync helper output and `codex plugin list` showing only `shipglows` in the personal marketplace.

## Acceptance Criteria

- [x] AC 1: Given ShipGlows is cloned on a machine, when `$900-shipglows-core` is invoked, then Codex can load the internal skill from `skills/900-shipglows-core/SKILL.md` after runtime sync.
- [x] AC 2: Given local skills exist, when `python3 tools/audit_shipglows_skills.py` runs, then it audits `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills` without depending on the old plugin path.
- [x] AC 3: Given the personal marketplace is listed, then `shipglows-core` is absent and `shipglows` remains present.
- [x] AC 4: Given docs and references mention active audit commands, then they point to the versioned ShipGlows tool path, not `~/plugins/shipglows-core/...`.
- [x] AC 5: Given the public plugin docs are read by a fresh agent, then they preserve the distinction between public `shipglows` and internal `shipglows-core`.
- [x] AC 6: Given runtime sync is checked, then current-user Codex and Claude links for `900-shipglows-core` are valid symlinks or the run reports the concrete blocked path.

## Test Strategy

- Run the new audit helper locally.
- Run metadata lint on changed docs/specs with frontmatter.
- Run skill budget audit for the full skill tree.
- Run focused scans for old plugin paths and internal/public wording.
- Run current-user skill sync repair/check for `900-shipglows-core`.
- Run plugin list to confirm the personal marketplace no longer presents `shipglows-core`.
- Do not run site build unless rendered site content changes.

## Risks

- Risk: duplicate skill/plugin names confuse Codex while the old plugin remains enabled. Mitigation: make the repo skill canonical, remove marketplace discoverability, and later uninstall the pilot plugin after a clean transition.
- Risk: stale validation commands in specs keep pointing to the old plugin path. Mitigation: update active references and docs; preserve historical specs unless they are active run commands.
- Risk: public users see internal tooling as a product feature. Mitigation: keep it out of the public plugin and site skill pages.
- Risk: audit script false positives drive churn. Mitigation: keep findings classified as hard/review/style and require scenario-first triage before edits.

## Execution Notes

- Read first: old plugin skill, old audit script, `skills/references/skill-execution-fidelity.md`, and `shipglows_data/technical/codex-plugin-packaging.md`.
- Proof path: `scenario-first`.
- Stop if readiness is not `ready`, runtime sync blocks on non-symlink files, metadata lint fails for changed artifacts, or plugin list still exposes `shipglows-core` in the personal marketplace after the marketplace update.
- Do not delete `/home/claude/plugins/shipglows-core/` in this chantier.
- Do not edit `~/.codex/config.toml` unless the operator explicitly asks to uninstall the old plugin after migration.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 10:05:00 UTC | 100-sg-spec | GPT-5 Codex | Created spec for porting ShipGlows Core from plugin pilot into an internal ShipGlows skill and versioned audit tool. | draft | /101-sg-ready shipglows-core internal skill port |
| 2026-06-11 10:06:29 UTC | 101-sg-ready | GPT-5 Codex | Checked required sections, user-story fit, scope, proof path, security posture, docs coherence, and metadata lint. | ready | /009-sg-skill-build shipglows-core internal skill port |
| 2026-06-11 10:15:19 UTC | 009-sg-skill-build | GPT-5 Codex | Added internal 900-shipglows-core skill, versioned audit helper, routing/help/docs updates, runtime sync, and public-plugin separation docs. | implemented | /103-sg-verify shipglows-core internal skill port |
| 2026-06-11 10:15:19 UTC | 103-sg-verify | GPT-5 Codex | Verified scenario-first contract with audit script, skill-code index lint, metadata lint, skill budget audit, runtime sync checks, marketplace JSON, stale-path scan, and diff check. | verified | /104-sg-end shipglows-core internal skill port |
| 2026-06-11 10:15:19 UTC | 001-sg-build | GPT-5 Codex | Orchestrated the spec-first build from operator request through local implementation and verification. | implemented locally; ship pending | /104-sg-end shipglows-core internal skill port |

## Current Chantier Flow

100-sg-spec ✅ -> 101-sg-ready ✅ -> 009-sg-skill-build ✅ -> 103-sg-verify ✅ -> 104-sg-end next -> 005-sg-ship pending
