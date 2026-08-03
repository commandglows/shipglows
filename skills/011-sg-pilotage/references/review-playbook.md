---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-03"
status: active
source_skill: 011-sg-pilotage
scope: pilotage-review-mode
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/011-sg-pilotage/SKILL.md
  - shipglows_data/workflow/reviews/
  - shipglows_data/workflow/TASKS.md
  - CHANGELOG.md
depends_on:
  - artifact: skills/references/product-decision-chain.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Transferred from 703-sg-review under the approved pilotage consolidation."
next_step: "$011-sg-pilotage review weekly"
---

# Review Mode Playbook

## Outcome

Reconstruct what changed, what is proven, what remains open, and what the next session should pick up. A review is an evidence-based retrospective and closure aid, not verification or a truth machine.

## Scope Grammar

- `review daily`: last 24 hours.
- `review weekly`: last 7 days.
- `review sprint`: the declared sprint or approximately two weeks when the project uses that cadence.
- `review release`: changes since the last release boundary.
- bare `review`: load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and ask for exactly one scope.

## Evidence Model

Inspect the minimum relevant task tracker, commits, diff, tests, proof artifacts, docs, changelog, releases, and deployment evidence. Reconstruct the intended outcome where possible and classify claims explicitly:

- `activity`: files, commits, or notes changed;
- `implemented`: the planned local change exists and implementation checks passed;
- `verified`: the required conformity or behavior proof passed;
- `assumed`: a plausible claim without sufficient evidence.

A commit, merge, build, changelog entry, or deployment is activity evidence and may support implementation; none proves the user outcome alone. This mode does not replace verification by `103-sg-verify` and must not report assumed behavior as verified.

When capturing product lessons, decision changes, rework, failed proof, or coherence drift, load `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md`. Record only evidence-backed lessons with causal status, applicability boundary, keep/change/retire decision, and a future proof hook.

## Review Artifact

Write the canonical metadata-bearing review artifact to `shipglows_data/workflow/reviews/REVIEW-YYYY-MM-DD.md` when the project uses the ShipGlows corpus. Include at least:

```yaml
---
artifact: review
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "<project>"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
status: "draft|reviewed|partial"
source_skill: 011-sg-pilotage
scope: "daily|weekly|sprint|release"
user_story: "<outcome or unknown>"
confidence: "high|medium|low"
risk_level: "low|medium|high"
security_impact: "none|yes|unknown"
docs_impact: "none|yes|unknown"
evidence: []
next_step: "<owner route>"
---
```

Summarize outcome, completed, in progress, blocked, learned, risks, documentation coherence, metrics, and one to three next candidates. Do not expose secrets, private payloads, or raw sensitive logs.

## Bounded Writes

- Update `shipglows_data/workflow/TASKS.md` only when review evidence justifies a precise state change.
- Update `CHANGELOG.md` only for user-visible changes supported by evidence, never merely because a review occurred.
- Before either write, load the required shared format, authoritatively re-read the target, apply the smallest possible patch, recompute once if its anchor moved, and stop if ambiguity remains.
- Preserve partial work as `in_progress` with the missing proof rather than marking it done.

## Output And Boundaries

Report evidence limits, review-artifact path, tracker/changelog mutations, stale documentation, risks, and next-session candidates. Route current ranking to `priorities`, deferred capture to `backlog`, execution to `706-continue` or `102-sg-start`, proof to `103-sg-verify`, and closure to `104-sg-end`. Review does not replace verification, execute work, or silently prioritize active tasks.
