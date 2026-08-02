---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-29"
created_at: "2026-05-29 23:34:37 UTC"
updated: "2026-05-30"
updated_at: "2026-05-30 20:21:23 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: workflow
owner: Diane
user_story: "En tant qu'operatrice ShipGlows, je veux exporter puis auditer durablement les conversations agent qui revelent des travers, afin que ShipGlows transforme les frictions reelles en ameliorations de skills, de rapports, de suivi et de comportements d'execution."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/tmux-capture-conversation/SKILL.md
  - skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh
  - skills/clean-conversation-transcript/SKILL.md
  - skills/sg-conversation-audit/SKILL.md
  - skills/sg-skill-build/SKILL.md
  - skills/sg-docs/SKILL.md
  - skills/sg-verify/SKILL.md
  - skills/references/decision-quality-contract.md
  - skills/references/question-contract.md
  - skills/references/master-delegation-semantics.md
  - skills/references/reporting-contract.md
  - skills/references/spec-driven-development-discipline.md
  - shipglows_data/workflow/conversations/
  - shipglows_data/workflow/conversation-audits/
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/question-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Conversation audit 2026-05-29: transcripts under /home/claude showed recurring agent flaws: reporting instead of acting, over-detailed reports, literalism over intent, weak routing, and proof gaps."
  - "User decision 2026-05-29: tmux-capture-conversation should get a ShipGlows preset such as `shipglows` that stores relevant conversations in one canonical place for future analysis."
  - "User decision 2026-05-29: the conversation-audit skill should be able to export first, then analyze and propose auto-evolution/correction of ShipGlows."
  - "Observed transcript: /home/claude/conversation-sg-prod-dernier-run-blacksmith-ci.md shows `sg-prod` reporting a clear CI compile failure instead of immediately fixing or routing the actionable defect."
  - "Observed transcript: /home/claude/shipglows/shipglows_data/workflow/conversations/conversation-sg-build-architecture-skills-20260504.md shows the desired master-skill UX: less plumbing exposed, subagents by default, and concise user-facing reports."
next_step: "None"
---

# Spec: ShipGlows Conversation Audit And Auto-Evolution Loop

## Title

ShipGlows Conversation Audit And Auto-Evolution Loop

## Status

ready

## User Story

En tant qu'operatrice ShipGlows, je veux exporter puis auditer durablement les conversations agent qui revelent des travers, afin que ShipGlows transforme les frictions reelles en ameliorations de skills, de rapports, de suivi et de comportements d'execution.

## Minimal Behavior Contract

ShipGlows must add a durable conversation feedback loop: a ShipGlows-specific export mode stores relevant tmux/Codex transcripts in a canonical workflow folder, and a new conversation-audit skill can optionally trigger that export before analyzing one or more transcripts for recurring agent flaws. The audit produces a structured report with evidence, categories, severity, affected skills/references, recommended fixes, and a safe next route such as `sg-skill-build`, `sg-docs`, `sg-verify`, or a new spec. If a transcript includes sensitive content, private URLs, secrets, or raw logs, the system must redact or block unsafe persistence instead of turning the transcript into public content. The easy edge case is creating another passive report; the feature succeeds only if the audit can route concrete auto-evolution work from real conversation evidence without polluting the main conversation or weakening quality gates.

## Success Behavior

- Preconditions: A ShipGlows conversation is available in a tmux pane, or one or more Markdown transcripts already exist under a project or `/home/claude`.
- Trigger: The operator runs `$tmux-capture-conversation shipglows`, `$sg-conversation-audit`, `$sg-conversation-audit latest`, or `$sg-conversation-audit export shipglows`.
- User/operator result: Conversation transcripts are stored under a predictable project-local path, and the audit report explains the agent flaws in concise, actionable language.
- System effect: ShipGlows creates or updates `shipglows_data/workflow/conversations/` and `shipglows_data/workflow/conversation-audits/` artifacts, classifies flaws, links evidence paths, and names the affected skills/contracts.
- Success proof: A fixture transcript or captured conversation produces a valid audit report with at least one categorized finding and one routed next action.
- Silent success: Not allowed. The run must report where the transcript/audit was written, what categories were found, and whether corrections were only proposed or ready to execute.

## Error Behavior

- Expected failures: no tmux pane available, ambiguous transcript source, unsafe output path, transcript contains likely secrets, export fails, transcript is too noisy to classify, no actionable finding, or proposed correction would touch unrelated dirty files.
- User/operator response: Ask one targeted question only when the source, destination, or correction route materially changes safety or scope.
- System effect: Do not write unsafe transcript content, do not claim a skill needs correction without evidence, and do not launch correction work from a weak or ambiguous finding.
- Must never happen: inventing transcript evidence, leaking secrets/private URLs, overwriting conversation files without `--force`, creating public content from private transcripts, opening duplicate specs when an existing chantier owns the issue, or auto-patching skills from a single unclear complaint.
- Silent failure: Not allowed. Blocked or partial audits must name the exact missing input, unsafe content, or evidence gap.

## Problem

ShipGlows conversations currently contain valuable evidence about where agents fail: they over-report, obey literal sarcasm, stop at diagnosis when a fix is obvious, ask weak questions, or expose too much internal plumbing. Those learnings are scattered across ad hoc Markdown exports and chat memory. Without a durable audit loop, the same agent flaws recur and skill improvements depend on the operator remembering and manually translating each frustration into a spec or patch.

## Solution

Add a canonical conversation export preset and a new `sg-conversation-audit` lifecycle/source skill. The export preset stores ShipGlows-relevant transcripts under `shipglows_data/workflow/conversations/`. The audit skill reads existing or freshly exported transcripts, classifies agent-behavior failures, writes a durable audit report under `shipglows_data/workflow/conversation-audits/`, and routes concrete improvements to the appropriate owner skill or new spec.

## Scope In

- Add a `shipglows` preset/mode to `tmux-capture-conversation` and its script.
- Define canonical storage:
  - `shipglows_data/workflow/conversations/`
  - `shipglows_data/workflow/conversation-audits/`
- Create `sg-conversation-audit` as a ShipGlows skill.
- Support modes:
  - default: audit relevant stored conversations
  - `latest`: audit the latest stored conversation
  - `path <file-or-dir>`: audit an explicit transcript path
  - `export shipglows`: capture with the ShipGlows preset, then audit the new transcript
  - `report=agent`: detailed evidence handoff
- Define stable finding categories:
  - `missed_action`
  - `over_reporting`
  - `wrong_owner_route`
  - `literalism_over_intent`
  - `proof_gap`
  - `stale_skill_contract`
  - `bad_question`
  - `user_friction`
  - `unsafe_ship_or_dirty_scope`
  - `weak_follow_through`
- Add an audit report template with metadata, evidence pointers, severity, affected skills, recommended owner, and proposed correction route.
- Add a redaction/safety gate for private transcript content.
- Add routing rules to `sg-skill-build`, `sg-docs`, `sg-verify`, or `/sg-spec` when findings cross the chantier threshold.
- Update README/help/public skill pages and content maps only where this new workflow becomes user-facing.

## Scope Out

- No automatic skill patching without an explicit owner route and validated finding.
- No ingestion of all `/home/claude/**/*.md` by default.
- No public publishing of transcripts.
- No training data export, telemetry upload, or external analytics.
- No attempt to classify every normal assistant imperfection as a skill defect.
- No replacement of `tmux-capture-conversation` or `clean-conversation-transcript`; this feature composes them.

## Constraints

- `tmux-capture-conversation` remains a reliable helper: capture, name, and store. It should not grow the audit intelligence.
- `sg-conversation-audit` owns analysis, classification, and improvement routing.
- Stored transcripts and audit reports are project-local workflow artifacts, not public site content.
- Transcript evidence must be referenced by file path and small excerpts only; never paste large private transcript blocks into public docs or broad reports.
- The audit must distinguish one-off execution mistakes from systemic skill-contract gaps.
- The audit must preserve the decision-quality contract: proposed fixes optimize correctness, security, durability, excellence, and proof quality before speed or convenience.
- Findings that imply behavior changes in core lifecycle skills require spec/ready/start/verify rather than a direct broad patch.
- Existing dirty worktree changes must not be reverted or included in unrelated ship scope.

## Test Contract

- Surface/stack profile: ShipGlows skill/runtime tooling, Bash script, Markdown artifacts, and Astro public docs if surfaced.
- Automated proof:
  - shell dry-run for `capture_tmux_conversation.sh --dry-run`
  - parser/classifier unit fixture if implemented as a script
  - metadata lint for new templates/spec/docs
  - skill budget audit
  - runtime skill sync
  - site build if public skill/docs content changes
- Agent-run proof:
  - `rg` checks for mode names, canonical paths, categories, redaction rules, and routing rules
  - fixture audit against at least one captured transcript containing a known flaw
- Manual proof:
  - optional operator confirmation that the report categories match real frustration signals
  - no required manual checklist in v1 unless `sg-ready` decides user confirmation is necessary
- Proof order:
  - fixture/static checks first
  - skill sync and budget second
  - public site build only if public surfaces change
  - manual/operator review only for subjective severity calibration
- Fresh external docs: not needed; this spec is governed by local ShipGlows skill contracts and tmux/Bash behavior already present in the repo.

## Dependencies

- Existing helper skill: `skills/tmux-capture-conversation/SKILL.md`.
- Existing capture script: `skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh`.
- Optional cleanup helper: `skills/clean-conversation-transcript/SKILL.md`.
- Existing contracts:
  - `skills/references/decision-quality-contract.md`
  - `skills/references/question-contract.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/chantier-tracking.md`
  - `skills/references/master-delegation-semantics.md`
- Owner routes:
  - `sg-skill-build` for skill contract changes
  - `sg-docs` for docs/content alignment
  - `sg-verify` for checking whether a fix satisfies the identified flaw
  - `sg-spec` for non-trivial behavior changes

## Invariants

- Conversations are evidence, not product truth. A single transcript can trigger investigation, but systemic changes require corroboration or a clearly severe failure.
- Audit reports must keep a clear distinction between:
  - observed evidence
  - inferred agent flaw
  - affected skill or reference
  - recommended correction
  - confidence
- The export preset must never overwrite existing transcripts unless `--force` is explicit.
- The audit must not weaken existing safety gates to reduce friction.
- If a failure is directly actionable, the recommended route should name the owner skill that can fix it, not merely describe the problem.
- Public-facing summaries must be concise and non-sensitive.

## Links & Consequences

- Upstream: tmux pane transcripts, existing Markdown conversation exports, operator frustration signals, ShipGlows lifecycle specs, bug/prod/deploy failures.
- Downstream: new skill `sg-conversation-audit`, capture preset updates, conversation audit reports, skill specs or patches, public/help docs if the skill becomes discoverable.
- Cross-cutting impacts: redaction, metadata lint, skill budget, runtime sync, reporting contract, chantier potential classification.
- Shipping impact: new skill and script changes require `shipglows_sync_skills.sh --check --all` before ship.

## Documentation Coherence

- Update `README.md` and/or `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` if `sg-conversation-audit` becomes a public/operator skill.
- Add `site/src/content/skills/sg-conversation-audit.md` if public skill pages are maintained for all active skills.
- Update `shipglows_data/editorial/content-map.md` if a new public skill page or public docs section is added.
- Update `skills/sg-help/references/help-catalog.md` so users can discover the audit workflow.
- Update `tmux-capture-conversation` README/public docs if the `shipglows` preset changes its user-facing behavior.

## Edge Cases

- The latest transcript is about another project, not ShipGlows.
- The transcript includes secrets, private URLs, cookies, logs, or PII.
- The transcript is a generated public content file, not an actual conversation.
- The same conversation exists in two locations.
- A finding is caused by a model/runtime limitation, not a skill contract.
- The operator explicitly asks for read-only analysis; the audit must not launch correction.
- A transcript contains sarcasm, frustration, or insults; the audit must extract the operational signal without mirroring tone.
- A proposed fix crosses multiple lifecycle skills; the audit must route to a spec instead of patching one file opportunistically.
- An audit finds that the best fix is already implemented in current skills; report `already covered` with the reference and recommend verification, not duplicate work.

## Implementation Tasks

- [ ] Task 1: Add canonical conversation storage policy
  - File: `skills/tmux-capture-conversation/SKILL.md`
  - Action: Document the `shipglows` preset and canonical destination `shipglows_data/workflow/conversations/`.
  - User story link: Gives the operator one stable place to store future conversations for analysis.
  - Depends on: None
  - Validate with: `rg -n "shipglows_data/workflow/conversations|shipglows preset|conversation-audits" skills/tmux-capture-conversation/SKILL.md`
  - Notes: Keep this helper focused on capture and storage.

- [ ] Task 2: Implement script preset support
  - File: `skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh`
  - Action: Accept a `shipglows` positional preset or explicit `--preset shipglows` and route output to the inferred ShipGlows governance root `shipglows_data/workflow/conversations/`.
  - User story link: Lets `$tmux-capture-conversation shipglows` work without manual path selection.
  - Depends on: Task 1
  - Validate with: `skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh --dry-run --preset shipglows` or equivalent shell fixture if tmux is unavailable.
  - Notes: Preserve existing `--destination` override behavior.

- [ ] Task 3: Add conversation audit report template
  - File: `templates/conversation_audit.md`
  - Action: Define frontmatter, source transcript refs, finding table, categories, severity, evidence snippets, affected skills, recommended owner route, and safety notes.
  - User story link: Makes audit results durable and comparable over time.
  - Depends on: None
  - Validate with: `python3 tools/shipglows_metadata_lint.py templates/conversation_audit.md`
  - Notes: Add metadata lint support if a new artifact type is required.

- [ ] Task 4: Add metadata lint support for conversation audits if needed
  - File: `tools/shipglows_metadata_lint.py`
  - Action: Accept `artifact: conversation_audit` with required metadata fields, or document reuse of an existing artifact type.
  - User story link: Keeps audit outputs compliant with ShipGlows artifact governance.
  - Depends on: Task 3
  - Validate with: `python3 tools/shipglows_metadata_lint.py templates/conversation_audit.md`
  - Notes: Avoid broad lint churn.

- [ ] Task 5: Create `sg-conversation-audit`
  - File: `skills/sg-conversation-audit/SKILL.md`
  - Action: Define modes, canonical paths, source resolution, categories, redaction gate, report modes, chantier potential routing, and owner skill handoff.
  - User story link: Gives the operator a direct skill for turning frustrating conversations into ShipGlows improvements.
  - Depends on: Tasks 1-4
  - Validate with: `rg -n "name: sg-conversation-audit|missed_action|over_reporting|literalism_over_intent|conversation-audits|sg-skill-build|redaction" skills/sg-conversation-audit/SKILL.md`
  - Notes: Trace category should likely be `conditionnel`, process role `source-de-chantier`.

- [ ] Task 6: Add optional analyzer helper script or fixture parser
  - File: `tools/shipglows_conversation_audit.py` or `skills/sg-conversation-audit/scripts/`
  - Action: Provide deterministic extraction of transcript metadata, likely user-friction signals, category markers, evidence snippets, and report skeleton.
  - User story link: Reduces subjective drift and makes audits repeatable.
  - Depends on: Task 5
  - Validate with: a fixture transcript containing `missed_action`, `over_reporting`, and `literalism_over_intent`.
  - Notes: Script can be lightweight in v1; LLM judgement may still fill recommendations.

- [ ] Task 7: Add fixture conversations
  - File: `shipglows_data/workflow/conversations/fixtures/`
  - Action: Add redacted fixture snippets based on observed patterns, not full private transcripts.
  - User story link: Proves the audit categories work on real failure shapes.
  - Depends on: Task 6
  - Validate with: `sg-conversation-audit` fixture mode or script command.
  - Notes: Keep fixtures small and sanitized.

- [ ] Task 8: Define actionable failure routing rule
  - File: `skills/references/actionable-failure-contract.md`
  - Action: Define when an owner skill must fix/reroute instead of only reporting a failure with clear file/line/cause evidence.
  - User story link: Prevents the `sg-prod` Blacksmith CI failure pattern from recurring.
  - Depends on: Task 5
  - Validate with: `rg -n "actionable failure|file.*line|fix or route|read-only exception|sg-prod|sg-check|sg-fix" skills/references/actionable-failure-contract.md`
  - Notes: Load this from `sg-prod`, `sg-check`, `sg-verify`, `sg-deploy`, and `sg-build` where relevant.

- [ ] Task 9: Wire actionable failure into owner skills
  - File: `skills/sg-prod/SKILL.md`, `skills/sg-check/SKILL.md`, `skills/sg-verify/SKILL.md`, `skills/sg-deploy/SKILL.md`, `skills/sg-build/SKILL.md`
  - Action: Require fix/reroute behavior when evidence is actionable, with read-only exceptions.
  - User story link: Turns failed evidence into correction instead of passive reporting.
  - Depends on: Task 8
  - Validate with: `rg -n "actionable-failure-contract|actionable failure|fix or route|read-only" skills/sg-prod/SKILL.md skills/sg-check/SKILL.md skills/sg-verify/SKILL.md skills/sg-deploy/SKILL.md skills/sg-build/SKILL.md`
  - Notes: Keep each skill's ownership boundaries intact.

- [ ] Task 10: Update discovery and public/operator docs
  - File: `README.md`, `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`, `skills/sg-help/references/help-catalog.md`, `site/src/content/skills/sg-conversation-audit.md` if public skill pages are required.
  - Action: Explain when to use conversation audit, how export+audit works, and that private transcripts stay workflow artifacts.
  - User story link: Makes the workflow discoverable without exposing internal transcript content.
  - Depends on: Tasks 5 and 8
  - Validate with: `rg -n "sg-conversation-audit|conversation audit|conversation-audits|tmux-capture-conversation shipglows" README.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md skills/sg-help/references/help-catalog.md site/src/content/skills`
  - Notes: Run site build if public content changes.

## Acceptance Criteria

- [ ] AC 1: Given the operator runs `$tmux-capture-conversation shipglows`, when the capture succeeds, then the transcript is stored under `shipglows_data/workflow/conversations/` with a non-generic title and no manual destination prompt unless ambiguity remains.
- [ ] AC 2: Given the operator runs `$sg-conversation-audit export shipglows`, when a tmux pane is available, then the skill captures the transcript first and audits the captured file in the same run.
- [ ] AC 3: Given an existing transcript path, when `$sg-conversation-audit path <file>` runs, then it writes one audit report under `shipglows_data/workflow/conversation-audits/`.
- [ ] AC 4: Given a transcript shows an agent reporting a clear build failure without fixing or routing, when audited, then the report includes category `missed_action` and recommends the actionable failure route.
- [ ] AC 5: Given a transcript shows excessive technical output in the user thread, when audited, then the report includes category `over_reporting` and points to the reporting contract or affected skill.
- [ ] AC 6: Given a transcript shows sarcasm or frustration being followed literally against the established goal, when audited, then the report includes category `literalism_over_intent`.
- [ ] AC 7: Given a transcript contains likely secrets or private raw logs, when audited, then the audit blocks or redacts unsafe evidence and does not create public content.
- [ ] AC 8: Given a finding has weak evidence or is a one-off runtime miss, when audited, then the report marks confidence appropriately and does not recommend broad skill changes.
- [ ] AC 9: Given a finding reveals a systemic multi-skill gap, when audited, then the report recommends `/sg-spec` or `/sg-skill-build` instead of a silent direct patch.
- [ ] AC 10: Given the audit report is complete, when `sg-verify` checks it, then every recommendation has evidence, severity, affected skill/reference, and next owner route.
- [ ] AC 11: Given public/operator docs are updated, when `pnpm --dir shipglows-site build` runs, then the site build passes.
- [ ] AC 12: Given skills are changed, when skill validations run, then `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` and `tools/shipglows_sync_skills.sh --check --all` pass or report only accepted non-blocking risks.

## Test Strategy

- Unit/static:
  - shell argument parsing for `shipglows` or `--preset shipglows`
  - analyzer helper fixture tests if helper script is added
  - metadata lint for new template/report/spec
- Integration:
  - dry-run export with the ShipGlows preset
  - audit a redacted fixture transcript and verify generated categories/routes
  - audit `latest` from the canonical conversations folder
- Manual:
  - one operator review of the first real audit report to calibrate severity and usefulness
- Regression:
  - ensure default tmux capture behavior still writes to `shipglows_data/workflow/conversations/` for non-preset captures
  - ensure `clean-conversation-transcript` remains independent and is not forced into every audit run

## Risks

- Security impact: yes. Transcripts can contain private project context, secrets, raw logs, private URLs, personal data, or sensitive operator frustration. Mitigation: redaction gate, private workflow storage, no public publishing, evidence snippets only.
- Product/workflow risk: high. A weak audit loop could generate noisy specs and make ShipGlows more bureaucratic. Mitigation: confidence scoring, chantier threshold, and owner routing.
- False positive risk: medium. One bad run may be a runtime/model issue rather than a skill defect. Mitigation: distinguish one-off execution failure from systemic contract gap.
- Maintenance risk: medium. Adding a new skill and script parser can increase skill inventory. Mitigation: compact activation contract and progressive disclosure references.

## Execution Notes

- Read first:
  - `skills/tmux-capture-conversation/SKILL.md`
  - `skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh`
  - `skills/clean-conversation-transcript/SKILL.md`
  - `skills/references/decision-quality-contract.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/chantier-tracking.md`
  - `skills/sg-prod/SKILL.md`
  - `skills/sg-check/SKILL.md`
  - `skills/sg-verify/SKILL.md`
- Useful evidence examples:
  - `/home/claude/conversation-sg-prod-dernier-run-blacksmith-ci.md`
  - `shipglows_data/workflow/conversations/conversation-sg-build-architecture-skills-20260504.md`
  - `conversation-shipglows-questions-contextuelles-des-skills.md`
- Implementation approach:
  1. Add storage/preset support to the capture helper.
  2. Add report template and metadata lint support.
  3. Create `sg-conversation-audit` with categories and routing rules.
  4. Add fixture-based audit proof.
  5. Add actionable failure contract and wire affected skills.
  6. Update discovery/docs/public surfaces.
- Validation commands:
  - `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/shipglows-conversation-audit-and-auto-evolution-loop.md`
  - `rg -n "sg-conversation-audit|conversation-audits|shipglows_data/workflow/conversations|missed_action|literalism_over_intent|actionable failure" skills templates tools README.md docs site/src/content/skills shipglows_data/workflow/specs`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipglows_sync_skills.sh --check --all`
  - `pnpm --dir shipglows-site build` if public content changes
- Stop conditions:
  - transcript source is ambiguous and no safe default exists
  - redaction gate flags likely secrets
  - finding cannot be tied to evidence
  - proposed correction would touch unrelated dirty files
  - new skill public page would violate Astro content schema

## Open Questions

None for v1. The operator has selected the core architecture: keep export and analysis separate, but allow the audit skill to trigger export via an argument such as `export shipglows`.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-29 23:34:37 UTC | sg-spec | GPT-5 Codex | Created draft spec for a ShipGlows conversation export, audit, and auto-evolution loop | draft | /sg-ready ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 00:01:23 UTC | sg-ready | GPT-5 Codex | Reviewed readiness for the conversation export, audit, and auto-evolution loop; structure, user-story alignment, security/redaction, proof plan, and owner routing are sufficient for implementation | ready | /sg-start ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 07:00:28 UTC | sg-verify | GPT-5 Codex | Verification requested after delegated sg-start launch, but the implementation subagent failed before completion and no planned artifacts were present locally | blocked | /sg-start ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 07:12:44 UTC | sg-start | GPT-5 Codex | Implemented conversation-audit workflow: added `shipglows` capture preset, conversation audit skill contract, fixture paths, actionable-failure reference, and public/operator discovery updates | implemented | /sg-verify ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 07:14:09 UTC | sg-verify | GPT-5 Codex | Verified implementation after local repairs for metadata, fixture classification, and runtime skill sync; metadata lint, helper compile, fixture classification, skill budget, runtime sync, site build, and tmux dry-run proof passed | verified | /sg-end ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 07:33:35 UTC | sg-end | GPT-5 Codex | Closed the verified conversation-audit chantier, updated task tracker and changelog bookkeeping, and left commit/push to sg-ship | closed | /sg-ship ShipGlows Conversation Audit And Auto-Evolution Loop |
| 2026-05-30 20:21:23 UTC | sg-ship | GPT-5 Codex | Shipped the verified conversation-audit loop with TDD/checklist and batch conversation audit workflow artifacts in a scoped ShipGlows workflow commit | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: done, spec ready for implementation.
- `sg-start`: done, implemented with public-facing and script/skill updates completed.
- `sg-verify`: done, verified after metadata, fixture, runtime sync, site build, and tmux dry-run proof.
- `sg-end`: closed, task tracker and changelog prepared.
- `sg-ship`: shipped.

Next step: None
