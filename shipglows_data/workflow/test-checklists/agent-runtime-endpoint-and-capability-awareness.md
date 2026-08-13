---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "3.1.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness-and-mutation-approval
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/specs/agent-runtime-endpoint-and-capability-awareness.md
  - tests/windows/static-development-environment.ps1
depends_on: []
supersedes: []
evidence:
  - "PowerShell parser checks pass for module, launcher, installer, and focused regression test."
  - "tests/windows/static-development-environment.ps1 passes project-document preservation, idempotence, durable URL, legacy cleanup, runtime context, and approval-contract scenarios."
  - "tests/windows/devserver-contract.sh passes under Git Bash."
  - "Focused skill unit tests, execution-fidelity audit, budget audit, metadata lint, invocation graph, and git diff check pass."
  - "Windows Flox removal is covered by static absence checks and native nested-manifest discovery."
next_step: "/103-sg-verify runtime awareness and mutation approval"
---

# Runtime Awareness And Mutation Approval Checklist

| ID | Scenario | Expected |
| --- | --- | --- |
| RA-01 | Full installer | Global `environment.md` records Windows, PowerShell, Codex and Playwright facts. |
| RA-02 | Register project | Visible `ENVIRONMENT.md` exists and preserves pre-existing content. |
| RA-03 | Assign port | Project document contains `http://127.0.0.1:3002`. |
| RA-04 | Start or stop | Registry status changes without rewriting the durable project document. |
| RA-05 | Legacy migration | Only ShipGlows-managed `server.env` and its exact Git exclude entry are removed. |
| RA-06 | Context mode | Global file, project file and registry are read without mutation or fallback to `4321`. |
| RA-07 | Tool boundary | Configured Playwright without a current tool is reported as configured but not exposed. |
| RA-08 | Windows project discovery | Direct and nested apps resolve from native manifests with no Flox-specific code or environment injection. |
| MA-01 | Initial imperative | Agent proposes `🧭 PLAN À VALIDER` and performs no mutation. |
| MA-02 | Post-plan approval | Agent executes only the approved scope and proofs. |
| MA-03 | Material change | Agent stops and requests approval of a replacement plan. |
| MA-04 | Micro-edit or server action | The compact plan gate still applies. |
