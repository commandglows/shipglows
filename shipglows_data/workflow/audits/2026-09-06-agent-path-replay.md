---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-06"
updated: "2026-09-06"
status: active
source_skill: 900-shipglows-core
scope: agent-path-replay-tooling
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems: [tools/skill_activation_budget.py]
depends_on: []
supersedes: []
evidence:
  - tools/test_observed_skill_trace.py
  - shipglows_data/workflow/playbooks/agent-path-replay.md
  - tools/fixtures/agent_path_replay_cases.json
next_step: "Use the protocol for the next scoped path audit; no autonomous execution is scheduled."
---

# Agent-path replay preservation

The operator approved preserving the workflow and adding faithful partial/truncated
read accounting. The bounded implementation adds a cold Core playbook, five evaluator
cases, a V2 trace shape example and additive V2 measurement to the existing evaluator.
It creates no new public skill, scheduled runner, provider integration or publication.

The pressure case is a truncated read with unknown delivered size followed by a
partial reread. Full-file sizing would overstate the first event; counting unknown
traffic as zero would understate it. V2 preserves a known subtotal and null total,
checks source hashes and reports repeated paths without inventing text overlap.
V1 full-file trace accounting remains unchanged. Neither format captures provider
telemetry automatically, proves complete read coverage or measures financial savings.

Validation: 32 focused tests passed across observed trace, activation budget and
progressive-loading pilot suites. A synthetic CLI V2 trial returned structurally
valid but incomplete measurement with null total as intended. All 16 declared
scenario budgets passed. Changed-reference estimate: 2,245 to 2,244 tokens against
the unchanged pre-edit HEAD source. The playbook is loaded only for replay/measurement;
ordinary runtime paths gain no eager dependency. Existing ceilings were unchanged.

The five cases are reusable evaluator specifications, not five newly executed
behavioral trials. Earlier fresh-agent evidence remains in the September 5 audits.
Before/after replay sources must now stay frozen for the duration of each variant.

Documentation: the mapped skill-context-budget reference links the protocol and
describes V1/V2 semantics. Editorial: no public promise or article changed.
Fresh docs: not needed for this local standard-library implementation.
Independent read-only review found no blockers. Its optional strict-version input
check was added with regression coverage; absent-version V1 stays compatible.
Changes remain local; no commit or push performed for this addition.
