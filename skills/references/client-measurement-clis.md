---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-11-15"
updated: "2026-11-15"
status: active
source_skill: 900-shipglows-core
scope: client-measurement-clis
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/406-sg-seo/references/gsc-evidence-workflow.md
  - cli/shipglows-gsc.sh
  - shipglows_data/technical/google-search-console-cli.md
depends_on:
  - artifact: skills/references/canonical-paths.md
    artifact_version: "2.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-11-15: client Search Console performance data is a framework-owned read path, not a third-party MCP or manual UI scrape."
next_review: "2026-12-15"
next_step: "/103-sg-verify client-measurement-clis"
---

# Client Measurement CLIs

ShipGlows-owned read-only CLIs supply live client measurement where OAuth or API keys already exist. They stay separate from the DevServer/PM2 tree.

## Activation Rule

When the operator asks for Google Search Console data, GSC metrics, Search Analytics, property performance, sitemaps status from GSC, or URL inspection via the API, route to public `sg-seo` (mode `monitoring` when the ask is read-only). Load `$SHIPGLOWS_ROOT/skills/406-sg-seo/references/gsc-evidence-workflow.md` before claiming data is unavailable or before proposing a browser UI, export scrape, or third-party GSC integration.

## Google Search Console

| Item | Value |
| --- | --- |
| Owner | `406-sg-seo` / public `sg-seo` |
| Launcher | `$SHIPGLOWS_ROOT/cli/shipglows-gsc.sh` (installed aliases: `shipglows-gsc`, `gsc`) |
| Implementation | `tools/shipglows_gsc.py` |
| Operator guide | `shipglows_data/technical/google-search-console-cli.md` |
| Workflow | `skills/406-sg-seo/references/gsc-evidence-workflow.md` |

Never substitute SerpApi (`shipglows-serp`) or Parallel search for verified-property GSC performance; those tools answer different questions.

## Related Read Tools

- `shipglows-serp`: one-shot localized Google SERP snapshot (SerpApi), not GSC.
- `shipglows-parallel` / `shipglows-search`: web discovery and extract, not GSC performance.