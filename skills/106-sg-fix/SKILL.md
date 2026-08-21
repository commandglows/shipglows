---
name: 106-sg-fix
description: "Triage and repair bugs, regressions, and failing behavior."
argument-hint: <bug description, error message, or failing behavior>
---

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows paths. Resolve project artifacts from project root.

Primary artifact type: `specialist-workflow`.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Load `chantier-tracking.md` before reporting when exactly one spec-first chantier owns the run. Trace only that chantier; otherwise use a `(local)` header and do not mutate specs. Apply its potential threshold to non-trivial unowned follow-up.

## Mission And Authority

Answer: `Ce bug est-il assez clair et borné pour un correctif direct sûr ?`

Own intake, classification, bounded repair, bug memory, and retest routing; not specs, specialist diagnosis, verification, or shipping.

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before ShipGlows-owned reads, tools, runtime/bug-memory checks, or writes. Apply `$SHIPGLOWS_ROOT/skills/references/operator-last-resort-evidence.md` before asking the operator for logs, screenshots, reproduction, status, or validation.

## Classification

Reconstruct actor, trigger, broken behavior, and expected value; choose:

- `direct`: small, local, clear, low-risk, with an obvious expected behavior and named proof path.
- `spec-first`: multi-file/cross-system behavior, unclear product meaning, likely edge cases, migration/data/auth/performance implications, or material permission, visibility, workflow-integrity, security, destructive, or external-side-effect ambiguity. Load `spec-driven-development-discipline.md`; do not code; route through spec readiness and implementation.
- `diagnostic-only`: evidence is insufficient and a browser/auth/runtime specialist owns the next diagnosis; do not code.

When ambiguity could change behavior, scope, authority, failure handling, data exposure, tenant isolation, or security, load `decision-quality-contract.md` before one targeted question. Direct fixes still require root-cause and owner-boundary reasoning.

Choose `regression-first`, `evidence-first`, or `exception-with-proof`. For non-trivial state, boundary, interface, or exceptional behavior, load `zombies-edge-case-heuristic.md` before finalizing reproduction scope.

## Conditional Reference Map

- For a `direct` classification, load `references/bug-fix-workflow.md` before bug-memory mutation or repair.
- Before the first code write, load `implementation-excellence-preflight.md`; classify and emit `🛡️ GARDE-FOUS`; load applicable authorities, `task-application-loop.md`, and `clean-code-quality-contract.md`.
- Before selecting or claiming a retest surface, load `project-development-mode.md` and `references/bug-proof-and-reporting.md`.
- Load `project-runtime-policy.md` for ShipGlows-managed PM2 startup failures or crash loops.
- Load `design-system-token-contract.md` before UI, mobile, layout, token, theme, motion, keyboard/IME, overlay, responsive, or visual repair; changed UI files also require the design drift check.
- Load `documentation-freshness-gate.md` when current framework, SDK, service, API, auth/session, build, migration, cache, routing, or integration behavior may control the fix.
- Load `atlas-protection-preflight.md` before writing to a project with an Atlas registry; a bug report never authorizes Gold/Diamond changes.
- Load `owasp-application-security-awareness.md` before writing to an internet-facing or privileged surface. Load only triggered Supabase, Sentry, diagnostics, auth-debug, or browser references.
- Load `reporting-contract.md` before the final report.

Reclassify on growth; a failed `Implementation Excellence Gate` forbids `fixed-pending-verify`.

## Durable Memory And Result Semantics

A direct fix requires a `BUG-ID` and `shipglows_data/workflow/bugs/BUG-ID.md`, except copy-only typos, purely cosmetic defects without state/permission/data/interaction consequences, or duplicates with no new history. The exception only waives creation of a new durable bug file, never evidence, retest, or verification.

Keep status at most `fix-attempted` until retest evidence exists; allow `fixed-pending-verify` only after a passing retest; never close without verification. Preserve the exact visual sequence `evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify`.

For a user-visible visual defect, technical checks support only `implemented`; do not say resolved, fixed, verified, or closed until a person validates the rendered result. If unavailable, report the proof gap and owner.

## Security And Stop Conditions

Preserve auth/authz, tenant/resource boundaries, input validation, security-by-default, and protections against replay, double-submit, stale state, invalid order, data exposure, and unsafe external effects. UI-only protection is insufficient.

Stop direct work when:

- ambiguity changes product meaning, data handling, permissions, security, destructive behavior, or external effects;
- another patch would repeat attempts without reproduction evidence and a root-cause hypothesis;
- no practical regression/evidence path can be named;
- required durable bug memory cannot be safely created or updated;
- preview-push proof is required but no matching deployment target exists;
- required fresh external documentation remains unresolved.

## Validation

- `python3 -m unittest tools.test_106_sg_fix_compaction_contract tools.test_bug_proof_fidelity_contract tools.test_clean_code_quality_contract tools.test_owasp_application_security_contract tools.test_zombies_edge_case_contract`
- `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
- `python3 tools/shipglows_metadata_lint.py skills/106-sg-fix/references/bug-fix-workflow.md skills/106-sg-fix/references/bug-proof-and-reporting.md`
- `tools/shipglows_sync_skills.sh --check --skill 106-sg-fix`
