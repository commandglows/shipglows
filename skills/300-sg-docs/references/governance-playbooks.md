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

Keep a project's workflow corpus light enough that agents and the operator read only live material, without losing a decision. Git history is the only archive: tidy distills what still matters into canonical docs, then deletes. It never creates archive folders, archive indexes, or moved copies.

1. **Inventory.** Run `python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/project_docs_tidy_audit.py" .` It classifies `shipglows_data/workflow/` work artifacts as `open`, `recent`, `delivered`, `retired`, `dormant`, `archived` (legacy `archives/` trees), `pinned` (removable but read by a test), or `untracked`, lists each item's inbound references outside the workflow corpus, and counts open and done tracker rows. Bugs whose `bug_status` is not closed stay `open`. Templates, playbooks, and checklists are out of scope. `--check` answers only whether a tidy is operationally due: removable backlog, removable material outweighing live work, or accumulated done tracker rows. Closure, next-outcome selection, and maintenance call it so tidy follows project activity; the 60-day `workflow-tidy` cadence is only a backstop.
2. **Triage each candidate**, reading it before deciding, in the order of the value triage of `skills/references/dead-code-obsolescence-audit.md`: `open` and `recent` stay. For `delivered`, `retired`, and `archived` items, `reconnect` or `merge` any durable decision, behavior rule, or constraint not yet in its canonical surface (technical, product, business, editorial docs) under the Migration Preservation Rule, then `delete`; a `retired` item first confirms its successor carries the truth. `dormant` items are an operator decision per item: resume (stays), supersede into a live item, or delete as abandoned with a one-line reason. A dormant item that is still useful becomes one `TASKS.md` row linking it, and the tidy continues; tidy never starts a session, agent, or chantier per item, and still ends on one consolidated question. Conversations, conversation audits, verbatim extracts, and repurpose packs are kept as raw material for public content: before deleting one, run the `007-sg-content` repurpose check and record whether it should become, or feed, site or blog content (article, illustration, section of an existing page). A `yes` becomes one editorial roadmap row linking it, and the file stays until that content ships. `untracked` items are never deleted: the operator commits or explicitly discards them first. Unresolved ownership or truth stops that item, not the run. When a class holds more than about twenty items, triage by family (kind, class, age, status): read every item with live inbound references plus at least three per family, state the sampling in the packet, and move any item that contradicts its family verdict to individual review. `pinned` items stay; report them as test-coupling debt and fix the test (frozen fixture under `tools/`, or skip when the artifact is absent), never by deleting the test.
3. **Trackers.** Delete done rows from `TASKS.md` and append-only logs once their durable outcome lives in a canonical doc or the changelog; keep headers, legends, open rows, and the latest `workflow-tidy` audit record.
4. **Links.** Before deleting, find inbound references to each item (`git grep` on its path and slug) in live docs, specs, trackers, and code; repoint them to the canonical target or remove them, including `depends_on` edges.
5. **Approval packet.** Write the full per-item list to a working file outside the repository (the session scratchpad); it is never committed. In the message, show per-class counts and sizes, then the item list by verdict (`delete`, `merge then delete`, `reconnect`, `keep`, `ask`) with each `dormant` question. Wait for explicit approval; it covers the listed items only.
6. **Apply** in one commit per run: merges and link repairs first, then `git rm` of approved items and tracker-row deletions. The commit message lists every deleted path with its class so `git show <commit>^:<path>` or a revert restores it. Never purge history, rewrite commits, or delete untracked files.
7. **Proof and report.** Re-run the inventory and the topology preflight, confirm no live reference points to a deleted path, then append one `shipglows_data/workflow/AUDIT_LOG.md` record with `domain: workflow-tidy` and `next_due` so the maintenance cadence resets, and report live size before and after, merged and deleted items, the recovery commit, and remaining `dormant` decisions. Maintenance invokes this mode when it is due; direct operator invocation is optional.

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
