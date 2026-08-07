---
name: 202-sg-emailing
description: "Email writing, sequences, accessible templates, deliverability, authentication, and bounded agent operations."
argument-hint: [write | sequence | template | deliverability | provider | audit]
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/shipglows`). ShipGlows-owned tools, shared references, skill-local references, templates, workflow docs, and internal scripts must resolve from `$SHIPGLOWS_ROOT`.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, sequence-first, and in the user's active language. Use `report=agent` only when the user explicitly asks for a detailed handoff, routing evidence, or a fuller audit matrix.

## Mission

`202-sg-emailing` owns the reusable email lifecycle contract: audience and transactional writing, sequences, accessible templates, deliverability/authentication guidance, and bounded agent operations. Product implementation, infrastructure mutation, verification, and release remain with their active métier owners.

## Contract References

- `shipglows_data/business/business.md`
- `shipglows_data/business/product.md`
- `shipglows_data/branding/branding.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/editorial/content-map.md`
- `skills/references/source-intake-classification.md`
- `skills/references/email-sequence-storage.md` when a sequence should be retained in a project repository
- `skills/references/email-work-routing.md` when the task crosses writing, template, delivery, provider, agent, test, or release layers
- `references/accessible-email-writing-playbook.md` before drafting or auditing email content
- `references/accessible-email-technical-playbook.md` when work touches templates, markup, provider setup, rendering, or technical QA
- `references/email-deliverability-and-authentication-playbook.md` when work touches sending domains, SPF, DKIM, DMARC, reputation, compliance, suppression, or delivery operations
- `references/resend-agent-integration-playbook.md` before an agent connects to or operates Resend through a plugin, MCP, CLI, or API

## Scope

- In: sequences, transactional and lifecycle email guidance, nurture tracks, launches, follow-ups, subjects, preview text, CTA mapping, segment-aware messaging, accessible template requirements, deliverability/authentication guidance, provider-operation gates, and email audits.
- Out: one-to-one personal mail by default, inbox support replies, direct ownership of product implementation or infrastructure mutation, spam/evading tactics, and unsupported claims.

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
- Treat accessibility as a drafting constraint: preserve language, direction, semantic structure, descriptive links, image alternatives, contrast, and a usable non-visual reading order through the writing playbook.
- Do not claim an email accessible from automated checks alone; technical email work must use the technical playbook's transformed-markup, manual, client-matrix, and fallback verification.
- Require explicit bounded authorization before an agent sends or schedules mail, mutates recipients or suppressions, changes domains/DNS/webhooks, or rotates credentials.
- When a sequence is durable, store it with the selected project's workflow artifacts; do not turn the private source cache into an email library.

## Stop Conditions

- The request is actually personal mail unless the user asks to adapt it into a sequence.
- The audience or objective is too vague to draft without guessing.
- The sequence would rely on unsupported product or performance claims.
- The request would change public positioning, brand voice, or content surface without first respecting the governed business, branding, GTM, and editorial contracts.

## Validation

Validate this skill after edits with:

```bash
rg -n "202-sg-emailing|one-to-one|sequence|audience|cadence|CTA|opt-out|claim|accessible-email|email-sequence-storage" skills/202-sg-emailing/SKILL.md
python3 tools/shipglows_metadata_lint.py skills/202-sg-emailing/references/*.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --skill 202-sg-emailing
```
