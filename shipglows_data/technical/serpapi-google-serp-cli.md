---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-01"
updated: "2026-10-01"
status: reviewed
source_skill: 102-sg-start
scope: serpapi-google-serp-cli
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/shipglows_serp.py
  - tools/test_shipglows_serp.py
  - cli/shipglows-serp.sh
  - cli/install.sh
  - shipglows_data/workflow/specs/serpapi-google-serp-cli.md
depends_on: []
supersedes: []
evidence:
  - "SerpApi official Google Search API documentation checked 2026-10-01: HTTPS endpoint, required q/api_key, localization and device parameters, synchronous JSON response, and default cache behavior."
  - "SerpApi official pricing checked 2026-10-01: free tier advertises 250 monthly searches; successful uncached searches count toward quota and cached searches are free."
  - "Implementation validation uses mocked HTTP responses; no real API key or provider request is part of automated tests."
next_step: "Provide an operator API key in the process environment only when intentionally running a SERP lookup."
next_review: "2026-11-01"
---

# SerpApi Google SERP CLI

## Purpose and boundary

`shipglows-serp` runs one explicit Google query through SerpApi and returns a JSON snapshot of organic results. It is a separate ShipGlows-owned tool; it is not SerpApi's API product, the vendor MCP server, or a Search Console report.

Use [Google Search Console CLI](google-search-console-cli.md) for queries that actually generated impressions/clicks and the site's average position. Use this command when you want to inspect an arbitrary keyword, including one for which Claiire has not yet appeared. A snapshot depends on country, language, device, location, time, and SerpApi's result processing; it is not a universal or durable rank.

## Where it lives

- Source: `tools/shipglows_serp.py` (Python standard library only).
- POSIX repository launcher: `cli/shipglows-serp.sh`.
- Installer alias: `shipglows-serp` where the ShipGlows shell installer registers repository tools.
- Windows: invoke the source with Python from the repository root; no native Windows alias is installed by this shell wrapper.
- Focused tests: `tools/test_shipglows_serp.py`; all transport calls use a fake opener.

## Setup and commands

The API key is read from `SERPAPI_API_KEY` in the process environment. The CLI never asks for, stores, or prints it. Supply it through your approved local secret manager or set it temporarily in the terminal session; do not put it in Git, a checked-in `.env`, an argument, or a command example.

From the ShipGlows repository root on POSIX:

```bash
shipglows-serp search --query "conseil nutritionnel Claiire" --domain claiire.fr
shipglows-serp search --query "coach bien-être" --location "Paris, France" --device mobile --country fr --language fr --domain claiire.fr
```

When the launcher is not installed:

```bash
bash cli/shipglows-serp.sh search --query "coach bien-être" --location "Paris, France" --device mobile --domain claiire.fr
```

On Windows PowerShell:

```powershell
python "$env:SHIPGLOWS_ROOT\tools\shipglows_serp.py" search --query "coach bien-être" --location "Paris, France" --device mobile --domain claiire.fr
```

Defaults are `country=fr`, `language=fr`, and `device=desktop`. `--country`/`--gl` expects a two-letter country code; `--language`/`--hl` accepts a short language code such as `fr` or `en-gb`. `--location` is optional; use a city and country for a more explicit location. The provider default number of results is retained because the current Google Search API reference does not document a `num` option.

Successful output includes the requested query/locale/device, SerpApi's resolved location when returned, a bounded metadata summary, organic result position/title/link/snippet rows, and (if `--domain` was supplied) matching pages and the best `target_rank`. Domain matching accepts the apex hostname and dot-delimited subdomains, not lookalike suffixes.

## Security and quota

- The key is required by SerpApi as an `api_key` query parameter over HTTPS. This client does not print the request URL, does not persist the key, and redacts a reflected key from provider error text and result strings. Avoid HTTP debug logging or proxies that record full request URLs.
- Each invocation makes at most one request, never retries or paginates, and returns only selected fields. There is no background mode or keyword batch.
- SerpApi's current docs advertise 250 searches/month on its Free plan. Cached searches are free; successful uncached searches count toward usage. Provider plans and quotas can change, so check [current pricing](https://serpapi.com/pricing) before repeated use.
- Queries are sent to SerpApi. Do not include sensitive or personal search terms.
- No SerpApi MCP is configured or required. No signup, subscription, account change, or API key is included in this implementation.

## Validation

```bash
python -m unittest tools.test_shipglows_serp
python tools/shipglows_serp.py --help
bash -n cli/shipglows-serp.sh cli/install.sh
python tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/serpapi-google-serp-cli.md shipglows_data/technical/serpapi-google-serp-cli.md
```

These checks are credential-free and make no API request. A real lookup is a separate operator action that requires `SERPAPI_API_KEY` and may use account quota.

## Official references

- [SerpApi Google Search API](https://serpapi.com/search-api)
- [SerpApi pricing](https://serpapi.com/pricing)

## Maintenance rule

Update this guide when the endpoint/response contract, credential handling, locale/device options, wrapper/installer behavior, quota implications, or validation changes. Keep SERP snapshots distinct from GSC impressions and average-position evidence.
