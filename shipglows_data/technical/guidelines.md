---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.9.0"
project: "shipglows"
created: "2026-04-26"
updated: "2026-08-21"
status: reviewed
source_skill: manual
scope: guidelines
owner: "unknown"
confidence: high
risk_level: medium
linked_systems:
  - "cli/shipglows.sh"
  - "cli/lib.sh"
  - "cli/config.sh"
  - "local/"
  - "skills/"
  - "shipglows_data/workflow/playbooks/spec-driven-workflow.md"
  - "templates/"
  - "shipglows_data/technical/"
  - "shipglows_data/technical/design-system-authority.md"
security_impact: yes
docs_impact: yes
evidence:
  - "CLAUDE.md and current repo structure define active shell, workflow, and metadata conventions"
  - "User decision 2026-04-29: standardize ShipGlows internal contracts in English and user-facing interaction in the user's active language."
  - "User decision 2026-05-11: root ShipGlows governance Markdown is not compliant; canonical project artifacts live under shipglows_data/."
  - "User decision 2026-06-11: managed applications need a declared design-system authority before agents customize UI implementation."
  - "User decision 2026-08-02: .shipglows.env is the optional, durable project runtime policy surface; it must remain data-only and closed-schema."
  - "Operator decision 2026-08-21: project delivery posture is declared separately from validation surface; remote Git persistence remains mandatory in development and after every validated milestone."
  - "Operator decision 2026-08-21: Git persistence preflight is silent when healthy and runs only at existing mutating-start, resume, sensitive-operation, and closure boundaries."
depends_on: []
supersedes: []
next_review: "2026-05-26"
next_step: "/sg-docs audit shipglows_data/technical/guidelines.md"
---

# Technical Guidelines

## Scope Of This Document

This file defines stable engineering and documentation rules for working inside ShipGlows. It is not the place for product positioning, system topology walkthroughs, or public messaging.

## Stack

- Bash-first orchestration for CLI and operational flows.
- Flox for runtime isolation.
- PM2 for managed process execution.
- Caddy plus DuckDNS for public exposure.
- Markdown artifacts plus skills for workflow governance.

## Critical Rules

- Invalidate PM2 cache after PM2 state changes.
- Validate project paths before using them.
- Prefer idempotent operations over check-then-act races.
- Do not treat generated runtime config as primary source of truth.
- Treat `.shipglows.env` as optional committed runtime policy, never as an executable dotenv or secret store. Its supported keys are allowlisted; unknown entries must fail loudly.
- Keep project delivery posture in the data-only `ShipGlows Delivery Policy` governance section, not in `.shipglows.env`: maturity, validation surface, and observed provider state are separate axes. Every posture requires milestone and final remote Git persistence; `development` never means local-only.
- Apply the lightweight Git persistence preflight at existing lifecycle boundaries, never before every edit: preserve unrelated dirty work, distinguish local/remote/deployed evidence, and require a remote recovery point before sensitive mutation.
- Keep automatic recovery enabled by default. A project may opt out with `SHIPGLOWS_AUTO_REPAIR=false`; failed restart and crash-loop paths must then show PM2 logs, offer Codex repair, return failure, and never call `env_start` automatically.
- Keep documentation contracts versioned when they guide implementation or audits.
- Keep code-proximate technical docs aligned through `shipglows_data/technical/code-docs-map.md`.
- For UI projects, declare the design-system authority before changing visual implementation.
- Follow the ShipGlows language doctrine: English for internal contracts, the user's active language for user-facing interaction.
- Keep ShipGlows governance artifacts under project-local `shipglows_data/`; root legacy governance files are migration sources only.

## Preferred Patterns

- Use focused context docs instead of overloading one mega-doc.
- Use `shipglows_data/technical/` for durable subsystem details instead of expanding `AGENT.md`, `shipglows_data/technical/context.md`, or `CLAUDE.md`.
- Use specs and verification for non-trivial work.
- Keep doc roles exclusive: route, context, business, product, GTM, architecture, brand, guidelines.
- Prefer explicit stop conditions over silent assumption repair.

## Anti-Patterns

- Silent success or silent failure in user-facing flows unless explicitly justified.
- Business or product claims without evidence.
- Metadata migration that rewrites content body unnecessarily.
- Treating root `BUSINESS.md`, `CONTEXT.md`, `CONTENT_MAP.md`, `GUIDELINES.md`, or similar ShipGlows governance files as compliant final locations.
- Using trackers as if they were decision contracts.
- Parallel edits to shared docs such as `shipglows_data/technical/code-docs-map.md`, `AGENT.md`, `shipglows_data/technical/context.md`, or workflow docs without explicit ready-spec ownership.
- Shipping code changes while mapped technical docs are known stale or missing.
- Changing application UI without a declared design-system authority for tokens, theme, component variants, layout, motion, and mobile constants.

## Validation Expectations

- Technical checks are necessary but not sufficient.
- User-facing success and error behavior should be observable or explicitly justified.
- Docs that affect product understanding must be checked when behavior changes.
- Mapped code changes require a `Documentation Update Plan` or an explicit no-impact justification.

## Change Routing

- Runtime orchestration changes belong first in `cli/lib.sh`, `cli/config.sh`, `cli/shipglows.sh`, or `local/`.
- Workflow and artifact-governance changes belong first in `skills/`, templates, and workflow docs.
- Product, business, GTM, and brand decisions belong in their dedicated contracts before they are repeated elsewhere.
- Layout migration belongs in `sg-docs migrate-layout`; do not create new root governance files as a shortcut.

## Documentation Expectations

- `AGENT.md` routes to the right context.
- `shipglows_data/technical/context.md` maps the repo operationally.
- Specialized context docs stay narrow.
- `shipglows_data/technical/README.md` indexes subsystem technical docs.
- `shipglows_data/technical/code-docs-map.md` maps code paths to primary docs, validation, and docs update triggers.
- Every technical module doc needs owned files, entrypoints, invariants, validation, Reader checklist, and a maintenance rule.
- Business, product, GTM, brand, architecture, and guidelines docs should each keep an exclusive role in their canonical `shipglows_data/` locations.
- `shipglows_data/branding/branding.md` owns visual identity; `shipglows_data/technical/design-system-authority.md` owns the code-level token/theme/component source of truth.

## Technical Docs Maintenance

- `shipglows_data/technical/` is internal-only in v1.
- The Reader produces a `Documentation Update Plan` after every code-changing execution wave and again during end verification.
- The Reader diagnoses docs impact; an executor or integrator applies the docs update.
- Shared files stay sequential by default: `shipglows_data/technical/code-docs-map.md`, `AGENT.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/guidelines.md`, `shipglows_data/workflow/playbooks/spec-driven-workflow.md`, and `tools/shipglows_metadata_lint.py`.
- Parallel technical-doc edits are allowed only when a ready spec defines disjoint file ownership.
- Technical docs may link to architecture, context, specs, and decisions, but must not copy their full content.
- Technical docs do not include per-file `last_verified_against` fields in v1.

## Language Doctrine

- ShipGlows internal contracts use English by default: `SKILL.md` instructions, workflow steps, YAML/frontmatter keys, stable section headings, acceptance criteria, stop conditions, validation notes, and technical documentation.
- User-facing interaction uses the user's active language: questions, short progress updates, final reports, and visible product copy should stay consistent with the language used by the user or configured for the project.
- French user-facing output must use proper accents and natural French. Do not write accentless French unless a technical identifier, command, slug, or ASCII-only file format requires it.
- Stable machine-readable labels stay English even inside otherwise localized content, for example `Status`, `Scope In`, `Acceptance Criteria`, `Skill Run History`, and command names such as `001-sg-build`.
- Do not mix languages casually inside one artifact. If an internal English document needs to show a user prompt, quote the prompt in the user's language and label it clearly.
- Legacy mixed-language artifacts do not require a broad migration. When editing a touched section, move it toward this doctrine without rewriting unrelated history.
- Preserve the original language of quoted user input, source evidence, legal text, or externally sourced material.

## Tracker Boundaries

- Project-local `shipglows_data/workflow/TASKS.md` is the active project task tracker. Legacy `${SHIPGLOWS_DATA_DIR:-$HOME/shipglows_data}` paths are migration evidence only.
- `shipglows_data/workflow/TASKS.md` is the local repo tracker.
- `shipglows_data/workflow/AUDIT_LOG.md` is the local audit index/log.
- Root `TASKS.md` and `AUDIT_LOG.md` are legacy project tracker locations unless an external project tool explicitly requires them.
- A project section inside the master tracker is not the same thing as a local `shipglows_data/workflow/TASKS.md`.
- Local trackers should stay cleaner than the master tracker: active backlog first, optional historical completed context second.
- When creating a local tracker after project history already exists in the master tracker, import active work into the local backlog and move older completed items into a short historical section only if they are useful context.
