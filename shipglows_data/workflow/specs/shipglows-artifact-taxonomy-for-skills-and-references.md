---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-12"
created_at: "2026-06-12 08:52:46 UTC"
updated: "2026-06-12"
updated_at: "2026-06-12 12:31:22 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "skill-and-reference-architecture"
owner: "unknown"
user_story: "As the ShipGlows operator, I want a complete but simple taxonomy for skills, references, templates, and records, so we can reduce confusion first at the architecture level and only then compact wording safely."
confidence: "high"
risk_level: "high"
security_impact: "none"
docs_impact: "yes"
linked_systems:
  - "skills/*/SKILL.md"
  - "skills/references/*"
  - "templates/*"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "README.md"
  - "AGENT.md"
  - "shipglows_data/technical/context.md"
  - "shipglows_data/technical/skill-runtime-and-lifecycle.md"
  - "shipglows_data/workflow/specs/compact-shipglows-skill-instructions.md"
  - "shipglows_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md"
  - "shipglows_data/workflow/specs/skill-taxonomy-and-chantier-sources.md"
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/chantier-tracking.md"
    artifact_version: "0.5.0"
    required_status: "draft"
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.18.1"
    required_status: "draft"
supersedes: []
evidence:
  - "User decision 2026-06-12: work first on clarity and concision at the architecture/structure level, then on semantics."
  - "Conversation 2026-06-12 distinguished router purity from master-workflow orchestration and specialist execution."
  - "Current repository already separates skills, shared references, templates, and durable spec artifacts, but boundary confusion remains in practice."
  - "Existing chantiers compact skill bodies and skill descriptions, yet they do not define one canonical artifact taxonomy covering entrypoints, workflows, contracts, references, templates, and records."
next_step: "/005-sg-ship shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md"
---

# Title

ShipGlows Artifact Taxonomy For Skills And References

# Status

ready

# User Story

As the ShipGlows operator, I want a complete but simple taxonomy for skills, references, templates, and records, so we can reduce confusion first at the architecture level and only then compact wording safely.

# Minimal Behavior Contract

When this chantier runs, ShipGlows must define one canonical taxonomy for the artifacts that govern skill behavior and project guidance: `entrypoint-router`, `master-workflow`, `specialist-workflow`, `contract`, `reference`, `template`, and `record`. For each type, the system must state its question centrale, unit of value, allowed content, forbidden content, and expected output, then map existing ShipGlows artifacts to one primary type only. If a file materially performs two jobs, the taxonomy must require extraction or split instead of accepting ambiguity. The easiest edge case to miss is treating every router-like skill the same, which collapses the distinction between choosing a workflow and orchestrating a chantier.

# Success Behavior

- Preconditions: the repository already contains skills, shared references, templates, governance docs, and durable specs with recurring boundary confusion.
- Trigger: the operator launches `/101-sg-ready` and then `/102-sg-start` on this spec.
- User/operator result: the operator gets a canonical artifact taxonomy, an ideal responsibility matrix, a short classification rubric, and a concrete mapping of current ShipGlows files to their primary type.
- System effect: future compaction, rewrites, and routing work can distinguish what belongs in `SKILL.md`, what belongs in `skills/references/*`, what belongs in templates, and what belongs in durable records.
- Proof of success: touched docs state the taxonomy consistently; representative skills and references can be classified quickly without debate; no artifact family needs dual-primary labels.

# Error Behavior

- If the taxonomy creates categories that overlap materially, the run must stop and narrow or merge them before applying documentation changes.
- If a proposed type is too abstract to classify existing ShipGlows files quickly, the run must reject it or tighten the matrix.
- If a current file needs two primary types to make sense, the run must mark it for split/extraction instead of forcing a bad classification.
- If the resulting taxonomy cannot distinguish `000-shipglows` from `001-sg-build`, or a shared rule from a support map, verification fails.
- Must never happen: solving confusion by renaming categories only, while leaving responsibility boundaries implicit or contradictory.

# Problem

ShipGlows already invested in compaction, layering, routing, and chantier doctrine. The remaining confusion is not mainly sentence length. It is boundary confusion between artifact roles. Skills can contain routing, orchestration, execution detail, shared doctrine, and reporting rules in the same body. References can drift into normative contracts. Templates can accumulate usage doctrine. Durable records can start re-explaining the method instead of only capturing a case.

This makes later concision work unreliable: when the structure is unclear, text grows to compensate. A clean semantic pass therefore depends on a more explicit artifact architecture.

# Solution

Define a complete but simple artifact taxonomy with seven primary types:

- `entrypoint-router`
- `master-workflow`
- `specialist-workflow`
- `contract`
- `reference`
- `template`
- `record`

For each type, document its dominant question, responsibility boundary, legal/illegal content, and expected output. Then create a matrix that classifies representative ShipGlows artifacts and exposes where current files are structurally mixed. Use that matrix to drive future extraction, compaction, and documentation updates.

# Canonical Artifact Taxonomy

ShipGlows documents that govern behavior should resolve to exactly one primary artifact type below.

- `entrypoint-router`: chooses the first safe route for a request.
- `master-workflow`: owns delegated lifecycle orchestration for a chantier.
- `specialist-workflow`: executes one bounded domain task under a selected master flow.
- `contract`: authoritative reusable rule text that sets what should happen.
- `reference`: support map, index, checklist, or playbook that points to doctrine.
- `template`: durable structure for creating artifacts.
- `record`: durable case log of one durable event, result, or audit scope.

## Canonical Taxonomy Matrix

| Artifact type | Question centrale | Unite de valeur | Horizon | Contenu legitime | Contenu illegitime | Verbe dominant | Sortie attendue |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `entrypoint-router` | `Quel est le premier pas correct et sans perte de contexte ?` | Routing precision | Immediate | Invocation paths, default questions, ambiguity routing, delegation handoff rules, safety gates | Implementation details, specialist execution logic, runtime fixes | `route` | Route decision, next execution target, or direct answer |
| `master-workflow` | `Qui dirige cette opération jusqu'à la preuve ?` | Lifecycle integrity | Multi-step chantier | Readiness, topology, owner handoff, proof gates, trace updates, next steps ownership | One-off task fixes, reusable policy, artifact creation templates | `orchestrate` | Controlled sequence and ownership state for the active chantier |
| `specialist-workflow` | `Quelle action technique ou opérationnelle mène à un résultat sûr ?` | Execution quality | One chantier or one bounded wave | Task execution plan, domain checks, specialist reporting, remediation | Routing policy, lifecycle ownership, reusable global policy text | `execute` | Bound specialist outcome with explicit proof and next action |
| `contract` | `Quelle règle est obligatoire dans tous les cas pertinents ?` | Shared predictability | Long-lived | Canonical doctrine, quality gates, non-ambiguous requirements, required checks, explicit exceptions | Mutable run history, one-time status updates, per-case narratives | `define` | Durable normative contract with scoped exceptions |
| `reference` | `Quel support aide à appliquer une règle correctement ?` | Speed of correct usage | Short-to-mid term | Indexes, maps, examples, migration notes, playbooks, FAQ fragments, decision aides | New canonical rule, ownership routing, evidence claims, mandatory proofs | `support` | Contextual guidance that points to the right contract/workflow |
| `template` | `Quel format doit être réutilisé sans réécrire la structure ?` | Writing speed and consistency | Long-term | Frontmatter headers, required sections, skeletons, placeholders, allowed placeholders, field names | Narrative history, policy decisions, proof claims, case-specific conclusions | `shape` | Reusable artifact skeleton matching metadata and schema |
| `record` | `Que prouve et trace ce cas précis ?` | Traceability and auditability | Case-long | Changelog-like facts, status history, one durable event, canonical ledger lines, evidence metadata | Reusable process doctrine, reusable routing policy, future workflows | `record` | One durable artifact entry with clear scope, status, and next step |

### Boundary Rules (Minimal)

- `entrypoint-router` must route to one primary target and must not own specialist execution.
- `master-workflow` may coordinate multiple specialists but must not become a reusable policy source.
- `specialist-workflow` follows a selected master and must not reroute the chantier boundary.
- `contract` must state requirements and guardrails; if a file also tells users how to use every case separately, split that usage guidance.
- `reference` must stay advisory or navigational; if it introduces non-local policy, split to `contract`.
- `template` must be mostly structural; avoid embedding procedural doctrine.
- `record` must describe a case, not become the method used for next instances.

## Boundary and Anti-Pattern Matrix

| Area | Symptom | Anti-pattern sign | Recommended action |
| --- | --- | --- | --- |
| Router vs orchestrator confusion | A router file contains workflow commands and trace updates | `entrypoint-router` starts running `103-sg-verify` logic itself | Extract orchestration into `master-workflow` or specialist links; keep router focused to handoff |
| Master vs specialist drift | A specialist file defines project-wide readiness or lifecycle gating | `specialist-workflow` claims route and owns chantier history | Keep specialist execution-only logic, move lifecycle flow to `master-workflow` |
| Contract/reference contamination | A support map becomes the actual enforcement rule | `reference` states mandatory behavior and penalties | Move required rules to `contract`; keep the former as usage guidance |
| Template/workflow drift | Template includes execution policy text or proof exceptions | `template` changes behavior in different contexts | Move decision logic to `contract` or `reference`; keep template fields/shape only |
| Record/doctrine mixing | A case log embeds canonical method and becomes the primary teaching source | `record` becomes the basis for future runs instead of a one-off trace | Keep record single-case; reference `contract` and `reference` for method |

## Representative Mapping to Primary Types

| Artifact | Primary type | Why one type |
| --- | --- | --- |
| `AGENT.md` | `reference` | Central entrypoint guide and routing map for operators |
| `skills/000-shipglows/SKILL.md` | `entrypoint-router` | Receives free-form instruction and delegates to one primary target |
| `skills/001-sg-build/SKILL.md` | `master-workflow` | Owns delegated execution with readiness + verification + ship handoff | 
| `skills/100-sg-spec/SKILL.md` | `master-workflow` | Owns the spec intake and reading gate for durable work |
| `skills/references/canonical-paths.md` | `contract` | Defines mandatory path-resolution rule and exception policy |
| `shipglows_data/technical/context.md` | `reference` | Context map used to orient local decisions and routing |
| `templates/spec.md` | `template` | Artifact structure for durable spec creation |
| `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md` | `record` | Durable result and mapping for this chantier |

## Structural Debt and Extraction Targets

- `skills/102-sg-start/SKILL.md`: mixed `SKILL.md` contract and multi-page execution playbook; low-risk target remains `execution-workflow.md`, but the local contract still embeds long model/topology prose. Recommendation: keep as is for this chantier and plan a future `102-sg-start` cleanup follow-up only if execution semantics change.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: mixes canonical workflow doctrine with user-facing command guidance. It is currently coherent as one contract but still close to the `contract`/`reference` boundary. Recommendation: split command-cheatsheet snippets to a dedicated reference once churn becomes high.
- `README.md`: user onboarding and internal architecture context are mixed in one public-facing doc; it remains stable today and should be kept non-mixed by explicit section roles unless a dedicated public-facing architecture reference is added.

# Scope In

- Define the canonical seven-type artifact taxonomy for ShipGlows skill and reference architecture.
- Define the distinction between `entrypoint-router`, `master-workflow`, and `specialist-workflow`.
- Define the distinction between `contract` and `reference`.
- Define the role of `template` and `record` in the same architecture.
- Produce an ideal matrix with responsibility, horizon, allowed content, forbidden content, and output for each type.
- Produce a boundary matrix that identifies common confusions and anti-patterns.
- Map representative existing artifacts to one primary type.
- Identify which current files are structurally mixed and require extraction or split recommendations.
- Update the architecture and lifecycle docs that explain ShipGlows artifact structure if implementation changes are accepted.

# Scope Out

- Rewriting all skills in this chantier.
- Global semantic shortening of all skills or references.
- Renaming skill directories, invocation keys, or public commands.
- Changing chantier tracking categories beyond what is needed to explain artifact roles.
- Public site taxonomy or marketing categorization of skills.
- Provider-specific runtime or installer behavior.

# Constraints

- The taxonomy must stay simple enough for a maintainer to classify a file quickly.
- Simplicity cannot come from collapsing distinct responsibilities.
- Each artifact gets one primary type only.
- Secondary roles may be mentioned, but they do not replace the primary classification.
- If a file performs two serious primary jobs, the preferred remedy is split or extraction.
- The taxonomy must preserve existing distinctions already surfaced in ShipGlows, especially router versus orchestrator versus specialist, and contract versus support reference.
- Internal contracts and matrices remain in English.

# Test Contract

- Surface profile: documentation architecture and skill-governance contract.
- Automated proof available: targeted `rg` checks, metadata lint, and consistency checks against touched docs.
- Non-automated proof required: human review of classification clarity on representative files.
- Ordered proof path:
  1. matrix and mapping draft inside the spec or linked artifact
  2. consistency update in the touched docs
  3. targeted grep checks on taxonomy labels and examples
  4. metadata lint for changed frontmatter artifacts
  5. manual review of representative classifications
- Manual checklist expected if the chantier updates many files or the wording remains debatable: `shipglows_data/workflow/test-checklists/shipglows-artifact-taxonomy-for-skills-and-references.md`
- Exception with proof: no browser, auth, provider, or device proof is required because the change is local to ShipGlows governance artifacts.

# Dependencies

- Local contracts:
  - `skills/references/decision-quality-contract.md`
  - `skills/references/skill-instruction-layering.md`
  - `skills/references/chantier-tracking.md`
  - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
- Local context and integration docs:
  - `README.md`
  - `AGENT.md`
  - `shipglows_data/technical/context.md`
  - `shipglows_data/technical/skill-runtime-and-lifecycle.md`
- Related prior chantiers:
  - `shipglows_data/workflow/specs/compact-shipglows-skill-instructions.md`
  - `shipglows_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md`
  - `shipglows_data/workflow/specs/skill-taxonomy-and-chantier-sources.md`
- Fresh external docs verdict: `fresh-docs not needed`, because this chantier defines local ShipGlows artifact architecture rather than framework or provider behavior.

# Invariants

- `000-shipglows` remains distinguishable from master skills by primary role.
- Master skills remain distinguishable from specialist skills by ownership of a chantier and sequencing responsibility.
- Shared reusable rules stay classifiable as `contract`, not hidden inside general references.
- Support maps and indexes stay classifiable as `reference`, not promoted to implicit doctrine by accident.
- Templates prescribe form, not workflow.
- Records capture a case, not the general method.

# Links & Consequences

- `skills/*/SKILL.md`: their role descriptions and future compaction work depend on this taxonomy.
- `skills/references/*`: shared references may need to split into true contracts versus support references.
- `templates/*`: template boundaries become easier to preserve when they are explicitly separated from doctrine.
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`: may need a short artifact-architecture explanation so lifecycle docs stay aligned.
- `README.md`, `AGENT.md`, and technical context docs may need concise alignment language if they currently blur artifact roles.
- Future chantiers on skill compaction, routing, docs architecture, or taxonomy should depend on this classification instead of re-deriving it ad hoc.

# Documentation Coherence

- Update `shipglows_data/technical/skill-runtime-and-lifecycle.md` with the canonical taxonomy matrix.
- Update `shipglows_data/workflow/playbooks/spec-driven-workflow.md` with the canonical artifact taxonomy section.
- Keep `README.md` and `AGENT.md` unchanged in this chantier; re-open follow-up only if router guidance becomes ambiguous for the new taxonomy.
- Update `skills/references/skill-instruction-layering.md` only if this taxonomy requires contract/reference boundary reclassification later.
- Do not edit trackers such as `TASKS.md`, `AUDIT_LOG.md`, or legacy `PROJECTS.md`.

# Edge Cases

- A master skill contains enough routing logic to be mistaken for an entrypoint-router.
- A specialist skill includes a mini-lifecycle and starts to behave like a master skill.
- A shared reference contains normative rules but is named and used like a neutral support doc.
- A template begins to explain when it should be chosen, which turns it into workflow doctrine.
- A spec or audit record starts re-teaching the whole method instead of only documenting the case.
- A single current file cannot be classified cleanly because the architecture debt is real; the chantier must call that out instead of forcing certainty.

# Implementation Tasks

- [x] Task 1: Write the canonical taxonomy definition.
  - File: `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Action: Add the final seven-type taxonomy with exact definitions, dominant questions, and boundaries.
  - User story link: Creates the durable contract that later work can reuse instead of re-arguing artifact roles.
  - Depends on: None
  - Validate with: `rg -n "entrypoint-router|master-workflow|specialist-workflow|contract|reference|template|record" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Notes: The definitions must distinguish routing from orchestration and contract from support reference.

- [x] Task 2: Add the ideal artifact matrix.
  - File: `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Action: Add the matrix with question centrale, unit of value, horizon, allowed content, forbidden content, dominant verb, and expected output for each type.
  - User story link: Makes the taxonomy operational instead of purely conceptual.
  - Depends on: Task 1
  - Validate with: `rg -n "Question centrale|Unite de valeur|Horizon|Contenu legitime|Contenu illegitime|Verbe dominant|Sortie attendue" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Notes: Keep the matrix dense and discriminating rather than exhaustive-by-prose.

- [x] Task 3: Add the boundary and anti-pattern matrix.
  - File: `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Action: Document how to recognize structural contamination, including router/orchestrator confusion, contract/reference drift, template/workflow drift, and record/doctrine drift.
  - User story link: Gives future maintainers a way to detect where confusion actually lives.
  - Depends on: Task 2
  - Validate with: `rg -n "anti-pattern|contamination|router|orchestrator|drift|split|extraction" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Notes: The output should prefer split/extraction recommendations over tolerant ambiguity.

- [x] Task 4: Map representative ShipGlows artifacts to primary types.
  - File: `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Action: Classify representative files such as `AGENT.md`, `skills/000-shipglows/SKILL.md`, `skills/001-sg-build/SKILL.md`, `skills/100-sg-spec/SKILL.md`, `skills/references/canonical-paths.md`, `shipglows_data/technical/context.md`, `templates/*`, and durable specs.
  - User story link: Proves the taxonomy works on real files and not only on theory.
  - Depends on: Task 3
  - Validate with: `rg -n "AGENT.md|000-shipglows|001-sg-build|100-sg-spec|canonical-paths|context.md|templates|shipglows_data/workflow/specs" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Notes: Each mapped artifact must receive one primary type only.

- [x] Task 5: Identify structural debt and extraction targets.
  - File: `shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Action: List current artifacts that likely mix primary roles and specify whether they need split, extraction, rename for clarity, or explicit no-change.
  - User story link: Converts taxonomy work into actionable architecture cleanup rather than a static glossary.
  - Depends on: Task 4
  - Validate with: `rg -n "split|extract|no-change|mixed|primary type|debt" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - Notes: Do not implement all cleanups in this chantier unless they remain strictly local and non-controversial.

- [x] Task 6: Align the core architecture docs.
  - Files: `shipglows_data/technical/skill-runtime-and-lifecycle.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, `README.md`, `AGENT.md`
  - Action: Update only the docs needed to reflect the canonical artifact taxonomy and its most important distinctions.
  - User story link: Keeps the doctrine discoverable for future maintainers and agents.
  - Depends on: Tasks 1-5
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md shipglows_data/technical/skill-runtime-and-lifecycle.md shipglows_data/workflow/playbooks/spec-driven-workflow.md README.md AGENT.md`
  - Notes: Skip unchanged docs; explain any intentional no-update decision in `Documentation Coherence`.

# Acceptance Criteria

- [x] The spec defines exactly seven primary artifact types with non-overlapping responsibilities.
- [x] The taxonomy distinguishes `entrypoint-router`, `master-workflow`, and `specialist-workflow` clearly enough to classify known master skills without debate.
- [x] The taxonomy distinguishes `contract` from `reference` clearly enough to classify shared doctrine versus support maps without debate.
- [x] The ideal matrix exists and is usable as a design tool.
- [x] A representative mapping of current ShipGlows artifacts to primary types exists.
- [x] At least one boundary/anti-pattern matrix exists for structural contamination detection.
- [x] The spec identifies where current architecture debt still mixes primary roles.
- [x] Any touched docs remain metadata-valid and coherent with the taxonomy.

# Test Strategy

- Run targeted `rg` checks on the new spec to confirm all seven types, the matrix headings, and representative mappings are present.
- Run `python3 tools/shipglows_metadata_lint.py` on every changed frontmatter artifact.
- Manually classify at least these representative files and confirm the taxonomy yields one clear primary type:
  - `AGENT.md`
  - `skills/000-shipglows/SKILL.md`
  - `skills/001-sg-build/SKILL.md`
  - `skills/100-sg-spec/SKILL.md`
  - `skills/references/canonical-paths.md`
  - `shipglows_data/technical/context.md`
  - one artifact template
  - one durable spec
- Reject the taxonomy if two reviewers would likely classify the same representative file differently without additional rules.

# Risks

- The taxonomy may become too abstract and fail to guide real edits.
- The taxonomy may become too detailed and reintroduce the confusion it tries to remove.
- Existing files may carry enough mixed responsibility that the architecture debt looks larger than expected.
- Later compaction may misuse the taxonomy as a renaming exercise instead of a boundary-cleanup tool.
- Security impact: none, because this chantier only updates governance documentation and does not touch auth, permissions, runtime execution paths, or user data.

# Execution Notes

- Read first:
  - `skills/references/decision-quality-contract.md`
  - `skills/references/skill-instruction-layering.md`
  - `shipglows_data/workflow/playbooks/spec-driven-workflow.md`
  - `shipglows_data/workflow/specs/compact-shipglows-skill-instructions.md`
  - `shipglows_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md`
- Keep the first implementation pass architectural. Do not begin by rewriting wording globally.
- Prefer one canonical matrix over scattered definitions across several docs.
- Where a current file is mixed, record the structural debt instead of smoothing it away rhetorically.
- If the taxonomy implies major structural changes to many skills, stop after the architecture pass and route through `/101-sg-ready` again before implementation.
- Validation commands:
  - `rg -n "entrypoint-router|master-workflow|specialist-workflow|contract|reference|template|record" shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md`
  - `python3 tools/shipglows_metadata_lint.py <changed-frontmatter-artifacts>`

# Open Questions

None.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-12 08:52:46 UTC | 100-sg-spec | GPT-5 Codex | Created a draft spec for canonical ShipGlows artifact taxonomy across skills, references, templates, and records | draft | /101-sg-ready shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md |
| 2026-06-12 09:25:52 UTC | 101-sg-ready | GPT-5 Codex | Reviewed readiness of `ShipGlows Artifact Taxonomy For Skills And References`; closed Open Questions and approved for implementation | ready | /102-sg-start shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md |
| 2026-06-12 10:36:11 UTC | 102-sg-start | GPT-5 Codex | Added canonical seven-type taxonomy, ideal matrix, anti-pattern matrix, representative mapping, structural debt list, and aligned runtime workflow docs | implemented | /103-sg-verify shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md |
| 2026-06-12 10:55:00 UTC | 103-sg-verify | GPT-5 Codex | Verified user-story fit, taxonomy coherence, documentation alignment, metadata validity, runtime skill sync, and proof-path adequacy for the artifact-taxonomy chantier | verified | /104-sg-end shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md |
| 2026-06-12 12:30:36 UTC | 104-sg-end | GPT-5 Codex | Updated this spec history and completed remaining trace closure after rerunning metadata lint and targeted taxonomy checks for this chantier. | closed | /005-sg-ship shipglows_data/workflow/specs/shipglows-artifact-taxonomy-for-skills-and-references.md |
| 2026-06-12 12:31:22 UTC | 005-sg-ship | GPT-5 Codex | Shipped the bounded governance-surface updates for this chantier only; validation checks passed and unrelated dirty files were intentionally left out of this ship. | shipped | none |

# Current Chantier Flow

- 100-sg-spec: draft
- 101-sg-ready: ready
- 102-sg-start: implemented
- 103-sg-verify: verified
- 104-sg-end: closed
- 005-sg-ship: shipped
- Next step: none
