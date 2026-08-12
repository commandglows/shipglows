---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 105-sg-check
scope: check-repair-and-report
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: no
linked_systems:
  - skills/105-sg-check/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave-2 compaction extracted bounded repair and proof-gap reporting from the activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Check Repair and Report Playbook

Load this reference only after a failure, blocker, material coverage gap, or hosted-proof requirement appears.

## Repair loop

For authorized `fix` mode, read the error, inspect the failing source, repair the root cause, and rerun the failed check. Repeat at most three times. Preserve the intended guardrail and surface every risky assumption. In `nofix`, do not edit anything.

If the third cycle fails, stop and provide the failing command, concise evidence, affected surface, likely owner, and safest next action under the actionable failure contract.

## Coverage and hosted proof

Call out missing tests, typechecks, lint, builds, runtime/integration coverage, partial dependency evidence, and warnings with plausible product or security impact.

For `vercel-preview-push`, local results are pre-push confidence only. For `hybrid`, distinguish local/static evidence from hosted behavior. Use preview proof routing and hand off through `005-sg-ship -> 405-sg-prod`, followed by the appropriate browser, auth, or manual-flow owner.

## Report

List the target, mode, checks executed, results, repairs, remaining failures, and `Risky assumptions / gaps`. State explicitly what was not proven. A green build must never be upgraded into evidence that login, checkout, sync, permissions, or another main user flow works end to end.
