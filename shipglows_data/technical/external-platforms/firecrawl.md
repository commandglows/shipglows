---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-firecrawl
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/technical-docs-corpus.md
  - shipglows_data/technical/external-platforms/README.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against official Firecrawl changelog, GitHub releases, API v2 introduction, scrape endpoint, and MCP docs."
  - "Operator explicitly supplied https://github.com/firecrawl/firecrawl/releases as a release source to preserve."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Firecrawl Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Firecrawl-related freshness checks. Use it before relying on assumptions about Firecrawl API endpoints, SDKs, MCP tooling, scrape/crawl/search behavior, document parsing, browser interaction, pricing/credits, retention, or release-driven migration work.

It does not replace Firecrawl documentation. It records the source map and ShipGlows decision rules agents should use before updating code, dependency posture, technical docs, or project-local Firecrawl usage notes.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Official docs entrypoint and API v2 overview | https://docs.firecrawl.dev/api-reference/v2-introduction |
| Complete docs index for agents | https://docs.firecrawl.dev/llms.txt |
| Scrape endpoint and current request/response fields | https://docs.firecrawl.dev/api-reference/v2-endpoint/scrape |
| Firecrawl changelog | https://www.firecrawl.dev/changelog |
| GitHub releases, tags, and release notes | https://github.com/firecrawl/firecrawl/releases |
| MCP server docs | https://docs.firecrawl.dev/mcp |
| Developer MCP use case | https://docs.firecrawl.dev/use-cases/developers-mcp |
| GitHub organization | https://github.com/firecrawl |

Freshness evidence on 2026-05-24:

- Firecrawl API v2 docs describe Scrape, Parse, Crawl, Map, Search, Agent, and Browser capabilities, with `https://api.firecrawl.dev` as the API base URL and bearer API-key authentication.
- The `/scrape` reference includes current fields that matter for code review and security, including `formats`, `onlyMainContent`, `onlyCleanContent`, `maxAge`, `waitFor`, `mobile`, `timeout`, `parsers`, `actions`, `location`, `proxy`, `storeInCache`, `lockdown`, and `zeroDataRetention`.
- The official changelog lists v2.10 on May 15, 2026, including `/parse`, Lockdown Mode, Question and Highlights formats, Go/Ruby/PHP/.NET SDK additions, Rust SDK v2 promotion, and reliability/security fixes.
- The changelog lists v2.9.0 on April 10, 2026, including `/interact`, additional scrape formats, PDF parsing options, Java and Elixir SDKs, and reliability fixes.
- Firecrawl MCP docs describe cloud and self-hosted support, scrape/crawl/search/deep research/batch scraping capabilities, hosted SSE and local `npx` setup, logging, rate-limit handling, and retries.
- GitHub releases remain the preserved release source supplied by the operator and should be checked for tag-level release notes and self-hosted changes.

## Freshness Gate Use

Use `fresh-docs checked` for Firecrawl decisions only after checking the relevant official Firecrawl docs, changelog, GitHub release, SDK docs, MCP docs, or visible provider state.

Use `fresh-docs gap` when:

- Firecrawl behavior affects a task but current endpoint docs, changelog, release notes, SDK docs, MCP docs, or project-local usage were not checked.
- Code depends on a Firecrawl SDK version but the local package version and matching SDK docs were not identified.
- A project uses Firecrawl but lacks `shipglows_data/technical/platforms/firecrawl.md`.
- The task touches data retention, scraping third-party sites, browser interaction, auth/cookies, MCP secrets, or high-volume crawling without a clear security and compliance note.

Use `fresh-docs conflict` when current Firecrawl docs, changelog, or release notes contradict project code, local docs, or an agent's planned implementation.

## ShipGlows Decision Rules

- Prefer official Firecrawl SDKs over raw HTTP when the project language has maintained v2 support and the SDK improves auth, polling, errors, or typed usage.
- Raw HTTP is acceptable for narrow integrations when it reduces dependency surface and the API contract is explicitly captured in code/tests.
- Do not assume older v1 endpoint shapes or SDK behavior apply to v2. Confirm endpoint path, parameters, response shape, and SDK method names before edits.
- Treat `/parse`, `/interact`, Question/Highlights formats, Lockdown Mode, and SDK additions as release-driven opportunities that may justify code improvements or new project capabilities.
- Treat `lockdown` and `zeroDataRetention` as security/privacy-relevant options. Do not enable or disable them silently; document the product reason and data-retention implication.
- Treat browser interaction, profiles, cookies, authenticated scraping, and dynamic actions as high-risk. Require explicit project context and avoid storing raw session data or credentials.
- For bulk crawl/search/parse jobs, check rate limits, credit usage, retries, queue status, timeout behavior, and idempotency before recommending automation.
- For technical freshness work, Firecrawl release notes can trigger a review, but implementation decisions should be confirmed against endpoint or SDK docs.
- For MCP use, never store `FIRECRAWL_API_KEY` values in docs or committed config. Prefer environment-variable references and secret-manager instructions.

## Common Project-Local Fields

A project using Firecrawl should maintain `<governance-root>/shipglows_data/technical/platforms/firecrawl.md` with:

- Firecrawl role in the product: research, scraping, docs ingestion, lead enrichment, monitoring, agent browsing, or content extraction
- integration path: API, SDK, MCP, CLI, self-hosted, or hybrid
- local SDK/package name and version when applicable
- endpoint list used: `/scrape`, `/parse`, `/crawl`, `/map`, `/search`, `/agent`, `/browser`, `/interact`, or MCP tools
- data retention posture and whether `lockdown` or `zeroDataRetention` is required
- expected input sources and robots/compliance constraints
- output formats and downstream consumers
- rate-limit/credit/queue assumptions
- secret keys by name only, never values
- validation commands or smoke scenarios

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store Firecrawl API keys, raw cookies, authenticated browser profiles, private scraped data, customer documents, raw provider logs, or sensitive extracted content in ShipGlows docs.
- Treat document parsing as sensitive when files include contracts, medical records, financial data, customer data, or internal reports.
- Treat scraping automation as compliance-sensitive. Capture the intended source category and any allowlist/robots/legal constraints in project-local docs.
- Treat Firecrawl MCP as a privileged web-data tool: it can fetch live external content and consume credits. Use scoped secrets and avoid committing MCP configs with inline keys.
- Summarize provider evidence with redaction and link to source artifacts only when they are safe to share.

## Validation

For global note changes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/firecrawl.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/firecrawl.md
```

For project-local Firecrawl notes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/platforms/firecrawl.md
rg -n "integration path|endpoint|retention|Validation|Maintenance Rule" shipglows_data/technical/platforms/firecrawl.md
```

## Reader Checklist

- Firecrawl dependency, SDK import, API endpoint, MCP config, or docs mention found -> check for project-local Firecrawl usage note.
- Firecrawl release/changelog changes mention endpoints, SDKs, MCP, retention, parsing, browser interaction, or reliability/security fixes -> compare against current project code and docs.
- Code touches scraping, crawling, document parsing, web search, or browser automation -> run the Freshness Gate and check relevant Firecrawl docs.
- Project uses Firecrawl for user/customer data -> verify retention, secret handling, compliance, and logging assumptions before giving a high-confidence verdict.
- Major Firecrawl release affects integration shape -> route upgrades to `010-sg-technical deps` or `010-sg-technical migrate`; route code impact to `010-sg-technical audit`; route docs impact to `sg-docs`.

## Maintenance Rule

Update this note when Firecrawl endpoint semantics, SDK coverage, MCP behavior, retention/privacy options, pricing/credit assumptions, self-hosted deployment requirements, or ShipGlows Firecrawl proof rules change. Review it at least monthly while Firecrawl remains a candidate for technical freshness and web-data workflows.
