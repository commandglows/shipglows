---
artifact: workflow_review
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-06-26"
updated: "2026-06-27"
status: draft
source_skill: 900-shipglows-core
scope: "skill-system-hardening-register"
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/
  - tools/audit_shipglows_skills.py
  - tools/skill_budget_audit.py
  - skills/references/canonical-paths.md
  - skills/references/skill-execution-fidelity.md
  - shipglows_data/workflow/TASKS.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "skills/references/skill-execution-fidelity.md"
    artifact_version: "1.2.0"
    required_status: "active"
evidence:
  - "User decision 2026-06-26: generalize preflight and system-improvement hardening across ShipGlows skills instead of treating misses as isolated incidents."
  - "2026-06-26 audit_shipglows_skills.py result: 0 hard, 1 review, 0 style; only 101-sg-ready shows body-size risk."
  - "2026-06-26 skill_budget_audit.py result: 68 skills, 1 separate risk, absolute estimate 8461/8500."
  - "2026-06-27 transverse sweep: shared references extracted for ShipGlows-owned preflight, operator-last-resort evidence, preview-proof routing, and chantier-potential intake; remaining corpus rechecked skill-by-skill for first-screen contract gaps."
  - "2026-06-27 audit_shipglows_skills.py result: 0 hard, 1 review, 0 style; the only remaining review signal was `skills/emailing/SKILL.md` missing a visible report-contract signal, fixed in this sweep."
  - "2026-06-27 skill_budget_audit.py result: 69 skills, 0 separate risks, absolute estimate 8581/8500; local skill contracts are now within per-skill budget but the corpus still needs a future aggregate compaction pass."
supersedes: []
next_review: "2026-07-03"
next_step: "/009-sg-skill-build plan aggregate corpus compaction after the execution-fidelity hardening sweep"
---

# Skill System Hardening Register

## Purpose

This register tracks the cross-skill hardening sweep requested on 2026-06-26.
The goal is not broad rewrite churn. The goal is to review every ShipGlows skill
against the same execution-fidelity pressure points and only open edits where
the risk is concrete.

## Review Contract

Audit each skill against these five checks:

1. `preflight`: does the skill force a mechanical preflight before fragile
   validation or external tooling?
2. `canonical_paths`: does it resolve ShipGlows-owned tools and references from
   `${SHIPGLOWS_ROOT:-$HOME/shipglows}` rather than the project cwd?
3. `system_loop`: does the skill help convert a miss into `problem -> cause ->
   prevention -> contract improvement`, instead of only reporting the symptom?
4. `operator_last_resort`: does the skill avoid pushing proof back to the
   operator when the agent can run it safely?
5. `body_size`: is the activation body compact enough that critical gates stay
   visible under pressure?

## Status Legend

- `todo`: not yet reviewed against this register
- `verify`: a likely good pattern exists and needs a focused mechanical check
- `priority`: known risk already observed or flagged by audit
- `done`: reviewed against this register and no immediate hardening needed

## Sweep Outcome

| Area | Outcome |
| --- | --- |
| Shared doctrine | Repetition was reduced by extracting `shipglows-owned-preflight.md`, `operator-last-resort-evidence.md`, `preview-proof-routing.md`, and reusing `chantier-tracking.md` for chantier-potential thresholds. |
| High-risk execution skills | `101`-`109`, `003`, and `405` now expose first-screen guardrails more reliably with local anchors to shared doctrine. |
| Remaining corpus | Mechanical and targeted review found no additional immediate contract hole beyond `emailing`, which now exposes the reporting contract explicitly. |
| Residual system risk | The main remaining issue is corpus-wide aggregate body size (`8581 / 8500`), which is a compaction campaign, not an execution-fidelity contract gap. |

## Hardening Snapshot

| Skill | Verdict | Notes |
| --- | --- | --- |
| `900-shipglows-core` | strong baseline | Explicit canonical preflight, explicit system-improvement loop, and explicit stop condition for running ShipGlows-owned audit steps too early. |
| `101-sg-ready` | compacted | Detailed review heuristics and report templates moved to a local playbook; the activation body is now compact enough to clear the body-size risk. |
| `102-sg-start` | hardened | Added a compact local ShipGlows-owned preflight so canonical reference/tool resolution and operator-last-resort discipline stay visible in the activation body. |
| `103-sg-verify` | hardened | Added a compact local ShipGlows-owned preflight so verification cannot start from inferred paths or partial reference memory under pressure. |
| `108-sg-browser` | reference pattern | Best current example of explicit runtime preflight, safe stop behavior, and owner routing before browser proof. |
| `emailing` | patched | Added explicit `Report Modes` so the audit tool no longer sees a hidden reporting contract on this lightweight master workflow. |

## Registry

### Routing And Master Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `000-shipglows` | routing | done | Entry router already exposes canonical path, reporting, delegation, and routing references on the first screen. | none |
| `001-sg-build` | master | done | Lifecycle owner already exposes canonical path, reporting, delegation, and required references early enough for pressure execution. | none |
| `002-sg-maintain` | master | done | Maintenance master already exposes lifecycle, chantier, reporting, and ownership boundaries clearly on activation. | none |
| `003-sg-bug` | master | done | Bug lifecycle now uses the shared preview-proof and chantier-potential doctrine without duplicating it locally. | none |
| `004-sg-deploy` | master | done | Deploy lifecycle already exposes reporting, lifecycle routing, and hosted-proof sensitivity on the first screen. | none |
| `005-sg-ship` | master | done | Ship gate already exposes canonical path, reporting, and required references where execution pressure is highest. | none |
| `006-sg-design` | master | done | Design lifecycle already exposes canonical path, reporting, design-system references, and validation/stop anchors clearly. | none |
| `007-sg-content` | master | done | Content lifecycle already exposes canonical path, reporting, scope gate, and validation discipline clearly enough. | none |
| `008-sg-onboarding` | master | done | Onboarding lifecycle already exposes canonical path, reporting, required references, and proof gates clearly on activation. | none |
| `009-sg-skill-build` | master | done | Skill-maintenance master already exposes lifecycle routing and governance references prominently enough for execution fidelity. | none |

### Execution Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `100-sg-spec` | execution | done | Spec entrypoint stays compact and already exposes canonical path, reporting, mission, references, stop rules, and validation. | none |
| `101-sg-ready` | execution | done | Detailed readiness heuristics moved to a local playbook; top-level gate now stays focused on activation and verdict ownership. | none |
| `102-sg-start` | execution | done | Compact local ShipGlows-owned preflight added; validation passed and no further immediate hardening is needed in this batch. | none |
| `103-sg-verify` | execution | done | Compact local ShipGlows-owned preflight added; validation passed and no further immediate hardening is needed in this batch. | none |
| `104-sg-end` | execution | done | Compact local ShipGlows-owned preflight and local validation anchors added; closure bookkeeping now exposes the same first-30-seconds guardrail as the other critical lifecycle skills. | none |
| `105-sg-check` | execution | done | Compact local ShipGlows-owned preflight and local validation anchors added; runtime-visibility checks now expose the same first-30-seconds guardrail as other critical execution skills. | none |
| `106-sg-fix` | execution | done | Compact local ShipGlows-owned preflight and explicit operator-autonomy reminder added; bug repair now exposes the same first-30-seconds guardrail as the other critical execution skills. | none |
| `107-sg-test` | execution | done | Manual QA skill now exposes chantier-potential and preview-proof routing while keeping operator-last-resort discipline explicit. | none |
| `108-sg-browser` | execution | done | Strong explicit runtime preflight and owner-routing pattern; use as a reference skill for future hardening. | none |
| `109-sg-auth-debug` | execution | done | Compact local ShipGlows-owned preflight and explicit operator-last-resort reminder added; auth debugging now exposes the same first-30-seconds guardrail as the other critical proof skills. | none |

### Content And Research Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `200-sg-redact` | content | done | Drafting helper already exposes canonical path, reporting, references, stop rules, and validation cleanly. | none |
| `201-sg-enrich` | content | done | Enrichment helper already exposes canonical path, reporting, references, stop rules, and validation cleanly. | none |
| `202-sg-repurpose` | content | done | Repurposing helper already exposes canonical path, reporting, references, stop rules, and validation cleanly. | none |
| `203-sg-research` | content | done | Research workflow already exposes canonical path, reporting, and required source references clearly enough for tool discipline. | none |
| `204-sg-market-study` | content | done | Market-study workflow already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `205-sg-veille` | content | done | Veille workflow already exposes canonical path, reporting, source references, and governance routing clearly enough. | none |
| `206-sg-audit-copy` | content | done | Copy audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `207-sg-audit-copywriting` | content | done | Copywriting audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |

### Docs And Ops Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `300-sg-docs` | docs-ops | done | Docs owner already exposes canonical path, reporting, references, stop rules, and validation where governance mistakes would matter. | none |
| `301-sg-context` | docs-ops | done | Context loader is intentionally compact and already exposes canonical path plus low-blast-radius helper scope. | none |
| `302-sg-help` | docs-ops | done | Help router already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `303-sg-resume` | docs-ops | done | Resume helper stays compact and already exposes canonical path, mission, and bounded helper behavior clearly enough. | none |
| `304-sg-changelog` | docs-ops | done | Changelog helper stays compact and already exposes canonical path and deterministic output scope clearly enough. | none |
| `305-sg-init` | docs-ops | done | Bootstrap helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `306-sg-scaffold` | docs-ops | done | Scaffold helper already exposes canonical path, references, and deterministic setup constraints prominently enough. | none |
| `307-sg-skills-refresh` | docs-ops | done | Skills-refresh helper already exposes canonical path, reporting, and required references clearly enough for future hardening work. | none |
| `308-sg-status` | docs-ops | done | Status reporter already exposes canonical path, reporting, references, and bounded reporting purpose clearly. | none |
| `309-sg-tasks` | docs-ops | done | Tasks helper stays compact and already exposes deterministic tracker-updater scope clearly enough. | none |
| `310-sg-github-hygiene` | docs-ops | done | GitHub hygiene workflow already exposes canonical path, reporting, scope gate, references, stop rules, and validation clearly. | none |

### Audit Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `400-sg-audit` | audit | done | Audit entrypoint already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `401-sg-audit-code` | audit | done | Code audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `402-sg-deps` | audit | done | Dependency audit helper already exposes canonical path and dependency-proof workflow prominently enough. | none |
| `403-sg-perf` | audit | done | Performance audit helper already exposes canonical path and heavy audit workflow clearly enough despite size. | none |
| `404-sg-migrate` | audit | done | Migration helper already exposes canonical path and migration-planning scope clearly enough for safe routing. | none |
| `405-sg-prod` | audit | done | Production proof skill now uses the shared preview-proof route and already exposes reporting, references, stop rules, and validation clearly. | none |
| `406-sg-audit-seo` | audit | done | SEO audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `407-sg-audit-translate` | audit | done | Translation audit helper already exposes canonical path, reporting, and audit workflow clearly enough despite size. | none |
| `408-sg-audit-gtm` | audit | done | GTM audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `409-sg-audit-a11y` | audit | done | Accessibility audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |

### Design Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `500-sg-design-from-scratch` | design | done | Design-system creation skill already exposes canonical path, reporting, scope gate, references, validation, and stop rules clearly. | none |
| `501-sg-design-playground` | design | done | Design playground scaffold already exposes canonical path and deterministic design-playground setup clearly enough. | none |
| `502-sg-audit-design` | design | done | Design audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `503-sg-audit-design-tokens` | design | done | Token audit helper already exposes canonical path, reporting, and audit workflow clearly enough despite size. | none |
| `504-sg-audit-components` | design | done | Component audit helper already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |

### Platform Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `600-sg-local-cloud-sync` | platform | done | Local/cloud sync design skill already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `601-sg-product-entitlements` | platform | done | Entitlements design skill already exposes canonical path, reporting, references, stop rules, and validation clearly. | none |
| `602-sg-platform-parity` | platform | done | Platform parity audit already exposes canonical path, reporting, mission, stop rules, and validation clearly. | none |

### Meta Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `700-sg-explore` | meta | done | Exploration workflow stays compact and already exposes canonical path plus bounded exploratory mission clearly. | none |
| `701-sg-backlog` | meta | done | Backlog triage helper already exposes canonical path, reporting, references, and bounded backlog scope clearly. | none |
| `702-sg-priorities` | meta | done | Prioritization helper already exposes canonical path, reporting, references, and bounded decision scope clearly. | none |
| `703-sg-review` | meta | done | Review helper already exposes canonical path, reporting, references, and findings-first review posture clearly. | none |
| `704-sg-model` | meta | done | Model router stays compact and already exposes canonical path plus bounded routing role clearly enough. | none |
| `705-sg-conversation-audit` | meta | done | Conversation audit helper already exposes canonical private paths, safety gate, reporting, and follow-through routing clearly. | none |
| `706-continue` | meta | done | Continue helper already exposes canonical path, bounded continuation rules, and anti-chantier-drift guardrails clearly. | none |
| `707-name` | meta | done | Minimal helper stays low-blast-radius and already exposes canonical path plus bounded session-tagging workflow clearly enough. | none |

### Transcript Skills

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `800-tmux-capture-conversation` | transcript | done | Capture helper already exposes canonical output-path rules and preset guardrails clearly on activation. | none |
| `801-clean-conversation-transcript` | transcript | done | Transcript cleanup helper stays compact and already exposes mission, required input, and deterministic editing rules clearly. | none |

### Internal Operator Skill

| Skill | Family | Status | Current signal | Next action |
| --- | --- | --- | --- | --- |
| `900-shipglows-core` | internal | done | Explicit ShipGlows-owned tool preflight and reusable system-improvement output are now local and visible. | none |

## Batch Plan

| Batch | Scope | Target outcome |
| --- | --- | --- |
| A | `900`, `101`, `102`, `103`, `108` | completed |
| B | `000`-`009`, `104`-`109` | completed |
| C | `300`-`310`, `400`-`409` | completed |
| D | `200`-`207`, `500`-`707`, `800`-`801` | completed |

## Update Rule

When a skill is reviewed, update its row with:

- `status`
- one short `current signal`
- one concrete `next action` or `none`

Do not rewrite the register into essay form. Keep it as the operational sweep
tracker for this hardening campaign.
