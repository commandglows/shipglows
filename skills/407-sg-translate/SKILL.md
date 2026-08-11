---
name: 407-sg-translate
description: "Audit translation and i18n quality or safely sync clearly mapped missing localized entries through one entrypoint."
argument-hint: "[audit [path|global] | sync [path] | apply [path] | path | global | help]"
---

# Translate

## Canonical Paths

Before resolving ShipGlows-owned files, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, local playbooks, templates, and workflow docs resolve from `$SHIPGLOWS_ROOT`; project files resolve from the current project root.

## Instruction Layering

This `SKILL.md` is the compact activation contract. Before editing it, load `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md`; audit procedure, synchronization procedure, quality checklists, matrices, and report templates stay in the three local references.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. Trace only when exactly one active spec owns the run; otherwise do not write a spec. Evaluate the standard `Chantier potentiel` threshold when findings imply non-trivial locale strategy, broad remediation, or proof work without a unique owner.

## Report Modes

Before the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, findings-first for `audit`, outcome-first for `sync`, and explicit about changed localization surfaces, ambiguity, and proof limits without a file inventory. Use `report=agent`, `handoff`, `verbose`, or `full-report` when the full locale matrix, touched-file evidence, or handoff detail is needed.

## Mission

`407-sg-translate` is the sole public translation and i18n entrypoint. It selects exactly one canonical mode—`audit` or `sync`—and one bounded playbook. `help` is discovery-only; `apply` is an input alias to `sync`, never a third mode or implementation path.

## Mode Detection

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or materially ambiguous preflight never activates an execution path. Load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before selecting scope or mutation authority.

Parse `$ARGUMENTS` exactly:

- bare invocation -> `audit` the unambiguous current project; load only `$SHIPGLOWS_ROOT/skills/407-sg-translate/references/audit-playbook.md`.
- `audit [<path|scope|global>]` -> load only `$SHIPGLOWS_ROOT/skills/407-sg-translate/references/audit-playbook.md`.
- `global` -> normalize to `audit global` and load only the audit playbook.
- a valid existing path or unambiguous path-like scope without a mode -> normalize to `audit <path-or-scope>` and load only the audit playbook; never infer `sync` from a path alone.
- `sync [<path|scope>]` -> load only `$SHIPGLOWS_ROOT/skills/407-sg-translate/references/sync-playbook.md`.
- `apply [<path|scope>]` -> normalize to the exact `sync` route and load only the sync playbook.
- `help` -> list the grammar, boundaries, and examples; load no execution playbook and make no file mutation.

Canonical public modes are exactly `audit` and `sync`. If input does not match these routes safely, report the accepted grammar and load no execution playbook. Exact mode tokens take precedence over path-like text. If the current project or `global` project set is not unambiguous, report the evidence gap or ask one focused scope question; do not launch arbitrary work.

## Required References

After routing, load only the selected playbook. That playbook loads `$SHIPGLOWS_ROOT/skills/407-sg-translate/references/translation-quality-reference.md` for the shared quality and i18n invariants it needs.

Load these shared references only when their gate applies:

- `$SHIPGLOWS_ROOT/skills/references/question-contract.md` before a required project, locale, or business-meaning decision.
- `$SHIPGLOWS_ROOT/skills/references/operational-record-format.md` before any explicitly authorized project-local audit/task record write; re-read the target immediately before a minimal write.
- `$SHIPGLOWS_ROOT/skills/references/task-registry-routing.md` before persisting follow-up work.

A missing selected playbook or mandatory shared reference is a visible blocked result. Do not fall back to the other mode or a retired identity.

## Owner Boundaries

- localized persuasion, offer, CTA, or message-market fit -> `009-sg-marketing copy` or `009-sg-marketing copywriting`
- SEO strategy, rankings, indexing, or launch ownership -> `406-sg-seo`; `407` still checks locale-specific technical i18n invariants
- editorial drafting or substantive localized-content lifecycle -> `007-sg-content` or `200-sg-redact`
- documentation ownership -> `300-sg-docs`
- broad cross-domain audit -> `400-sg-audit`, which invokes `407-sg-translate audit` for its translation lane

Do not absorb adjacent work merely because translated text or locale routes are involved.

## Safety And Mutation Authority

- `audit` is read-only for product files. Findings never grant remediation authority.
- `sync` may add only clearly mapped missing localized entries inside the selected scope. It never rewrites existing non-empty translations, changes locale/slug strategy, or standardizes disputed terminology by default.
- Preserve placeholders, ICU fragments, formatting tokens, Markdown links, HTML tags, component markers, brand/product names, and project terminology.
- Leave ambiguous, business-sensitive, terminology-conflicting, placeholder-unsafe, or unmapped entries unchanged; list them for review and continue only with independent low-risk entries.
- Never expose secrets, private payloads, credentials, cookies, or customer data in scans or reports.

## Validation

After contract edits, run:

```bash
python3 tools/test_407_sg_translate_contract.py
python3 -m unittest tools.test_010_sg_technical_contract
python3 tools/shipglows_metadata_lint.py skills/407-sg-translate
python3 tools/audit_shipglows_skills.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
python3 tools/skill_code_index_lint.py
tools/shipglows_sync_skills.sh --check --all
```

## Stop Conditions

Stop or return a confidence-limited result when the scope, source locale, locale mapping, project terminology, business meaning, placeholder structure, or selected reference is too uncertain for the requested operation. Do not convert an audit into a sync, a sync into broader rewriting, or a translation finding into an adjacent-owner change without explicit authority.

## Rules

- Keep one public identity, exactly two canonical modes, one compatibility alias, and one selected playbook per execution.
- Keep detailed procedure and checklists in the local references; do not recreate a monolithic activation body.
- Preserve active discoverability under `407-sg-translate`; the former operation-named identity is historical only and has no wrapper.
