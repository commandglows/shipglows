---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-10-20"
status: active
source_skill: 700-sg-explore
scope: durable-exploration-report
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/700-sg-explore/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-5 independent audit confirmed the durable-report boundary and redaction gate."
  - "2026-10-20: restored reuse-before-create, web-source citation, and non-silent write-failure rules lost in the Wave-5 compaction."
next_step: none
---

# Durable Exploration Report

Use this reference only when persistence is required.

## Mandatory path

Save to: `shipglows_data/workflow/explorations/YYYY-MM-DD-slug.md`

If this skill is used outside ShipGlows, use the local equivalent path only when project governance allows.

## Reuse before create (mandatory)

Before writing anything, search the explorations folder (and linked specs) for a report on the same topic.

- One match: update it in place (bump `updated` and `artifact_version`, append a run-history line) instead of creating a new file.
- Several plausible matches: ask the operator which one to continue.
- No match: only then create a new report.

Creating a duplicate without checking first is a serious error.

## Report fields

Include at least:

- topic and trigger,
- methods used,
- options compared,
- evidence list; for every web source used: URL, title, access date (YYYY-MM-DD), and its role in the reasoning,
- identified risks and unknowns,
- recommended next owner (`100-sg-spec`, `011-sg-pilotage`, `102-sg-start`, or another explicit owner),
- explicit statement that no implementation proof is included.

## Redaction rule

Never persist secrets, credentials, private user content, private tokens, or raw sensitive logs.

## Write failure

Never fail silently. If the report cannot be written (read-only project, missing folder, redaction impossible), say so in the final response with the reason and include the report content (sanitized) so the operator can recover it, or give a concrete next step.

## Minimal template

```markdown
---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "<project name>"
created: "<YYYY-MM-DD>"
updated: "<YYYY-MM-DD>"
status: "<draft|reviewed>"
source_skill: 700-sg-explore
scope: "<exploration scope>"
owner: "<operator>"
confidence: "<high|medium|low>"
risk_level: "<low|medium|high>"
security_impact: "<none|yes|unknown>"
docs_impact: "<none|yes|unknown>"
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - "<source or file path>"
  - "<source or file path>"
next_step: "<recommended next command or owner>"
---

# Exploration Report: <short title>

## Context
...

## Alternatives
...

## Evidence
- <file path> - <why it mattered>
- [<source title>](<url>) - Accessed <YYYY-MM-DD> - <role in reasoning>

## Risks and Unknowns
...

## Recommendation
...
```

Use `draft` unless an independent review actually occurred.
