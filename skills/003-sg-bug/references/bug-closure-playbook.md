---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 003-sg-bug
scope: bug-closure-and-ship-gates
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: no
linked_systems:
  - skills/003-sg-bug/SKILL.md
  - skills/005-sg-ship/SKILL.md
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "1.11.0"
    required_status: active
supersedes: []
evidence:
  - "Wave-2 compaction extracted detailed closure, ship, evidence-storage, and handoff procedures."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Bug Closure Playbook

Load this playbook only for verify, ship, close, or detailed closure-risk reporting. Read the durable bug file first. Do not load another local `003-sg-bug` playbook before the first closure action.

## Ship Gate

1. Read the bug file and optional index.
2. Block clean shipping for a high/critical bug unless its state is `fixed-pending-verify`, `closed`, `duplicate`, or `wontfix`.
3. For `fixed-pending-verify`, route to `103-sg-verify` before shipping.
4. For `closed`, `duplicate`, or `wontfix`, route to `005-sg-ship` only when code scope is bounded and other ship gates pass.
5. Explicit partial-risk acceptance may route to ship with a visible risk note, but never upgrades bug closure.

## Closure Gate

- `closed` requires passing evidence in `Retest History` and a verification-compatible state.
- `closed-without-retest` requires a visible reason, residual risk, and operator-facing exception wording.
- Otherwise route to retest or verification; do not infer closure from code, checks, deployment, or intent.

For a visual bug, retain the activation contract's rendered-human-validation gate even when all technical checks pass.

## Evidence Storage

- Keep `TEST_LOG.md` and optional `BUGS.md` compact.
- Keep full durable detail in `shipglows_data/workflow/bugs/BUG-ID.md` through the phase owner.
- Store only redacted large evidence under `test-evidence/BUG-ID/`.
- Reject paths escaping the repository and never preserve sensitive payloads.

## Reporting

Load the shared reporting contract. User mode reports observable status, compact proof, and material residual risk without exposing internal routes. Agent mode may include the bug identifier, record, development mode, proof path, redacted evidence, security posture, lifecycle state, owner route, remaining proof, and exact next command.

If closure is blocked, state the missing proof and safe recovery choice. If future non-trivial work emerges, apply the shared chantier-potential threshold rather than opening an unrelated chantier silently.
