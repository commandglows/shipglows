---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-09-01"
created_at: "2026-09-01 08:32:00 UTC"
updated: "2026-09-01"
updated_at: "2026-09-01 08:58:21 UTC"
status: reviewed
source_skill: 900-shipglows-core
source_model: GPT-5
scope: context-aware-technical-documentation-closure
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
user_story: "As the ShipGlows operator, I want every code chantier to update its canonical technical documentation faithfully before closure, using current changed paths and qualified context rather than confusing public editorial impact with total documentation impact."
linked_systems:
  - skills/references/context-quality-contract.md
  - skills/references/context-history-and-head.md
  - skills/references/documentation-reflection-gate.md
  - skills/references/reporting-contract.md
  - skills/references/master-workflow-lifecycle.md
  - skills/103-sg-verify/references/verification-baseline.md
  - skills/104-sg-end/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/installer-and-user-scope.md
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/technical/operator-guides/windows-devserver.md
  - shipglows_data/technical/native-code-context-graph.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
  - tools/test_context_lifecycle_capsule_contract.py
  - tools/test_reporting_contract.py
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.5.0"
    required_status: active
  - artifact: skills/references/documentation-reflection-gate.md
    artifact_version: "1.4.0"
    required_status: active
  - artifact: shipglows_data/technical/code-docs-map.md
    artifact_version: "3.28.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Commit f5df7d2 implements the Windows lock-integrity repair, changed-path documentation closure, focused regressions and mapped technical documentation."
  - "Current-run proof: 94 focused lifecycle contracts, four Windows suites, metadata lint, budgets, activation graph, executable resource closure, runtime sync and diff checks pass."
  - "A 2026-09-01 Windows toolbox repair changed mapped installer code, but the closure report incorrectly classified all documentation as not impacted because no public promise changed."
  - "The industrialized context lifecycle test covers readiness, execution, verification and continuation, but not documentation reflection, closure or full-close shipping."
  - "The current documentation reflection contract names the code-docs map but does not mechanically require changed-path mapping before allowing not impacted."
next_step: none
---

# Context-aware technical documentation closure

## Status

Reviewed and shipped to the chantier branch. The operator approved the cross-system correction on 2026-09-01 after the current Windows toolbox work exposed a false documentation no-impact verdict. Regression-first contracts, mapped documentation, runtime visibility and final context proof are complete.

## Problem

ShipGlows has a native code graph, a Context Head, a qualified Context Capsule and a canonical code-docs map, but their responsibilities are not connected tightly enough at closure. A report can currently treat unchanged public/editorial promises as evidence that all documentation is unaffected, even when modified code paths have explicit technical-documentation triggers.

## Minimal Behavior Contract

Before any report or transition claims a code chantier complete, closed, resolved or shipped, ShipGlows derives the exact changed code scope from Git or the exact delivery scope, revalidates context invalidated by those changes, compares every changed path to the canonical code-docs map, and resolves each applicable documentation trigger. `not impacted` is allowed only after this mapping finds no applicable technical, operational, product or support documentation. Editorial/public impact remains a separate classification.

The graph, Context Head and capsule accelerate discovery and expose freshness, certainty, missing relationships and truncation. They never replace Git, the changed scope, the code-docs map or canonical documents as authority.

## Scope In

- Documentation reflection, lifecycle, reporting, verification, closure and full-close shipping contracts.
- Focused pressure-scenario tests for changed-path mapping and context invalidation.
- Current Windows provider-toolbox documentation for PowerShell host compatibility, `mise.lock`, Windows-only integrity metadata and managed Google Cloud updates.
- Current chantier history, code-docs mapping confirmation, qualified context refresh and one internal closure event.

## Scope Out

- Public-site or editorial-content changes when no public promise changed.
- A new graph database, parser expansion, embeddings, hosted retrieval or treating derived context as canonical truth.
- Unrelated working-tree files, including the pre-existing optional dotfiles orchestration draft.
- Deployment, authentication, provider project activation or destructive Git operations.

## Success Behavior

- A material code change cannot receive `documentation: not impacted` until changed paths are checked against `shipglows_data/technical/code-docs-map.md`.
- A mapped documentation trigger routes the canonical owner update in the same approved workstream and keeps closure partial until aligned.
- An unmapped changed code area yields a technical-navigation bootstrap/review gap rather than an optimistic no-impact verdict.
- Dirty, staged, branch, HEAD, worktree, spec or lockfile changes revalidate dependent capsule claims before closure.
- A fresh Context Head may accelerate discovery; a stale or absent one uses a no-write refresh or targeted canonical fallback.
- Public/editorial impact is classified independently and cannot substitute for technical documentation impact.

## Error Behavior

- Missing or stale context remains explicit and blocks only dependent closure claims.
- Graph truncation, unsupported languages or noisy ranking triggers targeted canonical retrieval rather than false completeness.
- Missing Git evidence or unresolved delivery scope prevents a clean documentation verdict.
- Documentation updates cannot silently include unrelated files or strengthen unverified public claims.

## Implementation Tasks

1. [x] Add the exact failing pressure scenario to reporting and lifecycle context contract tests.
2. [x] Harden shared context, documentation-reflection, lifecycle and reporting contracts.
3. [x] Wire verification, closure and full-close shipping consumers to the revalidated documentation-impact evidence.
4. [x] Align current Windows toolbox technical and operator documentation with the implemented behavior.
5. [x] Run focused and mapped validations, refresh derived context, record the chantier result, commit and push exact milestones.

## Acceptance Criteria

- [x] AC1: changed code paths plus a matching docs-map trigger cannot yield `not impacted`.
- [x] AC2: no public/editorial change can coexist truthfully with an impacted technical-documentation result.
- [x] AC3: stale Context Head or capsule evidence is revalidated after relevant Git/spec/lockfile changes.
- [x] AC4: graph/capsule gaps never override canonical targeted retrieval.
- [x] AC5: 103, 104 and full-close 005 preserve the same documentation-impact evidence.
- [x] AC6: current Windows toolbox docs explain exact pins, machine-local `mise.lock`, Windows integrity metadata, backend limits and the managed Google Cloud update boundary.
- [x] AC7: focused reporting/context tests, Windows tests, metadata lint, activation/resource graphs, budgets, runtime sync and diff checks pass.
- [x] AC8: exact-scope commits and ordinary pushes exclude the unrelated untracked draft.

## Proof Strategy

Regression-first. The initial contract tests must fail because closure consumers do not yet require changed-path/code-docs mapping. After implementation, run focused contract tests, mapped Windows tests, metadata and graph checks, then refresh the Context Head against the final dirty scope before verification and delivery.

## Documentation Update Plan

- Code changed: Windows provider toolbox and shared lifecycle/closure contracts.
- Primary technical docs: `shipglows_data/technical/installer-and-user-scope.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`.
- Secondary docs: `shipglows_data/technical/runtime-cli.md`, `README.md`, `shipglows_data/technical/code-docs-map.md`, this spec.
- Required action: update.
- Priority: high.
- Reason: installation reproducibility and documentation-impact behavior changed.
- Owner role: integrator.
- Parallel-safe: no for shared lifecycle and mapping documents.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-01 08:32:00 | 900-shipglows-core | GPT-5 | Diagnosed the false documentation no-impact verdict and formalized the approved cross-system correction. | Ready: exact failure, canonical authority order, affected consumers, Windows trigger and proof path are resolved. | Add failing regression scenarios before contract edits. |
| 2026-09-01 08:54:56 | 102-sg-start | GPT-5 | Added failing pressure scenarios, hardened changed-path/context/map resolution across verification and closure, removed activation-budget debt, and aligned mapped Windows and lifecycle documentation. | Implemented: 83 focused reporting, context, verification, closure and ship contracts pass; full mapped verification remains. | Run metadata, graph, runtime-sync and Windows proof before closure. |
| 2026-09-01 08:58:00 | 103-sg-verify | GPT-5 | Verified the exact behavior contract, Windows repair, mapped documentation, metadata, activation budgets, resource closure, runtime visibility and final qualified context. | Verified: 94 focused contracts and four Windows suites pass; budgets have no findings, executable dependencies have zero cycles, and all runtime skill links are current. | Close and push the bounded final bookkeeping. |
| 2026-09-01 08:58:21 | 104-sg-end / 005-sg-ship | GPT-5 | Recorded one internal significant event, preserved the unrelated draft, and prepared the exact closure milestone after the implementation commit was already pushed. | Closed and shipped to the current chantier branch; editorial surfaces remain not impacted and the changelog event is internal-only. | Merge through the repository's normal protected integration path. |

## Current Chantier Flow

`100-sg-spec (complete) -> 101-sg-ready (ready) -> 102-sg-start (implemented) -> 103-sg-verify (verified) -> 104-sg-end (closed) -> 005-sg-ship (shipped)`
