---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 108-sg-browser
scope: browser-report-and-routing
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/108-sg-browser/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 7 extracted evidence interpretation, reporting, and routing."
next_step: none
---

# Browser Report and Routing

## Verdicts

- `pass`: objective observed with no material blocker.
- `fail`: objective not observed and evidence points to app behavior.
- `partial`: visible result plus material console/network/environment/evidence risk.
- `blocked`: runtime, target, timeout, environment, or tool prevents valid proof.
- `needs-auth`, `needs-deploy`, `needs-manual-test`, `unsafe-action`: owner/safety boundary selected before overreach.

## Routing

Route auth to `109-sg-auth-debug`, deploy discovery to `405-sg-prod`, unshipped preview work through bounded `005-sg-ship` then deploy proof, durable QA to `107-sg-test`, narrow repair to `106-sg-fix`, material contract change to `100-sg-spec`, and lifecycle evidence gaps to `103-sg-verify`.

## Report

State target category/environment, objective, observed fact, sanitized evidence, material limits, and next outcome. User mode hides private URLs and internal machinery. Agent mode may include sanitized URLs/runtime/evidence inventory. Never paste raw payloads, headers, storage, HAR, secrets, or PII.
