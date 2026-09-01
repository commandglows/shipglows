---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-21"
updated: "2026-09-01"
status: active
source_skill: 900-shipglows-core
scope: lightweight-git-persistence-preflight
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/git-milestone-delivery-contract.md
  - skills/references/project-delivery-policy.md
  - skills/102-sg-start/SKILL.md
  - skills/706-continue/SKILL.md
  - skills/104-sg-end/SKILL.md
depends_on:
  - artifact: skills/references/git-milestone-delivery-contract.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator correction 2026-09-01: Git preflight resolves delivery posture from canonical business context and asks a product question when it is missing."
  - "Operator decision 2026-08-21: protect work at mutating start and resume without adding a visible step when Git state is healthy."
next_review: "2026-11-21"
next_step: /103-sg-verify lightweight-git-persistence-preflight
---

# Lightweight Git Persistence Preflight

## Purpose

Detect work that exists only on the current machine before ShipGlows adds more risk. This is a read-only inspection embedded in existing lifecycle boundaries, not a new operator workflow.

## Activation Boundaries

Run once at each applicable boundary:

- before the first write of a mutating chantier;
- when resuming an interrupted mutating chantier;
- immediately before an auth, payment, permission, migration, destructive, tenant, secret, production, or private-data mutation;
- before closure classification.

Skip for direct answers, read-only audits, non-Git work, and repeated writes inside the same unchanged boundary. Do not rerun before every file edit.

## Read-Only Inspection

Resolve the exact repository, current branch, configured upstream, local `HEAD`, locally observed ahead/behind relation, tracked and untracked changes, staged paths, and the active chantier's owned paths. Run the read-only resolver from `project-delivery-policy.md`; use only canonical business `delivery_posture` to derive the intended integration branch. Inspect recent chantier/spec evidence only as needed to distinguish current, inherited, and unrelated work.

Do not fetch, push, switch branches, stage, stash, reset, clean, merge, or mutate provider settings during the preflight. Remote freshness beyond locally observed refs requires separate read-only remote evidence; never invent it.

## Persistence States

- `local`: chantier-owned changes are uncommitted, or a chantier-owned commit is not proven reachable from the resolved upstream.
- `backed up`: the relevant chantier commit is proven reachable from the resolved upstream.
- `deployed`: the intended commit is confirmed by authoritative hosting/provider evidence on the named preview, staging, or production target.

These states are cumulative but never interchangeable. A commit is not automatically backed up. A push proves remote persistence, not deployment. A reachable URL without matching commit/provider evidence does not prove deployment.

## Silent Healthy Path

When repository, branch, upstream, ownership, and persistence are coherent, continue without a question, confirmation, visible preflight card, or extra operator step. Reuse the evidence in the next normal report only when persistence materially affects trust.

## Actionable Findings

- Current chantier changes or commits exist only locally: use the already approved milestone/final delivery authority when applicable; otherwise expose the exact delivery decision before remote mutation.
- Canonical `delivery_posture` is missing or invalid: do not infer an integration branch; ask one product-status question, persist the answer to canonical business context under its bounded capture authority, then resume the preflight automatically.
- Inherited changes are clearly unrelated and non-overlapping: preserve them unstaged, record the exclusion internally, and continue.
- Inherited changes overlap the intended write set or ownership is unknown: stop before writing and ask one ownership question.
- Upstream is missing, ambiguous, unexpected, diverged, or points to the wrong remote: do not guess or push; report branch and expected recovery action.
- The previous interruption left a resolved chantier: state the last proven upstream commit, remaining local work, last proof, and next expected outcome, then continue when authority already covers it.

Do not convert every finding into a question. Ask only when ownership, remote target, or authority cannot be resolved safely from evidence.

## Sensitive Recovery Point

Before sensitive mutation, require the relevant pre-change baseline to be `backed up`. If owned changes form a coherent validated checkpoint, commit and push them through the approved milestone path. If they are incomplete, failing, secret-bearing, ambiguous, or outside authority, stop rather than manufacturing a recovery commit or absorbing unrelated work.

## Reporting

When persistence affects trust, use one compact line:

```text
📦 PERSISTANCE
✅ Local · ✅ Git distant · ➖ Déployé
```

Report only states supported by evidence. Omit this additional block on the healthy silent path when the ordinary delivery line already communicates the same truth. `🧭 SUITE` names the exact recovery outcome for any non-terminal state.

## Pressure Scenarios

- `GPP-HEALTHY-SILENT`: healthy backed-up state adds no question, receipt, or manual step.
- `GPP-START-LOCAL-AHEAD`: local-only commits are detected before the first new write.
- `GPP-RESUME-INTERRUPTED`: interruption recovery states upstream commit, local remainder, proof, and next outcome.
- `GPP-UNRELATED-DIRTY`: non-overlapping unrelated changes remain unstaged without blocking.
- `GPP-WRONG-REMOTE`: ambiguous or unexpected remote stops push and forbids guessing.
- `GPP-SENSITIVE-RECOVERY-POINT`: sensitive mutation requires a backed-up baseline.
- `GPP-STATE-SEPARATION`: local, backed up, and deployed require distinct evidence.
