---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-09"
created_at: "2026-06-09 11:09:38 UTC"
updated: "2026-06-09"
updated_at: "2026-06-09 11:09:38 UTC"
status: ready
source_skill: sg-build
source_model: "GPT-5 Codex"
scope: skill-maintenance
owner: Diane
user_story: "En tant qu'operatrice ShipGlows, je veux que sg-conversation-audit classe une vue conversationnelle nettoyee plutot que le bruit tmux brut, afin que les audits detectent les vrais travers agents sans faux positifs issus des commandes, diffs ou logs."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-conversation-audit/SKILL.md
  - skills/clean-conversation-transcript/SKILL.md
  - tools/shipglows_conversation_audit.py
  - shipglows_data/workflow/conversations/
  - shipglows_data/workflow/conversation-audits/
  - shipglows_data/workflow/conversations/fixtures/
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "shipglows_data/workflow/specs/shipglows-conversation-audit-and-auto-evolution-loop.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Run 2026-05-30: sg-conversation-audit export shipglows captured a tmux transcript successfully, but deterministic classification produced false positives from a diff question and an rg TODO search command."
  - "User observation 2026-05-31: terminal/tmux transcript is probably the available history source, but raw command/diff/log noise is the problem."
next_step: "/sg-end sg-conversation-audit cleaned transcript classification"
---

# Spec: sg-conversation-audit cleaned transcript classification

## Title

sg-conversation-audit cleaned transcript classification

## Status

ready

## User Story

En tant qu'opératrice ShipGlows, je veux que `sg-conversation-audit` classe une vue conversationnelle nettoyée plutôt que le bruit tmux brut, afin que les audits détectent les vrais travers agents sans faux positifs issus des commandes, diffs ou logs.

## Minimal Behavior Contract

`sg-conversation-audit` must preserve the raw tmux transcript as private evidence, derive a classifier input that removes or ignores non-conversational terminal blocks, command transcripts, diffs, JSON output, and long logs, then classify only the cleaned conversation text. The report must mention both source paths when a cleaned view is used and must not quote sensitive raw content. The easy edge case is to make the classifier less noisy by suppressing too much: the cleaned pass must still detect real agent-behavior failures from fixture conversations.

## Success Behavior

- Preconditions: a raw tmux/Codex transcript exists under `shipglows_data/workflow/conversations/`, or an explicit path is provided.
- Trigger: the operator runs `$sg-conversation-audit latest`, `$sg-conversation-audit path <file>`, or `$sg-conversation-audit export shipglows`.
- User/operator result: the audit report is based on conversation turns, not shell/diff/log noise.
- System effect: the classifier can produce a cleaned-text view internally or as a private sidecar; it keeps raw transcript references for evidence and safety.
- Success proof: the previously captured transcript `conversation-shipglows-doctrine-de-langue-20260530-203004.md` no longer reports `bad_question` and `weak_follow_through` from diff/search-command noise, while the positive issue fixture still reports `missed_action`, `over_reporting`, `literalism_over_intent`, `bad_question`, and `user_friction`.
- Silent success: not allowed; reports must state whether a cleaned classifier input was used.

## Error Behavior

- Expected failures: missing transcript, unreadable file, cleaned view empty or too small, unsafe raw transcript content, or classifier input ambiguity.
- User/operator response: block only when no usable conversation text remains or redaction cannot be preserved safely.
- System effect: do not overwrite raw transcripts, do not publish raw paths/secrets, and do not turn classifier false positives into owner routes.
- Must never happen: delete private transcript evidence, quote raw secrets/logs in reports, or suppress real user/agent turns just because they mention command-like text.
- Silent failure: not allowed. If cleaning removes all meaningful content, report `blocked` with reason.

## Problem

ShipGlows can only access conversation history reliably through tmux/Codex terminal capture. That source includes assistant commands, diffs, search output, JSON, file paths, and logs. The first real `export shipglows` audit proved the export path works but also showed deterministic classifier false positives from a product-decision sentence inside a diff and `TODO` inside an `rg` command. Without a cleaned classifier input, repeated audits will produce noise and erode trust.

## Solution

Add a conservative transcript-cleaning layer to `tools/shipglows_conversation_audit.py` and wire `sg-conversation-audit` documentation to require classifying cleaned conversation text by default. Keep the raw transcript as evidence. Add regression fixtures that prove command/diff noise is ignored while real behavior failures remain detectable.

## Scope In

- Add cleaned-classification mode to `tools/shipglows_conversation_audit.py`.
- Default the tool to cleaned classifier input while allowing raw mode for diagnostics if useful.
- Add or update fixtures for:
  - noisy tmux transcript false positives;
  - positive conversation failures that must remain detected.
- Update `skills/sg-conversation-audit/SKILL.md` so `export shipglows`, `latest`, and `path` classify the cleaned view.
- Validate metadata and skill runtime visibility if skill text changes.

## Scope Out

- No full replacement of `clean-conversation-transcript`.
- No public publication of cleaned/private transcripts.
- No LLM-based classifier in this pass.
- No broad rewrite of report templates unless needed for the cleaned-input field.
- No ship of unrelated dirty files.

## Constraints

- Raw transcript remains the private source of evidence.
- Cleaning must be conservative: remove obvious terminal/diff/log noise, not operator intent.
- A false positive removed from command/diff text is a success; a real user complaint removed from conversation text is a failure.
- The implementation must stay deterministic and testable.
- Existing dirty worktree changes must not be reverted.

## Test Contract

- `surface`: Python helper, sg-conversation-audit skill contract, private Markdown fixtures.
- `proof_profile`: regression-first plus metadata/static validation.
- `proof_order`:
  1. reproduce noisy transcript classification;
  2. implement cleaned classifier input;
  3. verify noisy transcript produces no false-positive findings;
  4. verify positive fixture still produces expected categories;
  5. metadata lint and focused rg checks;
  6. skill budget/sync if skill contract changes.
- `checklist_path`: none; no manual operator checklist is required for this deterministic workflow change.
- `required_scenario_ids`:
  - `NOISY-TMUX-DIFF`: diff lines and `rg` commands must not create `bad_question` or `weak_follow_through`.
  - `POSITIVE-FAILURES`: real conversation failure fixture must still produce known categories.
  - `RAW-SAFETY`: unsafe raw transcript flag remains visible even when cleaned classification is used.
  - `EMPTY-CLEANED`: if cleaned text is empty, the tool must not claim a clean audit silently.
- `required_results`:
  - The noisy transcript from the 2026-05-30 run returns zero retained categories in default cleaned mode.
  - The positive fixture still returns `missed_action`, `over_reporting`, `literalism_over_intent`, `bad_question`, and `user_friction`.
  - The tool output exposes whether cleaned input was used.
  - `sg-conversation-audit` documentation tells agents to classify the cleaned view while preserving raw evidence.
- `exception_with_proof`:
  - A sidecar cleaned file is optional if the tool can keep the cleaned view internal and report `cleaned_input_used`.
  - Full content cleanup via `clean-conversation-transcript` is not required if deterministic filtering is sufficient for classifier input.
- `exception_without_proof`: not allowed for classifier behavior changes.
- Fresh external docs: not needed; this is local Python/Markdown/skill behavior.

## Dependencies

- `tools/shipglows_conversation_audit.py`
- `skills/sg-conversation-audit/SKILL.md`
- `skills/clean-conversation-transcript/SKILL.md`
- `shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md` if present
- `shipglows_data/workflow/conversations/fixtures/conversation-audit-sample-issues.md`

## Invariants

- Raw transcript evidence is preserved.
- Reports stay private by default.
- Deterministic fixtures must remain stable.
- Owner routing happens only after evidence review, not from noisy classifier matches alone.

## Links & Consequences

- Upstream: tmux capture, raw terminal transcript structure, existing fixtures.
- Downstream: fewer noisy conversation-audit reports and clearer owner routes.
- Security: raw unsafe flag and redaction behavior stay visible.
- Documentation: skill contract must describe cleaned classification.

## Documentation Coherence

- Update `skills/sg-conversation-audit/SKILL.md`.
- Public docs are optional; no public promise changes beyond existing skill page unless implementation changes invocation syntax.
- Changelog/TASKS updates are deferred to `sg-end`/`sg-ship`.

## Edge Cases

- A user message includes code, command names, or `TODO` as real intent.
- A diff contains real user complaints copied from a transcript.
- A JSON report contains classifier categories from a previous audit.
- A transcript has only command output and no usable conversation turns.
- A raw transcript is unsafe but cleaned text appears safe.

## Implementation Tasks

- [ ] Task 1: Add cleaned classifier input
  - File: `tools/shipglows_conversation_audit.py`
  - Action: strip fenced raw transcript wrappers, diff lines, box/status chrome, command-output lines, JSON blocks, and common shell/search output before category matching.
  - Validate with: noisy transcript and positive fixture.

- [ ] Task 2: Expose cleaned-mode metadata
  - File: `tools/shipglows_conversation_audit.py`
  - Action: include `cleaned_input_used`, `raw_line_count`, and `cleaned_line_count` in fixture JSON output.
  - Validate with: `python3 tools/shipglows_conversation_audit.py <file> --fixtures`.

- [ ] Task 3: Add regression fixture
  - File: `shipglows_data/workflow/conversations/fixtures/conversation-audit-sample-noisy-terminal.md`
  - Action: create a small sanitized fixture containing an `rg` TODO command and diff question that must not classify as agent behavior.
  - Validate with: default cleaned classifier returns zero findings.

- [ ] Task 4: Update skill contract
  - File: `skills/sg-conversation-audit/SKILL.md`
  - Action: document that all modes classify a cleaned conversation view and preserve raw transcript evidence.
  - Validate with: focused `rg`.

## Acceptance Criteria

- [ ] AC 1: Given a noisy tmux transcript with diff/search noise, when classified in default mode, then command/diff lines do not produce `bad_question` or `weak_follow_through`.
- [ ] AC 2: Given the existing positive fixture, when classified in default mode, then real behavior categories remain detected.
- [ ] AC 3: Given an unsafe raw transcript, when cleaned classification runs, then `unsafe_detected` still reflects the raw source.
- [ ] AC 4: Given `sg-conversation-audit export shipglows`, when the report is produced, then the skill contract says the classifier works from a cleaned view and the raw transcript remains private evidence.
- [ ] AC 5: Given the cleaned view is empty, when classification runs, then the tool reports this state instead of silently treating the transcript as clean.

## Test Strategy

- Regression fixture command:
  - `python3 tools/shipglows_conversation_audit.py shipglows_data/workflow/conversations/fixtures/conversation-audit-sample-noisy-terminal.md --fixtures`
- Positive fixture command:
  - `python3 tools/shipglows_conversation_audit.py shipglows_data/workflow/conversations/fixtures/conversation-audit-sample-issues.md --fixtures`
- Real captured transcript command when present:
  - `python3 tools/shipglows_conversation_audit.py shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md --fixtures`
- Static checks:
  - `python3 -m py_compile tools/shipglows_conversation_audit.py`
  - `python3 tools/shipglows_metadata_lint.py <changed markdown artifacts>`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`
  - `tools/shipglows_sync_skills.sh --check --all`

## Risks

- Security risk: medium. Raw transcripts may contain private paths or sensitive context. Mitigation: raw unsafe detection remains independent of cleaned classifier input.
- Quality risk: medium. Over-aggressive cleaning could hide real failures. Mitigation: positive fixture regression and conservative line filtering.
- Workflow risk: low. The invocation surface stays stable.

## Execution Notes

- Proof path: `regression-first`.
- Development mode: local; no hosted/browser runtime proof needed.
- Model routing: current main-thread model is acceptable for bounded local Python/Markdown changes; no subagent was explicitly requested.
- Fresh external docs: not needed.
- Dirty scope: preserve existing unrelated dirty files.

## Open Questions

None. The responsible default is to classify a cleaned conversation view while preserving raw private evidence.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-09 11:09:38 UTC | sg-build | GPT-5 Codex | Created ready spec for cleaned transcript classification after real export/audit false positives | ready | /sg-start sg-conversation-audit cleaned transcript classification |
| 2026-06-09 11:09:38 UTC | sg-start | GPT-5 Codex | Implemented cleaned classifier input, raw-mode diagnostics, cleaned-mode metadata, noisy terminal regression fixtures, and sg-conversation-audit contract wording | implemented | /sg-verify sg-conversation-audit cleaned transcript classification |
| 2026-06-09 11:09:38 UTC | sg-verify | GPT-5 Codex | Verified regression-first proof: raw noisy fixture still reproduces false positives, cleaned noisy fixture has zero findings, positive fixture keeps five expected findings, real captured transcript has zero findings with raw unsafe flag preserved, Python compile passes, metadata lint passes, skill budget passes, and runtime skill sync passes | verified | /sg-end sg-conversation-audit cleaned transcript classification |

## Current Chantier Flow

- `sg-spec`: ready, created by sg-build from the observed false-positive audit.
- `sg-ready`: ready by direct mechanical inspection; no open questions.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: next.
- `sg-ship`: not launched.

Next step: `/sg-end sg-conversation-audit cleaned transcript classification`
