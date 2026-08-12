---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 203-sg-research
scope: research-report-template
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/203-sg-research/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-5 independent audit hardened durable report status semantics."
next_step: none
---

# Research Report Template

Use this template for durable research output.

---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "<project name or workspace>"
created: "<YYYY-MM-DD>"
updated: "<YYYY-MM-DD>"
status: <draft|reviewed>
source_skill: 203-sg-research
scope: "<topic>"
owner: "<operator>"
confidence: "<high|medium|low>"
risk_level: "<low|medium|high>"
security_impact: "<none|yes|unknown>"
docs_impact: "<none|yes|unknown>"
source_count: 0
linked_systems: []
depends_on: []
supersedes: []
evidence: []
next_step: "<recommended next action>"

# Research: <topic>

## Executive Summary

## Scope and Context

## Sources Used

## Comparison

## Recommendation

## Limits and Uncertainty

Use `draft` unless an independent review actually occurred; never stamp new research `reviewed` by default.
