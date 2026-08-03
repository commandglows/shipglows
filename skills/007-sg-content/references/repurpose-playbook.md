---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 007-sg-content
scope: content-repurpose-mode
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-router.md
  - skills/references/source-faithful-pack-contract.md
  - skills/references/repurpose-pack-storage.md
depends_on:
  - artifact: "skills/references/source-faithful-pack-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/repurpose-pack-storage.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Migrated source-specific repurpose procedure from the retired 202 owner into the bounded 007 repurpose mode."
next_step: "/103-sg-verify consolidate repurpose mode under sg-content"
---

# Repurpose Playbook

## Purpose

This is the bounded `007-sg-content repurpose <source>` lane. It turns safe, usable source material into a source-faithful pack and explicit downstream handoffs; it does not draft, apply, audit, publish, verify, or ship downstream content itself.

Load the shared `source-faithful-pack-contract.md`, `source-intake-classification.md`, `repurpose-pack-storage.md`, `content-quality-rubric.md`, `content-owner-handoffs.md`, public-first, and editorial contracts named by the `007` activation when their gates apply. They remain authoritative for pack schema, classification, persistence, scoring, owner selection, public placement, and claims.

## Mode Contract

- Parse `repurpose <source> [focus]`; a bare `repurpose` asks for a source and never reuses a previous one.
- `verbatim`, `mot pour mot`, or `copie exacte` takes precedence over analysis. Preserve the requested available conversation window in chronological order, speaker boundaries, Markdown, links, punctuation, and line breaks exactly. With no count, capture the immediately preceding assistant response; with `verbatim N`, capture the preceding N messages excluding the command. If fewer messages are available, preserve the contiguous available window and state the exact count. Add only speaker/ordinal labels and a minimal archival wrapper outside the preserved block.
- Verbatim is archival, not a pack shortcut: no analysis, summary, classification, translation, rewrite, inferred content strategy, or handoff matrix may enter the preserved block. Persist it only when the storage contract permits it, using `YYYY-MM-DD-verbatim-<short-slug>.md` under the governed project's repurpose-pack path.
- An explicit source takes precedence over a mode-like first word in that source payload. `repurpose` selects this playbook once; it never dispatches to a second public repurpose skill.
- Use `doc`, `marketing`, `full`, surface names, `apply`, `write`, `update`, `publish`, `faq`, `release notes`, `newsletter`, `thread`, `post`, `article`, or `outline` only as pack focus. They never authorize downstream edits.

## Safe Intake And Boundaries

1. Classify an unsettled source before reconstructing its truth. Resolve project, audience, intended surface, owner, copyright/consent posture, and claim risk through the shared intake contract.
2. Before any source reconstruction, durable write, report detail, fixture, diagnostic, or public output, stop safely for secret-bearing, private, unavailable, wrong-repository, or too-thin material. Do not copy source values into a repository, log, migration matrix, fixture, fallback location, or public surface.
3. Treat the source as evidence. Separate confirmed conversation/code facts, inference, and material that is not safe to publish. Do not turn roadmap, implementation detail, third-party framing, speculative positioning, or unproven security/privacy/reliability/AI/speed/savings/scale claims into product truth.
4. For a URL, fetch only when explicitly requested; treat fetched material as external source rather than product truth. For a build conversation, use relevant diffs or docs only to confirm what the conversation establishes.
5. Respect declared maps, claim register, page intent, Astro schema, blog policy, business registries, and public-first defaults. A missing declared surface remains `surface missing: blog`; never invent a path.

## Source-Faithful Pack Workflow

### 1. Reconstruct truth

- Build conversations: problem, user pain, approach, alternatives/tradeoffs, observable outcome, limits, and follow-up.
- Supplied text: core idea, thesis, implied audience, useful framing, reusable material, and generic, derivative, risky, or unsupported statements.
- Choose the smallest source mode: supplied source, supplied article, or workstream conversation. If no usable source remains, ask one focused source question.

### 2. Choose only justified outputs

- Produce internal documentation material for behavioral, setup, workflow, API, UX, constraint, edge-case, or operational signal.
- Produce public marketing material only for supported user benefit, removed friction, meaningful simplification, differentiating workflow, or well-evidenced build story.
- Reduce or omit a weak lane; never add generic filler.
- Grade each recommended surface as `must write`, `should write`, `optional`, or `do not write`. For the first two, include a precise owner handoff unless the surface is missing, unsafe, or intentionally deferred.

### 3. Inspect existing placement

Unless the user asked only for titles, include `Existing Content Opportunities` for both internal docs and public content. For each, name the surface, placement idea, audience learning moment, source proof, content move, priority, and exact owner. Prefer small, high-leverage insertions over an invented article.

Read-only parallel analysis may inspect non-overlapping internal and public surface sets when the lifecycle topology permits it. It must never edit, stage, commit, push, mutate trackers, or create runtime content; the `007` context integrates the findings.

### 4. Plan diffusion and hand off

For a site-facing or SEO-relevant idea, include a compact diffusion map: canonical surface, supporting surfaces, repeated concept, per-surface job, and intentionally skipped surfaces. Repetition changes job by surface; it does not duplicate one paragraph everywhere.

The pack is the deliverable. Route subsequent work through the shared owner matrix: `300-sg-docs` for governed docs, `200-sg-redact` for new long-form writing, `201-sg-enrich` for existing surfaces, `009-sg-marketing` or `406-sg-seo` for the named review, `203-sg-research`/`205-sg-veille` for evidence needs, `202-sg-emailing` for sequences, then verification and ship owners when applicable. Every handoff includes target, source truth and proof, intended move, claim limits, priority, and context.

### 5. Build and persist the pack

Use `source-faithful-pack-contract.md` in its canonical order. Keep `Best Next Actions` to three-to-five concrete actions when justified; separate documentation notes, marketing claims, and evidence. The pack must let a downstream owner act without rediscovering source truth.

Persist only when the source is safe, substantive, and belongs to the current governed project, and the operator did not request ephemeral output. Use the shared canonical path, filename, frontmatter, and same-source refresh rule. Otherwise report only `ephemeral only`, `unsafe to store`, `wrong repo`, or `signal too weak`; never use a fallback storage location.

### 6. Safety pass

- Downgrade unstated assumptions to hypotheses and separate implementation detail from public value.
- Keep copyright-safe transformation: extract structure, angle, summaries, outlines, FAQ ideas, and hooks rather than near-paraphrasing third-party text.
- Confirm every `must write` / `should write` outcome is handed to its owner, explicitly deferred, or blocked by a stated safe limit.
- If asked to apply, write, update, publish, or ship, report the bounded pack and owner handoffs without claiming downstream files changed.

## Pack Narrowing

The shared pack contract is canonical. This lane adds only these constraints:

- `Diffusion Map` is mandatory for site-facing or SEO-relevant sources.
- `Handoff Checklist` is mandatory for apply/create/update/fill requests.
- `Supporting Source Notes` stays an appendix unless detailed evidence is requested.
- A declared blog/article absence keeps any useful ideas labelled `surface missing: blog`; it never creates a route.

## Stop Conditions

Stop with the visible safe outcome when a required reference/playbook is missing, source safety or claim constraints would weaken, a governed destination is unavailable, a surface is undeclared, or a request would bypass a downstream owner. Do not create a chantier unless the user explicitly requests formalization.
