---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-27"
updated: "2026-08-27"
status: active
source_skill: 900-shipglows-core
scope: managed-project-required-ci-policy
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-delivery-policy.md
  - skills/305-sg-init/SKILL.md
  - skills/010-sg-technical/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - tools/shipglows_required_gate.py
depends_on:
  - artifact: skills/references/project-delivery-policy.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "ContentGlows audit 2026-08-27 proved that directly requiring a path-filtered Android workflow can deadlock unrelated pull requests."
  - "The ShipGlows repository gate proves that an always-triggered stable status can report no-impact success while retaining full relevant proof."
next_review: "2026-11-27"
next_step: "/103-sg-verify managed-project required CI policy"
---

# Managed Project Required CI Policy

## Invariant

Every active ShipGlows-managed GitHub repository protects its production branch with one exact status identity: `ShipGlows required gate`. The workflow that owns this status runs on every pull request into the production branch, every push to that branch, and `workflow_dispatch`. Never put top-level `paths` or `paths-ignore` filters on this workflow.

Path selectivity belongs inside the workflow. Relevant lanes run their declared checks; irrelevant lanes report explicit no-impact success. Classification errors, unknown commands, and applicable check failures fail the terminal status. Stack-specific or deploy jobs may keep their own path filters, but branch protection never requires them directly.

## Proportional Project Contract

- Detect Node, Flutter, and Python roots from project manifests and lockfiles.
- Use only conventional validation commands that are present and non-destructive. A project with different commands declares them in `.shipglows/required-gate.json`.
- Keep generated CI least-privileged with `contents: read`, exact-revision checkout, pinned maintained actions, bounded timeout, no secrets, and no privileged pull-request event.
- Default the production branch to `main` only when the delivery policy does not declare another branch.
- Archived, non-GitHub, generated mirror, or intentionally unprotected repositories require an explicit documented exception and remain visible as non-compliant until that exception is reviewed.

The optional project declaration has this data-only shape:

```json
{
  "production_branch": "main",
  "lanes": [
    {
      "id": "site",
      "runtime": "node",
      "root": "site",
      "paths": ["site/**"],
      "commands": ["npm ci", "npm run check"]
    }
  ]
}
```

Lane IDs use lowercase letters, digits, and hyphens. Supported runtimes are `shell`, `node`, `flutter`, and `python`. Commands are explicit repository code and must not contain deployment, publication, secret retrieval, destructive filesystem operations, or provider mutation.

## Audit And Reconciliation

Run the Core-owned `tools/shipglows_required_gate.py` through the resolved `$SHIPGLOWS_ROOT`; for example, `python "$SHIPGLOWS_ROOT/tools/shipglows_required_gate.py" audit --project <path>`. Audit is local and read-only. It reports missing, drifted, unsupported, or compliant state. `generate` writes only the explicit workflow output after safe project inspection.

Provider inspection uses `ruleset-plan` and fresh GitHub API state. Provider mutation is never implicit: `ruleset-apply` requires its exact confirmation token, an explicit repository and ruleset ID, a locally compliant workflow, the workflow present on the production branch, and a successful exact `ShipGlows required gate` check on that branch. It preserves existing rules and adds missing pull-request, deletion, non-fast-forward, and required-status protections without requiring a human approval for the solo-maintainer default.

Install and prove the workflow before protecting it. A missing or unsuccessful status blocks reconciliation; never weaken existing protection to recover from a lockout.

## Pressure Scenarios

- `GATE-ALWAYS-ON`: the exact status appears for every protected change.
- `GATE-PATH-NO-DEADLOCK`: an unrelated path completes successfully without running an expensive lane.
- `GATE-FAIL-CLOSED`: classification and applicable command failures propagate.
- `GATE-INSTALL-BEFORE-PROTECT`: provider apply refuses an absent or unproven check.
- `GATE-RULESET-PRESERVE`: existing rules remain present and deletion/non-fast-forward protection cannot regress.
- `GATE-DRIFT`: local and provider divergence is actionable and never silently repaired.
