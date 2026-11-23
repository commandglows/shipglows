---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-23"
updated: "2026-11-23"
status: active
source_skill: 900-shipglows-core
scope: product-feedback-triage
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/feedback_triage.py
  - tools/context_history.py
  - shipglows_data/technical/product-feedback-triage.md
  - skills/references/context-history-and-head.md
depends_on:
  - artifact: skills/references/context-history-and-head.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator need 2026-11-23: per-project triage of feedback, requests and votes stored in each product's Convex; agent proposes, operator validates, roadmap follows."
next_review: "2027-01-23"
next_step: none
---

# Product Feedback Triage

Use when the operator asks to read or act on ONE product's feedback, feature
requests or roadmap votes (`@shipglows/feedback-convex`). Never aggregate products.
Commands, discovery and the decision schema: `shipglows_data/technical/product-feedback-triage.md`.

1. In the product repository, run
   `python $SHIPGLOWS_ROOT/tools/feedback_triage.py --project-root <repo> inbox --format text`
   (JSON without `--format`). It reads dev through the declared Doppler scope.
   `--env prd` only when the operator explicitly asks for production.
2. Read the texts yourself; `suggestions` are lexical hints. Propose, per entry, one
   action: approve or merge a request into an item, reject, merge items, link
   feedback to an item or request, mark bug or duplicate, archive, or create a new
   item (bilingual `title`/`summary`, status considering/planned/in_progress).
3. Stop for the operator's explicit validation. Do not apply a proposal she has not
   validated; a changed proposal is validated again.
4. Write the validated decisions to a `shipglows.feedback-triage-decisions/v1` file
   outside the repository (scratch directory) with the inbox `deployment`, run
   `apply --decisions <file>` and show the dry-run plan, then `apply --confirm`.
   Report each `ok`, `error` and `not-run`; never retry a failed moderation blindly.
5. Created items are `visibility: hidden`. Public visibility still goes through
   `context_history.py pending` then `publish --id <item>`, commit and deploy, each
   authorized separately (`context-history-and-head.md`).

Never print or copy feedback authors, account ids, audio URLs or Doppler values into
reports, decision files, roadmap copy or history events. Roadmap copy describes the
product capability, not the person who asked.
