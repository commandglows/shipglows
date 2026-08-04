---
artifact: skill_playbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 205-sg-veille
scope: veille-triage
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/205-sg-veille/SKILL.md
  - skills/references/source-intake-classification.md
  - skills/references/editorial-content-corpus.md
depends_on:
  - artifact: skills/references/source-intake-classification.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Compaction spec: compact-205-sg-veille-as-source-triage-dispatcher.md"
next_step: "/103-sg-verify Compact 205-sg-veille As Source Triage Dispatcher"
---

# Veille Triage Playbook

## Scope

Load this only after `triage` resolves. It classifies external source material, offers a bounded human decision, and routes work; it does not conduct a long cited study, write content, or persist a decision by itself.

## Intake And Context

1. Separate `http`/`https` URLs from pasted text. Fetch URLs or read supplied text only as far as classification needs; record inaccessible or thin evidence as a limit, not a positive signal.
2. Load `source-intake-classification.md`. Use it as the shared first pass for source type, project fit, useful angle, owner route, cache rules, and binding hints. Then load only the business, product, brand, GTM, editorial, or technical governed files that change the selected project or score. Project-local `shipglows_data/` is decision truth; trackers, archives, memory, and root legacy files are not a competing corpus.
3. For more than three URLs, load `master-delegation-semantics.md` before delegated work. Fetches may be parallel only as read-only work; synthesis, questions, decisions, and writes remain sequential.
4. Keep raw/private source material ephemeral or in the shared private-review path when that doctrine permits it. Never place it in the public repo, a spec, a tracker, or a source cache.

## Source Evidence

- For an AppSumo or comparable marketplace listing, inspect three layers when available: offer page for packaging, official site for canonical framing, and founder Q&A or recent reviews for customer demand/objections. Keep disagreements visible.
- For a competitor/product/inspiration affecting demand, roadmap, UX, or positioning, inspect one material feedback surface when available (for example AppSumo, Play Store, Trustpilot, G2, or Capterra). Customer voice is qualitative evidence, not objective proof.
- A pasted ambiguous text can justify a limited freshness lookup only to classify it. A clear multi-source/cited research question belongs to `203-sg-research` with the question and known sources.

## Qualification And Scoring

Do not redo the general classification layer here. Use the shared intake result, then add veille-specific judgment.

Summarize each source in French in three or four lines: what it is, why it may matter, relevant project(s) and axes, then a conservative `/10` score. Assess exactly these four axes:

| Axe | Signal |
| --- | --- |
| Contenu | Inspiration for declared web, social, or education/entertainment content. |
| Architecture | UX, performance, stack, AI, infrastructure, or technical patterns. |
| Concurrence & inspiration | Same audience, market, or problem; product, UX, pricing, or positioning learning. |
| Opportunité collab | Partnership, integration, affiliate, or cross-promotion possibility. |

Score each plausible project honestly; `2/10` is valid. Flag a direct or indirect competitor as `⚔️ CONCURRENT` with its project. Do not select one project arbitrarily when several are justified, and never treat a score as a decision or a write authorization.

## Content And Product Gates

Before proposing an article, newsletter, social post, public docs, public skill page, FAQ, claim, sales surface, product offer, or pricing action, load `editorial-content-corpus.md`. Check the selected project’s declared content map, public surface, product inventory/canonical URL/delivery constraints, and claim proof requirements.

If a required surface is absent, say `surface missing: blog` (or the actual surface), do not create an editorial task, and route to `/007-sg-content repurpose <project> <source> <goal>` or `/300-sg-docs editorial <project>` as appropriate.

## Decision Loop

Load `question-contract.md` before each decision. Process one source at a time and display its name/source, French summary, conservative project table, evidence limits, and up to four source-specific choices. Choice 1 is always `1. Ignorer`; a competitor receives a benchmark option first among the remaining choices. Explain why the choice changes the owner or destination.

Possible choices are precise handoffs or permitted follow-up types, not a promise to execute another owner:

- `203-sg-research`: a clear question needs cited/deeper investigation or benchmark.
- `007-sg-content`: a declared content surface can transform or publish the source.
- `009-sg-marketing`: the operator explicitly asks for a market, GTM, copy, or positioning audit/study.
- `300-sg-docs`: the needed result is documentation or governance change.
- `011-sg-pilotage tasks`: general cleanup/reconciliation of an already-existing tracker.
- An explicit technical or editorial follow-up may be persisted only through the persistence playbook after the operator chooses it.

Continue only after an explicit decision. A source without enough proof, project ownership, or a safe owner route stays ephemeral and is reported as such.

## Scenario Anchors

- `VEILLE-MARKETPLACE-THREE-LAYERS`: marketplace + official site + feedback/Q&A; report divergence.
- `VEILLE-CONTENT-SURFACE-GATE`: undeclared content surface yields `surface missing: blog`, no fictitious task.
- `VEILLE-RAW-NOT-RESEARCH`: a raw competitor signal is triaged/scored, then may hand off to `203`; it is not a long cited synthesis.
- `VEILLE-OWNER-BOUNDARY`: rédaction/publication, audit marketing, docs, and tracker maintenance route to `007`, `009`, `300`, and `309` respectively.
