---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-13"
updated: "2026-10-20"
status: reviewed
source_skill: 300-sg-docs
scope: repository-history-archive
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/archives/
  - shipglows_data/technical/runtime-cli.md
  - docs/conversations/
depends_on: []
supersedes:
  - archive/README.md
evidence:
  - "300-sg-docs archive migration on 2026-07-13 classified every former root archive file before moving or deleting it."
next_step: "/103-sg-verify shipglows documentation governance cleanup phase 2"
---

# Repository History Archive

This directory preserves inactive repository history inside the canonical `shipglows_data/` governance corpus. Nothing here is current doctrine or an implementation source of truth.

## Removed History

The former `migration/`, `notes/`, `reports/`, and `root-documentation/` files were deleted on 2026-10-20 (`shipglows tidy` lot D1). Their durable content already lived in canonical docs; the files remain retrievable from Git history only.

Current runtime behavior belongs in `shipglows_data/technical/`. Current workflow contracts belong in `shipglows_data/workflow/`. Raw conversation captures belong in `docs/conversations/` when produced by the conversation-capture workflow.

## Migration Ledger

| Former surface | Final action | Reason |
| --- | --- | --- |
| `archive/MIGRATION_SUMMARY.md`, `archive/new-config.md`, `archive/plan_migration.md` | Preserved under `migration/`, deleted 2026-10-20 | Historical architecture and migration provenance; Git history only. |
| `archive/notes/OUTIL.md`, `archive/notes/devworkflow.md` | Preserved under `notes/`, deleted 2026-10-20 | Historical design and workflow inputs; Git history only. |
| Historical reports under `archive/reports/` | Preserved under `reports/`, deleted 2026-10-20 | Implementation and UX provenance; Git history only. |
| `ECOSYSTEM-AND-PORTS.md`, `FAQ.md`, `INSTALLATION-OWNERSHIP-SPEC.md` | Preserved under `root-documentation/`, deleted 2026-10-20 | Current owners live elsewhere; Git history only. |
| Two archived conversation captures | Moved to `docs/conversations/` | These are raw conversation records, not archive doctrine. |
| Empty tracker facades | Deleted | Canonical trackers already exist under `shipglows_data/workflow/`; the facades carried no independent state. |
| Two archive compatibility symlinks | Deleted | Their canonical install template and run trace already exist under `shipglows_data/workflow/`. |
| Duplicate `menu_simple_color.sh` backups | Deleted | Byte-identical obsolete scratch copies; Git history remains available. |
| `test.html` | Deleted | One-off scratch fixture with no consumer. |
| `tmp_drift_latest.txt` | Deleted | Generated temporary drift output, not durable evidence. |
| Former archive index files | Deleted | Replaced by this canonical index. |

## Maintenance Rule

Do not recreate a root `archive/` directory or new archive folders. Git history is the only archive: distill durable content into canonical docs, then delete the file.
