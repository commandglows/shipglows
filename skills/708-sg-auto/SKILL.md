---
name: 708-sg-auto
description: "Autonomous useful-work window for evidence-backed project improvements without local workload execution."
---

Primary artifact type: `master-workflow`.

## Canonical paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before resolving
ShipGlows-owned files. Project evidence and edits resolve from the current
project root. Do not infer a different project to find more work.

## Mission

Use a bounded AI-credit window to maximize useful project value delivered per
wall-clock minute from existing roadmap, planning, specs, backlog,
architecture, security, or compliance evidence. Continue without avoidable
operator discussion, skip blocked candidates, and never manufacture work,
reasoning, agents, or output merely to consume credits.

`shipglows auto` always and implicitly applies
`$SHIPGLOWS_ROOT/skills/references/no-local-execution-policy.md`. `nolocal`
cannot be disabled in this mode: `auto local` is invalid and `auto nolocal` is
only a redundant spelling with identical behavior.

## Frozen project root

At activation, resolve and freeze the current project root, using the current
Git top-level when available and otherwise the already resolved managed project
root. This is the sole work root for the full run. The parent and every
subagent must receive it explicitly and may discover, claim, or edit project
work only below it. Resolve every owned path canonically; reject `..` traversal
and any symlink whose real target leaves the frozen root. Do not switch to a sibling repository, clone another
repository, create or enter another worktree, or follow roadmap references into
another project to find more work.

Canonical ShipGlows contracts and current official sources may be read outside
the work root when required, but they never expand the project scope and no
outside-project file may be edited.

## Authority and ownership

Before any mutation, load
`$SHIPGLOWS_ROOT/skills/references/mutation-plan-approval.md` and apply only its
bounded Auto-session authority. It permits safe, reversible, current-project
local edits during this explicit mode; it never permits destructive,
privileged, secret, permission, billing, production, external, commit, push, or
deployment effects.

Trace category: `conditionnel`. Process role: `lifecycle`. Each selected ready
work item keeps its existing owner and durable source of truth. This engine
selects and coordinates candidates but does not merge several chantiers into a
new tracker, close them, or replace their owner contracts. Unattached static
audits remain local findings and may prepare a future spec without claiming a
verified security or compliance result.

## Mode contract

Treat remaining arguments as an optional project-local scope or horizon. A
missing horizon means the current agent run until platform stop, operator
interruption, or exhaustion of safe actionable candidates; never promise to
consume an exact balance that the runtime cannot observe.

Load `$SHIPGLOWS_ROOT/skills/708-sg-auto/references/auto-credit-window-playbook.md`
before candidate discovery. It owns evidence eligibility, priority order,
continuous execution, skip behavior, topology, and the final portfolio handoff.
Load
`$SHIPGLOWS_ROOT/skills/708-sg-auto/references/auto-session-coordination.md`
before every mutating candidate. Every mutation requires an atomic claim in
the captured Git root, even when no other conversation is known. A managed
non-Git root remains valid for read-only discovery and audit only; skip all
mutation there as `coordination unavailable`.
Load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` before
dispatching agents and the selected owner's contract before editing its
surface. Do not load unrelated owner skills speculatively.

Fast is a client/service-tier setting, not an authority or reasoning level. Use
it when the runtime proves it is already active. Never claim to self-activate
Fast, issue a client slash command on the operator's behalf, edit user-level
Codex configuration, pause for Fast, or infer its state. When it is not
observable, record `Fast: unknown/not applied` internally and continue.

## Execution invariants

- Safety, authority, root confinement, evidence, cross-conversation claims,
  dirty-file ownership, and readiness gate the candidate pool.
- Within that pool, expected durable value per wall-clock minute is the primary
  ordering dimension. Reasoning depth, model choice, generation volume, and
  agent count are task-fit means, never goals or credit-burning proxies.
- Prefer deep architecture, security/compliance, multi-file implementation,
  complex refactoring, and large-context review over small mechanical work.
- Subagents are authorized and recommended when two or more independent useful
  missions can improve elapsed time, isolation, or coverage. Use available
  parallelism without creating duplicate analysis or handoff ceremony. Keep a
  cohesive task main-only when delegation adds no material value.
- Choose the lowest reasoning effort that preserves the required quality.
  `high` is a normal baseline for complex auto work; use `xhigh`, `max`, or
  `ultra` only when concrete ambiguity, architecture, security, or error cost
  justifies the additional reasoning. Never escalate effort on a time curve or
  because credits may expire.
- After a candidate is selected, preserve its owner, architecture, acceptance
  contract, and security boundary; do not use auto as permission to invent
  product truth.
- If routine proof or a material decision blocks one candidate, skip the
  candidate and continue: skip the candidate and continue with the next safe one. Ask only when the whole run
  cannot continue safely without operator-owned authority or truth.
- Every applied slice remains `implemented — unverified` and retains deferred
  proof. Never claim `fixed`, `verified`, `secure`, `compliant`, `closed`, or
  `shipped`.

## Stop conditions

Stop the run when no safe actionable candidate remains; the horizon or platform
ends; the project cannot be resolved; all remaining work conflicts with dirty
ownership; or progress would require forbidden workload execution, destructive
or privileged action, secrets/private data, permission/auth/billing/production
changes, external writes, or a material product decision absent from governed
truth.

Never modify this auto engine, its no-local policy, mutation authority,
permissions configuration, or equivalent autonomy guardrail from inside an
auto run. Such self-expansion requires an ordinary explicitly approved
ShipGlows-core chantier.

## Reporting

Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final
response. Report the number and names of candidates applied, skipped, and left
unverified; changed surfaces; deferred proof owners/commands; the terminal stop
reason; and the compact agent receipt. Keep skipped sensitive findings redacted.

The final verdict is `implemented — unverified`, `partial — unverified`, or
`no safe actionable work`; it is never a closure or ship verdict.
