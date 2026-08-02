---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "shipglows"
created: "2026-06-30"
updated: "2026-06-30"
status: draft
source_skill: "300-sg-docs"
scope: "repo-doc-governance-refresh"
owner: "unknown"
confidence: "high"
risk_level: "medium"
security_impact: "none"
docs_impact: "yes"
domains: ["documentation-governance", "technical-docs", "workflow"]
issue_counts: {"high": 3, "medium": 3, "low": 1}
linked_systems:
  - "README.md"
  - "shipglows_data/technical/context.md"
  - "shipglows_data/technical/README.md"
  - "shipglows_data/workflow/TASKS.md"
  - "shipglows_data/workflow/AUDIT_LOG.md"
  - "shipglows_data/workflow/concurrent.md"
depends_on: []
supersedes: []
evidence:
  - "Root inventory on 2026-06-30 shows active governance files and compatibility wrappers mixed at repository root."
  - "Root TASKS.md and AUDIT_LOG.md diverged from their canonical shipglows_data/workflow counterparts."
  - "README.md claimed a cleaner root boundary than the repository actually exposed."
next_step: "/300-sg-docs duplicate audit"
---

# Repo Doc Governance Refresh

## Goal

Recentrer le repo sur sa structure documentaire canonique et rendre explicite ce qui est canonique, ce qui est une facade, et ce qui reste de la dette de migration.

## Duplicate Governance Review

| Artifact set | Classification | Canonical target | Action | Reason |
| --- | --- | --- | --- | --- |
| `TASKS.md` + `shipglows_data/workflow/TASKS.md` | merge-to-shared | `shipglows_data/workflow/TASKS.md` | root file reduced to compatibility facade | root tracker was stale and incomplete; canonical tracker is richer and already consumed by skills/TUI/docs |
| `AUDIT_LOG.md` + `shipglows_data/workflow/AUDIT_LOG.md` | merge-to-shared | `shipglows_data/workflow/AUDIT_LOG.md` | root file reduced to compatibility facade | root audit index was stale and drifted from canonical tracker |
| `concurrent.md` + `shipglows_data/workflow/concurrent.md` | merge-to-shared | `shipglows_data/workflow/concurrent.md` | root file reduced to compatibility facade | same governance intent already exists in canonical workflow layer |
| root shell wrappers + `cli/*` | keep-surface-specific | `cli/*` for behavior, root wrappers for compatibility | keep wrappers, label them as launchers | wrappers are intentional entrypoint compatibility, not duplicate governance docs |
| `ECOSYSTEM-AND-PORTS.md` + canonical technical layer | collision-needs-review | likely `shipglows_data/technical/runtime-cli.md` or a dedicated scoped technical note | keep as debt for a dedicated merge pass | root note is legacy, but preservation into technical layer was not proven in this pass |

## Public/Internal Surface Updates

- `README.md` now states the real layer split: `cli/`, `tui/`, `skills/`, plugin/site, and canonical `shipglows_data/`.
- `README.md` now labels root-only technical debt more accurately instead of implying the root is already clean.
- `shipglows_data/technical/context.md` now includes the TUI in the repo map and states that root governance duplicates must become facades or be removed.

## Remaining Debt

- `ECOSYSTEM-AND-PORTS.md` is still a legacy root note and should be merged into the technical layer with preservation proof.
- Other root docs such as `FAQ.md`, `INSTALL-REPORT-TEMPLATE.md`, and `INSTALL-RUN-TRACE.md` still need an ownership/placement decision.
- Root `shipglows_data/workflow/bugs/` vs `shipglows_data/workflow/bugs/` should be audited explicitly in a dedicated bug-governance pass.

## Preservation Ledger

| Source artifact | Canonical target | Content preserved | Content intentionally rejected | Tracker/task extraction | Final local state |
| --- | --- | --- | --- | --- | --- |
| `TASKS.md` | `shipglows_data/workflow/TASKS.md` | canonical tracker already contained the richer active state | stale duplicate task list | none | kept as facade |
| `AUDIT_LOG.md` | `shipglows_data/workflow/AUDIT_LOG.md` | canonical tracker already contained the richer active state | stale duplicate audit index | none | kept as facade |
| `concurrent.md` | `shipglows_data/workflow/concurrent.md` | canonical file already carried the same project note | none | none | kept as facade |
