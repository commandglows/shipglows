---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 002-sg-maintain
scope: maintenance-playbooks
owner: ShipGlows
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/002-sg-maintain/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/master-delegation-semantics.md
depends_on:
  - artifact: skills/references/master-workflow-lifecycle.md
    artifact_version: "1.8.0"
    required_status: active
  - artifact: skills/references/master-delegation-semantics.md
    artifact_version: "1.8.0"
    required_status: active
supersedes: []
evidence:
  - "2026-08-12: extracted 002-sg-maintain lane detail so its activation contract stays below the progressive-disclosure risk threshold."
next_review: "2026-11-12"
next_step: "/103-sg-verify maintenance-playbooks"
---

# Maintenance Playbooks

## Context Discovery

Before triage, inspect only evidence relevant to the selected lanes: current project and git state; documented development mode and package scripts; bug files then the optional bug index; recent tests; local tasks and audit log; active specs; and the applicable docs/governance surfaces (`AGENTS.md`/`CLAUDE.md`, technical/editorial maps, claim register, `SECURITY.md`, `.env.example`). Use focused discovery rather than treating an absent optional tracker as negative evidence.

## Quick Triage

`quick` is read-only. Inspect bugs, tasks, audits, docs, dependencies, check coverage, and development-mode state; return the three highest-value maintenance actions with their owner routes. Classify documentation findings as bootstrap gap, migration debt, drift, or non-compliance. Do not launch audits, edits, installs, commits, or ships.

## Full Lane Order

For broad maintenance, collect independent read-only evidence first, then sequence dependent owner work:

```text
003-sg-bug -> 010-sg-technical deps -> 300-sg-docs update/audit
-> 105-sg-check nofix -> 010-sg-technical audit or 400-sg-audit
-> 010-sg-technical migrate candidates -> 106-sg-fix/001-sg-build
-> 011-sg-pilotage tasks -> 103-sg-verify -> 004-sg-deploy/005-sg-ship
```

Use the shared lifecycle for readiness, validation, documentation reflection, closure, and ship. A finding crosses the implementation threshold when it is not safely resolved as factual read-only reporting and needs a durable work item or write.

## Delegated Roles

Load the matching `$SHIPGLOWS_ROOT/skills/references/subagent-roles/` contract when delegating: `technical-reader.md` for technical documentation impact, `editorial-reader.md` for public-content/claim impact, `sequential-executor.md` for one bounded write mission, and `integrator.md` for cross-output coherence.

- Triage Reader: read-only bugs, dependencies, docs, checks, audits, migrations, security, specs, and project mode; returns a ranked plan.
- Lane Executor: owns exactly one bounded write set through the selected owner.
- Technical and Editorial Readers: produce documentation, editorial, and claim-impact plans where relevant.
- Integrator: consolidates evidence, runs focused proof, and decides whether verification may begin.
- Ship Executor: uses `004-sg-deploy` for deployment proof or `005-sg-ship` for bounded repo/docs/tooling changes.

Every delegated mission states the project root, active spec or mini-contract, mission, owned and forbidden surfaces, validation commands, report mode, and stop conditions.

## Security Lane

`security` first reviews bug files, then the optional bug index, for open high/critical security, auth, permission, data, webhook, or secret issues. Identify whether the project exposes auth, payments, webhooks, public APIs, multi-tenant data, admin actions, or production secrets. Route dependency and supply-chain posture to `010-sg-technical deps`; route code-level authn/authz, tenant/trust boundaries, secrets, webhooks, destructive actions, validation, secure failure, and abuse resistance to `010-sg-technical audit`.

Create or continue a spec when remediation crosses the chantier threshold; execute only safe remediations through bounded owners. Verify and ship only when the security, dependency, documentation, and check gates pass. Missing `SECURITY.md`, `.env.example`, development mode, or preview-proof policy are gaps, not vulnerabilities by themselves. Recommend a dedicated security audit skill only when repeated security-only work proves that need; do not create it from this lane.

## Detailed Report

User mode reports the chantier, verdict, project, result (`completed`, `verified`, `shipped`, `ship-ready`, `needs attention`, or `blocked`), topology, agents, lifecycle, checks, ship route, security posture, and proof gaps. Agent/handoff mode may include file/tracker evidence, the complete bug/dependency/docs/audit matrix, per-domain routes, proposed tracker entries, delegated missions, and validation/ship gates.
