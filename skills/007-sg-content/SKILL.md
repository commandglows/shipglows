---
name: 007-sg-content
description: "Orchestrate substantive content lifecycles across sources, claims, public surfaces, validation, and ship."
argument-hint: '[goal | source | file | mode: plan, capture, clean-transcript, repurpose, draft, enrich, audit, marketing, seo, editorial, apply, ship]'
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` before ShipGlows-owned files. Project artifacts resolve from the current project root.

## Public Métier, Chantier, And Reporting

Public label: `sg-content`. Trace category: `obligatoire`. Process role: `lifecycle`.

Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md`; own public content from intent through authorized publication. Internal architecture/governance/agent docs belong to `sg-docs`. Attach to one unique spec when present and apply `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`; otherwise do not mutate a spec. Load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md` before the final report. Default to outcome-first `report=user`.

## Explicit Invocation And Scope Gate

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

`007-sg-content` owns substantive content lifecycles and owner coherence, not generic writing or specialist internals. Do not activate it for an explicit atomic string, placeholder, typo, heading-tag, or formatting replacement that needs no content strategy, claim decision, or new surface. Execute that change directly and run the focused surface check.

If intent, source, surface, or public promise is too fuzzy, route `700-sg-explore`; use `100-sg-spec` for non-trivial, multi-surface, new-surface, or claim-sensitive work. Never invent an undeclared public surface.

## Progressive Content Packs

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before ShipGlows-owned tools or editorial/runtime surfaces. Local packs load directly and never chain.

- After atomic short-circuit and explicit preflight, load `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-router.md` to select one lane.
- Explicit `repurpose <source>` additionally loads `$SHIPGLOWS_ROOT/skills/007-sg-content/references/repurpose-playbook.md` directly; `capture`/`tmux`/`capture-full-conversation` load internal `800`, and `clean-transcript <path>` loads internal `801`.
- Once substantive public drafting/audit/apply work is selected, load `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-governance-and-quality.md`.
- Before validation, verification, publication, or ship routing, load `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-delivery-and-proof.md`.

Load at most one local playbook before the first substantive action.

Only after a substantive multi-phase lifecycle is selected, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md` and `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`. Independent read-only evidence may run in parallel; mutations remain sequential unless a ready spec assigns non-overlapping `Execution Batches`.

## Conditional Shared Authorities

- Unsettled pasted source/email/URL/transcript/note/article/example: `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md`.
- Canonical owner choice/handoff: `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md`.
- Public governance/schema/claims: `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` and `$SHIPGLOWS_ROOT/skills/references/public-first-content-default.md` for Diane unless explicitly internal.
- Audit/final draft/final repurpose/enrichment/verification score: `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md`.
- Durable source-faithful memory: `$SHIPGLOWS_ROOT/skills/references/repurpose-pack-storage.md`.
- Current external platform, SEO/AEO, crawler, analytics, framework, SDK, or provider claims: `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md` and official sources.
- Sales/offer CTA, proof, objection, copy-pattern, or inspiration work: `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`; show at most five private-index IDs and require operator selection before detailed records become direction.

## Activation-Critical Claim And Safety Gates

Treat public claims as product promises. Never publish secrets, private URLs/logs, tokens, credentials, keys, sensitive operations, roadmap/speculation as shipped, or stronger security/privacy/compliance/reliability/speed/savings/pricing/outcome claims without evidence. Preserve runtime schemas and unrelated dirty files.

Keep source truth separate from public claims. Declared surfaces beat invented paths. For Diane, public content is the default, but the exact declared surface must still be resolved. `repurpose ... verbatim` remains exact archival preservation, independent from cleanup or analysis.

## Stop Conditions

Stop when source/goal/surface cannot be inferred; a requested surface is undeclared; a required spec is not ready; an owner would be bypassed; claims are blocked, mismatched, or unproven; schema, build, metadata, budget, runtime link, verification, or ship scope fails; fresh external truth is missing; or unrelated dirty files would ship.

## Final Report

Report outcome and proof, selected lane/owner boundary, editorial status, and Fresh Docs Gate verdict. `report=agent` may add source classification, pack storage, handoff, files, validation, or unresolved claim risk. Never expose internal routing in user mode.

## Validation

Run `tools/test_007_sg_content_compaction_contract.py`, repurpose/proportionality/delegation/reporting consumers, metadata, fidelity, budget, and runtime-sync checks.
