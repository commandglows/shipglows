---
name: 400-sg-audit
description: "Audit product, code, design, SEO, GTM, and performance."
argument-hint: '[file-path | "global"] (omit for full project)'
---

## Canonical Paths

Before resolving any ShipGlowz-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipglowz`). ShipGlowz tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPFLOW_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Because this skill has process role `source-de-chantier`, evaluate the standard threshold from `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md` before the final report. Add a `Chantier potentiel` block when findings reveal non-trivial future work and no unique chantier owns it.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/audit-master-workflow.md`: Master audit planning, domain routing, parallel/read-only audit rules, consolidation, tracking, and fix handoff details.
- `$SHIPFLOW_ROOT/skills/references/operational-record-format.md`: required before creating or mutating audit or task operational records in `AUDIT_LOG.md` or `TASKS.md`.
- `$SHIPFLOW_ROOT/skills/references/skill-refactor-verifier.md`: required for audit-skill compaction or process-migration checks.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPFLOW_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

`400-sg-audit` answers one routing question: what audit scope is actually needed here, and should we coordinate multiple domains or route directly to one specialist audit owner?

Use the master workflow for global or project-level coordination, and route directly to specialist audit skills when one domain is obvious.

Keep the boundary explicit: `400-sg-audit` owns broad audit planning, domain selection, bounded read-only fan-out, and consolidation. It does not need to stay in the loop when one specialist audit already clearly owns the question.

Route directly instead of staying in `400-sg-audit` when the scope is already narrow:

- code correctness, security, architecture, or test posture -> `010-sg-technical audit`
- dependency risk, licenses, or supply-chain posture -> `010-sg-technical deps`
- performance, bundles, rendering, CWV, data, or database efficiency -> `010-sg-technical performance`
- migration risk -> `010-sg-technical migrate`
- live deployment truth, health, or runtime behavior -> `405-sg-prod`

## Core Execution Rules

- Findings first; prioritize cross-domain P1/P2 clusters and systemic risk.
- For projects with UI, treat missing or bypassed design-system authority as a systemic design/governance risk and ensure the Design lane checks `skills/references/design-system-token-contract.md`.
- Evaluate `Chantier potentiel` when findings require multi-domain remediation, staged fixes, or owner-skill follow-up.
- Use bounded read-only audit fan-out only when each lane has disjoint evidence scope and no file mutation.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|Report Modes|GLOBAL MODE|PROJECT MODE|findings|parallel|references/" skills/400-sg-audit/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglowz_sync_skills.sh --check --all`

For compaction or refactor work, also run the verifier reference before closing the task.
