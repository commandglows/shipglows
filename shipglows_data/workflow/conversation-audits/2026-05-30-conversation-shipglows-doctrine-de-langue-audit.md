---
artifact: conversation_audit
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-30"
updated: "2026-05-30"
status: draft
source_skill: sg-conversation-audit
scope: export-shipglows
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: no
categories:
  - bad_question
  - weak_follow_through
findings: []
owner_routes:
  - sg-verify
evidence:
  - "shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md"
  - "tools/shipglows_conversation_audit.py"
depends_on: []
supersedes: []
next_step: "none"
---

# Conversation Audit

## Context

- Source transcript: `shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md`
- Audit mode: `export shipglows`
- Audit scope: current tmux pane, captured with `tmux-capture-conversation --preset shipglows --yes`
- Reviewed at: `2026-05-30 20:30:20 UTC`
- Transcript length: `3029` lines

## Redaction / Safety Gate

- Unsafe-content detected: `true`
- Unsafe findings: terminal transcript contains local filesystem paths and command output context.
- Evidence redacted for public report: full transcript and raw path-heavy snippets are not copied here.
- Block reason: no public publication. Private governance storage is acceptable under `shipglows_data/workflow/conversations/` and `shipglows_data/workflow/conversation-audits/`.

## Deterministic Classifier Pass

Command:

```bash
python3 tools/shipglows_conversation_audit.py shipglows_data/workflow/conversations/conversation-shipglows-doctrine-de-langue-20260530-203004.md --fixtures
```

Classifier output:

- `unsafe_detected`: `true`
- `finding_count`: `2`
- categories: `bad_question`, `weak_follow_through`
- owner routes: `sg-build`

## Findings

No actionable agent-behavior finding retained.

| category | severity | title | confidence | evidence | owner | route |
| --- | --- | --- | --- | --- | --- | --- |
| bad_question | low | Classifier false positive on product-decision text inside a diff | high | line 626, repeated around line 852 | none | no action |
| weak_follow_through | low | Classifier false positive on `TODO` inside an `rg` search command | high | lines 741, 891, 935 | none | no action |

## Aggregate Signals

- affected categories: `bad_question`, `weak_follow_through`
- most repeated issue: classifier context sensitivity on terminal transcripts
- owner concentration: no owner route retained after review
- evidence quality: medium for classifier regression insight, low for operational agent defect

## Routing

- recommended_action: `noop`
- recommended_chantier: none
- suggested next command: none

## Notes

- The export path worked.
- The report path worked.
- The current deterministic classifier is sensitive to command text and diffs. This is already an expected limitation from prior audits and does not justify a new chantier by itself.
- If repeated false positives become noisy, route a focused improvement to `sg-verify` or `sg-skill-build` for contextual classifier filtering.

## Next Step

- None for this transcript.
