---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "2.32.0"
project: ShipGlows
created: "2026-10-26"
updated: "2026-10-26"
status: reviewed
source_skill: sg-docs
scope: python-runtime-provisioning
owner: Diane
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
---

# Python runtime provisioning

## Rule

ShipGlows requires **Python 3.9+** as `python3` for its CLI tools (`shipglows-fetch`, `shipglows-search`, `shipglows-scraping`, `shipglows-readwise`, and the `skills`, `env`, `private-data`, `project` control planes).

1. **Who installs it**
   - Debian/Ubuntu server: `sudo ./cli/install.sh` installs `python3` and `python3-yaml` through apt. This is the only path that provisions Python system-wide.
   - Workstations (macOS, Linux without root, Windows): the user installs Python 3.9+ once with the platform package manager. ShipGlows never installs it silently from a CLI entry point.
2. **How it is installed**: `brew install python@3.12` (macOS), `winget install -e --id Python.Python.3.12` (Windows), `sudo apt-get install -y python3` (Debian/Ubuntu). On Windows, disable the `python3` App Execution Alias if it shadows the install.
3. **Systems**: Linux (Debian/Ubuntu first), macOS, Windows via Git Bash or WSL.
4. **If it is missing or too old**: the entry point stops before running anything, exits with code 2, and prints the command name, the detected state (absent or version), the install command for the platform, and this policy path. It never falls through to a secondary `command not found` or import error.

## Implementation

- Guard: `cli/python-runtime.sh` (`shipglows_python3_ready`, `shipglows_python3_diagnose`). It detects and explains only.
- Callers: the CLI wrappers and the control-plane branches of `cli/shipglows.sh`.
- `project` keeps its JSON contract: the diagnostic goes to stderr, then `{"status":"unavailable","code":"pythonUnavailable"}`.

## Out of scope (tracked separately)

- A non-root local install path for docs and metadata tools (TASKS: 🟠 "chemin d'installation local sans root").
- `cli/lib.sh` JSON and pip fallbacks: they already degrade through `jq` and do not need the guard.
- Documenting the full bootstrap matrix per environment (TASKS: 🟠).
