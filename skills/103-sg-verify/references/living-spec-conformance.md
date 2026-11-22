---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-22"
updated: "2026-11-22"
status: active
source_skill: 103-sg-verify
scope: 103-sg-verify-living-spec-conformance
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/103-sg-verify/SKILL.md
  - skills/references/capability-spec-delta.md
  - tools/spec_delta_merge.py
  - shipglows_data/workflow/specs/capabilities/
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-11-22: verification compares code with the living capability spec, not only with the change spec."
next_step: none
---

# Living Spec Conformance

Apply when the change spec has a `## Capability Delta`, or when changed code belongs to a capability in `shipglows_data/workflow/specs/capabilities/`. A change spec proves the change; the living spec states everything that must still hold. Verify both.

## Expected State

1. Resolve touched capabilities: the delta's `Capability` lines, plus every living spec whose requirements cover changed paths or behavior, even when the change spec does not name it.
2. Build the expected requirement set per capability. Before the merge: living requirements, minus `REMOVED`, with `MODIFIED` replacing same-name blocks, plus `ADDED`. After the merge: the living spec as written.
3. Run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/spec_delta_merge.py" <change-spec> --check` and `--validate` on each touched living spec. A refusal is a finding, never something to edit around.

## Compare Code To Requirements

For every expected requirement of a touched capability, not only the delta:

- locate the code path and the test or proof that exercises each `Scenario` (`WHEN` -> `THEN`);
- read the diff for behavior that contradicts an untouched requirement: this is a regression even when every `AC` of the change spec passes;
- for `REMOVED`, confirm the behavior is gone or intentionally kept under another requirement;
- for `MODIFIED`, confirm the old behavior no longer survives in code, tests, or docs.

Classify each requirement: `met` (code plus proof), `unproven` (code without scenario proof), `violated`, or `not checked — <reason>`.

## Drift Without A Delta

- Code changes capability behavior with no delta: `implemented but not specified`; route the missing delta to `100-sg-spec`, or correct the code.
- Living spec disagrees with code that the change did not touch: report pre-existing drift with its requirement name and owner route; never rewrite the living spec during verification to make it pass.
- No living spec exists for the touched behavior: not a failure; report `no living spec` and verify against the change spec alone.

## Verdict Effect

Report `Living Spec Fit: pass | partial | fail | not applicable` with the capability names and the count of requirements checked. A `violated` requirement or a refused `--check` is `fail` and forbids `verified`. `unproven` on critical behavior is `partial`. A delta that is valid but not yet merged is normal before closure and never a failure.
