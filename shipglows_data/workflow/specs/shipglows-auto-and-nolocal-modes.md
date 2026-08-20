---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-20"
created_at: "2026-08-20 07:59:01 UTC"
updated: "2026-08-20"
updated_at: "2026-08-20 13:04:39 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "shipglows auto and nolocal modes"
owner: Diane
user_story: "As the ShipGlows operator approaching an AI-credit deadline, I want autonomous conversations that maximize useful project value without artificial token burn, stay confined to their launch root, coordinate independent agents, and always defer local workloads, plus an independent no-local modifier for ordinary work."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/shipglows/SKILL.md
  - skills/000-shipglows/SKILL.md
  - skills/708-sg-auto/SKILL.md
  - skills/708-sg-auto/references/auto-session-coordination.md
  - skills/references/no-local-execution-policy.md
  - skills/references/mutation-plan-approval.md
  - skills/references/skill-invocation-registry.json
  - skills/references/skill-code-index.md
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
  - tools/test_shipglows_auto_nolocal_contract.py
depends_on:
  - artifact: skills/references/mutation-plan-approval.md
    artifact_version: "1.10.0"
    required_status: active
  - artifact: skills/references/master-delegation-semantics.md
    artifact_version: "1.15.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.7.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-20: auto must prioritize reasoning, large-context analysis, code generation, architecture, security, and compliance work because local builds and tests consume wall time without materially consuming AI credits."
  - "Operator decision 2026-08-20: auto must always include the nolocal policy, while nolocal remains independently usable for operator-selected work."
  - "Current router exposes no global auto or nolocal contract; sg-docs auto and 102-sg-start auto-verify are unrelated local modes."
  - "Operator correction 2026-08-20: useful work, not raw reasoning-token consumption, is the optimization target; effort and agents must be justified by task value."
  - "Operator decision 2026-08-20: auto recommends useful subagents, freezes the launch root for all agents, coordinates concurrent claims, treats Fast as pre-existing client state, and always implies nolocal."
next_step: "Close the verified instruction-contract chantier when the operator requests lifecycle closure"
---

# Spec: ShipGlows Auto And Nolocal Modes

## Title

ShipGlows Auto And Nolocal Modes

## Status

ready

## User Story

As the ShipGlows operator approaching an AI-credit deadline, I want autonomous conversations that maximize useful project value without artificial token burn, stay confined to their launch root, coordinate independent agents, and always defer local workloads, plus an independent no-local modifier for ordinary work.

## Minimal Behavior Contract

`shipglows auto [optional scope or horizon]` starts a bounded autonomous useful-work window, treats that invocation as authority for safe local reversible edits and useful delegated agents, freezes the launch project root, ranks eligible work by durable value per wall-clock minute, and always applies `nolocal` implicitly. Reasoning effort, Fast, generation volume, and agent count are never consumption targets. `shipglows nolocal <objective>` keeps the ordinary owner and approval lifecycle for an operator-selected objective while applying only the execution restriction. Both modes may inspect and edit in-scope files, but they never run builds, tests, lint, typechecks, dependency installation, application servers, browsers, emulators, containers, executed migrations, commits, pushes, deployments, or other workload/external-state operations. If a candidate is unsafe, ambiguous, blocked, duplicated by a fresh claim, already dependent on missing proof, or not backed by roadmap/planning/security/compliance evidence, `auto` skips it and selects the next safe candidate; it never invents busywork or reasoning to consume credits.

## Success Behavior

- Preconditions: A current project root is resolved and frozen and contains at least one safe actionable roadmap, planning, security, compliance, architecture, refactor, or implementation surface.
- Trigger: The operator invokes `shipglows auto`, optionally with a scope or horizon, or invokes `shipglows nolocal <objective>`.
- User/operator result: `auto` proceeds without avoidable discussion and returns a concise portfolio handoff; `nolocal` executes the selected objective under normal ownership with a visible deferred-proof boundary.
- System effect: Safe local files and ignored coordination claims may be created or edited below the frozen root; useful subagents inherit the same root and nolocal boundary; no workload execution or external state change occurs; every touched work item remains open as `implemented — unverified` until normal proof runs later.
- Success proof: Scenario-first contract tests prove routing, authority, priority order, forbidden operations, status vocabulary, stop/skip behavior, and mode separation.
- Silent success: Not allowed; the final handoff names changed work, deferred proof, and stop reason.

## Error Behavior

- Expected failures: No eligible work, unresolved project identity, only unsafe or blocked candidates, unavailable required source truth, dirty-file ownership collision, expired horizon, or platform stop.
- User/operator response: `auto` skips individual blocked candidates and continues; it stops only when no safe candidate remains or a hard authority/safety/platform boundary applies. `nolocal` follows the ordinary owner question/stop contract.
- System effect: No forbidden operation runs, no false verification or closure state is recorded, and unrelated work remains untouched.
- Must never happen: Artificial token-wasting output or reasoning; unjustified model/effort escalation or agent fan-out; leaving the frozen root; duplicate claimed work; invented roadmap features; destructive or privileged changes; secret/credential/permission/billing/production mutation; local workload execution; external writes; commit/push/deploy; self-activation of Fast; or claims of fixed, verified, secure, compliant, complete, closed, or shipped.
- Silent failure: Not allowed; skipped candidates and the terminal stop reason are summarized without exposing sensitive evidence.

## Problem

The normal ShipGlows lifecycle optimizes delivery quality and proportional proof, but it can spend a short expiring credit window waiting for builds, tests, package installation, servers, or operator decisions. Parallel conversations can increase useful throughput naturally, but they can also duplicate work or collide on files. The mode must therefore optimize useful outcomes rather than raw token consumption, coordinate agents and conversations, and deliberately defer machine-bound proof. No independent policy otherwise expresses the same no-local-workload constraint for an ordinary operator-selected task.

## Solution

Keep `auto` and `nolocal` as distinct global ShipGlows modes. Route `auto` to internal `708-sg-auto`, freeze its launch root, recommend bounded subagents for independent useful missions, coordinate concurrent claims below that root, and compose the shared no-local-execution policy implicitly. Keep `nolocal` independently loadable by ordinary routed work. The narrowly bounded auto-session authority lets explicit `shipglows auto` and its delegated missions proceed continuously without defeating the universal safety boundary.

## Scope In

- Public `shipglows auto` and `shipglows nolocal <objective>` discovery and routing.
- Internal-only `708-sg-auto` engine for multi-chantier selection, ranking, execution, skip/stop behavior, receipts, and handoff.
- Shared `no-local-execution-policy.md` defining allowed static inspection/editing and forbidden workload/external-state operations.
- Auto-session authority limited to safe, reversible, current-project local edits; ordinary `nolocal` retains normal mutation approval.
- Useful-work priority order: after safety, authority, root, claims, and evidence eligibility, maximize durable value per wall-clock minute.
- Bounded subagents recommended for independent useful missions, with task-fit model and reasoning choices and no artificial fan-out.
- Root-local ignored coordination claims for concurrent conversations and non-overlapping file ownership.
- Fast truthfulness: use only when runtime evidence says it is already active; never self-activate it or edit user-level Codex configuration.
- Roadmap/planning work plus authorized security/compliance/architecture audits and hardening.
- Scenario-first tests, public help/docs, registry/index metadata, and installed-runtime synchronization.

## Scope Out

- Measuring or guaranteeing exact OpenAI credit consumption.
- Accessing account quota, estimating a burn curve, or forcing model effort to consume an expiring balance.
- Purchasing credits, changing plans, accessing billing, or querying private account usage.
- Builds, tests, lint, typechecks, installs, upgrades, servers, browser/device runs, containers, migrations, commits, pushes, deployments, or publication inside either mode.
- Destructive edits, deletion, credential/secret/permission changes, production or tenant mutation, billing/payment work, or irreversible/external actions.
- Replacing normal verification, closure, release, or compliance certification.
- Changing the unrelated `sg-docs auto` or `102-sg-start` auto-verify meanings.

## Constraints

- `auto` always applies `nolocal` implicitly; no `auto local` override is supported.
- `nolocal` is an execution policy, not an autonomous priority selector and not an authority bypass.
- Static repository discovery, source reading, bounded file editing, and read-only Git status/diff inspection remain allowed because they produce the requested work without executing the application workload.
- A candidate must have durable evidence in roadmap, planning, specs, backlog, code risk, or a legitimate security/compliance/architecture audit surface.
- Auto-session authority never covers remote, destructive, privileged, secret, billing, auth/permission, production, or irreversible effects.
- Unrelated dirty files are preserved; ownership collision skips the candidate.
- The launch Git/managed root is frozen for the parent and every subagent; other repositories, clones, and worktrees are excluded.
- Concurrent auto conversations reserve the smallest candidate/file scope below `.shipglows-auto/claims/`; fresh overlap skips the candidate.

## Dependencies

- Runtime: Codex/Claude-style skill routing and optional subagent support; no project dependency is installed. Subagents are recommended when available and useful, not required for one cohesive task.
- Document contracts: Mutation approval, delegation, decision quality, scenario-first proof, chantier tracking, and invocation registry contracts listed in frontmatter.
- Metadata gaps: Exact subscription-credit conversion is not public and is not needed for deterministic mode behavior.
- Fresh external docs: Checked 2026-08-20 only to confirm that higher reasoning effort generates more reasoning tokens and trades cost/latency for depth; no API behavior is implemented.

## Invariants

- Safety and explicit authority eligibility gate the candidate pool before credit intensity is scored.
- Within the safe eligible pool, durable project value per wall-clock minute is the primary ordering dimension; model, reasoning, generation, and agents remain task-fit implementation choices.
- `auto` never pauses for a routine implementation choice; it skips a blocked candidate and continues.
- `nolocal` alone never grants autonomous multi-chantier selection or mutation authority.
- Deferred proof remains explicit and executable later; no work item is closed from static inspection alone.
- Useful subagents are authorized and recommended for independent missions. Parallel writes require ready, non-overlapping execution batches and remain bound by frozen-root, claim, and dirty-file ownership.
- `auto` never changes Fast itself; unobservable Fast state is recorded as unknown and does not interrupt the run.

## Links & Consequences

- Upstream systems: Public router, operator invocation, roadmap/planning/spec sources, mutation authority, and model/delegation policy.
- Downstream systems: Selected métier owners, task/spec histories, deferred validation owners, public help, runtime skill sync, and invocation graph.
- Cross-cutting checks: Public-mode collision, numeric skill identity, metadata, activation graph, instruction budget, runtime discoverability, dirty-file safety, and truthful verification vocabulary.

## Documentation Coherence

- Update the public router contract, launch cheatsheet, skill lifecycle documentation, expert code index, and `708-sg-auto` README.
- Keep detailed execution rules in one local auto playbook and the transversal restriction in one shared policy rather than expanding the router.
- Do not change unrelated CLI/user documentation.

## Edge Cases

- `shipglows auto` with no explicit horizon runs until platform stop, operator interruption, or no safe actionable candidate; it cannot promise to exhaust a numeric balance.
- `shipglows auto nolocal` is accepted as redundant and behaves exactly like `shipglows auto`.
- `shipglows nolocal` without an objective reports the missing objective instead of selecting work autonomously.
- A high-credit candidate requiring a build/test to know how to edit is skipped or left as analysis-only; it is not guessed into a verified fix.
- A small high-value repair may outrank a reasoning-intensive chantier when it delivers more durable value per minute; token intensity is not a ranking goal.
- Ten concurrent auto conversations share no account-quota telemetry. Each stays task-fit and uses root-local claims to avoid duplicate useful work rather than attempting a per-session burn curve.
- Security/compliance analysis may produce and apply safe local hardening, but cannot claim the system secure or compliant without deferred proof.
- Existing `sg-docs auto` and `102-sg-start` auto-verify routes remain unchanged.

## ZOMBIES Coverage

- Zero: no eligible candidate produces a clean stop report and no mutation.
- One: one eligible candidate is implemented and handed off as unverified.
- Many: independent candidates are ranked, bounded, and processed without mixing ownership.
- Boundaries: expired horizon, context/platform stop, dirty collision, absent objective, and redundant `auto nolocal` are deterministic.
- Interfaces: router, registry, auto engine, shared policy, selected owner, and deferred-proof handoff retain explicit ownership.
- Exceptions: unsafe, privileged, destructive, ambiguous, or proof-dependent candidates are skipped without weakening the global safety contract.
- Simple scenarios: contract tests cover route, priority, forbidden actions, status, and mode separation without executing an application.

## Implementation Tasks

- [x] Task 1: Add the shared no-local execution and auto-session authority contracts.
  - File: `skills/references/no-local-execution-policy.md`, `skills/references/mutation-plan-approval.md`
  - Action: Define allowed inspection/editing, forbidden workload/external actions, truthful status, and the exact bounded authority granted only by `shipglows auto`.
  - User story link: Enables continuous useful edits without build/test wait or repeated approval prompts.
  - Depends on: None.
  - Validate with: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract`
  - Notes: Keep `nolocal` alone under the ordinary approval gate.

- [x] Task 2: Create the internal auto orchestrator.
  - File: `skills/708-sg-auto/SKILL.md`, `skills/708-sg-auto/references/auto-credit-window-playbook.md`, `skills/708-sg-auto/agents/openai.yaml`, `skills/708-sg-auto/README.md`
  - Action: Define candidate evidence, priority scoring, continuous skip/continue loop, topology, safety stops, deferred proof, and final receipt.
  - User story link: Turns the credit window into reasoning-intensive roadmap and hardening work.
  - Depends on: Task 1.
  - Validate with: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract`
  - Notes: Internal-only engine because the public product surface is `shipglows auto`.

- [x] Task 3: Add public routing and registry/index identity.
  - File: `skills/shipglows/SKILL.md`, `skills/000-shipglows/SKILL.md`, `skills/references/skill-invocation-registry.json`, `skills/references/skill-code-index.md`
  - Action: Detect `auto`/`nolocal`, hand `auto` to 708, apply the policy before normal owner routing for `nolocal`, and register code 708 without changing unrelated auto modes.
  - User story link: Makes both commands deterministic and discoverable.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract tools.test_skill_invocation_check && python3 tools/skill_code_index_lint.py`
  - Notes: `auto` and `nolocal` are public router modes; 708 remains internal.

- [x] Task 4: Add scenario-first regression coverage.
  - File: `tools/test_shipglows_auto_nolocal_contract.py`, `tools/test_skill_invocation_check.py`
  - Action: Assert route ownership, mandatory policy composition, primary reasoning-intensity priority, authority separation, forbidden operations, truthful statuses, skip/stop behavior, and collision avoidance.
  - User story link: Prevents future simplification from losing the intended credit-window behavior.
  - Depends on: Tasks 1-3.
  - Validate with: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract tools.test_skill_invocation_check`
  - Notes: Contract tests inspect instructions; they do not run project workloads.

- [x] Task 5: Align documentation and runtime discovery.
  - File: `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `shipglows_data/technical/skill-runtime-and-lifecycle.md`, runtime skill installation
  - Action: Document invocation, semantic separation, allowed/forbidden boundaries, unverified handoff, and internal engine ownership; synchronize affected skills after focused proof.
  - User story link: Makes the behavior usable and durable across installed agents.
  - Depends on: Tasks 1-4.
  - Validate with: metadata lint, focused contract tests, activation graph, budget check, diff check, and affected runtime sync.
  - Notes: Documentation and runtime files are synchronized; public routing and the direct Codex expert link both resolve to the installed runtime. No application build/test/install is required.

- [x] Task 6: Refine auto for useful multi-conversation work.
  - File: `skills/708-sg-auto/SKILL.md`, `skills/708-sg-auto/references/auto-credit-window-playbook.md`, `skills/708-sg-auto/references/auto-session-coordination.md`, `skills/references/mutation-plan-approval.md`, `skills/references/master-delegation-semantics.md`, `tools/shipglows_auto_claim.py`
  - Action: Replace token-throughput ranking with durable value per minute, authorize and recommend task-fit subagents, freeze the launch root, add atomic cross-conversation claims, keep Fast observational, and propagate implicit nolocal to every mission.
  - User story link: Lets many autonomous conversations produce distinct useful work without artificial reasoning burn or project drift.
  - Depends on: Tasks 1-5.
  - Validate with: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract tools.test_shipglows_auto_claim tools.test_skill_invocation_check`
  - Notes: Claim execution is minimal root-local control-plane bookkeeping explicitly allowed by nolocal; it never runs the application workload.

## Acceptance Criteria

- [x] AC 1: Given `shipglows auto`, when routing resolves the mode, then it hands off to internal `708-sg-auto`, applies `nolocal` mandatorily, and treats no `local` override as valid.
- [x] AC 2: Given multiple safe eligible candidates, when auto prioritizes work, then durable useful project value per wall-clock minute ranks first after safety/authority/evidence eligibility, without treating token consumption as value.
- [x] AC 3: Given any auto run, when it acts locally, then static discovery, reading, editing, and read-only status/diff are allowed while builds, tests, lint, typechecks, installs, servers, browsers, containers, migrations, commits, pushes, deploys, and external writes are forbidden.
- [x] AC 4: Given `shipglows nolocal <objective>`, when routing resolves the request, then it retains ordinary owner selection and mutation approval while applying only the shared no-local execution policy.
- [x] AC 5: Given a blocked or unsafe candidate, when auto can select another safe candidate, then it records the skip internally and continues without asking the operator; when none remains, it stops with the reason.
- [x] AC 6: Given implemented work without runtime proof, when auto reports state, then it says `implemented — unverified`, leaves lifecycle closure open, and lists deferred proof commands without running them.
- [x] AC 7: Given unrelated `sg-docs auto` or `102-sg-start` auto-verify behavior, when the global modes are added, then those existing modes remain unchanged and collision-free.
- [x] AC 8: Given a request to waste tokens, invent work, touch secrets/permissions/billing/production, delete data, or perform an external/irreversible action, when auto evaluates it, then it refuses or skips that action and preserves the bounded authority contract.
- [x] AC 9: Given one or more useful independent missions, when auto selects topology, then subagents are authorized and recommended only when they improve time, isolation, or coverage; one cohesive mission may remain main-only.
- [x] AC 10: Given any parent or delegated auto mission, when it discovers or edits project work, then it uses the immutable canonical Git/managed root captured at launch and rejects sibling repositories, clones, other worktrees, traversal, and symlink escape.
- [x] AC 11: Given concurrent auto conversations in one root, when they claim the same candidate or overlapping paths, then atomic root-local coordination grants one owner and the others skip; abandoned claims are never silently reclaimed.
- [x] AC 12: Given an effort or model decision, when auto selects it, then required task quality and risk justify the choice; expiring credits, elapsed time, or a desire to consume never justify escalation or artificial output.
- [x] AC 13: Given Fast is active, inactive, or unobservable, when auto runs, then it uses only a runtime-proven active state and never self-activates Fast, edits user configuration, pauses, or attributes the parent's state to a child without evidence.

## Test Strategy

- Unit: `python3 -m unittest tools.test_shipglows_auto_nolocal_contract tools.test_shipglows_auto_claim tools.test_skill_invocation_check`
- Integration: `python3 tools/skill_code_index_lint.py`, activation-graph validation, metadata lint for changed governed docs, and focused skill budget audit.
- Runtime: affected-skill synchronization and byte/target checks for `shipglows`, `000-shipglows`, and `708-sg-auto`.
- Manual: Independent semantic review of AC 1-13; no application workload, browser, device, provider, or deployment proof.

## Test Contract

### Surface

- Stack/surface: ShipGlows instruction contracts, registry, metadata, and public documentation.
- Primary proof mode: contract_only.
- Proof order: scenario-first unit checks, invocation/activation checks, metadata/budget checks, runtime sync, semantic review.

### Manual checklist

- Needed: no.
- Checklist path: None, because no rendered or provider-native behavior changes.
- Required scenario coverage: AC 1 through AC 13.
- Exception with proof: Application build/test/install is intentionally irrelevant to this instruction-only feature; focused contract and runtime-discovery evidence prove the changed surface.

### Required evidence stack

- Automated / unit / integration checks: focused auto/nolocal and atomic-claim unittests, skill-code index lint, activation graph, metadata lint, budget audit, runtime sync, and `git diff --check`.
- Agent-run browser proof: None, because no browser surface changes.
- Auth/session proof: None, because auth/session state is explicitly out of scope.
- Contract/integration proof: Router/registry/engine/policy pressure scenarios.
- Provider evidence: None, because exact credit accounting is not implemented or claimed.
- Device-native proof: None.

## OWASP Security Gate

- Applicability: No internet-facing endpoint, auth handler, tenant boundary, or data pipeline is added.
- Relevant safety mapping: authorization and software-integrity concerns are handled as workflow authority constraints; auto cannot expand permissions, touch secrets, install dependencies, execute untrusted workloads, or mutate production/external state.
- Proof: Contract tests assert forbidden boundaries and the narrow auto-session authority.
- Residual risk: Static code can still contain defects until deferred tests/builds run; every result remains explicitly unverified.

## Risks

- Security impact: High if autonomy authority is vague; mitigated by an explicit allowlist, forbidden external/destructive surfaces, dirty ownership checks, and truthful unverified status.
- Product/data/performance risk: Auto may produce broad unverified diffs; mitigate with roadmap evidence, bounded candidate slices, non-overlapping ownership, deferred proof commands, and no commit/push.
- Credit-optimization risk: Token usage cannot be guaranteed or observed reliably; mitigate by optimizing useful value per minute, using natural multi-conversation throughput, and forbidding artificial effort, agents, or output.
- Governance risk: `nolocal` could accidentally become an approval bypass; tests and contract wording keep authority exclusive to explicit `shipglows auto`.

## Execution Notes

- Read first: `skills/000-shipglows/SKILL.md`, `skills/shipglows/SKILL.md`, `skills/references/mutation-plan-approval.md`, `skills/references/master-delegation-semantics.md`, `skills/references/skill-invocation-registry.json`, and adjacent 700-band helpers.
- Approach: Scenario-first; shared policy first, internal engine second, thin router wiring third, docs/tests last.
- Validate with: Commands in `Test Strategy`; do not run application builds, tests, or installation.
- Stop conditions: Authority would extend beyond safe local reversible edits; public/internal identity collides; registry graph cannot represent the route; unrelated dirty files would be overwritten; or validation requires an application workload.
- Topology: Main-only integration writes because router, registry, and shared policy overlap; one independent read-only review verifies the completed contract. The implemented auto runtime itself recommends bounded subagents for independent useful missions.

## Open Questions

None

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-20 07:59:01 UTC | 100-sg-spec | GPT-5 Codex | Created autonomous credit-window and independent no-local-execution contract | draft | /101-sg-ready shipglows auto and nolocal modes |
| 2026-08-20 08:02:27 UTC | 101-sg-ready | GPT-5 Codex | Reviewed behavior, authority separation, risk boundaries, proof, consequences, and autonomous followability | ready | /102-sg-start shipglows auto and nolocal modes |
| 2026-08-20 08:08:32 UTC | 102-sg-start | GPT-5 Codex | Implemented shared nolocal policy, bounded auto authority, internal 708 engine, public routing, registry/index identity, scenario tests, and mapped documentation | in progress: focused source proof passed; independent review and runtime sync pending | /103-sg-verify shipglows auto and nolocal modes |
| 2026-08-20 08:16:51 UTC | 103-sg-verify | GPT-5 Codex | Verified AC 1-8 in source and installed runtime; independent review found and confirmed repair of public mode-route selection and invalid-form rejection | partial: behavior verified and runtime files identical; direct Codex expert link for 708 blocked by root-owned ~/.agents/skills | create the exact 708 Codex symlink with sudo, then recheck runtime discovery |
| 2026-08-20 13:04:39 UTC | 103-sg-verify | GPT-5 Codex | Verified useful-work prioritization, mandatory nolocal, bounded subagents, frozen root, atomic claims, lock symlink defense, task-fit effort, per-agent Fast truth, runtime parity, and direct discovery | verified: 56 focused scenarios pass; independent re-review validated all AC 1-13 | await operator lifecycle closure request |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: done, ready.
- `102-sg-start`: done, implementation and mapped documentation complete.
- `103-sg-verify`: done, AC 1-13 and installed runtime verified independently.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: close the verified instruction-contract chantier when the operator requests lifecycle closure.
