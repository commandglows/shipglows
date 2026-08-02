---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-bash
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows.sh
  - lib.sh
  - install.sh
  - local/
  - cli/shipglows_devserver_gum.sh
  - skills/references/documentation-freshness-gate.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against the GNU Bash manual and Bash Reference Manual."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Bash Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Bash-related freshness checks. Use it before relying on assumptions about shell error handling, traps, pipelines, quoting, functions, arrays, getopts, subshells, command substitution, installer behavior, or TUI shell scripts.

It does not replace the Bash manual. It records the source map and ShipGlows rules agents should use before changing Bash scripts, installers, local tunnel scripts, Gum menus, or project-local Bash usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| GNU Bash manual index | https://www.gnu.org/software/bash/manual/ |
| Bash Reference Manual HTML | https://www.gnu.org/s/bash/manual/bash.html |
| Bash 5.2 reference/manual note | https://www.gnu.org/software/bash/manual/bash.html |

Freshness evidence on 2026-05-24:

- GNU Bash manual pages remain the primary source for shell behavior, builtins, shell options, traps, expansions, and command execution.
- Bash manual text documents important `errexit` exceptions: commands inside `while`/`until`, `if` tests, most `&&`/`||` lists, non-final pipeline commands unless `pipefail` applies, and inverted `!` contexts behave differently from simple command failures.
- Bash manual text documents `pipefail`, `ERR` trap inheritance via `errtrace`, and shell-function/subshell nuances that matter for installer reliability.

## Freshness Gate Use

Use `fresh-docs checked` for Bash decisions only after checking Bash behavior in the manual or proving behavior with a focused shell smoke test.

Use `fresh-docs gap` when:

- Error handling depends on `set -e`, `ERR`, `trap`, command substitution, subshells, or pipelines and no focused proof was run.
- Installer or destructive script behavior changes without checking quoting, path validation, and failure modes.
- TUI/menu logic changes without verifying non-interactive fallback behavior.
- A project relies heavily on Bash but lacks `shipglows_data/technical/platforms/bash.md`.

Use `fresh-docs conflict` when Bash manual behavior contradicts local assumptions or planned implementation.

## ShipGlows Decision Rules

- Bash is appropriate for ShipGlows OS orchestration, installers, local tunnels, process lifecycle, and thin CLI/TUI glue.
- Do not treat `set -e` as comprehensive error handling. Check critical command status explicitly when failure must stop or branch.
- Use `set -o pipefail` for pipelines whose upstream failures matter, but still test commands where SIGPIPE or expected non-zero exits are normal.
- Quote variable expansions by default. Use arrays for commands and argument lists where possible.
- Validate paths and host/user inputs before destructive operations, network actions, SSH commands, or writes outside the repo.
- Use `printf` rather than `echo` when output portability or escapes matter.
- Keep installer scripts fail-closed: downloads, keyrings, package installs, and privileged operations must check success before proceeding.
- For complex parsing, prefer a more structured tool or a small Python helper when Bash becomes fragile.

## Common Project-Local Fields

A project using Bash as a real runtime/tooling surface should maintain `<governance-root>/shipglows_data/technical/platforms/bash.md` with:

- Bash version or OS support policy
- script entrypoints and destructive commands
- shell options and error-handling conventions
- dependency commands used by scripts
- TUI/non-interactive behavior
- validation commands
- privilege boundaries and rollback/cleanup policy

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never pass unvalidated user input to `eval`, shell-generated command strings, SSH commands, package manager commands, or destructive filesystem operations.
- Avoid `eval`; require explicit rationale if used.
- Treat `curl | bash`, remote script execution, keyring setup, package repositories, and `sudo` as high-risk.
- Redact secrets from command traces and logs. Avoid `set -x` around secret material.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/bash.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/bash.md
```

For changed shell files:

```bash
bash -n <changed-shell-file>
```

## Reader Checklist

- `*.sh`, Bash shebang, installer, local tunnel, PM2/Flox/Caddy/DuckDNS, or Gum menu changed -> check Bash assumptions.
- Error handling changed -> test the exact failing-path scenario, not only `bash -n`.
- Destructive or privileged command changed -> verify input validation and fail-closed behavior.
- Shell logic grows complex -> consider Python or a structured helper.

## Maintenance Rule

Update this note when Bash version support, shell error-handling doctrine, installer safety doctrine, command-parsing patterns, or ShipGlows shell validation rules change.
