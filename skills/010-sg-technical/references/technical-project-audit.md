---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-09-01"
status: active
source_skill: 010-sg-technical
scope: technical-project-audit
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/010-sg-technical/SKILL.md, skills/references/dead-code-obsolescence-audit.md]
depends_on: []
supersedes: []
evidence: ["Project-mode phases extracted from audit playbook.", "Operator approval 2026-09-01: the dead/obsolete-code lane must cover the declared source scope rather than inherit the qualitative 10–15 file sample."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Technical Project Audit

Audit one project through one connected pass: scope/user story; workflow integrity and abuse; architecture/data flow/conventions; quick performance; security; reliability/observability/recovery; framework practices; dead/obsolete code; then report. Inspect representative entry points, config, manifests, CI and 10–15 consequential files for the qualitative review. That sample does not bound the dead/obsolete-code lane: apply `skills/references/dead-code-obsolescence-audit.md` across every declared source root and supported entrypoint class, using governed navigation context first when present, then a distinct application reachability graph and language-native analyzers. Report `partial` or `not proven` whenever that broader inventory or its dynamic/external-consumer challenge is incomplete.

Security covers authn/authz and tenant boundaries, input/schema validation, secrets/config, HTTP/cookies/CORS/CSRF, data protection, logging/replay/source maps, webhooks, uploads, quotas and abuse. For applicable scope, report the relevant OWASP Top 10:2025 categories, selected ASVS v5.0.0 requirements, evidence limits, and residual owner route. Reliability covers async failure, tests, health/diagnostics, deployment rollback and monitor/alert distinction. Deep dependency and performance work route to their own `010` modes. Do not mutate unless separately authorized.
