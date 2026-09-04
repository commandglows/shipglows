---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-27"
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
  - "2026-08-27 DX ownership split keeps this audit pack specific to skills and doctrine while runtime and system scopes load direct packs."
next_step: none
---

# Core Skill and Doctrine Audit

Use only for a skill, shared-doctrine, activation, or skill-tooling audit. Runtime scope belongs to `dx-runtime-maintenance.md`; bare system or multi-surface scope belongs to `system-coherence.md`. Resolve `$SHIPGLOWS_ROOT`, confirm `skills/` and the requested versioned tool, then run the smallest audit matching scope. For the baseline use `tools/audit_shipglows_skills.py`; for routing ownership also run `tools/skill_invocation_check.py --audit-graph`.

Treat hard findings as blocking, review findings as scenario-first triage, and style findings as non-actionable without a demonstrated failure. Generic audit output never proves an observed behavior fixed.

Translate a confirmed non-style issue into one pressure scenario, narrow cause, reusable prevention rule, implementation locus, and focused proof. Do not rewrite skills from read-only audit output without explicit edit authorization or a ready spec.

For reference, trigger, shared-doctrine or protection changes, load
`skill-context-budget.md` and apply its Loading Change Gate even when files shrink.
Audit actual mandatory read edges against the scenario ledger; a smaller file or
passing generic audit never proves that context cost or protections are preserved.
