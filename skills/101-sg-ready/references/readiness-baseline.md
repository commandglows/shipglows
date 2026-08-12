---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 101-sg-ready
scope: readiness-baseline
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/101-sg-ready/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 6 extracted the always-run readiness baseline."
next_step: none
---

# Readiness Baseline

## Structure and metadata

Require governed spec metadata and the canonical behavioral, scope, task, proof, risk, consequence, documentation, execution, history, and flow sections. Critical placeholders, `TBD`, unresolved open questions, stale required dependencies, or a pre-existing unsupported `ready` status fail.

## User-story fit

A fresh reader must identify actor, trigger, value, observable success, observable failure, primary edge case, explicit non-goals, and how proof demonstrates the promise. Minimal behavior, tasks, acceptance criteria, and proof must trace to the same outcome.

## Execution quality

Tasks name target, action, order/dependency, user-story link, and exact validation. `Links & Consequences` covers consumers and cross-validation. `Documentation Coherence` names updates or a justified `None`. `Execution Notes` names first-read files, approach, constraints, commands, stops, and reroutes.

## Proof contract

Require surface/profile, automated checks, browser/auth/integration/provider/manual order, checklist/required scenarios where applicable, observable success/error evidence, and explicit exceptions. Non-trivial work uses proportional ZOMBIES coverage; coverage matters more than scenario count.

Any material ambiguity yields `not ready`.
