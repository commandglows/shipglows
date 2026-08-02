---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-18"
status: draft
source_skill: 004-sg-deploy
scope: 004-sg-deploy-report-template
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/references/reporting-contract.md
  - skills/references/chantier-tracking.md
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.10.0"
    required_status: active
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.8.0"
    required_status: draft
supersedes: []
evidence:
  - "Extracted from skills/004-sg-deploy/SKILL.md to keep long report templates outside the activation body."
  - "Operator correction 2026-07-18: detailed lifecycle evidence remains agent-only; unfinished or blocked user reports expose safe outcome choices instead."
next_review: "2026-07-13"
next_step: "/103-sg-verify 004-sg-deploy report template"
---

# Deploy Report Template

## Purpose

Provide the detailed `004-sg-deploy` report shape for `report=agent` or explicit handoff. Default and blocked user reports stay concise and follow `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

## Template

```text
## Deploy: [project or scope]

Result: [deployed / partial / blocked / rerouted]
Environment: [local / preview / production / unknown]
Development mode: [local / vercel-preview-push / hybrid / unknown]

Phases:
- Scope and risk gate -> [status]
- 105-sg-check -> [pass/fail/skipped/not needed]
- 005-sg-ship -> [shipped/blocked/not run]
- 405-sg-prod -> [ready/failed/pending/partial/not run]
- Evidence routing -> [108-sg-browser/109-sg-auth-debug/107-sg-test/not needed/missing]
- 103-sg-verify -> [verified/partial/failed/not run]
- 304-sg-changelog -> [updated/skipped/not run]

Evidence:
- Commit: [sha or none]
- Deployment URL: [url or none]
- Browser/manual proof: [summary or missing]
- Logs: [summary or not collected]
- Sentry: [issue/event summary | no direct dashboard access; PM2/Doppler checked | no pointer supplied | not applicable]

Risks or gaps:
- [item or none]

Next step:
- [command or none]

## Chantier

Skill courante: 004-sg-deploy
Chantier: [spec path | non applicable | non trace]
Trace spec: [ecrite | non ecrite | non applicable]
Flux:
- 100-sg-spec: [status]
- 101-sg-ready: [status]
- 102-sg-start: [status]
- 103-sg-verify: [status]
- 104-sg-end: [status]
- 005-sg-ship: [status]

Reste a faire:
- [item or None]

Prochaine etape:
- [command or none]

Place the shared chantier header immediately before `🎯 VERDICT (HH:mm) : [deployed | partial | blocked | rerouted]`; do not append a verdict after this body.
```

## User Report Compression

For `report=user`, compress the same content to:

- opening chantier and timestamped verdict headers
- outcome
- environment and URL
- evidence collected
- gaps or risks
- two or three plain-language recovery or continuation choices when the chantier remains open

Do not include the full phase matrix, internal owners, skills, commands, spec paths, or lifecycle state in user mode. Keep blocked and partial user reports actionable through safe outcome choices; use `report=agent` for handoff detail.
