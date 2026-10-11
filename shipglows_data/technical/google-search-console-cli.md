---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.3.1"
project: ShipGlows
created: "2026-07-14"
updated: "2026-10-01"
status: reviewed
source_skill: 102-sg-start
scope: google-search-console-cli
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [tools/shipglows_gsc.py, cli/shipglows-gsc.sh, tools/shipglows_serp.py, cli/shipglows-serp.sh, cli/install.sh, skills/406-sg-seo/SKILL.md]
depends_on: []
supersedes: []
evidence:
  - "Google Search Console API official documentation checked 2026-08-10; Google documents REST and official client libraries, with no Google-maintained GSC CLI or MCP identified."
  - "Implementation, authorized property listing, and a bounded performance request were verified on 2026-09-30; the newly verified property had no query rows yet."
  - "The ChatGPT plugin directory listed third-party GSC Wizard by 11 Internet on 2026-09-30; it is separate from this ShipGlows-owned CLI."
  - "Cross-linked the separate SerpApi keyword SERP snapshot tool on 2026-10-01 to distinguish it from Search Console performance data."
next_step: "/103-sg-verify google-search-console-api-cli"
next_review: "2026-10-14"
---

# Google Search Console CLI

## Purpose

`shipglows-gsc` is ShipGlows' canonical, read-only command-line client for Google Search Console. It retrieves evidence for operators and SEO workflows and does not change Search Console or the site.

Google exposes Search Console through its OAuth-protected REST API and language client libraries; the CLI is ShipGlows-owned, not a Google product. A third-party app named GSC Wizard by 11 Internet was listed in ChatGPT's plugin directory on 2026-09-30. It is separate from this CLI, may share relevant ChatGPT conversations and memories for context, and must not be assumed available in Codex or used without a separate operator choice.

For an arbitrary keyword-to-current-SERP lookup, use the separate [SerpApi Google SERP CLI](serpapi-google-serp-cli.md). This GSC reader remains the source for observed property performance: queries, impressions, clicks, and average position.

## Where It Lives

- Canonical implementation: `tools/shipglows_gsc.py` in the ShipGlows repository.
- Repository launcher: `cli/shipglows-gsc.sh`; the installer can register a `shipglows-gsc` command on supported shell installations.
- Internal operator entrypoint: the GSC note in `README.md`.
- SEO evidence workflow: `skills/406-sg-seo/references/gsc-evidence-workflow.md`.
- OAuth client configuration and authorized profiles live in the current user's local configuration directory, outside the repository. Never copy those files into project docs, Git, logs, or examples.

On Windows, when no shell alias is available, run the Python implementation directly from the repository root:

```powershell
python "$env:SHIPGLOWS_ROOT\tools\shipglows_gsc.py" --profile default auth status
python "$env:SHIPGLOWS_ROOT\tools\shipglows_gsc.py" --profile default sites
```

## SEO Skill Integration

`406-sg-seo` monitoring loads `skills/406-sg-seo/references/gsc-evidence-workflow.md` and invokes the repository implementation directly, so it does not depend on a globally installed alias. It may consume live data only when `auth status` reports an authorized profile; otherwise it reports the missing authorization and falls back to user-supplied evidence. OAuth login is operator-authorized setup, not an automatic monitoring step.

## Commands

```bash
python tools/shipglows_gsc.py --profile default auth status
python tools/shipglows_gsc.py --profile default auth login --client-secrets /absolute/path/google-oauth-desktop-client.json
python tools/shipglows_gsc.py --profile default sites
python tools/shipglows_gsc.py --profile default performance --site sc-domain:example.com --start-date 2026-06-01 --end-date 2026-06-30 --dimension query --row-limit 100
python tools/shipglows_gsc.py --profile default sitemaps --site sc-domain:example.com
python tools/shipglows_gsc.py --profile default inspect --site sc-domain:example.com --url https://example.com/page
```

Run these commands from the repository root. `--profile` is a global option and must precede the subcommand. Performance defaults to the `page` dimension, `web` search type, and a 1,000-row limit; `--dimension` can be repeated to request grouped dimensions such as `query` and `page`. The end date is inclusive. The API returns JSON; a successful response can contain no `rows` when Google has no rows available for that property and date range. An empty result is not proof of an API failure, and a newly verified property may still be in Google's data-processing window. Report that state as incomplete evidence rather than asserting zero impressions.

## Security Contract

- OAuth scope is only `webmasters.readonly`.
- OAuth client configuration and refresh tokens stay in the user's configuration directory, outside the repository. On POSIX systems the implementation requests directory mode `0700` and file mode `0600`. On Windows, `chmod` alone does not establish NTFS ACL privacy; verify the effective ACL on the configuration directory and files before claiming owner-only access.
- `auth status` currently includes a `token_path` field in its JSON result. This is a path, not a token value, but it conflicts with the workflow rule against exposing credential paths. Treat raw status output as local-only; a code change is needed before claiming the CLI redacts this field.
- The CLI does not print secrets or perform write requests.
- The OAuth client-secret JSON and resulting token files must never be committed.

## Validation

```bash
python3 -m unittest tools.test_shipglows_gsc
python3 tools/shipglows_gsc.py auth status
bash -n cli/shipglows-gsc.sh cli/install.sh
```

## Maintenance Rule

Update this guide when GSC scopes, endpoints, credential storage, commands, installation paths, integrations, or validation changes. Keep current implementation status distinct from dated historical research about the earlier third-party MCP pilot.
