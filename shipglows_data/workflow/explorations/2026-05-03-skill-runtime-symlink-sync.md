---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-05-03"
updated: "2026-05-03"
status: draft
source_skill: sg-explore
scope: "skill-runtime-symlink-sync"
owner: "Diane"
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/*/SKILL.md"
  - "install.sh"
  - "~/.codex/skills"
  - "~/.claude/skills"
  - "skills/sg-skill-build/SKILL.md"
  - "skills/sg-build/SKILL.md"
  - "skills/sg-browser/SKILL.md"
evidence:
  - "2026-05-03 local comparison: `sg-browser` and `sg-build` exist in ShipGlows skills but are missing from both current-user Claude and Codex skill directories."
  - "2026-05-03 local check: `sg-skill-build` runtime symlinks were manually repaired before this exploration."
  - "install.sh already owns `configure_skills`, `ensure_skill_link`, and `verify_skill_link`, but that logic is not available as a small reusable runtime sync command."
depends_on: []
supersedes: []
next_step: "/sg-spec Shared ShipGlows skill runtime sync"
---

# Exploration Report: Skill Runtime Symlink Sync

## Starting Question

Should `sg-skill-build` own symlink creation directly, or should ShipGlows extract a reusable skill runtime sync mechanism because other skills and workflows need it too?

## Context Read

- `skills/sg-explore/SKILL.md` - confirmed this is exploration mode, so no implementation should happen.
- `install.sh` - contains existing symlink logic through `configure_skills`, `ensure_skill_link`, and `verify_skill_link`.
- `skills/sg-skill-build/SKILL.md` - currently gained a local runtime-link gate for newly created or renamed skills.
- `skills/sg-build/SKILL.md` - source skill exists but runtime symlinks are missing.
- `~/.codex/skills` and `~/.claude/skills` - current-user runtime discovery directories are missing `sg-browser` and `sg-build`.

## Internet Research

- None. This is local ShipGlows runtime behavior.

## Problem Framing

ShipGlows has two separate states for a skill:

```text
repo source of truth                 runtime discovery
skills/<name>/SKILL.md  ───────▶     ~/.codex/skills/<name>
                                      ~/.claude/skills/<name>
```

The current failure happens between those two states. A skill can be fully implemented and shipped in the repo while still being invisible to a local Codex or Claude session because the runtime symlink was not created.

This affects more than `sg-skill-build`. Current local evidence shows `sg-browser` and `sg-build` are also missing from both runtime directories.

## Option Space

### Option A: Keep symlink logic inside `sg-skill-build`

- Summary: `sg-skill-build` creates or verifies `~/.codex/skills/<name>` and `~/.claude/skills/<name>` for the skill it just created or renamed.
- Pros: small and immediately relevant to skill creation.
- Cons: does not help `sg-init`, `sg-check`, `sg-ship`, install repair flows, or drift checks for existing skills.

### Option B: Extract a reusable runtime sync helper

- Summary: create a small ShipGlows-owned helper that compares `skills/*/SKILL.md` with current-user runtime skill directories, repairs missing or stale symlinks, and blocks on non-symlink collisions.
- Pros: one implementation can serve `install.sh`, `sg-skill-build`, diagnostics, and future repair flows.
- Cons: needs a spec because it touches installer behavior, runtime discovery, and possibly multi-user scope.

### Option C: Rely only on `install.sh`

- Summary: tell operators to rerun install/configuration when a new skill is added.
- Pros: no new helper.
- Cons: too heavy for normal skill maintenance and easy to forget; it leaves a known blind spot after creating a skill.

## Comparison

```text
Need                                  A: sg-skill-build only   B: shared helper   C: install only
------------------------------------  ----------------------   ----------------   ---------------
New skill created                     yes                      yes                indirect
Existing skill symlink drift          no                       yes                indirect
sg-build/sg-browser current gap       no                       yes                yes, heavy
Can be reused by checks/ship/init      no                       yes                limited
Avoid duplicated shell snippets        no                       yes                yes
Operator ergonomics                   medium                   high               low
```

## Emerging Recommendation

Create a reusable helper, then have `sg-skill-build` call that helper for the current skill. `install.sh` can keep its install-time flow but should either reuse the helper or share the same behavior contract.

Suggested shape:

```text
tools/shipglows_sync_skills.sh

Modes:
- --user current
- --skill <name>
- --all
- --check
- --repair

Targets:
- ~/.codex/skills
- ~/.claude/skills
```

The helper should:

- resolve `$SHIPGLOWS_ROOT`
- list valid `skills/*/SKILL.md`
- create missing symlinks
- repair stale symlinks
- refuse to overwrite non-symlink targets
- verify `SKILL.md` is reachable through each runtime directory
- print a compact summary suitable for skills and install scripts

## Non-Decisions

- Whether to support every user under `/home/*` outside install-time eligible user selection.
- Whether the helper should be shell or Python.
- Whether missing runtime links should block `sg-ship` globally or only skill-maintenance ships.

## Rejected Paths

- Manual one-off `ln -s` as the long-term answer - it fixed `sg-skill-build` locally but does not prevent the same failure for `sg-build`, `sg-browser`, or future skills.
- Treating this as a Codex cache issue only - current filesystem checks show missing symlinks for `sg-build` and `sg-browser`.

## Risks And Unknowns

- Non-symlink collisions: a user may have a real directory under `~/.codex/skills/<name>` or `~/.claude/skills/<name>`; the helper must not overwrite it without explicit approval.
- Multi-user scope: `install.sh` currently targets eligible users; a runtime helper should default to current user unless invoked by install with explicit users.
- Session reload: even after symlinks are fixed, an already-running Codex session may need restart/reload before the skill list updates.
- Dirty worktree: current repo has unrelated `install.sh` edits around Flutter/Android policy; implementation should avoid mixing those changes into this symlink fix unless explicitly scoped.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: This report records paths and local skill names only.

## Decision Inputs For Spec

- User story seed: As a ShipGlows maintainer, I want a reusable skill runtime sync command so newly created or existing ShipGlows skills are visible in Claude and Codex without rerunning a full install.
- Scope in seed: current-user symlink check/repair, optional `--skill <name>`, optional `--all`, integration with `sg-skill-build`, validation output.
- Scope out seed: destructive replacement of non-symlink directories, broad multi-user mutation outside install-time explicit scope, Codex process reload automation.
- Invariants/constraints seed: ShipGlows source is `${SHIPGLOWS_ROOT:-$HOME/shipglows}/skills/<name>`; runtime targets are current-user `~/.codex/skills/<name>` and `~/.claude/skills/<name>`; never overwrite non-symlink targets silently.
- Validation seed: compare repo skills to runtime symlinks; verify `readlink -f`; verify `SKILL.md` reachable; run `bash -n` if shell; run metadata lint on docs/specs; update bug dossier and `sg-skill-build` contract.

## Handoff

- Recommended next command: `/sg-spec Shared ShipGlows skill runtime sync`
- Why this next step: the fix affects a shared runtime/infrastructure behavior used by multiple skills and install flows, so it deserves a small spec before implementation.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-05-03 04:25:00 UTC | Missing `sg-build` and reusable symlink management | Compared repo skill directories with current-user Claude/Codex runtime symlinks and reviewed existing install-time symlink functions. | Found `sg-browser` and `sg-build` missing from both runtime directories; recommended a shared runtime sync helper. | /sg-spec Shared ShipGlows skill runtime sync |
