---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-08-05"
created_at: "2026-08-05 17:45:00 UTC"
updated: "2026-08-05"
updated_at: "2026-08-05 18:05:00 UTC"
status: reviewed
source_skill: 103-sg-verify
scope: "runtime-installer-and-skill-distribution-separation"
owner: "Diane"
proof_profile: "automated -> structural -> manual runtime"
stack_profile: "shell, Git sparse-checkout, Codex plugin"
target_scope: "runtime-installer-and-skill-distribution-separation"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "install-shipglows.sh"
  - "cli/install.sh"
  - "plugins/shipglows/"
  - ".opencode/skills/shipglows/"
  - ".agents/skills/shipglows/"
depends_on:
  - artifact: "shipglows_data/workflow/specs/runtime-installer-and-skill-distribution-separation.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "2026-08-05 automated installer regression passes 41/41."
  - "2026-08-05 plugin manifest validation and public skill-sync checks pass."
next_step: "Synchronize the separate public website bootstrap before advertising its endpoint."
---

# Manual Test Checklist: Runtime Installer and Skill Distribution Separation

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RID-001 | runtime bootstrap | A clean non-root user runs the default public bootstrap. | yes | Sparse checkout contains runtime paths only; it reports `runtime` and does not create Claude/Codex skill links. | PASS | 2026-08-05 18:05:00 UTC | Disposable local-origin bootstrap proof. | Runtime checkout contained `cli`, `local`, `tui`, `.claude` and excluded `skills`, `shipglows_data`, `.opencode`. | |
| RID-002 | corpus bootstrap | A clean user selects `SHIPGLOWS_INSTALL_SURFACE=corpus`. | yes | Public skills and OpenCode/KiloCode-compatible shims are available; no private repository data appears. | PASS | 2026-08-05 18:05:00 UTC | Disposable local-origin bootstrap proof. | Corpus checkout exposed public skills and both compatible shims; private-data CLI module was absent. | |
| RID-003 | Codex plugin | A Codex user follows the marketplace route without a ShipGlows source checkout. | yes | Plugin installs and routes ShipGlows without creating a runtime/corpus clone. | PASS | 2026-08-05 18:05:00 UTC | Isolated `CODEX_HOME` marketplace + plugin installation. | `shipglows@shipglows` installed and enabled; temporary-home alias warning is expected and does not affect plugin state. | |
| RID-004 | existing checkout | A modified existing Git checkout is rerun with a different surface. | yes | Local changes are preserved and the installer gives a safe recovery path. | PASS | 2026-08-05 18:05:00 UTC | Disposable checkout surface-upgrade proof. | The corpus upgrade completed after stashing the injected local edit. | |
