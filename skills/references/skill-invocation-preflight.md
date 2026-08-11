---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.2"
project: ShipGlows
created: "2026-07-29"
updated: "2026-08-11"
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

- `valid`: continue with the explicit skill silently.
- `invalid`: do not activate any skill; explain the exact error and show a suggestion only when the registry has one uniquely supported correction. A clear spelling typo may receive a `did_you_mean` suggestion.
- `ambiguous`: do not activate any skill; ask one plain-language question.

Never auto-execute a suggested skill, including a typo correction. Ambiguous
or distant spellings remain invalid without a guessed route. This preflight
applies only to explicit skill commands; natural-language routing and
deterministic micro-edits keep their existing paths.
