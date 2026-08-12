---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
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

Before accepting an invocation, it validates the registry-owned activation graph: every public wrapper and declared engine must exist, every alias must resolve through a declared owner mode, and every installed expert must be owned by at least one public route. Run the same preflight directly with:

```bash
python3 "$SHIPGLOWS_ROOT/tools/skill_invocation_check.py" --audit-graph
```

This graph describes skill ownership and activation only. Reference-level `depends_on` metadata remains resource governance and is not inferred from prose.

- `valid`: continue with the explicit skill silently.
- `invalid`: do not activate any skill; explain the exact error and show a suggestion only when the registry has one uniquely supported correction. A clear spelling typo may receive a `did_you_mean` suggestion.
- `ambiguous`: do not activate any skill; ask one plain-language question.

Never auto-execute a suggested skill, including a typo correction. Ambiguous
or distant spellings remain invalid without a guessed route. This preflight
applies only to explicit skill commands; natural-language routing and
deterministic micro-edits keep their existing paths.
