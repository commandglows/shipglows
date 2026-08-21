---
name: 405-sg-prod
description: "Verify production deploys, logs, health, and live behavior."
argument-hint: [optional: project name or URL]
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Instruction Layering

This `SKILL.md` is the activation contract. Before editing or expanding this skill, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` and keep bulky workflow detail in skill-local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. If attached to one unique chantier spec, write the run trace there. If no unique chantier exists, do not write to a spec.

## Chantier Potential Intake

Apply the chantier-potential threshold from `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md` before the final report.
For `405-sg-prod`, use it when deploy/runtime findings reveal non-trivial future work and no unique chantier already owns that work.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for audits and failures, outcome-first for successful support runs, and in the user's active language. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when detailed evidence is needed.

## Required References

Always load shared references only when their gate applies. Load skill-local references precisely by mode:

- `references/production-verification-workflow.md`: Production and preview verification workflow, deployment status, health checks, logs, Blacksmith evidence, reporting, and stop rules.
- `$SHIPGLOWS_ROOT/skills/references/actionable-failure-contract.md`: when findings are identified, route each failure to a concrete owner with evidence and impact.
- `$SHIPGLOWS_ROOT/skills/references/project-runtime-policy.md`: before diagnosing or proposing recovery for a ShipGlows-managed PM2 environment.

## Mode Detection

Parse `$ARGUMENTS` and choose the smallest safe mode under `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md`: bounded professional scope, never shortcut quality.

- DEPLOYMENT CHECK: load `references/production-verification-workflow.md` to verify deploy status and choose preview/production target.
- RUNTIME EVIDENCE: load the workflow reference before health checks, logs, Sentry, diagnostics/log-copy UI, PM2, Vercel, or Blacksmith evidence.
- PREVIEW-PUSH: load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` when the project uses preview-push validation.
- DELIVERY POSTURE: load `$SHIPGLOWS_ROOT/skills/references/project-delivery-policy.md`; enforce preview for published deployable changes and staging or documented equivalent isolation for sensitive production, without treating a successful Git push as deployment proof.

## Core Execution Rules

- Preserve deployment evidence, health check, log completeness, redaction, Sentry/PM2, diagnostics/log-copy, Blacksmith, and preview handoff rules.
- When PM2 evidence reveals a restart failure or crash loop, read the project runtime policy before recommending recovery. A disabled automatic-repair policy requires logs and Codex repair handoff, not automatic `env_start` recovery.
- Apply the Operator Autonomy Standard: gather safe deploy/build/runtime evidence, diagnostics, logs, health checks, and visible support IDs yourself before asking the operator; ask only for access, secrets, unavailable dashboards, manual/device-only proof, or unsafe external actions.
- Evaluate `Chantier potentiel` for outage, deploy, runtime, rollback, observability, or monitoring follow-up.
- Never expose secrets, cookies, tokens, private logs, unredacted env values, or unrelated customer data.

## Stop Conditions

Stop and report blocked when:

- A required reference is missing or contradicts this activation contract.
- The requested work would change behavior outside this skill's scope.
- A safety, security, documentation, source, claim, auth, production, redaction, or chantier guardrail would need to be weakened.
- The action would edit unrelated dirty files or mutate durable state without an owner-skill contract.

## Validation

Validate this skill after edits with:

- `rg -n "Trace category|Process role|Chantier Potential|deploy|health|logs|Sentry|Blacksmith|redaction|project-runtime-policy|references/" skills/405-sg-prod/SKILL.md`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `tools/shipglows_sync_skills.sh --check --all`
