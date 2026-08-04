---
name: 000-shipglows
description: "Route non-trivial requests to skills while deterministic micro-edits execute directly."
argument-hint: <instruction>
---

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Intent-to-Outcome Ownership

For non-trivial routing, load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`. Resolve `project -> product -> surface -> feature`, inspect discoverable evidence before asking, and transition into the selected public métier owner in the same conversation. Routing is not a terminal handoff: preserve the outcome while the selected owner clarifies only material operator decisions and continues A to Z.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

`000-shipglows` does not write to chantier specs, bug files, release scopes, commits, or deployment state. A selected owner skill owns durable state and chantier tracing after handoff. When the atomic gate below selects direct execution, the base executor owns only the bounded requested edit and its focused proof. If invoked inside a spec-first flow, do not modify `Skill Run History`; use a `(local)` chantier header with a short work name.

## Report Modes

Before producing a final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, route-first, and in the user's active language. Use detailed report modes only when the user explicitly asks for handoff evidence or when routing is blocked.

## Explicit Invocation Preflight

Before handing off an explicit skill name or numeric skill command, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md` and obey its checker result. A valid invocation stays silent; an invalid or ambiguous one never activates a substitute skill.

## Atomic Direct-Execution Gate

Before loading routing, topology, or owner-skill references, keep the request in direct main-thread execution when the user supplied one explicit deterministic edit, the target is known or discoverable with one focused lookup, no domain judgment or sensitive boundary is involved, and focused validation is sufficient. Typical cases are an exact string or placeholder replacement, a typo, one formatting token, or one `h1` to `h2` change.

Do not load a domain or lifecycle skill for these requests. Apply the bounded edit and run the smallest relevant check. An explicitly named skill still activates and uses its smallest safe mode. This is the activation-critical form of the shared Skill Selection Proportionality Gate.

## Delegation And Topology

For requests that do not pass the Atomic Direct-Execution Gate, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md` before deciding execution topology.

`000-shipglows` is a primary router, not a master lifecycle executor. Its default topology is `main-thread routing`:

- answer directly when no file work or lifecycle action is needed
- execute directly in the main conversation when a bounded file edit passes the Atomic Direct-Execution Gate
- hand off directly in the main conversation to the selected skill contract when work belongs to an existing skill
- ask one numbered routing question when multiple routes are plausible and the answer changes behavior, risk, data, permissions, public claims, staging, closure, or ship posture

Do not launch a selected master skill inside a subagent. In particular, do not run `001-sg-build`, `002-sg-maintain`, `003-sg-bug`, `004-sg-deploy`, `007-sg-content`, `600-sg-local-cloud-sync`, or `900-shipglows-core build` as a nested subagent from `000-shipglows`. After direct handoff, the selected master or domain skill owns its own delegated sequential execution through the shared delegation reference.

Use a read-only routing scout only when all of these are true:

- cheap local inspection is needed to choose between owner skills
- the scout is forbidden to edit, stage, commit, push, deploy, or mutate trackers
- the scout does not invoke a master skill or launch further subagents
- the result is only a route recommendation for the main-thread handoff

## Shared Routing Reference

Before classifying a non-trivial instruction, load `$SHIPGLOWS_ROOT/skills/references/entrypoint-routing.md`.
Before classifying ShipGlows package-scope terminology, load `$SHIPGLOWS_ROOT/skills/references/shipglows-terms.md`.
Before classifying a user-provided source, pasted email, URL, transcript, article, note, or competitor/content example, load `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md`.
Before applying any named operator profile semantics, load `$SHIPGLOWS_ROOT/skills/references/profile-activation.md`.
Before shaping a named-profile answer from role posture alone, load `$SHIPGLOWS_ROOT/skills/references/profile-project-context.md` and the smallest relevant project context bundle for the resolved role.
When the instruction is a high-level critique, business goal, or collaboration complaint, load `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md` before deciding whether the route is clear or a user question is needed.
When `$ARGUMENTS` activates a named operator profile such as `%Victoire`, `%SEO-specialist`, `%Tariq`, `profile=victoire`, `profile=tariq`, or `profile=traffic-manager`, load the matching profile under `$SHIPGLOWS_ROOT/shipglows_data/business/agent-profiles/` and its referenced operator role under `$SHIPGLOWS_ROOT/skills/references/operator-roles/` before choosing the route or shaping the answer.

Use that reference as the canonical routing matrix. Do not duplicate specialist internals here.

If focus tags are present in `$ARGUMENTS`, treat them as binding route-bias cues for the current turn. Do not merely mention that the tags were seen; apply their execution implications from `entrypoint-routing.md` before choosing a route, fallback, or question.

When `$ARGUMENTS` begins with a three-digit skill code or a three-digit runtime skill name, load `$SHIPGLOWS_ROOT/skills/references/skill-code-index.md` before natural-language classification. Resolve `NNN`, `NNN-skill`, `NNNskill`, or `NNN skill` to the runtime skill name from that index, then hand off to that skill.

For requests that remain after the Atomic Direct-Execution Gate, load `$SHIPGLOWS_ROOT/skills/references/decision-quality-contract.md` before choosing a route, answer, or fallback. Routing must prefer the owner path that preserves correctness, security, performance, maintainability, durability, excellence, and proof quality; do not route to the fastest or easiest owner when that would weaken the work. Apply the `Structure Replacement Doctrine`: prefer the route that removes current operator friction, ambiguity, or maintenance burden when it remains quality-equivalent.

## Mission

`000-shipglows` is the primary natural-language entrypoint for non-technical operators.
Primary artifact type: `entrypoint-router`.

When the instruction is about improving ShipGlows itself, its skills, its routing, or its governance, the default destination is the ShipGlows system under `$SHIPGLOWS_ROOT`, not the current project repository, unless the user explicitly names a local project target.

Invoking a ShipGlows skill that exists to maintain ShipGlows itself, including `900-shipglows-core`, is enough to imply ShipGlows as the target unless the operator explicitly names another repo.

The operator does not need to spell out "ShipGlows" in the request; the skill invocation itself is enough to bind the target to ShipGlows when the selected skill exists to maintain ShipGlows.

It answers one question:

```text
What should ShipGlows do with this instruction, and which existing skill should own it?
```

The goal is not to create a new mega-master or the shortest route. The goal is to keep the operator from memorizing the skill taxonomy while preserving the quality and excellence bar, gates, delegation rules, evidence rules, and ship rules owned by existing skills.

Keep the boundary explicit: `000-shipglows` routes, answers, or selects bounded direct execution. It does not prime broad context for a known task, generate a portfolio status dashboard, or continue a resolved chantier after owner selection is already clear.

## Mode Detection

Parse `$ARGUMENTS` as the operator instruction.

- Empty argument: give a compact orientation answer and ask for the instruction to route.
- `help`, `aide`, `commands`, `skills`, or route-selection questions: answer directly or route to `302-sg-help` only if the user wants the full help surface.
- Named profile activation: apply `skills/references/profile-activation.md`. When the instruction starts with `%<Profile>`, `profile=<id>`, or `profil=<id>`, or clearly asks to respond as a known profile, load the matching profile and keep its role bias active for this turn. The canonical syntax is `%<Profile>`. The profile shapes arbitration and output style; it does not replace owner-skill routing. `#<Tag>` remains reserved for focus tags and route-bias cues.
- Numeric skill code: resolve the leading three digits through `skill-code-index.md`, then hand off to the runtime skill. Accepted forms include `001`, `001-sg-build`, `001sfbuild`, and `001 sg-build`.
- Explicit skill name: preflight it, then hand off only when valid. If its safety or scope gate blocks execution, let that skill reroute explicitly instead of silently substituting another owner.
- Natural-language instruction: apply the Atomic Direct-Execution Gate first; classify only unmatched requests with the routing matrix below.
- Natural-language instruction with focus tags: classify using the routing matrix plus the focus-tag execution priorities; tags can change owner preference, artifact preference, and whether a direct suggestion is too passive.

Route away instead of staying in `000-shipglows` when the operator already knows the helper surface needed:

- context priming before real work -> `301-sg-context`
- cross-project git/sync dashboard or portfolio state report -> `308-sg-status`
- paused work item continuation -> `706-continue`

## Routing Matrix

Choose exactly one route unless the user explicitly asks for a dashboard or comparison.

When the ambiguity is between adjacent lifecycle owners, prefer the earliest unresolved owner instead of a later closure/ship skill:

- work not yet implemented -> `102-sg-start`
- implementation complete but proof still needs judgment or owner routing -> `103-sg-verify`
- proof judged and only closure bookkeeping remains -> `104-sg-end`
- closure/bookkeeping complete and the next owned action is git shipping -> `005-sg-ship`

When the ambiguity is between proof lanes, prefer the narrowest evidence owner:

- guided manual QA, retest logging, `shipglows_data/workflow/TEST_LOG.md`, or bug-state update -> `107-sg-test`
- one-off non-auth browser-visible proof -> `108-sg-browser`
- auth/session/callback/protected-route proof -> `109-sg-auth-debug`

For requests involving declared products, sales surfaces, or public claims, prefer owner skills that preserve product governance and proof coherence instead of treating the request as generic copy or generic docs work.

| Intent | Route |
| --- | --- |
| Pure question, explanation, or advice with no file work | Answer directly |
| Explicit deterministic micro-edit with no domain judgment or sensitive boundary | Direct main-thread execution with focused validation; no owner skill |
| Build or change a user-facing feature and also think about end-user clarity, UX/UI friction, activation, beginner adoption, or first-success guidance | public `sg-development`; runtime `001-sg-build` owns implementation and evaluates the internal experience gate |
| Non-trivial feature, code, site, product, or workflow work | public `sg-development`; runtime `001-sg-build` |
| Create a new app from scratch (carnet, gestion, CRUD, etc.) | `001-sg-build <instruction>` — le Blueprint Gate cherchera un blueprint correspondant dans `skills/app-blueprints/` pour guider la creation |
| Recurring maintenance, security upkeep, dependencies, docs drift, checks, audit freshness, migrations, or project hygiene | `002-sg-maintain <mode or instruction>` |
| Bug report, `BUG-ID`, retest, closure, fix state, or bug ship-risk question | `003-sg-bug <instruction>` |
| Release confidence, preview/prod deploy, deployed truth, runtime logs, production health, post-deploy proof | `004-sg-deploy <instruction>` |
| Deploy-target recommendation for an app project | `004-sg-deploy <instruction>` — `004-sg-deploy` loads the canonical advisory matrix in `skills/references/deploy-target-matrix.md`; ShipGlows advises, but final choice remains project-contextual |
| Content strategy, repurposing, drafting, enrichment, SEO audit, editorial governance, apply/publish content | `007-sg-content <instruction>` |
| Market study, GTM audit, copy clarity audit, or persuasion/copywriting audit | `009-sg-marketing <market|gtm|copy|copywriting> <instruction>` |
| Source intake, pasted email/article/transcript/URL classification, project fit, angle selection, or owner-skill choice | Load `source-intake-classification.md`, then route to the owner skill |
| Design request, UI/UX work, redesign, design tokens, playground, accessibility design, component design, visual proof, or token migration | `006-sg-design <instruction>` |
| End-user experience, UX/UI clarity, trust, friction, feature activation, onboarding, setup guidance, first-success path, permission/setup sequencing, or recoverable states | `008-sg-customer <audit|flow|onboarding|recovery> <target>`; ask among modes when intent is mixed |
| Local-first data promotion, cloud hydration, account sync, merge/conflict policy, reinstall recovery, or sync/save UX state | public `sg-engineering sync`; internal engine `600-sg-local-cloud-sync` |
| Product access, paid plans, premium gates, entitlement ledgers, provider events, activation codes, refunds/revokes, support access flows, or backend access gates | public `sg-engineering access`; internal engine `601-sg-product-entitlements` |
| Cross-platform behavior or capability parity | public `sg-engineering parity`; internal engine `602-sg-platform-parity` |
| Create, modify, rename, document, or validate ShipGlows skills | `900-shipglows-core build <instruction>` |
| Refresh an existing ShipGlows skill conservatively | `900-shipglows-core refresh <target>` |
| Extract a blueprint from an existing app, create a new blueprint | `900-shipglows-core build <instruction>` — route à `900-shipglows-core build` (ShipGlows interne), pas à `001-sg-build` (end-user) |
| ShipGlows Core execution-fidelity audit or public-plugin packaging readiness for ShipGlows itself | `900-shipglows-core audit <scope>` or `900-shipglows-core packaging <scope>` |
| One obvious audit domain only | relevant `400-sg-audit-* <instruction>` or `400-sg-audit <instruction>` |
| One obvious owner lane only, such as checks, docs, browser proof, auth diagnosis, manual QA, dependency posture, migration, or final ship | focused owner skill |
| Ambiguous between two or more material routes | Ask one concise numbered routing question |

## Direct Handoff Contract

When a route is clear:

1. Name the selected skill and why in one short sentence when useful.
2. Continue in the same conversation under the selected skill's contract.
3. Load the selected skill's required references before executing it.
4. Pass the original user instruction as the target argument.
5. Preserve the selected skill's report mode defaults unless the user asked for a detailed handoff.
6. Treat the route as a transition into the owner skill, not as a terminal answer that leaves the operator to re-invoke the builder.

When routing a user-facing feature to `001-sg-build` and the instruction mentions
onboarding, activation, beginner users, setup guidance, discoverability, or
first-success, preserve that as a post-build activation requirement. `001-sg-build`
owns the implementation lifecycle first, then evaluates whether to route or
suggest `008-sg-customer`.

Do not stop at "run `/skill ...`" when the user asked ShipGlows to handle the work and the route is safe. A command recommendation is acceptable only for pure orientation, unsupported runtime handoff, or a blocked state.

If the route is clear and safe, the router should hand off immediately instead of lingering on explanation or passive routing language.

## Question Gate

Before asking a user-facing routing question, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md`.

Ask only when the answer changes the route or safety posture. Ask one concise routing question with why the route matters and numbered options. Include a recommended route only when one option is clearly safe from the current instruction and project context.

Do not treat operator-owned business or framing truth as generic routing ambiguity. If one precise question would resolve the route safely, ask it instead of reporting blocked.

Good routing questions are short and practical:

```text
1. Route type
Why: the next step uses different evidence and files depending on whether this is an existing bug or a new product improvement.
Recommended: 1. Product improvement - use this when the request describes a new behavior rather than an observed regression.

Options:
1. Product improvement - hand off to `001-sg-build`.
2. Existing bug - hand off to `003-sg-bug`.

Reply with the number, or name another route.
```

Do not ask broad "anything else?" questions.

## Stop Conditions

Stop and report `blocked` when:

- no route can be chosen without a material product, data, security, permission, deployment, or ship decision
- the selected skill contract is missing or unreadable
- runtime subagents are required by the selected master skill but unavailable and the user has not accepted degradation
- the user requests nested master-skill-in-subagent execution
- the instruction asks for destructive, production, payment, auth, tenant, secret, or broad dirty-file action without explicit approval
- the route would bypass an owner skill's evidence, verification, closure, or ship gate

## Final Report

For direct answers:

```text
🧱 CHANTIER (local) : <short request name>
🎯 VERDICT (HH:mm) : answered
Result: [answer]
Route: direct answer
```

For handoff:

```text
Route: [selected skill]
Reason: [short reason]
Active profile: [name or none]
Role bias: [role id or none]
Execution: direct main-thread handoff; selected skill owns any delegated sequential execution
```

Then continue with the selected skill's final-report contract.

For blocked routing:

```text
🧱 CHANTIER (local) : <short request name>
🎯 VERDICT (HH:mm) : blocked
Route: blocked
Reason: [short reason]
Decision needed:
1. [numbered routing question]
```

## Rules

- Keep this skill thin.
- Do not duplicate internals of owner skills.
- Do not mutate files before the selected owner skill takes over.
- Do not launch selected master skills inside subagents.
- Do not treat direct handoff as parallelism.
- Do not create specs, bug files, commits, deployments, or public-content changes directly from this router.
- Match user-facing language to the user's active language.
