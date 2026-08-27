---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-27"
created_at: "2026-08-27 11:39:29 UTC"
updated: "2026-08-27"
updated_at: "2026-08-27 11:54:06 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: shipglows-dx-system-ownership
owner: Diane
user_story: "As the ShipGlows operator, I want Core to maintain the complete ShipGlows DX system while keeping shipglows_app separate, so skill, CLI, TUI, DevServer, installer, and packaging evolution remains coherent without absorbing the public site or SaaS product."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/900-shipglows-core/SKILL.md
  - skills/900-shipglows-core/references/
  - skills/references/skill-invocation-registry.json
  - skills/references/shipglows-terms.md
  - tools/test_900_shipglows_core_contract.py
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/context.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - README.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.3.1"
    required_status: active
  - artifact: skills/references/skill-instruction-layering.md
    artifact_version: "1.10.0"
    required_status: active
  - artifact: shipglows_data/technical/architecture.md
    artifact_version: "1.15.0"
    required_status: reviewed
  - artifact: shipglows_data/technical/skill-runtime-and-lifecycle.md
    artifact_version: "2.35.0"
    required_status: reviewed
supersedes: []
evidence:
  - "Operator decision 2026-08-27: shipglows is the DX system containing skills, TUI, and CLI/DevServer, while shipglows_app owns the public site and SaaS product."
  - "The current Core contract already resolves CLI, TUI, Windows DevServer, and installer paths, but its description, mission, build playbook, lifecycle docs, and README still constrain ownership to skill maintenance."
  - "ShipGlows terminology already defines one combined package of CLI scripts, skills, local tooling, and documentation, so current ownership wording is internally inconsistent rather than absent."
next_step: "/104-sg-end full ShipGlows Core DX system ownership"
---

# Spec: ShipGlows Core DX System Ownership

## Title

ShipGlows Core DX System Ownership

## Status

reviewed

## User Story

As the ShipGlows operator, I want Core to maintain the complete ShipGlows DX system while keeping `shipglows_app` separate, so skill, CLI, TUI, DevServer, installer, and packaging evolution remains coherent without absorbing the public site or SaaS product.

## Minimal Behavior Contract

When Core receives ShipGlows-system work, it classifies the target as skill/doctrine, DX runtime, packaging/distribution, or cross-surface coherence and loads exactly the matching direct playbook. A recognized target produces an executable lifecycle and proof route inside the `shipglows` repository. An absent, ambiguous, or out-of-bound target stops visibly. The easiest missed edge case is treating a quoted `shipglows_app` site or SaaS goal inside Core context as permission to modify that separate product.

## Success Behavior

- Preconditions: The canonical linked ShipGlows developer root resolves and the Core activation graph passes preflight.
- Trigger: `$shipglows core <instruction>` or an explicit valid `900-shipglows-core <mode> <target>` invocation concerns the ShipGlows system.
- User/operator result: Core owns and routes maintenance across skills, CLI, TUI, DevServer, installers, and packaging without asking the operator to choose an internal playbook.
- System effect: Core contracts, activation metadata, proof scenarios, and canonical DX documentation agree on one repository boundary.
- Success proof: Focused Core contract tests, invocation graph preflight, metadata lint, skill validation, and targeted drift scans pass.
- Silent success: Not allowed; the final report names the routed surface and proof.

## Error Behavior

- Expected failures: Missing canonical root or playbook, ambiguous target surface, invalid explicit mode, activation graph failure, or attempted `shipglows_app` mutation from hard Core context.
- User/operator response: A visible bounded error names the missing or excluded surface and the smallest valid route.
- System effect: No fallback to a sibling checkout, deprecated Core pilot, or `shipglows_app`; no unrelated mutation.
- Must never happen: Core silently absorbs site/SaaS ownership, duplicates runtime procedures in its activation body, or treats agent aliases as shell CLI commands.
- Silent failure: Not allowed; the boundary and recovery route remain explicit.

## Problem

Core is half-generalized. Its canonical-path section already names CLI, TUI, installers, and the Windows DevServer, but its discovery description, mission, `build` pack, audit baseline, README, and lifecycle documentation still present it as a skill-maintenance owner. A fresh agent can therefore discover the right files and still choose the wrong owner or proof contract.

## Solution

Define Core as the internal lifecycle owner for the ShipGlows DX system and retain progressive disclosure through direct surface-specific playbooks. Preserve the current modes and compatibility while routing `build` and scoped `audit` work by target surface. Add a cross-surface coherence contract and state the `shipglows` versus `shipglows_app` repository boundary in canonical terminology and architecture docs.

## Scope In

- Core activation contract and discovery description.
- Skill/doctrine maintenance through the existing skill playbook.
- DX runtime maintenance for Unix CLI/DevServer, native Windows DevServer, environment control plane, local helpers, TUI, and associated installers.
- Cross-surface coherence for behavior spanning agent contracts, runtime commands, packaging, documentation, and proof.
- Activation-profile metadata, focused contract tests, help/lifecycle/README wording, architecture, context, and code-doc mapping.

## Scope Out

- Functional changes to CLI, TUI, DevServer, environment engine, or installers.
- Starting or stopping a local server, running an installer, deployment, release, or public publication.
- Any file or behavior in `shipglows_app`, including its website and SaaS product.
- Renaming the public `$shipglows` entrypoint, internal `900-shipglows-core` engine, or existing modes.
- Making Core public or reviving the deprecated `shipglows-core` pilot.
- Reformatting or staging unrelated pre-existing worktree changes.

## Constraints

- Keep `SKILL.md` concise and activation-oriented; procedures belong in direct non-chaining references.
- Preserve `audit`, `build`, `refresh`, `packaging`, and `help` mode compatibility.
- Internal contracts stay English; user-facing reports stay in the active language.
- A runtime target must select runtime maintenance directly; a skill target must not load runtime procedure; a cross-surface target must name one integration owner and all affected proofs.
- Existing dirty files outside this spec remain untouched and unstaged.

## Test Contract

- surface: Core routing, activation metadata, and DX ownership documentation.
- proof_profile: scenario-first plus focused mechanical checks.
- proof_order: focused Core tests -> explicit invocation/graph preflight -> skill validation and metadata lint -> targeted drift scan -> Git diff hygiene.
- checklist_path: none; no manual, browser, hosted, provider, device, or server evidence applies because executable runtime behavior is unchanged.
- required_scenario_ids:
  - `CORE-DX-SKILL`: a skill/doctrine target selects the existing skill-maintenance playbook.
  - `CORE-DX-RUNTIME`: a CLI, TUI, DevServer, installer, local-helper, or environment target selects the DX runtime playbook.
  - `CORE-DX-COHERENCE`: a request spanning agent and runtime behavior loads one coherence contract and names every affected proof surface.
  - `CORE-DX-APP-BOUNDARY`: a site/SaaS request for `shipglows_app` is evidence only in hard Core context and never becomes an edit target.
  - `CORE-DX-MISSING-PACK`: a missing required direct playbook blocks instead of falling back.
- ZOMBIES coverage: Z = missing target or pack blocks; O = one recognized surface loads one playbook; M = cross-surface change has one integration owner; B = `shipglows`/`shipglows_app` boundary; I = public router -> Core -> surface playbook; E = invalid mode, graph failure, or out-of-bound target; S = preserve existing modes and add only direct references needed for routing.

## Dependencies

- Runtime: Python 3 for focused tests and activation preflight; no application runtime or server dependency.
- Document contracts: decision quality, skill instruction layering, architecture, and skill runtime lifecycle at the versions declared above.
- Metadata gaps: Existing reviewed contracts are current enough for this local ownership change; no external documentation is required.

## Invariants

- `shipglows` is the DX-system repository: skills, CLI/DevServer, TUI, local/runtime helpers, installers, packaging, and their internal governance.
- `shipglows_app` remains a separate product repository for the public site and SaaS.
- `$shipglows` remains the public router; `900-shipglows-core` remains internal and repo-synced.
- `shipglows-core` remains a deprecated historical pilot, never canonical or public.
- Agent expert aliases remain Codex routing syntax, never shell CLI commands.
- Runtime implementation owners and tests remain canonical; Core orchestrates lifecycle and coherence rather than duplicating code internals.

## Links & Consequences

- Upstream systems: Public `shipglows` hard Core context, explicit invocation preflight, canonical path resolution, and mutation approval.
- Downstream systems: Core local playbooks, activation profile, help catalog, lifecycle docs, README, architecture/context, and future Core-run DX chantiers.
- Cross-cutting checks: Public/internal packaging boundary, Windows bootstrap handoff, documentation map, runtime proof selection, and exclusion of `shipglows_app`.

## Documentation Coherence

- Update Core lifecycle wording in the README, spec-driven workflow, and skill runtime/lifecycle reference.
- Update canonical terminology and architecture/context to name the DX boundary and separate product repository.
- Update the code-docs map for Core and its direct runtime/coherence playbooks.
- Public website or SaaS documentation is not impacted because `shipglows_app` behavior and promise do not change.

## Edge Cases

- Bare `900-shipglows-core build` remains invalid even though build target kinds expand.
- `build 006-sg-design` selects skill maintenance; `build cli/windows` selects runtime maintenance.
- A change to a CLI command documented in a skill selects coherence rather than two unrelated chantiers.
- A request quoting a desired `shipglows_app` outcome inside `$shipglows core` repairs or evaluates DX behavior only.
- Runtime work on Windows still loads the existing Windows bootstrap workflow rather than duplicating it.
- A future new DX surface is not silently classified; the Core contract must be extended with an owner and proof mapping first.

## Implementation Tasks

1. Core routing contract and direct references.
   - Files: `skills/900-shipglows-core/SKILL.md`, `skills/900-shipglows-core/references/dx-runtime-maintenance.md`, `skills/900-shipglows-core/references/system-coherence.md`, and the existing skill/audit playbooks.
   - Action: Broaden the mission, classify targets, keep direct progressive disclosure, add runtime and coherence procedures, and make scoped audit behavior match the selected surface.
   - User story link: Makes Core own the whole DX system without becoming a monolith.
   - Depends on: This ready spec.
   - Validate with: `python3 -m unittest tools.test_900_shipglows_core_contract`.
   - Notes: Do not modify runtime implementation files.
2. Activation and discovery alignment.
   - Files: `skills/references/skill-invocation-registry.json`, `skills/302-sg-help/references/help-modes-expert-catalog.md`, and `tools/test_high_traffic_activation_profiles.py` only if its executable profile expectations require an update.
   - Action: Register the new conditional Core gates while preserving public owner, alias, internal engine, modes, and explicit-only policy.
   - User story link: Keeps the same entrypoint discoverable and mechanically valid.
   - Depends on: Task 1.
   - Validate with: `python3 tools/skill_invocation_check.py "shipglows core maintain the DX runtime"` and `python3 tools/skill_invocation_check.py --audit-graph`.
   - Notes: Do not add Core aliases to the shell CLI.
3. Canonical DX boundary documentation.
   - Files: `skills/references/shipglows-terms.md`, `shipglows_data/technical/architecture.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/code-docs-map.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and `README.md`.
   - Action: Replace skill-only Core ownership wording with DX-system ownership and explicitly separate `shipglows_app` site/SaaS ownership.
   - User story link: Gives fresh agents one stable repository and product boundary.
   - Depends on: Task 1.
   - Validate with: Metadata lint on changed artifacts plus focused scans for stale skill-only Core ownership.
   - Notes: No public product claim changes.
4. Scenario-first regression proof.
   - File: `tools/test_900_shipglows_core_contract.py`.
   - Action: Add behavior-focused assertions for the five required scenarios and preserve existing compactness, packaging, hard-context, and Windows bootstrap checks.
   - User story link: Prevents the ownership split from drifting back to skills-only or expanding into `shipglows_app`.
   - Depends on: Tasks 1-3.
   - Validate with: `python3 -m unittest tools.test_900_shipglows_core_contract`.
   - Notes: Test decisions and routing invariants, not incidental prose formatting.
5. Integrate, verify, and deliver.
   - Files: Exact files changed by Tasks 1-4 plus this spec.
   - Action: Run proportional checks, update chantier history/status, inspect the exact diff, commit only owned paths, and push ordinary commits to the resolved upstream.
   - User story link: Leaves a remotely durable, coherent DX maintenance contract.
   - Depends on: Tasks 1-4 passing.
   - Validate with: Focused tests, metadata lint, skill validation, activation preflight, `git diff --check`, exact staging review, and upstream containment.
   - Notes: Exclude all unrelated pre-existing dirty paths.

## Acceptance Criteria

- [x] AC 1: Given a skill/doctrine target, when Core selects `build`, then it loads the skill-maintenance playbook and not the runtime playbook.
- [x] AC 2: Given a CLI, TUI, DevServer, installer, local-helper, or environment target, when Core selects `build`, then it loads the DX runtime playbook with the matching canonical code, docs, and proof route.
- [x] AC 3: Given a target spanning agent and runtime behavior, when Core classifies it, then one coherence contract names the integration owner and every affected validation surface.
- [x] AC 4: Given `shipglows_app` site or SaaS language inside hard Core context, when routing completes, then `shipglows_app` remains excluded from mutation and only the ShipGlows DX behavior is evaluated.
- [x] AC 5: Given existing explicit Core invocations, when preflight runs, then all current modes, alias resolution, internal visibility, and packaging boundaries remain valid.
- [x] AC 6: Given a missing required direct playbook or invalid target, when Core attempts activation, then it stops visibly without fallback.
- [x] AC 7: Given a fresh agent reads canonical docs, then it can state that `shipglows` owns the DX system and `shipglows_app` owns the public site and SaaS.
- [x] AC 8: Given the final diff, then no CLI/TUI/DevServer implementation file and no `shipglows_app` file changed.

## Test Strategy

- Unit: Focused Core contract test and activation-profile tests if touched.
- Integration: Explicit invocation and full activation graph preflight.
- Contract: Skill validator, metadata lint, targeted stale-wording scans, and Git diff hygiene.
- Manual: Review the final diff for repository boundary, direct-reference followability, and unrelated dirty-file exclusion.
- Exception with proof: Full CLI/Windows DevServer suites are not run because runtime implementation behavior is unchanged; static owner/proof mapping and existing Windows handoff assertions cover this contract-only change.

## Risks

- Security impact: None; the change does not alter credentials, permissions, runtime execution, or external state.
- Product risk: Core could become a catch-all. Mitigation: classify only declared DX surfaces, use direct non-chaining references, and retain specialist runtime/test owners.
- Compatibility risk: Existing expert invocations could drift. Mitigation: preserve modes and keys, update only conditional activation gates, and run preflight.
- Boundary risk: `shipglows_app` could be absorbed by broad "ShipGlows system" wording. Mitigation: make the repository boundary an explicit invariant and pressure scenario.
- Maintenance risk: Repeating procedures across skill and runtime playbooks could diverge. Mitigation: keep cross-surface rules in one coherence reference and point to canonical code/docs owners.

## Execution Notes

- Read first: Core skill and local playbooks, invocation registry, Core contract test, canonical terms, architecture/context, skill runtime/lifecycle, code-docs map, README lifecycle section, and current worktree status.
- Proof path: `scenario-first`.
- Implementation classification: `shared/domain + documentation-only`; no frontend, backend, or runtime implementation code.
- Topology: `main-only`; one cohesive bounded stream, and no subagent topology was requested.
- Stop conditions: Runtime behavior changes become necessary; `shipglows_app` must be modified; activation graph fails for unrelated debt; an owned target overlaps pre-existing dirty work; or proof requires server/installer execution.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-27 11:39:29 UTC | 100-sg-spec | GPT-5 Codex | Created the DX-system ownership contract from the approved Core unification plan and explicit repository boundary. | draft | /101-sg-ready ShipGlows Core DX system ownership |
| 2026-08-27 11:41:26 UTC | 101-sg-ready | GPT-5 Codex | Confirmed autonomous scope, repository boundary, direct-playbook routing, scenario-first proof, documentation consequences, and exact delivery constraints. | ready | /900-shipglows-core build ShipGlows Core DX system ownership |
| 2026-08-27 11:53:30 UTC | 900-shipglows-core | GPT-5 Codex | Extended Core across skill/doctrine, DX runtime, and cross-plane coherence with direct packs, preserved the shipglows_app boundary, and aligned activation/help/technical contracts. | implemented | /103-sg-verify ShipGlows Core DX system ownership |
| 2026-08-27 11:54:06 UTC | 103-sg-verify | GPT-5 Codex | Verified all eight acceptance criteria with 21 focused Core regressions, nine activation-profile checks, a valid 86-edge activation graph, metadata and context-budget checks, runtime-link proof, drift scans, and exact diff hygiene. The generic system skill validator was non-authoritative here because it rejects the repository-standard pre-existing argument-hint field. | verified | /104-sg-end full ShipGlows Core DX system ownership |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: passed, spec ready.
- `900-shipglows-core build`: implemented.
- `103-sg-verify`: verified.
- `104-sg-end`: next.
- `005-sg-ship`: pending.

Next step: `/104-sg-end full ShipGlows Core DX system ownership`
