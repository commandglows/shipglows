---
artifact: manual_test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-08-05"
created_at: "2026-08-05 17:45:00 UTC"
updated: "2026-08-20"
updated_at: "2026-08-20 17:11:29 UTC"
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
depends_on:
  - artifact: "shipglows_data/workflow/specs/runtime-installer-and-skill-distribution-separation.md"
    artifact_version: "1.0.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "2026-08-05 automated installer regression passes 41/41."
  - "2026-08-05 plugin manifest validation and public skill-sync checks pass."
  - "2026-08-20 channel contract requires one Codex router: linked developer corpus or public plugin, never both."
  - "2026-08-20 contributor channel regression covers plugin install, linked clone transition, managed unlink, personal-skill preservation, idempotence, and another-clone refusal."
next_step: "Synchronize the separate public website bootstrap before advertising its endpoint."
---

# Manual Test Checklist: Runtime Installer and Skill Distribution Separation

| Scenario ID | Surface | Scenario | Required | Expected | Status | Observed | Evidence pointer | Notes | Bug Link |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| RID-001 | runtime bootstrap | A clean non-root user runs the default public bootstrap. | yes | Sparse checkout contains runtime paths only; it reports `runtime` and does not create Claude/Codex skill links. | PASS | 2026-08-05 18:05:00 UTC | Disposable local-origin bootstrap proof. | Runtime checkout contained `cli`, `local`, `tui`, `.claude` and excluded `skills`, `shipglows_data`, `.opencode`. | |
| RID-002 | corpus bootstrap | A clean user selects `SHIPGLOWS_INSTALL_SURFACE=corpus`. | yes | Public skills and the dedicated OpenCode shim are available; no duplicate repository-level Codex router or private repository data appears. | PASS | 2026-08-20 17:11:29 UTC | Bootstrap selection 55/55 plus repository entrypoint contract. | Corpus selection remains complete while the generic Codex-discoverable repository shim is absent. | |
| RID-005 | Codex entrypoint channels | A developer links the corpus while the ShipGlows plugin is enabled, or explicitly selects the plugin channel. | yes | Mixed ownership fails closed; plugin mode removes only the managed router link; linked mode becomes valid after the plugin is removed. | PASS | 2026-08-20 17:11:29 UTC | Runtime sync regression plus live Codex profile smoke. | Conflict scenario passed; live profile reports plugin not installed and linked public catalog 14/14. | |
| RID-006 | Contributor CLI | A contributor runs `shipglows skills status`, `link`, and `unlink` around a complete clone. | yes | Transitions are idempotent, another clone is never replaced, personal skills remain untouched, plugin restoration is explicit, and an unwritable catalogue fails before mutation. | PASS | 2026-08-20 | Dedicated skills-channel regression. | Plugin → linked → none → plugin passed; foreign clone refusal and permission preflight preserved their original targets. | |
| RID-003 | Codex plugin | A Codex user follows the marketplace route without a ShipGlows source checkout. | yes | Plugin installs and routes ShipGlows without creating a runtime/corpus clone. | PASS | 2026-08-05 18:05:00 UTC | Isolated `CODEX_HOME` marketplace + plugin installation. | `shipglows@shipglows` installed and enabled; temporary-home alias warning is expected and does not affect plugin state. | |
| RID-004 | existing checkout | A modified existing Git checkout is rerun with a different surface. | yes | Local changes are preserved and the installer gives a safe recovery path. | PASS | 2026-08-05 18:05:00 UTC | Disposable checkout surface-upgrade proof. | The corpus upgrade completed after stashing the injected local edit. | |
