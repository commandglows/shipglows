---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-05-17"
updated: "2026-05-17"
status: reviewed
source_skill: sg-start
scope: "skill-taxonomy-and-discovery-descriptions"
owner: "Diane"
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
domains: ["skills", "workflow", "documentation-governance"]
issue_counts: {"hard_blockers": 0, "future_specs": 3, "low_risk_description_edits": 56}
evidence:
  - "Generated inventory from skills/*/SKILL.md on 2026-05-17."
  - "Baseline skill budget audit: 61 skills, 0 hard violations, 0 warnings, 0 body-size risks, absolute estimate 7988/8000, repo-relative estimate 6646/8000, average description length 70.7."
  - "Local transcript /home/claude/docs_update_skill_bug.md showed sg-docs update-mode work missed a governance-layout migration gate."
  - "Local transcript /home/claude/sg-build-subagents-ex.md was inspected and contained no actionable routing signal."
  - "sg-verify 2026-05-17 checked skill budget, runtime sync, metadata, role labels, and description uniqueness."
depends_on:
  - artifact: "shipglows_data/workflow/specs/audit-and-compact-skill-taxonomy-descriptions.md"
    artifact_version: "1.0.3"
    required_status: "ready"
supersedes: []
next_step: "None"
---

# Skill Taxonomy Description Audit

## Scope Understood

This audit covers the discovery descriptions and declared chantier roles for all 61 `skills/*/SKILL.md` files. It does not delete, rename, merge, or change invocation keys.

Success means the descriptions become clearer routing triggers, not only shorter strings. High-risk consolidation remains a recommendation for separate specs.

## Baseline

- Skills: 61
- Hard violations: 0
- Warnings: 0
- Body-size risks: 0
- Description characters: 4310
- Average description length: 70.7
- Absolute discovery estimate: 7988 / 8000
- Repo-relative discovery estimate: 6646 / 8000
- Longest descriptions: 80-96 characters, already under hard limits but too close to the fallback absolute budget.

## Applied Result

- Edited descriptions: 56
- Skills kept unchanged: 5
- Description characters: 3127
- Average description length: 51.3
- Absolute discovery estimate: 6805 / 8000
- Repo-relative discovery estimate: 5463 / 8000
- Validation status at edit time: 0 hard violations, 0 warnings, 0 body-size risks.

## Family Map

- Lifecycle/master: `sg-spec`, `sg-ready`, `sg-start`, `sg-verify`, `sg-end`, `sg-ship`, `sg-build`, `sg-deploy`, `sg-maintain`, `sg-design`, `sg-content`, `sg-skill-build`.
- Audit/source: `sg-audit*`, `sg-deps`, `sg-perf`.
- Bug/proof/source: `sg-bug`, `sg-fix`, `sg-test`, `sg-browser`, `sg-auth-debug`, `sg-prod`, `sg-check`, `sg-migrate`.
- Content/docs/support: `sg-docs`, `sg-redact`, `sg-enrich`, `sg-repurpose`, `sg-changelog`, `sg-scaffold`, `sg-skills-refresh`, `sg-init`.
- Research/strategy/source: `sg-research`, `sg-market-study`, `sg-veille`.
- Pilotage: `sg-backlog`, `sg-priorities`, `sg-review`, `sg-tasks`, `continue`.
- Helper/session/router: `shipglows`, `sg-context`, `sg-model`, `sg-help`, `sg-status`, `sg-resume`, `sg-explore`, `name`, `tmux-capture-conversation`, `clean-conversation-transcript`.

## Overlap Findings

- `sg-build` vs `sg-start`: keep both. `sg-build` owns story-to-ship orchestration; `sg-start` executes a ready spec or clear local task.
- `sg-deploy` vs `sg-ship` vs `sg-prod`: keep all. `sg-deploy` orchestrates release confidence; `sg-ship` commits/pushes; `sg-prod` verifies deployed truth.
- `sg-maintain` vs `sg-bug` vs `sg-fix`: keep all. `sg-maintain` owns project maintenance; `sg-bug` owns the bug lifecycle; `sg-fix` triages and repairs failing behavior.
- `sg-test` vs `sg-browser` vs `sg-auth-debug`: keep all. `sg-test` owns manual QA and bug capture; `sg-browser` owns non-auth browser evidence; `sg-auth-debug` owns auth/session/provider proof.
- `sg-docs` vs content skills: keep all. `sg-docs` owns documentation and governance layout; `sg-redact`, `sg-enrich`, and `sg-repurpose` own content production and transformation.
- `sg-audit-copy` vs `sg-audit-copywriting`: keep both for now. `sg-audit-copy` evaluates product/interface copy; `sg-audit-copywriting` evaluates offer and persuasion.
- `sg-design`, `sg-audit-design`, `sg-design-from-scratch`, `sg-design-playground`, `sg-audit-design-tokens`, `sg-audit-components`, `sg-audit-a11y`: keep all. The descriptions must distinguish orchestration, audits, creation, and tooling.
- `sg-research`, `sg-market-study`, `sg-veille`: keep all. `sg-research` produces cited reports; `sg-market-study` answers demand/competition/monetization; `sg-veille` triages sources into actions.

## Transcript Failure Modes

- `sg-docs` failure: `/home/claude/docs_update_skill_bug.md` shows a docs update concluded after README/docs refresh while missing root legacy artifacts and mixed docs layout. Root cause: the discovery description only advertised README/API/component/metadata drift, while the actual role includes governance-layout compliance and `migrate-layout`. Decision: clarify `sg-docs` description to mention governance-layout compliance. Future hardening may need a separate spec if update-mode gate wording still allows local-only success.
- `sg-build` transcript: `/home/claude/sg-build-subagents-ex.md` contains only capture metadata and no actionable routing failure. Decision: no change.

## Decision Matrix

| Skill | Family | Trace / role | Lines / tokens | Chars | Decision | Target description |
| --- | --- | --- | ---: | ---: | --- | --- |
| `clean-conversation-transcript` | helper/session | non-applicable / helper | 143 / 1423 | 77 -> 52 | shorten | Clean tmux/Codex transcripts into readable Markdown. |
| `continue` | pilotage | conditionnel / pilotage | 194 / 2219 | 51 -> 44 | shorten | Resume paused work and report the next step. |
| `name` | helper/session | non-applicable / helper | 47 / 467 | 67 -> 35 | shorten | Name or rename the current session. |
| `sg-audit` | audit | conditionnel / source-de-chantier | 67 / 876 | 69 -> 55 | shorten | Audit product, code, design, SEO, GTM, and performance. |
| `sg-audit-a11y` | audit | conditionnel / source-de-chantier | 67 / 869 | 20 -> 20 | keep | Accessibility audit. |
| `sg-audit-code` | audit | conditionnel / source-de-chantier | 67 / 845 | 89 -> 58 | shorten | Audit code correctness, security, architecture, and tests. |
| `sg-audit-components` | audit | conditionnel / source-de-chantier | 342 / 4963 | 23 -> 23 | keep | Component system audit. |
| `sg-audit-copy` | audit | conditionnel / source-de-chantier | 67 / 870 | 68 -> 51 | shorten | Audit copy clarity, tone, conversion, and friction. |
| `sg-audit-copywriting` | audit | conditionnel / source-de-chantier | 67 / 845 | 68 -> 53 | shorten | Audit marketing copy, offer, persona, and persuasion. |
| `sg-audit-design` | audit | conditionnel / source-de-chantier | 87 / 1086 | 19 -> 19 | keep | UI/UX design audit. |
| `sg-audit-design-tokens` | audit | conditionnel / source-de-chantier | 323 / 4483 | 31 -> 26 | shorten | Design-token system audit. |
| `sg-audit-gtm` | audit | conditionnel / source-de-chantier | 67 / 877 | 90 -> 55 | shorten | Audit positioning, funnel, offer, and growth readiness. |
| `sg-audit-seo` | audit | conditionnel / source-de-chantier | 69 / 971 | 67 -> 53 | shorten | Audit SEO health, metadata, indexing, and intent fit. |
| `sg-audit-translate` | audit | conditionnel / source-de-chantier | 429 / 4790 | 85 -> 58 | shorten | Audit translation quality, i18n sync, and missing strings. |
| `sg-auth-debug` | bug/proof | conditionnel / source-de-chantier | 67 / 892 | 87 -> 52 | shorten | Debug auth, OAuth, cookies, callbacks, and sessions. |
| `sg-backlog` | pilotage | conditionnel / pilotage | 140 / 1595 | 76 -> 49 | shorten | Triage backlog ideas, deferred work, and cleanup. |
| `sg-browser` | bug/proof | conditionnel / source-de-chantier | 216 / 2480 | 74 -> 62 | shorten | Check non-auth pages with browser, console, and network proof. |
| `sg-bug` | bug/proof | conditionnel / source-de-chantier | 264 / 3721 | 89 -> 66 | shorten | Bug lifecycle for intake, dossiers, fixes, retests, and ship risk. |
| `sg-build` | lifecycle/master | obligatoire / lifecycle | 358 / 4442 | 77 -> 49 | shorten | Orchestrate story-to-ship product implementation. |
| `sg-changelog` | docs/support | conditionnel / support-de-chantier | 137 / 1436 | 73 -> 57 | shorten | Generate grouped Keep a Changelog notes from git history. |
| `sg-check` | bug/proof | conditionnel / source-de-chantier | 168 / 2675 | 73 -> 56 | shorten | Technical checks for typecheck, lint, build, and repair. |
| `sg-content` | content/docs | obligatoire / lifecycle | 271 / 3813 | 18 -> 18 | keep | Content lifecycle. |
| `sg-context` | helper/session | non-applicable / helper | 83 / 739 | 89 -> 56 | shorten | Prime task context with cached memory and focused files. |
| `sg-deploy` | lifecycle/master | obligatoire / lifecycle | 288 / 3232 | 76 -> 60 | shorten | Orchestrate release checks, ship, deploy, proof, and verify. |
| `sg-deps` | audit | conditionnel / source-de-chantier | 317 / 4106 | 66 -> 55 | shorten | Audit dependency security, drift, licenses, and config. |
| `sg-design` | lifecycle/master | obligatoire / lifecycle | 269 / 3091 | 24 -> 23 | shorten | UI/UX design lifecycle. |
| `sg-design-from-scratch` | design/support | conditionnel / source-de-chantier | 297 / 3427 | 40 -> 40 | keep | Design-system creation from existing UI. |
| `sg-design-playground` | design/support | conditionnel / support-de-chantier | 307 / 3843 | 41 -> 40 | shorten | Scaffold a live design-token playground. |
| `sg-docs` | content/docs | conditionnel / support-de-chantier | 97 / 1208 | 93 -> 58 | clarify description | Maintain docs, metadata, and governance-layout compliance. |
| `sg-end` | lifecycle/master | obligatoire / lifecycle | 181 / 2320 | 79 -> 57 | shorten | Close tasks with summaries, trackers, and changelog prep. |
| `sg-enrich` | content/docs | conditionnel / support-de-chantier | 63 / 835 | 71 -> 61 | shorten | Enrich content with research, user focus, and conversion fit. |
| `sg-explore` | helper/session | non-applicable / helper | 260 / 2554 | 80 -> 56 | shorten | Explore ideas, problems, and requirements before coding. |
| `sg-fix` | bug/proof | conditionnel / source-de-chantier | 293 / 4618 | 82 -> 58 | shorten | Triage and repair bugs, regressions, and failing behavior. |
| `sg-help` | helper/session | non-applicable / helper | 66 / 822 | 88 -> 63 | shorten | Answer ShipGlows skills, workflows, modes, and prompt questions. |
| `sg-init` | docs/support | conditionnel / support-de-chantier | 62 / 762 | 89 -> 61 | shorten | Bootstrap ShipGlows tracking, stack detection, and registries. |
| `sg-maintain` | lifecycle/master | obligatoire / lifecycle | 291 / 4216 | 89 -> 52 | shorten | Orchestrate project maintenance from triage to ship. |
| `sg-market-study` | research/strategy | conditionnel / source-de-chantier | 67 / 893 | 84 -> 57 | shorten | Research demand, competitors, keywords, and monetization. |
| `sg-migrate` | bug/proof | conditionnel / source-de-chantier | 198 / 1895 | 64 -> 55 | shorten | Plan framework upgrades and breaking-change migrations. |
| `sg-model` | helper/session | non-applicable / helper | 187 / 2236 | 66 -> 53 | shorten | Route models for ShipGlows tasks and reasoning levels. |
| `sg-perf` | audit | conditionnel / source-de-chantier | 404 / 4601 | 88 -> 63 | shorten | Audit bundles, rendering, Core Web Vitals, data, and databases. |
| `sg-priorities` | pilotage | conditionnel / pilotage | 128 / 1535 | 96 -> 53 | shorten | Prioritize work by impact, effort, blockers, and ROI. |
| `sg-prod` | bug/proof | conditionnel / source-de-chantier | 67 / 907 | 87 -> 59 | shorten | Verify production deploys, logs, health, and live behavior. |
| `sg-ready` | lifecycle/master | obligatoire / lifecycle | 319 / 4423 | 83 -> 58 | shorten | Validate spec readiness, user-story fit, and secure scope. |
| `sg-redact` | content/docs | conditionnel / support-de-chantier | 63 / 847 | 69 -> 62 | shorten | Draft long-form articles, guides, editorials, and brand voice. |
| `sg-repurpose` | content/docs | conditionnel / support-de-chantier | 67 / 918 | 91 -> 62 | shorten | Repurpose sources into docs, marketing, FAQs, or site updates. |
| `sg-research` | research/strategy | conditionnel / source-de-chantier | 157 / 1397 | 83 -> 59 | shorten | Research web and local sources into cited Markdown reports. |
| `sg-resume` | helper/session | non-applicable / helper | 146 / 1351 | 84 -> 55 | shorten | Summarize session state, task status, and next actions. |
| `sg-review` | pilotage | conditionnel / pilotage | 199 / 2516 | 60 -> 56 | shorten | Review session changes, docs, summaries, and next steps. |
| `sg-scaffold` | docs/support | conditionnel / support-de-chantier | 205 / 2910 | 85 -> 57 | shorten | Scaffold pages, components, routes, hooks, and utilities. |
| `sg-ship` | lifecycle/master | obligatoire / lifecycle | 304 / 4066 | 75 -> 59 | shorten | Ship with checks, commits, pushes, and closure when needed. |
| `sg-skill-build` | lifecycle/master | obligatoire / lifecycle | 320 / 3766 | 61 -> 58 | shorten | Maintain ShipGlows skills from spec to validation and ship. |
| `sg-skills-refresh` | docs/support | conditionnel / support-de-chantier | 164 / 2514 | 82 -> 65 | shorten | Refresh skills against current practice and conservative updates. |
| `sg-spec` | lifecycle/master | obligatoire / lifecycle | 68 / 1152 | 81 -> 59 | shorten | Write specs with user stories, contracts, risks, and plans. |
| `sg-start` | lifecycle/master | obligatoire / lifecycle | 76 / 1357 | 78 -> 57 | shorten | Execute ready specs or clear local tasks with guardrails. |
| `sg-status` | helper/session | non-applicable / helper | 122 / 1289 | 78 -> 56 | shorten | Report cross-project git status, sync state, and issues. |
| `sg-tasks` | pilotage | conditionnel / pilotage | 201 / 2705 | 82 -> 44 | shorten | Update task trackers and suggest next steps. |
| `sg-test` | bug/proof | conditionnel / source-de-chantier | 447 / 4768 | 74 -> 42 | shorten | Manual QA, retests, logs, and bug capture. |
| `sg-veille` | research/strategy | conditionnel / source-de-chantier | 274 / 3291 | 65 -> 44 | shorten | Triage business veille sources into actions. |
| `sg-verify` | lifecycle/master | obligatoire / lifecycle | 111 / 1197 | 72 -> 56 | shorten | Verify ship readiness, correctness, coherence, and risk. |
| `shipglows` | helper/router | non-applicable / helper | 171 / 2096 | 43 -> 36 | shorten | Route requests to skills or answers. |
| `tmux-capture-conversation` | helper/session | non-applicable / helper | 96 / 1295 | 81 -> 51 | shorten | Capture tmux panes to cleaned Markdown transcripts. |

## High-Risk Decisions Requiring Separate Specs

- Possible consolidation of copy audit roles (`sg-audit-copy` and `sg-audit-copywriting`) should stay out of this chantier because public promises and routing behavior would change.
- Possible consolidation inside the design family should stay out of this chantier because the current split separates orchestration, audit, token tooling, component audit, accessibility, and design-system creation.
- `sg-docs update` gate hardening may deserve a separate spec if future runs still complete local docs refreshes without escalating governance-layout migration.

## Risky Assumptions / Proof Gaps

- The inventory uses local `skills/*/SKILL.md` only; runtime usage frequency is not measured.
- The proposed descriptions intentionally keep a few longer strings where shorter wording would blur family boundaries.
- No direct Claude/Codex picker retest is possible inside this static pass; validation relies on budget audit, runtime symlink check, role-label grep, and family review.

## Recommended Next Step

Apply only the listed description edits, update internal lifecycle docs and changelog for the taxonomy/description pass, then run the budget audit, runtime sync check, metadata lint on changed artifacts, and focused role-label checks.
