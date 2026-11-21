---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.7.0"
project: ShipGlows
created: "2026-07-29"
updated: "2026-11-21"
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
  - skills/references/execution-posture-tags.md
depends_on:
  - artifact: "skills/references/skill-code-index.md"
    artifact_version: "2.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decisions 2026-07-29 and 2026-08-20: automatic explicit-command checks; fail-closed posture tags."
  - "Waves 9-14: ownership graph, dependency closure and activation profiles block before routing."
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

It removes only registry-declared execution posture tags, wherever placed, and
returns requested, implied and effective tags (`execution-posture-tags.md` owns
implications; conflicts are invalid). Other focus tags remain part of the
instruction. Mode-implied posture applies after routing, so `shipglows blitz`
always receives effective `#nolocal` and rejects `#local`. Legacy
`shipglows nolocal <objective>` normalizes to the default router objective plus `#nolocal`.

Before accepting, it validates the registry-owned ownership graph (every wrapper,
engine and alias resolves through a declared owner mode; every installed expert has
a public owner), the explicit `depends_on` closure of activation-profile resources,
and the selected engine's declared activation profile. Nothing is inferred from
prose or `linked_systems`. Run the graph audit alone with `--audit-graph`;
`tools/resource_dependency_graph.py --all` is a non-blocking historical diagnostic.

- `valid`: continue with the explicit skill silently.
- `invalid`: do not activate any skill; explain the exact error and show a suggestion only when the registry has one uniquely supported correction. A clear spelling typo may receive a `did_you_mean` suggestion.
- `ambiguous`: do not activate any skill; ask one plain-language question.

Never auto-execute a suggested skill, including a typo correction. Ambiguous
or distant spellings remain invalid without a guessed route. This preflight
applies only to explicit skill commands; natural-language routing and
deterministic micro-edits keep their existing paths.
