---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "2.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-21"
status: active
source_skill: 900-shipglows-core
scope: reporting-pressure-scenarios
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/reporting-contract.md
depends_on: []
supersedes: []
evidence:
  - "Extracted from reporting-contract.md in wave 13 for maintenance-only loading."
  - "Operator decision 2026-08-13: reporting choices must carry strategic business value and short controls must trigger guided follow-up."
  - "Operator clarification 2026-08-15: closure reports must make documentation reflection visible."
  - "Operator decision 2026-08-15: closure proof and documentation evidence each stay on one visually labelled line separated by middle dots."
  - "Operator decision 2026-08-15: true chantier starts receive the same visual structure without exposing file paths or technical links."
  - "Operator decision 2026-08-18: reporting structure must not create work merely to fill its blocks."
  - "Operator decision 2026-08-16: closure reports expose editorial impact separately and reject ceremonial content."
  - "Operator correction 2026-08-21: SUITE must select real business continuity and reject no-action-required outcomes."
  - "Operator decision 2026-08-16: a useful completed result may offer guided deepening or reorientation without reopening delivery."
  - "Operator approval 2026-08-21: conversation restart recommendations are quality-based, stabilized, resumable, and operator-started."
  - "Operator correction 2026-08-21: a new objective alone does not trigger restart; useful context must be materially unreliable."
  - "Operator approval 2026-08-22: context checking must be proportional, transition-light, and signal-driven."
next_review: "2026-11-12"
next_step: none
---

# Reporting Pressure Scenarios

- `SSRP-001 human success`: concise active-language outcome and proof, no checklist dump.
- `SSRP-002 human not-ready`: plain blockers plus one numbered recovery decision, no internal command/owner.
- `SSRP-003 human blocked safety`: redacted evidence, safest action, no secrets or bulk logs.
- `SSRP-004 agent handoff`: explicit agent mode may include matrices, files, commands, and internals.
- `SSRP-005 proof limit`: name missing proof/exception before any completion claim.
- `SSRP-006 active lifecycle`: agent-runnable stages continue rather than becoming operator tasks.
- `SSRP-007 directed conversation`: milestones advance the unresolved goal; they do not replace it.
- `SSRP-008 no modified-file inventory`: user mode omits modified-files heading, file names, paths, and counts.
- `SSRP-009 chantier opening`: local/spec header precedes time-only verdict; no trailing chantier block.
- `SSRP-010 compact validation line`: emit `✅ Tests 18/18 · 🧾 Métadonnées OK · 🔄 Sync 236/236`; unavailable/failing segments stay separate.
- `SSRP-011 chantier emoji semantics`: normal `🧱`, genuinely blocked `🚧`, context markers only for their declared meanings.
- `SSRP-012 unfinished chantier choice`: open user result ends with two or three plain choices; complete result does not.
- `SSRP-013 recurrence-claim-boundary`:
  - `local-repair`: report a bounded result and known recurrence conditions, not all projects or future changes.
  - `unsupported-guarantee`: require a preventive invariant whose scope covers the claim; reject “pour toujours”, “garanti”, “ne se reproduira pas” and semantic equivalents otherwise.
  - `proofless-invariant`: an invariant without focused mechanical proof does not authorize a universal non-recurrence claim.
  - `covered-invariant`: state the invariant, its scope, and its focused mechanical proof; claim prevention only for that covered scope.
- `SSRP-014 strategic business choice`: a material unfinished-chantier decision offers distinct business visions with outcome, stakeholder effect, horizon, trade-off, and a reasoned recommendation; technical workflow variants fail.
- `SSRP-015 guided questioning`: selecting a short `Questionner` control triggers focused questions that reveal business truth or distinguish credible directions; it never grants mutation approval.
- `SSRP-016 guided reorientation`: selecting a short `Réorienter` control triggers concrete alternative business directions and their consequences; it never answers with a blank “toward what?”.
- `SSRP-017 no blank-page handoff`: the operator receives evidence-backed framing, proposals, and a recommendation instead of being asked to invent strategy or technical mechanics.
- `SSRP-018 visible closure docs`: any report claiming closed, complete, done, resolved, or shipped includes `📖 DOCUMENTATION`, then exactly one compact line using `✅ updated · <scope>`, `➖ not impacted · <concrete reason>`, or `⚠️ needs review · <surface>`; material `needs review` forbids closure language.
- `SSRP-019 visual closure card`: a successful closure uses the five ordered blocks `✨ RÉSULTAT`, `🧪 PREUVES`, `📖 DOCUMENTATION`, `✏️ ÉDITORIAL`, and `📦 LIVRAISON`; proof, documentation, and editorial content each occupy one line with ` · ` separators, while an empty `⚠️ LIMITES` block is absent.
- `SSRP-020 visual start card`: after approval, a substantive chantier starts once with `🚀 Démarré` and the ordered blocks `✨ OBJECTIF`, `📐 PÉRIMÈTRE`, `🧪 PREUVES ATTENDUES`, and `📖 DOCUMENTATION PRÉVUE`; the card never replaces a pending approval prompt or decorates a micro-action.
- `SSRP-021 no technical path leakage`: `report=user` omits file names, paths, and clickable technical file links unless the operator must act on that exact artifact or explicitly requests detailed evidence.
- `SSRP-022 reporting effort ceiling`: one meaningful proof may support a verdict; placeholder counts are not quotas; prose stays to one sentence per block; no extra check, audit, research, documentation, content, or detail is created solely for reporting, while proof and documentation genuinely required by the chantier remain mandatory.
- `SSRP-022 visible closure editorial`: every completion claim includes `✏️ ÉDITORIAL` with `updated`, `not impacted · <concrete reason>`, or `needs review · <surface>`; a material gap blocks closure, `No declared public surface` is valid evidence, and unaffected work creates no filler content.
- `SSRP-023 completed chantier follow-up`: when a delivered result has a useful decision surface, the closure may offer `Approfondir` and `Réorienter`; either starts guided follow-up, does not reopen the completed chantier, and never grants mutation approval. An empty ceremonial menu fails.
- `SSRP-024 mandatory next block`: every final user report includes a useful `🧭 SUITE`; `none`, no-action-required wording, semantic equivalents, and empty ceremonial menus fail.
- `SSRP-025 conversation continuity`: unfinished operator goals, earlier open chantiers, and pending review, PR, preview, proof, commit, push, or delivery in the current conversation beat tracker, audit, and new-idea candidates; safely agent-runnable authorized work continues before final reporting.
- `SSRP-026 tracker priority`: when conversation, proof, delivery, and active chantiers are clear, select actionable `TASKS.md` work in `P0 -> P1 -> P2 -> P3` order without inflating severity; skip a higher item only with evidence that it is blocked or inapplicable.
- `SSRP-027 overdue audit fallback`: when no actionable tracked work exists, compare `AUDIT_LOG.md` with the audit cadence matrix and choose the first event-triggered, never-run, or most overdue applicable audit instead of claiming completion has no sequel.
- `SSRP-028 grounded business continuation`: when conversation, delivery, active work, tracker, and audit freshness are clear, select one evidence-backed product, customer, editorial, security, quality, or funnel improvement; speculative busywork fails.
- `SSRP-029 authority boundary`: choosing a next outcome never grants mutation authority for a new or expanded chantier, bypasses a pause, or turns reporting into hidden execution.
- `SSRP-030 restart capability truth`: Codex never claims it can restart, reset, close, or replace its active conversation; only the operator starts a new one.
- `SSRP-031 no superficial restart`: message count, elapsed time, conversation length, compaction, and an independent outcome alone never justify restart while useful context remains reliable.
- `SSRP-032 stabilized resumable restart`: a quality-based restart recommendation follows durable-state and Git stabilization, reports any incomplete state honestly, and includes one redacted self-contained copyable prompt for a fresh agent.
- `SSRP-033 proportional context cost`: chantier end, compaction, or major subject change receives only a lightweight state check; no full conversation reread occurs by default, and a targeted refresh reads only affected sources after a concrete degradation signal.
