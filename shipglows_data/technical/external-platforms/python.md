---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-python
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/shipglows_metadata_lint.py
  - tools/skill_budget_audit.py
  - tools/codebase-mcp/
  - skills/references/documentation-freshness-gate.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Python 3.14 docs, stdlib docs, venv docs, argparse docs, and Python Packaging User Guide."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Python Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Python-related freshness checks. Use it before relying on assumptions about Python runtime versions, virtual environments, packaging, CLI parsing, subprocess behavior, filesystem/path handling, JSON/YAML tooling, local scripts, or Python-based helper services.

It does not replace Python documentation. It records the source map and ShipGlows rules agents should use before changing Python tooling, dependency setup, project-local Python usage docs, or Python scripts that affect ShipGlows operations.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Python docs entrypoint | https://docs.python.org/3/ |
| Python standard library | https://docs.python.org/3/library/ |
| Python 3.14 docs contents | https://docs.python.org/3.14/contents.html |
| Virtual environments | https://docs.python.org/3.14/library/venv.html |
| `argparse` | https://docs.python.org/3/library/argparse.html |
| Packaging guide | https://packaging.python.org/guides/ |
| Externally managed environments | https://packaging.python.org/en/latest/specifications/externally-managed-environments.html |

Freshness evidence on 2026-05-24:

- Python docs list `argparse`, `pathlib`, `subprocess`, `logging`, `json`, `tempfile`, and `venv` as standard library modules relevant to ShipGlows tooling.
- Python `venv` docs describe virtual environments as isolated package environments with their own site directories.
- Python Packaging User Guide covers modern packaging, virtual environments, dependency specs, `pyproject.toml`, and packaging standards.
- Externally managed environment specs explain why system Python installations should guide users toward virtual environments instead of global package mutation.

## Freshness Gate Use

Use `fresh-docs checked` for Python decisions only after checking the relevant Python/PyPA docs and local project runtime evidence.

Use `fresh-docs gap` when:

- A script depends on a specific Python minor version but the local version, shebang, or CI runtime was not checked.
- A dependency or package-install path mutates system Python without explicit reason.
- A Python CLI changes argument parsing, subprocess execution, file writes, or YAML/JSON parsing without focused validation.
- A project uses non-trivial Python but lacks `shipglows_data/technical/platforms/python.md`.

Use `fresh-docs conflict` when current Python/PyPA docs contradict local docs, installer assumptions, or planned implementation.

## ShipGlows Decision Rules

- Prefer the standard library for small durable tooling when it is sufficient: `argparse`, `pathlib`, `json`, `subprocess`, `tempfile`, `logging`, `dataclasses`, and `typing`.
- Prefer structured parsers over ad hoc string parsing for YAML/JSON/TOML/frontmatter when available.
- Avoid mutating system Python in installers. Use apt packages for OS-level dependencies or project-local virtual environments for Python packages.
- Pin or document Python runtime expectations when scripts depend on version-specific behavior.
- Use `subprocess.run([...], check=True)` with argument lists for local commands unless shell semantics are explicitly required.
- Do not log secrets, raw env dumps, tokens, credentials, cookies, or private paths.
- For generated reports or docs, write deterministic output and validate metadata/schema after writes.

## Common Project-Local Fields

A project using Python should maintain `<governance-root>/shipglows_data/technical/platforms/python.md` when Python is part of its runtime/tooling contract, with:

- Python version policy and runtime source
- package manager or virtual environment strategy
- key scripts and entrypoints
- dependency files: `pyproject.toml`, `requirements.txt`, lockfiles, or Flox/system packages
- validation commands
- subprocess/file-write/security constraints
- CI/deploy runtime expectations

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store secrets, raw env vars, OAuth tokens, cookies, service account JSON, or API keys in Python docs, fixtures, logs, or exception reports.
- Treat subprocess calls, temp files, archive extraction, path joins, and shell invocations as injection and data-loss surfaces.
- Avoid `shell=True` unless a shell feature is required and all inputs are trusted or safely quoted.
- Validate paths before destructive writes or deletes.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/python.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/python.md
```

## Reader Checklist

- `*.py`, `pyproject.toml`, `requirements.txt`, Python shebang, `venv`, or Python package install changes found -> check for project-local Python usage note.
- Installer touches Python -> verify system-vs-venv boundary.
- Python script changes file IO/subprocess/parsing -> run syntax and focused behavior validation.
- Python dependency changes -> route to `010-sg-technical deps` or `010-sg-technical migrate` as appropriate.

## Maintenance Rule

Update this note when Python runtime support, packaging guidance, virtualenv behavior, stdlib APIs used by ShipGlows, or Python dependency/security posture changes.
