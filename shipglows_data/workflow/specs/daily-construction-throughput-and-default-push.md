---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-17"
created_at: "2026-08-17 20:01:00 UTC"
updated: "2026-08-17"
updated_at: "2026-08-17 20:01:00 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: GPT-5 Codex
scope: daily-construction-throughput-and-default-push
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/master-workflow-lifecycle-core.md
  - skills/references/master-workflow-lifecycle.md
  - skills/005-sg-ship/
  - skills/104-sg-end/
  - skills/900-shipglows-core/references/skill-maintenance-playbook.md
  - tools/test_daily_construction_contract.py
depends_on: []
supersedes: []
evidence:
  - "Operator correction 2026-08-17: completed clean daily work should be committed and pushed by default instead of accumulating locally."
  - "Operator correction 2026-08-17: daily construction should use zero or one focused check when sufficient; broad suites belong to release, health, security, migration, or explicit audit work."
next_step: "Implement, run the focused contract proof, commit, and push main."
---

# Daily construction throughput and default push

## User story

As a solo operator building MVPs, I want ShipGlows to spend daily effort on construction, record coherent work promptly, and push completed clean chantiers so validated work does not remain hidden on one machine.

## Contract

- A completed clean daily chantier proceeds to bounded commit and push by default.
- The push is included in the chantier approval plan as soon as it is a known intended outcome; the remote mutation gate remains explicit, but it must not be forgotten or deferred by habit.
- Low-risk localized work may use no automated check when no focused check provides meaningful signal.
- Behavior changes normally use one narrow regression or contract check.
- Full suites, broad lint/typecheck/build bundles, skill audits, budget audits, health audits, and security audits are not daily defaults.
- Broader proof is reserved for release preparation, explicit audit requests, security/data/auth/payment/destructive boundaries, dependency or platform migrations, broad shared-runtime changes, or evidence that the narrow proof is insufficient.
- Failed attempted checks remain blocking unless risk-accepted explicitly. Skipping irrelevant broad checks is not a failure.
- Unrelated dirty files remain excluded unless the operator explicitly includes them.

## Acceptance criteria

1. Shared lifecycle doctrine names bounded commit and push as the default terminal route for clean completed daily work.
2. Closure exposes an unpushed clean chantier as delivery pending rather than silently complete.
3. Quick ship defaults to zero or one focused check and forbids full suites without a material trigger.
4. Core skill maintenance no longer mandates refresh, global audit, budget audit, metadata lint, and broad suites for every bounded daily repair.
5. Release, health, security, migration, and explicit audit workflows retain stronger proof.
6. One focused contract test mechanically protects the policy.
7. The change is committed separately from pre-existing documentation and pushed to `origin/main` without force.

## Non-goals

- Removing secret checks, staged-diff review, approval for remote push, or failure stops.
- Claiming production readiness from a commit, push, or narrow test.
- Weakening high-risk or release validation.

## Proof

Run only `python -m unittest tools.test_daily_construction_contract tools.test_900_shipglows_core_contract`, inspect the staged diff, and perform a bounded secret-pattern check. Do not run the complete ShipGlows or Windows suites for this chantier.
