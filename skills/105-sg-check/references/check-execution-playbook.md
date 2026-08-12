---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 105-sg-check
scope: check-execution
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: no
linked_systems:
  - skills/105-sg-check/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted stack-specific check execution from the activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Check Execution Playbook

Load this reference only after the target project and check scope are known.

## Detect the target

Inspect project instructions, lockfiles, manifests, source roots, and declared scripts. Match the existing package manager. If no project marker exists but several project directories do, ask for the target rather than guessing. Shared `TASKS.md`, `AUDIT_LOG.md`, and legacy `PROJECTS.md` are read-only here.

## Select and run checks

Run dependent checks sequentially so the first meaningful failure remains clear.

- TypeScript/JavaScript: declared typecheck, lint, test, and build scripts through npm, pnpm, or yarn according to the lockfile.
- Astro: the declared Astro check and build commands.
- Python: compile changed modules or collect tests first, then run the relevant pytest scope with early failure.
- Bash: `bash -n` on relevant scripts, then existing focused test scripts.

Prefer the project's documented commands over generic defaults. Missing commands are coverage gaps, not silent passes. Do not run a framework-heavy full sequence when a scoped syntax, type, lint, or test check is sufficient.

## ShipGlows runtime visibility

When skills were added, renamed, edited, or reported stale, run the canonical sync helper in check mode for the affected skill or catalog. Report missing, stale, or non-link entries. Repair only in authorized `fix` mode and only when the task owns runtime visibility.

## Quick dependency scan

When selected, use the installed package manager's audit and outdated commands. Report high/critical vulnerabilities and summarize outdated packages. For Python, use `pip-audit` only if already available and inspect outdated packages without installing tooling.

Treat unavailable registries, missing audit tools, auth requirements, and partial output as incomplete proof. Never auto-update dependencies. Route comprehensive analysis to `/010-sg-technical deps <project>`.
