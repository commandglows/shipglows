---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-20"
updated: "2026-10-24"
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
  - skills/708-sg-blitz/SKILL.md
  - skills/709-sg-auto/SKILL.md
  - tools/shipglows_execution_profile.py
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
  - "Operator decision 2026-10-24: add granular per-workload tags (build, test, server, commit, ci) and a saved default execution profile changed on request rather than per invocation."
  - "Operator decision 2026-08-20: retain shipglows nolocal as a legacy compatibility alias and enrich mode/tag documentation."
next_review: "2026-09-20"
next_step: "/103-sg-verify execution posture tags"
---

# Execution Posture Tags

## Purpose

Execution posture tags are position-independent tags for ShipGlows agent
invocations. `#local`, `#nolocal`, and `#ci` are presets; the granular tags
control one workload each. They refine how the selected owner may
gather proof; they are not métier modes, owner selectors, authority grants, or
shell CLI flags.

## Canonical semantics

| Tag | Effect |
| --- | --- |
| `#local` | Permit proportional local workloads under the selected owner's normal authority and safety gates. It never requires a build or test merely because the tag is present. |
| `#nolocal` | Apply `no-local-execution-policy.md`: static inspection and bounded edits may continue, while application, validation, installation, runtime, Git-write, deployment, and external-write effects are deferred. |
| `#ci` | Imply `#nolocal` and name an existing CI pipeline as the deferred executable proof target. It does not authorize commit, push, workflow dispatch, remote execution, deployment, or any other external write. |

Granular tags, one workload each:

| Tag pair | Workload |
| --- | --- |
| `#build` / `#nobuild` | builds, bundles, release or standalone artifacts |
| `#test` / `#notest` | tests, lint, analyze, type checks, formatters that check |
| `#server` / `#noserver` | managed dev sessions through `shipglows-dev` and browser proof |
| `#commit` / `#nocommit` | exact-scope local commits under existing authority |
| `#noci` | never name or plan CI as a proof destination; `#ci` is its opposite |

`#nolocal` implies `#nobuild #notest #noserver #nocommit`; `#ci` implies
`#nolocal`. A positive granular tag permits a workload only within the
selected owner's authority and never forces it.

If CI is absent, inaccessible, or cannot prove the changed surface, retain
`implemented — unverified`; never fall back silently to local execution or
invent a CI result.

## Composition and conflicts

- Tags may appear before, between, or after an agent command's ordinary
  tokens. Duplicate tags collapse to one effective tag.
- `#local` conflicts with `#nolocal` and `#ci`; reject the invocation rather
  than guessing precedence.
- Each positive tag conflicts with its `#no…` pair, `#ci` conflicts with
  `#noci`, and `#nolocal` (or `#ci`) conflicts with `#build`, `#test`,
  `#server`, and `#commit` through its implications.
- `#local` combines with negative granular tags: `#local #notest` permits
  proportional local work except tests.
- `#nolocal #ci` is valid: `#ci` supplies the deferred proof destination and
  already implies `#nolocal`.
- Ordinary focus tags such as `#docs`, `#quality`, or `#proof` remain separate
  routing cues and are not consumed as execution posture tags.
- Tags narrow or permit execution only within existing authority. A tag does
  not authorize mutation, secrets, destructive work, publication, external
  effects, or lifecycle closure.

## Default execution profile

Without a tag, each workload follows the saved default profile. Resolve the
effective value per workload with
`$SHIPGLOWS_ROOT/tools/shipglows_execution_profile.py resolve --project <root> [--mode <mode>] --tags <tags>`.
Precedence, highest first: explicit invocation tags, mode defaults (`auto`
permits test, server and commit; `blitz` denies every local workload),
project profile `shipglows_data/execution-profile.json`, user profile
`~/.shipglows/state/execution-profile.json`, built-in defaults (build and CI
denied; test, server and commit allowed).

A tag is a one-off exception. When the operator asks to change the default
(`shipglows profile`, « change mon profil par défaut »), update the saved
profile with the helper's `set` command (`--scope user` by default,
`--scope project --project <root>` for one project) and report the new values.
Never hand-edit the file. Push, PR, CI dispatch, deployment and other external
effects are authority questions, never profile values.

## Blitz and compatibility

`shipglows blitz` always implies `#nolocal`. Explicit `#nolocal` is redundant,
`#ci` is allowed as a deferred proof destination, and `#local` is invalid. The
same rules apply to every delegated blitz mission.

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
- `POSTURE-BLITZ`: `shipglows blitz` receives effective `#nolocal`, while
  `shipglows blitz #local` is invalid.
- `POSTURE-LEGACY`: `shipglows nolocal improve checkout` normalizes to the
  default router objective plus `#nolocal`.
- `POSTURE-GRANULAR`: `sg-development fix login #notest` may use the dev
  server and commit but runs no test, lint or type check.
- `POSTURE-PROFILE`: with a saved `test=deny` profile, a plain command runs no
  test; `#test` permits tests for that invocation only.
- `POSTURE-PROFILE-CHANGE`: « change mon profil par défaut, autorise les
  tests » runs `shipglows_execution_profile.py set test=allow`.
- `POSTURE-NO-AUTHORITY`: no posture tag authorizes mutation, push, CI dispatch,
  deploy, or closure by itself.
