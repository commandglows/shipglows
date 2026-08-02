---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-14"
updated: "2026-07-14"
status: reviewed
source_skill: 102-sg-start
scope: google-search-console-cli
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [tools/shipglows_gsc.py, shipglows-gsc.sh, cli/install.sh, skills/406-sg-seo/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Google Search Console API official documentation checked 2026-07-14."]
next_step: "/103-sg-verify google-search-console-api-cli"
next_review: "2026-10-14"
---

# Google Search Console CLI

## Purpose

`shipglows-gsc` retrieves read-only Google Search Console evidence for operators and SEO workflows. It is not the third-party MCP and does not automate site changes.

## Commands

```bash
shipglows-gsc auth login --client-secrets /absolute/path/google-oauth-desktop-client.json
shipglows-gsc sites
shipglows-gsc performance --site sc-domain:example.com --start-date 2026-06-01 --end-date 2026-06-30 --dimension page --dimension query
shipglows-gsc sitemaps --site sc-domain:example.com
shipglows-gsc inspect --site sc-domain:example.com --url https://example.com/page
```

## Security Contract

- OAuth scope is only `webmasters.readonly`.
- Refresh tokens live under `${XDG_CONFIG_HOME:-$HOME/.config}/shipglows/gsc/` with mode `0600`.
- The CLI does not print secrets or perform write requests.
- The OAuth client-secret JSON and resulting token files must never be committed.

## Validation

```bash
python3 -m unittest tools.test_shipglows_gsc
python3 tools/shipglows_gsc.py auth status
bash -n shipglows-gsc.sh cli/install.sh
```

## Maintenance Rule

Update this guide when GSC scopes, endpoints, credential storage, commands, or validation changes.
