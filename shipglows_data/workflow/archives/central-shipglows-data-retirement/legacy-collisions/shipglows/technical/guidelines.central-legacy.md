---
artifact: operating_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows_data
created: "2026-04-26"
updated: "2026-04-26"
status: active
source_skill: sg-init
scope: docs_operations
owner: shipglows
confidence: medium
depends_on:
  - CLAUDE.md
  - BUSINESS.md
  - BRANDING.md
evidence:
  - README.md
  - CLAUDE.md
  - BUSINESS.md
  - BRANDING.md
  - TASKS.md
supersedes: []
risk_level: medium
security_impact: medium
docs_impact: high
next_review: "2026-10-26"
next_step: "/sg-docs audit shipglows_data/GUIDELINES.md"
---

# GUIDELINES — shipglows_data

## Scope
These rules apply to `/home/claude/shipglows_data` and to any agent action that edits this workspace.

## Repository rules
- Use existing tracker files as operational truth and avoid duplicating the same decision across files.
- Keep `TASKS.md`, `PROJECTS.md`, and `AUDIT_LOG.md` as operational artifacts.
- Move durable decisions to long-lived documents (`BUSINESS.md`, `BRANDING.md`, `GUIDELINES.md`, or project-level artifacts) when stable.
- Avoid placeholder drift: if a file section is renamed or removed in a project, update `PROJECTS.md` and related references.

## Documentation standards
- Frontmatter should include `artifact`, `artifact_version`, `project`, and update metadata for newly created artifact files.
- Use explicit status markers: `todo`, `done`, `in progress`, `blocked`, `deferred`.
- Use absolute paths in links when referencing files from this workspace (`/home/claude/shipglows_data/...`).
- Preserve French-language conventions in French-first projects when applicable (project scope should dictate language).

## Environment conventions
- Never write secrets in plaintext into tracked docs.
- Use `your_<service>_api_key_here` style placeholders.
- Store values in `.env` locally; keep `.env.example` as reusable, non-secret template.
- The workspace expects at least these core keys in `.env`:
  - `SHIPGLOWS_PROJECTS_DIR`
  - `SHIPGLOWS_DATA_DIR`
  - `SHIPGLOWS_LOG_DIR`
  - `SHIPGLOWS_LOG_FILE`
  - `SHIPGLOWS_CADDYFILE`
  - `SHIPGLOWS_SECRETS_DIR`
  - `SHIPGLOWS_SESSION_DIR`

## Security and operational safety
- Remove concrete credentials from any pasted logs or copied files.
- For OAuth/JWT/secret keys, use clearly masked placeholders with no real token fragments.
- If adding new integrations, extend `.env.example` first, then document required setup in this file.

## Quality expectations for changes
- Update `README.md` whenever new core files are added.
- Update `CLAUDE.md` when workflows, stacks, or required environment keys change.
- Link any newly important process to the relevant task in `/home/claude/shipglows_data/TASKS.md`.
