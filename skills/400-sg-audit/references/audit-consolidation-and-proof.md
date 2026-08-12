---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 400-sg-audit
scope: audit-consolidation-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/400-sg-audit/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from audit-master-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify audit consolidation"
---

# Audit Consolidation And Proof

Consolidate by project, domain, and severity, then merge duplicates into cross-domain root causes. Prioritize P1/P2 clusters, user-story incoherence, security/supply-chain risk, design-system bypass, documentation drift, and unsupported product claims.

Every material finding includes evidence, affected systems, consequence, severity, confidence, and owner route. Separate observed defects from risky assumptions and missing proof. A green build, static scan, or HTTP response proves only its stated surface; it does not prove auth, authorization, payments, webhooks, private data, or end-to-end product behavior.

Never expose secrets, tokens, cookies, credentials, private payloads, production PII, or unredacted sensitive logs. Internet-facing or privileged surfaces apply the shared OWASP awareness gate and route technical findings with the relevant Top 10:2025 categories.

The report accounts for every selected cell and states totals without double counting. Use findings-first user mode by default; detailed mode may include the project × domain matrix, evidence ledger, assumptions, confidence limits, and handoff notes. Do not award a tidy grade when evidence is partial.
