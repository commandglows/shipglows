---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 400-sg-audit
scope: audit-records-remediation
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/400-sg-audit/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from audit-master-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify audit records"
---

# Audit Records And Remediation

Do not write operational records during read-only audit cells. After consolidation, load the shared operational-record format before touching `AUDIT_LOG.md` or `TASKS.md`; preserve project-root governance placement, stable finding identifiers, severity, evidence, owner, status, and timestamps. Avoid duplicate tasks for the same root cause.

Evaluate the chantier threshold. Major findings, P0/P1 items, cross-domain P2 clusters, breaking risk, or remediation needing a spec become a concrete `Chantier potentiel` route when no unique chantier owns them.

Fixing is a separate authorized phase. Offer or route bounded findings to the specialist owner, `106-sg-fix`, or `100-sg-spec` as risk requires. Never auto-fix, close, ship, rollback, rewrite trackers, or strengthen public claims from an audit-only request. Re-audit affected surfaces after repair and retain unresolved proof gaps.
