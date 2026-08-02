---
artifact: brand_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows_data
created: "2026-04-26"
updated: "2026-04-26"
status: active
source_skill: sg-init
scope: documentation_brand
owner: shipglows
confidence: high
depends_on: []
evidence:
  - "README.md"
  - "CLAUDE.md"
  - "GUIDELINES.md"
  - "BUSINESS.md"
  - "TASKS.md"
  - "PROJECTS.md"
supersedes: []
risk_level: low
security_impact: low
docs_impact: high
brand_voice: "Direct, concise, evidence-first"
trust_posture: "Transparent and cautious with explicit uncertainty"
next_review: "2026-10-26"
next_step: "/sg-docs audit shipglows_data/BRANDING.md"
---

# Branding — shipglows_data

## Positioning
A practical operations system for managing multiple product lanes, designed for speed, continuity, and traceability.

## Voice
- **Direct**: give clear decisions, not noise.
- **Pragmatic**: prefer concrete next action over theory.
- **Disciplined**: document what changed and why.
- **Concise**: short paragraphs, explicit ownership, explicit status.

## Style
- Primary focus is clarity of workflow and evidence.
- Tone stays neutral and trustworthy, with occasional urgency when blockers are critical.
- Prefer actionable markdown lists, decision tables, and explicit checkboxes.

## Audience voice settings
- Internal operator working across many repos.
- AI assistants with short attention windows needing immediate orientation.
- External contributors reviewing progress or audits.

## Visual identity for docs
No fixed UI theme is assumed inside this repository. If a project-specific visual system is needed for generated outputs, default to:

- Strong section hierarchy (`##`, `###`) for scanability.
- `code` style for paths, commands, and variable names.
- Explicit "required", "optional", and "status" labels for every section that impacts execution.

## Values
- Operational continuity
- Evidence over assumptions
- Safety around secrets and credentials
- Transparency on unresolved risks
