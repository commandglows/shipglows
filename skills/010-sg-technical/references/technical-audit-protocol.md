---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-07"
status: active
source_skill: 010-sg-technical
scope: technical-audit-protocol
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/010-sg-technical/SKILL.md, skills/references/clean-code-quality-contract.md, skills/references/owasp-application-security-awareness.md]
depends_on: []
supersedes: []
evidence: ["Common doctrine, reporting and traffic-first tracking extracted from audit playbook.", "User decision 2026-08-07: technical code audits must apply the pragmatic Clean Code quality contract.", "User decision 2026-08-07: technical security audits use OWASP Top 10:2025 awareness and selected ASVS v5.0.0 controls."]
next_step: "/103-sg-verify compact monolithic skill references"
---

# Technical Audit Protocol

Start with actor, user outcome, observable success, linked systems, invariants, and trust boundaries. Reconstruct a user story only when absent and label it inferred. Treat bypass, replay, stale state, partial failure, unauthorized actors, abuse, and product incoherence as first-class findings.

Report Business metadata versions for business, brand and guideline contracts. Missing, stale, draft, low-confidence or unversioned material caps confidence; it cannot support an A for User Story Fit, Workflow Integrity, or Security.

Audit is read-only unless exact fix scope is authorized explicitly or an active lifecycle contract grants it. Findings otherwise contain evidence, impact, findings and the proposed remediation only, proof gaps and a `Chantier potentiel` decision. Before any tracker write, load operational-record format, re-read the target immediately before a minimal change, and stop if the anchor remains ambiguous. Preserve traffic-first records and redact secrets, credentials, cookies, private payloads, customer data and raw logs.

For authored code, apply `skills/references/clean-code-quality-contract.md` and report a proportional `Clean Code Gate`. Findings must identify concrete maintenance or correctness impact; preferences without evidence are not defects.

For applicable security scope, apply `skills/references/owasp-application-security-awareness.md` and report an `OWASP Security Gate`; map findings to relevant Top 10:2025 categories, selected ASVS v5.0.0 requirements, evidence, and residual owner route. Do not claim full OWASP coverage from static evidence or a scanner.
