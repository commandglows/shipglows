---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-06"
updated: "2026-09-06"
status: active
source_skill: 900-shipglows-core
scope: agent-path-replay
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems: [tools/skill_activation_budget.py]
depends_on: []
supersedes: []
evidence: [shipglows_data/workflow/audits/2026-09-05-proportionate-reporting.md]
next_step: none
---

# Replay an agent path

Use only when testing or optimizing an instruction path. Core owns this protocol;
ordinary skill execution does not load it. `skills/references/skill-context-budget.md`
retains authority for quality, required reads and budget arbitration.

## Prepare

1. Copy one case from `tools/fixtures/agent_path_replay_cases.json`. Freeze the exact
   user prompt, expected action, prohibited actions, fixture contents, checkpoint,
   and source byte hashes. Include entry, routing and reporting instructions.
2. Record agent/model settings, initial context, host, tool inventory and run ID.
   Before/after runs use the same conditions and fixture reset. Different conditions
   remain explicit limitations. Freeze each variant before running; do not edit
   instructions during a replay. Baseline is a frozen working tree, not just HEAD.
3. Use a disposable project with unrelated records/custom fields to preserve.
   Simulate a failed write at the fixture/tool boundary; never change real machine
   permissions or services to create a failure. Never run Android, Git or production
   actions for the planning cases. A closure case uses a disposable technical task
   with real focused evidence, not an invented success result.

## Replay and observe

Start a fresh agent for each independent case. Supply the task and fixture context,
not expected read counts or the desired answer. Keep evaluator expectations separate.
For the duplicate case only, repeat in the same context and label it as a warm run.
If agent delegation is unavailable, preserve a standalone replay prompt and report
the behavioral proof pending; deterministic tests are not a fresh-agent replay.

Capture the first response verbatim, actions, questions, writes, errors and tool-read
events in order. Record full/partial/truncated extent and actual delivered character
count when available; otherwise use null. Count only attributable source text, not
requested output limits or the original size of a truncated result. Split combined
outputs only when attribution is reliable. Keep unattributable tool output separately.
Do not repair the first response retrospectively. Do not store secrets or raw private
content; sanitize paths and retain hashes/counts rather than copied source bodies.

## Measure

Use `tools/fixtures/agent_path_trace_v2.example.json` as a shape example, replacing its
placeholder hash with SHA256 of source bytes at the time of the read. Trace paths are
relative to the measured root. `audit_trace(trace, root=frozen_root)` supports a frozen
checkout; the CLI uses its own repository root. Source drift invalidates measurement.

```bash
python tools/skill_activation_budget.py --scenario planning-task-capture --trace observed.json --format json
python -m unittest tools.test_observed_skill_trace tools.test_skill_activation_budget
```

V1 (no version or version 1) preserves the existing full-file current-source estimate.
V2 requires `extent`, `source_sha256` and explicit `delivered_characters` on each event.
Null means unknown, including a full read with unavailable telemetry. Known counts
are divided by four and rounded up per event. The output gives `known_tokens` and a
null `total_tokens` when any event is unmeasured or invalid. `measurement_status`
must be checked: CLI structural success does not imply complete measurement.

V2 does not invent unique/repeated token counts for overlapping partial reads. It
reports repeated-path events instead. A complete measurement means supplied counts
are available, not independent authentication or complete instruction coverage.
Keep prompts, project evidence, tool overhead, duration and provider usage separate.
Never generate observed events from the registry's declared reads.

## Judge and retain

Check behavior first: expected action, prohibited effects, evidence, preserved data,
appropriate question/confirmation/closure. Independently review required-read coverage
against source instructions. Then compare declared and observed costs separately.
Unknown traffic is a gap, never a saving. Changed requirements need explicit approval
and their own comparison label; never move a checkpoint to improve a percentage.

Save one sanitized run record per variant under `shipglows_data/workflow/reviews/`:
case ID, prompt, conditions, source hashes, trace, exact response, fixture hashes,
behavior verdict, measurement verdict and limitations. An audit links the pair and
reports before/after totals only where comparable. Keep historical failed trials.
Tests protect known accounting and decision boundaries; they do not certify arbitrary
agent behavior. No budget improvement compensates for a lost safeguard.
