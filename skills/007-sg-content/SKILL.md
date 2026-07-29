---
name: 007-sg-content
description: "Orchestrate substantive content lifecycles across sources, claims, public surfaces, validation, and ship."
argument-hint: '[goal | source | file | mode: plan, capture-full-conversation, clean-transcript, repurpose, draft, enrich, audit, marketing, seo, editorial, apply, ship]'
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlowz-owned file, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipglowz`). ShipGlowz tools, shared references, skill-local `references/*`, templates, workflow docs, internal scripts, and public skill content must resolve from `$SHIPFLOW_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPFLOW_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `007-sg-content` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open with the opening chantier header from `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to any spec. Route to `/700-sg-explore <content idea>` when the content intent, surface, source, or public promise is too fuzzy to frame a ready spec. Route to `/100-sg-spec <content lifecycle title>` when the work is non-trivial, multi-surface, claim-sensitive, or requires a new content surface.

## Report Modes

Before producing the final report, load `$SHIPFLOW_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs file lists, validation matrices, source evidence, or unresolved gate state.

## ShipGlowz-Owned Preflight

Apply `$SHIPFLOW_ROOT/skills/references/shipglowz-owned-preflight.md` before reading ShipGlowz-owned references, running ShipGlowz-owned tools/scripts, or checking ShipGlowz-owned editorial/runtime surfaces.

## Master Delegation

Before choosing execution topology, load `$SHIPFLOW_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference; local nuances below only narrow or route it. Content lifecycle work defaults to delegated sequential when reading, drafting, editing, validating, applying public-content updates, or preparing ship. Parallel content work is allowed only from ready `Execution Batches` with non-overlapping surfaces.

## Master Workflow Lifecycle

Before resolving content phases, load `$SHIPFLOW_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, content work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship routing. Local sections below define content surfaces, owner routes, and public-claim gates only.

## Mission

`007-sg-content` is the master lifecycle for content management. It decides which content lane should run, applies governance gates, and carries content work toward validation and ship routing.

It is the content lifecycle master (`master-workflow`): it decides how source, surface, claim, specialist-owner, validation, and ship work should stay coherent from intake to publishable output.

`007-sg-content` owns content lifecycle coherence across source, surface, claims, quality, and ship, not generic writing detached from governance.

It routes content work to specialist owner skills and keeps the lifecycle coherent.

## Scope Gate

`007-sg-content` routes content lifecycle work. It does not replace specialist owner skills or invent new public surfaces on the fly.

Do not activate it for an explicit atomic string, placeholder, typo, heading-tag, or formatting replacement that needs no content strategy, claim decision, or new surface. Execute that change directly and run the focused surface check.

## Required References

Load before routing or execution:

- `$SHIPFLOW_ROOT/skills/007-sg-content/references/content-router.md` for mode selection, spec gates, governance gates, owner routing, and rubric details.
- `$SHIPFLOW_ROOT/skills/007-sg-content/references/repurpose-playbook.md` only for the explicit `repurpose <source>` lane; it preserves source-faithful, verbatim, storage, safety, and handoff behavior without creating another public command.
- `$SHIPFLOW_ROOT/skills/800-tmux-capture-conversation/SKILL.md` only for `capture-full-conversation`; it is an internal implementation behind the public mode.
- `$SHIPFLOW_ROOT/skills/801-clean-conversation-transcript/SKILL.md` only for `clean-transcript <path>`; it is an internal implementation behind the public mode.
- `$SHIPFLOW_ROOT/skills/references/content-owner-handoffs.md` for the canonical content-owner matrix and minimum handoff payload.
- `$SHIPFLOW_ROOT/skills/references/source-intake-classification.md` when the input is a pasted source, email, URL, transcript, note, article, or example whose project, angle, or owner route is not already settled.
- `$SHIPFLOW_ROOT/skills/references/editorial-content-corpus.md` when public content, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content are in scope.
- `$SHIPFLOW_ROOT/skills/references/content-quality-rubric.md` when mode includes audit, final draft, final repurpose, enrichment validation, or verification handoff with a required quality score.
- `$SHIPFLOW_ROOT/skills/references/public-first-content-default.md` when Diane invokes content work and has not explicitly redirected it toward internal content or `300-sg-docs`.
- `$SHIPFLOW_ROOT/skills/references/repurpose-pack-storage.md` when content work starts from a source and should preserve a durable source-faithful pack in the project repo.

## Inspiration Gate

For sales-page creation, offer-page copy, CTA/proof/objection sequencing, copy-pattern comparison, or explicit inspiration requests, load `$SHIPFLOW_ROOT/skills/references/design-inspiration-library.md`. Filter only the private `index.yaml`, present at most five reference IDs with fit reasons, and require operator selection before loading detailed records or treating references as direction. Pass selected reference IDs to the owner skill and require them in the resulting spec/copy artifact; summarize copy patterns without long verbatim reuse or screenshot redistribution. Market, competitor, pricing, positioning, and differentiation work stays in `shipglowz_data/business/project-competitors-and-inspirations.md`.

## Validation

Run the checks that match changed surfaces.

For ShipGlowz skill or workflow changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPFLOW_ROOT:-$HOME/shipglowz}/tools/shipglowz_sync_skills.sh" --check --skill 007-sg-content
```

For ShipGlowz docs/specs/content-map artifacts:

```bash
python3 tools/shipglowz_metadata_lint.py shipglowz_data/workflow/specs README.md shipglowz_data/workflow/playbooks/spec-driven-workflow.md shipglowz_data/editorial/content-map.md shipglowz_data/business/business.md shipglowz_data/business/product.md shipglowz_data/branding/branding.md shipglowz_data/business/gtm.md shipglowz_data/business/project-competitors-and-inspirations.md shipglowz_data/business/affiliate-programs.md shipglowz_data/technical/context.md shipglowz_data/technical shipglowz_data/editorial shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md
```

For public site or runtime content:

```bash
pnpm --dir shipglowz-site build
```

For public-claim and leak scans:

```bash
rg -n "secret|token|credential|private key|BEGIN .*KEY" README.md shipglowz_data/editorial/content-map.md shipglowz_data site/src skills
rg -n "surface missing: blog|Editorial Update Plan|Claim Impact Plan|Astro content schema|claim register" shipglowz_data/editorial/content-map.md shipglowz_data/editorial skills site/src/content/skills
```

Use `108-sg-browser` when public visual or route behavior needs observed browser evidence. Use `405-sg-prod` only for deployed truth and `109-sg-auth-debug` only for auth/session flows.

## Fresh Docs Gate

When a content task depends on current external framework/runtime/provider behavior, run the Documentation Freshness Gate from `$SHIPFLOW_ROOT/skills/references/documentation-freshness-gate.md`.

Record one explicit verdict:

- `fresh-docs checked`
- `fresh-docs not needed`
- `fresh-docs gap`
- `fresh-docs conflict`

For OpenAI, SDK, framework, SEO/AEO, crawler, analytics, or platform claims, use the relevant official docs or owner skill freshness rules before publishing current claims.

## Security and Abuse Constraints

- Treat public claims as product promises.
- Never publish secrets, private URLs, internal logs, tokens, credentials, private keys, or sensitive operational details.
- Never present roadmap or speculative content as shipped behavior.
- Never strengthen security, privacy, compliance, AI reliability, automation quality, speed, savings, availability, pricing, or business outcome claims without evidence.
- Never add ShipGlowz governance frontmatter to runtime content unless the schema accepts it.
- Never ship with unrelated dirty files unless the user explicitly authorizes wider scope.
- Never create content paths outside the declared surfaces without a spec or explicit surface decision.

## Stop Conditions

Stop and report `blocked` when:

- no source, goal, or surface can be inferred and the user has not answered a targeted question
- a blog/article/newsletter/social/support surface is requested but undeclared
- content strategy or public claims require a spec and readiness is not `ready`
- an owner skill should handle the work and bypassing it would duplicate specialist responsibility
- the claim register marks a claim `blocked`, `needs proof`, or `claim mismatch`
- runtime content schema would be violated
- public site build fails
- metadata lint fails on changed artifacts
- skill budget audit fails hard for skill changes
- runtime skill links are missing, stale, or blocked by non-symlink files
- verification fails
- ship scope includes unrelated dirty files without explicit approval

## Final Report

Follow the shared reporting contract. In addition to its required outcome and proof, identify the selected content lane and owner boundary, editorial status, and Fresh Docs Gate verdict. Use `report=agent` only for source classification, pack-storage decision, owner handoff, validation evidence, or unresolved claim risks that the next owner needs.

## Rules

- Orchestrate; do not duplicate specialist internals.
- Follow shared operator-partnership doctrine. In content work, apply the obvious editorial follow-through that stays inside the current surface and owner contract before asking for framing help.
- For Diane, presume public content by default and arbitrate only the correct declared public surface unless she explicitly asks for internal content or routes through `300-sg-docs`.
- Own `repurpose <source>` as one bounded local mode: load its playbook, keep verbatim requests archival, create only the governed source-faithful pack when safe, then hand downstream work to the established owner.
- Expose `capture-full-conversation` and `clean-transcript <path>` as public modes while keeping `800` and `801` internal-only. Keep `repurpose ... verbatim` exact and independent from cleanup.
- Keep content source truth separate from public claims.
- Prefer declared surfaces over invented paths.
- Ask only targeted questions when the answer changes mode, surface, scope, security, claims, or ship posture.
- Use spec-first for non-trivial or public-claim-sensitive content work.
- Follow the shared master delegation reference for delegated sequential defaults and spec/batch-gated parallelism.
- Preserve runtime schemas.
- Validate before ship routing.
