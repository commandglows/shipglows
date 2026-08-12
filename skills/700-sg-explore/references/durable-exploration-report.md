# Durable Exploration Report

Use this reference only when persistence is required.

## Mandatory path

Save to: `shipglows_data/workflow/explorations/YYYY-MM-DD-slug.md`

If this skill is used outside ShipGlows, use the local equivalent path only when project governance allows.

## Report fields

Include at least:

- topic and trigger,
- methods used,
- options compared,
- evidence list,
- identified risks and unknowns,
- recommended next owner (`100-sg-spec`, `011-sg-pilotage`, `102-sg-start`, or another explicit owner),
- explicit statement that no implementation proof is included.

## Redaction rule

Never persist secrets, credentials, private user content, private tokens, or raw sensitive logs.

## Minimal template

```markdown
---
artifact: exploration_report
project: "<project name>"
created: "<YYYY-MM-DD>"
updated: "<YYYY-MM-DD>"
status: reviewed
source_skill: 700-sg-explore
scope: "<exploration scope>"
owner: "<operator>"
confidence: [high|medium|low]
risk_level: [low|medium|high]
security_impact: [none|yes|unknown]
docs_impact: [none|yes|unknown]
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
...

## Risks and Unknowns
...

## Recommendation
...
```
