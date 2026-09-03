---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-09-04"
status: active
source_skill: 900-shipglows-core
scope: vercel-cost-conscious-operations
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-development-mode.md
  - skills/002-sg-maintain/references/maintenance-playbooks.md
  - skills/004-sg-deploy/references/release-confidence-workflow.md
  - skills/405-sg-prod/references/production-verification-workflow.md
  - skills/305-sg-init/references/bootstrap-entrypoint-and-dev-mode.md
  - shipglows_data/technical/external-platforms/vercel.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.3.1"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-04: Pro enables private organization repository deployment but does not justify speed-first or unobserved consumption."
  - "Official Vercel documentation checked 2026-09-04 for Pro, spend management, builds, deployment protection, WAF, observability, analytics, and MCP."
next_review: "2026-10-04"
next_step: none
---

# Vercel Cost-Conscious Operations

## Purpose

Apply this contract when a project declares Vercel as its deployment provider and a decision touches plan capabilities, builds, previews, spend, firewall, observability, analytics, or provider-agent access. Hobby is the portable baseline. Pro is a deliberate capability envelope, not permission to consume credits or require paid features.

## Plan And Capability Truth

- Record `vercel_plan: hobby | pro | enterprise | unknown` as project intent; never infer it from a repository's visibility, organization ownership, URL, local `.vercel` metadata, or one observed deployment.
- A Pro plan may be justified solely by private organization repository deployments. Do not manufacture infrastructure usage to "use" included credit.
- Treat credits and included allocations as ceilings and offsets, not targets. Unused credit is an acceptable economical outcome.
- Recheck official provider documentation before relying on current prices, allocations, limits, defaults, or add-on availability.

## Economical Defaults

Use these defaults unless fresh project evidence documents a stronger need:

- `build_machine_policy: standard-default`; Enhanced or Turbo requires measured build duration, memory, queue, or delivery impact plus an expected cost boundary.
- `build_concurrency_policy: one-per-branch`; unrestricted on-demand concurrency requires demonstrated queue cost to users or releases.
- prioritize production builds only when the project has a production release path; do not accelerate inactive or non-live projects.
- skip unaffected projects and superseded builds where supported; do not trade compute spend for agent convenience.
- paid add-ons remain disabled unless a named product, security, compliance, analytics, or retention outcome justifies their recurring cost.

Never recommend a faster paid build merely because it is available. Compare time saved, frequency, credit impact, and business consequence first.

## Spend Control

Each Pro team should have one reviewed spend posture with an owner, billing-cycle amount, notification channels, and review cadence. Inspect provider usage by project and resource before proposing optimization. Report current usage, trend, projected end-of-cycle spend when available, top contributors, and evidence gaps without copying sensitive logs or billing identifiers.

Spend actions have distinct authority:

- notifications are the safe baseline;
- a webhook may create a redacted internal alert or work item only through its declared receiving-system contract;
- pausing production deployments for every project is a global availability mutation and always requires explicit operator authority;
- resuming, changing the spend amount, or changing billing/add-ons also requires explicit authority.

Never call a configured threshold a hard cap unless provider evidence proves the action and scope. Seats, integrations, and fixed add-ons may sit outside metered-spend controls and must be reported separately when relevant.

## Preview And Access

- Use preview deployments only when hosted behavior is authoritative or collaboration value justifies the build.
- Prefer Vercel Authentication for non-public previews and free Viewer access for appropriate reviewers.
- Automation bypass material is a secret: keep it outside repositories and reports, scope it minimally, and never expose it through screenshots, logs, URLs, or copied commands.
- A protected preview still requires application-level auth, authorization, tenant isolation, and data-safety proof where applicable.

## WAF And Abuse Control

Apply new WAF or rate-limit rules as `log -> review -> enforce -> verify`. Start from concrete traffic or threat evidence, name the protected route and legitimate clients, check false positives, then choose challenge, deny, or rate limit. Provider WAF never substitutes for server-side validation or authorization. Rule publication, disabling, bypasses, IP actions, and production rate limits are security/production mutations and require their normal authority.

## Observability And Analytics

- Use Vercel observability for deployments, builds, traffic, functions, cache, firewall, and provider-cost signals.
- Use application observability such as Sentry for errors, releases, traces, and user-impact evidence when the project contract requires it.
- Enable Web Analytics or Speed Insights only when a named acquisition, conversion, experience, or performance decision will consume the data.
- Upgrade Observability, Analytics, Speed Insights, deployment protection, or another add-on only after a retained-data, metric, security, or workflow limit is observed and the recurring cost is accepted.

## Agent And Tool Boundary

ShipGlows owns intent, authority, sequencing, redaction, and proof. Vercel MCP is the preferred provider-state source when it is discovered and callable in the current agent; Vercel CLI is the explicit operational fallback. Provider skills or machine-readable documentation may improve current implementation knowledge but never replace ShipGlows ownership or grant account mutation authority. Configured, installed, and callable remain distinct states.

## Pressure Scenarios

- `VCC-HOBBY-PORTABLE`: a Hobby project completes through supported local or preview proof without Pro-only requirements.
- `VCC-PRO-PRIVATE-ORG`: Pro is retained for private organization repositories while Standard builds and restrained concurrency remain valid defaults.
- `VCC-CREDIT-NOT-TARGET`: unused credit never triggers discretionary builds, analytics, storage, or add-ons.
- `VCC-TURBO-MEASURED`: Turbo is proposed only with measured pressure, expected benefit, and cost boundary.
- `VCC-SPEND-AUTHORITY`: an alert or webhook never silently becomes a global project pause, billing change, or resume.
- `VCC-WAF-STAGED`: a new production rule cannot skip log/review and false-positive proof.
- `VCC-TOOL-TRUTH`: configured MCP without a callable tool remains unavailable for current-run provider proof.

## Stop Conditions

Stop before an unapproved billing, add-on, permission, environment, domain, firewall, deployment, production, or global-pause mutation; before exposing a token, bypass secret, private URL, raw billing identifier, or sensitive log; or when current provider truth is required but neither a callable MCP/tool nor authorized CLI evidence is available.
