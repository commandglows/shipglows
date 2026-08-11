---
name: 900-shipglows-core
description: "Internal ShipGlows skill maintenance: audit, build, refresh, packaging, and help."
argument-hint: "<audit [scope]|build <target>|refresh <target>|packaging [scope]|help>"
---

# ShipGlows Core

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows-owned tools, shared references, skill-local references, templates, workflow docs, and internal scripts resolve from `$SHIPGLOWS_ROOT`.
Follow the shared `ShipGlows-Owned Tool Preflight` doctrine from `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md`. Do not infer ShipGlows-owned tool paths from the current working directory or ask the operator to run the tool while this preflight is still agent-runnable.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

For a unique spec-first chantier, append the current `900-shipglows-core` run, update `Current Chantier Flow`, and use the opening chantier header. If no unique chantier is in scope, do not write a spec; use a `(local)` chantier header and route non-trivial build work to `100-sg-spec`.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and in the operator's active language. Use `report=agent` only for detailed handoffs, blocked runs, or explicit verbose requests.
When issues are found, keep `report=user` compact while preserving the `System-Improvement Output` below.

## Mission

`900-shipglows-core` is the sole internal ShipGlows entrypoint for skill improvement. It audits, builds, refreshes, validates, and prepares packaging decisions without acting as a public user-facing plugin.

Because this skill is itself ShipGlows infrastructure, invoking `900-shipglows-core` is an implicit instruction to improve ShipGlows even if the operator does not say "ShipGlows" out loud. The default target is the ShipGlows system under `$SHIPGLOWS_ROOT`: shared references, skill contracts, and governance rules. Do not assume the current project repository is the intended edit target unless explicitly named.

When the operator asks to modify the ShipGlows CLI or TUI from another conversation, treat the default edit targets as:

- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/shipglows.sh`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/lib.sh`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/config.sh`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/install.sh`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/install-shipglows.ps1`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/cli/windows/`
- `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tui/`

It also protects cross-skill invariants such as product governance: declared products should not rely on ad hoc URL discovery, improvised delivery framing, or unsupported public claims when the project corpus is supposed to hold that truth.

Use it when Diane or a ShipGlows maintainer wants to:

- audit whether local skills expose mission, scope, stop, validation, reference, and report signals clearly;
- investigate whether Codex is likely to miss a skill gate or ask the operator to do proof it could run itself;
- inspect portability risks for the public `shipglows` plugin and `$shipglows` entrypoint; `shipglows` is compatibility-only;
- keep the old `shipglows-core` plugin pilot historical, internal, and out of the public marketplace path.

## Mode Detection

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Parse `$ARGUMENTS` exactly as:

```text
audit [scope]
build <skill, path, or maintenance goal>
refresh <skill>
packaging [scope]
help
```

| Mode | Load / behavior |
| --- | --- |
| `audit` | Run the local execution-fidelity audit workflow below; translate non-style issues into system-improvement output. |
| `build` | Load `references/skill-maintenance-playbook.md`; use spec-first lifecycle gates for non-trivial contract work. |
| `refresh` | Load `references/skill-refresh-playbook.md`; preserve conservative evidence, novelty, and self-refresh rules. |
| `packaging` | Apply the packaging workflow and internal/public boundary below. |
| `help` | Explain the supported modes and canonical invocation shape. |

Bare or invalid input must list these modes or ask one targeted routing question. `build` and `refresh` without a target are invalid; do not infer a target, reuse the last target, or treat retired `009-sg-skill-build` / `307-sg-skills-refresh` names as aliases.

If an invalid mode is a known mode owned by another skill, preserve the
preflight stop but show the unique owner and exact invocation template. In
particular, `900-shipglows-core excellence` must suggest
`103-sg-verify mode=excellence <task or scope>`; never silently activate the
other skill from the rejected command.

`core` is a hard ShipGlows-system context: all text after the prefix belongs to
the ShipGlows workflow, never to the current project. An operator critique is a
bounded repair request, not a bare invocation: select the narrowest internal
`build` target and continue without asking the operator to choose a mode.
Project names, a quoted wrong route, and a stated desired project outcome are
failure evidence only. For example, `shipglows core pourquoi il propose
d'auditer ShipGlows ? je veux le projet courant` repairs the core routing rule;
it does not audit either repository. Diagnose and repair the ShipGlows layer
that selected the wrong target, then prove that this exact critique remains a
core repair request.

## Scope Gate

Audit, packaging, and help requests are read-only unless the operator asks for edits. `build` and `refresh` follow their loaded playbook; non-trivial behavior changes require a ready spec. An operator critique of ShipGlows execution authorizes a bounded repair at the narrowest justified ShipGlows layer unless the operator says `read-only`, `audit only`, or otherwise forbids edits.

Target binding rule: when `900-shipglows-core` is invoked through `shipglows core`, the edit target is always the ShipGlows system under `$SHIPGLOWS_ROOT`. No later project name, repository path, request, or quoted outcome overrides that context. To perform project work, leave `core` and invoke the relevant project mode or métier.

This skill is internal-only:

- do not add it to the public `shipglows` plugin bundle or `$shipglows` entrypoint;
- do not create a public site skill page for it unless the operator explicitly reverses that policy;
- do not treat the deprecated local plugin source at `$HOME/plugins/shipglows-core` as canonical.
- do not preserve `009-sg-skill-build` or `307-sg-skills-refresh` as aliases after their migration.

## Required References

Load only what the current request needs:

- `$SHIPGLOWS_ROOT/skills/references/skill-execution-fidelity.md` for skill-obedience, audit classification, and operator-last-resort rules.
- `$SHIPGLOWS_ROOT/skills/references/skill-instruction-layering.md` before choosing whether a behavior fix belongs in shared doctrine or a local skill contract.
- `shared:resource-discovery` when building, auditing, or migrating reference/playbook discovery, semantic resource IDs, or resolver behavior.
- `$SHIPGLOWS_ROOT/shipglows_data/technical/codex-plugin-packaging.md` for public plugin packaging and sparse bootstrap constraints.
- `$SHIPGLOWS_ROOT/skills/references/windows-bootstrap-development-workflow.md` before auditing, building, testing, or handing off native Windows bootstrap, installer, runtime-path, migration, wrapper, or self-update changes.
- `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md` before recommending or making skill-contract edits.
- `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` and `master-delegation-semantics.md` before `build` chooses lifecycle gates or delegated execution.
- `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before final reporting.
- `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-maintenance-playbook.md` for `build`.
- `$SHIPGLOWS_ROOT/skills/900-shipglows-core/references/skill-refresh-playbook.md` for `refresh`.

## Audit Workflow

For local skill-quality audits:

1. Resolve `$SHIPGLOWS_ROOT`.
2. Confirm the owned path `$SHIPGLOWS_ROOT/skills` exists.
3. Confirm the target tool `$SHIPGLOWS_ROOT/tools/audit_shipglows_skills.py` exists.
4. Run the versioned audit helper:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/audit_shipglows_skills.py"
```

5. Treat the helper as baseline evidence only: `hard` findings block completion until fixed or disproven; `review` findings need scenario-first triage; `style` findings do not justify standalone churn.
6. Do not claim an observed execution failure fixed from the generic audit alone. Require focused mechanical or pressure-scenario proof for that failure class.
7. Do not rewrite skills from audit output unless a ready spec or explicit operator instruction authorizes an edit pass.

## Mode Scenarios

- `audit [scope]`: audit only the resolved ShipGlows target; no contract edit is inferred.
- `build <target>`: load the maintenance playbook; ambiguous placement goes to `700-sg-explore`, while non-trivial contract work requires `100 -> 101 -> 102 -> 900 refresh -> 103 -> 104 -> 005`. Every material skill edit receives conservative `refresh <target>` review before final budget and `103`.
- `refresh <target>`: load the refresh playbook; `refresh 900-shipglows-core` is blocked as ordinary self-refresh and must use explicit spec-backed `build` work that loads the refresh playbook as an independent manual review with scenario-first and source-completeness proof.
- `packaging [scope]`: retain the internal/public package boundary; it does not publish `900`.
- `help`: describe modes only; no audit, build, or refresh action runs.
- Missing local playbook, target, runtime sync path, or required proof path blocks the affected mode rather than falling back to a retired command.

## System-Improvement Output

When `900-shipglows-core` confirms a non-style issue, the run is not complete until it has translated the finding into a reusable system-improvement output.

Required fields:

- `Observed problem`
- `System cause`
- `Prevention rule`
- `Contract/tooling improvement proposal`

System-improvement output must be scenario-first. Do not stop at wording criticism, generic "be more careful" advice, or a broad rewrite suggestion without naming the pressure scenario and the narrowest improvement locus that would prevent recurrence.

Before editing from an observed execution failure: name the pressure scenario, apply the shared `Followability Gate`, choose the narrowest owner layer, and define focused mechanical or scenario proof. A passing generic audit is not completion proof for the observed failure.

Prefer the smallest justified target:

- local skill contract when the issue is owned by one skill
- shared reference when multiple skills depend on the same doctrine
- audit/tooling improvement when the failure should be caught mechanically

For skill-improvement requests, default to shared-reference improvement first. Only edit a local skill body first when the behavior is activation-critical and unique to that owner skill.

Style-only findings do not require full system-improvement output unless a pressure scenario shows that the style gap is likely to cause a real execution failure.

## Packaging Workflow

For plugin packaging work:

1. Keep `shipglows` as the canonical public plugin and `$shipglows` as its public entrypoint; `shipglows` is a compatibility alias only.
2. Keep `900-shipglows-core` internal and repo-synced for operators; `shipglows-core` is a deprecated historical pilot, never canonical or public.
3. Check that public plugin flows do not require `$HOME/.shipglows/runtime` or `$HOME/plugins/shipglows-core`.
4. Use sparse bootstrap only after explicit approval because it changes local state and downloads source.
5. Never package secrets, private transcripts, customer context, dependency directories, local caches, or machine-specific paths.

## Stop Conditions

Stop and report `blocked` when:

- `$SHIPGLOWS_ROOT/skills` does not exist;
- `$SHIPGLOWS_ROOT/tools/audit_shipglows_skills.py` is missing when an audit was requested;
- a ShipGlows-owned audit step would run before resolving `$SHIPGLOWS_ROOT`, confirming the owned path, and confirming the target tool file;
- the request would present `shipglows` as the canonical public identity, or publish, bundle, or market `shipglows-core` as a public user plugin without explicit operator reversal;
- the request would edit broad skill contracts without a ready spec or explicit edit-pass instruction;
- the next proof step would require secrets, private account access, destructive actions, or user-only device access.

## Validation

Validate this skill after edits with:

```bash
rg -n "Mode Detection|Mode Scenarios|skill-maintenance-playbook|skill-refresh-playbook|retired|Mission|Scope Gate|Required References|Stop Conditions|Validation" skills/900-shipglows-core/SKILL.md
python3 -m unittest tools.test_900_shipglows_core_contract
python3 -m unittest tools.test_master_delegation_contract
python3 -m unittest tools.test_reporting_contract
python3 tools/audit_shipglows_skills.py
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill 900-shipglows-core
```
