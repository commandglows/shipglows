---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-08-03"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: progressive-resource-discovery
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/resource_resolver.py
  - tools/resource_dependency_graph.py
  - skills/references/canonical-paths.md
  - skills/references/skill-instruction-layering.md
  - skills/references/
  - skills/*/references/
  - shipglows_data/workflow/playbooks/
  - skills/references/ux-reference-intelligence.md
  - skills/references/ux-reference-connectors.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.8.0"
    required_status: active
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-03: prefer smaller searchable reference files and provide agents a governed way to discover the most relevant resources."
  - "Scenario tests prove landing-page starter-pack ranking, exact ID resolution, expansion, inactive filtering, deterministic output, and bounded failure behavior."
  - "2026-08-12 resolver audit found eight-result starter packs between about 16000 and 18500 estimated tokens when only result count was bounded."
  - "Operator decision 2026-08-12: bound advisory reference loading by count and estimated tokens without building a new dependency graph."
  - "Wave 13 added a separate blocking graph for explicit activation-profile dependencies; advisory resolver ranking remains unchanged."
  - "Operator decision 2026-08-24: relevant skills must use one shared external-experience source system and reject sources that are unavailable, stale, rights-restricted, or irrelevant."
next_review: "2026-09-03"
next_step: "Review semantic resource-profile migration after resolver adoption evidence."
---

# Progressive Resource Discovery

## Purpose

Give ShipGlows agents a bounded, explainable way to find relevant references and playbooks after a skill and mode are known. The resolver reduces physical-path coupling and ad hoc filesystem search; it does not replace skill ownership, required gates, or project evidence.

This resolver is advisory discovery. It is separate from `tools/resource_dependency_graph.py`, which blocks profiled invocation when explicit `depends_on` paths, version/status constraints, or cycles are inconsistent. Resolver scores and `linked_systems` never create dependency edges.

## Discovery Sequence

For non-trivial work that may benefit from supporting doctrine beyond the activation contract:

1. Select the owner skill and mode first.
2. Resolve every activation-critical resource explicitly required by that skill.
3. Ask the resolver for a small starter pack using the skill, mode, and bounded user intent.
4. Read only the resources needed for the current decision.
5. Expand one selected resource when its declared dependencies or linked systems materially affect the task.
6. Stop discovery when the owner contract and proof path are sufficient.

Do not load the whole corpus, recursively chase every link, or treat a high lexical score as authority.

## External Experience Evidence

The resolver discovers internal ShipGlows resources; it does not call external
providers. When construction, specification, design, or customer-experience
work needs external experience evidence for a material journey, interaction,
navigation model, or visual direction, exact-resolve
`shared:ux-reference-intelligence`, then
`shared:ux-reference-connectors`. Apply their runtime availability, freshness,
eligibility, authority, rights, and fallback rules before using any external
source. Do not rely on starter-pack ranking to activate this mandatory gate.

## Resolver Commands

Starter pack:

```bash
python3 "$SHIPGLOWS_ROOT/tools/resource_resolver.py" \
  --skill 009-sg-marketing \
  --mode copywriting \
  --intent "landing page section flow and repetition" \
  --limit 8 \
  --max-tokens 12000
```

Resolve one semantic resource ID:

```bash
python3 "$SHIPGLOWS_ROOT/tools/resource_resolver.py" \
  --get shared:landing-page-copywriting-framework
```

Expand one resource into declared neighbors:

```bash
python3 "$SHIPGLOWS_ROOT/tools/resource_resolver.py" \
  --expand shared:landing-page-copywriting-framework
```

The JSON result exposes stable ID, resolved canonical path, type, actual status, score, reasons, estimated tokens, aggregate token use, and skipped candidates. Use `--format text` only for compact human inspection.

## Starter-Pack Budget

- Apply both result-count and estimated-token limits. The default advisory ceiling is 12,000 estimated tokens.
- Estimate deterministically from file characters; this is a context guard, not provider billing telemetry.
- Deduplicate canonical paths before accounting.
- If a candidate does not fit the remaining budget, skip it whole and report its ID, status, estimate, and reason. Never silently truncate a normative resource.
- Mandatory activation references are resolved before this advisory pack and accounted separately.
- A single oversized result does not authorize raising the cap. The caller may exact-resolve it after checking authority and relevance.

Statuses remain literal. `active` gets the normal trust preference; `draft`, `unknown`, and `reviewed` are visibly labelled and never silently promoted to `active`. Inactive statuses stay excluded unless diagnostic inclusion was explicitly requested.

## Authority Boundary

- A `required` skill gate remains mandatory even when it ranks poorly or does not appear in a bounded starter pack.
- A discovered resource is advisory until its status, owner boundary, freshness, and applicability are checked.
- Project-owned product, business, brand, technical, editorial, Atlas, security, and claim contracts remain authoritative for project truth.
- An inactive resource is excluded by default. Explicit inclusion is diagnostic, not permission to apply it.
- The resolver never selects a skill, invokes a workflow, edits a file, accesses the network, or searches outside canonical ShipGlows resource roots.

## Semantic IDs And Migration

Prefer stable semantic IDs over physical paths in new cross-skill discovery contracts:

- `shared:<relative-stem>` for shared references;
- `<skill-name>:<relative-stem>` for skill-local references;
- `workflow:<relative-stem>` for reusable workflow playbooks.

During migration, existing physical loaders remain valid and mandatory. Replace one only after an exact semantic-ID lookup, owner gate, missing-resource failure, runtime portability, and focused scenario test prove equivalent followability. Do not bulk-remove paths merely because the resolver exists.

## Metadata Guidance

Small references remain searchable when their frontmatter and first headings accurately expose:

- artifact type and active status;
- narrow scope;
- source skill or owner;
- linked systems and dependencies;
- a specific title and purpose.

Do not add keyword stuffing or duplicate prose for ranking. Improve the actual scope, links, and headings instead.

## Pressure Scenarios

- `RESOURCE-STARTER`: a landing-page copywriting intent under `009-sg-marketing` returns the shared landing framework and local copywriting playbook with explicit reasons.
- `RESOURCE-IRRELEVANT`: a dependency-audit intent under `010-sg-technical` does not surface the landing framework in its bounded top results.
- `RESOURCE-EXACT`: a stable resource ID resolves one canonical file or fails visibly; it never guesses between collisions.
- `RESOURCE-EXPAND`: expanding a resource returns directly declared dependencies and linked owner resources before loose lexical neighbors.
- `RESOURCE-AUTHORITY`: a recommended resource never overrides a mandatory activation gate, inactive status, or project source of truth.
- `RESOURCE-BOUNDARY`: resolver execution performs no write, network, subprocess, skill activation, or arbitrary filesystem traversal.
- `RESOURCE-TOKEN-BOUND`: selected unique resources fit both limits and every skipped oversized candidate is visible.
- `RESOURCE-STATUS`: `active`, `draft`, `unknown`, and `reviewed` remain distinguishable in ranking and output.
