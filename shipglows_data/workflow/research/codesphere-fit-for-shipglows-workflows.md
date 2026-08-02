---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-07-04"
updated: "2026-07-04"
status: reviewed
source_skill: 203-sg-research
scope: "Codesphere fit for ShipGlows workflows"
owner: "Codex"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
source_count: 8
evidence:
  - "https://www.codesphere.com/"
  - "https://docs.codesphere.com/intro"
  - "https://docs.codesphere.com/core-concepts/landscapes-and-workspaces"
  - "https://docs.codesphere.com/workspace-toolkit/ci-and-deploy/configuring-a-landscape"
  - "https://docs.codesphere.com/workspace-toolkit/monitor/log-browser"
  - "https://docs.codesphere.com/category/automations"
  - "https://docs.codesphere.com/next/apis-and-automations/public-api"
depends_on: []
supersedes: []
  - "https://www.codesphere.com/remote-development"
next_step: "/204-sg-market-study compare Codesphere vs Railway/Render/Fly.io for ShipGlows-target workflows"
---

# Research: Codesphere fit for ShipGlows workflows

> Generated 2026-07-04 - Sources: 8

## Executive Summary

Codesphere looks strong when the goal is to standardize cloud development, preview environments, deployment, managed services, and observability inside one platform. It does **not** replace ShipGlows's core value: context routing, spec-first execution, verification discipline, and agent handoff quality.

For ShipGlows, the best reading is: **possible infrastructure target for some app projects, not a foundation replacement for ShipGlows itself**. Recommendation: do not pivot ShipGlows around Codesphere; if the platform is interesting, run a narrow pilot on one multi-service app where preview deployments, managed services, or self-hosted sovereignty matter.

## Why it matters for ShipGlows

ShipGlows's core promise is reduced ambiguity, better agent handoffs, and stronger execution contracts for solo founders and small technical teams. Codesphere's promise is different: a unified cloud platform for development, deployment, and operations across hosted or self-hosted infrastructure. That means there is overlap on runtime and delivery workflows, but not on the governance layer that makes ShipGlows distinct.

## Current product shape

Based on Codesphere's current public site and docs as of **2026-07-04**, the platform presents itself as a "virtual cloud platform" and "self-hostable cloud provider" with a declarative `ci.yml`-driven model called a **Landscape** plus attached **Workspaces** for day-to-day development and operations.

Key current capabilities:

- Unified dev/deploy/ops model around `ci.yml` Landscapes and Workspace cockpits.
- Built-in cloud IDE plus local IDE connectivity over SSH or remote tunnels.
- Built-in CI/CD stages and preview-deployment automation for GitHub, GitLab, and Bitbucket.
- Managed services and reproducible environment provisioning from configuration.
- Built-in monitoring, logs, and request tracing.
- Public API and CLI surface for automation.
- Strong self-hosted / private-cloud / sovereignty positioning.

## Workflow fit against ShipGlows

## Good fit

- **Preview and review environments**: Codesphere documents automated PR preview workspaces, which maps well to app projects needing live review before merge.
- **Multi-service app environments**: the Landscape model is well suited to projects that need app + database + cache + networking declared together.
- **Self-service deploy workflows**: developers can modify config, test, deploy, inspect logs, and manage services in one surface.
- **Teams that want infra abstraction**: Codesphere is explicitly selling standardization across cloud, on-prem, and hybrid installations.
- **Regulated or sovereignty-sensitive projects**: this is one of their clearest positioning angles.

## Weak fit

- **ShipGlows core doctrine**: Codesphere does not cover `AGENT.md`, context routing, spec readiness, verification gates, or skill ownership. That remains ShipGlows territory.
- **Founder-first local autonomy**: ShipGlows works well from repo + terminal + server workflows. Codesphere pulls execution toward a platform-centric model.
- **Low-complexity projects**: for small single-service apps, the platform may add more control-plane weight than benefit.
- **Open-ended agent workflow orchestration**: Codesphere has API/CLI automation, but the public material does not suggest a first-class equivalent to ShipGlows's artifact-governed agent lifecycle.

## Operational caveats

- **Monitoring is not default-on**: the Log Browser docs say monitoring must first be enabled at both team and landscape level, and only team admins can enable it.
- **Log retention is short**: current log retention is documented as 14 days, with quota-based overwrite.
- **Some observability/runtime features are uneven**: the Log Browser page explicitly scopes collection to Reactive services; the Landscape config docs also note some platform integrations still require manual configuration for certain runtime paths.
- **API auth is user-scoped**: the Public API currently uses API keys that inherit the exact permissions and visibility of the user account, which is weaker than a more granular service-account model.
- **Docs freshness split exists**: the Public API page opened from the `next` docs stream explicitly says it is a weekly build and points readers back to the latest stable docs.
- **Managed-service config edits carry infra risk**: the Landscape config docs warn that renaming a service can recreate it and lead to data loss.

## What it could replace for us

Codesphere could plausibly replace or absorb parts of the following, on a per-project basis:

- preview/staging environment provisioning
- app hosting and multi-service runtime composition
- some CI/CD orchestration
- some log/trace inspection and operational dashboards
- some "remote dev environment" setup burden

It would **not** replace:

- ShipGlows routing and skill ownership
- spec/ready/start/verify/end lifecycle
- documentation governance
- business/product/GTM context contracts
- agent handoff discipline

## Practical recommendation

Use Codesphere only if we want a **platform target** for specific app projects, not as a strategic replacement for ShipGlows's operating model.

Recommended posture:

1. **Do not adopt Codesphere as the base platform for ShipGlows itself.**
2. **Consider a bounded pilot** only for a project that has all of these traits:
   - multi-service or preview-heavy
   - benefits from managed services
   - would gain from built-in logs/traces
   - may benefit from self-hosted or sovereignty posture
3. **If we pilot it, keep ShipGlows above it**:
   - ShipGlows remains the workflow governor
   - Codesphere becomes one deploy/runtime substrate
4. **Pilot success criteria should be explicit**:
   - faster preview environment setup
   - less infra glue code
   - no loss of local control or debugging clarity
   - no new ambiguity in deploy ownership

## Suggested integration angle

If we want to explore this seriously, the cleanest route is not "move ShipGlows into Codesphere". The cleaner route is:

- keep ShipGlows as the execution and governance layer
- treat Codesphere as an optional deployment backend for selected apps
- later evaluate whether `004-sg-deploy` or adjacent deploy/playbook surfaces should gain a Codesphere target mode via CLI or Public API

## Bottom line

Codesphere looks like a credible platform for **standardized app delivery**. ShipGlows is a framework for **governed agent execution and reduced ambiguity**. Those are adjacent, not competing centers of gravity.

So the answer for "pour nos workflows ?" is:

- **yes, maybe**, for app delivery workflows that need preview environments, managed services, and unified ops
- **no**, as a replacement for ShipGlows's core workflow system
- **best next step**: compare it against Railway, Render, and Fly.io specifically through the lens of ShipGlows-managed app projects

## Sources

- [Codesphere homepage](https://www.codesphere.com/) - current positioning around infrastructure control, faster deployment cycles, and cost reduction.
- [Codesphere Docs: Introduction](https://docs.codesphere.com/intro) - current product model, monitoring, administration, and self-hosted scope.
- [Landscapes & Workspaces](https://docs.codesphere.com/core-concepts/landscapes-and-workspaces) - main abstraction model for deployable environments and attached workspaces.
- [Configuring a Landscape](https://docs.codesphere.com/workspace-toolkit/ci-and-deploy/configuring-a-landscape) - details on runtime types, managed services, `ci.yml`, and data-loss caveat on service renames.
- [Log Browser](https://docs.codesphere.com/workspace-toolkit/monitor/log-browser) - monitoring enablement, retention window, and scope limits.
- [Automations](https://docs.codesphere.com/category/automations) - preview deployment integrations across GitHub, GitLab, and Bitbucket.
- [Public API](https://docs.codesphere.com/next/apis-and-automations/public-api) - current API posture, PAT-style auth, and docs-location pattern.
- [Remote Development](https://www.codesphere.com/remote-development) - local IDE connectivity, cloud IDE, CI/CD, and monorepo-oriented workflow claims.
