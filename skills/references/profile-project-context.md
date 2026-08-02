---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-06-28"
updated: "2026-07-12"
status: active
source_skill: 900-shipglows-core
scope: profile-project-context
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/profile-activation.md
  - skills/000-shipglows/SKILL.md
  - skills/302-sg-help/SKILL.md
  - shipglows_data/business/
  - shipglows_data/technical/
  - shipglows_data/editorial/content-map.md
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-06-28: named profiles must load useful project context, not only their role contract."
  - "Operator decision 2026-07-12: technology specialist profiles load canonical platform notes plus the smallest project-local technical context."
next_review: "2026-07-12"
next_step: "/103-sg-verify profile-project-context"
---

# Profile Project Context

## Purpose

This contract defines which project context documents named profiles should load beyond their role contract.

Profiles must not answer from role posture alone. They should ground arbitration in the target project's business, product, editorial, and technical context when those documents exist and the task needs them.

## Core Rule

After resolving a named profile and its operator role:

1. identify the relevant project context layer
2. load the smallest useful project-specific context bundle
3. shape the answer from both the role contract and the loaded project truth

Do not load every project document by default. Load the narrowest coherent bundle for the current question.

## Context Bundles By Profile

### `growth-operations-lead` -> `Victoire`

Default bundle:

- `shipglows_data/business/business.md`
- `shipglows_data/business/product.md`
- `shipglows_data/business/gtm.md`

Load additionally when relevant:

- `shipglows_data/business/project-competitors-and-inspirations.md`
- `shipglows_data/business/affiliate-programs.md`
- `shipglows_data/editorial/content-map.md`

Use this bundle for prioritization, leverage, positioning, growth sequencing, offer, SEO leverage, and distribution tradeoffs.

### `risk-and-coherence-guardian` -> `Prudence`

Default bundle:

- `shipglows_data/business/product.md`
- `shipglows_data/technical/context.md`
- `shipglows_data/technical/code-docs-map.md`

Load additionally when relevant:

- `shipglows_data/business/gtm.md`
- `shipglows_data/technical/guidelines.md`
- `shipglows_data/technical/architecture.md`

Use this bundle for coherence checks, hidden dependencies, scope risk, governance drift, proof weakness, and contradiction surfacing.

### `product-architecture-planner` -> `Ariane`

Default bundle:

- `shipglows_data/business/product.md`
- `shipglows_data/technical/context.md`
- `shipglows_data/technical/architecture.md`

Load additionally when relevant:

- `shipglows_data/business/business.md`
- `shipglows_data/technical/code-docs-map.md`
- `shipglows_data/technical/guidelines.md`
- `shipglows_data/workflow/playbooks/spec-driven-workflow.md`

Use this bundle for phase planning, slice definition, dependency mapping, sequencing, and execution framing.

### `end-user-adhesion-reviewer` -> `Adhesion`

Default bundle:

- `shipglows_data/business/product.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/branding/branding.md`

Load additionally when relevant:

- `shipglows_data/editorial/content-map.md`
- `skills/008-sg-customer/SKILL.md`
- `shipglows_data/business/business.md`

Use this bundle for value perception, trust, comprehension, CTA friction, onboarding friction, and user desire to continue.

### `seo-specialist` -> `SEO Specialist`

Default bundle:

- `shipglows_data/editorial/content-map.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/branding/branding.md`

Load additionally when relevant:

- `shipglows_data/business/product.md`
- `shipglows_data/technical/code-docs-map.md`
- `README.md`

Use this bundle for search intent fit, discoverability, content structure, claim safety, and SEO-related surface coherence.

### `traffic-manager` -> `Tariq`

Default bundle:

- `shipglows_data/business/business.md`
- `shipglows_data/business/gtm.md`
- `shipglows_data/business/product.md`

Load additionally when relevant:

- `shipglows_data/business/affiliate-programs.md`
- `shipglows_data/business/project-competitors-and-inspirations.md`
- `shipglows_data/editorial/content-map.md`
- `README.md`

Use this bundle for acquisition-channel arbitration, source-to-landing fit, tracking readiness, conversion measurement, paid/organic sequencing, affiliate/referral opportunities, and traffic-quality tradeoffs.

### `neovim-specialist` -> `Neovim Specialist`

Default bundle:

- `shipglows_data/technical/external-platforms/neovim.md`
- `/home/claude/dotfiles/nvim/README.md`
- `/home/claude/dotfiles/nvim/FILES.md`

Load additionally when relevant:

- `/home/claude/dotfiles/nvim/MyNeovim/lazy-lock.json`
- `/home/claude/dotfiles/nvim/MyNeovimTermux/`
- `shipglows_data/technical/code-docs-map.md`

Use this bundle for Neovim/Lua configuration, plugin compatibility, LSP/Treesitter setup, headless validation, and workstation-versus-Termux profile decisions.

### Technology specialist profiles

For `python-specialist`, `bash-specialist`, `astro-specialist`, `typescript-specialist`, `javascript-specialist`, `flutter-specialist`, `dart-specialist`, `firebase-specialist`, `convex-specialist`, `vercel-specialist`, `sentry-specialist`, `cloud-integrations-specialist`, `turso-specialist`, and `crewai-specialist`, load:

- the platform note linked by the role contract
- the target project's `shipglows_data/technical/code-docs-map.md` when present
- the smallest relevant project-local usage note under `shipglows_data/technical/platforms/` when present
- the affected dependency/config files needed to establish the actual project version and conventions

Use this bundle for stack-specific implementation, audits, debugging, migration, validation, and freshness decisions. Do not load unrelated platform notes or copy vendor documentation into the answer.

## Missing Context Rule

If one or more context files in the relevant bundle do not exist:

- continue with the existing project truth that is available
- name the missing context only when it materially weakens the answer
- do not invent product, audience, or business truth that the project has not declared

## Cross-Project Rule

When the active repository is not ShipGlows itself, resolve project context from the current project root first.

When the task is explicitly about ShipGlows governance or internal behavior, resolve from `${SHIPGLOWS_ROOT:-$HOME/shipglows}`.

## Maintenance Rule

Update this contract when profile families, role semantics, or project-context loading rules change.
