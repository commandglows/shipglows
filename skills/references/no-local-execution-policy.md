---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-20"
updated: "2026-08-20"
status: active
source_skill: 708-sg-auto
scope: no-local-workload-execution
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/000-shipglows/SKILL.md
  - skills/708-sg-auto/SKILL.md
  - skills/references/mutation-plan-approval.md
  - skills/references/spec-driven-development-discipline.md
depends_on:
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.7.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-20: no-local execution must exist independently from credit-window autonomy."
  - "Operator decision 2026-08-20: auto must spend the available window on model reasoning and generation rather than waiting for builds, tests, or installation."
  - "Operator decision 2026-08-20: auto always implies nolocal, including for every delegated subagent."
next_review: "2026-09-20"
next_step: "/103-sg-verify shipglows auto and nolocal modes"
---

# No-Local Execution Policy

## Purpose

Apply this policy when the operator invokes `shipglows nolocal <objective>` or
when another contract, including `shipglows auto`, explicitly composes it. It
restricts workload and external-state execution while preserving the static
inspection and file editing needed to produce useful work.

`nolocal` is an execution policy. It does not select work, grant mutation
authority, waive a material product or safety decision, or imply autonomous
portfolio execution. `nolocal` alone grants no mutation authority; the normal
mutation approval contract remains active unless another exact authority owns
the run.

## Allowed operations

- discover, search, and read in-scope source, governance, roadmap, planning,
  specifications, configuration, and documentation;
- perform static reasoning over those files and current read-only evidence;
- create or edit bounded in-scope code, tests, specifications, documentation,
  and configuration without executing the resulting workload;
- use read-only Git status and diff inspection, plus similarly static ownership
  checks that cannot mutate repository or external state;
- use read-only current official or primary-source research when freshness is
  material and no external write, authentication, or private data is involved;
- prepare deferred verification commands and a precise handoff without running
  them.
- when `shipglows auto` composes this policy, execute only the canonical
  `$SHIPGLOWS_ROOT/tools/shipglows_auto_claim.py` helper to maintain minimal ignored claims
  below the frozen project root; this is control-plane bookkeeping, not
  permission to execute project tooling or any arbitrary local script.

Shell-based file discovery or text inspection is allowed when it remains
read-only. `nolocal` means no application or validation workload execution; it
does not mean that an agent must reason without reading the repository.

## Forbidden operations

Do not run or trigger:

- builds, tests, test runners, snapshots, coverage, benchmarks, or smoke suites;
- lint, formatters that write, typechecks, static analyzers, scanners, or code
  generators that execute project tooling;
- dependency installation, dependency upgrades, package-manager resolution,
  bootstrap, setup, or environment installation;
- application servers, workers, queues, watchers, browser automation, browsers,
  emulators, simulators, device tooling, containers, or virtual machines;
- executed migrations, seeds, data jobs, infrastructure plans/applies, or
  commands that mutate a database, cache, service, provider, or runtime;
- commits, amends, rebases, merges, tags, pushes, pull requests, releases,
  publication, deployments, messages, or other external writes;
- credentials, secrets, permissions, auth policy, billing, production, tenant,
  or irreversible/destructive state changes.

Do not replace a forbidden command with an equivalent wrapper, remote runner,
CI dispatch, delegated agent, MCP tool, browser tool, or provider call. The
policy follows the effect, not the command name or host. Every subagent inherits
the same prohibition and may not escape it through another agent.

## Proof and status

Use `exception-with-proof` for the implementation run: static contract review
and diff inspection may support the state `implemented — unverified`, but they
do not establish runtime behavior. List the smallest deferred verification
commands in dependency order for a later normal verification run.

Never use `fixed`, `verified`, `secure`, `compliant`, `complete`, `closed`,
`shipped`, or equivalent completion language for behavior that depends on a
forbidden proof surface. Do not close a spec, bug, audit finding, or release
scope from no-local evidence alone.

## Stop and handoff

Stop the current slice when safe implementation requires executing a forbidden
operation, observing runtime behavior, accessing secrets/private data, changing
authority, or overwriting unrelated work. In `shipglows auto`, return control to
the auto candidate loop so it can skip that candidate and continue. In ordinary
`shipglows nolocal`, follow the selected owner's normal blocked or decision
contract.

The handoff records changed files, assumptions, known gaps, deferred commands,
and the exact first normal proof owner. A deferred command is an instruction for
later; never execute it inside this policy.

## Pressure scenarios

- `NOLOCAL-STATIC-EDIT`: inspect and edit source, then report `implemented — unverified`; do not run the prepared test.
- `NOLOCAL-WRAPPER-BYPASS`: a CI, MCP, container, remote runner, or subagent that would execute a forbidden effect remains forbidden.
- `NOLOCAL-READONLY-GIT`: `status` and `diff` inspection are allowed; commit, branch mutation, worktree creation, tag, push, and PR writes are not.
- `NOLOCAL-SEPARATE-AUTHORITY`: `shipglows nolocal <objective>` still follows ordinary mutation approval; only an independently applicable authority can permit edits.
- `NOLOCAL-RUNTIME-DEPENDENCY`: when the next safe decision requires a build, test, server, browser, provider, or migration result, stop or skip rather than guess.
