---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "2.32.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-24"
status: reviewed
source_skill: 102-sg-start
scope: skill-runtime-and-lifecycle
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/
  - skills/references/
  - skills/references/skill-instruction-layering.md
  - skills/references/skill-context-budget.md
  - skills/references/expert-mode-aliases.md
  - skills/000-shipglows/SKILL.md
  - skills/708-sg-auto/SKILL.md
  - skills/references/no-local-execution-policy.md
  - skills/references/execution-posture-tags.md
  - skills/references/entrypoint-routing.md
  - skills/001-sg-build/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/011-sg-pilotage/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/900-shipglows-core/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/305-sg-init/SKILL.md
  - tools/skill_invocation_check.py
  - tools/resource_dependency_graph.py
  - skills/references/skill-invocation-registry.json
  - tools/skill_activation_budget.py
  - skills/300-sg-docs/SKILL.md
  - skills/references/reporting-contract.md
  - skills/references/reporting-agent-handoff.md
  - skills/references/reporting-blocked-and-audit.md
  - skills/references/reporting-pressure-scenarios.md
  - skills/references/master-workflow-lifecycle.md
  - skills/references/git-milestone-delivery-contract.md
  - skills/references/decision-quality-contract.md
  - skills/references/spec-driven-development-discipline.md
  - skills/references/content-quality-rubric.md
  - skills/references/question-contract.md
  - skills/references/sentry-observability.md
  - skills/references/design-inspiration-library.md
  - tools/capture_design_inspiration.py
  - tools/vivaldi_bookmarks.py
  - tools/audit_shipglows_skills.py
  - specs/001-sg-build-autonomous-master-skill.md
  - specs/skill-reporting-modes-and-compact-reports.md
  - shipglows_data/workflow/playbooks/spec-driven-workflow.md
  - templates/
  - docs/technical/
  - docs/editorial/
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
    artifact_version: "0.22.0"
    required_status: draft
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "skills/references/editorial-content-corpus.md"
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 closes all 29 residual full-graph findings through canonical migrations, boundary reclassification, inverse-edge repair, and other-project governance removal; integrated complete graph 691/895/0 and profiled graph 133/89/0 are valid."
  - "Wave 19 migrates 44 proven canonical missing paths, resolves the 10 original constraint findings, reclassifies 6 non-artifact unversioned edges, and retains 29 classified missing targets without introducing cycles or fake metadata."
  - "Wave 18 removes all three full-graph cycles, repairs 79 constraints, migrates 13 active canonical paths, and reclassifies 73 historical edges as evidence while preserving the valid profiled graph."
  - "Skill inventory and workflow doctrine."
  - "Editorial content corpus and Editorial Reader role added for public-content impact analysis."
  - "Governance corpus lifecycle added: 305-sg-init bootstraps, 300-sg-docs maintains, 001-sg-build consumes."
  - "108-sg-browser added as the generic non-auth Playwright MCP browser evidence skill."
  - "Runtime capability discovery now checks direct and deferred/searchable tool catalogs before declaring configured Playwright unavailable."
  - "900-shipglows-core build is the sole internal lifecycle mode for ShipGlows skill maintenance."
  - "004-sg-deploy added as the dedicated release confidence orchestrator."
  - "006-sg-design added as the master design lifecycle orchestrator for UI/UX, tokens, playgrounds, visual proof, verification, and ship routing."
  - "Private Vivaldi bookmark intake reads only configured design subtrees and keeps machine paths and real results outside the public repository."
  - "002-sg-maintain promoted to a master maintenance lifecycle from triage through delegated execution, verification, and ship/deploy routing."
  - "Shared reporting contract added: concise user reports by default, explicit agent handoff reports when requested."
  - "Reporting contract clarified: user-mode ship reports should match the user's active language, use outcome/evidence/limits ordering, and allow a few sober status emojis."
  - "Wave 13 combines ownership and executable resource-closure preflight, while retaining --all as a diagnostic of historical dependency debt."
  - "Wave 13 keeps the reporting decision surface in a compact core and moves agent handoff, blocked/audit, and maintenance scenarios to direct conditional leaves."
  - "Wave 14 adds measured activation profiles for high-traffic owners 010, 103, and 300, bringing the executable pilot to six profiles without changing runtime loaders."
  - "Wave 15 compacts three shared baseline authorities in place and exposes detailed path, autonomy, and implementation procedure through direct conditional leaves."
  - "Wave 16 compacts five domain workflow monoliths into compatibility cores with direct non-chaining leaves and adds five measured activation profiles."
  - "Wave 17 reduces the 010 and 103 selected baselines below 5,000 tokens through conditional semantic-mode routing and direct verification release-proof/CI leaves."
  - "Skill launch cheatsheet added for master and supporting modes."
  - "900-shipglows-core build routes fuzzy skill ideas or placement decisions through 700-sg-explore before 100-sg-spec."
  - "Codex source-tree discovery follows the official ~/.agents/skills user scope, with a native PowerShell junction helper for Windows developers."
  - "007-sg-content added as the master content lifecycle for strategy, repurposing, drafting, enrichment, audits, docs, validation, and ship routing."
  - "008-sg-customer renamed as the customer activation lifecycle for first-success paths, setup guidance, recoverable states, docs impact, and proof routing."
  - "600-sg-local-cloud-sync added as the local-to-cloud data promotion, merge, sync UX, and security contract skill."
  - "001-sg-build delegated sequential subagent consent clarified; subagents and parallelism are distinct runtime concepts."
  - "Master delegation semantics extracted to skills/references/master-delegation-semantics.md and cited by master/orchestrator skills."
  - "Master workflow lifecycle extracted to skills/references/master-workflow-lifecycle.md; bug work items now use shipglows_data/workflow/bugs/*.md as source of truth and shipglows_data/workflow/BUGS.md as optional/generated triage."
  - "000-shipglows <instruction> documented as the primary non-technical router with direct main-thread handoff to selected skills."
  - "300-sg-docs init clarified as the governance bootstrap lane for empty or near-empty repositories, with explicit bootstrap README and code-docs-map behavior."
  - "Shared operator/question doctrine clarified: the operator is not a fallback coder, but is the right source for business-critical framing questions when repository evidence is insufficient."
  - "Shared question/default contract added for numbered user-facing decisions and context-safe defaults."
  - "003-sg-bug clarified as a bug lifecycle executor through owner skills and bounded subagents, not a simple next-command router."
  - "Shared Sentry observability reference added for runtime evidence, release/environment correlation, redaction, and performance overhead checks."
  - "Sentry reference clarified: skills never have direct Sentry dashboard access; bounded local PM2 logs and redacted Doppler presence/scope checks are acceptable supporting evidence when no Sentry pointer is supplied or visible."
  - "Model routing now resolves through the canonical Sol/Terra/Luna and `codex` profiles; Spark is selected only when the runtime exposes it and model overrides are reported as applied or advisory."
  - "Delegation defaults clarified: two or more independent read-only scopes fan out in parallel, mutations stay delegated sequential, and parallel writes require ready non-overlapping Execution Batches with an integration owner."
  - "Layered skill-instruction contract added for progressive SKILL.md compaction with pilot extraction to skill-local references."
  - "Spec-driven development discipline added: spec-first remains the outer lifecycle contract, while execution skills choose proof paths such as test-first, regression-first, scenario-first, evidence-first, or exception-with-proof."
  - "Pilot compaction applied to 300-sg-docs, the former design-audit contract, and 103-sg-verify while preserving chantier/reporting/security/doc-update gates."
  - "Skill taxonomy description audit applied compact routing descriptions across 61 skills while preserving names, trace categories, process roles, and runtime visibility."
  - "103-sg-verify aligned stale dependency metadata during the skill taxonomy description verification."
- "Decision quality contract: ShipGlows optimizes for shipped business value and short lead time through coherent architecture, with safety and proof proportional to concrete risk."
- "Skill instruction layering refreshed: SKILL.md is the activation contract; detailed playbooks, examples, matrices, and edge cases belong in references."
- "Codex model wording refreshed to use the current `codex` implementation profile instead of pinning long implementations to a deprecated slug."
  - "102-sg-start local auto-verify contract added: eligible local, tool-backed, non-destructive verification can run inside 102-sg-start, while hosted/browser/manual/production/ship proof stays with owner skills and 001-sg-build remains full lifecycle orchestrator."
  - "900-shipglows-core added as an internal operator skill for skill execution-fidelity audits and plugin-packaging readiness, backed by tools/audit_shipglows_skills.py."
  - "010-sg-technical github added as the git/GitHub sync, stale branch, PR drift, and Dependabot hygiene skill."
  - "Public/docs handoff clarity updated: helper docs now distinguish explains vs routes vs invokes vs owns execution, and runtime docs clarify that OpenCode/KiloCode internal calls are not manual operator commands."
  - "Rights-aware private design-inspiration corpus and bounded Inspiration Gate added for design and copy workflows."
  - "006-sg-design library add, approve, list, and status modes added for safe private-corpus curation and index synchronization."
  - "011-sg-pilotage consolidated task maintenance, backlog, priorities, review, and Codex-session operations behind five explicit lazily loaded modes."
  - "2026-08-03: progressive resource discovery added a read-only resolver with stable semantic IDs, bounded canonical-root scanning, dependency expansion, and explicit authority limits."
  - "2026-08-04 added provider-neutral animation modes to 006-sg-design; GSAP remains optional after project-fit and proof gates."
  - "2026-08-04 added the exact 302-sg-help mode catalog with one line per repository skill and registered free-form help invocation validation."
  - "2026-08-12 wave 12 added compact lifecycle/delegation decision cores for the 004 pilot and direct entitlement ledger/ingestion/support-proof leaves for 601."
  - "Métier-first public hierarchy separates 13 public owners from numeric internal engines and requires progressive clarification followed by autonomous outcome ownership."
  - "Public skills now have direct runtime folders and matching Codex metadata; numeric prefixes are expert/compatibility identifiers rather than picker names."
  - "Codex expert shortcuts now resolve through public owner modes before internal engines; core remains the sole hard system-context switch."
  - "Two-tier mutation approval adds a cumulative fast path for exact local routine reversible actions while keeping full plans for ineligible and remote mutations."
  - "2026-08-15: bounded technical chantier approval now includes ordinary exact-scope local commits without duplicate approval."
  - "2026-08-15: every closure now exposes documentation reflection and material documentation gaps prevent closed or shipped wording."
  - "2026-08-15: successful closure reports now use a stable four-block visual card with one-line proof and documentation evidence separated by middle dots."
  - "2026-08-15: approved substantive chantiers now open with a matching four-block start card, use the open-book documentation icon, and omit technical file links from user reports."
  - "2026-08-18: report cards now have an explicit effort ceiling: one meaningful proof may suffice and no work is created merely to fill a block."
  - "2026-08-15: standalone `v` canonically approves only the immediately preceding pending approval message."
  - "2026-08-16: current-project hygiene is read-only and proposal-first; explicit Git scope specializes to the safe Git cleanup workflow."
  - "2026-08-20: shipglows auto added as a bounded autonomous credit-window route through internal 708-sg-auto; it always composes the independent nolocal policy, prioritizes useful reasoning/generation after safety eligibility, and leaves all work implemented but unverified."
  - "2026-08-20: auto was refined to optimize durable value rather than token burn, freeze the launch root, coordinate concurrent claims, recommend useful subagents, and treat Fast as an external pre-existing client state."
  - "2026-08-20: #local, #nolocal, and #ci became position-independent execution posture tags; #ci implies #nolocal, auto implies #nolocal, and shipglows nolocal remains compatibility syntax."
  - "2026-08-21: every explicit coherent validated implementation milestone commits before the next slice, and standard clean chantier closure requires final commit plus ordinary upstream push."
next_review: "2026-06-01"
next_step: "/300-sg-docs technical audit skills"
---

# Skill Runtime And Lifecycle

## Purpose

This doc covers ShipGlows skills, lifecycle flow, references, templates, model/topology decisions, and documentation gates. Read it before changing `skills/*/SKILL.md`, shared skill references, or `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.

## Instruction Layering Policy

ShipGlows skill instructions follow layered progressive disclosure:

- compact activation logic in `skills/*/SKILL.md`
- shared doctrine in `skills/references/*.md`
- heavy skill-specific checklists/playbooks in `skills/<skill>/references/*.md`

Use `skills/references/skill-instruction-layering.md` as the canonical placement contract. `SKILL.md` is the activation contract: keep trigger, mission, scope, required loaders, stop conditions, validation commands, report mode, and local non-negotiables there; move detailed playbooks, examples, matrices, troubleshooting branches, and edge cases to references. Use `skills/references/skill-context-budget.md` for body-size and discovery-budget thresholds.

Compaction must preserve operational guardrails: canonical path resolution, chantier trace semantics, reporting contract loading, security/redaction rules, and documentation-update gates.

Large workflow references should use a compact compatibility core at the established path and direct leaves by real mode, phase, or proof gate. The top-level `SKILL.md` remains the activation contract and names the exact references to load; no local leaf loads a sibling.

## Public Métier Surface And Internal Engines

Discovery descriptions are routing triggers, not workflow summaries. Keep them
short, one sentence, and front-loaded with the work type or domain.

The normal operator surface is one router plus thirteen public métier owners:

| Domain | Public owner | Engine mapping |
| --- | --- | --- |
| Créer | `sg-development`, `sg-design`, `sg-experience` | `001-sg-build`, `006-sg-design`, `008-sg-customer` |
| Qualité | `sg-bug`, `sg-engineering`, `sg-maintenance` | `003-sg-bug`, `010-sg-technical` plus `600`/`601`/`602`, `002-sg-maintain` |
| Publier | `sg-release` | `004-sg-deploy` |
| Développer l’audience | `sg-content`, `sg-marketing`, `sg-seo` | `007-sg-content`, `009-sg-marketing`, `406-sg-seo` |
| Gouverner | `sg-docs` | `300-sg-docs` |
| Organiser | `sg-planning`, `sg-help` | `011-sg-pilotage`, `302-sg-help` |

`shipglows` is the public natural-language router. Each public owner has a
real folder and matching `name:` metadata (`skills/sg-development/`,
`skills/sg-engineering/`, and so on), so the runtime picker exposes the métier
name directly. Public owners select and coordinate numeric engines invisibly;
they do not require operators to learn
the lifecycle, proof, research, context, or packaging helper names.

The resolution hierarchy is `project -> product -> surface -> feature`.
Repository evidence decides as much of that hierarchy as possible. This keeps
multi-product projects safe: absence of an explicit product name is not a
license to alter every product or surface.

The owner follows a progressive clarification gate:

1. Inspect relevant evidence and established contracts.
2. Ask one numbered question only if a missing operator-owned business, scope,
   safety, permission, or external-effect decision changes the work.
3. Never ask the operator to select an engine, playbook, implementation
   technique, validation command, or handoff topology.
4. Once a fresh agent could execute safely, continue from specification or a
   bounded execution contract through implementation, proof, documentation
   reflection, and closure.

The only valid returns to the operator are a real decision, new authority,
secret, destructive/external effect, or genuinely manual proof. A public owner
may use `100`–`109`, `200`–`205`, `301`–`308`, `400`, `405`, `600`–`602`, `700`–`707`,
or `900` engines as appropriate. `900-shipglows-core` remains internal-only.

Three-digit codes remain only in the expert/compatibility lookup through
`skills/references/skill-code-index.md`; they are not runtime-picker identities
or a second public taxonomy. `sg-help expert` exposes that catalogue when
explicitly requested.

Codex expert shortcuts are a separate ergonomic layer, not separate owners.
Their canonical resolution is `router alias -> public owner -> owner mode ->
internal engine`, declared in `skill-invocation-registry.json` and explained by
`expert-mode-aliases.md`. Default help continues to show métier modes only;
expert help adds the shortcut equivalences and numeric targets. `verify`
preserves an explicit specialist owner before using its proof path, while
`core` alone hard-binds the remaining request to ShipGlows-system maintenance.

The same registry is the canonical ownership graph. `skill_invocation_check.py`
validates public wrappers, declared engines, alias ownership, and complete expert
coverage, then validates the executable resource closure before accepting an explicit invocation. Optional pilot
`activation_profiles` declare body, baseline, and named conditional reference
sets without parsing prose; `skill_activation_budget.py` validates and measures
them, and selected-profile failure blocks preflight. Their explicit paths seed
`resource_dependency_graph.py`: `skills/**` dependencies are traversed
transitively, while profiled `shipglows_data/**` artifacts are verified as
terminal project-governance leaves. Required semantic versions, exact statuses,
target metadata, and reachable cycles fail closed. Runtime loaders remain the
execution authority; no edge is inferred from prose or `linked_systems`.

The default dependency command covers this executable profiled closure only.
`resource_dependency_graph.py --all` audits the broader current corpus to expose
historical dependency debt, but that diagnostic is not an invocation gate.

Wave 18 reduces that full diagnostic from 687 artifacts, 998 dependencies, 3
cycles, and 272 findings to 688 artifacts, 923 dependencies, zero cycles, and
89 findings. It repairs 79 safe constraints, migrates 13 active canonical
paths, and moves 73 historical relationships from executable `depends_on`
metadata to provenance evidence. The remaining 73 missing targets, 6 status
mismatches, 6 unversioned targets, 3 invalid required-version constraints, and 1 invalid actual status stay explicit and
non-blocking. The profiled invocation graph remains valid at 133 artifacts, 89
dependencies, and zero cycles.

Wave 19 continues the diagnostic-only cleanup from 688 artifacts, 923
dependencies, zero cycles, and 89 findings to 689 artifacts, 912 dependencies,
zero cycles, and 29 findings. Forty-four missing paths now resolve to proven
canonical artifacts, all 10 original constraint issues are resolved, and 6
non-artifact README, template, or executable-skill edges are reclassified
outside `depends_on` without fake metadata. The 29 remaining findings are all
missing targets classified as external resources, genuinely absent artifacts,
old unversioned skill paths without a proven equivalent, or inverse
relationships that would create cycles. Two candidate migrations were reverted
after cycle proof. The profiled execution graph remains valid at 133 artifacts,
89 dependencies, and zero cycles.

Wave 20 closes the integrated full graph at 691 artifacts, 895 dependencies, zero cycles,
and zero findings while the profiled execution graph remains valid at
133/89/0. Canonical documentation stays versioned in `depends_on`; executable
skills and runtime shims stay linked systems; external or historical inputs are
evidence only; and unrelated project governance is excluded. Dependency-path
normalization removes only an explicit `./` prefix so `.agents` and `.opencode`
remain exact hidden-directory paths.

Wave 14 extends this accounting and preflight pilot to six owners: `004`,
`010`, `103`, `300`, `601`, and `900`. It records high selected baselines for
`010` (11,361 tokens), `103` (9,517), and `300` (6,791) without altering their
runtime loading semantics. The next remediation boundary is repeated shared
baseline weight in canonical-path resolution, intent-to-outcome autonomy, and
decision-quality doctrine; that compaction is explicitly outside Wave 14.

Wave 15 completes that shared-baseline tranche without changing the six owner
loaders or canonical authority paths. `canonical-paths.md`, `intent-to-outcome-
autonomy.md`, and `decision-quality-contract.md` retain the first safe decision;
five purpose-specific references hold detailed runtime/private-root, project-
governance, execution, pressure-scenario, and implementation-discipline work.
Each leaf is selected directly and never chains to a sibling. Before any new
conditional gate, selected baselines measure `004` 3,128, `010` 6,177, `103`
5,657, `300` 3,451, `601` 2,081, and `900` 2,487 estimated tokens. The 010 and
103 baselines remain above target and are reported as follow-up debt.

Wave 16 adds profiles for `109-sg-auth-debug`, `200-sg-redact`,
`201-sg-enrich`, `400-sg-audit`, and `405-sg-prod`. Their former workflow
cores measured 5,870, 7,196, 6,607, 6,524, and 6,189 tokens; their compact
cores now measure 799, 827, 808, 672, and 727. Selected baselines are 3,544,
2,222, 2,097, 2,961, and 2,821. Phase and proof leaves are direct and
non-chaining, so profile gates remain independent activation choices.

Wave 17 closes the two remaining selected-baseline hotspots. `010` loads its
technical router only after semantic-mode selection requires it and measures
4,562 tokens, down from 6,177. `103` no longer pays twice for the
ShipGlows-owned preflight already expressed by its activation contract; direct
release-proof and CI leaves load only at their evidence gates. Its baseline is
4,907 tokens, down from 5,657. These changes preserve owner routing, verdict
precedence, security/product gates, proof semantics, stops, and reporting.

Wave 12 demonstrates two compatible progressive patterns. `004-sg-deploy`
loads `master-workflow-lifecycle-core.md` plus `master-delegation-core.md` for
the normal multi-stage decision and escalates to the existing detailed
authorities only when the cores identify unresolved detail. `601` loads the
primary entitlement invariants, then exactly one direct ledger/authorization,
provider-ingestion, or support/proof branch. Neither pattern uses reference
chaining or replaces runtime loader authority with profile metadata.

Wave 13 applies the direct-leaf pattern to final reporting. The compact
`reporting-contract.md` owns the default user decision surface.
`reporting-agent-handoff.md`, `reporting-blocked-and-audit.md`, and
`reporting-pressure-scenarios.md` load only at their declared gates and never
chain to siblings. Explicit `report=agent` has sole priority for detailed risks
and audit handoffs; it does not also load the blocked/audit leaf.

Within helper/pilotage surfaces, keep the first-screen distinction explicit:

- `302-sg-help` explains workflow, doctrine, and skill choice; its default catalogue is public, while `expert` exposes the internal engine list.
- `303-sg-resume` summarizes the visible conversation only.
- `706-continue` advances the currently resolved work item from durable local evidence.
- `000-shipglows` routes or answers directly at the main entrypoint.
- `301-sg-context` primes minimum sufficient, qualified context before known work. It uses contextual MCP operations only when callable and otherwise falls back to focused native search, reads, Git, environment, and canonical-source evidence.
- `308-sg-status` reports cross-project git and sync state.
- `700-sg-explore` frames the problem or option space before commitment.
- `011-sg-pilotage tasks` maintains the durable execution tracker; editorial/public-content follow-up stays in `shipglows_data/editorial/ROADMAP.md` through content owners.
- `011-sg-pilotage backlog` captures, defers, cleans, or promotes future work.
- `011-sg-pilotage priorities` ranks active work for immediate execution order without executing it.
- `011-sg-pilotage review` reconstructs what happened, what is proven, and what should happen next without replacing verification.
- `011-sg-pilotage sessions` triages repository-scoped Codex titles, renames only the current thread with an explicit status, and previews safe old-session pruning.
- `704-sg-model` recommends the right model policy for the current scope.
- `707-name` stores the current Claude session's local statusline tag; Codex title changes stay in `011-sg-pilotage sessions`.
- `800-tmux-capture-conversation` exports a raw tmux conversation transcript to Markdown.
- `801-clean-conversation-transcript` cleans one existing transcript for readability.

Do not blur these roles. Help is not continuation, resume is not repo truth, continue is not a passive summary, route is not context priming, context priming is not execution, and status reporting is not maintenance ownership.

Keep the pilotage boundary explicit as well: exploration is not backlog grooming, backlog grooming is not current prioritization, prioritization is not retrospective review, and review is not open-ended ideation.

Keep the execution-pilotage boundary explicit too: task-tracker maintenance is not continuation of the active work item, and continuation is not a generic request to rewrite tracker state.

Keep the residual helper boundary explicit as well: model routing is not execution, session naming is not recap, transcript capture is not transcript cleaning, and transcript cleaning is not content repurposing by default.

## Public/Docs Handoff Vocabulary

Keep public and repo-visible guidance aligned on four distinct jobs:

- `explains`: a helper surface clarifies doctrine, invocation, or choice without taking over work
- `routes`: an entrypoint decides the next owner skill or answers directly when no owner is needed
- `invokes`: the runtime executes an internal skill/tool call after the user request is interpreted
- `owns execution`: the selected lifecycle or specialist skill now carries the work, proof path, and stop conditions

Use this vocabulary consistently:

- `302-sg-help` explains and routes.
- `000-shipglows` routes or answers directly at the main entrypoint.
- `706-continue` resumes the current work item from durable evidence.
- Lifecycle and specialist owners own execution once selected.

Do not describe a helper as if it owns execution, and do not describe a runtime-internal invocation as if it were a manual operator command.

## Runtime Invocation Note

Runtime-facing docs must distinguish user input from runtime internals:

- In Codex or Claude-style runtimes, the operator launches a public métier name such as `shipglows` or `sg-development`; numeric engines remain available for expert precision.
- In OpenCode or KiloCode-style runtimes, the operator should ask for the ShipGlows skill in natural language or choose it through the runtime skill picker.
- Internal calls such as `skill({ name: "shipglows" })` may appear in runtime implementations or logs, but they are not commands the operator should type manually.

Named operator profiles are a separate invocation layer above skills:

- `skill` = capability and execution owner
- `operator role` = stable decision contract
- `agent profile` = human-readable named invocation such as `Victoire` or `SEO Specialist`

Profiles do not replace owner-skill routing. They bias the arbitration and answer shape used by `000-shipglows` or `302-sg-help`.

Syntax split:

- `%<Profile>` = named operator profile activation
- `#<Tag>` = focus tag or route-bias cue
- `profile=<id>` = compatibility syntax when a plain prefix is easier in a given runtime

The canonical behavior contract for profile resolution, precedence, fallback, and reporting lives in `skills/references/profile-activation.md`.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `skills/*/SKILL.md` | Executable skill contracts | Keep descriptions compact; route heavy detail to references |
| `skills/references/*.md` | Shared doctrine and provider-specific references | Resolve from `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}` |
| `tools/resource_resolver.py` | Read-only progressive discovery of relevant shared references, skill-local references, and reusable workflow playbooks | Run only after owner skill/mode selection; resolve from `${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}` and canonical roots |
| `skills/references/resource-discovery.md` | Resolver invocation, semantic resource IDs, bounded expansion, migration guidance, and authority boundary | Advisory discovery only; mandatory skill gates, project truth, freshness, owner, and proof contracts remain authoritative |
| `skills/references/skill-instruction-layering.md` | Canonical layering contract for `SKILL.md` activation rules vs shared or skill-local references | Load before editing or compacting skills |
| `skills/<skill>/references/*.md` | Skill-local heavy checklists, mode playbooks, and report matrices | Keep top-level SKILL focused on activation and gates |
| `skills/references/master-delegation-semantics.md` | Shared master/orchestrator delegation, subagent, short-approval, and parallelism doctrine | Load before master skills choose execution topology |
| `skills/references/mutation-plan-approval.md` | Universal two-tier and explicit post-message approval gate for intentional mutations | A full approved technical chantier includes exact-scope milestone commits and its disclosed ordinary final push; force, history rewrite, unrelated scope, and undisclosed remote effects remain gated. |
| `skills/references/git-milestone-delivery-contract.md` | Mandatory Git persistence at coherent milestones and clean chantier end | Commit each declared validated slice before continuing; commit remaining closure changes and push all owned commits before standard clean closure. Never create empty commits or absorb unrelated dirty paths. |
| `skills/references/master-workflow-lifecycle.md` | Shared master/orchestrator lifecycle skeleton and work item model | Load before master skills resolve intake, readiness, model/topology, validation, verification, closure, or ship/deploy routes |
| `skills/references/master-{workflow-lifecycle,delegation}-core.md` | Compact first-decision lifecycle and topology gates | Load from migrated pilots first; escalate to the detailed authority only on the core's explicit conditions |
| `skills/references/decision-quality-contract.md` | Shared shipping-quality doctrine: business value and short lead time, coherent architecture, non-negotiable safety, relevant performance, maintainability, and proportional proof | Load before routing, model/fallback selection, implementation, fixes, skill-contract changes, verification, or recommended defaults |
| `skills/references/context-quality-contract.md` | Shared context capsule, evidence-state, authority, invalidation, readiness, and handoff doctrine | Load when context sufficiency, authority, freshness, conflict, compaction, or handoff can change a decision or completion claim |
| `skills/references/skill-code-index.md` | Canonical numeric lookup from memorable codes to unchanged skill names | Update whenever a skill is added, removed, or renamed; validate with `python3 tools/skill_code_index_lint.py` |
| `skills/900-shipglows-core/SKILL.md` | Internal lifecycle owner for ShipGlows skill audit, build, refresh, and packaging modes | Keep out of public plugin packaging and public skill pages unless the operator explicitly changes the policy |
| `skills/references/spec-driven-development-discipline.md` | Shared spec-first/proof-first discipline | Load before execution or verification when behavior, bug, skill contract, UI/docs/auth/deploy, operational, or integration work needs a proof path |
| `skills/references/content-quality-rubric.md` | Shared project-aware content quality scoring schema and blocked-code contract | Load when content owner skills or `103-sg-verify` produce/consume editorial quality gates |
| `skills/references/reporting-contract.md` and `skills/references/reporting-*.md` | Compact final-report core plus direct conditional leaves | Successful user mode loads the core; explicit agent mode has sole detailed-report priority; blocked/audit and pressure scenarios load only at their gates |
| `skills/references/sentry-observability.md` | Shared Sentry runtime evidence, PM2/Doppler fallback evidence, release/environment correlation, redaction, and performance-overhead doctrine | Load when runtime behavior, crashes, 5xx, event IDs, deploy confidence, auth/payment/data failures, jobs, webhooks, verification, audits, or perf checks depend on observability |
| `skills/references/product-entitlements-playbook.md`, `product-entitlement-{ledger-and-authorization,ingestion,support-and-proof}.md` | Primary product-access invariants plus direct conditional procedure branches | Load the primary doctrine after entitlement selection, then one branch for ledger/backend, ingestion, or support/proof work |
| `skills/references/design-inspiration-library.md`, `skills/references/design-inspiration/`, `tools/vivaldi_bookmarks.py` | Shared private-corpus, capture-bundle, rights, taxonomy, Inspiration Gate, and optional read-only bookmark intake | Load for new visual direction, sales/offer-page creation, major redesign, copy-pattern comparison, or explicit inspiration requests; search only privately configured Vivaldi subtrees, treat results as candidates, and never load the full bookmark collection or private corpus by default |
| `skills/601-sg-product-entitlements/SKILL.md` | Product entitlement skill for access ownership, provider-event handling, backend authorization gates, support flow framing, product-local mirrors, and sync/auth handoffs | Load when projects need an entitlement contract, duplicate-ledger review, product-access guard design, provider/manual grant routing, or entitlement-gated sync preconditions |
| `skills/600-sg-local-cloud-sync/references/*.md` | Local-to-cloud sync doctrine, UX/security checklist, and Flutter implementation checklist | Load when projects touch local data promotion, cloud hydration, merge/conflict policy, sync state UX, sensitive-data exclusions, or reinstall recovery |
| `skills/references/subagent-roles/*.md` | Internal role contracts such as Technical Reader and Editorial Reader | Role files are read by orchestration skills; keep read-only roles explicit |
| `skills/references/operator-roles/*.md` | Operator decision-role contracts such as `growth-operations-lead` | Keep these focused on arbitration rules, preferred owner skills, stop conditions, and output shape |
| `skills/references/profile-activation.md` | Canonical profile resolution, precedence, fallback, and reporting contract | Load before changing named-profile semantics or examples |
| `skills/references/profile-project-context.md` | Canonical project-context bundle mapping for named profiles | Load before changing how profiles consume project business/product/editorial/technical context |
| `shipglows_data/business/agent-profiles/*.md` | Human-readable named operator profiles such as `Victoire` or `SEO Specialist` | Profiles bind a display name to one operator role and invocation syntax; they do not become separate skills |
| `tools/shipglows_sync_skills.sh` | Unix current-user Claude/Codex skill runtime sync helper | Uses `~/.claude/skills` and Codex `~/.agents/skills` |
| `tools/shipglows_sync_skills.ps1` | Native Windows source-tree skill sync helper | Uses directory junctions and keeps the public installer plugin-first |
| `tools/audit_shipglows_skills.py` | Versioned ShipGlows skill execution-fidelity audit helper used by `900-shipglows-core` and conversation follow-through gates | Keep read-only by default; audit findings classify risk but do not authorize broad edits without scenario-first triage |
| `tools/skill_code_index_lint.py` | Numeric skill-code index validator | Run after changing `skills/references/skill-code-index.md` or the skill set |
| `shipglows_data/workflow/playbooks/spec-driven-workflow.md` | Global workflow doctrine | Sequential shared file |
| `templates/*.md` | Durable artifact templates | Keep linter-compatible |
| `AGENT.md`, `AGENTS.md` | Agent entrypoint and compatibility alias | `AGENT.md` canonical; `AGENTS.md` symlink only |

## Canonical Artifact Taxonomy

ShipGlows-owned artifacts are classified into seven primary types:

- `entrypoint-router`: request intake and safe routing, including `000-shipglows` and similar router surfaces.
- `master-workflow`: lifecycle orchestration and delegation for chantiers.
- `specialist-workflow`: domain execution under a selected master workflow.
- `contract`: authoritative governance or behavioral doctrine that must be consistently reusable.
- `reference`: support documentation, indexes, checklists, or maps that help apply contracts.
- `template`: schema-rich documents used to create durable artifacts with predictable shape.
- `record`: one durable case entry for a specific operation, scope, or decision trace.

### Type-by-Type Boundaries

- `entrypoint-router` resolves user intent and delegates once; it should not own lifecycle proof logic or durable domain policy.
- `master-workflow` owns `100-sg-spec` -> `101-sg-ready` -> `102-sg-start` -> `103-sg-verify` orchestration and must hand execution to specialists rather than execute policy-specific fixes directly.
- `specialist-workflow` executes a bounded set of domain tasks and hands back outcomes; it should not redefine router or master-level ownership.
- `contract` defines what must be true across contexts and is the anchor for reusable standards.
- `reference` supports application of contracts and should avoid introducing new mandatory policy that does not already exist in a contract.
- `template` defines structure and required fields; behavior and policy stay in contracts or SKILL-specific instructions.
- `record` captures facts of one case; method and doctrine must come from contract/reference siblings.

When a file materially performs two serious primary jobs, split or extract before adding further content.

Operator roles and named profiles do not add new primary artifact types:

- operator roles are `contract`
- named profiles are `reference`

## Entrypoints

- `shipglows <instruction>`: recommended non-technical first command; resolves project -> product -> surface -> feature, asks only material questions, then hands the main thread to the selected public métier owner.
- `%Victoire <instruction>`: canonical named-profile activation for the `Victoire` growth-operations profile.
- `%SEO-specialist <instruction>`: canonical named-profile activation for the `SEO Specialist` search-discovery profile.
- `000-shipglows profile=victoire <instruction>`: compatibility form of the same profile activation.
- `000-shipglows profile=seo-specialist <instruction>`: compatibility form of the same profile activation.
- Numeric skill codes: `shipglows 01`, `shipglows 01-001-sg-build`, or equivalent code-first requests resolve through `skills/references/skill-code-index.md` to canonical skill names without renaming runtime skills.
- `700-sg-explore -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end`: normal non-trivial flow.
- `106-sg-fix`: bug-first entrypoint that may route direct or spec-first.
- `305-sg-init`: project bootstrap that reports or creates baseline technical and editorial governance corpus state.
- `300-sg-docs`: documentation generation, governance bootstrap, audit, metadata, and technical-docs mode.
- `300-sg-docs technical`: technical governance bootstrap, code-docs map creation, and audit.
- `300-sg-docs editorial`: editorial governance scaffolding and audit for public-content drift, claim register, page intent, and runtime content schema preservation.
- `shipglows git` -> `sg-engineering github` -> `010-sg-technical`: manual read-only PR/branch/worktree dashboard; `reconcile` proposes exact merge candidates and `clean` applies the shared post-integration lifecycle only after fresh approval.
- `shipglows hygiene` -> `sg-maintenance hygiene` -> `002-sg-maintain`: comprehensive non-mutating audit of the current project across Git residue, dependencies, security, documentation, checks, audits, and quality debt; `hygiene git` specializes to `github clean`, while multi-project scope is rejected.
- `003-sg-bug`: professional bug loop lifecycle executor (`107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship`).
- `002-sg-maintain`: master project maintenance lifecycle for bugs, dependencies, docs, checks, audits, migrations, tasks, security posture, delegated remediation, verification, and ship/deploy routing.
- `108-sg-browser`: generic non-auth browser verification through Playwright MCP for URLs, page-level assertions, screenshots, console summaries, and network summaries.
- `001-sg-build`: user-facing orchestrator that consumes the governance corpus gate before implementation, closure, and ship.
- `004-sg-deploy`: release confidence orchestrator (`105-sg-check -> 005-sg-ship -> 405-sg-prod -> 108-sg-browser/109-sg-auth-debug/107-sg-test -> 103-sg-verify -> 304-sg-changelog`).
- `007-sg-content`: master content lifecycle (`CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> 103-sg-verify -> 005-sg-ship`).
- `skills/references/content-quality-rubric.md`: shared editorial scoring contract used by content owner skills and verification gates.
- `006-sg-design`: master design lifecycle (`design intent -> specialist audit/token/animation/playground route -> spec-first implementation when needed -> checks/browser proof -> 103-sg-verify -> 005-sg-ship`).
- `008-sg-customer`: one customer-experience owner with `audit`, `flow`, `onboarding`, and `recovery` modes (`first-success path -> setup order -> states/recovery -> docs impact -> proof or 001-sg-build`).
- `600-sg-local-cloud-sync`: local-to-cloud data sync contract (`data inventory -> account association -> promotion/hydration -> merge/conflict/tombstones -> sync UX/security -> proof or 001-sg-build`).
- `601-sg-product-entitlements`: product access lifecycle contract (`identity/provider/access separation -> ledger ownership -> backend gates/support -> sync/auth handoff or 001-sg-build`).
- `006-sg-design`: sole public design entrypoint; `system`, `playground`, explicit `audit ui|tokens|components|a11y`, and `animation <audit|design|implement|tune> [scope]` modes load bounded local playbooks. GSAP is optional after project-fit, current-doc, licensing, lifecycle, reduced-motion, and performance checks.
- `900-shipglows-core`: sole internal operator skill for ShipGlows skill execution-fidelity audits, maintenance lifecycle (`build`), conservative refresh (`refresh`), and public-plugin packaging readiness checks. Skill maintenance follows `700-sg-explore when needed -> 100-sg-spec -> SKILL.md -> runtime skill links -> 900-shipglows-core refresh -> budget audit -> 103-sg-verify -> 300-sg-docs/help -> 005-sg-ship`. It is repo-synced, not a public user plugin surface.
- `tools/shipglows_sync_skills.sh --check|--repair`: reusable Unix helper for current-user Claude/Codex skill visibility and install-time selected-user linking.
- `tools/shipglows_sync_skills.ps1 -Mode check|repair`: native Windows developer helper for the same source-tree workflow without symbolic-link privilege requirements.
- `005-sg-ship` and `405-sg-prod`: shipping and deployed verification.
- `skills/references/master-delegation-semantics.md`: shared execution-topology doctrine for master/orchestrator skills.
- `skills/references/master-workflow-lifecycle.md`: shared lifecycle and work item doctrine for master/orchestrator skills.
- `skills/references/reporting-contract.md`: shared final-report modes for concise user reports and explicit detailed agent handoffs.

## Control Flow

Primary router flow:

```text
shipglows <instruction>
  -> repository-backed project -> product -> surface -> feature resolution
  -> one numbered question only when an operator-owned decision is material
  -> direct main-thread handoff to one public métier owner
  -> selected owner orchestrates numeric engines, proof, docs reflection, and closure
```

The selected master then owns its own delegated sequential execution. The router must not run a master skill inside a subagent or reimplement the selected skill's lifecycle gates.

```text
source skill
  -> possible chantier
  -> 100-sg-spec
  -> 101-sg-ready
  -> Governance Corpus Gate
  -> 102-sg-start
  -> optional 102-sg-start local auto-verify when proof is local, tool-backed, non-destructive, and has no external side effect
  -> Documentation Update Plan after code-changing wave
  -> Editorial Update Plan after public-content or claim-impacting wave
  -> 103-sg-verify
  -> Documentation Update Plan during end verification
  -> visible documentation reflection before every closed/complete/resolved/shipped report
  -> Editorial Update Plan during end verification when public content is impacted
  -> 104-sg-end / 005-sg-ship
```

Shared master lifecycle:

```text
intake
  -> work item resolution
  -> readiness gate
  -> model/topology routing
  -> delegated or owner-skill execution
  -> targeted validation and evidence routing
  -> verification
  -> post-verify closure
  -> bounded ship/deploy/release routing
```

`102-sg-start` may record `auto-verify: run` for eligible local proof only. At each declared coherent validated milestone it routes to `005-sg-ship checkpoint` for an exact-scope commit before continuing. Final push still follows `103-sg-verify -> 104-sg-end -> 005-sg-ship`; hosted/browser/manual/production proof stays with its owner.

Model routing is a lifecycle gate, not a promise that the active conversation can switch its own runtime model. Master skills use `skills/704-sg-model/references/model-routing.md` as the detailed source and `skills/references/decision-quality-contract.md` as the quality boundary. Sol covers frontier/high-cost-of-error reasoning, Terra balanced daily work, Luna bounded low-risk/high-volume missions when quality remains equivalent, and the `codex` profile long agentic implementation. Spark is used only when the runtime explicitly exposes it. Delegated missions include model, reasoning, quality-equivalent fallback, availability evidence, and whether the override was actually applied.

Release confidence flow:

```text
004-sg-deploy
  -> scope and risk gate
  -> 105-sg-check
  -> 005-sg-ship
  -> 405-sg-prod
  -> 108-sg-browser / 109-sg-auth-debug / 107-sg-test
  -> 103-sg-verify
  -> 304-sg-changelog when useful
```

Professional bug flow:

```text
003-sg-bug
  -> 107-sg-test for capture or retest
  -> 106-sg-fix for diagnosis and fix attempts
  -> 109-sg-auth-debug / 108-sg-browser when evidence is missing
  -> 103-sg-verify for closure
  -> 005-sg-ship for final bug-risk-aware shipping
```

Project maintenance flow:

```text
002-sg-maintain
  -> maintenance intake and triage
  -> existing chantier/spec gate
  -> 100-sg-spec + 101-sg-ready when non-trivial
  -> delegated sequential maintenance lanes
  -> 003-sg-bug / 010-sg-technical deps|audit|migrate / 300-sg-docs / 105-sg-check / 400-sg-audit / 106-sg-fix / 001-sg-build
  -> Documentation Update Plan and Editorial Update Plan when impacted
  -> 103-sg-verify
  -> 004-sg-deploy or 005-sg-ship
```

Content lifecycle flow:

```text
007-sg-content
  -> CONTENT_MAP and editorial corpus
  -> surface, source, claim, and schema gates
  -> 205-sg-veille / 203-sg-research / 009-sg-marketing market when source or market evidence is missing
  -> 007-sg-content repurpose / 200-sg-redact / 201-sg-enrich
  -> 009-sg-marketing copy|copywriting|gtm / 406-sg-seo
  -> 300-sg-docs for docs or editorial governance updates
  -> npm --prefix site run build and 108-sg-browser when public site proof is needed
  -> 103-sg-verify
  -> 005-sg-ship only when dirty scope is bounded
```

Design/copy Inspiration Gate support flow:

```text
eligible design or copy intent
  -> read private index.yaml only
  -> filter by page/audience/style/section/copy pattern/conversion goal
  -> present at most five reference IDs
  -> operator selection
  -> load selected private bundles only
  -> record selected IDs and summarize transferable/anti-copy patterns
```

The source-derived corpus resolves from `${SHIPGLOWS_INSPIRATION_LIBRARY_DIR:-${SHIPGLOWS_PRIVATE_DIR:-$HOME/.shipglows}/design-inspiration-library}` and stays outside public repositories. The public repo contains only contracts, schemas, tool code, and synthetic fixtures. Competitor, pricing, positioning, differentiation, and market work continues to use `shipglows_data/business/project-competitors-and-inspirations.md`.

`006-sg-design` also owns the direct private-library entrypoint: `library add <url>`, optional known `wayback <archive-url>`, `library approve <id>`, `library list`, and `library status`. Add creates a `candidate`; approval requires curation/anti-copy review and atomically updates the record plus `index.yaml`; Wayback remains metadata only and never triggers or blocks an archive request.

## Invariants

- Lifecycle skills trace into exactly one chantier spec when one is identified.
- `000-shipglows <instruction>` is a router, not a hidden master runner: it answers pure conversation directly, asks one numbered question when ambiguous, and otherwise hands the main thread to the selected skill. Its global `auto` mode hands off to `708-sg-auto`; registered execution posture tags are applied after owner/mode resolution.
- `#local`, `#nolocal`, and `#ci` are transversal execution posture tags, not métier modes or authority grants. `#ci` implies `#nolocal`; `#local` conflicts with both; ordinary focus tags remain routing cues.
- `708-sg-auto` is the internal owner for public `shipglows auto`. It selects several evidence-backed candidates when useful, ranks durable value per wall-clock minute after safety, authority, readiness, claim, and dirty-ownership gates, and always applies `no-local-execution-policy.md` implicitly.
- Auto freezes the launch Git/managed root for the parent and every subagent. Concurrent conversations use ignored root-local claims to avoid duplicate candidates and overlapping paths. Subagents are authorized and recommended only when independent useful missions improve time, isolation, or coverage.
- Auto never raises reasoning effort, creates agents, or generates output merely to consume credits. Fast is used only when the runtime proves it already active; the agent never self-activates it or edits user-level configuration.
- `shipglows nolocal <objective>` is a legacy compatibility alias normalized to `shipglows <objective> #nolocal`; it is not an autonomous selector or approval bypass.
- Auto-session authority covers only safe reversible current-project local edits. It forbids builds, tests, lint, typechecks, installation, servers, browser/device work, containers, migrations, commits, pushes, deployments, destructive/privileged effects, secrets, permission/auth/billing/production changes, and self-expansion of its own guardrails.
- Work produced under `auto`, `#nolocal`, or `#ci` remains `implemented — unverified` when its executable proof is deferred; commands or CI targets are reported but not executed, and lifecycle closure stays open.
- `102-sg-start` implements from the ready contract; it should not rediscover product intent while coding.
- Spec-first is the outer lifecycle contract; proof-first is the implementation discipline. Execution and verification skills choose a proof path (`test-first`, `regression-first`, `scenario-first`, `evidence-first`, or `exception-with-proof`) before claiming completion.
- The Reader diagnoses docs impact; the executor or integrator applies docs updates.
- The Technical Reader diagnoses code-docs impact; the Editorial Reader diagnoses public-content and claim impact.
- Shared files are sequential by default.
- Master/orchestrator skills load `skills/references/master-delegation-semantics.md` before choosing execution topology. Two or more independent read-only scopes fan out in parallel by default; mutations use delegated sequential execution; parallel writes require ready non-overlapping `Execution Batches` with one integration owner.
- Master/orchestrator skills load `skills/references/master-workflow-lifecycle.md` before resolving lifecycle flow. The shared skeleton is intake, work item resolution, readiness, model/topology routing, owner-skill execution, validation/evidence, verification, post-verify closure, and bounded ship/deploy/release routing.
- Skills load `skills/references/decision-quality-contract.md` before quality-sensitive routing, model/fallback choice, implementation, fix, verification, or recommendations. Completion requires industrial-grade quality proportional to consequence; merely functional, unintentionally generic for the accepted product, fragile, cluttered, or unresolved provisional work presented as final remains partial. Brand surfaces use award-caliber craft as a benchmark, while operational interfaces stay clarity-first. Institutional claims require a framework-specific scoped audit against named requirements and direct evidence.
- Skills should load `skills/references/question-contract.md` before user-facing questions. They ask only when the answer changes route, scope, risk, validation, closure, ship posture, public claims, or technical/product/editorial direction; otherwise they proceed by the best-practice default only when it is clear, low-risk, reversible, context-compatible, and verifiable.
- Skills should not use the operator as a substitute for local technical inspection. They should, however, ask precise numbered business/product/audience/framing questions when those facts are operator-owned and materially improve the work.
- When skill bodies are edited or compacted, treat top-level `SKILL.md` as the activation contract. Keep required section labels (`Canonical Paths`, `Trace category`, `Process role`, `Report Modes`) and local non-negotiables there; move only supporting detail to references.
- Bug work uses one Markdown bug file under `shipglows_data/workflow/bugs/*.md` as the durable source of truth. `shipglows_data/workflow/BUGS.md`, when present, is an optional compact/generated/triage view and must not override the bug file.
- Short natural-language confirmations after diagnosis or proposal continue the current chantier in delegated sequential mode by intent rather than exact keyword, not parallel fan-out.
- Fresh context is preferred for non-trivial spec-first execution when available.
- ShipGlows-owned references resolve from `$SHIPGLOWS_ROOT`, not the project repo.
- A newly created or renamed ShipGlows skill is not globally runtime-visible until current-user `~/.claude/skills/<name>` and Codex `~/.agents/skills/<name>` link to `$SHIPGLOWS_ROOT/skills/<name>` and expose `SKILL.md`.
- `tools/shipglows_sync_skills.sh --check` is read-only and reports missing, stale, broken, and non-symlink runtime entries.
- `tools/shipglows_sync_skills.sh --repair` creates missing links and replaces stale symlinks; it must not overwrite non-symlink entries unless an install-time caller explicitly passes `--backup-existing`.
- Native Windows developers use `tools/shipglows_sync_skills.ps1`; it creates directory junctions and preserves non-link collisions unless `-BackupExisting` is explicit. Public Codex users install the plugin instead of this corpus.
- `305-sg-init` bootstraps minimal governance corpus state; `300-sg-docs` owns corpus creation, update, and audit; `001-sg-build` consumes the corpus through gates.
- Technical governance applies to code projects by default. Editorial governance applies when public pages, README promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content surfaces exist.
- Skills that use Playwright MCP for browser evidence must load
  `skills/references/playwright-mcp-runtime.md` first and refuse stale Linux
  ARM64 Chrome-stable fallback evidence. Playwright MCP is the default web-QA
  lane. They inspect direct and host-provided deferred/searchable tool catalogs,
  then use a safe read-only probe before reporting `callable` or `not exposed`.
  The optional upstream `playwright-interactive` skill is reserved for Electron
  or complex persistent programs and cannot shadow or block a working MCP lane.
- Skills that use runtime failure evidence, deploy confidence, bug evidence, auth/payment/data failure diagnosis, jobs, webhooks, verification, or performance telemetry must load `skills/references/sentry-observability.md` when Sentry is configured, visible, or materially relevant. Skills never have direct Sentry dashboard access; Sentry evidence means a redacted issue/event pointer supplied by the operator, visible in the app, visible in logs, or already present in context. When no Sentry pointer is available, bounded PM2 logs and Doppler key presence/scope checks may be used as supporting evidence without printing secrets.
- `108-sg-browser` owns generic non-auth browser proof. `109-sg-auth-debug` owns auth, session, callback, provider, tenant, and protected-route browser proof.
- `004-sg-deploy` owns release orchestration only; `005-sg-ship` owns checkpoint commits and final commit/push, `405-sg-prod` owns deployed truth, and proof skills own observed behavior.
- `003-sg-bug` owns bug lifecycle execution through owner skills and bounded subagents; phase skills still own bug record mutation, diagnosis, retest evidence, verification, and shipping internals.
- `002-sg-maintain` owns the maintenance lifecycle; bugs, dependencies, docs, checks, audits, migrations, tasks, security review, repair, verification, and ship still run through their specialist owner skills and gates.
- `010-sg-technical github` owns focused Git/GitHub hygiene as one `worktree -> branch -> pull request` graph. Its public `shipglows git` route defaults to read-only audit; `reconcile` and `clean` retain fresh approval gates. Commit/push stays with `005-sg-ship`, dependency risk with `010-sg-technical deps`, major upgrades with `010-sg-technical migrate`, and CI diagnosis with `github:gh-fix-ci`.
- `007-sg-content` owns content-management orchestration; repurposing, drafting, enrichment, marketing modes, SEO audit, docs, veille, browser proof, verification, and ship still run through their specialist owner skills and gates.
- Design and content skills use the shared Inspiration Gate only for eligible creative direction; they shortlist from `index.yaml`, require operator selection, record selected reference IDs, and never treat discovery as approval to imitate.
- Content owner skills (`007-sg-content` including `repurpose`, `200-sg-redact`, `201-sg-enrich`, `009-sg-marketing copy|copywriting|gtm`, `406-sg-seo`) and `103-sg-verify` must use one shared rubric contract from `skills/references/content-quality-rubric.md`; recoverable score states (`needs retry`, `duplicate_in_progress`, `conflicting_score_state`, `stale_or_mismatched_score`) are never valid verification proof.
- `006-sg-design` owns the public design lifecycle; its system, playground, audit, and `animation <audit|design|implement|tune> [scope]` modes load bounded playbooks, while implementation, browser proof, verification, and shipping remain lifecycle gates. GSAP is optional rather than a public mode or implicit dependency.
- `008-sg-customer` owns customer contracts through four exact modes: `audit`, `flow`, `onboarding`, and `recovery`; implementation, visual design, docs/content, browser proof, manual QA, and auth diagnosis still run through `001-sg-build`, `006-sg-design`, `300-sg-docs`/`007-sg-content`, `108-sg-browser`, `107-sg-test`, and `109-sg-auth-debug` when needed.
- `900-shipglows-core build` owns internal skill-maintenance orchestration and must route to `700-sg-explore` before `100-sg-spec` when skill intent, placement, public promise, or governance policy is too fuzzy for one targeted question to settle.
- A release is not considered verified from push success, provider success, or a bare `200 OK` alone.
- User-facing reports default to `report=user`: concise, outcome-first, matched to the user's active language, without file paths, file names, or technical file links unless the operator must act on the exact artifact. After approval, substantive chantiers open once with `✨ OBJECTIF`, `📐 PÉRIMÈTRE`, `🧪 PREUVES ATTENDUES`, `📖 DOCUMENTATION PRÉVUE`. Successful closure reports use `✨ RÉSULTAT`, `🧪 PREUVES`, `📖 DOCUMENTATION`, `📦 LIVRAISON`; compact evidence stays on one line separated by ` · `. Cards reuse already-required work: one meaningful proof may suffice, prose stays to one sentence per block, and no extra check, research, documentation, or content is created solely for reporting. Detailed `report=agent` handoff must be explicit.
- `001-sg-build` planning questions are business decision briefs, not bare technical prompts: they name the problem root, business stakes, practical options, and recommended best-practice answer before asking for a decision.
- Audit skills still report findings first, but default user reports should summarize top findings, proof gaps, chantier potential, and next action; full matrices and domain checklists belong in `report=agent`.

## Failure Modes

- A weak spec that lacks success/error behavior or explicit constraints must route back to readiness instead of being silently repaired during coding.
- If mapped docs are missing from a `Documentation Update Plan`, the docs gate fails. If a closure report omits its visible `updated`, `not impacted — <concrete reason>`, or `needs review — <surface>` classification, closure fails.
- If public content, README, FAQ, pricing, public docs, skill pages, or claims are affected but missing from an `Editorial Update Plan`, the editorial gate fails.
- If `001-sg-build` prepares implementation with missing or stale `docs/technical/code-docs-map.md`, applicable `docs/editorial/`, or `CONTENT_MAP.md`, it must route to `300-sg-docs` or record explicit no-impact/no-surface status before proceeding.
- If a master skill patches in the master conversation merely because a file change is small while subagents are available, treat that as workflow drift. Small scope may use a mini-contract, but the execution mode remains delegated sequential for file work.
- If `001-sg-build agents` touches files, runs validation, prepares closure, or prepares ship without launching a bounded subagent and without explicitly reporting degraded execution, treat that as workflow drift.
- If the `000-shipglows <instruction>` router nests `001-sg-build`, `002-sg-maintain`, `003-sg-bug`, `004-sg-deploy`, `007-sg-content`, or `900-shipglows-core build` inside a subagent instead of handing off the main thread, treat that as workflow drift.
- If `shipglows auto` runs a workload/external effect, leaves its frozen root, duplicates a fresh claimed scope, invents work or reasoning to consume credits, self-activates Fast, claims verification/compliance/closure, or modifies its own authority guardrails, treat that as workflow drift. If `#nolocal` bypasses ordinary mutation approval or selects a portfolio autonomously, if `#ci` triggers remote work, or if conflicting posture tags are resolved by argument order, treat the execution-posture boundary as failed.
- If a short natural-language confirmation is treated as consent for parallel writes without ready non-overlapping `Execution Batches`, treat that as workflow drift. Independent read-only parallel fan-out remains the default.
- If future projects are told to rerun ShipGlows's shipped governance specs instead of using `305-sg-init` and `300-sg-docs`, treat that as workflow drift.
- If a new skill exists under `skills/<name>/SKILL.md` but is missing from current-user Claude or Codex skill directories, treat the skill lifecycle as incomplete until the runtime symlinks are repaired.
- If filesystem runtime links are correct but the current agent still does not list a skill, treat it as a process reload/session-cache issue before changing source contracts.
- If the Reader edits docs directly outside assignment, treat it as role misuse.
- If `AGENTS.md` diverges from `AGENT.md`, verification fails.
- If Playwright MCP reports `/opt/google/chrome/chrome` on Linux ARM64 after
  BUG-2026-05-02-001, treat the current MCP process as stale or misconfigured;
  do not diagnose the app until the runtime preflight passes.

## Security Notes

- Skill instructions must not contradict higher-priority system, developer, or active spec instructions.
- Do not expose secrets, private logs, or credentials in generated reports.
- Any task that affects auth, permissions, tenant boundaries, destructive behavior, or external side effects must use spec-first when ambiguity remains.

## Validation

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
bash -n tools/shipglows_sync_skills.sh tests/skills/runtime-sync.sh
bash tests/skills/runtime-sync.sh
tools/shipglows_sync_skills.sh --check --all
python3 tools/shipglows_metadata_lint.py skills/references/master-delegation-semantics.md skills/references/master-workflow-lifecycle.md skills/references/spec-driven-development-discipline.md skills/references/technical-docs-corpus.md skills/references/editorial-content-corpus.md skills/references/subagent-roles/editorial-reader.md skills/references/skill-instruction-layering.md skills/references/skill-context-budget.md shipglows_data/workflow/playbooks/spec-driven-workflow.md AGENT.md
rg -n "Governance Corpus Gate|305-sg-init.*bootstrap|300-sg-docs.*maintain|001-sg-build.*consume|004-sg-deploy|002-sg-maintain|007-sg-content|master-delegation-semantics|master-workflow-lifecycle|bug file|delegated sequential|subagent|parallelism|short natural-language|Execution Batches|reporting-contract|report=user|docs/technical|docs/editorial" skills/305-sg-init/SKILL.md skills/300-sg-docs/SKILL.md skills/004-sg-deploy/SKILL.md skills/002-sg-maintain/SKILL.md skills/007-sg-content/SKILL.md specs/001-sg-build-autonomous-master-skill.md shipglows_data/workflow/playbooks/spec-driven-workflow.md README.md skills/references/reporting-contract.md skills/references/master-delegation-semantics.md skills/references/master-workflow-lifecycle.md
```

Run focused `rg` checks for the affected skill contract and linked references.

## Reader Checklist

- `skills/*/SKILL.md` changed -> check this doc, `technical-docs-corpus.md`, and workflow docs.
- New/renamed skill or visibility drift -> run `tools/shipglows_sync_skills.sh --check --skill <name>` or `--check --all`.
- Resource/playbook discovery changed -> run `python3 -m unittest tools.test_resource_resolver`, a bounded live resolver example, metadata lint on the shared reference/spec, and `git diff --check`; do not treat resolver ranking as a replacement for required loaders or owner routing.
- Playwright MCP usage changed -> check `skills/references/playwright-mcp-runtime.md`
  and `skills/109-sg-auth-debug/references/playwright-auth.md`.
- Public-content skill changed -> check `editorial-content-corpus.md`, `docs/editorial/`, and workflow docs.
- Governance corpus bootstrap or adoption changed -> check `skills/305-sg-init/SKILL.md`, `skills/300-sg-docs/SKILL.md`, `technical-docs-corpus.md`, `editorial-content-corpus.md`, `README.md`, and workflow docs.
- Content lifecycle changed -> check `CONTENT_MAP.md`, `docs/editorial/`, public skill content, `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, and workflow docs.
- A lifecycle rule changed -> update `shipglows_data/workflow/playbooks/spec-driven-workflow.md`.
- Report mode or final-report doctrine changed -> update `skills/references/reporting-contract.md`, `skills/references/chantier-tracking.md`, and affected master/audit skills.
- A docs gate changed -> update `skills/300-sg-docs/SKILL.md`, `technical-docs-corpus.md`, and `code-docs-map.md`.
- An editorial gate changed -> update `skills/300-sg-docs/SKILL.md`, `editorial-content-corpus.md`, `docs/editorial/`, and workflow docs.

## Maintenance Rule

Update this doc when skill roles, lifecycle flow, chantier tracing, technical-docs gates, editorial gates, model/topology rules, or shared reference resolution changes.
