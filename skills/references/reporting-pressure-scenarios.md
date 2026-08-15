---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-15"
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
- `SSRP-018 visible closure docs`: any report claiming closed, complete, done, resolved, or shipped includes `Documentation reflection: updated | not impacted — <concrete reason> | needs review — <surface>`; material `needs review` forbids closure language.
