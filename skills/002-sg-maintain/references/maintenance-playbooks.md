---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-10-20"
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
  - skills/references/audit-cadence-matrix.json
  - skills/references/next-outcome-selection.md
  - skills/references/vercel-cost-conscious-operations.md
depends_on:
  - artifact: skills/references/master-workflow-lifecycle.md
    artifact_version: "1.8.0"
    required_status: active
  - artifact: skills/references/master-delegation-semantics.md
    artifact_version: "1.8.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-04: Vercel Pro maintenance must optimize for measured, controlled consumption rather than speed or credit exhaustion, while preserving Hobby portability."
  - "Operator decision 2026-09-01: hygiene remains proposal-only for non-Git corrections while safe Git/GitHub convergence uses standing authority without validation prompts."
  - "2026-08-12: extracted 002-sg-maintain lane detail so its activation contract stays below the progressive-disclosure risk threshold."
  - "2026-08-16: operator approved a current-project-only, proposal-first hygiene audit."
  - "2026-08-21: operator required audit freshness to become the deterministic fallback after active conversation and tracker work are exhausted."
next_review: "2026-11-12"
next_step: "/103-sg-verify maintenance-playbooks"
---

# Maintenance Playbooks

## Context Discovery

Before triage, inspect only evidence relevant to the selected lanes: current project and git state; documented development mode and package scripts; bug files then the optional bug index; recent tests; local tasks and audit log; active specs; and the applicable docs/governance surfaces (`AGENTS.md`/`CLAUDE.md`, technical/editorial maps, claim register, `SECURITY.md`, `.env.example`). Compare audit-log dates with `skills/references/audit-cadence-matrix.json` through `tools/audit_cadence_status.py`; event-triggered, never-run, and overdue domains are freshness findings, while project governance may declare stricter intervals. Use focused discovery rather than treating an absent optional tracker as negative evidence.

## Quick Triage

`quick` is read-only. Inspect bugs, tasks, audit freshness, docs, dependencies, check coverage, and development-mode state; return the three highest-value maintenance actions with their owner routes. Classify documentation findings as bootstrap gap, migration debt, drift, or non-compliance. Rank event-triggered and overdue audits through the shared matrix without inventing severity. Do not launch audits, edits, installs, commits, or ships.

## Current-Project Hygiene

`hygiene` is a comprehensive read-only audit, not the abbreviated `quick`
triage and not the mutating `full` lifecycle. Inspect the current project only:

- Git and temporary worktree residue, using local status, refs, worktree metadata, and already available PR evidence without an implicit fetch, plus `tools/git_storage_check.py` for local storage upkeep (`git worktree prune`, `git gc`) routed to `shipglows git` when due
- dependencies and supply-chain posture
- security and trust-boundary gaps
- documentation and governance drift, plus the read-only workflow tidy inventory (`tools/project_docs_tidy_audit.py`) as a proposal when its `--check` or the `workflow-tidy` cadence says due
- checks, audits, and quality debt
- stale generated, cache, build, or task residue only when ownership and disposability can be classified without deleting it

Deduplicate findings by evidence identity, rank them by risk and leverage, name
their normal owner route, and return one grouped correction proposal. Distinguish
verified findings, freshness gaps, unavailable-tool gaps, and informational
notes. Zero findings returns a clean verdict; one or many findings retain the
same report shape.

No non-Git correction is authorized by the hygiene invocation. Do not install,
edit, fix, migrate, deploy, or delete application or content artifacts. Those
corrections require their normal owner contract. Ordinary Git/GitHub
stewardship remains standing authority: the audit may fetch/prune and route
proven reconciliation or cleanup to `shipglows git` without a validation
prompt. Never invoke native `git clean`; `shipglows hygiene git` instead routes
to the safe Git lifecycle, which proves ownership and integration, preserves
unique or ambiguous state, and records a terminal disposition.

## Tidy Lane

`tidy` (aliases `shipglows tidy`, `ménage`) brings the current project back to a light, at-rest state. It is the operator-facing entrypoint for cleanup that closure, next-outcome selection, and maintenance otherwise trigger by project activity.

1. **Inventory, read-only, together:** `tools/project_docs_tidy_audit.py .` (workflow docs and specs), `tools/git_resting_state.py . --integration <canonical integration branch>` (worktrees, branches, pull requests, upstream drift), `tools/git_storage_check.py .` (worktree prune, gc), and, only when the project is ShipGlows itself, `tools/orphan_reference_audit.py`.
2. **Triage** each lane with its owner rules: `300-sg-docs` TIDY MODE for workflow docs, the Resting State of `git-temporary-artifact-lifecycle.md` for Git artifacts, the storage check's prescribed commands, and the value triage of `dead-code-obsolescence-audit.md` for orphan skill docs.
3. **One approval packet** for the whole run, grouped by lane: what converges automatically under standing Git authority, and what needs approval (deletions, merges of work this run does not own, `dormant` decisions). Never split it into several questions.
4. **Apply** through the owners in this order: Git convergence and storage upkeep, then documentation merges, then deletions in one commit per lane whose message lists every deleted path. Untracked files are never deleted.
5. **Report** before/after sizes, what converged, what was deleted (with the recovery commit), what remains and why, and end with `Git: at rest on <branch>` or the remaining proposal.

Tidy never archives, rewrites history, force-pushes, or uses expiring-now Git commands.

## Full Lane Order

For broad maintenance, collect independent read-only evidence first, then sequence dependent owner work:

```text
003-sg-bug -> 010-sg-technical deps -> 300-sg-docs update/audit [-> 300-sg-docs tidy]
-> 105-sg-check nofix -> 010-sg-technical audit or 400-sg-audit
-> 010-sg-technical migrate candidates -> 106-sg-fix/001-sg-build
-> 011-sg-pilotage tasks -> 103-sg-verify -> 004-sg-deploy/005-sg-ship
```

Run `300-sg-docs tidy` inside the docs lane whenever `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/project_docs_tidy_audit.py" . --check` reports `due` (operational trigger, primary) or `tools/audit_cadence_status.py` reports the `workflow-tidy` domain overdue (time backstop); its own approval packet still gates every move, and a declined or deferred packet is reported, not retried in the same run.

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

## Vercel Economy Lane

When Vercel is declared, load `skills/references/vercel-cost-conscious-operations.md`. In quick or hygiene mode, inspect only available project policy and provider evidence; do not mutate the account. Report plan-policy gaps, Standard/Enhanced/Turbo choice, concurrency mode, skipped/superseded build posture, spend ownership, current and projected usage when callable evidence exists, top resource contributors, preview protection, WAF review state, observability fit, and paid add-ons. Preserve Hobby compatibility as the baseline and never recommend consuming credit merely because it is included. Provider usage, billing, firewall, or protection state that is configured but not callable remains an evidence gap.

In mutating maintenance, changing spend thresholds, billing, add-ons, build settings, deployment protection, WAF rules, domains, environments, or production availability retains its explicit provider/security authority. A spend webhook may open a redacted finding through a separately approved receiver, but it never silently pauses or resumes projects.

## Detailed Report

User mode reports the chantier, verdict, project, result (`completed`, `verified`, `shipped`, `ship-ready`, `needs attention`, or `blocked`), topology, agents, lifecycle, checks, ship route, security posture, and proof gaps. Agent/handoff mode may include file/tracker evidence, the complete bug/dependency/docs/audit matrix, per-domain routes, proposed tracker entries, delegated missions, and validation/ship gates.
