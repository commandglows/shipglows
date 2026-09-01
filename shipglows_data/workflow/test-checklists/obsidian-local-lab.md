---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-02"
updated: "2026-09-02"
status: active
source_skill: 102-sg-start
scope: obsidian-local-lab
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: no
linked_systems:
  - shipglows_data/workflow/specs/shipglows-obsidian-local-lab.md
depends_on: []
supersedes: []
evidence:
  - "Checklist follows the ready local Lab contract."
next_step: none
---

# Obsidian Local Lab Checklist

- Record hashes of `%APPDATA%\obsidian\obsidian.json`, `%APPDATA%\obsidian\Local State`, and the selected personal vault before the run.
- Run the built plugin with `-Headless -Json`, one representative `-InteractionCommand`, and `-Screenshot`.
- Confirm `artifact=passed`, `hostLoad=passed`, the expected plugin identity/version, and registered commands.
- Confirm interaction and diagnostics independently; preserve reported plugin errors.
- Confirm the screenshot shows the expected plugin surface.
- Confirm no Lab-owned Obsidian processes remain and the disposable run directory was removed.
- Recompute personal hashes and confirm no personal vault/profile mutation.
- Run Chrome Extension Lab, Obsidian start, monorepo detection, packaging, and capability regression tests.
