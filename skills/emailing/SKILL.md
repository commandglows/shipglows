---
name: emailing
description: "Plan, draft, route, and audit audience email sequences."
argument-hint: [sequence brief | audience brief | draft | audit]
---

Compatibility alias. Canonical skill name: `sg-emailing`.

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows-owned tools, shared references, skill-local references, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, sequence-first, and in the user's active language. Use `report=agent` only when the user explicitly asks for a detailed handoff, routing evidence, or a fuller audit matrix.

## Mission

`emailing` owns audience email sequences: planning, drafting, reviewing, and routing sequence work with clear audience, cadence, CTA, and claim consequences.

## Contract References

- `shipglows_data/business/business.md`
- `shipglows_data/business/product.md`
- `shipglows_data/branding/branding.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/editorial/content-map.md`
- `skills/references/source-intake-classification.md`
- `skills/references/email-sequence-storage.md` when a sequence should be retained in a project repository

## Scope

- In: multi-step email sequences, nurture tracks, launches, follow-ups, subject lines, preview text, CTA mapping, segment-aware messaging, and sequence audits.
- Out: one-to-one personal mail by default, inbox support replies, spam/evading tactics, sending infrastructure, and unsupported claims.

## Routing

- Use `700-sg-explore` when the audience, goal, or sequence angle is still fuzzy.
- Use `skills/references/source-intake-classification.md` when the user provides an email, URL, article, transcript, or example as inspiration before adapting it into a sequence.
- Use `100-sg-spec` when sequence work needs a durable contract before implementation.
- Route upstream content/source work to `007-sg-content repurpose <source>`, `200-sg-redact`, or `007-sg-content` when the brief is not yet sequence-ready.
- Route tone, clarity, conversion, and persuasion checks to `009-sg-marketing copy` or `009-sg-marketing copywriting` when review is the main ask.

## Core Rules

- Default to audience-sequence framing, not one-to-one correspondence.
- Ask for audience, goal, and desired action when they are missing.
- Keep the sequence structure visible: trigger, audience, objective, cadence, CTA, stop rule.
- Preserve governed business, product, brand, and GTM claims; do not invent proof, urgency, or conversion data.
- Use the editorial content map when a sequence is actually a public content, landing-page, FAQ, or repurposing request.
- When using a source email as inspiration, extract structure, angle, proof pattern, CTA, and sequence role; do not copy distinctive phrasing or unsupported claims.
- Surface opt-out, consent, and compliance consequences when relevant.
- When a sequence is durable, store it with the selected project's workflow artifacts; do not turn the private source cache into an email library.

## Stop Conditions

- The request is actually personal mail unless the user asks to adapt it into a sequence.
- The audience or objective is too vague to draft without guessing.
- The sequence would rely on unsupported product or performance claims.
- The request would change public positioning, brand voice, or content surface without first respecting the governed business, branding, GTM, and editorial contracts.

## Validation

Validate this skill after edits with:

```bash
rg -n "emailing|one-to-one|sequence|audience|cadence|CTA|opt-out|claim|email-sequence-storage" skills/emailing/SKILL.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill emailing
```
