---
name: 300-sg-docs
description: "Maintain docs, bootstrap governance, metadata, and governance-layout compliance."
disable-model-invocation: true
argument-hint: [file-path | init | readme | api | components | audit | update | metadata | migrate-layout | technical | editorial | duplicates | add-project]
---

## Mission

Public label: `sg-docs`. Own internal architecture, governance, code-adjacent, context, metadata, and agent docs through validation. Public audience content belongs to `sg-content`, except repository bootstrap/governance.

Resolve `$SHIPGLOWS_ROOT` (default `$HOME/.shipglows/runtime`) and load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before reading owned files or invoking an owned tool; confirm the target tool stays under that root. Project source resolves from the target root; project governance resolves from the canonical governance root, which is the monorepo root when applicable.

Before clarification or mode selection, load `skills/references/intent-to-outcome-autonomy.md`. Keep internal contracts in English and user-facing output in the active language. Never expose secrets or strengthen an unproven public claim.

## Mode Selection

Run the governance topology preflight **before any mutation**:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/audit_project_governance_topology.py" .
```

`compliant` continues; `migration-required` selects layout migration; `review-required` must resolve bootstrap or ownership before mutation. Do not report narrow work complete while this gate is unresolved.

Select one family and load only its direct playbook:

| Intent | Mode | Direct family reference |
| --- | --- | --- |
| `init`, bootstrap, file path, `readme`, `api`, `components`, empty args | INIT, FILE, README, API, COMPONENTS, AUTO | `references/simple-bootstrap-playbooks.md` |
| `audit`; `update`; `technical [audit]`; `docs/technical`; `editorial [audit]`; `docs/editorial`; `duplicata`, duplicates, duplicate audit; `migrate-layout`, layout; `metadata`, migrate-frontmatter | AUDIT, UPDATE, TECHNICAL, EDITORIAL, DUPLICATE, LAYOUT MIGRATION, METADATA | `references/governance-playbooks.md` |
| `add-project`, project import/refresh, import URL | ADD PROJECT, ADD PROJECT UPDATE | `references/private-project-playbooks.md` |

Load exactly one family before the first mode action. `references/mode-playbooks.md` is a compatibility index only; do not load it during normal execution. Do not load one local family reference from another.

## Conditional Gates

- Load `references/core-governance.md` before governance audit/update, technical/editorial governance, duplicates, layout migration, metadata migration, or any operation that changes canonical ownership, placement, preservation, or public claims. Simple FILE/API/COMPONENTS work does not load it unless one of those gates is reached.
- Load `references/bootstrap-starter-templates.md` only for INIT or empty/near-empty README/AUTO bootstrap.
- Load `skills/references/question-contract.md` only before a material merge, replace, scope, surface, or bootstrap question.
- Load `skills/references/documentation-freshness-gate.md` only when current external framework, SDK, provider, runtime, schema, auth, deployment, or API behavior controls truth.
- Load `skills/references/technical-docs-corpus.md` and `skills/references/code-navigation-and-function-docs.md` for technical governance.
- Load `skills/references/editorial-content-corpus.md` for editorial governance; add `task-registry-routing.md` when operational follow-up is involved.
- Load `project-governance-rules.md` for project compliance, `documentation-governance-rules.md` for documentation architecture/placement, and the metadata migration guide for METADATA.
- Load `$SHIPGLOWS_ROOT/skills/references/guided-business-product-discovery.md` when creating or materially repairing business/product/GTM/brand context, and `$SHIPGLOWS_ROOT/skills/references/product-decision-chain.md` when its decision links change.
- Load `skills/references/skill-context-budget.md` only for skill discovery or instruction-budget work.
- Load `skills/references/private-data-repo-contract.md` for durable private operator data.
- For private-project modes, directly load `$SHIPGLOWS_ROOT/shipglows_data/workflow/playbooks/project-import-playbook.md`, its checklist, `source-intake-classification.md`, `private-memory-store.md`, and `private-data-repo-contract.md`.

## Authority And Mutation Contract

- Preserve existing confirmed content and canonical ownership. Label unknown facts instead of inferring product truth from a sentence or stack.
- Before slimming, deleting, moving, or replacing a document, map its canonical destination, preserve non-redundant content and active tracker signals, and record intentional rejection. Use explicit merge decisions for collisions.
- Keep operational trackers free of governance frontmatter. Keep implementation work in `shipglows_data/workflow/TASKS.md` and editorial work in `shipglows_data/editorial/ROADMAP.md`.
- Changed behavior requires aligned documentation evidence or explicit `not impacted because ...`.
- Skill-contract changes route through `900-shipglows-core build`; app-rendered skill content does not receive ShipGlows governance frontmatter.
- Validate only the selected surface plus every artifact mutated by it. A passing structure or metadata check does not prove semantic preservation.

## Stop Conditions

Stop as `blocked` when a required reference has no safe fallback; ownership is unresolved; migration would overwrite/discard content without a merge/preservation decision; changed metadata cannot lint; `AGENTS.md` conflicts with `AGENT.md`; external truth lacks freshness proof; or a skill promise/lifecycle route changes without a bounded maintenance contract.

## Reporting

Before the final report, load `skills/references/reporting-contract.md`. When exactly one active `shipglows_data/workflow/specs/*.md` chantier owns the work, also load `skills/references/chantier-tracking.md`, update its history/flow, and use the spec header. Otherwise use a concise `(local)` chantier header. Default to outcome-first `report=user`; use `report=agent` for blocked runs, handoff, or explicit detail.

## Validation

Run focused checks for touched surfaces. Include topology audit and metadata lint for changed governed artifacts. Prove migrations with diff plus targeted searches. Skill scope requires budget audit, sync check, and focused contracts; rendered public skill pages require a site build.
