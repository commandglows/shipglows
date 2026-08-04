---
name: 002-sg-maintain
description: "Orchestrate project maintenance from triage to ship."
argument-hint: [optional: quick | full | security | deps | docs | audits | global | no-ship | report=agent]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`. Search for a matching active `specs/*.md` chantier. If exactly one chantier owns the maintenance scope, append the current `002-sg-maintain` run to `Skill Run History`, update `Current Chantier Flow`, and include the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no matching chantier exists and the maintenance work is non-trivial, run or route through `100-sg-spec` and `101-sg-ready` before implementation. If the work is a narrow local fix safe without a full spec, write a short maintenance mini-contract in the final report and continue in delegated sequential mode. If multiple specs plausibly match, ask the user to select one.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, lifecycle-result first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` for detailed evidence matrices or downstream handoff.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Maintenance defaults to delegated sequential for triage, repair, docs, checks, validation, integration, and ship preparation when subagents are available; parallel maintenance remains gated by ready `Execution Batches`.

## Master Workflow Lifecycle

Before resolving maintenance phases, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship/deploy routing. Local sections below define maintenance lanes and owner routes only.

## Context

- Current directory: !`pwd`
- Current date: !`date '+%Y-%m-%d'`
- Project name: !`basename $(pwd)`
- Git status: !`git status --short 2>/dev/null || echo "Not a git repo"`
- ShipGlows development mode: !`rg -n "ShipGlows Development Mode|development_mode|validation_surface|ship_before_preview_test|post_ship_verification|deployment_provider" CLAUDE.md SHIPGLOWS.md 2>/dev/null || echo "No project development mode documented"`
- Package manager signals: !`ls -1 package.json package-lock.json yarn.lock pnpm-lock.yaml requirements.txt Pipfile.lock pyproject.toml 2>/dev/null || echo "none"`
- Package scripts: !`node -e "const p=require('./package.json'); console.log(JSON.stringify(p.scripts||{}, null, 2))" 2>/dev/null || echo "no package.json scripts"`
- Bug files: !`find bugs -maxdepth 1 -type f -name "BUG-*.md" 2>/dev/null | sort | tail -40 || echo "No bugs directory"`
- Optional bug triage view: !`tail -80 shipglows_data/workflow/BUGS.md 2>/dev/null || echo "No shipglows_data/workflow/BUGS.md"`
- Recent tests: !`tail -60 shipglows_data/workflow/TEST_LOG.md 2>/dev/null || echo "No shipglows_data/workflow/TEST_LOG.md"`
- Project-local tasks: !`head -80 shipglows_data/workflow/TASKS.md 2>/dev/null || head -80 TASKS.md 2>/dev/null || echo "No project-local TASKS.md"`
- Project-local audit log: !`tail -80 shipglows_data/workflow/AUDIT_LOG.md 2>/dev/null || tail -80 AUDIT_LOG.md 2>/dev/null || echo "No project-local AUDIT_LOG.md"`
- Active specs: !`find shipglows_data/workflow/specs specs -maxdepth 1 -type f -name "*.md" 2>/dev/null | sort | head -60 || echo "No specs directory"`
- Docs governance: !`found=0; for f in AGENT.md AGENTS.md CLAUDE.md shipglows_data/technical/context.md shipglows_data/editorial/content-map.md shipglows_data/technical/code-docs-map.md shipglows_data/editorial/claim-register.md CONTEXT.md CONTENT_MAP.md docs/technical/code-docs-map.md docs/editorial/claim-register.md SECURITY.md .env.example; do if [ -e "$f" ]; then echo "$f"; found=1; fi; done; [ "$found" = 1 ] || echo "none"`

## Mission

`002-sg-maintain` is the project maintenance master skill.

It answers one operational question:

```text
What maintenance work needs to be handled, and how do we carry it through to verified, shippable completion?
```

The goal is not another report. `002-sg-maintain` owns maintenance scope selection and lifecycle continuation across the right owner lanes. It should keep the operator out of command-stitching by piloting maintenance intake, spec/readiness when needed, bounded delegated execution, verification, and ship/deploy routing.

Keep the first decision explicit:

- stay in `002-sg-maintain` when the dominant job is existing-project upkeep across bug/deps/docs/audit/check/release-prep lanes
- route out early when the dominant job is one feature, one bug loop, or one release-confidence pass that already has its own owner

## Ownership Boundaries

Orchestrate existing skills; do not duplicate their internals.

- `003-sg-bug` owns bug lifecycle execution, bug files, retests, verification, and ship risk.
- `010-sg-technical deps` owns dependency health, vulnerabilities, supply chain, licenses, drift, and config.
- `300-sg-docs` owns documentation update/audit, metadata, technical corpus, editorial corpus, and stale-doc repair.
- `105-sg-check` owns local typecheck, lint, build, tests, and quick dependency checks.
- `400-sg-audit` owns broad multi-domain audits.
- `010-sg-technical audit` owns code, architecture, reliability, and security review.
- `010-sg-technical migrate` owns framework/package upgrade migrations and breaking-change work.
- `011-sg-pilotage tasks` owns tracker reconciliation and durable task updates.
- `106-sg-fix`, `001-sg-build`, and `004-sg-deploy` own repair, feature work, and release execution.
- `100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `104-sg-end`, and `005-sg-ship` own lifecycle gates.

`002-sg-maintain` may execute through these owner skills and bounded subagents. It must not silently bypass their gates, but it should not stop at recommendations when the user asked maintenance to be handled.

Keep the boundary explicit: `002-sg-maintain` decides what existing-project upkeep to carry through, not generic feature implementation, standalone bug-loop ownership, or release-proof ownership.

When the next owner is already obvious, route directly instead of lingering in maintenance triage:

- new product/story delivery -> `001-sg-build`
- one bug lifecycle -> `003-sg-bug`
- bounded release confidence, deployment truth, or post-push proof -> `004-sg-deploy`
- one obvious specialist audit lane -> `400-sg-audit` or the exact `010-sg-technical audit|deps|performance` mode

## Execution Modes

### `main-only`

Use only for pure conversation, explicit `quick` read-only triage, or a `global` dashboard before the user selects target projects.

### `delegated sequential` (default)

`/002-sg-maintain` or `$002-sg-maintain` is explicit bounded maintenance delegation consent for the current project. Apply the shared master delegation semantics for short approvals, mini-contracts, degradation, and subagent boundaries.

Load these role contracts from `$SHIPGLOWS_ROOT/skills/references/subagent-roles/` when delegating:

- `technical-reader.md` for read-only technical documentation impact
- `editorial-reader.md` for read-only public-content and claim impact
- `sequential-executor.md` for one bounded write mission at a time
- `integrator.md` for cross-output coherence before verification and ship

### `spec-gated parallel`

Allowed only when the ready maintenance spec defines safe `Execution Batches` with:

- non-overlapping write ownership
- dependency order
- per-batch validation
- integration owner

Without explicit safe batches, parallelism is blocked.

## Mode Detection

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

Parse `$ARGUMENTS`:

- empty -> run the master maintenance lifecycle for the current project.
- `quick` -> read-only maintenance triage only; do not create specs, edit files, or ship.
- `full` -> run the broad maintenance lifecycle with deeper audit/check/dependency/docs lanes.
- `security` -> run the security maintenance lifecycle: bug risk, dependency vulnerability posture, secret/config hygiene, auth/permission surfaces, code-security review, remediation when safe, verification, and ship/deploy routing.
- `deps` -> run the dependency maintenance lane through `010-sg-technical deps`, remediation/migration when needed, verification, and ship routing.
- `docs` -> run the docs/governance maintenance lane through `300-sg-docs`, validation, verification, and ship routing.
- `audits` -> run the audit maintenance lane through `400-sg-audit` or narrower audit skills, then remediation lifecycle for findings that cross the implementation threshold.
- `global` -> workspace maintenance dashboard using local project discovery (`shipglows_data/` markers), then ask which projects to inspect or execute. Do not modify multiple projects without explicit project selection.
- `no-ship` -> run through verification, then stop before `005-sg-ship` or `004-sg-deploy` with a ship-ready report.
- `report=agent`, `handoff`, `verbose`, or `full-report` -> include detailed evidence and command suggestions.

If the user asks to fix, migrate, deploy, or build a specific thing, keep `002-sg-maintain` as the master only when the work is part of maintenance. Otherwise route directly to the owning skill.

## On-Demand References

Load these references when the maintenance scope touches documentation governance:

- `$SHIPGLOWS_ROOT/skills/references/project-governance-rules.md` when the task is about whether the project respects ShipGlows governance shape, ownership, monorepo topology, or corpus completeness.
- `$SHIPGLOWS_ROOT/skills/references/documentation-governance-rules.md` when the task is about documentation architecture, metadata compliance, canonical placement, duplicate docs, or update discipline.

## Maintenance Levels

### Quick Maintenance

`quick` mode is intentionally small and read-only:

1. Read bug, task, audit, docs, dependency, and development-mode state.
2. Identify open high/critical bugs, stale bug statuses, missing bug files, or stale optional bug indexes.
3. Identify dependency signals: lockfile age if visible, package manager, high/critical audit command availability, outdated major-upgrade hints when cheap.
4. Identify docs/governance signals: missing `CLAUDE.md`/`SHIPGLOWS.md` development mode, missing technical/editorial corpus when relevant, stale frontmatter next steps, missing `SECURITY.md` when the project has public/auth/payment surfaces.
   Classify each docs finding as bootstrap gap, migration debt, drift, or non-compliance instead of a generic docs warning.
5. Identify check coverage gaps: no typecheck, lint, tests, build, or meaningful runtime validation scripts.
6. Identify audit recency gaps from `AUDIT_LOG.md`.
7. Return the top 3 maintenance actions with owner skill commands or the recommended master lifecycle mode.

Do not launch audits, edits, installs, commits, or ships in `quick`.

### Master Maintenance Lifecycle

Default and `full` mode should execute the lifecycle as far as safely possible:

```text
intake
  -> triage
  -> existing chantier/spec gate
  -> 100-sg-spec + 101-sg-ready when non-trivial
  -> delegated sequential execution through owner skills/subagents
  -> 105-sg-check / targeted validations
  -> Documentation Update Plan
  -> Editorial Update Plan when public surfaces or claims changed
  -> 103-sg-verify
  -> 104-sg-end when a chantier needs closure bookkeeping
  -> 004-sg-deploy for release confidence or 005-sg-ship for bounded repo/docs/tooling changes
```

Recommended owner-skill order for broad maintenance:

```text
003-sg-bug -> 010-sg-technical deps -> 300-sg-docs update/audit -> 105-sg-check nofix -> 010-sg-technical audit or 400-sg-audit -> 010-sg-technical migrate candidates -> 106-sg-fix/001-sg-build -> 011-sg-pilotage tasks -> 103-sg-verify -> 004-sg-deploy/005-sg-ship
```

Run phases sequentially when one phase can change the risk interpretation of the next. Use parallel subagents only with ready non-overlapping `Execution Batches`.

## Delegation Contracts

Use subagents for real master-skill work when the runtime supports it.

- Triage Reader: read-only; inspect bugs, deps, docs, checks, audits, migrations, security signals, specs, and project mode; return a ranked maintenance plan.
- Lane Executor: write-capable only for one assigned owner lane and write set; use `010-sg-technical deps`, `300-sg-docs`, `106-sg-fix`, `001-sg-build`, `010-sg-technical migrate`, or `105-sg-check fix` as appropriate.
- Technical Reader: read-only; produce the `Documentation Update Plan`.
- Editorial Reader: read-only; produce the `Editorial Update Plan` and `Claim Impact Plan` when public surfaces changed.
- Integrator: consolidate outputs, run focused validations, resolve doc/editorial gates, and decide whether verification can start.
- Ship Executor: run or route through `004-sg-deploy` when deployment proof is needed, or `005-sg-ship` for bounded repo/docs/tooling changes. Do not ship unrelated dirty files.

Every delegated prompt must include:

```text
project root
active spec or mini-contract
assigned mission
owned files/surfaces
forbidden files/surfaces
validation commands
report mode
stop conditions
```

### Security Maintenance

ShipGlows does not need a separate `400-sg-audit-security` yet. Security maintenance is covered by two existing owners:

- `010-sg-technical deps`: dependency vulnerabilities, supply chain, package drift, licenses, registry/config posture.
- `010-sg-technical audit`: authn/authz, tenant boundaries, trust boundaries, secrets, webhooks, destructive actions, input validation, secure failure modes, abuse resistance.

`002-sg-maintain security` should:

1. Check `shipglows_data/workflow/bugs/*.md` first, then optional `shipglows_data/workflow/BUGS.md` if present, for open high/critical security, auth, permissions, data, webhook, or secret issues.
2. Check whether the project has auth, payments, webhooks, public APIs, multi-tenant data, admin actions, or production secrets.
3. Run or route to `/010-sg-technical deps` for dependency/security posture and remediation proposals.
4. Run or route to `/010-sg-technical audit report=agent` when code-level security review is needed.
5. Create or continue a spec when remediation crosses the chantier threshold.
6. Execute safe remediations through bounded owner skills/subagents.
7. Verify and ship only when security, dependency, docs, and check gates allow it.
8. Report missing `SECURITY.md`, missing `.env.example`, missing development mode, or missing preview-proof policy as gaps, not as vulnerabilities by themselves.

If repeated security-only work becomes common, recommend a future `/400-sg-audit-security` spec. Do not create it from `002-sg-maintain`.

## Spec And Readiness Gate

Use a full spec when maintenance touches any of:

- production behavior, auth, permissions, data, payments, webhooks, secrets, migrations, dependencies, deployment, or rollback risk
- multiple files or multiple owner skills
- public pages, README promises, pricing, docs, claim surfaces, or governance corpus changes
- work that needs staged execution, retest, deployment proof, or user/operator confirmation

Use a mini-contract only when the fix is local, low-risk, and verifiable in the current run.

If a spec is created or continued, run `101-sg-ready` and do not start implementation until readiness is `ready`.

## Verification And Ship Gate

After execution:

1. Run focused owner validations and `105-sg-check` when applicable.
2. Produce or refresh the `Documentation Update Plan`.
3. Produce or refresh the `Editorial Update Plan` when public content or claims changed.
4. Run or route through `103-sg-verify`.
5. If `no-ship` is absent and verification passes, run or route through:
   - `004-sg-deploy` when deployment truth or browser/manual proof is required.
   - `005-sg-ship` when the change is bounded to repo/docs/tooling and deployment proof is not required.
6. Stop before ship if unrelated dirty files, failed checks, missing proof, open high/critical bugs, or unresolved security risks remain.

## Stop Conditions

Stop and report `blocked` when:

- the project scope is ambiguous and multiple projects could be maintained
- a requested full/global run would modify trackers, docs, dependencies, or code without explicit approval
- high/critical open bugs make "healthy" wording unsafe
- suspected secrets are present in untracked or staged files
- dependency/security tools require installation or credentials not available in the environment
- Vercel/hosted validation is required but the project development mode is missing or contradictory
- no matching spec exists for non-trivial maintenance and `100-sg-spec` / `101-sg-ready` cannot produce a ready contract
- delegated write ownership overlaps or is undefined
- requested ship scope includes unrelated dirty files

## Report Shape

User-mode report:

```text
🧱 CHANTIER (<local|spec>) : <name>
🎯 VERDICT (HH:mm) : <status>
## Maintenance: <project>

Result: <completed | verified | shipped | ship-ready | needs attention | blocked>
Execution mode: <main-only | delegated sequential | spec-gated parallel>
Lifecycle: <triage -> spec/readiness -> execution -> checks -> verify -> ship/deploy>
Checks: <passed | failed | skipped with reason>
Ship: <004-sg-deploy | 005-sg-ship | no-ship | blocked with reason>

Security posture: <clear | partial | needs review | blocked> - <reason>
Proof gaps: <short list or none>
```

Agent mode may add:

- files and trackers read
- command evidence
- full bug/deps/docs/audit matrix
- per-domain owner skill route
- proposed task tracker entries
- delegated subagent mission summaries
- validation and ship gate matrix

## Important Rules

- Maintenance is not complete until it is verified, shipped, ship-ready with `no-ship`, or blocked at a named gate.
- Prefer "needs review" over "safe" when security evidence is partial.
- Do not invent audit freshness. Use `AUDIT_LOG.md`, `shipglows_data/workflow/bugs/*.md`, optional `shipglows_data/workflow/BUGS.md`, `shipglows_data/workflow/TEST_LOG.md`, specs, and command output.
- Do not conflate `010-sg-technical migrate` and `010-sg-technical deps`: deps finds risk and drift; migrate plans and executes approved breaking-change upgrade work.
- Do not treat missing `SECURITY.md` as a blocker for small local tools, but report it for public, auth, payments, webhook, or multi-user products.
- When maintenance reveals implementation work, execute it through bounded owner skills/subagents after the appropriate spec/readiness gate.
- Do not commit, push, deploy, or mark complete without the relevant `005-sg-ship` or `004-sg-deploy` gate.
