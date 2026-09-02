---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-09-02"
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
  - "Operator decision 2026-09-02: documentation audit and update classify root PITCH.md presence, navigation, and freshness."
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

## AUDIT MODE

Compare documentation and doc-like surfaces against code and current contracts. Check missing coverage, metadata, bug-model docs, language, dependencies/freshness, and user-risk surfaces such as install, auth, billing, migration, API, and troubleshooting. Run `tools/audit_project_pitches.py <project-root>` for a managed project and report `missing`, `stale`, or `review_required` as a governance finding. Audits are read-only unless the request also authorizes update.

## UPDATE MODE

Audit silently, then apply bounded remediations. Preserve ownership and tracker separation. Run skill-budget checks only for skill/discovery scope. Persist durable decisions to their canonical surfaces. Create or refresh root `PITCH.md` from evidenced business/product sources, preserve it as a concise navigation card, and never let it own delivery posture or operational state. Before slimming local docs, perform source-to-canonical preservation and update the destination in the same change. Create missing governance only when evidence justifies it; resume the originating outcome after a recoverable governance repair.

Prioritize P0 dangerous drift, P1 conventions, P2 stale docs, then P3 missing coverage.

## LAYOUT MIGRATION MODE

Classify root, legacy, and nested corpora as moveable, collision, external-root-ok, tracker/runtime-content, migrate, or standalone-exception. Build a preservation ledger for every source: target, preserved content/tasks, intentional rejection, and final state. Prefer `git mv`, never overwrite collisions silently, and run metadata plus legacy-path checks. A later consolidation request must recompare original sources to repair semantic loss.

## METADATA MODE

Frontmatter migration is additive. Define scope; classify candidates as migrate, compliant, runtime content, tracker/archive excluded, or ambiguous; preserve bodies; infer only obvious values and otherwise use `unknown` with lower confidence; lint the changed scope.

## Result

Report the selected mode, preservation evidence, validation, unresolved collisions or freshness gaps, and the next outcome. Structural compliance alone is not semantic proof.
