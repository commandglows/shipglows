---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "3.3.1"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-14"
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
  - tests/install/playwright-mcp-contract.sh
  - tools/test_108_sg_browser_compaction_contract.py
depends_on: []
supersedes: []
evidence:
  - "607 repository unit tests pass with declared test dependencies; 5 environment-specific tests are skipped."
  - "A live current-turn lookup found mcp__playwright__browser_tabs only through the deferred catalog and its read-only list probe succeeded."
  - "Windows and Linux Playwright installer contracts pass; the Windows PowerShell parser reports no errors."
  - "Documentation topology is compliant; README, installer scope, Windows operator guide, runtime, lifecycle, spec, and checklist metadata pass."
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
| RA-07 | Tool boundary | Configured Playwright absent from direct and deferred current-turn discovery is reported as configured but not exposed. |
| RA-08 | Windows project discovery | Direct and nested apps resolve from native manifests with no Flox-specific code or environment injection. |
| RA-09 | Python bootstrap | `uv python install --default` publishes functional `python` and `python3`; failure blocks installer readiness. |
| RA-10 | Agent Python awareness | Global `environment.md` reports the detected version, `uv` manager, and both commands without a hardcoded Python version. |
| RA-11 | Playwright evidence | Global `environment.md` reports Chromium installation/path, MCP configuration/path, and Codex verification. |
| RA-12 | Capability boundary | Context reports installed/configured/discovered/callable/failed/not-exposed independently and never infers absence from the first visible list. |
| RA-13 | Deferred discovery | Playwright absent from the first visible list but present as `mcp__playwright__*` in `ALL_TOOLS`, `tool_search`, or equivalent is discovered rather than reported unavailable. |
| RA-14 | Safe capability probe | A discovered Playwright surface becomes `callable` only after a read-only probe or requested call succeeds. |
| RA-15 | Configured but undiscovered | Installed and configured Playwright absent from direct and deferred catalogs is reported `not exposed`, not absent or broken. |
| RA-16 | Discovered call failure | A failed safe probe is reported `failed` with its exact runtime cause, without downgrading installation/configuration truth. |
| RA-17 | Cross-platform persistence | Windows and Linux installers keep Playwright MCP enabled globally for future sessions. |
| RA-18 | Lane ownership | Playwright MCP remains default for web QA; optional `playwright-interactive` failure cannot block it. |
| RA-19 | Native result shape | Successful Playwright installation returns exactly one structured result with installation, configuration, verification, config-path, and Chromium-path evidence. |
| MA-01 | Initial imperative | Agent proposes `🧭 PLAN À VALIDER` and performs no mutation. |
| MA-02 | Post-plan approval | Agent executes only the approved scope and proofs. |
| MA-03 | Material change | Agent stops and requests approval of a replacement plan. |
| MA-04 | Micro-edit or server action | The compact plan gate still applies. |
