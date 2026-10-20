---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-01"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: parallel-web-search-cli
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/shipglows_parallel.py
  - cli/shipglows-parallel.sh
  - cli/install.sh
  - tools/test_shipglows_parallel.py
  - shipglows_data/workflow/specs/parallel-web-search-cli.md
depends_on: []
supersedes: []
evidence:
  - "Parallel Search API endpoint, request, response, and modes reviewed in official docs on 2026-10-01."
  - "Parallel Extract, Search filters, Task runs, and Monitor lifecycle checked against current official API documentation on 2026-10-04."
  - "Retry, Retry-After, timeout override and network-reason reporting covered by fake-transport unit tests on 2026-10-20."
next_review: "2026-11-01"
next_step: none
---

# Parallel Web Search CLI

## Purpose and boundary

`shipglows-parallel search` calls the Parallel Search API and prints normalized web results with excerpts. `extract` reads content from explicit public URLs; `research` starts or retrieves asynchronous cited Task runs; `monitor` creates and manages recurring change watches. It complements two separate tools:

- `shipglows-serp` returns localized organic Google SERP snapshots through SerpApi.
- `shipglows-gsc` reads Search Console performance data for verified properties.
- `shipglows-parallel` returns Parallel's web-search relevance order and excerpts. That order is not a Google ranking, an impression, or a position measurement.

Search is useful for source discovery; Extract is for reading selected pages after discovery or from URLs supplied directly; Task runs handle multi-step research; Monitors track new changes after their creation. None is Google rank tracking.

## Setup and use

Set `PARALLEL_API_KEY` in the local secret environment used to launch the command. The CLI never prompts for, saves, or prints the key. It makes no request if the variable is absent.

```bash
shipglows-parallel search \
  --query "coaching bien-être France" \
  --query "coach santé Paris" \
  --objective "Trouver des pages web pertinentes pour une recherche SEO" \
  --domain claiire.fr

# Read known URLs; request full-page markdown when needed
shipglows-parallel extract \
  --url "https://example.fr/guide" \
  --objective "Relever les recommandations et les sources citées" \
  --full-content

# Launch cited deep research, then retrieve its result
shipglows-parallel research run --input "Compare competitor content coverage for topic X" --processor pro
shipglows-parallel research result --run-id trun_...

# Create and manage a daily competitor/news watch
shipglows-parallel monitor create --query "New product launches and pricing changes from example.com" --frequency 1d --include-domain example.com
shipglows-parallel monitor list
```

`--query` may be repeated up to five times. The API recommends concise three-to-six-word queries and two or three queries for best results; `--objective` adds context. `--domain` only marks exact-domain and subdomain matches in the response. The request uses Parallel's `fast` mode by default, which supports broader multilingual queries; `turbo`, `basic`, and `advanced` are available explicitly. Parallel currently documents `turbo` language support as English and Japanese only.

The optional installer link is created by `cli/install.sh` when the repository launcher exists. The system-wide installer was not run as part of implementation.

Extract accepts 1–20 distinct public HTTP(S) URLs per call. Repeat `--url` for multiple pages. By default the API returns objective-focused excerpts; `--full-content` requests complete page markdown via `advanced_settings.full_content`. Extract handles public JavaScript-rendered pages and PDFs. `errors` in the output must be checked because an individual URL can fail while other pages succeed. Full content can make responses large; the CLI caps the response at 4 MiB. Do not submit private, authenticated, or sensitive URLs.

Search can restrict results to up to ten included or excluded domains, filter publication dates with `--after-date`, localize using a two-letter country code, or set `--max-results`. Domain inclusion and exclusion are mutually exclusive. These are source discovery controls, not Google SERP measurements.

`research run` submits a Task run and returns its `run_id`; `research status` checks progress and `research result` retrieves the completed output. Text output produces a cited markdown report; `--output auto` delegates structured output selection to Parallel. Deep Research may take minutes and has processor-dependent cost; check current [Task pricing](https://docs.parallel.ai/getting-started/pricing) before choosing a high tier. Runs are created remotely, but this CLI does not persist the IDs locally.

`monitor create` creates a recurring `event_stream` that starts immediately and then runs on its schedule. `monitor list|get|events|cancel` inspect and manage it. Cancellation is permanent and requires the explicit `--confirm` flag. Optional webhooks must be public HTTPS URLs; avoid putting secrets in webhook query strings. Monitor tracks new changes from creation onward, not historical coverage. Recurring monitors can incur ongoing charges; cancel watches that are no longer useful.

## Request and output

- Search uses `POST https://api.parallel.ai/v1/search`; Extract uses `/v1/extract`; Task runs use `/v1/tasks/runs`; Monitor uses `/v1/monitors`. All use HTTPS and `x-api-key` authentication.
- One API call per command invocation, sent through a single helper (`send_request`) with bounded retries: up to 3 attempts with exponential backoff and jitter (about 1 s then 2 s) on network failures (`URLError`, `TimeoutError`, `OSError`, dropped connections) and HTTP 429/502/503/504. A `Retry-After` header sets the wait; above 60 s the CLI stops instead of waiting. Other 4xx errors (400, 401, 403, 404…) are never retried. Search, Extract and every GET are retried; `research run`, `monitor create` and `monitor cancel` make a single attempt so a lost response never creates or charges a resource twice. No local result persistence. Monitor runs recur remotely according to the selected frequency; monitor-list pagination is not followed automatically.
- Redirects are rejected so the authenticated request is not forwarded to another host.
- Search JSON contains provider, search ID, objective, input queries, selected mode, applied filters, and normalized results (position in Parallel relevance order, title, URL, date, excerpts, optional domain match). Extract JSON contains provider, extract ID, objective, whether full content was requested, normalized excerpts/full content, and per-URL errors. Task and Monitor commands preserve provider response fields, including status, research basis, citations, confidence, monitor ID, and event IDs.
- Each response body is capped at 4 MiB. The per-attempt network timeout comes from `--timeout <seconds>` on any subcommand, else `SHIPGLOWS_PARALLEL_TIMEOUT`, else the command default (30 seconds for Search, 60 for Extract, 45 for Task run/Monitor, 90 for Task status/result); values must be above 0 and at most 600. Errors are non-zero, bounded, and redact the API key. A final network error names the exception and its short reason (for example `URLError/gaierror` for DNS, `URLError/ConnectionRefusedError`, `URLError/SSLError`, `TimeoutError`), the number of attempts made, and the timeout; HTTP errors give the status, provider message and attempt count.
- API results and search terms go to Parallel. Do not submit sensitive or personal queries.

## Cost and limits

Search's current pricing lists `fast` and `turbo` at **$1 per 1,000 requests** and `basic` and `advanced` at **$5 per 1,000**. This CLI defaults Search to `fast`. Task processors have separate rates, and active Monitors can create recurring usage. Pricing and quotas can change; verify [current pricing](https://docs.parallel.ai/getting-started/pricing) before repeated use. No Task run or Monitor was created during implementation.

## Validation

```bash
python -m unittest tools.test_shipglows_parallel
python tools/shipglows_parallel.py --help
bash -n cli/shipglows-parallel.sh cli/install.sh
python tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/parallel-web-search-cli.md shipglows_data/technical/parallel-web-search-cli.md
```

The tests use fake HTTP transport and make no provider request. Use `doppler run --` for these commands when a project/config is selected for the repository. This checkout currently has no selected Doppler project, and these tests need no secrets. A live lookup is a separate operator action requiring `PARALLEL_API_KEY` and consuming account quota.

## Official references

- [Parallel Search API quickstart](https://docs.parallel.ai/search/search-quickstart)
- [Parallel Search API reference](https://docs.parallel.ai/api-reference/search/search)
- [Parallel Search modes](https://docs.parallel.ai/search/modes)
- [Parallel pricing](https://docs.parallel.ai/getting-started/pricing)
- [Parallel Extract quickstart](https://docs.parallel.ai/extract/extract-quickstart)
- [Parallel Extract best practices](https://docs.parallel.ai/extract/best-practices)
- [Search vs. Extract](https://docs.parallel.ai/search/migrate-to-parallel)
- [Parallel Search best practices](https://docs.parallel.ai/search/best-practices)
- [Task API quickstart](https://docs.parallel.ai/task-api/task-quickstart)
- [Task API deep research](https://docs.parallel.ai/task-api/examples/task-deep-research)
- [Monitor API quickstart](https://docs.parallel.ai/monitor-api/monitor-quickstart)

## Maintenance rule

Update this guide when the endpoint, authentication, response contract, mode pricing, key handling, command registration, or validation changes. Keep Parallel search relevance separate from Google SERP snapshots and Search Console metrics.
