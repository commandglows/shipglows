---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: "ShipGlowz"
created: "2026-05-25"
updated: "2026-07-17"
status: active
source_skill: 009-sg-skill-build
scope: skill-execution-fidelity
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/*/SKILL.md"
  - "skills/references/skill-instruction-layering.md"
  - "skills/references/spec-driven-development-discipline.md"
  - "skills/900-shipglowz-core/SKILL.md"
  - "tools/audit_shipglowz_skills.py"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.4.0"
    required_status: "active"
supersedes: []
evidence:
  - "User concern 2026-05-25: Codex has difficulty following ShipGlowz skills exactly."
  - "shipflow-core pilot audit initially produced 70 noisy signals; after classification it found 0 hard findings, 5 review findings, and 5 style findings."
  - "2026-06-11 shipflow-core was promoted from a plugin pilot into internal ShipGlowz skill 900-shipglowz-core with a versioned audit tool."
  - "Operational lesson: discovery budget compliance does not prove execution fidelity."
  - "User escalation 2026-05-26: agents keep asking the operator to continue or retest when browser/prod proof could be run by the agent."
  - "User decision 2026-06-10: execution contracts should favor compact outcome-focused instructions and avoid routine process narration."
  - "User decision 2026-06-10: SKILL.md is the activation contract; detailed playbooks, examples, matrices, and edge cases belong in references."
  - "User correction 2026-07-17: an explicit Lorem ipsum replacement must not trigger content, design, or lifecycle skill exploration."
next_review: "2026-08-17"
next_step: "/104-sg-end shipflow-skill-execution-fidelity-plugin-pilot"
---

# Skill Execution Fidelity

## Purpose

Define how ShipGlowz skill activation bodies should expose the instructions Codex must obey.

This reference complements `skills/references/skill-instruction-layering.md`.

- `skill-context-budget.md` protects startup discovery.
- `skill-instruction-layering.md` decides what stays in `SKILL.md` versus references.
- This file protects execution fidelity after Codex has loaded a skill.

Keep activation-body rules short enough to be obeyed. Put the deep operational material in references unless it is required to choose the next action safely.

Execution fidelity means a fresh agent can quickly answer:

1. What does this skill own?
2. When should it be used, and when should it stop or reroute?
3. Which references must be loaded before acting?
4. What proof is required before claiming completion?
5. What final report shape is expected?
6. Which next action must the agent perform itself before asking the operator?

It must also make the next best operator action obvious when a recurring friction, setup fork, migration choice, or recovery path has an owner skill or canonical ShipGlowz route.

## Skill Selection Proportionality Gate

Before automatically loading a domain or lifecycle skill, distinguish substantive domain work from atomic execution. The fact that a file contains copy, design, or code does not mean the requested change needs the corresponding lifecycle.

Directly execute the request when all of these are true:

- the user supplied one explicit, deterministic change
- the target is known or discoverable with one focused lookup
- the change needs no domain judgment, research, claim review, architecture decision, design-system decision, migration, security review, or destructive action
- focused deterministic validation is sufficient

Typical direct-execution requests include:

- change one `h1` to `h2`
- replace an exact string, testimonial placeholder, or Lorem ipsum value
- apply user-supplied button copy when it does not change a product claim
- fix a typo or one formatting token

Automatically activate a domain or lifecycle skill only when the task needs substantive specialist reasoning, multi-owner routing, governance, research, strategy, a new surface, claim-sensitive writing, or broad validation. Do not load a master router merely because its domain label matches the edited file.

An explicitly named skill still activates. Inside that skill, choose its smallest safe mode and avoid expanding an atomic request into a full lifecycle unless a concrete risk requires it.

Direct execution still requires proportional proof. Run the smallest relevant check, such as a focused search, unit test, typecheck, or surface build; do not substitute process narration for the edit.

## Required Activation Signals

Each material ShipGlowz skill should expose these signals near the top of `SKILL.md`, either as exact headings or clearly accepted aliases.

| Signal | Preferred heading | Accepted aliases | Purpose |
| --- | --- | --- | --- |
| Owner intent | `Mission` | `Purpose`, `Your task`, `Core Rule` | The skill's owned outcome and role. |
| Scope boundary | `Scope Gate` | `Mode Detection`, `Entry Rules`, `Accepted scope` | When to use the skill and when to route elsewhere. |
| Required context | `Required References` | `Required Reading`, `Load before execution` | Files that must be loaded before decisions or edits. |
| Stop behavior | `Stop Conditions` | `Blocked when`, `Must never`, `Ask before` | Conditions that forbid continuing silently. |
| Proof behavior | `Validation` | `Proof Path`, `Test Strategy`, `Evidence` | Checks or evidence required before done/verified claims. |
| Report behavior | `Report Modes` | `Final Report`, `Reporting` | User/agent report shape and verbosity. |

Use the preferred headings for new or heavily edited skills unless an existing heading is already clear and widely referenced.

## First-Screen Rule

The first screen of a `SKILL.md` should make the operational contract obvious before long examples or details.

The first screen should usually include:

- frontmatter with compact `description` and `argument-hint`
- `Canonical Paths`
- `Chantier Tracking` when applicable
- `Report Modes` when the skill reports results
- `Mission` or accepted owner-intent alias
- `Scope Gate` or accepted routing alias
- `Required References` for non-trivial workflows

Do not hide the only stop condition, security gate, or verification gate deep in a long example.

## Reference Path Clarity

Required references must be written as canonical paths, not ambiguous shorthand.

Use:

- `$SHIPFLOW_ROOT/skills/references/<file>.md` for shared references.
- `$SHIPFLOW_ROOT/skills/<skill>/references/<file>.md` for skill-local references.

Avoid:

- `references/<file>.md` without naming whether it is skill-local.
- "global reference" wording for skill-local files.

If a required reference is missing, stop and report a ShipGlowz installation or contract gap. Do not continue from memory unless the skill explicitly marks that reference as optional for the current objective.

## Checkpoint-Based Validation Cadence

Agents must not turn every conversation message into a build/check cycle. In
particular, do not run ESLint, typechecks, tests, production builds, or broad
audits after a small correction or while implementation is still in progress
unless the operator requested it or an immediate high-risk check is required.

The normal cadence is to defer technical validation to an explicit checkpoint,
the end-of-conversation handoff, `SGEND`/`104-sg-end`, or `SGSHIP`/`005-sg-ship`.
At that checkpoint, run the proportional checks for the changed surface and
report any deferred proof honestly. This cadence does not waive security or
provider-specific proof when the relevant risk is actually in scope.

## Runtime-First Classification Gate

When a browser page is stuck, blank, or shows no expected interaction, classify
the client runtime before diagnosing a provider, session, network, or backend
cause:

1. capture the visible state and URL;
2. inspect severe console errors for parse, module-loading, hydration, and
   uncaught-runtime failures;
3. inspect the relevant request only after the page script has started;
4. route to provider/session analysis only when the client runtime is healthy
   enough to make that analysis meaningful.

Pressure scenario: an auth recovery page remains on a loading label because a
classic browser script contains an ES-module import. The console parse error
is the primary cause; Supabase network/session analysis is secondary until the
script can start. A browser console proof or focused runtime smoke check is
required before reporting an auth/provider diagnosis.

## Operator-Last-Resort Rule

The operator tests only as a last resort. If the agent has the permission, credentials, environment, and tools to run or route the next proof step, it must do that before asking the operator.

Common proof routes:

- If a deployment URL is known and ready, run browser proof through `108-sg-browser` or auth proof through `109-sg-auth-debug`.
- If deployment truth is missing, route to `405-sg-prod` instead of asking the operator to inspect the deploy.
- If preview-push mode requires remote proof, ship first, then route to `405-sg-prod`, then route to `108-sg-browser` / `109-sg-auth-debug` / `107-sg-test` as appropriate.
- If a backend deploy makes a frontend action available, retest the frontend action when the action is non-destructive and the target environment is available.
- If the only remaining check is a local command, typecheck, lint, unit test, or deterministic script, run it instead of telling the operator to run it.

Ask the operator to test only when one of these is true:

- the test requires private credentials, MFA, paid access, device access, or a physical environment the agent does not have
- the action would buy, delete, publish, email, invite, charge money, mutate production data, or otherwise create non-reversible side effects without approval
- the proof requires subjective human judgment that cannot be captured by browser, console, network, logs, screenshots, or deterministic checks
- the tool/runtime is blocked and the report names the blocker
- the user explicitly wants to perform the test themselves

Weak:

```text
You can retest the import now.
Next step: /108-sg-browser
```

Good outcome report:

```text
Backend deployed; import retested through `108-sg-browser` against production.
```

Good blocked report:

```text
I cannot retest this directly because the flow requires your YouTube account
MFA. I verified deployment truth and the browser route; remaining proof is
operator-only.
```

## Activation And Next-Best-Action Rule

When the agent encounters a recurring user friction that ShipGlowz already knows how to guide, it must not stop at local troubleshooting or a passive warning.

Required behavior:

- identify the simple continue path
- identify the recommended path
- surface the owner skill, launcher route, or canonical ShipGlowz command when one materially improves first success
- frame the suggestion as a contextual activation step, not as a generic afterthought

This matters most for:

- setup and installation choices
- migrations and upgrades
- onboarding and first-run recovery
- auth, deploy, verification, and environment preparation
- any repeated fork where ShipGlowz has a stronger guided path than "continue manually"

Weak:

```text
This project uses npm. Continue or migrate if you want.
```

Good:

```text
This project uses npm.
Continue now with npm, or open Codex and run `/010-sg-technical migrate pnpm` for the guided migration path.
```

Do not over-promote unrelated skills. Suggest the owner skill only when it is a natural extension of the current friction and improves the user's chance of success.

## Wording Rules

Prefer directive, stable wording over narrative wording.

Good:

```markdown
## Stop Conditions

Stop and report `blocked` when:

- no unique spec can be identified
- validation fails
- the next action would rename a public invocation key
```

Weak:

```markdown
Be careful around specs, validation, and public names.
```

Good:

~~~markdown
## Validation

Run:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```
~~~

Weak:

```markdown
Make sure everything still looks good.
```

## Disposable Artifact Rule

Generated artifacts created for verification, preview, exploration, or scratch work are disposable unless they are explicitly promoted to a durable project artifact.

- Keep generated artifacts out of version control.
- Delete temporary build outputs, caches, previews, and scratch exports after the proof they supported is complete.
- Promote only the minimal durable artifact to the canonical project location when the run explicitly needs a persistent record.
- If a durable artifact is expected, write it in the canonical governance path, not beside source files or in a random root folder.

## Alias Policy

Do not rewrite existing skills only to normalize headings.

Heading changes are worth making when at least one is true:

- the skill was already being edited for a material reason
- the skill has observed execution failures
- a required gate is not visible from the activation body
- a mechanical audit or pressure scenario shows Codex is likely to miss the gate
- the skill is a master/lifecycle skill where ambiguity has high blast radius

For helper skills, a missing exact `Mission` heading is usually not a hard finding if the description and first section clearly state the task.

## Review Priority

Prioritize remediation in this order:

1. Lifecycle/master skills that stop with manual next steps even though agent-run proof is available.
2. Skills that answer recurring friction with local advice but hide the stronger owner skill or guided ShipGlowz route.
3. Lifecycle/master skills with missing or hidden stop, validation, or report gates.
4. Source-de-chantier skills whose escalation threshold is hard to find.
5. Skills over body-size risk thresholds where critical gates are buried.
6. Helper or transcript skills with unclear reporting expectations.
7. Style-only heading normalization.

Do not batch-edit all skills just because a style audit reports inconsistent headings.

## Scenario-First Proof

Skill execution-fidelity edits must use `scenario-first` proof from `spec-driven-development-discipline.md`.

Before editing a skill, name the pressure scenario:

```text
Given a fresh Codex agent loads this skill for <trigger>,
when <ambiguous or risky condition> occurs,
then the activation body makes the correct stop/reroute/proof/report action obvious.
```

Additional scenario for activation-path fidelity:

```text
Given a fresh Codex agent hits a recurring setup, migration, or recovery fork,
when ShipGlowz has a clearer owner skill or guided route than local ad hoc advice,
then the activation body or shared doctrine makes that next-best action obvious.
```

Activation-proportionality scenarios:

```text
ATOMIC-DIRECT: Given a fresh agent receives an explicit deterministic micro-edit,
when no domain judgment or sensitive boundary is involved,
then it performs the edit and focused proof without loading a domain or lifecycle skill.

EXPLICIT-SKILL: Given the user explicitly names a skill for a small task,
when the skill is available,
then it activates but uses its smallest safe mode without manufacturing lifecycle scope.
```

After editing, prove with focused checks:

```bash
rg -n "Mission|Scope Gate|Stop Conditions|Validation|Report Modes|Required References" skills/<skill>/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
```

Use `tools/shipglowz_sync_skills.sh --check --skill <skill>` when a runtime-discoverable skill changed.

## ShipGlowz Core Audit Relationship

The `shipflow-core` audit is an internal operator signal, not the source of truth.

Run it through the versioned ShipGlowz tool:

```bash
python3 "${SHIPFLOW_ROOT:-$HOME/shipglowz}/tools/audit_shipglowz_skills.py"
```

Treat its classifications as:

- `Hard`: likely blocks a completion claim until fixed or disproven.
- `Review`: needs scenario-first triage before edits.
- `Style`: may improve consistency but should not drive standalone churn.

The official ShipGlowz skill budget audit remains the authority for discovery-budget and body-size compliance.

## Non-Goals

- Do not require every skill to have identical headings.
- Do not rename skill invocations.
- Do not move all details into references if that hides gates.
- Do not treat "shorter" as better when it weakens obedience.
- Do not add public marketing claims about plugin readiness from this reference.
