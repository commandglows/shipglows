---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-20"
updated: "2026-08-20"
status: active
source_skill: 900-shipglows-core
scope: execution-posture-tags
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/708-sg-auto/SKILL.md
  - skills/references/shipglows-terms.md
  - skills/references/no-local-execution-policy.md
  - skills/references/skill-invocation-preflight.md
  - skills/references/skill-invocation-registry.json
  - tools/skill_invocation_check.py
depends_on:
  - artifact: skills/references/no-local-execution-policy.md
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-20: local, nolocal, and ci are transversal command tags rather than métier modes; auto remains a mode and implies nolocal."
  - "Operator decision 2026-08-20: retain shipglows nolocal as a legacy compatibility alias and enrich mode/tag documentation."
next_review: "2026-09-20"
next_step: "/103-sg-verify execution posture tags"
---

# Execution Posture Tags

## Purpose

`#local`, `#nolocal`, and `#ci` are position-independent execution posture
tags for ShipGlows agent invocations. They refine how the selected owner may
gather proof; they are not métier modes, owner selectors, authority grants, or
shell CLI flags.

## Canonical semantics

| Tag | Effect |
| --- | --- |
| `#local` | Permit proportional local workloads under the selected owner's normal authority and safety gates. It never requires a build or test merely because the tag is present. |
| `#nolocal` | Apply `no-local-execution-policy.md`: static inspection and bounded edits may continue, while application, validation, installation, runtime, Git-write, deployment, and external-write effects are deferred. |
| `#ci` | Imply `#nolocal` and name an existing CI pipeline as the deferred executable proof target. It does not authorize commit, push, workflow dispatch, remote execution, deployment, or any other external write. |

If CI is absent, inaccessible, or cannot prove the changed surface, retain
`implemented — unverified`; never fall back silently to local execution or
invent a CI result.

## Composition and conflicts

- Tags may appear before, between, or after an agent command's ordinary
  tokens. Duplicate tags collapse to one effective tag.
- `#local` conflicts with `#nolocal` and `#ci`; reject the invocation rather
  than guessing precedence.
- `#nolocal #ci` is valid: `#ci` supplies the deferred proof destination and
  already implies `#nolocal`.
- Ordinary focus tags such as `#docs`, `#quality`, or `#proof` remain separate
  routing cues and are not consumed as execution posture tags.
- Tags narrow or permit execution only within existing authority. A tag does
  not authorize mutation, secrets, destructive work, publication, external
  effects, or lifecycle closure.

## Auto and compatibility

`shipglows auto` always implies `#nolocal`. Explicit `#nolocal` is redundant,
`#ci` is allowed as a deferred proof destination, and `#local` is invalid. The
same rules apply to every delegated auto mission.

`shipglows nolocal <objective>` remains a legacy compatibility alias. Normalize
it to `shipglows <objective> #nolocal`, preserve the objective and ordinary
owner, and grant no additional authority. New documentation and examples use
the tag form.

## Agent syntax versus shell syntax

These are agent-conversation tags. In shells such as Bash, an unquoted `#`
starts a shell comment, so `#local`, `#nolocal`, and `#ci` must not be presented
as native shell arguments. When running the read-only invocation checker from a
shell, quote the complete invocation string.

## Pressure scenarios

- `POSTURE-CI-IMPLIES-NOLOCAL`: `sg-engineering verify checkout #ci` defers
  executable proof to CI and performs no local or remote workload itself.
- `POSTURE-CONFLICT`: `#local #nolocal` and `#local #ci` fail closed.
- `POSTURE-AUTO`: `shipglows auto` receives effective `#nolocal`, while
  `shipglows auto #local` is invalid.
- `POSTURE-LEGACY`: `shipglows nolocal improve checkout` normalizes to the
  default router objective plus `#nolocal`.
- `POSTURE-NO-AUTHORITY`: no posture tag authorizes mutation, push, CI dispatch,
  deploy, or closure by itself.
