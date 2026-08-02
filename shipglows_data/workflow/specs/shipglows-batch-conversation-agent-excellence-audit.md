---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-30"
created_at: "2026-05-30 16:33:28 UTC"
updated: "2026-05-30"
updated_at: "2026-05-30 20:21:23 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: workflow-audit
owner: Diane
user_story: "En tant qu'operatrice ShipGlows, je veux auditer les conversations Markdown sous /home/claude qui montrent les travers des agents, afin d'ameliorer les skills, leur capacite a etre suivies, leurs rapports, et leur niveau d'excellence operationnelle."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/conversations/
  - shipglows_data/workflow/conversation-audits/
  - shipglows_data/workflow/specs/
  - skills/sg-conversation-audit/SKILL.md
  - skills/references/actionable-failure-contract.md
  - skills/references/decision-quality-contract.md
  - skills/references/reporting-contract.md
  - skills/references/question-contract.md
  - skills/references/spec-driven-development-discipline.md
  - skills/sg-build/SKILL.md
  - skills/sg-skill-build/SKILL.md
  - skills/sg-docs/SKILL.md
  - skills/sg-verify/SKILL.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/actionable-failure-contract.md"
    artifact_version: "1.0.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/shipglows-conversation-audit-and-auto-evolution-loop.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "User request 2026-05-30: analyser les conversations .md sous /home/claude pour voir les travers des agents et optimiser les skills, leur capacite a etre suivies, et leur rapport."
  - "User request 2026-05-30: si le chantier est long, planifier une parallelisation."
  - "Candidate conversation files found: /home/claude/conversation-obstacles-creation-de-notre-set-de-skills.md"
  - "Candidate conversation files found: /home/claude/conversation-sg-prod-dernier-run-blacksmith-ci.md"
  - "Candidate conversation files found: /home/claude/shipglows/conversation-shipglows-questions-contextuelles-des-skills.md"
  - "Candidate conversation files found: /home/claude/shipglows/shipglows_data/workflow/conversations/conversation-sg-build-architecture-skills-20260504.md"
next_step: "None"
---

# Spec: ShipGlows Batch Conversation Agent Excellence Audit

## Title

ShipGlows Batch Conversation Agent Excellence Audit

## Status

ready

## User Story

En tant qu'operatrice ShipGlows, je veux auditer les conversations Markdown sous `/home/claude` qui montrent les travers des agents, afin d'ameliorer les skills, leur capacite a etre suivies, leurs rapports, et leur niveau d'excellence operationnelle.

## Minimal Behavior Contract

ShipGlows must run a safe, evidence-first audit over the relevant conversation Markdown files under `/home/claude`, excluding package caches and ordinary project documentation unless explicitly selected. The audit must identify recurring agent failure patterns, tie every finding to transcript evidence, group the findings by affected skill/reference and behavior category, and produce an actionable improvement plan with owner routes. If the corpus contains private paths, secrets, raw logs, or sensitive user context, the audit must keep full evidence private, use redacted excerpts, and avoid public content changes. The easy edge case is producing a passive complaint summary; the run succeeds only when it gives implementable skill/doc/reporting improvements and a proof path for verifying that future agents follow them.

## Success Behavior

- Preconditions: one or more candidate conversation Markdown files exist under `/home/claude`, and ShipGlows's local conversation-audit tooling or manual evidence review can read them safely.
- Trigger: the operator runs `/sg-start ShipGlows Batch Conversation Agent Excellence Audit` or an equivalent owner-skill handoff.
- User/operator result: a concise aggregate audit report names the top recurring agent flaws, the affected skills/contracts, and the concrete next correction route for each meaningful cluster.
- System effect: ShipGlows writes an aggregate audit report under `shipglows_data/workflow/conversation-audits/`, optionally writes per-transcript subreports, and opens follow-up routes only for evidence-backed changes.
- Success proof: every high/medium severity recommendation has a source transcript path, category, affected skill/reference, confidence, owner route, and validation method.
- Silent success: not allowed. The final report must state corpus size, skipped files, top findings, unsafe-content handling, and next route.

## Error Behavior

- Expected failures: no relevant transcript files found, too many unrelated Markdown files, unsafe transcript content, ambiguous project ownership, noisy evidence that cannot support a skill change, or dirty worktree conflicts in target skill files.
- User/operator response: ask a targeted question only if source selection, redaction policy, or correction ownership materially changes the result.
- System effect: do not ingest package caches by default, do not quote sensitive content in broad reports, do not create duplicate specs for findings already covered by an active chantier, and do not patch skills from weak evidence.
- Must never happen: publish private transcripts, invent evidence, treat one-off model failure as systemic without confidence labeling, bypass `decision-quality-contract`, or optimize for speed over durable correction quality.
- Silent failure: not allowed. A blocked run must name the exact corpus issue, safety hold, or evidence gap.

## Problem

ShipGlows has started improving its skills through spec-driven and test-driven workflows, but the operator still observes recurring execution failures in real conversations: agents over-report, stop at diagnosis, ask unnecessary questions, miss owner routes, expose internal plumbing, or follow literal words instead of the user's strategic intent. Those patterns are currently visible in scattered Markdown conversations under `/home/claude`; without a structured batch audit, the signals remain anecdotal and do not reliably become skill improvements.

## Solution

Create an operational audit chantier that uses `sg-conversation-audit` and direct transcript review to analyze a curated corpus of conversation Markdown files under `/home/claude`. The chantier will split large corpora into parallel batches, classify findings with stable categories, produce an aggregate report, and route improvements to `sg-skill-build`, `sg-docs`, `sg-verify`, or a new spec depending on severity and scope.

## Scope In

- Discover relevant conversation Markdown files under `/home/claude` with conservative filters:
  - include files whose names or parent folders indicate conversations/transcripts;
  - include explicit user-provided paths;
  - include `shipglows/shipglows_data/workflow/conversations/*.md`;
  - include canonical `shipglows_data/workflow/conversations/**/*.md`.
- Exclude by default:
  - package caches such as `.cargo`, `.bun`, `.cache`, `node_modules`, `.npm`, `.rustup`, `.pub-cache`;
  - normal project docs such as `README.md`, `CHANGELOG.md`, `shipglows_data/workflow/TEST_LOG.md`, `CLAUDE.md`, and `AGENT.md` unless explicitly selected.
- Produce one aggregate audit report in `shipglows_data/workflow/conversation-audits/`.
- Classify findings using `sg-conversation-audit` categories plus a human synthesis pass for:
  - followability gaps;
  - reporting noise;
  - missing execution ownership;
  - weak test/proof discipline;
  - failure to preserve user intent and excellence bar;
  - unclear skill routing;
  - poor handoff and lifecycle traceability.
- Plan parallel review if the selected corpus has more than four transcripts or more than roughly 80k words total.
- Convert findings into owner routes, not just observations.
- Preserve privacy and redaction rules for transcript evidence.

## Scope Out

- No public publication of full transcripts.
- No automatic editing of skills during the audit spec itself.
- No ingestion of every Markdown file under `/home/claude` without filtering.
- No retraining, telemetry upload, or external analytics.
- No broad rewrite of all skills from a single weak finding.
- No replacement of `sg-conversation-audit`; this chantier uses and stress-tests it.

## Constraints

- The audit must optimize for correctness, security, durability, excellence, and proof quality before speed or convenience.
- The corpus selector must be conservative: false negatives are acceptable when safety is unclear; false positives from package caches are not useful.
- Every recommendation must have transcript evidence and confidence.
- Findings must distinguish:
  - user frustration signal;
  - observed agent behavior;
  - likely skill/reference gap;
  - recommended correction;
  - validation method.
- If a finding affects multiple lifecycle skills or the global decision contract, route to `sg-spec` or `sg-skill-build` instead of direct opportunistic edits.
- Existing dirty files in the ShipGlows worktree must not be reverted or overwritten.

## Test Contract

- `surface`: ShipGlows workflow artifacts, Markdown transcripts, Python helper script, skill contracts, reporting contract, and private audit reports.
- `proof_profile`: mixed automated/static plus evidence-review proof. The audit itself is not a code implementation, but its recommendations must be evidence-backed and machine-checkable enough for `sg-verify`.
- `proof_order`:
  1. corpus inventory;
  2. safety filter;
  3. per-transcript deterministic classification;
  4. transcript review and batch notes;
  5. aggregate synthesis;
  6. owner-route mapping;
  7. follow-up chantier or skill-build decision.
- `checklist_path`: none for v1, because the audit output is a private workflow report; if follow-up implementation changes user-facing skill behavior, that follow-up chantier owns any manual checklist.
- `required_scenario_ids`:
  - `CORPUS-FILTER`: select relevant conversation transcripts while excluding package caches and ordinary project docs.
  - `SAFETY-GATE`: detect unsafe transcript content and preserve private/redacted handling.
  - `CLASSIFIER-BASELINE`: run deterministic category extraction where safe.
  - `BATCH-REVIEW`: produce evidence-backed findings for each selected transcript or batch.
  - `AGGREGATE-ROUTING`: deduplicate findings and assign owner routes with validation methods.
- `required_results`:
  - selected and skipped corpus paths are listed in the audit report;
  - unsafe content is blocked or redacted before broad reporting;
  - every medium/high finding has transcript evidence, category, severity, affected skill/reference, confidence, owner route, and validation method;
  - repeated findings are clustered rather than duplicated;
  - the final report states whether follow-up work should route to `sg-skill-build`, `sg-docs`, `sg-verify`, `sg-spec`, or no action.
- `exception_with_proof`:
  - deterministic classifier can be skipped for an unsafe transcript if the report records the safety reason;
  - parallelization can be skipped if the selected corpus has four or fewer transcripts and manageable word count;
  - manual operator review can be skipped if findings are evidence-backed and no subjective prioritization decision is needed.
- `exception_without_proof`: not allowed for medium/high recommendations; any such recommendation without evidence must be downgraded to non-actionable.
- Automated proof:
  - run deterministic classifier on selected safe transcripts or fixtures;
  - validate audit report metadata;
  - run `rg` checks for required categories, owner routes, and redaction markers;
  - run skill sync/budget checks only if the audit causes skill contract edits in a later phase.
- Agent-run proof:
  - read every selected transcript or assigned batch fully enough to justify findings;
  - produce per-batch notes with file paths and evidence pointers;
  - synthesize duplicates into clusters instead of counting repeated complaints as separate defects.
- Manual proof:
  - optional operator review of the aggregate top findings before starting correction work, especially for subjective severity and prioritization.
- Proof order:
  - corpus inventory;
  - safety filter;
  - per-transcript classification;
  - aggregate synthesis;
  - owner-route mapping;
  - follow-up chantier/skill-build decision.
- Manual checklist: not required for the audit itself unless follow-up implementation changes user-facing workflow behavior.
- Fresh external docs: not needed; this chantier is governed by local ShipGlows contracts and private conversation evidence.

## Dependencies

- `skills/sg-conversation-audit/SKILL.md`
- `tools/shipglows_conversation_audit.py`
- `templates/conversation_audit.md`
- `skills/references/actionable-failure-contract.md`
- `skills/references/decision-quality-contract.md`
- `skills/references/reporting-contract.md`
- `skills/references/question-contract.md`
- `skills/references/spec-driven-development-discipline.md`
- Existing candidate transcripts:
  - `/home/claude/conversation-obstacles-creation-de-notre-set-de-skills.md`
  - `/home/claude/conversation-sg-prod-dernier-run-blacksmith-ci.md`
  - `/home/claude/shipglows/conversation-shipglows-questions-contextuelles-des-skills.md`
  - `/home/claude/shipglows/shipglows_data/workflow/conversations/conversation-sg-build-architecture-skills-20260504.md`

## Invariants

- Conversation transcripts are evidence, not final product requirements.
- A finding is actionable only if it has evidence, affected owner, confidence, and validation route.
- Private transcripts stay private workflow artifacts.
- The audit must not weaken the excellence bar to reduce friction.
- The aggregate report should be concise for the operator and detailed enough for follow-up agents.
- Parallel agents may read different transcript batches, but one lead synthesis must own deduplication and final routing.

## Links & Consequences

- Upstream: real agent conversations, user frustration, existing audit tooling, ShipGlows lifecycle contracts.
- Downstream: aggregate conversation audit report, possible `sg-skill-build` updates, possible docs updates, possible verification gates, possible new specs for multi-skill behavior changes.
- Cross-cutting impacts: privacy, redaction, reporting compactness, skill followability, chantier tracking, model/tool routing, TDD/proof discipline.
- Shipping impact: if this audit produces skill changes later, those changes must pass `skill_budget_audit`, metadata lint, runtime skill sync, and any affected site build.

## Documentation Coherence

- If the audit finds only operational skill gaps, documentation updates may be limited to internal skills/references.
- If the audit changes public skill behavior or discoverability, update:
  - `README.md`
  - `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`
  - `skills/sg-help/references/help-catalog.md`
  - relevant `site/src/content/skills/*.md`
- The audit report itself is private workflow documentation, not public content.
- Language doctrine: internal contracts, report schema, stable categories, validation notes, and section headings stay in English. User-facing final reports and questions stay in the operator's active language, French, with natural accents. Quoted transcript evidence preserves original language and must be labeled as evidence.

## Edge Cases

- A file is a project README with the word "conversation" but not a transcript.
- A transcript contains secrets or private URLs.
- Multiple files contain the same conversation in different locations.
- A complaint reflects a runtime/model limitation rather than a skill gap.
- A skill already contains the correct instruction but agents still fail to follow it.
- A finding points to a global instruction issue rather than one skill.
- The best correction is to improve validation/reporting rather than add another rule.
- The corpus is small enough that parallelization would add coordination overhead.
- The corpus is large enough that one agent cannot read everything reliably.

## Implementation Tasks

- [ ] Task 1: Inventory and filter conversation corpus
  - File: `shipglows_data/workflow/conversation-audits/<date>-batch-agent-excellence-audit.md`
  - Action: Record selected transcript paths, skipped path patterns, corpus size, and safety status.
  - User story link: Ensures the audit is grounded in the right files, not random Markdown noise.
  - Depends on: None
  - Validate with: `find /home/claude -maxdepth 5 -type f -name '*.md'` plus explicit cache/doc exclusion notes in the audit report.
  - Notes: Current initial candidates are the four paths listed in `Dependencies`.

- [ ] Task 2: Run deterministic classification pass
  - File: `tools/shipglows_conversation_audit.py`
  - Action: Run the helper on each selected safe transcript or record why it cannot run safely.
  - User story link: Creates repeatable baseline categories before human synthesis.
  - Depends on: Task 1
  - Validate with: `python3 tools/shipglows_conversation_audit.py <transcript> --fixtures`
  - Notes: Treat classifier output as input evidence, not final judgement.

- [ ] Task 3: Perform transcript review and batch notes
  - File: `shipglows_data/workflow/conversation-audits/<date>-batch-agent-excellence-audit.md`
  - Action: Read selected transcripts and capture evidence-backed findings by category, severity, affected skill/reference, and recommended owner.
  - User story link: Converts real conversation friction into precise improvement work.
  - Depends on: Task 2
  - Validate with: every medium/high finding has a transcript path and short redacted excerpt or line pointer.
  - Notes: If more than four transcripts or roughly 80k words are selected, split into parallel batches.

- [ ] Task 4: Parallelize large corpus review when needed
  - File: `shipglows_data/workflow/conversation-audits/<date>-batch-agent-excellence-audit.md`
  - Action: Assign disjoint transcript batches to subagents, each returning findings in the same schema: file, category, severity, evidence pointer, affected skill/reference, owner route, confidence, validation suggestion.
  - User story link: Allows long audits without sacrificing depth or traceability.
  - Depends on: Task 1
  - Validate with: aggregate report lists each batch owner/result and deduplicates repeated findings.
  - Notes: The lead agent keeps synthesis ownership and does not let parallel notes become the final report unfiltered.

- [ ] Task 5: Synthesize recurring patterns and prioritize fixes
  - File: `shipglows_data/workflow/conversation-audits/<date>-batch-agent-excellence-audit.md`
  - Action: Cluster findings into systemic themes, rank by impact, and map each cluster to an owner route.
  - User story link: Prevents the output from being a passive list of annoyances.
  - Depends on: Tasks 2-4
  - Validate with: each top cluster has evidence count, affected surfaces, recommendation, and next command.
  - Notes: Prefer fewer strong recommendations over many speculative micro-rules.

- [ ] Task 6: Decide follow-up route
  - File: `shipglows_data/workflow/conversation-audits/<date>-batch-agent-excellence-audit.md`
  - Action: For each top cluster, choose `sg-skill-build`, `sg-docs`, `sg-verify`, `sg-spec`, or no action with reason.
  - User story link: Turns audit evidence into corrections that can be implemented and verified.
  - Depends on: Task 5
  - Validate with: no high/medium cluster lacks an owner or proof path.
  - Notes: Multi-skill/global behavior changes should become a spec or skill-build chantier.

## Acceptance Criteria

- [ ] CA 1: Given `/home/claude` contains many Markdown files, when the corpus is selected, then package caches and ordinary project docs are excluded by default.
- [ ] CA 2: Given the known conversation transcripts exist, when the audit inventories the corpus, then the four initial candidate paths are included or explicitly rejected with a safety reason.
- [ ] CA 3: Given a transcript contains unsafe content, when reviewed, then the audit report records a safety hold or redacted evidence instead of copying sensitive content.
- [ ] CA 4: Given a transcript shows an agent reporting instead of acting on a clear fixable failure, when synthesized, then the report maps it to `missed_action` or actionable-failure follow-up.
- [ ] CA 5: Given a transcript shows noisy reporting or internal plumbing in the user thread, when synthesized, then the report maps it to reporting-contract or skill-followability improvements.
- [ ] CA 6: Given a transcript shows weak questions, literalism, or loss of user intent, when synthesized, then the report maps it to question-contract, decision-quality, or owner-skill instructions.
- [ ] CA 7: Given more than four transcripts or a large word count are selected, when planning execution, then the audit splits work into parallel batches with disjoint file ownership.
- [ ] CA 8: Given parallel batch notes exist, when the final report is produced, then duplicate findings are merged and one lead synthesis owns the final recommendations.
- [ ] CA 9: Given a top finding is systemic, when routed, then the recommended next step is an owner skill or new spec, not a vague reminder.
- [ ] CA 10: Given the audit is complete, when `sg-verify` reviews it, then every meaningful recommendation has evidence, severity, affected surface, confidence, and validation route.

## Test Strategy

- Corpus selection:
  - list candidate transcript files and excluded path classes;
  - verify no package-cache documentation is included by default.
- Classifier proof:
  - run `tools/shipglows_conversation_audit.py` on safe selected transcripts or fixtures.
- Review proof:
  - record per-file evidence pointers and redacted excerpts only where safe.
- Synthesis proof:
  - cluster findings by category, affected skill/reference, owner route, and validation method.
- Follow-up proof:
  - for any proposed skill/doc change, run the relevant lifecycle command rather than editing inside this audit spec.

## Risks

- Security risk: high. Conversations may include private project details, paths, logs, credentials, or personal context. Mitigation: safety gate, redaction, private workflow storage, no public transcript publishing.
- Workflow risk: high. A noisy audit can create too many rules and make skills harder to follow. Mitigation: rank recurring patterns, require evidence and validation route, and prefer compact instruction changes.
- Quality risk: medium. Deterministic classification may miss nuanced failures. Mitigation: combine helper output with full transcript review and human synthesis.
- Scope risk: medium. `/home/claude` contains many Markdown files that are not conversations. Mitigation: conservative inclusion rules and explicit skipped patterns.

## Execution Notes

- Read first:
  - `skills/sg-conversation-audit/SKILL.md`
  - `tools/shipglows_conversation_audit.py`
  - `templates/conversation_audit.md`
  - `skills/references/actionable-failure-contract.md`
  - `skills/references/decision-quality-contract.md`
  - `skills/references/reporting-contract.md`
  - `skills/references/question-contract.md`
- Initial corpus command:
  - `find /home/claude -maxdepth 5 -type f -name '*.md' \( -iname '*conversation*' -o -iname '*transcript*' -o -path '*/shipglows_data/workflow/conversations/*' -o -path '*/shipglows_data/workflow/conversations/*' \) -not -path '*/node_modules/*' -not -path '/home/claude/.cargo/*' -not -path '/home/claude/.bun/*' -not -path '/home/claude/.cache/*'`
- Parallelization plan:
  - Batch A: top-level `/home/claude/conversation-*.md`
  - Batch B: ShipGlows repo conversation exports under `/home/claude/shipglows/**/conversation*.md`
  - Batch C: canonical `shipglows_data/workflow/conversations/**/*.md` fixtures/stored transcripts
  - Lead synthesis: merge findings, remove duplicates, assign owner routes, and produce the aggregate report.
- Execution batches:
  - Batch A owns only top-level `/home/claude/conversation-*.md` transcript review notes.
  - Batch B owns only ShipGlows repo conversation exports under `/home/claude/shipglows/**/conversation*.md`.
  - Batch C owns only canonical stored transcripts and fixtures under `shipglows_data/workflow/conversations/**/*.md`.
  - Lead synthesis owns the aggregate report, deduplication, final owner routes, and chantier-potential decisions.
- Suggested aggregate report path:
  - `shipglows_data/workflow/conversation-audits/2026-05-30-batch-agent-excellence-audit.md`
- Stop conditions:
  - unsafe transcript content cannot be redacted safely;
  - corpus selection would include unrelated package docs at scale;
  - findings cannot be tied to evidence;
  - follow-up correction route conflicts with existing dirty user changes.

## Open Questions

None for the spec. The first implementation step can proceed with the conservative corpus rules above and ask only if additional non-conversation Markdown files should be included.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-30 16:33:28 UTC | sg-spec | GPT-5 Codex | Created draft spec for a batch audit of `/home/claude` conversation Markdown files and planned parallelization for large corpus review | draft | /sg-ready ShipGlows Batch Conversation Agent Excellence Audit |
| 2026-05-30 16:43:46 UTC | sg-ready | GPT-5 Codex | Reviewed readiness, tightened dependency metadata, made proof contract mechanical, and validated security/redaction, corpus filtering, language doctrine, and execution batch ownership | ready | /sg-start ShipGlows Batch Conversation Agent Excellence Audit |
| 2026-05-30 16:50:44 UTC | sg-start | gpt-5.3-codex | Executed Batch Conversation Agent Excellence Audit over 4 candidate transcripts, applied safety redaction, synthesized recurring findings, and wrote `shipglows_data/workflow/conversation-audits/2026-05-30-batch-agent-excellence-audit.md` | implemented | /sg-verify ShipGlows Batch Conversation Agent Excellence Audit |
| 2026-05-30 18:58:34 UTC | sg-verify | GPT-5 Codex | Verified the aggregate audit report, reran metadata, classifier, skill-budget, runtime-sync, corpus, redaction, owner-route, and decision-quality checks, and added a coverage addendum for extra candidate paths found during verification | verified | /sg-end ShipGlows Batch Conversation Agent Excellence Audit |
| 2026-05-30 20:21:23 UTC | sg-ship | GPT-5 Codex | Shipped the verified batch conversation excellence audit; separate sg-end was intentionally skipped because `/sg-ship end` performed the closure and shipping step directly | shipped | None |

## Current Chantier Flow

- `sg-spec`: done, draft spec created.
- `sg-ready`: ready, spec validated for implementation.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: skipped by operator request; `/sg-ship end` performed closure and ship.
- `sg-ship`: shipped.

Next step: None
