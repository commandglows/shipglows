---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 010-sg-technical
scope: technical-file-audit
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/010-sg-technical/SKILL.md]
depends_on: []
supersedes: []
evidence: ["File-mode checklist extracted from audit playbook."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Technical File Audit

Read the file, direct imports/dependents, types, nearby equivalent patterns and product context. Score user-story fit, workflow integrity and abuse resistance, architecture/reuse, type safety, error handling, performance, security, modern practices and reliability.

At boundaries check authentication and per-resource authorization, validation, XSS/injection/open redirects/IDOR, secrets, sensitive telemetry, external/webhook/upload trust, rate limits and idempotency. Check loading/error/denied/retry states and whether UI is wrongly treated as enforcement. Report file:line evidence, user impact, confidence and proposed remediation. This route is read-only: only apply an exact authorized fix; otherwise do not change project code.
