---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-gum
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/shipglows_devserver_gum.sh
  - shipglows_data/technical/terminal-tui.md
  - skills/references/documentation-freshness-gate.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/external-platforms/bash.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Charmbracelet Gum README, commands list, install docs, and GitHub releases."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Gum Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Gum-related freshness checks. Use it before relying on assumptions about Gum menu behavior, command output, exit codes, styling, spinners, tables, prompts, install methods, or Bash TUI scripts.

It does not replace Gum documentation. It records the source map and ShipGlows rules agents should use before changing `cli/shipglows_devserver_gum.sh`, installer Gum setup, or project-local Gum usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Gum README and command docs | https://github.com/charmbracelet/gum |
| Gum releases | https://github.com/charmbracelet/gum/releases |
| Charmbracelet organization | https://github.com/charmbracelet |
| Homebrew formula signal | https://formulae.brew.sh/formula/gum |

Freshness evidence on 2026-05-24:

- Gum describes itself as a tool for shell scripts that provides ready-to-use utilities without writing Go code.
- Gum command list includes `choose`, `confirm`, `file`, `filter`, `format`, `input`, `join`, `pager`, `spin`, `style`, `table`, `write`, and `log`.
- Gum commands generally print selected/input values to stdout for capture by shell variables or files.
- `gum confirm` exits with `0` for affirmative and `1` for negative, making exit-code handling part of script control flow.
- Gum install docs include package managers, Charm apt/yum repositories, binary packages, and `go install`.
- Gum `spin` can hide or show command output depending on flags, which matters for diagnostics.

## Freshness Gate Use

Use `fresh-docs checked` for Gum decisions only after checking the Gum README/releases or proving behavior with a focused terminal smoke test.

Use `fresh-docs gap` when:

- A script depends on Gum stdout, exit status, hidden output, style rendering, selection limits, or non-interactive behavior and no proof was run.
- Installer behavior changes Gum install/update path without checking current official installation guidance.
- TUI script changes do not preserve a non-Gum fallback or clear blocked state.
- A project uses Gum materially but lacks `shipglows_data/technical/platforms/gum.md`.

Use `fresh-docs conflict` when current Gum docs contradict local menu assumptions or planned implementation.

## ShipGlows Decision Rules

- Gum is UI glue, not business logic. Keep state changes and destructive operations outside Gum prompts until user choice is validated.
- Always capture and check Gum command output/exit status deliberately. A canceled prompt must not fall through to a destructive default.
- Keep a Bash/plain fallback for environments where Gum is unavailable unless the project explicitly requires Gum.
- Do not hide important failure output behind spinners; use `--show-output` or equivalent where diagnostics matter.
- Stable script behavior must not depend on color/style rendering.
- Use Gum for ergonomic TUI choices, confirmations, inputs, filters, tables, and pagers; use structured code for complex validation.

## Common Project-Local Fields

A project using Gum should maintain `<governance-root>/shipglows_data/technical/platforms/gum.md` when Gum is a material UI dependency, with:

- Gum install source and version policy
- scripts using Gum
- fallback behavior when Gum is missing
- prompt/cancel handling rules
- commands used and expected stdout/exit behavior
- validation smoke scenarios

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never allow a canceled Gum prompt to default to a destructive or privileged action.
- Do not display secrets, tokens, private URLs, or raw logs in Gum tables, pagers, or prompts.
- Treat user-selected paths/hosts/projects as untrusted until validated by Bash/Python logic.
- Keep terminal output readable for audit; do not over-style critical warnings or errors.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/gum.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/gum.md
```

For menu changes:

```bash
bash -n cli/shipglows_devserver_gum.sh
```

## Reader Checklist

- `gum`, `cli/shipglows_devserver_gum.sh`, `gum choose`, `gum confirm`, `gum spin`, `gum table`, or installer Gum setup changed -> check Gum note.
- Prompt/cancel behavior changed -> test cancellation and empty selection.
- Spinner wraps a command -> ensure failure output remains diagnosable.
- Gum missing in environment -> verify fallback or blocked report.

## Maintenance Rule

Update this note when Gum command behavior, install guidance, release behavior, ShipGlows TUI fallback policy, or menu validation rules change.
