---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-02"
updated: "2026-08-02"
status: active
source_skill: 102-sg-start
scope: atlas-protection-preflight
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - tools/shipglows_atlas_preflight.py
  - tools/shipglows_atlas_import.py
  - shipglows_data/workflow/atlas/approved-surfaces.json
  - skills/101-sg-ready/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/005-sg-ship/SKILL.md
depends_on:
  - artifact: shipglows_data/workflow/specs/approved-surface-protection-and-product-atlas.md
    artifact_version: "1.4.0"
    required_status: ready
supersedes: []
evidence:
  - "Operator decision 2026-08-02: approved visible results must not be silently broken by agents."
next_review: "2026-09-02"
next_step: "/103-sg-verify Approved Surface Protection And Product Atlas"
---

# Atlas Protection Preflight

When a project owns `shipglows_data/workflow/atlas/approved-surfaces.json`, an agent must resolve Atlas impact before writing code that may affect a registered surface or function.

Run the ShipGlows-owned tool with every intended project-relative path:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/shipglows_atlas_preflight.py" \
  --atlas shipglows_data/workflow/atlas/approved-surfaces.json \
  --project-root . \
  --changed site/src/components/Hero.astro
```

The result is one of:

- `clear`: every path resolves and no protected dimension is affected.
- `review`: one or more paths are not in the impact map. Expand the map or explicitly establish no impact before writing; do not claim protection coverage for those paths.
- `block`: a Gold/Diamond `copy`, `design`, or `function` target is affected without a matching authorization. Do not write.

An authorization is exact and dimension-scoped: `--allow home.hero:design` or `--allow payment.process:function`. It is valid only when the active request/spec explicitly grants that exact surface/function and dimension. It never authorizes `structure`, `behavior`, another target, or another dimension.

The tool is an impact resolver, not permission escalation. It reads the canonical Atlas only, writes nothing, and treats unknown paths conservatively. It uses `surfaces[].impact_paths` and `functions[].dependencies`; project Atlas maintainers must keep those paths project-relative and current.

## Lifecycle Rules

- `101-sg-ready`: require named surface/function IDs, dimensions and authorization/proof planning when a spec can touch a registered protected target.
- `102-sg-start` and `106-sg-fix`: run the preflight before the first write and stop on `block`.
- `103-sg-verify`: rerun it against actual changed paths; unresolved `review` or any `block` prevents a clean verification verdict.
- `005-sg-ship`: rerun it against the staged release diff; a `block` prevents ship preparation.

No Atlas in the project is `not applicable`; do not invent one during unrelated work.
