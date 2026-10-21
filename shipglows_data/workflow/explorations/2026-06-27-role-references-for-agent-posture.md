---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: draft
source_skill: 700-sg-explore
scope: role-references-for-agent-posture
owner: Diane
confidence: medium
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/shipglows-terms.md
  - shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md
  - skills/references/entrypoint-routing.md
  - skills/references/skill-instruction-layering.md
  - skills/references/subagent-roles/
evidence:
  - "Operator idea 2026-06-27: add or integrate precise reference-based roles such as SEO specialist or growth hacker."
  - "ShipGlows already defines focus tags as lightweight recentering cues that do not replace owner-skill routing."
  - "ShipGlows already defines subagent roles for execution topology, but not domain specialist lenses."
depends_on: []
supersedes: []
next_step: "/100-sg-spec role references for agent posture"
---

# Exploration Report: Role References For Agent Posture

## Starting Question

Would it be useful to add precise reference-based roles, for example `%SEO-specialist` or `%growth-hacker`, so skills can stay operational while role/persona/context doctrine moves into references?

## Context Read

- `CLAUDE.md` - local repository constraints and ShipGlows architecture.
- `shipglows_data/technical/context.md` - current skill workflow, focus tag implications, and owner routing model.
- `README.md` - public explanation of skills, focus tags, and distribution.
- `skills/700-sg-explore/SKILL.md` - exploration mode and report threshold.
- `skills/references/canonical-paths.md` - canonical path resolution for ShipGlows-owned references.
- `skills/references/shipglows-terms.md` - current canonical focus tag taxonomy.
- `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md` - public explanation of focus tags.
- `skills/references/entrypoint-routing.md` - routing effects of tags and owner-skill selection.
- `skills/references/subagent-roles/technical-reader.md` - existing read-only execution role pattern.
- `skills/references/subagent-roles/editorial-reader.md` - existing editorial reader role pattern.
- `skills/references/skill-instruction-layering.md` - rule that skill bodies should stay compact and move reusable detail into references.

## Internet Research

- Not used.

## Problem Framing

ShipGlows currently has three related but different mechanisms:

- skills: own outcomes and workflows
- focus tags: recenter the current turn toward a canonical contract
- subagent roles: constrain execution topology and permissions

The proposed `%role` layer would solve a different problem: load a specialist judgment lens without creating a new workflow owner and without bloating existing skills with domain meta-content.

## Option Space

### Option A: Keep Only Skills And Focus Tags

- Summary: Extend the existing `#growth`, `#seo-intent`, `#distribution`, `#partner`, and similar tags.
- Pros: Simple; no new syntax; already documented and routed.
- Cons: Tags mix goals, surfaces, and posture. They are not precise enough for domain-specific judgment such as SEO specialist, growth marketer, pricing strategist, or UX researcher.

### Option B: Add `%role` References

- Summary: Introduce a role reference layer, probably under `skills/references/roles/`, invoked with `%role-name`.
- Pros: Clean separation between operational skill and expert lens. Keeps `SKILL.md` files compact. Allows one role to be reused by content, audit, design, GTM, onboarding, and build flows.
- Cons: Needs a strict boundary so roles do not become hidden skills. Requires routing docs, public cheatsheet updates, and conflict rules with focus tags.

### Option C: Add Domain Specialist Skills

- Summary: Create skills such as `seo-specialist`, `growth-hacker`, or `pricing-strategist`.
- Pros: Easy for users to invoke directly.
- Cons: Likely duplicates audit/content/GTM workflows, increases routing fragmentation, and makes small specialist lenses behave like owner workflows.

## Comparison

`%role` is the best fit if it is explicitly defined as a reference-loaded lens, not an owner route. A role should answer: "what standards and heuristics should the current owner skill apply?" It should not answer: "which workflow owns this task?"

Suggested separation:

| Layer | Syntax | Owns | Example |
| --- | --- | --- | --- |
| Skill | `/007-sg-content` or `007-sg-content` | workflow and artifact outcome | write, audit, repurpose, publish content |
| Focus tag | `#growth` | current priority and canonical contract | optimize for distribution and conversion |
| Role | `%seo-specialist` | specialist judgment lens | evaluate intent, SERP fit, internal links, crawlable structure |

## Emerging Recommendation

Add a reference-based role layer, but keep it small and bounded.

Recommended first contract:

- syntax: `%seo-specialist`, `%growth-strategist`, `%conversion-copywriter`, `%ux-researcher`
- source path: `skills/references/roles/<role>.md`
- behavior: role modifies analysis criteria, questions, risk detection, and validation expectations for the current turn
- non-behavior: role does not change owner skill by itself, does not create artifacts by itself, and does not override security, scope, proof, or canonical-path rules

The most useful first roles are probably:

- `%seo-specialist`
- `%growth-strategist` rather than `%growth-hacker`, because ShipGlows's tone is operator-grade and evidence-backed
- `%conversion-copywriter`
- `%product-strategist`
- `%ux-researcher`

## Non-Decisions

- Exact syntax is not final. `%role` is plausible because it does not collide with `#tags` or `/skills`.
- No final catalog size decided.
- No runtime parser or CLI behavior decided.

## Rejected Paths

- Making every specialist a skill - too much routing fragmentation.
- Expanding `#tags` into detailed persona doctrine - makes tags heavy and muddles their current purpose.
- Putting specialist meta-content inside many `SKILL.md` files - conflicts with the instruction layering contract.

## Risks And Unknowns

- Role/tag overlap: `%seo-specialist` and `#seo-intent` must compose cleanly.
- Role conflicts: `%seo-specialist %conversion-copywriter` may disagree on page structure or copy density; routing docs need a conflict rule.
- Prompt weight: role references must stay short enough to improve judgment without crowding out operational context.
- Public API clarity: users need a compact cheat sheet, or `%roles` become hidden magic.

## Redaction Review

- Reviewed: yes
- Sensitive inputs seen: none
- Redactions applied: none
- Notes: No secrets, tokens, cookies, private keys, customer data, or sensitive logs were read.

## Decision Inputs For Spec

- User story seed: As a ShipGlows operator, I can add `%role` references to a prompt so the current skill applies a specialist lens without changing workflow ownership.
- Scope in seed: role syntax contract, role reference directory, 3-5 initial role references, routing composition rules, docs updates.
- Scope out seed: new lifecycle skills, automatic subagent spawning, large persona libraries, model-specific prompt engineering.
- Invariants/constraints seed: roles do not replace owner-skill routing; roles do not override safety, proof, scope, or canonical path contracts; roles must stay reference-based and compact.
- Validation seed: metadata lint for new docs, focused `rg` checks for role docs and routing references, public cheatsheet update, one or two example prompt simulations.

## Handoff

- Recommended next command: `/100-sg-spec role references for agent posture`
- Why this next step: the concept is useful but touches routing semantics and public documentation, so it deserves a small spec before implementation.

## Exploration Run History

| Date UTC | Prompt/Focus | Action | Result | Next step |
|----------|--------------|--------|--------|-----------|
| 2026-06-27 04:39:09 UTC | `%role` references for SEO/growth-style agent posture | Compared current skills, focus tags, subagent roles, and instruction layering | Recommended a bounded `%role` reference layer rather than new specialist skills | `/100-sg-spec role references for agent posture` |
