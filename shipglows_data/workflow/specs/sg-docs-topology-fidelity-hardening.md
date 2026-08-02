---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-12"
created_at: "2026-07-12 20:55:00 UTC"
updated: "2026-07-12"
updated_at: "2026-07-12 21:12:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "300-sg-docs topology execution-fidelity hardening"
owner: "Diane"
user_story: "As the ShipGlows operator, I want sg-docs to detect incoherent project-governance topology automatically and act on it through one compact, mechanically proven contract, so I do not have to identify structural violations or repeat instructions myself."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/300-sg-docs/SKILL.md"
  - "skills/300-sg-docs/references/mode-playbooks.md"
  - "skills/references/documentation-governance-rules.md"
  - "skills/references/skill-execution-fidelity.md"
  - "skills/references/skill-instruction-layering.md"
  - "tools/audit_project_governance_topology.py"
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "A real 300-sg-docs update run normalized a few files while missing concurrent root shipglows_data, nested site/shipglows_data, root legacy governance files, and generated-output clutter."
  - "The follow-up wording duplicated the same topology gate across three instruction layers without adding mechanical proof."
  - "Current generic skill audits pass because they do not execute project-topology pressure scenarios."
next_step: "/005-sg-ship sg-docs topology fidelity hardening"
---

# Spec: SG Docs Topology Fidelity Hardening

## Title

SG Docs Topology Fidelity Hardening

## Status

ready

## User Story

As the ShipGlows operator, I want `300-sg-docs` to detect incoherent project-governance topology automatically and act through one compact, mechanically proven contract, so I do not have to identify structural violations or repeat instructions myself.

## Minimal Behavior Contract

Every `300-sg-docs` invocation first runs one deterministic project-topology audit. A compliant repository continues into the requested mode; a repository with competing or nested governance corpora, legacy root governance artifacts, or an invalid `AGENTS.md` relationship produces a migration-required verdict and routes into duplicate/layout handling before narrow documentation work can be reported complete. If the audit cannot determine whether a nested corpus is an independent repository, it reports a reviewable collision instead of asking the operator to locate files or silently continuing.

## Success Behavior

- A fresh agent sees one activation-level topology directive and one exact proof command.
- The audit detects `shipglows_data/`, nested governance corpora, legacy root artifacts, and invalid `AGENTS.md` compatibility automatically.
- Machine-readable output distinguishes `compliant`, `migration-required`, and `review-required`.
- Detailed migration doctrine remains in one owner reference and is not repeated across activation/playbook/shared doctrine.

## Error Behavior

- Invalid target paths or unreadable repositories return a non-zero error with a concise explanation.
- The audit never deletes, moves, or rewrites project files.
- A possible standalone nested repository is classified from Git boundaries; uncertain ownership becomes `review-required`.
- A generic skill-budget pass cannot substitute for the topology pressure tests.

## Problem

`300-sg-docs` had the right canonical-path doctrine but did not reliably apply it before narrow work. The attempted repair added prose in multiple layers and still lacked mechanical enforcement.

## Solution

Replace repeated prose with one activation directive backed by a read-only topology-audit tool and focused tests. Keep migration semantics in the existing core/playbook owner and make the exact audit command part of `300-sg-docs` validation.

## Scope In

- Compact the recent topology/followability wording.
- Add `tools/audit_project_governance_topology.py`.
- Add focused automated tests for compliant and non-compliant repositories.
- Wire the tool into `300-sg-docs` activation and validation.
- Update the technical tooling map if required.

## Scope Out

- Migrating TemuGlowz itself.
- Renaming skills or invocation keys.
- Rewriting unrelated skills or the full governance doctrine.
- Shipping, committing, or pushing.

## Constraints

- The audit is read-only and standard-library only.
- One canonical activation directive; no duplicated warning blocks.
- Existing user changes and unrelated dirty files remain untouched.
- No external documentation is needed because behavior is local repository policy.

## Test Contract

- Surface: Python CLI plus skill-contract Markdown.
- Primary proof mode: automated tests and scenario-first contract scans.
- Proof order: unit tests → fixture CLI runs → skill audits/budget → runtime sync.
- Required scenarios: compliant single corpus; root `shipglows_data`; nested `site/shipglows_data`; legacy root `BUSINESS.md`; valid/invalid `AGENTS.md`; nested standalone Git repository.
- Manual checklist: not required because all required behavior is deterministic and local.

## Dependencies

- Python standard library.
- Canonical path and monorepo governance rules listed in frontmatter.
- Fresh external docs: `fresh-docs not needed` — local policy and tooling only.

## Invariants

- `shipglows_data/` is the single canonical governance corpus at the project governance root.
- Root compatibility exceptions remain allowed.
- The topology audit never mutates the target.
- Compaction must improve followability, not merely line count.

## Links & Consequences

- Upstream: `300-sg-docs` activation and canonical-path doctrine.
- Downstream: update, audit, duplicate, and layout modes; future governed projects.
- Cross-cutting: skill budget, runtime skill visibility, metadata lint, documentation coherence.

## Documentation Coherence

- Update `shipglows_data/technical/code-docs-map.md` if the new tool needs durable routing coverage.
- No public skill-page promise changes; this is internal execution hardening.

## Edge Cases

- A nested corpus inside a true standalone Git repository is not automatically migration debt.
- A symlinked `AGENTS.md` must resolve exactly to `AGENT.md`.
- Generated directories are reported as hygiene signals but do not alone force governance migration.
- Multiple violations are reported together in stable, machine-readable output.

## Implementation Tasks

- [x] Task 1: Add the read-only topology audit and tests.
  - File: `tools/audit_project_governance_topology.py`, `tools/test_audit_project_governance_topology.py`
  - Action: detect canonical, competing, nested, root-legacy, compatibility, standalone, and generated-output states with stable exit codes/output.
  - User story link: automatic structural diagnosis without operator localization.
  - Depends on: None.
  - Validate with: `python3 -m unittest tools.test_audit_project_governance_topology`
- [x] Task 2: Compact `300-sg-docs` activation and owner doctrine.
  - File: `skills/300-sg-docs/SKILL.md`, `skills/300-sg-docs/references/mode-playbooks.md`, `skills/references/documentation-governance-rules.md`
  - Action: keep one local directive and remove redundant conditional/duplicate paragraphs.
  - User story link: agent followability under limited attention.
  - Depends on: Task 1.
  - Validate with: focused `rg` uniqueness checks.
- [x] Task 3: Align shared followability doctrine and technical tool routing.
  - File: `skills/references/skill-execution-fidelity.md`, `skills/references/skill-instruction-layering.md`, `shipglows_data/technical/code-docs-map.md`
  - Action: retain one canonical followability rule and document the topology-audit ownership path without repeated rationale.
  - User story link: durable prevention across future skill edits.
  - Depends on: Tasks 1-2.
  - Validate with: metadata lint and targeted routing scans.
- [x] Task 4: Run full bounded validation.
  - File: changed files in this spec only.
  - Action: run tool tests, fixture scenarios, metadata lint, skill audit, budget audit, diff check, and runtime sync check.
  - User story link: prove actual behavior instead of text presence.
  - Depends on: Tasks 1-3.
  - Validate with: commands in Test Strategy.

## Acceptance Criteria

- [x] AC 1: Given a fresh `300-sg-docs update` run in a repository with root and nested `shipglows_data`, when preflight runs, then it returns `migration-required` before narrow docs work.
- [x] AC 2: Given a compliant repository with one root `shipglows_data`, when preflight runs, then it returns `compliant` and exit code 0.
- [x] AC 3: Given a nested governance corpus in an independent Git repository, when preflight runs, then it records a standalone exception rather than a migration violation.
- [x] AC 4: Given root legacy governance artifacts, when preflight runs, then all are listed without requiring them as explicit CLI arguments.
- [x] AC 5: Given the skill contract after compaction, when searched for the topology gate, then one decisive activation directive and one proof command remain without three overlapping doctrine blocks.
- [x] AC 6: Given an audit execution failure, when the tool exits, then it does not mutate the target repository.
- [x] AC 7: Given generic skill audits pass, when topology scenario tests fail, then verification still fails.

## Test Strategy

- Unit: `python3 -m unittest tools.test_audit_project_governance_topology`
- Integration: run the CLI against temporary compliant/non-compliant fixtures and the TemuGlowz repository in read-only mode.
- Contract: metadata lint, focused `rg`, skill audit, budget audit, runtime sync check, `git diff --check`.
- Manual: none required.

## Risks

- Security impact: none; the tool reads paths and Git boundaries only.
- False positives: mitigated by explicit root compatibility allowlist and standalone Git-boundary detection.
- Instruction dilution: mitigated by uniqueness checks and removing redundant wording.
- Scope creep: bounded to `300-sg-docs`, shared followability doctrine, one tool, tests, and technical routing docs.

## Execution Notes

- Read first: `skills/300-sg-docs/SKILL.md`, its two required references, canonical paths, instruction layering, and execution fidelity.
- Implement the tool before final wording so the activation contract can point to real proof.
- Stop if the tool would need to mutate repositories or if standalone detection cannot be made deterministic.
- Validate with the commands in Test Strategy.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-12 20:55:00 UTC | 100-sg-spec | GPT-5 Codex | Created bounded topology-fidelity hardening spec from the observed sg-docs failure | draft | /101-sg-ready shipglows_data/workflow/specs/sg-docs-topology-fidelity-hardening.md |
| 2026-07-12 21:00:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed structure, behavior, failure handling, scope, risks, and mechanical proof contract | ready | /009-sg-skill-build shipglows_data/workflow/specs/sg-docs-topology-fidelity-hardening.md |
| 2026-07-12 21:02:00 UTC | 009-sg-skill-build | GPT-5 Codex | Implemented command-backed topology preflight, focused tests, compacted doctrine, runtime sync, and technical map update | implemented | /103-sg-verify shipglows_data/workflow/specs/sg-docs-topology-fidelity-hardening.md |
| 2026-07-12 21:03:00 UTC | 103-sg-verify | GPT-5 Codex | Verified all seven acceptance criteria, read-only behavior, metadata, skill budget, runtime visibility, and real TemuGlowz detection | verified | /005-sg-ship sg-docs topology fidelity hardening |
| 2026-07-12 21:12:00 UTC | 009-sg-skill-build | GPT-5 Codex | Removed the final redundant topology-preflight echo from UPDATE MODE while preserving its mode-specific audit action | implemented | targeted reverify |
| 2026-07-12 21:12:00 UTC | 103-sg-verify | GPT-5 Codex | Re-ran topology tests, uniqueness checks, metadata lint, budget audit, runtime sync, and diff check after final compaction | verified | /005-sg-ship sg-docs topology fidelity hardening |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready.
- `009-sg-skill-build`: implemented.
- `103-sg-verify`: verified.
- `104-sg-end`: pending.
- `005-sg-ship`: not authorized.

Next step: `/005-sg-ship sg-docs topology fidelity hardening`
