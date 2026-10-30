---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-30"
updated: "2026-10-30"
status: draft
source_skill: sg-docs
scope: bootstrap-matrix
owner: Diane
confidence: medium
risk_level: medium
security_impact: no
docs_impact: yes
---

# Bootstrap matrix by environment

## Rule

`install-shipglows.sh` (Unix, Termux) detects the platform first, then picks a mode, then refuses anything unsupported with the next command to run. It never guesses a platform or elevates privileges silently.

- **Modes**: `local` (no root, user tools and tunnels) and `full` (root, Debian/Ubuntu server: system packages and services).
- **Platforms**: `termux`, `macos`, `wsl`, `linux`, `windows-gitbash` (refused), `unsupported` (refused).
- **Windows native** is handled by `install-shipglows.ps1` (PowerShell), not by the shell bootstrap.
- **Python 3.9+** is never installed by a CLI entry point. Policy: [python-runtime-provisioning.md](python-runtime-provisioning.md).

## Matrix

| Environment | Detected as | Default mode | Root | Python 3.9+ provided by | Status |
|---|---|---|---|---|---|
| Debian/Ubuntu server, root or sudo | `linux`, debian family | `full` (root) | `sudo` required | `apt` (`python3`, `python3-yaml`) via `cli/install.sh` | Supported |
| Debian/Ubuntu server, non-root account | `linux`, debian family | `local` (prompt) | none | Admin installs it once | Supported (local) |
| Linux non-root, other distribution | `linux` | `local` (prompt) | none | Distribution package manager, or `uv python install 3.12` | Supported (local) |
| Linux, other distribution, root | `linux` | refused for `full` | not used | n/a | Use `local` without sudo |
| macOS | `macos` | `local` (forced) | none | `brew install python@3.12`, or `uv python install 3.12` | Supported (local) |
| WSL with Debian/Ubuntu | `wsl`, debian family | `full` if root, else `local` | as for Linux | As for Linux | Supported |
| Termux (Android) | `termux` | `local` (forced) | none | `pkg install python` | Supported (local) |
| Windows native (PowerShell) | `install-shipglows.ps1` | native installer | none for the user scope | `winget install -e --id Python.Python.3.12` | Supported by the PowerShell bootstrap |
| Windows Git Bash, MSYS, Cygwin | `windows-gitbash` | refused | n/a | n/a | Use `install-shipglows.ps1` or WSL |
| Other OS (BSD, unknown) | `unsupported` | refused | n/a | n/a | Not supported |

## Refusal messages

Each refusal prints the reason and the next command. The shell bootstrap never falls through to a secondary `command not found` or apt error.

- Git Bash/MSYS/Cygwin: names `install-shipglows.ps1` and WSL.
- Unsupported OS: lists supported platforms.
- `full` on macOS: suggests `SHIPGLOWS_INSTALL_MODE=local` without sudo.
- `full` on a non-Debian distribution: suggests `local` without sudo.
- `full` without root: suggests the `sudo env SHIPGLOWS_INSTALL_MODE=full sh` form (unchanged).

## Root policy

- Root is needed only for `full` (apt, `/usr/local`, Caddy, Flox, `/etc`). No path elevates silently.
- `local` never needs root. Python is the only prerequisite that may be missing. `local/install.sh` checks it before the Codex plugin step and stops with the diagnostic from `cli/python-runtime.sh`.

## Implementation

- Platform detection and refusals: `install-shipglows.sh` (`detect_platform`, `check_platform_support`, `resolve_install_mode`).
- Platform detection after the clone: `local/install.sh` (existing branches, same families).
- Python guard and install hints per platform: `cli/python-runtime.sh`.
- Read-only prerequisite check: `./cli/doctor.sh` (run from the clone). It sources `install-shipglows.sh` with `SHIPGLOWS_BOOTSTRAP_LIBRARY=1` to reuse the platform detection and refusals, and `cli/python-runtime.sh` for Python. It installs nothing: for each missing `git`, `curl`, `bash` or Python 3.9+, it prints the command for the detected platform (`pkg`, `xcode-select`/`brew`, `apt-get`, or the distribution's package manager). Exit 0 when the `local` prerequisites are present, 1 otherwise or when the platform is refused (Git Bash, unknown OS).

## Out of scope (tracked in TASKS)

- Aligning `README.md`, `AGENT.md`, `CONTEXT.md` and `GUIDELINES.md` on this contract.
- Verification of the refusal paths on real hosts (no run was done for this document).
