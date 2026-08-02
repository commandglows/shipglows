---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-14"
updated: "2026-07-14"
status: reviewed
source_skill: 203-sg-research
scope: "Google Search Console MCP, API, CLI, and SEO-agent feedback loop"
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/406-sg-seo/SKILL.md
  - skills/references/operator-roles/seo-specialist.md
  - shipglows_data/workflow/playbooks/seo-charge-referencement-web-playbook.md
  - /home/claude/.codex/config.toml
depends_on: []
supersedes: []
evidence:
  - "Local Codex configuration declares mcp_servers.gsc using @anthropic-community/mcp-gsc with enabled = false."
  - "Google Search Console API documentation confirms OAuth-protected Search Analytics, Sites, Sitemaps, and URL Inspection endpoints."
next_step: "Enable and authenticate GSC access for a bounded pilot, then add an evidence-to-action SEO review workflow."
---

# Research: Google Search Console For SEO Agents

## Executive Summary

ShipGlows has a configured Google Search Console MCP entry: `gsc` runs the third-party package `@anthropic-community/mcp-gsc`. It is disabled by default, so a normal Codex session and the current `406-sg-seo` skill cannot currently read live GSC data.

Google provides an official Search Console API. It can retrieve performance by query, page, country, device and date, list properties and sitemaps, and inspect a URL's Google index status. This is sufficient to make the SEO role improve existing content from observed evidence, provided that the relevant Google account authorizes access through OAuth.

## Local State

- `mcp_servers.gsc` exists in `/home/claude/.codex/config.toml`.
- It invokes `npx -y @anthropic-community/mcp-gsc`.
- `enabled = false`; it is therefore not active in a default Codex run.
- No first-party Search Console CLI is configured in ShipGlows.
- `gcloud` is installed, but does not expose a Search Console command group. Treat it as Google Cloud tooling, not as a GSC analytics CLI.
- `406-sg-seo` explicitly limits itself to codebase and local evidence unless Search Console data already exists locally.

## What Real GSC Data Enables

Use `searchanalytics.query` to compare periods and group/filter by `query`, `page`, `country`, `device`, and `date`. The response contains clicks, impressions, CTR, and average position.

This supports a disciplined improvement loop:

1. identify pages losing clicks or impressions;
2. identify queries with many impressions but weak CTR;
3. identify page/query intent mismatches and cannibalisation candidates;
4. compare mobile versus desktop or country segments;
5. inspect priority URLs after a technical or content change;
6. change the canonical source content or implementation;
7. re-measure after an agreed observation window.

The agent must not infer causality from a short date range, promise rankings, or edit content only because a query has volume. GSC returns Search Console's bounded data set, not a complete raw log of every query.

## Integration Options

### 1. Existing GSC MCP

Fastest pilot. Enable only for a dedicated session and authenticate it with an account that has access to the target property. It is third-party software, so its available tools, OAuth storage model, update cadence, and destructive actions must be reviewed before enabling it globally.

### 2. Official Search Console API

Recommended durable path. Build a small ShipGlows-owned adapter or CLI around the official API with read-only OAuth scope (`webmasters.readonly`) for analysis. Use the broader scope only when sitemap submission or another write action is explicitly requested.

### 3. Third-party CLI

Community CLIs exist, but none is installed or governed in this repository. They do not remove the OAuth requirement and add another maintenance/security surface. Do not make one the canonical integration without a bounded evaluation.

## Recommended Operating Boundary

- Read-only by default: sites, Search Analytics, sitemap status, URL Inspection.
- Separate analysis from changes: the SEO agent proposes evidence-linked changes; the project owner or implementation skill applies them.
- Require: property identifier, date range, baseline period, target audience/market, and target repository or public URL.
- Store only aggregated findings and recommendations in project artifacts. Do not commit OAuth tokens, refresh tokens, cookies, or raw credentials.
- Ask for explicit confirmation before write-capable actions such as sitemap submission.

## Recommendation

Run a bounded pilot with the existing MCP for one verified property, read-only queries only. If it proves useful and stable, replace or complement it with a ShipGlows-owned official API adapter/CLI so the role can reliably retrieve an evidence pack and turn it into a prioritized content/technical backlog.

## Sources

- [Search Console API overview](https://developers.google.com/webmaster-tools) - official scope of API capabilities.
- [Search Analytics query](https://developers.google.com/webmaster-tools/v1/searchanalytics/query) - dimensions, metrics, OAuth scopes, limits, and recent-data behavior.
- [Search Analytics guide](https://developers.google.com/webmaster-tools/v1/how-tos/search_analytics) - analysis patterns for pages, queries, mobile, and low CTR.
- [API reference](https://developers.google.com/webmaster-tools/v1/api_reference_index) - Sites, Sitemaps, Search Analytics, and URL Inspection coverage.
- [Authorize requests](https://developers.google.com/webmaster-tools/v1/how-tos/authorizing) - OAuth 2.0 requirement for user data.
- [Google API Node.js client](https://github.com/googleapis/google-api-nodejs-client) - official Node.js client with OAuth support.
