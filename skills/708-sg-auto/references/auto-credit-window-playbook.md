---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-20"
updated: "2026-08-20"
status: active
source_skill: 708-sg-auto
scope: autonomous-credit-window
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/708-sg-auto/SKILL.md
  - skills/708-sg-auto/references/auto-session-coordination.md
  - skills/references/no-local-execution-policy.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-08-20: useful reasoning-intensive work has absolute priority inside auto after safety and evidence eligibility."
  - "Operator correction 2026-08-20: optimize useful work rather than token consumption; do not force reasoning effort merely to consume expiring credits."
  - "Operator decision 2026-08-20: subagents are authorized and recommended for independent useful missions, while auto remains confined to its launch root and always implies nolocal."
next_review: "2026-09-20"
next_step: "/103-sg-verify shipglows auto and nolocal modes"
---

# Auto Credit Window Playbook

## Candidate evidence

Inspect the smallest useful combination of current roadmap, planning/backlog,
ready specs, active task records, architecture documentation, code risk, and
authorized security/compliance scope. A candidate is eligible only when its
desired outcome and owned files are grounded in durable evidence, its next
slice is implementable without workload execution, and its safety/authority
boundary is already resolved.

Prefer implementation from ready specs. When no ready implementation is safe,
use the window for evidence-backed architecture, security/compliance analysis,
spec hardening, or static remediation that creates durable future value. Never
invent work or produce artificial output to consume credits.

Exclude candidates that are speculative, already complete, dependent on a
missing runtime observation, blocked by an operator-owned product decision,
overlapping unrelated dirty work, or likely to require forbidden effects.

## Priority order

Apply these gates and scores in order:

1. **Eligibility gate:** safety, authority, and evidence eligibility, resolved
   ownership, and compatibility with the no-local policy.
2. **Primary ordering dimension:** expected durable project value delivered per
   remaining wall-clock minute.
3. **Quality floor:** durable product value, roadmap relevance, architecture
   coherence, and non-negotiable security remain sufficient.
4. **Tie-breakers:** independence, amount of useful code or contract output,
   low operator-decision risk, and the likelihood that deferred proof can be
   run cleanly later.

High-priority work can include deep architecture analysis, security and compliance
audits or hardening, multi-file implementation, complex refactoring,
large-context review, cross-surface consistency work, and substantial spec/code
generation. Small copy edits, formatting, trivial renames, mechanical cleanup,
or machine-bound tasks rank last unless they unblock a higher-intensity slice.

Do not optimize for visible line count, verbosity, duplicate implementations,
unnecessary abstractions, agent count, reasoning-token volume, or artificial
token use. Never prefer a more expensive model or effort merely because credits
expire. Model, effort, and topology must improve the selected outcome enough to
justify their coordination and latency cost.

## Reasoning and speed

Choose reasoning from mission difficulty rather than a consumption schedule.
Use `high` as a common baseline for complex implementation and analysis, and
promote to `xhigh`, `max`, or `ultra` only for a concrete quality need such as
cross-system ambiguity, security risk, architecture arbitration, or high error
cost. Do not ramp effort according to elapsed time or try to estimate an account
quota the runtime cannot observe.

Fast may increase useful throughput when the client already applies it. Treat
its state as `active`, `inactive`, or `unknown` only from runtime evidence. Each
subagent records its own runtime-observed state and never inherits the parent's
state. The
agent does not self-assign Fast, edit global configuration, or interrupt the run
to request it.

## Continuous loop

For each selected candidate:

1. Bind one existing owner and work item or one bounded static audit slice.
2. Confirm the frozen project root, load `auto-session-coordination.md`, and
   reserve the candidate and its smallest owned paths before every mutation,
   even when no concurrent conversation is known. Skip fresh overlapping
   claims. Without a Git root and a successful claim, continue only read-only
   analysis or select another candidate.
3. Record owned and forbidden files, assumptions, and deferred proof before
   editing.
4. Choose topology. Subagents are authorized and recommended when independent
   useful missions improve time, isolation, or coverage. Parallel writes
   require ready non-overlapping Execution Batches; otherwise keep writes
   sequential. Every delegated mission inherits the frozen root and nolocal.
5. Load the selected owner contract plus the no-local policy and implement the
   largest coherent slice that fits the remaining horizon without forbidden
   execution.
6. Inspect the diff statically, record `implemented — unverified`, and collect
   deferred verification commands without running them.
7. If a candidate becomes blocked, preserve partial truth, record the reason,
   skip it, and immediately select the next safe candidate.
8. Move any owned coordination claim to its truthful completed state,
   then continue until a terminal stop condition applies. Do not return to the
   operator merely to choose the next ordinary candidate.

Never edit overlapping files concurrently. Preserve unrelated changes and stop
or skip before any overwrite, deletion, checkout, reset, stash, branch/worktree
mutation, or other Git state change.

## Security and compliance lane

Static security/compliance work may inspect authorized code and governance,
write redacted findings, and apply safe local hardening that requires no secret,
runtime, provider, auth, permission, production, or destructive action. Treat
framework claims as unverified until the mapped audit and proof run later.

Do not expose exploit payloads, private data, secrets, or sensitive logs in the
portfolio report. A severe finding that cannot be remediated statically is
recorded minimally and skipped to preserve the rest of the credit window.

## Handoff

Return one compact portfolio grouped as:

- applied candidates and changed surfaces;
- skipped candidates and non-sensitive reasons;
- deferred verification commands in dependency order;
- remaining lifecycle owner for every `implemented — unverified` slice;
- agent receipt and terminal stop reason.

Do not run deferred verification commands. Do not close selected specs, bugs,
audit findings, releases, or security/compliance claims.

## Pressure scenarios

- `AUTO-CREDIT-PRIMARY`: after eligibility gates, a deep multi-file/security candidate outranks a trivial edit even when the trivial edit is faster.
- `AUTO-USEFUL-NOT-BURN`: no agent, reasoning level, or output is selected solely because it consumes more credits; task difficulty and useful value own the choice.
- `AUTO-AGENTS-USEFUL`: independent valuable missions recommend subagents, while one cohesive task remains main-only when delegation would add only overhead.
- `AUTO-ROOT-FROZEN`: the parent and every subagent keep the launch root; sibling repositories, clones, and worktrees are never candidate sources.
- `AUTO-FAST-TRUTH`: Fast is used only when runtime evidence says it is active; the agent never claims to self-activate it or edits user configuration.
- `AUTO-NO-BUSYWORK`: no eligible work produces `no safe actionable work`, not invented features or verbose filler.
- `AUTO-SKIP-CONTINUE`: one candidate needs runtime proof; preserve it as skipped and continue another independent candidate without asking.
- `AUTO-NOLOCAL-REDUNDANT`: `shipglows auto nolocal` behaves exactly as `shipglows auto`; `shipglows auto local` is unsupported.
- `AUTO-UNVERIFIED`: static edits yield `implemented — unverified` plus deferred verification commands, never a fixed/secure/compliant/closed claim.
- `AUTO-SELF-GUARD`: an auto run never expands its own authority, no-local policy, agent permissions, or safety guardrails.
