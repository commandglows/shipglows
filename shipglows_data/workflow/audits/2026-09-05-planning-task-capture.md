---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: planning-task-capture-pilot
owner: Diane
confidence: high
risk_level: low
security_impact: no
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - tools/test_planning_task_capture.py
  - tools/fixtures/planning_task_capture_baseline.json
  - skills/references/skill-invocation-registry.json
next_step: "Evaluate shared authority and reporting costs separately before extending this pilot."
---

# Planning task capture pilot

## Approved outcome

The user approved a scoped improvement to sg-planning: understand a supplied task,
reduce unnecessary reads, preserve safe capture, compare before/after, and defer
generalization to other skills. Original pressure case: record Android validation
on the Linux VM after commit and push. Recording does not execute that dependency.

Observed problem: the previous task-capture run loaded eight distinct files and
reported 13,661 tool-output tokens before some truncation. This is historical tool
output, not provider billing or a complete normative loading baseline.

System cause: the public wrapper required general outcome interpretation, the
engine required an explicit mode even for clear task intent, and the capture path
unconditionally loaded destination-selection and chantier-tracing procedures.
Overly broad agent reads also contributed to the historical run.

Prevention rule: select an existing tasks operation from clear supplied intent;
load authority, grammar, fresh-write proof and reporting, with richer procedures
only at an explicit decision boundary. Preserve ambiguous-project clarification,
editorial ownership, duplicate/status protection and explicit spec tracing.

Contract/tooling improvement: bounded branch in the existing owner and tasks
playbook, complete declared scenario and focused omission/regression checks.
No new public mode, shared authority rewrite, install or project task execution.

## Comparable measurement

Scenario: `planning-task-capture`, from public entry through saved-task report.
Assumptions: known project, existing tracker, supplied implementation task,
no equivalent/conflicting record or attached spec, no execution or status change.
Both sides exclude project evidence, environment, model reasoning and provider
telemetry. Costs use the existing ceil(characters/4) estimator, unique files once.

| Measure | Before | After |
| --- | ---: | ---: |
| Declared required skill/reference files | 14 | 10 |
| Estimated tokens | 28,718 | 22,025 |

Reduction: 6,693 estimated tokens, 23.3%. This is a declared path comparison,
not an observed billing reduction. The fixture freezes baseline hashes and
costs; its original first-write lower bound is retained and explicitly corrected
for functional excellence and reporting completeness after independent review.

Authority alone still costs 8,019 estimated tokens; reporting and its closure
references cost 7,253. Together they account for about 69% of the remaining path.
This pilot does not alter those shared protections or authorize their redesign.

## Proof and limits

- 19 focused tests pass: existing pilotage/discovery contracts plus three capture
  checks covering safety wording, required-read omission and eager-read regression.
- Scenario evaluator passes structural and budget checks. The explicit invocation
  checker accepts sg-planning tasks; changed documentation metadata passes.
- Discovery budget audit exits zero. Runtime link check: 30/30, no repair needed;
  installed sg-planning is linked to the changed canonical source.
- Independent prose review found and corrected baseline omissions, spec tracing,
  ambiguous-project fallback and first-directive reporting provenance.
- These automated checks detect known contract failures, not arbitrary agent
  behavior. An independent synthetic replay on a disposable tracker created one
  todo task with its commit/push dependency, asked no clarification, and performed
  no dependency execution. Repeating the request preserved the tracker SHA-256:
  `2b415bb454e64da8dc6c2cebf97a5a323a92475c68ed7c9640c1a4e9efa440be`.
- The replay initially read seven skill/reference files plus environment and
  tracker. It omitted three required closure/reflection references. Therefore it
  proves capture and dedupe, not full reporting compliance or a cheaper complete
  observed path. The declaration retains all ten required files; the agent was
  asked to finish the missing reporting checks without repeating the write.
  It then read the three omitted references and completed its report with the
  tracker hash unchanged. Corrected inventory: ten skill/reference files plus
  environment and tracker. The omission remains part of the initial evidence;
  later correction does not retroactively establish first-pass compliance.

Documentation: owner README and mapped runtime/lifecycle document updated.
Editorial: no existing public promise changed; no public content generated.
Changes are local; this pilot performed no commit or push. Other dirty work is
outside this scope and remains untouched.
