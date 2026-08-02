---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-27"
created_at: "2026-06-27 06:39:00 UTC"
updated: "2026-06-27"
updated_at: "2026-06-27 06:39:00 UTC"
status: ready
source_skill: "100-sg-spec"
source_model: "GPT-5 Codex"
scope: skill-maintenance
user_story: "As a ShipGlows user who sends audience email sequences, I want a dedicated emailing skill for multi-step campaigns, so I can produce consistent sequences with clear cadence, audience fit, and measurable outcomes."
owner: "Diane"
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "skills/emailing/SKILL.md"
  - "skills/007-sg-content/SKILL.md"
  - "skills/200-sg-redact/SKILL.md"
  - "skills/202-sg-repurpose/SKILL.md"
  - "skills/206-sg-audit-copy/SKILL.md"
  - "skills/207-sg-audit-copywriting/SKILL.md"
  - "shipglows_data/business/business.md"
  - "shipglows_data/business/product.md"
  - "shipglows_data/business/gtm.md"
  - "shipglows_data/business/affiliate-programs.md"
depends_on:
  - artifact: "skills/references/reporting-contract.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/spec-driven-development-discipline.md"
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "User request 2026-06-27: create a skill called `emailing` for email sequences, not one-to-one mail."
  - "User clarification 2026-06-27: the skill must frame consequences for audience sequences, not individual replies."
  - "Existing skills `007-sg-content`, `200-sg-redact`, `202-sg-repurpose`, `206-sg-audit-copy`, and `207-sg-audit-copywriting` cover adjacent copy/content work but do not own sequence-specific email orchestration."
next_step: "/102-sg-start shipglows_data/workflow/specs/emailing-sequences-audience-skill.md"
---

# Spec: Emailing Sequences Audience Skill

## Status

ready

## User Story

As a ShipGlows user who sends email sequences to an audience, I want a dedicated `emailing` skill that helps me design, write, and review multi-step campaigns, so I can produce consistent sequences with clear cadence, audience fit, and measurable outcomes without treating the work like one-to-one mail.

## Minimal Behavior Contract

The `emailing` skill must own audience-facing email sequence work. It should turn a campaign brief into a sequence plan, subject lines, preview text, message bodies, CTA mapping, segmentation notes, cadence suggestions, and stop/skip rules. It must explicitly exclude one-to-one sales/support replies unless the user asks to adapt a sequence into a direct mail template. It must keep claims grounded in the governed business/product corpus, preserve opt-out and compliance considerations, and state when a sequence needs another owner skill for research, repurposing, copy audit, or product-claim verification.

## Success Behavior

- Preconditions: the user wants audience email sequences, a campaign, a newsletter-like flow, a nurture track, a launch sequence, or a follow-up series.
- Trigger: the operator invokes `emailing` with a brief, source, audience, or draft request.
- User/operator result: the skill returns sequence structure, messaging drafts, and practical consequences for the audience, not generic prose advice.
- System effect: the skill frames each sequence around audience segment, goal, trigger, cadence, proof, CTA, and stop condition.
- Success proof: the output distinguishes sequence work from one-to-one mail and avoids unsupported claims or invented audience data.

## Error Behavior

- Expected failures: missing audience, missing goal, ambiguous trigger, unsupported product claim, illegal or unsafe request, or a request that is actually a personal email rather than a sequence.
- User/operator response: ask one targeted question or route to the right owner skill instead of inventing a sequence.
- System effect: no fabricated segmentation, no invented performance promises, no hidden consent assumptions, and no reuse of a one-to-one tone for campaign work.
- Must never happen: treating audience sequences as generic copy, turning a sequence brief into support mail, or silently accepting an unclear audience when the consequence changes the sequence.

## Problem

ShipGlows has strong adjacent content and copy skills, but none of them owns the operator intent “I need an email sequence for my audience.” Without a dedicated skill, sequence work gets blurred into article drafting or generic copy review, which hides cadence, segmentation, opt-out, and campaign-level decision making.

## Solution

Create a dedicated `emailing` skill that sits between content/copy skills and campaign execution. It should make sequence-specific consequences explicit: who the audience is, why the email goes now, what each step changes, what CTA follows, and when the sequence should stop or branch.

## Scope In

- Design audience email sequences.
- Draft sequence steps, subjects, previews, and body copy.
- Review sequence logic, cadence, and CTA alignment.
- Adapt governed business/product messaging into sequence form.
- Surface compliance, opt-out, and claim risks early.

## Scope Out

- One-to-one email drafting as the default use case.
- Full CRM automation setup or sending infrastructure.
- Spam-bypass, deceptive, or policy-evading tactics.
- Unsupported product promises or invented conversion proof.

## Acceptance Criteria

- The skill body names `emailing` as the owner of audience email sequences.
- The skill body explicitly excludes one-to-one mail by default.
- The skill body routes upstream content, repurposing, and copy audit work to adjacent owner skills.
- The skill body requires audience, goal, and desired action before drafting when those details are missing.
- The skill body keeps sequence structure visible: trigger, audience, objective, cadence, CTA, and stop rule.
- The skill body preserves claim evidence, opt-out, and compliance consequences.
- The skill body remains concise and directive instead of becoming a generic marketing or CRM guide.

## Test Contract

- surface: `skills/emailing/SKILL.md`
- proof_profile: `scenario-first`
- proof_order:
  1. confirm the skill name and description are sequence-first
  2. confirm the scope excludes one-to-one mail by default
  3. confirm the routing rules cover upstream content/copy/audit work
  4. confirm the stop conditions block vague audience or unsupported claims
- required_scenario_ids:
  - `sequence-audience-brief`
  - `sequence-one-to-one-mismatch`
  - `sequence-unsupported-claim`
  - `sequence-upstream-routing`
- required_results:
  - audience sequence brief yields a sequence plan rather than generic prose
  - one-to-one request is rejected or adapted explicitly, not silently accepted
  - unsupported claims surface a risk instead of being invented
  - upstream content/copy requests route to an adjacent owner skill
- exception_with_proof: none
- exception_without_proof: none

## Test Strategy

- Read the skill body and verify the contract lines directly with `rg`.
- Use a fresh-agent reading test: can a new operator tell this is for sequences, not inbox replies?
- Re-run readiness after any later edits that touch routing, scope, or compliance.

## Risks

- Users may still say "email" when they mean a one-off mail, so the skill must keep the sequence distinction explicit.
- The skill could drift into copywriting or content drafting if the routing rules are too soft.
- Claims could become invented if the skill is used without the governed business/product corpus.
- Opt-out and compliance rules could be glossed over if the contract does not keep them visible.

## Execution Notes

- Read first: `skills/007-sg-content/SKILL.md`, `skills/200-sg-redact/SKILL.md`, `skills/202-sg-repurpose/SKILL.md`, `skills/206-sg-audit-copy/SKILL.md`, `skills/207-sg-audit-copywriting/SKILL.md`.
- Keep the skill body English, concise, and activation-oriented.
- Keep user-facing guidance in the active language if later added, but preserve internal contract labels in English.
- Avoid expanding the skill into a general marketing workspace or CRM automation guide.
- Validate with `rg -n "emailing|sequence|one-to-one|audience|cadence|CTA|opt-out|claim" skills/emailing/SKILL.md`.

## Open Questions

None

## Constraints

- Default to audience-sequence framing, not personal correspondence.
- Ask for audience, goal, and desired action when they are missing.
- Preserve claim evidence and product governance when referencing ShipGlows products.
- Route research, repurposing, or copy audits to adjacent owner skills when that is the better first step.
- Keep the skill contract short and directive; detailed playbooks belong in references.

## Dependencies

- `skills/007-sg-content/SKILL.md`
- `skills/200-sg-redact/SKILL.md`
- `skills/202-sg-repurpose/SKILL.md`
- `skills/206-sg-audit-copy/SKILL.md`
- `skills/207-sg-audit-copywriting/SKILL.md`
- `shipglows_data/business/business.md`
- `shipglows_data/business/product.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/business/affiliate-programs.md`

## Invariants

- `emailing` means sequence work for an audience, not one-to-one mail by default.
- Sequence structure must stay visible: trigger, audience, objective, cadence, CTA, and stop rule.
- Claims must stay within the governed corpus.
- If the brief is actually a different content or audit task, route there instead of stretching the skill.

## Links & Consequences

- Consequence for operators: fewer ambiguous “write me an email” handoffs and less manual reshaping of generic copy into sequences.
- Consequence for adjacent skills: content and copy skills remain available as upstream support, but `emailing` owns the sequence-specific output.
- Consequence for governance: sequence claims stay tied to the business/product corpus and cannot drift into invented proof.

## Documentation Coherence

- Add a short discoverability note in the skill body only if needed after implementation.
- Keep adjacent skill docs unchanged unless later verification shows discoverability or overlap drift.
- Do not create a public page unless a later ship decision explicitly requires it.

## Edge Cases

- A user asks for a single follow-up email inside a sequence: keep the sequence frame and mark the step role.
- A user asks for personal outreach: explain the mismatch and either adapt the sequence or route to a different owner.
- A user asks for campaign copy with no audience: ask for audience before drafting.
- A user asks for risky claims: preserve the claim gate and surface the risk instead of softening it silently.

## Implementation Tasks

- [x] Task 1: Create the `emailing` skill contract.
  - File: `skills/emailing/SKILL.md`
  - Action: Add a concise skill body that owns audience email sequences and excludes one-to-one mail by default.
  - User story link: Gives the operator a dedicated entrypoint for sequence work.
  - Depends on: This spec
  - Validate with: `rg -n "emailing|sequence|one-to-one|audience|opt-out|claim|cadence" skills/emailing/SKILL.md`

- [x] Task 2: Keep the skill aligned with adjacent content and copy owners.
  - File: `skills/emailing/SKILL.md`
  - Action: Route supporting work to `007-sg-content`, `200-sg-redact`, `202-sg-repurpose`, `206-sg-audit-copy`, or `207-sg-audit-copywriting` when the brief is upstream or adjacent.
  - User story link: Prevents duplication and keeps the new skill bounded.
  - Depends on: Task 1
  - Validate with: `rg -n "007-sg-content|200-sg-redact|202-sg-repurpose|206-sg-audit-copy|207-sg-audit-copywriting" skills/emailing/SKILL.md`

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-27 06:39:00 UTC | 100-sg-spec | GPT-5 Codex | Created the durable contract for the new `emailing` skill. | ready | `/101-sg-ready shipglows_data/workflow/specs/emailing-sequences-audience-skill.md` |
| 2026-06-27 09:27:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed the spec and found missing readiness sections, so it was not yet ready. | not ready | add acceptance, test, risks, execution notes, and open questions |
| 2026-06-27 11:31:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the `emailing` skill contract for audience email sequences. | implemented | `/103-sg-verify shipglows_data/workflow/specs/emailing-sequences-audience-skill.md` |
| 2026-06-27 09:27:00 UTC | 100-sg-spec | GPT-5 Codex | Completed the readiness repair for the `emailing` spec after `101-sg-ready` identified missing sections. | ready | `/102-sg-start shipglows_data/workflow/specs/emailing-sequences-audience-skill.md` |
| 2026-06-27 11:37:00 UTC | 103-sg-verify | GPT-5 Codex | Verified the `emailing` skill contract, runtime links, and spec coherence for audience email sequences. | verified | `/104-sg-end shipglows_data/workflow/specs/emailing-sequences-audience-skill.md` |
| 2026-06-27 11:40:00 UTC | 104-sg-end | GPT-5 Codex | Closed the chantier after implementation and verification, with no tracker or changelog delta required. | closed | none |

## Current Chantier Flow

```text
100-sg-spec: ready
101-sg-ready: ready
102-sg-start: implemented
103-sg-verify: verified
104-sg-end: closed
005-sg-ship: pending
```

## Current State

- Chantier identified: yes.
- Current spec: `shipglows_data/workflow/specs/emailing-sequences-audience-skill.md`.
- Scope is intentionally sequence-first and audience-first.
- Required next step: none.
