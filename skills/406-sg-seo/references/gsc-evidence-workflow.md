---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-10"
updated: "2026-08-10"
status: active
source_skill: 406-sg-seo
scope: seo-gsc-evidence-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/406-sg-seo/SKILL.md
  - cli/shipglows-gsc.sh
  - tools/shipglows_gsc.py
  - shipglows_data/technical/google-search-console-cli.md
depends_on: []
supersedes: []
evidence:
  - "Official Google Search Console API and client-library documentation reviewed 2026-08-10."
  - "No Google-maintained GSC CLI or MCP and no OpenAI-maintained GSC Codex plugin identified in official documentation."
next_review: "2026-11-10"
next_step: "/103-sg-verify google-search-console-api-cli"
---

# GSC Evidence Workflow

Use this workflow for SEO monitoring and for audits that need current Search Console evidence. It consumes the official Google Search Console API through ShipGlows' read-only local adapter; it never changes a property, sitemap, page, or Google setting.

## Entry Gate

1. Resolve the executable as `$SHIPGLOWS_ROOT/cli/shipglows-gsc.sh`; do not require a global `gsc` or `shipglows-gsc` alias.
2. Run `auth status` for the requested profile, defaulting to `default` only when no profile was named.
3. If unauthorized, do not launch `auth login`. Report the OAuth prerequisite and use a supplied GSC export or clearly mark live GSC evidence unavailable.
4. If authorized, run `sites` and match the requested project to exactly one property. Accept an explicit `sc-domain:` or exact URL-prefix property first.
5. Stop for operator selection when zero or multiple properties plausibly match. Never infer ownership from a similar domain.

## Evidence Acquisition

Use only the smallest queries needed for the requested outcome:

- `performance`: compare clicks, impressions, CTR, average position, pages, and queries over explicit date ranges. Record the date range, search type, dimensions, and row limit with the interpretation.
- `sitemaps`: verify submitted sitemap status and API-reported errors or warnings.
- `inspect`: inspect only explicit fully qualified URLs attached to the selected property.
- `sites`: establish accessible properties and permission levels; do not expose unrelated property names in a user-facing report.

Recent GSC data can be incomplete and aggregated. Treat changes as signals, not proof of causality. Distinguish missing rows from zero performance, and do not call average position a live rank.

## Security And Failure Handling

- Preserve the `webmasters.readonly` scope. Never request broader scopes for monitoring.
- Never print, copy, summarize, or commit client secrets, refresh tokens, access tokens, token paths, or raw credential files.
- Treat authorization, network, API quota, invalid-property, and revoked-token failures as unavailable evidence, not as proof of an SEO defect.
- Do not silently substitute one property, profile, date range, search type, or dimension for another.
- Keep raw JSON local unless the operator explicitly requests an export; user reports should contain only the evidence needed for the SEO conclusion.

## Reporting Contract

State whether evidence is `live GSC`, `supplied export`, or `unavailable`. For live evidence, include the property, date range, comparison basis, and material API limitations. Separate observed metrics from recommended content or technical changes.
