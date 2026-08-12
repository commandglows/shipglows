---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 003-sg-bug
scope: bug-state-routing
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: no
linked_systems:
  - skills/003-sg-bug/SKILL.md
  - shipglows_data/workflow/bugs
depends_on:
  - artifact: skills/references/master-workflow-lifecycle.md
    artifact_version: "1.4.1"
    required_status: active
supersedes: []
evidence:
  - "Wave-2 compaction extracted detailed bug-file and state procedures from the activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Bug State Routing

Load this playbook only when selecting a bug, reconciling its durable record, or interpreting lifecycle state. Load the shared master workflow lifecycle first. Do not load another local `003-sg-bug` playbook before the first state action.

## Load The Durable State

When a BUG-ID is present:

1. Open `shipglows_data/workflow/bugs/BUG-ID.md` before interpreting status.
2. Read `shipglows_data/workflow/BUGS.md` only when present and only as secondary triage context.
3. Extract title, status, severity, next step, reproduction, expected/observed behavior, redaction state, diagnosis, fix attempts, retest history, and linked spec/task/commit/release.
4. Prefer the bug file when the index disagrees, report the inconsistency, and choose the safest next action.

If the index points to a missing bug file, treat it as `needs-info`; continue to evidence or repair only when the remaining context makes that safe. If the bug file exists without an index row, report the optional index gap but continue when frontmatter and status are usable.

## State Matrix

| State | Next safe action |
| --- | --- |
| `open` | Diagnose through `106-sg-fix`, or gather evidence first when reproduction is weak. |
| `needs-info` | Gather agent-accessible context, then ask only for the missing operator-owned fact. |
| `needs-repro` | Route to `107-sg-test`, `108-sg-browser`, or `109-sg-auth-debug` according to the proof gap. |
| `in-diagnosis` | Continue through `106-sg-fix` unless another owner is already active. |
| `fix-attempted` | Route to `107-sg-test --retest`; do not verify or ship clean. |
| `fixed-pending-verify` | Route to `103-sg-verify`. |
| `closed` | Take no action unless investigating regression or release notes. |
| `closed-without-retest` | Expose residual risk and retest when closure confidence matters. |
| `duplicate` | Route to the canonical bug; never fork work. |
| `wontfix` | Preserve the decision unless the product decision changes. |

Critical and high severity block clean shipping until the activation contract's allowed state gate is satisfied. Medium and low severity may proceed only with explicit partial-risk wording.

## Selection Pressure Cases

- Empty invocation with several bugs: choose only the highest-priority safe one; do not silently create a multi-bug execution batch.
- Multiple explicit BUG-IDs: ask which one to handle first unless the request is an explicitly read-only dashboard.
- Repeated fix attempts without root-cause evidence: route to deeper diagnosis, not another speculative patch.
- Dominant work is maintenance, a feature, or a bounded release: leave this lifecycle and route to the matching master.
