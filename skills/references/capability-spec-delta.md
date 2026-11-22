---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-22"
updated: "2026-11-22"
status: active
source_skill: 100-sg-spec
scope: capability-spec-delta
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - templates/spec.md
  - tools/spec_delta_merge.py
  - skills/references/closure-archive-guard.md
  - skills/104-sg-end/references/closure-bookkeeping-playbook.md
  - skills/103-sg-verify/references/living-spec-conformance.md
  - shipglows_data/workflow/specs/capabilities/
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-11-22: keep OpenSpec's delta specs and living specs as a format, without reintroducing the OpenSpec tool removed on 2026-03-23."
next_review: "2027-02-22"
next_step: none
---

# Capability Spec Delta

## Purpose

A change spec in `shipglows_data/workflow/specs/<slug>.md` describes one change. A living spec in `shipglows_data/workflow/specs/capabilities/<domain>.md` states the requirements in force for one capability, so current behavior is read in one file instead of N change specs. The change spec carries a delta; closure merges it into the living spec.

This is a format plus one small merge tool. No OpenSpec CLI, change folders, proposal files, or extra lifecycle stage.

## Requirement Format

Used identically in deltas and living specs:

```markdown
### Requirement: <name>

The <actor/system> SHALL <observable obligation>.

#### Scenario: <name>

- **WHEN** <trigger or state>
- **THEN** <observable result>
```

- The statement uses `SHALL` or `MUST`; state behavior, never implementation.
- Each requirement has at least one scenario with a `**WHEN**` and a `**THEN**` bullet; `**GIVEN**` and `**AND**` bullets are optional.
- The name identifies the requirement inside its capability; matching ignores case and repeated spaces. Rename by `REMOVED` plus `ADDED`.

## Delta In A Change Spec

```markdown
## Capability Delta

- Capability: `<domain>`

## ADDED Requirements
## MODIFIED Requirements
## REMOVED Requirements
```

- `Capability` is a lowercase slug naming `capabilities/<domain>.md`. Write `- Capability: none, because <reason>` when no capability behavior changes (docs, refactor, tooling without a behavior contract).
- `ADDED`: new requirements. `MODIFIED`: the complete new text of an existing requirement, same name; it replaces the old block wholesale. `REMOVED`: the name plus a mandatory `**Reason**: ...` line.
- Empty blocks contain `None`. A second capability repeats `## Capability Delta` followed by its own blocks.
- Acceptance criteria stay: `AC n` proves this change; requirements state what remains true afterwards. Each new or modified scenario should be covered by at least one AC or named test.

## Living Spec

`# Capability: <domain>`, `## Purpose`, `## Requirements` (requirement blocks only), then `## Change History` (`Date | Change spec | Operation | Requirement | Reason`). Choose a stable behavior domain (`auth-session`, `billing-trial`), never a chantier name. Seed a capability only from behavior proven in force; never bulk-rewrite old change specs into capabilities.

## Merge At Closure

Merge only when the change is implemented and verified, during closure:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/spec_delta_merge.py" shipglows_data/workflow/specs/<slug>.md --check
python3 "${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/spec_delta_merge.py" shipglows_data/workflow/specs/<slug>.md
```

- `ADDED` appends, `MODIFIED` replaces the requirement of the same name, `REMOVED` deletes and records its reason in `Change History`.
- The merge is all-or-nothing across capabilities. It refuses, writing nothing, when a `MODIFIED` or `REMOVED` requirement is not in the living spec, an `ADDED` one already exists, a requirement is malformed, or the change spec is already in `Change History`.
- `--create` lets an `ADDED`-only delta create a missing capability file; complete its `Purpose` and frontmatter afterwards.
- `--validate <capability.md | capabilities dir>` checks living specs without merging.
- A refusal is a closure limit: fix the delta or the living spec, never hand-edit around the tool to force closure.

Never merge a delta for unimplemented, unverified, or abandoned work; the living spec must describe reality.
