---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: ShipGlows
created: "2026-07-29"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: explicit-skill-invocation-preflight
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - tools/skill_invocation_check.py
  - tools/resource_dependency_graph.py
  - skills/references/skill-invocation-registry.json
  - skills/references/skill-code-index.md
  - skills/000-shipglows/SKILL.md
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-29: explicit commands are checked automatically across master skills."
  - "Recovery 2026-08-03: the original untracked implementation was recovered selectively from Git stash and migrated to the canonical ShipGlows namespace."
  - "Wave 9: invocation validation now blocks inconsistent public-to-engine activation graphs before routing."
  - "Wave 10: selected pilot skills also block when their explicit reference-activation profile is inconsistent."
  - "Wave 13: preflight combines ownership validation with the explicit dependency closure of profiled resources."
  - "Wave 14: executable profile preflight covers six measured owners, including high-traffic 010, 103, and 300."
next_review: "2026-09-03"
next_step: "none"
---

# Explicit Skill Invocation Preflight

Before handing off an explicit ShipGlows skill invocation, run:

```bash
python3 "$SHIPGLOWS_ROOT/tools/skill_invocation_check.py" "$ARGUMENTS"
```

The checker is read-only. It resolves public names from
`skill-invocation-registry.json` and retains `skill-code-index.md` only for
explicit expert/legacy engine invocations.

Before accepting an invocation, it validates the registry-owned ownership graph: every public wrapper and declared engine must exist, every alias must resolve through a declared owner mode, and every installed expert must be owned by at least one public route. It then validates the explicit dependency closure declared by activation-profile resources. Run the combined preflight directly with:

```bash
python3 "$SHIPGLOWS_ROOT/tools/skill_invocation_check.py" --audit-graph
```

The resource closure follows explicit `depends_on` edges under `skills/**` transitively. Profiled `shipglows_data/**` artifacts are checked as terminal governance leaves. Every traversed edge must declare `artifact_version` and `required_status`; missing targets, invalid or insufficient versions, mismatched or unsupported statuses, and reachable cycles block activation. Nothing is inferred from prose or `linked_systems`.

The default graph audit covers the executable activation-profile closure. `python3 "$SHIPGLOWS_ROOT/tools/resource_dependency_graph.py" --all` is a separate diagnostic for historical corpus debt; its findings do not block an otherwise valid profiled invocation.

When the selected engine declares an `activation_profiles.skills` entry in the same registry, preflight validates that profile's body and reference paths before returning `valid`. Six profiles are currently measured: `004`, `010`, `103`, `300`, `601`, and `900`. Profiles remain incremental: undeclared skills keep their existing invocation behavior, and declared runtime loaders remain authoritative.

- `valid`: continue with the explicit skill silently.
- `invalid`: do not activate any skill; explain the exact error and show a suggestion only when the registry has one uniquely supported correction. A clear spelling typo may receive a `did_you_mean` suggestion.
- `ambiguous`: do not activate any skill; ask one plain-language question.

Never auto-execute a suggested skill, including a typo correction. Ambiguous
or distant spellings remain invalid without a guessed route. This preflight
applies only to explicit skill commands; natural-language routing and
deterministic micro-edits keep their existing paths.
