---
name: 007-sg-content
description: "Orchestrate substantive content lifecycles across sources, claims, public surfaces, validation, and ship."
argument-hint: '[goal | source | file | mode: plan, capture, clean-transcript, repurpose, draft, enrich, audit, marketing, seo, editorial, apply, ship]'
---

Primary artifact type: `master-workflow`.

## Canonical Paths

Before resolving any ShipGlows-owned file, load `$SHIPGLOWS_ROOT/skills/references/canonical-paths.md` (`$SHIPGLOWS_ROOT` defaults to `$HOME/.shipglows/runtime`). ShipGlows tools, shared references, skill-local `references/*`, templates, workflow docs, internal scripts, and public skill content must resolve from `$SHIPGLOWS_ROOT`, not from the project repo where the skill is running. Project artifacts and source files still resolve from the current project root unless explicitly stated otherwise.

## Public Métier Ownership

Public label: `sg-content`. Load `$SHIPGLOWS_ROOT/skills/references/intent-to-outcome-autonomy.md` before clarification or editorial routing. Resolve `project -> product -> surface -> feature` and own public documentation/content outcomes through research, creation, validation, application, and authorized publication. Internal architecture, governance, code, context, metadata, and agent docs belong to `sg-docs`.

## Chantier Tracking

Trace category: `obligatoire`.
Process role: `lifecycle`.

Before executing from a spec-first chantier, load `$SHIPGLOWS_ROOT/skills/references/chantier-tracking.md`, read the spec's `Skill Run History` and `Current Chantier Flow`, append a current `007-sg-content` row with result `implemented`, `partial`, `blocked`, or `rerouted`, update `Current Chantier Flow`, and open with the opening chantier header from `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

If no unique chantier spec is identified, do not write to any spec. Route to `/700-sg-explore <content idea>` when the content intent, surface, source, or public promise is too fuzzy to frame a ready spec. Route to `/100-sg-spec <content lifecycle title>` when the work is non-trivial, multi-surface, claim-sensitive, or requires a new content surface.

## Report Modes

Before producing the final report, load `$SHIPGLOWS_ROOT/skills/references/reporting-contract.md`.

Default to `report=user`: concise, outcome-first, and using the opening chantier header. Use `report=agent`, `handoff`, `verbose`, or `full-report` only when another agent needs file lists, validation matrices, source evidence, or unresolved gate state.

## ShipGlows-Owned Preflight

Apply `$SHIPGLOWS_ROOT/skills/references/shipglows-owned-preflight.md` before reading ShipGlows-owned references, running ShipGlows-owned tools/scripts, or checking ShipGlows-owned editorial/runtime surfaces.

## Master Delegation

Before choosing execution topology, load `$SHIPGLOWS_ROOT/skills/references/master-delegation-semantics.md`.

This skill follows that reference. Independent read-only research, source, claim, and surface audits use the selected read-only batch matrix by default. Drafting, editing, publishing, and other mutations stay delegated sequential unless ready write `Execution Batches` assign non-overlapping surfaces.

## Master Workflow Lifecycle

Before resolving content phases, load `$SHIPGLOWS_ROOT/skills/references/master-workflow-lifecycle.md`.

Use the shared skeleton for intake, content work item resolution, readiness, model/topology routing, owner-skill execution, validation, verification, and post-verify ship routing. Local sections below define content surfaces, owner routes, and public-claim gates only.

## Explicit Invocation Preflight

Before parsing an explicit invocation, load `$SHIPGLOWS_ROOT/skills/references/skill-invocation-preflight.md`; invalid or ambiguous preflight never activates this skill.

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

- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/content-router.md` for mode selection, spec gates, governance gates, owner routing, and rubric details.
- `$SHIPGLOWS_ROOT/skills/007-sg-content/references/repurpose-playbook.md` only for the explicit `repurpose <source>` lane; it preserves source-faithful, verbatim, storage, safety, and handoff behavior without creating another public command.
- `$SHIPGLOWS_ROOT/skills/800-tmux-capture-conversation/SKILL.md` only for `capture`, its `tmux` alias, or the legacy `capture-full-conversation` alias; it is an internal implementation behind the public mode.
- `$SHIPGLOWS_ROOT/skills/801-clean-conversation-transcript/SKILL.md` only for `clean-transcript <path>`; it is an internal implementation behind the public mode.
- `$SHIPGLOWS_ROOT/skills/references/content-owner-handoffs.md` for the canonical content-owner matrix and minimum handoff payload.
- `$SHIPGLOWS_ROOT/skills/references/source-intake-classification.md` when the input is a pasted source, email, URL, transcript, note, article, or example whose project, angle, or owner route is not already settled.
- `$SHIPGLOWS_ROOT/skills/references/editorial-content-corpus.md` when public content, README public promises, docs, FAQ, pricing, support copy, public skill pages, blog/article intent, claims, or runtime content are in scope.
- `$SHIPGLOWS_ROOT/skills/references/content-quality-rubric.md` when mode includes audit, final draft, final repurpose, enrichment validation, or verification handoff with a required quality score.
- `$SHIPGLOWS_ROOT/skills/references/public-first-content-default.md` when Diane invokes content work and has not explicitly redirected it toward internal content or `300-sg-docs`.
- `$SHIPGLOWS_ROOT/skills/references/repurpose-pack-storage.md` when content work starts from a source and should preserve a durable source-faithful pack in the project repo.

## Inspiration Gate

For sales-page creation, offer-page copy, CTA/proof/objection sequencing, copy-pattern comparison, or explicit inspiration requests, load `$SHIPGLOWS_ROOT/skills/references/design-inspiration-library.md`. Filter only the private `index.yaml`, present at most five reference IDs with fit reasons, and require operator selection before loading detailed records or treating references as direction. Pass selected reference IDs to the owner skill and require them in the resulting spec/copy artifact; summarize copy patterns without long verbatim reuse or screenshot redistribution. Market, competitor, pricing, positioning, and differentiation work stays in `shipglows_data/business/project-competitors-and-inspirations.md`.

## Validation

Run the checks that match changed surfaces.

For ShipGlows skill or workflow changes:

```bash
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
"${SHIPGLOWS_ROOT:-$HOME/.shipglows/runtime}/tools/shipglows_sync_skills.sh" --check --skill 007-sg-content
```

For ShipGlows docs/specs/content-map artifacts:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs README.md shipglows_data/workflow/playbooks/spec-driven-workflow.md shipglows_data/editorial/content-map.md shipglows_data/business/business.md shipglows_data/business/product.md shipglows_data/branding/branding.md shipglows_data/business/gtm.md shipglows_data/business/project-competitors-and-inspirations.md shipglows_data/business/affiliate-programs.md shipglows_data/technical/context.md shipglows_data/technical shipglows_data/editorial shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md
```

For public site or runtime content:

```bash
pnpm --dir shipglows-site build
```

For public-claim and leak scans:

```bash
rg -n "secret|token|credential|private key|BEGIN .*KEY" README.md shipglows_data/editorial/content-map.md shipglows_data site/src skills
rg -n "surface missing: blog|Editorial Update Plan|Claim Impact Plan|Astro content schema|claim register" shipglows_data/editorial/content-map.md shipglows_data/editorial skills site/src/content/skills
```

Use `108-sg-browser` when public visual or route behavior needs observed browser evidence. Use `405-sg-prod` only for deployed truth and `109-sg-auth-debug` only for auth/session flows.

## Fresh Docs Gate

When a content task depends on current external framework/runtime/provider behavior, run the Documentation Freshness Gate from `$SHIPGLOWS_ROOT/skills/references/documentation-freshness-gate.md`.

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
- Never add ShipGlows governance frontmatter to runtime content unless the schema accepts it.
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
- Expose `capture` and `clean-transcript <path>` as public modes while keeping `800` and `801` internal-only. Accept `tmux` and legacy `capture-full-conversation` as aliases for `capture`. Keep `repurpose ... verbatim` exact and independent from cleanup.
- Keep content source truth separate from public claims.
- Prefer declared surfaces over invented paths.
- Ask only targeted questions when the answer changes mode, surface, scope, security, claims, or ship posture.
- Use spec-first for non-trivial or public-claim-sensitive content work.
- Follow the shared master delegation reference: parallelize independent read-only evidence by default; keep mutations sequential unless ready non-overlapping write `Execution Batches` exist.
- Preserve runtime schemas.
- Validate before ship routing.
