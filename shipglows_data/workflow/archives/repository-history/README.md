---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-13"
updated: "2026-07-13"
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

## Preserved History

- `migration/`: early Flox, PM2, Dokploy, configuration, and migration records.
- `notes/`: historical workflow and web-inspector design inputs.
- `reports/`: historical implementation, priority, UX, and improvement reports.
- `root-documentation/`: root documents retained for provenance after their active ownership moved elsewhere.

Current runtime behavior belongs in `shipglows_data/technical/`. Current workflow contracts belong in `shipglows_data/workflow/`. Raw conversation captures belong in `docs/conversations/` when produced by the conversation-capture workflow.

## Migration Ledger

| Former surface | Final action | Reason |
| --- | --- | --- |
| `archive/MIGRATION_SUMMARY.md`, `archive/new-config.md`, `archive/plan_migration.md` | Preserved under `migration/` | Historical architecture and migration provenance. |
| `archive/notes/OUTIL.md`, `archive/notes/devworkflow.md` | Preserved under `notes/` | Historical design and workflow inputs. |
| Historical reports under `archive/reports/` | Preserved under `reports/` | Implementation and UX provenance. |
| `ECOSYSTEM-AND-PORTS.md`, `FAQ.md`, `INSTALLATION-OWNERSHIP-SPEC.md` | Preserved under `root-documentation/` | Historical root-documentation evidence; current owners live elsewhere. |
| Two archived conversation captures | Moved to `docs/conversations/` | These are raw conversation records, not archive doctrine. |
| Empty tracker facades | Deleted | Canonical trackers already exist under `shipglows_data/workflow/`; the facades carried no independent state. |
| Two archive compatibility symlinks | Deleted | Their canonical install template and run trace already exist under `shipglows_data/workflow/`. |
| Duplicate `menu_simple_color.sh` backups | Deleted | Byte-identical obsolete scratch copies; Git history remains available. |
| `test.html` | Deleted | One-off scratch fixture with no consumer. |
| `tmp_drift_latest.txt` | Deleted | Generated temporary drift output, not durable evidence. |
| Former archive index files | Deleted | Replaced by this canonical index. |

## Maintenance Rule

Do not recreate a root `archive/` directory. Preserve useful inactive governance history under `shipglows_data/workflow/archives/<bounded-scope>/`; delete generated, duplicate, empty-facade, or unreferenced scratch material after recording the decision.
