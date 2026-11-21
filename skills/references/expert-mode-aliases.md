---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-05"
updated: "2026-11-21"
status: active
source_skill: 000-shipglows
scope: codex-expert-mode-aliases
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/302-sg-help/SKILL.md
  - skills/302-sg-help/references/help-modes-expert-catalog.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
depends_on:
  - artifact: skills/references/skill-invocation-preflight.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-05: add short expert modes for Codex without changing the shell CLI."
  - "Operator decision 2026-08-05: shipglows capture and shipglows tmux resolve to sg-content capture."
  - "Operator decision 2026-08-16: shipglows git provides manual PR, branch, and worktree hygiene."
  - "Operator decision 2026-08-16: shipglows hygiene audits the current project without mutation; hygiene git selects the safe Git clean workflow."
next_review: "2026-09-05"
next_step: "/103-sg-verify expert mode aliases"
---

# Codex Expert Mode Aliases

These aliases are read only by the `shipglows` Codex router, never as shell commands; do not add them to `cli/shipglows.sh`. The canonical mapping lives in `skills/references/skill-invocation-registry.json`; this reference explains how to apply it.

Form: `shipglows <alias> <instruction>`.

The alias is resolved before natural-language routing and numeric skill lookup, following `public owner -> owner mode -> internal engine`. The rest of the instruction passes unchanged; workflow, proof, and stop rules stay with the public owner and internal engine.

| Alias | Public owner | Owner mode | Internal engine |
| --- | --- | --- | --- |
| `core` | `shipglows` | `core` | `900-shipglows-core` |
| `explore` | `sg-planning` | `explore` | `700-sg-explore` |
| `spec` | `sg-planning` | `spec` | `100-sg-spec` |
| `status` | `sg-planning` | `status` | `308-sg-status` |
| `resume` | `sg-planning` | `resume` | `303-sg-resume` |
| `build` | `sg-development` | `build` | `001-sg-build` |
| `fix` | `sg-bug` | `fix` | `106-sg-fix` |
| `verify` | `sg-engineering` by default; specialist when explicit | `verify` or specialist audit mode | `103-sg-verify` or specialist proof engine |
| `test` | `sg-engineering` | `test` | `107-sg-test` |
| `browser` | `sg-engineering` | `browser` | `108-sg-browser` |
| `git` | `sg-engineering` | `github` | `010-sg-technical` |
| `hygiene` | `sg-maintenance` (`sg-engineering` for explicit Git scope) | `hygiene` or `github clean` | `002-sg-maintain` or `010-sg-technical` |
| `tidy`, `ménage` | `sg-maintenance` | `tidy` | `002-sg-maintain` |
| `capture` | `sg-content` | `capture` | `800-tmux-capture-conversation` |
| `tmux` | `sg-content` | `capture` | `800-tmux-capture-conversation` |
| `ship` | `sg-release` | `ship` | `005-sg-ship` |
| `deploy` | `sg-release` | `deploy` | `004-sg-deploy` |
| `prod` | `sg-release` | `prod` | `405-sg-prod` |

`shipglows hygiene` is current-project-only and read-only: one grouped proposal across maintenance families; corrections need a new exact approval. `shipglows hygiene git` runs only the safe `shipglows git clean` skill workflow, never native `git clean`. Workspace or multi-project hygiene is rejected, not widened.

`shipglows tidy` (alias `ménage`) cleans the current project: workflow docs and specs, Git resting state and storage, and, inside ShipGlows, orphan skill docs. It returns one approval packet and deletes rather than archives; Git history is the archive.

`verify` keeps specialist ownership for explicit scopes: design, accessibility, UI, or animation (`sg-design`); SEO or search (`sg-seo`); release, deploy, preview, live, or production (`sg-release`); bug, regression, reproduction, or retest (`sg-bug`). Otherwise implementation-quality proof uses `sg-engineering verify`; generic `103-sg-verify` never replaces an applicable specialist audit.

Other aliases use their declared owner and mode. Natural-language requests still route by intent; an alias applies only as the first token after `shipglows`.

`core` is a hard context switch: every word after `shipglows core` concerns the ShipGlows system, never the current project. It may request a repair, audit, design, or other Core work; project names, quoted routes, and desired outcomes are evidence about ShipGlows, not targets. Exit `core` to invoke another mode or métier for project work.
