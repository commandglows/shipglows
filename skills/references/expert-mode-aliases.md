---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-05"
updated: "2026-08-05"
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
next_review: "2026-09-05"
next_step: "/103-sg-verify expert mode aliases"
---

# Codex Expert Mode Aliases

These aliases are interpreted by the `shipglows` Codex router only. They are
not shell commands and must not be added to `cli/shipglows.sh`. The canonical
mapping lives in `skills/references/skill-invocation-registry.json`; this
reference explains how to apply it.

Use the form:

```text
shipglows <alias> <instruction>
```

The alias is resolved before natural-language routing and before numeric skill
lookup. Resolution follows `public owner -> owner mode -> internal engine`.
The remainder of the instruction is passed unchanged. An alias owns no
workflow rules, proof rules, or stop conditions: those remain with its public
owner and selected internal engine.

| Alias | Public owner | Owner mode | Internal engine |
| --- | --- | --- | --- |
| `core` | `shipglows` | `core` | `900-shipglows-core` |
| `explore` | `sg-planning` | `explore` | `700-sg-explore` |
| `spec` | `sg-planning` | `spec` | `100-sg-spec` |
| `status` | `sg-planning` | `status` | `308-sg-status` |
| `resume` | `sg-planning` | `resume` | `303-sg-resume` |
| `build` | `sg-development` | `build` | `001-sg-build` |
| `fix` | `sg-bug` | `fix` | `106-sg-fix` |
| `verify` | `sg-engineering` by default; specialist owner when explicit | `verify` or specialist audit mode | `103-sg-verify` or specialist proof engine |
| `test` | `sg-engineering` | `test` | `107-sg-test` |
| `browser` | `sg-engineering` | `browser` | `108-sg-browser` |
| `capture` | `sg-content` | `capture` | `800-tmux-capture-conversation` |
| `tmux` | `sg-content` | `capture` | `800-tmux-capture-conversation` |
| `ship` | `sg-release` | `ship` | `005-sg-ship` |
| `deploy` | `sg-release` | `deploy` | `004-sg-deploy` |
| `prod` | `sg-release` | `prod` | `405-sg-prod` |

`verify` preserves specialist ownership when its scope is explicit: design,
accessibility, UI, or animation routes to `sg-design`; SEO or search routes to
`sg-seo`; release, deploy, preview, live, or production routes to `sg-release`;
a bug, regression, reproduction, or retest routes to `sg-bug`; otherwise
implementation-quality proof uses `sg-engineering verify`. The shortcut never
lets generic `103-sg-verify` replace an applicable specialist audit.

The other aliases select the owner and mode declared above. A normal
natural-language request remains free to route by intent; an alias is selected
only when it is the first token after `shipglows`.

`core` is a hard context switch: every word after `shipglows core` concerns the
ShipGlows system. It may request a repair, audit, design, documentation, or
other Core work, but it never targets the current project. Project names,
quoted routes, and desired project outcomes are evidence about the ShipGlows
behavior being discussed. Exit `core` and invoke another mode or métier for
actual project work.
