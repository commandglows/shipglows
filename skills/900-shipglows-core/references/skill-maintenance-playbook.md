---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-15"
updated: "2026-07-15"
status: active
source_skill: 900-shipglows-core
scope: skill-maintenance-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/skill-instruction-layering.md
  - skills/references/skill-code-index.md
depends_on: []
supersedes:
  - skills/009-sg-skill-build/SKILL.md
evidence:
  - "2026-07-15 operator decision: consolidate internal skill maintenance under 900-shipglows-core."
next_step: "/103-sg-verify consolidate skill maintenance under shipglows core"
---

# Skill Maintenance Playbook

Use for `900-shipglows-core build <skill, path, or maintenance goal>`. `900` is internal-only, but this mode may maintain a public skill; public-surface checks then apply to that target, never to `900` itself.

## Resolve, Place, And Gate

1. Resolve one explicit ShipGlows skill or app-blueprint target under `$SHIPGLOWS_ROOT`; reject generic third-party generation, unscoped repository refactors, a missing target, invalid invocation name (lowercase letters, numbers, hyphens; no edge/double hyphen; max 64), ambiguous spec, or unapproved invocation rename.
2. Search adjacent skills and shared references for overlap. Prefer an existing mode, reference, or shared doctrine; create a domain skill only for a distinct trigger/outcome and a master only for a distinct multi-owner lifecycle. Record the placement decision.
3. Route broad ambiguity to `700-sg-explore`; otherwise, non-trivial work follows `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship`. Do not edit while readiness is not `ready`.
4. Blueprint extraction from a source app is the explicit exception: load `skills/references/app-blueprints.md`; it produces a blueprint, not a product spec, and does not invent a readiness gate.

## Build The Contract

1. Load `decision-quality-contract`, `skill-instruction-layering`, `spec-driven-development-discipline`, `question-contract`, `operator-partnership-contract`, `master-workflow-lifecycle`, `master-delegation-semantics`, and `task-application-loop` as applicable. Use delegated sequential work by default; parallel work needs ready, non-overlapping batches.
2. Define a pressure scenario and proof path before editing; change one bounded task slice at a time. Prefer a shared-reference repair unless the behavior is activation-critical and owner-specific.
3. Keep `SKILL.md` an English activation contract: concise mission, scope, modes/references, stops, validation, report/lifecycle trace. Move procedures, matrices, and examples to bounded references. User-facing prompts/reports use the active language.
4. Preserve security and ship scope: never expose secrets, strengthen unproven claims, rename an invocation without approval, or include unrelated dirty files. Record `fresh-docs not needed`, `checked`, `gap`, or `conflict`; a behavior/safety gap blocks progress.

## Runtime, Surfaces, And Proof

1. On a new/renamed invocation directory, require `agents/openai.yaml` display name to equal the exact invocation key when that file exists. Repair then check current-user Claude/Codex links with `tools/shipglows_sync_skills.sh`; non-symlink collisions block. Install-wide distribution and runtime reload are separate, explicit follow-ups.
2. After every material skill edit, run `900-shipglows-core refresh <target>` as conservative review before the final budget audit and `103-sg-verify`. For target `900-shipglows-core`, ordinary self-refresh stays prohibited: the spec-backed build run loads and applies `skill-refresh-playbook.md` as an independent manual review, with scenario-first and source-completeness proof.
3. A strictly mechanical change may record `refresh not needed` only with a written justification and focused proof that no refresh concern can apply; `fresh-docs not needed` is not that justification.
4. Load `skill-context-budget` before material body, discovery, or public-page growth. Run focused scenarios, metadata lint, `audit_shipglows_skills.py`, the budget audit, and runtime sync; run site/plugin checks only for affected surfaces.
5. Align help, routing, README/workflow/lifecycle docs, and public skill pages when the target's discoverability, promise, or invocation changes. Preserve the target's approved visibility; a brand-new material skill workflow is public by default unless its ready spec explicitly approves an internal-only exception. This policy never publishes internal-only `900`. Report both `Documentation Update Plan` and `Editorial Update Plan` as complete, no impact, or blocked.
6. Route implementation to `103-sg-verify`; this playbook neither closes nor ships. Report target, placement, lifecycle/proof, refresh or justified exception, runtime/reload status, changed surfaces, docs/editorial statuses, and remaining blockers.
