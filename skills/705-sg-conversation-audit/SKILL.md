---
name: 705-sg-conversation-audit
description: "Audit ShipGlows conversations into actionable improvements."
argument-hint: "[default|latest|path <file-or-dir>|export shipglows|--trace <rollout.jsonl>|report=agent]"
---

# 705-sg-conversation-audit

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`).

Canonical paths for this skill:

- Input transcripts: `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/`
- Audit output: `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversation-audits/`
- Optional fixtures: `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/fixtures/`

Conversation audits are ShipGlows-owned governance artifacts even when the audited conversation concerns another project. Do not create project-local `shipglows_data/workflow/conversations/` or `shipglows_data/workflow/conversation-audits/` directories for this skill. An explicit `path <file-or-dir>` may read an external transcript as input evidence, but the generated audit report still belongs under `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversation-audits/`.

## Chantier Tracking

Trace category: `conditionnel`.
Process role: `source-de-chantier`.

When attached to a unique chantier spec, append a `Chantier potentiel` block if non-trivial future work is found and no unique chantier owns it.

## Redaction and Safety Gate

- Never publish or ingest private transcripts by default.
- Keep default output under `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversation-audits/` (private governance area).
- Preserve the raw transcript as private evidence, but classify a cleaned conversation view by default.
- If a transcript contains likely secrets/private URLs/log paths/PII tokens, stop with a safety hold.
- Never include full secrets in the report; include only redacted excerpts.
- If safety holds, propose one of:
  - `100-sg-spec`: define a redaction-and-hygiene contract first
  - `300-sg-docs`: if source-surface rules changed
  - `103-sg-verify`: for evidence/process review

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned conversation-audit/runtime surfaces.

## Mission

Audit stored ShipGlows conversation transcripts into private governance reports with evidence-backed findings, safety holds, and owner routes for improvement work.

## Modes

- `default` (implicit): audit most recent file under `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/` with fallback to `latest`.
- `latest`: audit the most recent transcript in the canonical conversation directory.
- `path <file-or-dir>`: audit a specific transcript file or all files in a directory; this can read external input but must not move the audit output out of `$SHIPGLOWS_ROOT`.
- `export shipglows`: run `800-tmux-capture-conversation --preset shipglows` first, then audit the new transcript from `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversations/`.
- `--trace <rollout.jsonl>`: use the explicitly supplied rollout trace to verify delegation receipts and explicit delegation requests. Never auto-discover a trace or infer runtime events from prose.
- `report=agent`: include detailed evidence and route rationale.

## Canonical Workflow

1. Resolve target transcript set:
   - explicit `path` argument,
   - `latest`,
   - or default latest-in-folder.
2. Validate redaction gate before reading raw transcript content.
3. Derive a cleaned classifier input that removes obvious terminal chrome, command output, diffs, JSON payloads, and long log/search noise while preserving user/agent turns.
4. Classify the cleaned view with deterministic categories (below), while keeping raw unsafe detection tied to the original transcript.
5. When `--trace` is supplied, correlate explicitly labelled transcript turn IDs with a complete rollout trace and emit the delegation result as exactly one of `verified`, `finding`, or `unverifiable`.
6. Write report to `$SHIPGLOWS_ROOT/shipglows_data/workflow/conversation-audits/<slug>.md` using template `templates/conversation_audit.md`.
7. Run the ShipGlows Core follow-through gate below before final reporting.
8. Print top findings + evidence summary + routing recommendation + any automatic skill-contract audit result.

## ShipGlows Core Follow-Through Gate

Do not leave skill-contract follow-up as a manual operator action when the local tools are available.

After classifying a conversation, automatically run a ShipGlows skill-contract audit when one or more findings indicate that skills may be unclear, stale, or insufficiently enforceable:

- `missed_action`
- `proof_gap`
- `stale_skill_contract`
- `user_friction`
- `weak_follow_through`
- `missed_delegation`
- `false_agents_receipt`

Preferred route:

```text
$900-shipglows-core audit local ShipGlows skills for the skill-contract gap found in this conversation
```

If the skill is not available in the current session but the local ShipGlows source exists, run the versioned audit tool directly:

```bash
python3 "${SHIPGLOWS_ROOT:-$HOME/shipglows}/tools/audit_shipglows_skills.py"
```

Scope the follow-through to read-only analysis. Do not rewrite ShipGlows skills from this skill unless the operator explicitly asks for an edit pass.

The final report must include one of:

- `shipglows_core_followup: run` with the top audit result or relevant targeted finding,
- `shipglows_core_followup: unavailable` with the missing path or missing skill/tool capability,
- `shipglows_core_followup: skipped` only when no finding category above was present.

When a conversation finding names specific owner skills, map the ShipGlows Core follow-up to those files first, then broaden to all local skills only if the owner skill is ambiguous.

## Stable Finding Categories

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

### Evidence Heuristics

- Findings are evidence-first and deterministic.
- Frictions are valid only when mapped to text evidence, scope impact, and confidence.
- One line of evidence per finding in the report.
- Terminal/diff/search-command matches are classifier noise unless a human review ties them to an actual user or agent turn.
- Reports should mention `cleaned_input_used` or equivalent when the helper script provides it.
- `missed_delegation` and `false_agents_receipt` require an explicit, complete trace with unambiguous turn correlation. Missing, malformed, incomplete, or uncorrelated traces are `unverifiable`, never evidence of compliance or a finding.
- `Agents: <count>` counts unique agents successfully dispatched directly by the orchestrator signing that turn's receipt. Nested agents are excluded from that count.
- Do not conclude that delegation occurred, was missed, or that an agent receipt is truthful from transcript prose alone.

## Categories to Owners

- `missed_action` → `001-sg-build`
- `over_reporting` → `001-sg-build`
- `wrong_owner_route` → `001-sg-build`
- `literalism_over_intent` → `001-sg-build`
- `proof_gap` → `103-sg-verify`
- `stale_skill_contract` → `100-sg-spec`
- `bad_question` → `001-sg-build`
- `user_friction` → `001-sg-build`
- `unsafe_ship_or_dirty_scope` → `100-sg-spec`
- `weak_follow_through` → `001-sg-build`
- `missed_delegation` → `001-sg-build`
- `false_agents_receipt` → `103-sg-verify`

## Owner Handoff

- Route high-confidence skill-contract changes to `001-sg-build` and `100-sg-spec`.
- Route recurring quality-control gaps to `103-sg-verify`.
- Escalate process-risked safety policy issues to `100-sg-spec`.

## Required References

Load:

- `skills/references/decision-quality-contract.md`
- `skills/references/reporting-contract.md`
- `skills/references/actionable-failure-contract.md`
- `skills/references/spec-driven-development-discipline.md`
- `templates/conversation_audit.md`

## Report Modes

Default: `report=user`.
Use `report=agent` for evidence-heavy handoff.

## Stop Condition

Stop and report blocked if:

- no usable transcript is available,
- safety gate blocks raw-content output,
- owner route is ambiguous after a deterministic classification pass.
