---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: reviewed
source_skill: 900-shipglows-core
scope: progressive-loading-common-paths-baseline
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/skill-invocation-registry.json
  - tools/skill_activation_budget.py
  - tools/test_progressive_loading_common_paths.py
depends_on: []
supersedes: []
evidence:
  - "Approved second wave measures six natural public-entry families and the missing-target continuation variant."
next_review: "2026-10-05"
next_step: none
---

# Common natural-language loading checkpoints

Historical measurement evidence, not runtime instructions. These fixtures use the
existing `activation_profiles.scenarios` and `skill_activation_budget.py` evaluator.
There is no second resolver or model-routing system.

## Baseline identity and method

Baseline was captured on 2026-09-05 after the approved Core pilot and before the
common-path edits, in the dirty working tree based on commit
`65d3fc1791370ab7a2668014ce7b2338bde11d75`. It is **not** that commit's file content.
Every scenario stores exact per-file raw-byte SHA256 and estimated tokens in
`baseline_reads`. The two main baseline contracts were:

- question: 5,381 tokens, SHA256 `f5fa11129683a5ef41cb13b4bbdcdd124e91b2eaf0759d65cb75b46bbb6faae4`;
- partnership: 4,043 tokens, SHA256 `e1ac1218e5756f7ebdb98df14c58e319157b6dd8668d4dd9057eeacd8db41df1`.

Token estimates use `ceil(len(Path.read_text(encoding="utf-8"))/4)`, including
frontmatter, with Python newline normalization and one cost per canonical file.
Machine hashing or metadata validation does not expose those files to an agent
and is not counted as a model read. Host instructions, conversation, project
artifacts, source code, tool output and provider tokenization are outside these
instruction-file estimates. No actual application was changed or tested by these
fixtures; they are declared scenario checkpoints, not observed agent traces.

## Comparable checkpoints

| Scenario ID suffix | End of measured prefix | Baseline | Ceiling |
| --- | --- | ---: | ---: |
| docs-direct | Direct route selected, before write/proof/report | 4,436 | 4,436 |
| verify-direct | Direct route selected, before running proof/report | 4,436 | 4,436 |
| bug-proof-selection | Evidence owner and authoritative proof route selected and reported | 23,641 | 23,641 |
| feature-approval | First material plan presented, before spec/readiness/execution | 40,827 | 40,827 |
| page-comprehension | Initial finding and next owner reported | 19,520 | 19,520 |
| resume-ready | Unique ready target and next authorized unit selected | 12,523 | 12,523 |
| resume-missing | Target unavailable after focused evidence search; clarification reported | 25,562 | 19,171 |

The suffixes are prefixed `common-` in the registry. Six families produce seven
fixtures because continuation has a ready and an unresolved variant. These are
representative scenarios supplied by the user, not measured frequency rankings.
The differing stop points are intentional and must never be compared as total
completed-task costs. Each registry record contains the prompt, assumptions,
checkpoint, first-read parent, stage, reason and trigger.

Independent source review corrected two incomplete first-pass totals: bug
20,920 omitted the explicit `project-development-mode -> project-delivery-policy`
and `spec-driven-development-discipline -> zombies-edge-case-heuristic` reads;
adding their frozen pre-wave costs gives 23,641. Feature 37,202 omitted the build
owner's UI `design-system-token-contract` gate; adding it gives 40,827. Earlier
totals must not be used as complete checkpoint baselines. The registry records
these corrections and original file hashes without pretending they were HEAD.

## Selection and exclusions

- Exact internal documentation changes and focused non-UI local checks exercise
  the existing bounded direct gate. No métier skill is required at route selection.
  Actual documentation mutation still requires the mutation approval contract;
  proof and reporting remain downstream obligations.
- The defect fixture selects `sg-bug`, one evidence playbook, the mandated proof
  discipline, edge-case coverage, project development mode and its delivery-policy
  dependency. The existing evidence-pack -> development-mode -> delivery-policy
  chain has depth three; the measurement preserves it rather than flattening it. It stops before topology/dispatch,
  repair and closure. A visible symptom never becomes a verified fix in this model.
- The feature fixture selects the existing-product build owner and early-route
  pack, then questions/partnership/approval for a genuinely material unresolved
  choice, including the mandatory UI design-system authority contract. It does not start readiness or create a spec. Later readiness, delegated
  implementation, UX intelligence when triggered, proof and closure are not waived.
- The page fixture includes supplied trustworthy comprehension evidence and known
  user/first-success context. Those assumptions justify experience audit. The bare
  phrase “page confuse” alone cannot resolve design versus experience. There is no
  external feedback, loading operation, permissions choice or implementation in
  this checkpoint; those triggers would add their specific references.
- Ready continuation includes current-context quality and the continuation
  playbook, then execution doctrine after the next unit is identified. Missing
  continuation includes question/partnership/strategic and unfinished reporting,
  but no execution leaf or invented target.

Known owners skip the full entrypoint matrix. A cited doctrine is not, by itself,
a mandatory full-file read. Metadata `depends_on` validates document compatibility;
it is not an activation closure. The baseline never includes unrelated advisory
citations or all the playbooks of a selected métier. Conditional instruction reads
are omitted only where the explicit fixture assumptions make the trigger false.

## Verification and practical limits

Run `python -B -m unittest tools.test_progressive_loading_common_paths` and
`python -B tools/skill_activation_budget.py --scenarios --format json`.
The tests require no increase on the direct witnesses and other checkpoints,
at least 25% reduction on missing-target clarification, and no increase over baseline depth
after engine selection. The bug fixture preserves its inherited depth-three
cascade; all other common fixtures have baseline depth one. This is an existing
loading cost to expose, not a new cascade introduced by this wave. A negative-control eager read must exceed the direct
budget, proving that a structurally valid path alone cannot pass the budget.

These deterministic fixtures do not demonstrate that a live agent always follows
the route. Controlled replays must additionally record actual first reads,
repeated reads, route decisions, safety stops and relevant evidence. Unknown
project data and runtime-dependent proof should be measured separately rather
than filled with a fabricated full-lifecycle estimate.
