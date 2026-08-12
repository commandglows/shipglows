---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: core-audit-and-improvement
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - tools/audit_shipglows_skills.py
  - tools/skill_invocation_check.py
depends_on: []
supersedes: []
evidence:
  - "Wave 9 extracted core audit mechanics after activation and graph validation."
next_step: none
---

# Core Audit and Improvement

Resolve `$SHIPGLOWS_ROOT`, confirm `skills/` and the requested versioned tool, then run the smallest audit matching scope. For the baseline use `tools/audit_shipglows_skills.py`; for routing ownership also run `tools/skill_invocation_check.py --audit-graph`.

Treat hard findings as blocking, review findings as scenario-first triage, and style findings as non-actionable without a demonstrated failure. Generic audit output never proves an observed behavior fixed.

Translate a confirmed non-style issue into one pressure scenario, narrow cause, reusable prevention rule, implementation locus, and focused proof. Do not rewrite skills from read-only audit output without explicit edit authorization or a ready spec.
