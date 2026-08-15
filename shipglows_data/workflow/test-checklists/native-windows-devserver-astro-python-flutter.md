---
artifact: test_checklist
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-15"
updated: "2026-08-15"
status: active
source_skill: 900-shipglows-core
scope: native-windows-devserver-project-catalog
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/shipglows-devserver.ps1
  - tests/windows/devserver-project-catalog.ps1
  - shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
depends_on:
  - artifact: shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md
    artifact_version: "0.2.28"
    required_status: draft
supersedes: []
evidence:
  - "Regression-first project catalogue test failed on the missing Get-SgProjectCatalog command before implementation."
  - "The Windows static contract and isolated catalogue fixtures passed on 2026-08-15."
  - "Final five-run workspace benchmark medians passed at 902.05 ms cold and 31.96 ms warm using temporary registry/index state."
next_step: "/103-sg-verify native Windows project catalogue on installed runtime after shipping"
---

# Native Windows DevServer project catalogue checklist

## Automated catalogue proof

- [x] Zero, one, many, and homonymous leaf-folder catalogues resolve deterministically.
- [x] One bounded linear scan discovers monorepo launch surfaces without rescanning descriptors at each boundary.
- [x] Canonical `launchPath` identity deduplicates root/launch entries across case and trailing-slash variants.
- [x] Workspace-relative `/` display names are unique; outside-workspace names remain canonical paths.
- [x] Navigation projects only `Name`; lifecycle menus retain action-relevant status, kind, and port fields.
- [x] Picker labels map to exact identities instead of selecting the first equal label.
- [x] A `package.json` without `scripts.dev`, including empty dependency blocks under StrictMode, is ignored.

## Cache and invalidation proof

- [x] In-process and fresh-module reads reuse the five-minute persistent index.
- [x] Refresh forces a rebuild; register and unregister invalidate memory and persistent state; clone uses the same invalidation API.
- [x] Schema, workspace, scanner-version, and exact TTL boundary mismatches rebuild the index.
- [x] Corrupt JSON and moved/deleted surfaces are rejected without becoming authoritative.
- [x] Concurrent forced writers leave one valid atomically replaced index.
- [x] Registry entries win discovery conflicts for status, port, logs, and process metadata.

## Performance and safety

- [x] Five cold scans: `894.72`, `920.59`, `942.56`, `894.90`, `902.05` ms; median `902.05` ms, target `<1000` ms.
- [x] Five warm reads: `31.96`, `31.96`, `31.81`, `31.80`, `36.09` ms; median `31.96` ms, target `<200` ms.
- [x] Fixtures and benchmark use temporary runtime, registry, logs, and project-index paths only.
- [x] No user server, installed runtime, live registry, install, bootstrap, commit, or push is part of this proof.
