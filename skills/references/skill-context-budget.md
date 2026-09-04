---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.14.0"
project: ShipGlows
created: "2026-04-29"
updated: "2026-09-05"
status: active
source_skill: 300-sg-docs
scope: skill-context-budget
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - skills/*/SKILL.md
  - skills/*/agents/openai.yaml
  - tools/skill_budget_audit.py
  - Codex
depends_on: []
supersedes: []
evidence:
  - "Approved Core pilot adds complete declared scenarios, independent budget verdicts and observed reread accounting."
next_review: "2026-10-05"
next_step: none
---

# Skill Context Budget

## Separate Costs And Authority

- `D-portable`: repository-relative path + name + description of selected catalogue.
- `D-runtime`: lexical installed path + name + description, only for an explicitly
  supplied runtime root. Never resolve junctions before pricing discovery.
- Terminal profile: one engine body, baseline and independently selectable gates.
- Complete declared scenario: public entry, routing, selected engine, applicable
  references and report. Count canonical files once; do not infer completeness
  from a valid terminal profile or a green dependency graph.
- Observed trace: supplied actual full-file read events, with repeated costs shown
  separately. A declaration is never an observation or provider billing telemetry.

Public wrappers remain implicit; experts explicit-only. The invocation registry
owns catalogue membership, not a duplicated count in this document. Missing policy
is runtime-default implicit and must be reported. Keep the existing 8500-character
portable guard; changing it requires a distinct approved migration.

## Metadata And Body Targets

- `description`: one concise sentence, target 80–120 characters, warning above 140, hard ShipGlows maximum 200.
- Put syntax in `argument-hint`, never `Args:` in a description.
- Keep names lowercase, hyphenated, stable, under 64 characters, and equal to their directory.
- `SKILL.md`: target under 500 lines and about 5,000 estimated body tokens.
- Wrapper target: below 500 tokens; atomic owner 800–1,800; master 1,200–2,200 when safe.
- Activation core (`body + mandatory references`) should target below 5,000 unique estimated tokens.
- A reference above 5,000 estimated tokens is a review signal: split only when multiple real loading decisions exist.

Size is never authority to remove a stop condition, security gate, proof requirement, trace role, or reporting contract.

## Progressive Loading

Runtime directives remain authority. Select owner/mode first, mandatory invariants
next, and one direct specialized reference when a concrete decision requires it.
Keep trigger, safety stops and proof visible before detail is selected. Leaf siblings
never load one another. Ordinary routing does not require delegation procedure.
A resolved owner does not require the full routing matrix. Reuse loaded current
canonical text; reread only for a freshness signal or loss of usable context.

`linked_systems` and resolver results are advisory. `depends_on` validates document
versions/status/cycles; it is not an instruction to inject those files. Mandatory
references remain required even when an advisory pack omits them. Never silently
truncate a normative file to meet a ceiling. Examples and historical wave evidence
are cold: see `shipglows_data/technical/progressive-loading-pilot-baseline.md` only
for historical investigation, not ordinary activation.

## Executable Scenario Accounting

Extend `activation_profiles.scenarios` in `skill-invocation-registry.json` only for
reviewed pilots. Each scenario declares `entry`, `selected_engine`, and `reads`.
Each first read has `path`, `parent` (null only for entry), `stage`, `trigger`, and
`reason`. Parent identifies the directive that first requires the file, not a
metadata dependency. Shared references appear once. Review the ledger against the
runtime text; tool validation alone cannot prove that every required read is listed.

`budget` declares `max_tokens` and `max_depth_after_selection`; `baseline_tokens`
and `min_reduction_percent` gate comparison. Freeze baseline commit, file hashes,
per-file token estimates and scenario conditions. Recompute comparisons when scope
changes; never disguise a former lower bound as a complete baseline. The pilot's
Core audit baseline includes previously omitted execution, excellence, fidelity and
unfinished-choice conditions. Keep the original audit lower bounds visible.

The existing estimator uses ceil(UTF-8 text characters/4), not a model tokenizer.
CLI returns nonzero for invalid declarations or failed scenario budgets. It reports
structural and budget verdicts separately, per-stage cost and depth. Depth counts
declared edges below the selected engine; it is not actual UI/tool navigation.
Terminal profiles retain compatibility: `valid` alone does not enforce a ceiling.
Their worst case is a union of all gates, not one realistic executable scenario.

For observed full-file events pass `--trace` JSON containing `events`, each with
`path` and `reason`. Do not synthesize it from a declared scenario; partial reads,
metadata output, model prompts and tool results need separate telemetry and cannot
be represented honestly as full-file reads. Trace paths remain within the root.

## Audit Commands

```bash
python3 tools/skill_budget_audit.py --skills-root skills --catalog all --discovery-mode implicit --format markdown
python3 tools/skill_activation_budget.py --scenarios
python3 tools/skill_activation_budget.py --scenario core-help --format json
python3 tools/skill_activation_budget.py --scenario core-help --trace /path/to/observed-reads.json
python3 tools/resource_dependency_graph.py --format text
```

Budget failures require a smaller sufficient load or an explicit reviewed exception,
never deletion of safety, authority, proof, trace or reporting requirements. Broader
migration waits for scenario and consumer non-regression evidence from this pilot.

## Common-Path Checkpoints

The approved second pilot adds seven `common-*` scenarios (six natural-language
families plus a missing-target continuation variant). Their `checkpoint` and
`assumptions` delimit the measured obligation: routing, a first proof decision,
or an unfinished approval/clarification report. They are not complete lifecycle
costs. Existing Core scenarios retain their complete declared-path boundaries.
Common baselines freeze the post-Core-pilot working tree with per-file hashes;
HEAD alone cannot reconstruct that baseline. See the common-paths baseline document
under `shipglows_data/technical/` only for measurement/audit, not runtime activation.

## Loading Change Gate

Before changing a reference, trigger, shared normative text or protection, freeze
comparable affected paths (including reporting), costs and depth, even if files
shrink. Review mandatory edges against runtime prose; distinguish advisory links
and validity dependencies. For uncovered paths add one bounded scenario, not a
corpus read. Record every read's need, trigger and timing. Keep safety and proof
visible before optional detail; examples/history stay cold.

Run the existing scenario evaluator and focused protection tests. Independently
review `required_reads`: it asserts indispensable paths, never generates them
from `reads`. Missing requirements fail structurally even if cost falls. Test
extra eager reads, cascades, omissions and removed protections. Assertions detect
known cases, not arbitrary prose; independent review remains required.

Block unexplained cost/depth increases, lost protections and approved-budget
failures. Necessary increases require evidence and explicit operator arbitration;
never silently raise ceilings, change the checkpoint or remove requirements to
pass. Report before/after and limits; unmeasured changes are not proven safe.
