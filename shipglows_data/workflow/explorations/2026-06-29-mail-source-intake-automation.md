---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-07-13"
status: draft
source_skill: 700-sg-explore
scope: mail-source-intake-automation
owner: unknown
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - /home/claude/.shipglows/private/data/mail-source
  - /home/claude/dotfiles/nvim/MyNeovim/lua/shipglows/mail
  - /home/claude/contentglowz/lab/agents/sources/newsletter_extractor.py
  - /home/claude/contentglowz/lab/agents/sources/ingest.py
  - /home/claude/contentglowz/lab/api/services/email_source_service.py
  - /home/claude/contentglowz/lab/api/services/project_generation_context.py
  - skills/references/source-intake-classification.md
  - skills/references/private-memory-store.md
  - skills/emailing/SKILL.md
  - shipglows_data/business/portfolio-project-pitch-links.md
evidence:
  - "Operator request 2026-06-29: use local email corpus as daily source material for project routing and idea validation."
  - "Local mail store observed at /home/claude/Mail with Maildir folders and notmuch index."
  - "mbsync and notmuch are installed; no user systemd timer currently handles mail classification."
  - "Operator request 2026-07-13: compare Mail Intelligence with ContentGlowz email/newsletter capabilities before adding automatic angles and next actions."
  - "ContentGlowz currently performs per-user IMAP ingestion, LLM idea extraction, fixed-project scoring, Idea Pool insertion, and remote archiving, but has no durable one-record-per-email review object."
  - "Seventeen focused ContentGlowz tests covering email-source scheduling, newsletter routes, generation context, memory scoping, and Idea Pool mode passed on 2026-07-13; the extractor itself has no focused test coverage."
depends_on:
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/private-memory-store.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
next_step: "/100-sg-spec shared source analysis contract and adapters"
---

# Exploration Report: Mail Source Intake Automation

## Starting Question

How should ShipGlows process the operator's local email corpus every day, classify emails by probable project and useful angle, and leave the operator with a small validation queue instead of a manual sorting job?

## Context Read

- `CLAUDE.md` - confirmed hidden-cache preference and existing ShipGlows runtime conventions.
- `/home/claude/Mail` - found local Maildir corpus with `competitors/business-a/INBOX`, `_to_transcribe`, and `.notmuch`.
- `/home/claude/.mbsyncrc` - found `mbsync` pull setup for the local mail corpus; secrets were redacted from inspection.
- `/home/claude/.notmuch-config` - found notmuch indexing config and current tag model.
- `skills/references/source-intake-classification.md` - source classification contract already owns project/angle/owner-skill routing.
- `skills/references/private-memory-store.md` - private storage contract already owns reusable source and pitch cache placement.

## Internet Research

- None. Local system inspection was enough for this exploration pass.

## Problem Framing

The operator has an existing email corpus that is useful as source material for projects, content, email sequences, product ideas, competitor insights, and market signals.

The missing layer is not just a new writing skill. It is an operational intake pipeline:

```text
IMAP
  -> mbsync
  -> Maildir under ~/Mail
  -> notmuch index
  -> daily classifier
  -> private review queue
  -> operator validates/modifies
  -> owner skill acts later
```

The output should be proposals, not automatic publication or automatic content generation.

## Option Space

### Option A: Manual Skill Invocation

- Summary: The operator invokes `#source` or `emailing` with copied email content.
- Pros: Low implementation cost, maximum control, minimal privacy risk.
- Cons: Too manual for daily use; does not reduce triage drag enough.

### Option B: Daily Local Classifier

- Summary: A local script syncs mail, indexes notmuch, classifies candidate emails, and writes a private queue for validation.
- Pros: Matches the daily workflow; keeps raw mail local; creates a repeatable validation surface.
- Cons: Needs careful privacy, idempotency, dedupe, and review-state handling.

### Option C: Full Autonomous Agent

- Summary: A scheduled agent reads mail, classifies, drafts outputs, and routes actions automatically.
- Pros: Highest automation.
- Cons: Too risky now: private mail, possible copyright issues, wrong project routing, and no validation gate.

## Comparison

Option B is the right middle layer. It automates discovery and classification without removing the operator's approval step.

The classifier should produce records like:

```text
Source id: <notmuch message id or thread id>
Date:
From domain:
Subject summary:
Probable project:
Useful angle:
Owner skill:
Suggested action:
Confidence:
Risks:
Review state: pending | accepted | edited | rejected | ignored
```

Raw email bodies should stay in Maildir or the private memory store only when explicitly approved.

## Emerging Recommendation

Create a dedicated operational skill or tool layer for daily mail source intake.

Recommended shape:

- `mail-intake` as an internal operational workflow, not a content-writing skill.
- A local script under ShipGlows or a private runtime folder that runs:
  - `mbsync business-a-mail`
  - `notmuch new`
  - a bounded notmuch query for fresh or unreviewed messages
  - source-intake classification against portfolio index and private pitch cache
  - output to `${SHIPGLOWS_PRIVATE_ROOT:-${SHIPGLOWS_PRIVATE_ROOT:-$HOME/.shipglows/private/data}}/mail-intake/queue/`
- A user-facing review command that shows pending proposals and lets the operator accept, edit, reject, or route one.
- A user systemd timer when the manual command is reliable.

## ContentGlowz Comparison (2026-07-13)

ContentGlowz already contains a partial source-analysis engine, but it serves a
different execution policy from Mail Intelligence.

Current ContentGlowz flow:

```text
per-user IMAP settings
  -> managed six-hour scheduler job
  -> full newsletter text extraction
  -> LLM proposes up to five content ideas per email
  -> persona/niche relevance score
  -> one Idea Pool row per proposed idea
  -> archive every fetched email after the batch
```

Useful existing pieces:

- encrypted per-user IMAP credential handling and project-scoped scheduling
- full-text email normalization
- multiple angle extraction and relevance scoring
- Project Intelligence context builder with tenant and token boundaries
- Idea Pool as a downstream content-candidate surface

Important gaps before reuse:

- There is no canonical source record that keeps one reviewed analysis per email.
- The extractor maps model output back to messages by subject and does not retain
  the stable source UID in the persisted Idea Pool metadata.
- Idea Pool bulk insertion has no source-level dedupe key.
- All fetched messages are archived after any non-empty batch result, including
  messages for which no idea was returned.
- The extractor calls the legacy environment-key OpenRouter helper directly
  instead of the request-scoped AI runtime used by current authenticated routes.
- The ingestion prompt uses persona/niche context only; it does not consume the
  richer Project Intelligence generation context already used by newsletter
  generation.
- Focused route and scheduler tests pass, but no focused tests cover extractor
  parsing, source correlation, dedupe, or partial-batch archiving.

Mail Intelligence has the inverse strengths and limits:

- one private review record per source email, with stable local source identity
- portfolio-level project routing and explicit human acceptance
- read-only raw-mail boundary and no automatic downstream content creation
- only one angle/action in the current schema, and structured persistence still
  depends on a provider path that can return machine-readable output

## Shared Boundary Recommendation

Share the analysis contract and pure analysis behavior, not inbox access,
provider credentials, storage, or mutation policy.

```text
                         shared source-analysis contract
                  summary + candidates + angles + actions + risks
                                      |
                    +-----------------+-----------------+
                    |                                   |
          portfolio_review mode              fixed_project_content mode
                    |                                   |
     Maildir/notmuch + private cache       per-user IMAP + Project Intelligence
                    |                                   |
       private Neovim review record              ContentGlowz source record
                    |                                   |
         explicit operator handoff          reviewed ideas -> Idea Pool
```

Recommended normalized input:

- stable source identifier and source type
- bounded source text plus observed metadata
- routing mode: `portfolio_review` or `fixed_project_content`
- optional operator project/angle/action hints
- bounded project, audience, brand, product, GTM, and editorial context
- allowed output types and mutation policy

Recommended normalized output:

- factual summary, separated from inference
- zero or more candidate projects with confidence and reasoning
- zero or more content angles with format, hook, audience fit, and risks
- zero or more next actions with owner skill or ContentGlowz workflow owner
- reusable email pattern fields when relevant: structure, promise logic, proof
  pattern, CTA shape, objection handling, and sequence role
- review status, provenance, model metadata, and schema version

The adapters must remain separate:

- Mail Intelligence owns local source lookup, private queue persistence,
  portfolio routing, Neovim interaction, and the no-remote-mutation rule.
- ContentGlowz owns per-user authentication, IMAP credentials, Project
  Intelligence retrieval, source/idea persistence, and downstream generation.

Do not extract a shared runtime package before both adapters consume the same
versioned JSON contract successfully. First centralize the schema, validation,
prompt policy, and observed-versus-inferred rules. Then extract those pure parts
into a small provider-neutral Python package; keep provider and storage ports
in each host application.

## Recommended Delivery Order

1. Specify `SourceAnalysis` and `SourceEnvelope` as versioned, provider-neutral
   contracts with multiple angles and actions.
2. Extend Mail Intelligence records to display precomputed analysis while
   preserving manual review and the raw-mail boundary.
3. Add a canonical per-email source-analysis record in ContentGlowz, then derive
   Idea Pool candidates from accepted or policy-approved angles.
4. Move ContentGlowz extraction onto its request-scoped AI runtime and Project
   Intelligence context.
5. Add source UID correlation, idempotency, partial-result handling, and explicit
   archive policy before enabling autonomous processing.
6. Extract a shared pure package only after contract parity is proven in both
   adapters.

## Non-Decisions

- Exact LLM provider/model for classification.
- Exact review UI: Markdown queue, terminal menu, TUI, or future ShipGlows App surface.
- Whether to persist full email bodies. Default should be no.
- Whether accepted ideas create specs, backlog items, sequence briefs, or direct owner-skill prompts.
- Final repository and distribution mechanism for a future shared Python package.
- Whether ContentGlowz archives source mail automatically, only after successful
  source-level persistence, or only after operator approval.

## Rejected Paths

- Put email-derived caches in the public ShipGlows repo - rejected because email content is private and may include third-party text.
- Let `emailing` own the whole mail pipeline - rejected because many emails route to research, repurpose, docs, product, or market study instead of email sequences.
- Start with full autonomous writing - rejected because the operator asked for validation/modification of ideas.

## Risks And Unknowns

- Privacy risk: inbox material can contain personal data, order details, private headers, tracking links, or third-party copyrighted content.
- Classification drift: wrong project routing will create noisy proposals unless the portfolio pitch cache is reliable.
- Review fatigue: if the daily queue is too large, the automation becomes another inbox.
- Idempotency: the classifier must not reprocess the same message every run unless the operator asks.
- Storage boundary: raw email bodies should stay outside Git and preferably outside durable source-cache unless approved.
- Scheduling: a timer is useful only after the command is deterministic and has logs/failure handling.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: local mail paths, mbsync/notmuch config shape, email corpus counts, high-level notmuch search metadata
- Redactions applied:
  - `[REDACTED_TOKEN]`
  - `[REDACTED_COOKIE]`
  - `[REDACTED_PRIVATE_KEY]`
  - `[REDACTED_CUSTOMER_DATA]`
  - `[REDACTED_SENSITIVE_LOG]`
- Notes: The report intentionally excludes email bodies, sender details, subject examples, hostnames, usernames, and password material.

## Decision Inputs For Spec

- User story seed: As the operator, I want ShipGlows to scan my local mail corpus daily, classify useful source emails by likely project and angle, and give me a small validation queue so I can accept, edit, or reject ideas before any downstream skill acts.
- Scope in seed: local Maildir/notmuch intake, daily classification, private queue, dedupe state, validation workflow, project/angle/owner-skill suggestions, safe storage policy, optional systemd user timer.
- Scope out seed: automatic publication, automatic email sending, storing credentials, syncing new mail accounts, full inbox UI, deleting or modifying remote mail.
- Invariants/constraints seed: no public repo email cache; raw email body persistence requires approval; classifier must be idempotent; output must be review-first; source-intake and private-memory contracts must govern routing/storage.
- Validation seed: dry-run classification on a small notmuch query; metadata/no-secret audit; idempotent rerun proof; queue record schema check; timer dry-run; failure log review.

## Handoff

- Recommended next command: `/100-sg-spec shared source analysis contract and adapters`
- Why this next step: the local intake and review UI now exist, while the next
  cross-project decision changes persisted schemas, AI runtime boundaries,
  dedupe, and remote mailbox mutation policy.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-06-29 10:20:00 UTC | Daily email source intake automation | Inspected local Maildir/notmuch/mbsync setup and compared manual, daily classifier, and full automation options | Recommend a local daily classifier with private review queue and explicit validation gate | `/100-sg-spec daily mail source intake automation` |
| 2026-07-13 11:40:03 UTC | Compare Mail Intelligence and ContentGlowz email intelligence | Inspected both implementations, current governance contracts, and focused ContentGlowz tests | Recommend one versioned source-analysis contract with separate local-review and fixed-project adapters; do not share ingestion or storage policy | `/100-sg-spec shared source analysis contract and adapters` |
