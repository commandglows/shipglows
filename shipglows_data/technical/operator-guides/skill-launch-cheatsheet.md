---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.10.1"
project: ShipGlows
created: "2026-05-04"
updated: "2026-08-04"
status: reviewed
source_skill: 300-sg-docs
scope: skill-launch-cheatsheet
owner: unknown
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - site/src/pages/skill-modes.astro
  - site/src/content/skills/
  - README.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - shipglows_data/editorial/content-map.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.18.4"
    required_status: draft
supersedes:
  - docs/skill-launch-cheatsheet.md
evidence:
  - "Master skill contracts and public skill pages."
  - "Public launch cheatsheet in site/src/pages/skill-modes.astro."
  - "900-shipglows-core build routes fuzzy skill ideas through 700-sg-explore before 100-sg-spec."
  - "007-sg-content added as the master content lifecycle entrypoint."
  - "000-shipglows <instruction> documented as the primary non-technical router with direct handoff to selected skills."
  - "Shared question/default contract added for numbered decisions and context-safe defaults."
  - "006-sg-design added as the master design lifecycle entrypoint for UI/UX, tokens, playgrounds, implementation, proof, and ship routing."
  - "008-sg-customer renamed as the customer activation lifecycle for first-success paths, setup guidance, recoverable states, and proof routing."
  - "600-sg-local-cloud-sync added as the local-to-cloud data promotion, merge, sync UX, and security contract entrypoint."
  - "003-sg-bug clarified as a lifecycle executor that continues through owner skills and bounded subagents when safe."
  - "Skill taxonomy description audit clarified runtime families while keeping public skill names and invocation paths stable."
  - "602-sg-platform-parity added as the platform parity/concordance audit and routing skill."
  - "900-shipglows-core added as an internal operator-only ShipGlows Core audit skill."
  - "010-sg-technical github added as the git/GitHub sync, stale branch, PR drift, and Dependabot hygiene skill."
  - "Public/docs handoff clarity updated: numeric examples now match three-digit runtime names, and runtime invocation notes distinguish manual user commands from OpenCode/KiloCode internal calls."
  - "Added direct links to repo-visible OpenCode and KiloCode runtime pages."
  - "2026-07-17 atomic routing update: deterministic micro-edits execute directly before owner-skill routing."
  - "2026-07-17 sg-verify update: mode=excellence or an unambiguous natural-language request adds a distinct critical focus after standard métier verification."
  - "2026-08-03: public modes now explicitly select bounded local playbooks; operators do not choose reference files."
  - "2026-08-03 pilotage consolidation replaced four public management skills with 011-sg-pilotage and five explicit modes."
  - "2026-08-04 added provider-neutral animation modes to 006-sg-design; GSAP remains optional after project-fit and proof gates."
next_step: "/300-sg-docs audit shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
---

# Skill Launch Cheatsheet

Use this page when you need to choose which ShipGlows skill to launch and which mode argument changes the workflow.

## Default Rule

Start with `000-shipglows <instruction>` when you want a non-technical first command. It answers pure conversational requests directly, executes deterministic micro-edits directly with focused validation, and routes substantive work to the right master or specialist skill. It uses a default only when the route is clear, low-risk, context-compatible, and verifiable.

A public mode selects one bounded local playbook. The owner skill loads detailed references when needed; the operator chooses the work, not a reference file.

Start with `001-sg-build` directly when you already know the request is a feature, code, site, or docs workstream that needs the build lifecycle.

Use a focused skill directly when you intentionally want one owner lane: checks, docs, browser proof, auth diagnosis, manual QA, production truth, audit, dependency posture, migration, or final ship.

## Numeric Skill Codes

ShipGlows also maintains a numeric lookup for faster skill discovery without renaming skills. The canonical index is `skills/references/skill-code-index.md`.

Accepted lookup forms include `001`, `001-sg-build`, `001sfbuild`, and `001 sg-build`; all resolve through `000-shipglows` to the canonical runtime skill name. The numeric code is a lookup aid, not a second public name.

Core codes:

| Code | Skill |
| --- | --- |
| `000` | `000-shipglows` |
| `001` | `001-sg-build` |
| `002` | `002-sg-maintain` |
| `003` | `003-sg-bug` |
| `004` | `004-sg-deploy` |
| `005` | `005-sg-ship` |
| `006` | `006-sg-design` |
| `007` | `007-sg-content` |
| `008` | `008-sg-customer` |
| `009` | `009-sg-marketing` |
| `010` | `010-sg-technical` |
| `011` | `011-sg-pilotage` |

Family bands: `100-199` lifecycle/proof, `200-299` content/research/copy, `300-399` docs/context/support, `400-499` audit/quality/ops, `500-599` design/components, `600-699` data/activation, `700-799` pilotage/session, `800-899` conversation/transcript, `900-999` internal/meta.

## Runtime Invocation Note

Keep four roles separate:

- `302-sg-help` explains and routes.
- `000-shipglows` routes, answers, or keeps deterministic micro-edits in direct execution.
- The selected lifecycle or specialist skill owns execution.
- The runtime may invoke internal calls after interpreting the user request.

Practical rule by runtime:

- Codex or Claude-style runtime: type the visible skill name such as `000-shipglows` or `001-sg-build`.
- OpenCode or KiloCode-style runtime: ask for the ShipGlows skill in natural language or use the runtime skill picker.
- Internal calls such as `skill({ name: "shipglows" })` are runtime implementation details, not manual commands to type.

Runtime-specific repo pages:

- [OpenCode](./opencode-shipglows.md)
- [KiloCode](./kilocode-shipglows.md)

## Named Profiles

Named profiles are an operator layer above skills.

- `skill` = execution owner
- `operator role` = decision contract
- `agent profile` = human-readable invocation such as `Victoire`, `Prudence`, `Ariane`, `Adhesion`, `SEO Specialist`, or `Tariq`

Use `%<Profile>` when you want the router and owner skill to keep the same execution contract while changing arbitration posture for the turn.

- `%Victoire` -> growth prioritization and leverage
- `%Prudence` -> risk surfacing and coherence challenge
- `%Ariane` -> phase structure, sequencing, and first-slice framing
- `%Adhesion` -> end-user trust, clarity, and friction review
- `%SEO-specialist` -> search intent, discoverability, and page coherence
- `%Tariq` -> acquisition-channel choice, tracking readiness, and traffic-to-landing fit

Keep `#<Tag>` separate. A tag such as `#Adhesion` or `#growth` is a focus cue, not a named profile activation.

Example:

```text
%Ariane update les docs internes et surface externes #Adhesion
```

Here, `Ariane` structures the work, `#Adhesion` keeps end-user clarity and friction visible, and `000-shipglows` still chooses the owner skill.

Common documentation and governance focus tags:

- `#rules` -> reload the governed-project rule set
- `#docs` -> enforce strict documentation architecture, metadata, placement, and update discipline
- `#public-docs` -> bias toward public/editorial documentation surfaces
- `#internal-docs` -> bias toward internal technical and operator-facing documentation
- `#canon` -> bias toward the canonical source of truth
- `#owner` -> bias toward the owning artifact instead of duplicated surfaces

Example:

```text
000-shipglows #docs #canon #internal-docs audit this repo before we touch the docs
```

Here, `#docs` tightens documentation-governance compliance, `#canon` keeps the source of truth explicit, and `#internal-docs` biases the route toward internal governance artifacts rather than public copy.

## Current Runtime Families

Public categories make the catalog easier to browse. Runtime families explain how ShipGlows routes work internally.

| Family | Role | Examples |
| --- | --- | --- |
| Lifecycle/master | Carry work across several gates. | `000-shipglows`, `001-sg-build`, `002-sg-maintain`, `004-sg-deploy`, `006-sg-design`, `007-sg-content`, `008-sg-customer`, `900-shipglows-core build`, plus `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship` |
| Data trust/source | Frame local-first data becoming account-backed cloud data and product access becoming entitlement-backed. | `600-sg-local-cloud-sync`, `601-sg-product-entitlements` |
| Audit/source | Expose quality, security, performance, SEO, copy, design, dependency, parity, or GTM risk that may deserve a chantier. | `400-sg-audit`, `010-sg-technical`, `602-sg-platform-parity` |
| Bug/proof | Diagnose failures, validate behavior, or confirm deployment truth. | `003-sg-bug`, `106-sg-fix`, `107-sg-test`, `108-sg-browser`, `109-sg-auth-debug`, `405-sg-prod`, `105-sg-check` |
| Content/docs/support | Keep public content, documentation, scaffolding, changelogs, skill contracts, governance surfaces, and git/GitHub hygiene coherent with shipped behavior. | `007-sg-content repurpose`, `300-sg-docs`, `200-sg-redact`, `201-sg-enrich`, `304-sg-changelog`, `306-sg-scaffold`, `305-sg-init`, `010-sg-technical github` |
| Research/pilotage/helper | Clarify information, manage work/session state, prioritize, summarize, route, or preserve context without owning full lifecycle closure. | `009-sg-marketing`, `203-sg-research`, `205-sg-veille`, `011-sg-pilotage`, `301-sg-context`, `704-sg-model`, `302-sg-help`, `308-sg-status`, `303-sg-resume`, `700-sg-explore`, `706-continue`, `707-name` |
| Internal/meta | Operator-only tools for maintaining ShipGlows itself. | `900-shipglows-core` |

## Master Skills

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-technical first command | `000-shipglows <instruction>` | Answers pure conversation directly, executes deterministic micro-edits directly with focused validation, and routes substantive feature/code/docs, maintenance, bug, release, content, marketing, design, onboarding, sync, skill-maintenance, and audit work to the matching owner. Uses context-safe defaults and asks one numbered question only when ambiguity changes route, risk, scope, or proof. |
| Non-trivial product, code, site, or docs work | `001-sg-build [spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>` | Plain task text is the story. Use `spark`, `codex`, `mini`, `agents`, or `sous-agent` to make model-specific delegated sequential execution a validation gate. For user-facing features, `001-sg-build` evaluates whether to suggest or route `/008-sg-customer` after implementation. Use detailed report modes only for handoff evidence. |
| Recurring project upkeep | `002-sg-maintain [mode]` | `full`/no argument, `quick`, `security`, `deps`, `docs`, `audits`, `no-ship`, `global`. |
| Release confidence after implementation | `004-sg-deploy [target or mode]` | no argument, `skip-check`, `--preview`, `--prod`, `no-changelog`. |
| Bug-loop lifecycle | `003-sg-bug [BUG-ID, summary, or mode]` | no argument, `BUG-ID`, `--fix`, `--retest`, `--verify`, `--ship`, `--close`. |
| Content management | `007-sg-content [goal, source, file, or mode]` | `plan`, `capture-full-conversation`, `clean-transcript`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship`; `repurpose ... verbatim` preserves exact source text and is distinct from capture/cleanup. It hands market, GTM, copy, and copywriting review to an explicit `009-sg-marketing` mode. Add `score`, `quality gate`, or `grille projet` when you want project-aware scoring through the shared rubric. |
| Marketing study or review | `009-sg-marketing <mode> <target>` | `market`, `gtm`, `copy`, `copywriting`, `help`. |
| Work and conversation pilotage | `011-sg-pilotage <mode> [arguments]` | Exactly one of `tasks`, `backlog`, `priorities`, `review`, or `sessions`; unclear or mixed input asks for one mode and mutates nothing. |
| Conversation quality audit | `705-sg-conversation-audit [latest|path <file-or-dir>|export shipglows|report=agent]` | Audit recurring operator-facing defects in conversation transcripts and route durable owner actions. |
| Design lifecycle | `006-sg-design <design question or goal>` | `tokens`, `audit`, `animation`, `playground`, page/route targets, redesign goals, token migration, visual proof, or natural-language design requests. |
| Customer experience | `008-sg-customer <audit|flow|onboarding|recovery> <target>` | Four customer modes for friction/trust audits, first-success flow contracts, setup, and recoverable states; routes adjacent-owner work. |
| Local-to-cloud data sync | `600-sg-local-cloud-sync <project, feature, or data domains>` | Local data promotion, cloud hydration, merge/conflict policy, sync/save UX states, sensitive-data exclusions, and proof routing. |
| Product entitlements and access gates | `601-sg-product-entitlements <project or feature>` | Entitlement ownership, provider events, activation codes, product-local mirrors, backend authorization gates, support flows, and sync handoffs. |
| Internal skill creation or maintenance | `900-shipglows-core build <idea or path>` | new skill idea, existing skill path, optional `700-sg-explore` for fuzzy placement, runtime/docs validation gates. |

If the request concerns declared products, sales surfaces, or evidence-backed claims, start by checking `shipglows_data/business/product.md`, `shipglows_data/business/gtm.md`, and `shipglows_data/editorial/README.md` before launching a content or docs skill.

Content scoring examples:

```text
/007-sg-content audit article avec grille projet
/200-sg-redact finalise puis note ce brouillon
/007-sg-content repurpose transforme cette source en article et applique la grille qualite
/103-sg-verify verifier le gate de score editorial
```

## Supporting Skills

| Need | Launch | Useful modes |
| --- | --- | --- |
| Manual expert lifecycle | `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end` | Use when you intentionally want to drive each gate instead of using `001-sg-build`. |
| Commit and push ready work | `005-sg-ship [mode]` | no special argument, `skip-check`, `end la tache`/`end`/`fin`/`close task`, `all-dirty`/`ship-all`/`tout-dirty`. |
| Browser proof | `108-sg-browser` | Target a non-auth URL, route, preview, or production page. |
| Auth or session diagnosis | `109-sg-auth-debug` | Target login, OAuth, cookies, callbacks, tenants, providers, sessions, or protected routes. |
| Manual QA or retest evidence | `107-sg-test` | Target a guided scenario, checklist-first manual proof, test log, retest, or bug file update. |
| Deployment truth | `405-sg-prod` | Target deployment URL, build logs, runtime logs, preview/prod health, or live readiness. |
| Technical checks | `105-sg-check` | Target typecheck, lint, build, tests, dependency checks, or shell validation. |
| Readiness or excellence verification | `103-sg-verify [mode=standard|mode=excellence] [scope]` | Standard mode vérifie le métier et la ship-readiness. `mode=excellence` ou une demande naturelle non ambiguë d’excellence ajoute une seconde focale critique et retourne `verified_with_excellence_gaps` ou `excellent`; il ne remplace pas un audit spécialiste. |
| Documentation work | `300-sg-docs [mode or target]` | `readme`, `api`, `components`, `audit`, `update`, `metadata`, `technical`, `editorial`, or a file path. |
| Git/GitHub hygiene | `010-sg-technical github [mode]` | `audit`, `branches`, `dependabot`, `fix`, plus current-repo or workspace scope. |
| Audit lane | `400-sg-audit*` | Choose the audit owner: code, design, copy, SEO, GTM, deps, perf, a11y, translation, components, or design tokens. |
| Platform parity/concordance | `602-sg-platform-parity <project, feature, or spec path>` | Check product and technical parity across web, Android, iOS, Windows, macOS, and Linux; route gaps to `100-sg-spec`, `001-sg-build`, `107-sg-test`, `103-sg-verify`, `300-sg-docs`, or `005-sg-ship`. |
| Conversation quality lane | `705-sg-conversation-audit` | Classify recurring conversation execution defects and route concrete owner follow-up paths. |
| Internal ShipGlows Core audit | `900-shipglows-core audit [scope]` | Operator-only execution-fidelity audit for ShipGlows itself; use `900-shipglows-core packaging [scope]` for plugin-packaging readiness. Neither mode is a public user-plugin surface. |
| Design system creation | `006-sg-design system [target]` | Use when no coherent professional token system exists; follow with `playground` or `audit tokens` as needed. |
| Animation lifecycle | `006-sg-design animation <audit|design|implement|tune> [scope]` | Audit, design, implement, or tune coherent motion; GSAP is optional after stack, licensing, lifecycle, reduced-motion, and performance fit. |
| Technical posture | `010-sg-technical <audit|deps|performance> [target]` | Select exactly one code/security, dependency, or performance lane. |
| Framework migration | `010-sg-technical migrate [package[@version]]` | Use a structured package target such as `astro@5`, a package name, or no argument for discovery. |
| Orientation and routing | `308-sg-status`, `302-sg-help`, `704-sg-model`, `303-sg-resume` | Use for git dashboard, workflow help, model choice, or concise context transfer. |
| Conversation naming, status, and cleanup | `011-sg-pilotage sessions <project-or-cwd>` | Review unmanaged Codex titles; use `sessions rename <status>` for the current conversation or `sessions prune <project-or-cwd>` for a dry-run preview before deletion. |

Model routing note: `704-sg-model` recommends the right model for the current scope. In Codex/OpenAI, default small bounded subagents to `gpt-5.4-mini`, use `gpt-5.3-codex-spark` for Spark-eligible summaries, text-only handoffs, micro-code, or targeted UI/local edits when credits/availability permit, route long implementation through the `codex` implementation profile, and use `gpt-5.5` with calibrated `low`/`medium`/`high`/`xhigh` reasoning for high-risk transverse reasoning. The main thread may only recommend a model switch unless the runtime supports applying the override; `spark`, `codex`, `sous-agent`/`subagent`/`agents`, and `mini` arguments request model-specific subagent delegation.

## Explicit Mode Switches

| Skill | Explicit modes currently documented |
| --- | --- |
| `000-shipglows` | `<instruction>`; pure conversation direct answer; direct main-thread handoff to selected `sg-*` skill; one numbered clarification question when ambiguous |
| `001-sg-build` | `<story, bug, or goal>`; `spark`; `codex`; `mini`; `agents`; `sous-agent`; `no-agents`; `report=agent`; `handoff`; `verbose`; `full-report` |
| `002-sg-maintain` | no argument/`full`; `quick`; `security`; `deps`; `docs`; `audits`; `no-ship`; `global`; detailed report modes |
| `004-sg-deploy` | no argument; `skip-check`; `--preview`; `--prod`; `no-changelog` |
| `003-sg-bug` | no argument; `BUG-ID`; free-text summary; `--fix`; `--retest`; `--verify`; `--ship`; `--close` |
| `007-sg-content` | no argument or content goal; `plan`; `repurpose`; `draft`; `article`; `blog`; `guide`; `enrich`; `audit`; `copy`; `copywriting`; `seo`; `editorial`; `apply`; `publish`; `ship`; `score`; `quality gate`; `grille projet` |
| `009-sg-marketing` | `market <target>`; `gtm <target>`; `copy <target>`; `copywriting <target>`; `help` |
| `006-sg-design` | design question; page/route; `tokens`; `audit`; `animation`; `playground`; redesign goal; token migration; visual proof; detailed report modes |
| `008-sg-customer` | `audit [scope]`; `flow [feature-or-flow]`; `onboarding [feature-or-flow]`; `recovery [feature-or-state]`; detailed report modes |
| `600-sg-local-cloud-sync` | project, feature, data domains, sync question; audit; Flutter focus; secrets/sensitive-data focus; detailed report modes |
| `900-shipglows-core build` | new skill idea; existing skill path; `700-sg-explore` reroute when placement or public promise is too fuzzy |
| `010-sg-technical github` | no argument/`audit`; `branches`; `dependabot`; `fix`; `current repo`; `workspace` |
| `900-shipglows-core` | `audit [scope]`; `build <target>`; `refresh <target>`; `packaging [scope]`; `help`; `report=agent` |
| `705-sg-conversation-audit` | `latest`; `path <file-or-dir>`; `export shipglows`; `report=agent` |
| `602-sg-platform-parity` | project, feature, or spec path; `platforms=web,android,ios,windows,macos,linux`; `report=agent` |
| `006-sg-design` | `system`; `playground [route]`; `audit ui|tokens|components|a11y [scope]`; `animation <audit|design|implement|tune> [scope]`; library/redesign/migration; detailed report modes |
| `005-sg-ship` | no special argument; `skip-check`; `end la tache`; `end`; `fin`; `close task`; `all-dirty`; `ship-all`; `tout-dirty` |
| `103-sg-verify` | no mode/`mode=standard` for métier correctness, proof, risk, and ship-readiness; `mode=excellence` or an unambiguous natural-language excellence request for a fresh second focus beyond acceptance criteria; verdicts `verified`, `verified_with_excellence_gaps`, or `excellent`, while proof/risk failures keep precedence |
| `407-sg-translate` | bare or path shorthand = audit; `audit [path\|global]`; `sync [path]`; `apply [path]` is a sync alias; `help` is discovery-only |
| `011-sg-pilotage` | `tasks [focus]`; `backlog [add|defer|review|clean]`; `priorities [impact|effort|blockers|high-roi|quick-wins]`; `review [daily|weekly|sprint|release]`; `sessions [project-or-cwd|rename <status>|prune [cwd]]` | Select one management action; session prune is dry-run first and apply requires exact cwd confirmation. |

## How To Read Arguments

An argument can be one of three things:

| Argument type | Meaning | Example |
| --- | --- | --- |
| Mode keyword | A word or flag switches the workflow. | `002-sg-maintain quick`, `004-sg-deploy skip-check`, `005-sg-ship all-dirty` |
| Structured input | The shape of the argument selects a target. | `010-sg-technical migrate astro@5`, `003-sg-bug BUG-2026-05-03-001` |
| Free-form task | The argument is the actual work description. | `001-sg-build add a markdown skill cheatsheet` |

When in doubt, read the skill's `argument-hint` and mode-detection section. If no mode rule matches, treat the argument as a task or target description.

## Shell Shortcuts

| Shortcut | Expands to | Use |
| --- | --- | --- |
| `ch` | `clear; tmux clear-history` | Clear the current shell screen and the current tmux pane scrollback. |
