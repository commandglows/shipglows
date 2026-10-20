---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-10-20"
status: active
source_skill: 300-sg-docs
scope: 300-sg-docs-governance-playbooks
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/300-sg-docs/references/core-governance.md
  - shipglows_data/technical/
  - shipglows_data/editorial/
depends_on: []
supersedes: []
evidence:
  - "Extracted from the former eager mode playbook during wave-3 compaction."
next_step: "/103-sg-verify progressive skill activation compaction wave 3"
---

# Governance Playbooks

The activation gate supplies core governance before any mode here. Apply the topology preflight before mutation and preserve semantic content before cleanup.

## TECHNICAL DOCS MODE

Use the shared technical corpus and code-navigation contract selected by the activation gate. Read the governance-root code-docs map. Bootstrap, audit, or update the layer so mapped areas have owners, primary docs, entrypoints, invariants, validation, reader checklists, maintenance rules, behavior indexes for ambiguous/high-load terms, and source-comment coverage for critical symbols. Monorepos use one root corpus with scoped mappings; UI surfaces declare design-system authority. Provider notes must distinguish reusable official-source notes from project-specific usage and must pass freshness gates when current behavior matters.

## EDITORIAL GOVERNANCE MODE

Use the shared editorial corpus selected by the activation gate. Audit or bootstrap content maps, page intent, claim evidence, editorial gates, runtime schemas, and the editorial roadmap. Keep public-content backlog in `shipglows_data/editorial/ROADMAP.md`, not the execution tracker. If no editorial surface exists, report `skipped - no editorial surfaces detected`.

## DUPLICATE GOVERNANCE MODE

Inventory candidates by theme then surface. Classify each set as `merge-to-shared`, `keep-surface-specific`, `split-shared-and-surface-delta`, or `collision-needs-review`. Report artifact set, canonical target, action, and reason. Merge/delete only after unique content and active tracker signals are preserved; unresolved truth collisions stop for review.

## TIDY MODE

Keep a project's workflow corpus light enough that agents and the operator read only live material, without losing a decision. Tidy moves and distills; it never deletes.

1. **Inventory.** Run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/project_docs_tidy_audit.py" .` It classifies `shipglows_data/workflow/` work artifacts as `open`, `recent`, `delivered`, `retired`, or `dormant` and counts open and done tracker rows. Templates, playbooks, checklists, and existing archives are out of scope. `--check` answers only whether a tidy is operationally due: archivable backlog, archivable material outweighing live work, or accumulated done tracker rows. Closure, next-outcome selection, and maintenance call it so tidy follows project activity; the 60-day `workflow-tidy` cadence is only a backstop.
2. **Triage each candidate**, reading it before deciding: `open` and `recent` stay. `delivered` and `retired` items are distilled, then archived: durable decisions, behavior rules, or constraints not yet in their canonical surface (technical, product, business, editorial docs) are merged there first under the Migration Preservation Rule; a `retired` item also needs its successor link. `dormant` items are an operator decision per item: resume (stays), supersede (status `superseded`, then archive), or archive as abandoned with a one-line reason. Unresolved ownership or truth stops that item, not the run.
3. **Trackers.** Move done rows of `TASKS.md` and append-only logs into `shipglows_data/workflow/archives/<YYYY>/<TRACKER>-done.md`; keep headers, legends, open rows, and a one-line pointer to the archive.
4. **Links.** Before moving, find inbound references to each item (`git grep` on its path and slug) in live docs, specs, trackers, and code; repoint them to the archive or canonical target, including `depends_on` edges.
5. **Approval packet.** Show per-class counts and sizes, then the item list by verdict (`archive`, `merge then archive`, `keep`, `ask`) with each `dormant` question. Wait for explicit approval; it covers the listed items only.
6. **Apply** after loading `$SHIPGLOWS_ROOT/skills/references/closure-archive-guard.md`: `git mv` into `shipglows_data/workflow/archives/<YYYY>/<kind>/`, deterministic names, no overwrite, and one row per item in `shipglows_data/workflow/archives/INDEX.md` (`closed or archived date | item | one-line outcome | archive path`). Use one revertable commit per run.
7. **Proof and report.** Re-run the inventory and the topology preflight, confirm no live reference points to a moved path, then append one `shipglows_data/workflow/AUDIT_LOG.md` record with `domain: workflow-tidy` and `next_due` so the maintenance cadence resets, and report active size before and after, archived and merged items, and remaining `dormant` decisions. Maintenance invokes this mode when that cadence is due; direct operator invocation is optional.

Removing an archived item entirely is outside tidy and follows the Removal Execution Lane of `skills/references/dead-code-obsolescence-audit.md`.

## AUDIT MODE

Compare documentation and doc-like surfaces against code and current contracts. Check missing coverage, metadata, bug-model docs, language, dependencies/freshness, and user-risk surfaces such as install, auth, billing, migration, API, and troubleshooting. Audits are read-only unless the request also authorizes update.

## UPDATE MODE

Audit silently, then apply bounded remediations. Preserve ownership and tracker separation. Run skill-budget checks only for skill/discovery scope. Persist durable decisions to their canonical surfaces. Before slimming local docs, perform source-to-canonical preservation and update the destination in the same change. Create missing governance only when evidence justifies it; resume the originating outcome after a recoverable governance repair.

Prioritize P0 dangerous drift, P1 conventions, P2 stale docs, then P3 missing coverage.

End an update run with the tidy inventory summary. When `delivered`, `retired`, and `dormant` items together outweigh `open` and `recent` ones, recommend TIDY MODE; never tidy implicitly.

## LAYOUT MIGRATION MODE

Classify root, legacy, and nested corpora as moveable, collision, external-root-ok, tracker/runtime-content, migrate, or standalone-exception. Build a preservation ledger for every source: target, preserved content/tasks, intentional rejection, and final state. Prefer `git mv`, never overwrite collisions silently, and run metadata plus legacy-path checks. A later consolidation request must recompare original sources to repair semantic loss.

## METADATA MODE

Frontmatter migration is additive. Define scope; classify candidates as migrate, compliant, runtime content, tracker/archive excluded, or ambiguous; preserve bodies; infer only obvious values and otherwise use `unknown` with lower confidence; lint the changed scope.

## Result

Report the selected mode, preservation evidence, validation, unresolved collisions or freshness gaps, and the next outcome. Structural compliance alone is not semantic proof.
