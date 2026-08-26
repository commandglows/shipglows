---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.13.0"
project: ShipGlows
created: "2026-05-01"
updated: "2026-08-26"
status: reviewed
source_skill: sg-start
scope: technical-docs-index
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/
  - shipglows_data/technical/code-docs-map.md
  - AGENT.md
  - shipglows_data/technical/context.md
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-technical-documentation-layer-for-ai-agents.md"
    artifact_version: "1.0.0"
    required_status: ready
supersedes: []
evidence:
  - "Spec defines shipglows_data/technical as the internal code-proximate documentation layer."
  - "Blacksmith technical note added for CI observability and APK build operations."
  - "External platform corpus added for global Freshness Gate source notes and project-local provider usage contracts."
  - "Firecrawl global platform note added with official docs, changelog, MCP, and GitHub release sources."
  - "Convex, Clerk, Firebase, and Google Cloud global platform notes added for common ShipGlows project stacks."
  - "Supabase, Sentry, and Astro global platform notes added for common auth/database, observability, and public-site stacks."
  - "Python, Bash, and Gum global platform notes added for ShipGlows tooling, shell runtime, and Gum TUI scripts."
  - "CrewAI global platform note added for agent orchestration, tools, memory, structured outputs, and dependency freshness."
  - "GitHub Actions technical note added for CI cost, cache, monorepo trigger, and workflow topology guardrails."
  - "Codex plugin packaging note added for the lightweight shipglows plugin and sparse source bootstrap."
  - "Design-system authority technical artifact added for declaring project canonical token/theme/component sources."
  - "Operator guides migrated from root docs into shipglows_data/technical/operator-guides/."
  - "Progressive resource discovery added a read-only resolver and shared authority-boundary reference for bounded reference/playbook search."
  - "Latest-build artifact access documentation added for source-labelled local and CI shortcuts, private cached packages, and honest host-platform limits."
  - "Auth0 platform note added for SDK, native CLI, Deploy CLI, MCP, tenant, authentication, and hosted-proof boundaries."
  - "Doppler platform note added for native CLI, keychain, environment scope, process injection, service-token, MCP, and agent-safety boundaries."
next_review: "2026-06-18"
next_step: "/sg-docs technical audit"
---

# Technical Documentation

## Purpose

`shipglows_data/technical/` is the internal code-proximate documentation layer for ShipGlows. It tells agents which durable subsystem doc to read, which files are owned by that subsystem, which invariants must survive edits, and which checks prove the change.

This layer complements the existing docs:

- `shipglows_data/technical/architecture.md` stays the global system view.
- `shipglows_data/technical/context.md` stays the compact operational map.
- `shipglows_data/technical/guidelines.md` stays the general engineering doctrine.
- `shipglows_data/technical/external-platforms/` stores global external provider notes used by the Freshness Gate.
- `shipglows_data/workflow/specs/*.md` stay chantier contracts and run history.
- `shipglows_data/technical/*.md` documents durable subsystem behavior near the code.
- `shipglows_data/technical/operator-guides/` stores canonical operator-facing Markdown references.

It does not share canonical ownership with random root notes. When a root technical document overlaps this layer, the technical layer wins and the root note should be treated as migration debt or a compatibility facade until a preservation pass finishes.

## Read Order

1. Open `shipglows_data/technical/code-docs-map.md` and match the changed path.
2. Open the primary technical doc for that subsystem.
3. Open secondary docs only when the map says the change crosses a boundary.
4. After a code-changing wave, produce a `Documentation Update Plan` from the map.
5. Update impacted docs sequentially unless a ready spec assigns disjoint files to separate executors.

## Docs

| Doc | Open when the task touches |
| --- | --- |
| `code-docs-map.md` | Any code change, Reader pass, final integration, or docs gate |
| `operator-guides/README.md` | Operator-facing Markdown guides, launch cheatsheets, focus tags, OpenCode, or KiloCode usage |
| `runtime-cli.md` | `shipglows.sh`, `lib.sh`, `config.sh`, PM2/Flox/Caddy/DuckDNS flows |
| `terminal-tui.md` | `tui/`, read-only dashboard behavior, task/audit/spec readers, and operator visibility rules |
| `local-tunnels-and-mcp-login.md` | `local/`, SSH tunnels, remote helper scripts, MCP OAuth login |
| `skill-runtime-and-lifecycle.md` | `skills/`, lifecycle skills, references, templates, Reader/Executor rules, `tools/resource_resolver.py`, `tools/test_resource_resolver.py`, and resolver-related specs; stable resource IDs, bounded ranking, expansion, and authority boundaries |
| `agent-clarity-pass-playbook.md` | Future agent-clarity hardening passes across overlapping skills, batching rules, and first-screen boundary method |
| `artifact-metadata-and-linter.md` | `templates/`, `tools/shipglows_metadata_lint.py`, frontmatter contracts |
| `codebase-mcp.md` | `tools/codebase-mcp/` |
| `public-site-and-content-runtime.md` | `site/`, `shipglows_data/editorial/content-map.md`, public/private doc boundaries |
| `installer-and-user-scope.md` | `install.sh`, root/user setup, aliases, skill links, MCP config |
| `latest-build-artifact-access.md` | Latest successful local/CI Windows packages and Android APKs, private cache/state, desktop shortcuts, GitHub artifact synchronization, and platform limits |
| `codex-plugin-packaging.md` | `/home/claude/plugins/shipglows/`, personal marketplace, plugin manifest, sparse source bootstrap |
| `product-behavior-intelligence.md` | Cross-project product analytics framing for behavior graphs, activation, retention, feature impact, exploratory analytics, and GTM proof |
| `decisions.md` | ADR-style decisions, `decision_record` templates, durable decision routing |
| `github-actions.md` | GitHub Actions workflow cost, caches, monorepo triggers, job topology, deploy guards, and artifacts |
| `design-system-authority.md` | Project UI design-system authority: canonical token/theme source, component bridge, layout/motion authority, forbidden bypasses, and validation |
| `blacksmith.md` | Blacksmith CI runners, APK build observability, logs, SSH debugging, monitors, metrics, cache, Testboxes |
| `firebase-firestore-oidc-ci-playbook.md` | Firebase/Firestore CI setup with GitHub OIDC/WIF, step-by-step wiring and troubleshooting matrix |
| `external-platforms/README.md` | Global provider/source corpus, Freshness Gate source policy, project-local platform usage template |
| `external-platforms/vercel.md` | Vercel deployment, environment, CLI, logs, preview/production, and hosted proof assumptions |
| `external-platforms/firecrawl.md` | Firecrawl API, SDK, MCP, scraping, parsing, release, retention, and web-data freshness assumptions |
| `external-platforms/convex.md` | Convex deployments, generated APIs, auth, Clerk integration, indexes, actions, and scheduled functions |
| `external-platforms/crewai.md` | CrewAI agents, crews, tasks, flows, tools, memory, structured outputs, LiteLLM/OpenRouter, and dependency migrations |
| `external-platforms/clerk.md` | Clerk SDKs, middleware, hooks, webhooks, JWT templates, Convex integration, and hosted auth proof |
| `external-platforms/auth0.md` | Auth0 SDKs, native operator CLI, login/status boundaries, Deploy CLI separation, tenant safety, and hosted auth proof |
| `external-platforms/doppler.md` | Doppler native CLI, keychain, project/config scope, secret injection, service/identity tokens, MCP risk, and agent-safe use |
| `external-platforms/firebase.md` | Firebase Auth, Firestore Security Rules, Admin SDK boundaries, CLI deploys, and Hosting |
| `external-platforms/google-cloud.md` | Google Cloud IAM, ADC, service accounts, Workload Identity Federation, Cloud Run identity, and CI credentials |
| `external-platforms/supabase.md` | Supabase Auth, Postgres/RLS, Storage, SSR sessions, CLI, migrations, and database advisors |
| `external-platforms/sentry.md` | Sentry SDKs, environments, releases, source maps, Debug IDs, monitors, alerts, and PII-safe incident proof |
| `external-platforms/astro.md` | Astro content collections, schemas, env vars, static/on-demand rendering, deploys, and major upgrades |
| `external-platforms/python.md` | Python runtime, stdlib tooling, virtual environments, packaging, subprocess, parsing, and script validation |
| `external-platforms/bash.md` | Bash shell behavior, error handling, traps, pipelines, quoting, installers, and destructive-command safety |
| `external-platforms/gum.md` | Charmbracelet Gum commands, install sources, TUI output/exit behavior, prompt cancellation, and Bash menu validation |

## Non-Coverage

The layer does not create one doc per file. Small legacy files such as menu frontend variants, compatibility wrappers, historical archives, and standalone test fixtures are covered through the closest subsystem doc or through an explicit Reader note when a change proves they need a dedicated doc.

## Validation

Run the checks listed in `code-docs-map.md` for the changed paths. At minimum, technical-doc changes should pass:

```bash
rg -n "Maintenance Rule|Validation|Owned Files|Entrypoints" shipglows_data/technical templates/technical_module_context.md
python3 tools/shipglows_metadata_lint.py shipglows_data/technical templates/technical_module_context.md
```

## Maintenance Rule

Update this index when a technical doc is added, renamed, removed, or when a major code area gains an explicit non-coverage reason. Keep this file as an index; put subsystem details in the subsystem docs.
