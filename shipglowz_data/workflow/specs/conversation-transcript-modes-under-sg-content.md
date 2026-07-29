---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlowz
created: "2026-07-29"
updated: "2026-07-29"
status: ready
source_skill: 900-shipglowz-core
scope: public-conversation-transcript-modes
owner: Diane
user_story: "As a ShipGlowz operator, I want one public content entrypoint for full capture, transcript cleaning and exact verbatim preservation without exposing internal transcript skills as standalone public identities."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-router.md
  - skills/800-tmux-capture-conversation/SKILL.md
  - skills/801-clean-conversation-transcript/SKILL.md
  - plugins/shipglowz/assets/pack-catalog.json
  - shipglowz-site/src/content/skills/sg-content.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-07-29: expose capture full conversation and clean transcript as modes while retaining verbatim as a distinct archival mode."
next_step: "/102-sg-start conversation-transcript-modes-under-sg-content"
---

# Spec: Conversation transcript modes under `sg-content`

## User Story

As a ShipGlowz operator, I want one public content entrypoint for full tmux
capture, transcript cleaning and exact verbatim preservation, without exposing
the internal capture/cleanup skills as separate public identities.

## Contract

`sg-content capture-full-conversation` delegates raw tmux export to the
internal capture implementation. `sg-content clean-transcript <path>` delegates
readability cleanup to the internal cleanup implementation. `sg-content
repurpose <source> verbatim` preserves the requested source window exactly and
does not clean, summarize or repurpose it. The three modes remain distinct.

## Acceptance Criteria

- [x] Public `sg-content` documentation exposes the two new modes and retains verbatim under repurpose.
- [x] Routing documentation maps capture and cleanup to the existing internal implementations.
- [x] Public documentation does not present `800` or `801` as standalone user-facing skills.
- [x] Existing repurpose/verbatim contract tests remain valid.
- [x] Focused mode tests prove the three boundaries.

## Current Chantier Flow

- `900-shipglowz-core`: implemented; focused mode verification passed.
- `103-sg-verify`: focused contract verification and public-site build passed.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-29 00:00:00 UTC | 900-shipglowz-core | GPT-5 Codex | Added public transcript modes under `sg-content` while retaining `800`/`801` as internal implementations and preserving verbatim as a separate branch | implemented | Run focused content contract, metadata, budget, and packaging checks |
| 2026-07-29 00:00:00 UTC | 900-shipglowz-core | GPT-5 Codex | Updated internal launch docs and public README, repaired the historical contract-test exclusion, and reran the complete 007 repurpose contract suite | implemented | Resolve the independent Astro dependency issue before claiming a public-site build pass |
| 2026-07-29 00:00:00 UTC | 900-shipglowz-core | GPT-5 Codex | Reinstalled with the declared pnpm 11.15.0 toolchain and verified the public Astro site build (83 pages) | implemented | None for this bounded change |
| 2026-07-29 00:00:00 UTC | 007-sg-content | GPT-5 Codex | Applied the clean-transcript mode to the available captured conversation, removed terminal/tool output, preserved Diane/agent IA turns, and retained the raw source separately | partial | Recover the missing pre-scrollback conversation window from the original conversation source before claiming a complete archive |
