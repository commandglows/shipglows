---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.5.0"
project: "shipglows"
created: "2026-06-10"
updated: "2026-07-18"
status: active
source_skill: 001-sg-build
scope: "build-lifecycle-workflow"
owner: "Diane"
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/001-sg-build/SKILL.md"
  - "skills/references/master-workflow-lifecycle.md"
  - "skills/references/master-delegation-semantics.md"
  - "skills/references/preferred-stacks.md"
  - "skills/references/app-blueprints.md"
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Extracted from 001-sg-build/SKILL.md during residual body-risk cleanup."
  - "Clarified that 102-sg-start local auto-verify is not full 001-sg-build lifecycle orchestration."
  - "Operator correction 2026-07-17: resolve the canonical preferred stack after platform footprint and before blueprint matching."
  - "Operator correction 2026-07-18: unfinished build reports offer operator-facing outcome choices without exposing internal workflow controls."
next_step: "none"
---

# Build Lifecycle Workflow

Use this reference after the top-level `001-sg-build` activation contract has loaded the shared lifecycle, delegation, reporting, and decision-quality references.

## Context Probes

Gather current directory, date, project name, git branch, git status, project-local `shipglows_data/workflow/TASKS.md` or fallback `TASKS.md`, local `TASKS.md` when present, and available specs under canonical project spec locations.

## Execution Mode Detail

If `$ARGUMENTS` activates a named profile such as `%Victoire`, `%Ariane`, `%Prudence`, `%Adhesion`, or `profile=...`, resolve the matching profile in `$SHIPGLOWS_ROOT/shipglows_data/business/agent-profiles/`, load its referenced operator-role contract, then load `skills/references/profile-project-context.md` and the smallest relevant project context bundle for the resolved role before sequencing, blueprint matching, or user-facing arbitration.

Keep the active profile visible in reasoning and reporting when it materially shaped prioritization, phase order, or the final recommendation. Do not claim profile activation silently if the answer does not reflect it.

### Argument Flags

- `spark`, `codex`, `mini`, `agents`, `subagent`, or `sous-agent`: force delegated sequential model-topology.
- `no-agents` or `main-only`: force main-thread execution when the user intentionally accepts less isolation.
- `report=agent`, `handoff`, `verbose`, and `full-report`: affect report detail only, not execution agents.

### Delegated Sequential

`/001-sg-build <story>` or `$001-sg-build <story>` is explicit bounded delegation consent for the current chantier. Use shared master delegation semantics for subagent defaults, short approvals, mini-contracts, degradation, and reporting.

Any subagent argument is stricter than default consent: file-changing or validation-bearing paths must launch one bounded subagent at a time or stop/report degraded execution.

### Parallel Modes

Use a selected read-only batch matrix by default for two or more independent reconnaissance or evidence scopes. Parallel writes are allowed only when a ready spec defines safe `Execution Batches`; otherwise mutations stay delegated sequential.

## Question Gate

Ask only when the answer changes behavior, security, data, permissions, money movement, destructive side effects, staging scope, public claims, validation proof, closure, or ship risk.

When a material question is needed, frame it for a business decision maker:

- problem root
- business stakes
- 2-3 practical options with consequences
- best-practice recommendation
- one precise decision request

If the best-practice answer is clear, low-risk, reversible, inside contract, compatible with context, and verifiable in the current run, choose it and continue.

## Blueprint Gate Detail

After work item resolution, before spec creation:

1. Apply the Greenfield Platform Footprint Rule from `$SHIPGLOWS_ROOT/skills/references/question-contract.md`; distinguish browser, PWA, iOS/Android, desktop, launch phase, and roadmap targets when they change architecture.
2. Load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md` and apply compatible operator-approved presets before proposing technology alternatives.
3. Load `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md` for the full contract.
4. Extract keywords from the user request: normalize to lowercase, remove stopwords, keep nouns.
5. **Read the registry** at `$SHIPGLOWS_ROOT/skills/app-blueprints/README.md`. Parse `available_blueprints` for match candidates.
6. Score each candidate first by required-platform compatibility, then by keyword overlap against `match_keywords`, `name`, and `description`.
7. For matched candidates, **resolve the blueprint file**:
   a. Check `$SHIPGLOWS_ROOT/skills/app-blueprints/<id>/blueprint.md` (local cache).
   b. If missing but `source.repo` is set in the registry, clone the repo: `git clone --depth 1 <repo> $SHIPGLOWS_ROOT/skills/app-blueprints/<id>/`. Use `$HOME/.shipglows/blueprints/<id>/` as fallback if `$SHIPGLOWS_ROOT` is unavailable.
   c. If both fail, exclude this candidate.
8. If no local match is found in the registry, fall back to scanning `$SHIPGLOWS_ROOT/skills/app-blueprints/*/blueprint.md` for orphaned local blueprints not yet in the registry.
9. Pick the best exact archetype match (score > 0). If a candidate is platform-compatible but domain-mismatched, keep it as a stack/conventions reference rather than inheriting its models and routes. If tied, ask the user.
10. If a match is found:
   - Read the full blueprint file.
   - Keep the blueprint path in context for downstream skills.
   - When routing to `100-sg-spec`, include a handoff note: `blueprint: [id]`.
   - When routing to `306-sg-scaffold`, set `BLUEPRINT_PATH=/path/to/blueprint.md` in the handoff context and include `blueprint: [id]` in the handoff note.
   - Add to the final report:
     ```text
     Blueprint: [id] (v[version]) — resolved from [local | cloned from <repo>]
     ```
11. If no match, proceed without blueprint. This is normal for novel app types.

Add to the final report:
```text
Blueprint: [id] (v[version]) — matched on keywords [word1, word2]
```

## Spec And Readiness Loop Detail

For non-trivial work:

1. If a blueprint is active, pre-fill the spec's Architecture, Stack, Models, and Routes sections from it.
2. Run or route to `100-sg-spec`.
3. Run `101-sg-ready`.
4. If not ready, apply one correction pass and rerun readiness.
5. Stop after a bounded loop, default max 3 readiness iterations, with `blocked` or a user decision.
6. Do not run `102-sg-start` until the spec is ready.

For trivial local work, a direct mini-contract may replace a full spec only when decision quality is satisfied.

## Fresh Context Handling

For spec-first execution, prefer a fresh execution context for delegated implementation if the runtime allows it. If a fresh context cannot be created and scope risk is material, ask the user to open a new thread before continuing.

## Governance Corpus Gate

Before `102-sg-start`, check:

- `shipglows_data/technical/` with legacy fallback `docs/technical/`
- `shipglows_data/technical/code-docs-map.md` with legacy fallback
- `shipglows_data/editorial/content-map.md` with legacy fallback
- applicable editorial files
- `$SHIPGLOWS_ROOT/skills/references/technical-docs-corpus.md`
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md`

Classify each as `already existed`, `created`, `needs audit`, `skipped`, or `blocked`. If missing or stale, route to `300-sg-docs` bootstrap/audit or block.

## Documentation And Editorial Gates

After each large sequential block or parallel wave, run a technical reader pass against the docs map, produce or refresh a documentation update plan, apply impacted technical docs, and block the next wave unless docs are complete, no impact, or pending final integration with a reason.

When visible behavior, public docs, README promises, FAQ, pricing, support copy, skill pages, content surfaces, or claims are affected, run an editorial reader pass and apply updates or explicitly record no editorial impact.

## Model Routing Gate

Before `102-sg-start`, load model routing and choose the profile based on complexity, ambiguity, failure cost, expected duration, and topology. Keep one fast model for simple/local work; use the shared guidance for non-trivial/risky work.

## Browser Evidence Routing

Use:

- `108-sg-browser` for non-auth browser assertions, visual state, console/network, screenshots, and interactions
- `109-sg-auth-debug` for auth/session/callback/cookie/provider/tenant/protected-route issues
- `405-sg-prod` for hosted deployment/runtime truth, logs, serverless/edge behavior, and deployment health
- `107-sg-test` for durable manual QA scripts, retests, and structured test logs

For local-complete implementation with hosted/prod/provider proof pending, route immediately to the concrete owner with scenario and target/environment.

## Implementation And Verification Orchestration

When the contract is ready:

1. Run `102-sg-start`.
2. Validate local implementation outcomes and any `102-sg-start` local follow-through result.
3. If `102-sg-start` reported `auto-verify: run` for local-only, non-destructive checks, treat those checks as complete for local proof and continue to the remaining lifecycle evidence decisions; do not treat that as full lifecycle completion.
4. Run `103-sg-verify` for remaining user-facing proof obligations not already completed locally.
5. If hosted/deployed/provider proof is missing, route to owner proof skills with scenario and target/environment.
6. If verification fails, reroute to correction before closure.

`001-sg-build` remains the sole owner of orchestration through `103-sg-verify -> 104-sg-end -> 005-sg-ship`, even when local `102-sg-start` auto-verify ran.

Do not close or ship half-coded outcomes.

## Post-Implementation Onboarding Gate

Evaluate `008-sg-customer` when work adds or changes a user-facing feature, setup flow, first-run state, empty state, permission, integration, settings path, multi-step workflow, public promise, docs/support expectation, or behavior a beginner might not discover.

Route before closure when activation/onboarding is part of the spec or acceptance criteria. Otherwise, suggest onboarding only when it materially improves adoption.

## End And Ship Orchestration

After verification passes:

1. Run `104-sg-end`.
2. Run `005-sg-ship` with bounded staging scope for the current chantier.
3. Never use `all-dirty` or `ship-all` without explicit user request.
4. If proof remains partial, ask explicit risk acceptance before shipping.

Do not end with `/104-sg-end` or `/005-sg-ship` as a manual next step after successful verification unless a named stop condition blocks orchestration.

## Internal Role References

When delegating, load role contracts from `$SHIPGLOWS_ROOT/skills/references/subagent-roles/` as needed: technical reader, editorial reader, sequential executor, wave executor, and integrator. Do not expose these role files as user-facing commands.

## Report Templates

User mode:

```text
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [résultat]

[Résumé orienté résultat et preuve compacte]
[Limite ou risque seulement s'il compte]

[Si le chantier reste ouvert, terminer par les choix numérotés en langage
simple du contrat de reporting. Ne jamais exposer une commande, un skill, un
agent, un flux, un chemin de spec ou une étape interne.]
```

Agent mode may include mode, execution mode, agents, contract, phases, evidence routing, validation, risks, next step, and full chantier metadata.
