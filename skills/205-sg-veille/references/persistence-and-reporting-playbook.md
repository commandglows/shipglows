---
artifact: skill_playbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 205-sg-veille
scope: veille-persistence-and-reporting
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/205-sg-veille/SKILL.md
  - skills/references/task-registry-routing.md
  - shipglows_data/workflow/research/
depends_on:
  - artifact: skills/references/task-registry-routing.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Compaction spec: compact-205-sg-veille-as-source-triage-dispatcher.md"
next_step: "/103-sg-verify Compact 205-sg-veille As Source Triage Dispatcher"
---

# Veille Persistence And Reporting Playbook

## Continuation Recognition

A decision reply is a continuation of `triage`, not an `apply` mode. It is valid only if the immediately visible conversation identifies the triaged source, proposed option, project, and decision. Otherwise ask one recovery question to link the choice or relaunch `triage`; do not create hidden session/global state, a watchlist, or a synthetic backlog item.

## Decision Before Writes

Only explicit operator decisions can produce durable derivatives. Before every write, load `task-registry-routing.md` and `operational-record-format.md`, re-read the exact target from disk, locate the current anchor, and make the smallest append/update possible. If the anchor moved, re-read once and recompute; if it remains ambiguous, stop and ask. Never rewrite a tracker, report, or `tools.md` from a stale snapshot.

Route each authorized derivative separately:

| Follow-up | Canonical destination | Boundary |
| --- | --- | --- |
| Technical/implementation action | target project `shipglows_data/workflow/TASKS.md` | only when the project owns the tracker and the decision is technical. |
| Public/editorial action | target project `shipglows_data/editorial/ROADMAP.md` | requires declared surface; content transformation stays a `007-sg-content` handoff. |
| Veille decision report and non-private tool note | target project `shipglows_data/workflow/research/`, or `$SHIPGLOWS_ROOT/shipglows_data/workflow/research/` for portfolio scope | append/update only after decision; no raw private source cache. |
| General tracker housekeeping | `011-sg-pilotage tasks` | do not absorb this owner. |

A mixed technical/editorial decision considers two correct destinations; it never merges the records. Undeclared public content is not written: report the missing surface and route to `007` or `300`.

## Research Notes And Redaction

Use a new dated `veille-YYYY-MM-DD[-N].md` report only when a decision requires an owned, non-sensitive derivative. `tools.md` is append/update-only: find the same URL after re-reading it and minimally update that fiche; otherwise append one. Do not overwrite the file.

Persist only a redacted, justified derivative. Never persist or print tokens, cookies, private source text, PII, sensitive screenshots, raw headers, secret-bearing URLs, or an unredacted external-source cache. Redact sensitive URL parameters before any report, option, or task. Source access failures and marketplace/feedback disagreement stay explicit limits.

## French Report

All operator-facing output and durable report text is natural, accented French. Record actual human decisions, not automatic verdicts: concise source, project/score, relevant axes, evidence limits, decision, action/handoff, and destination. State how many technical records, editorial records, and tool fiches changed only after they changed.

## Chantier And Owner Handoffs

Before final output load `chantier-tracking.md` and `reporting-contract.md`. If no unique chantier owns multi-domain findings requiring a product, content, architecture, or implementation decision, provide the complete `Chantier potentiel` block and route `/100-sg-spec <title>`; do not create a spec. If a unique chantier owns the result, trace only as the shared doctrine permits.

## Scenario Anchors

- `VEILLE-SPLIT-PERSISTENCE`: explicit mixed technical/editorial decision uses separate `TASKS` and `ROADMAP` routes after target re-read/minimal patch.
- `VEILLE-CONTINUATION-NO-HIDDEN-STATE`: an unlinked reply asks for context or restarts triage; no durable state is created.
- `VEILLE-CHANTIER-POTENTIAL`: multi-domain decision produces a complete potential block and `/100-sg-spec` route without touching an ambiguous spec.
