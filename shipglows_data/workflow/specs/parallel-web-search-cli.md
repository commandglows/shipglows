---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-01"
created_at: "2026-10-01 19:15:46 UTC"
updated: "2026-10-20"
updated_at: "2026-10-20"
status: implemented
source_skill: 100-sg-spec
source_model: GPT-6.1 Codex
scope: parallel-web-search-cli
owner: Diane
user_story: "As a ShipGlows SEO operator, I want one CLI for Parallel Search, Extract, deep research, and scheduled monitoring so I can discover sources, read pages, investigate topics, and track changes while keeping web research separate from Google ranking and Search Console performance data."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - Parallel Search API
  - Parallel Extract API
  - Parallel Task API
  - Parallel Monitor API
  - tools/shipglows_parallel.py
  - cli/shipglows-parallel.sh
  - cli/install.sh
  - tools/test_shipglows_parallel.py
  - shipglows_data/technical/parallel-web-search-cli.md
  - shipglows_data/technical/README.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/runtime-cli.md
  - README.md
depends_on: []
supersedes: []
evidence:
  - "Parallel official Search API docs checked 2026-10-01: POST https://api.parallel.ai/v1/search; x-api-key header; required search_queries; normalized result list ordered by relevance."
  - "Official mode/pricing docs checked 2026-10-01: fast mode costs $1 per 1,000 calls and is recommended for most agents; turbo is currently English/Japanese only; advanced is the API default at $5 per 1,000."
  - "Operator instruction 2026-10-01: add Parallel alongside the newly implemented SerpApi CLI; no live provider call or credential setup was requested."
next_step: "Run mocked implementation checks; live provider lookup remains operator-controlled."
next_review: "2026-11-01"
---

# Spec: Parallel Web Search CLI

## Status

Implemented as a CLI for Parallel Search, Extract, Task, and Monitor. Search returns Parallel relevance-ordered web sources and excerpts; the CLI does not measure Google SERP positions or Search Console performance. Local fake-transport proof is required; feature endpoint calls are out of scope during implementation.

## User story

As a ShipGlows SEO operator, I want a small CLI for Parallel Search so I can discover relevant web pages and excerpts while keeping web research separate from Google ranking and Search Console performance data.

## Minimal behavior contract

Given search terms, explicit public URLs, a research prompt, or a monitoring command and a locally supplied `PARALLEL_API_KEY`, `shipglows-parallel` calls the corresponding Parallel API and prints JSON. Search supports up to five queries and domain/date/location/result-count filters; Extract accepts 1–20 distinct HTTP(S) URLs and optional full content; Task creates and retrieves async cited runs; Monitor creates, lists, reads, inspects events, and explicitly cancels recurring monitors. It never saves credentials or persists output. Missing credentials, invalid inputs, provider failures, invalid JSON, and oversized bodies fail safely with a non-zero status.

## Success behavior

- Each invocation makes one provider call; Search, Extract, and GET calls retry transient failures (network errors, HTTP 429/502/503/504) up to 3 attempts with backoff and `Retry-After`, while Task run creation and Monitor create/cancel stay single-attempt. Task status/result checks are explicit separate commands.
- Requests use `x-api-key` auth and documented endpoint fields.
- `fast` is explicit default for multilingual search and currently priced at $1/1,000 calls; mode choices are available to the operator.
- Output normalizes provider results, preserves excerpt text, and assigns response-order positions. It labels the order as Parallel relevance rather than a Google SERP rank.
- Optional hostname matching supports apex and dot-delimited subdomains, not lookalike suffixes.
- Search source filters and geography are separate from Google SERP semantics.
- Monitor cancellation requires explicit `--confirm`; no live monitor is created during implementation.

## Error behavior and security

- Missing/blank API key, empty/too-long queries, more than five queries, oversized objective/response, timeout, network/HTTP error, application error, malformed JSON, and wrong response shape fail non-zero.
- The key is read only from `PARALLEL_API_KEY`, sent in the documented header, redacted from provider messages, and never returned or persisted.
- Redirects are rejected so the API key header is not forwarded to another host.
- Provider responses are bounded at 4 MiB and error diagnostics do not emit request headers, URL secrets, or raw unbounded bodies.
- Search terms and objective are transmitted to Parallel; sensitive queries are outside the intended use.

## Scope in

- Standard-library Python client with Search, Extract, Task research, and Monitor subcommands.
- Repository launcher, optional existing installer alias, normalized JSON, fake-transport tests, and internal docs/map updates.

## Scope out

- Real feature API calls during implementation/automated validation; paid-plan or account changes; API-key registration/storage or Doppler project setup.
- Parallel MCP setup, ChatGPT/Codex MCP connection, Monitor webhooks receiver, local scheduling, and persistent result storage.
- Google SERP measurement, GSC OAuth/performance reporting, keyword volumes, rank tracking, persistent result history, or automated SEO recommendations.
- New package dependencies or changes to SerpApi/GSC behavior.

## Constraints and provider contract

- Official endpoint: `POST https://api.parallel.ai/v1/search`, JSON body, `x-api-key` header.
- `search_queries` is required; docs allow 1-5 queries, up to 200 characters each. `objective` is optional and at most 5,000 characters. Modes: `turbo`, `fast`, `basic`, `advanced`.
- Fast mode is the default; official docs recommend it for most agents, supporting broader multilingual coverage. Turbo currently supports English/Japanese only. Official pricing checked 2026-10-01 lists fast/turbo at $1/1,000 requests, basic/advanced at $5/1,000; prices may change.
- Provider response results are relevance-ordered and can contain URL, title, date, and excerpts. Do not label their order as Google rank.
- Extract uses `POST https://api.parallel.ai/v1/extract`; `full_content` is requested inside `advanced_settings` and returned as markdown. Individual URL failures remain visible in `errors`.
- Search can configure `advanced_settings.source_policy`, `location`, and `max_results`.
- Task creates with `POST /v1/tasks/runs`, then status and results use separate documented GET endpoints; text reports include citations.
- Monitor creates `event_stream` resources with `POST /v1/monitors`; each begins a run immediately and repeats at the selected frequency. Cancellation uses `POST /v1/monitors/{monitor_id}/cancel`, is permanent, and requires `--confirm` in this CLI.
- No live request is needed for implementation proof and none is authorized by this spec.

## Test contract

- Python standard-library `unittest` with injected fake opener.
- Cover header/body, exactly-one-request contract, mode defaults, multiple queries/objective, domain match boundaries, missing key before I/O, invalid bounds, HTTP/network/application errors, malformed/oversized data, redaction, CLI JSON and exit codes, wrapper/installer syntax, metadata lint, and scoped diff hygiene.
- Never use real credentials or issue a provider request during tests.

## Documentation coherence

Update `parallel-web-search-cli.md`, technical index, code-doc map, runtime CLI guide, root README, and installer registration. State the cost and keep the provider's relevance order separate from SerpApi/GSC semantics.

## Open questions

None for the bounded one-request CLI. A real `PARALLEL_API_KEY` and account/quota choice are operator-owned and not required for implementation proof.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-10-01 19:15:46 UTC | 100-sg-spec | GPT-6.1 Codex | Defined a separate Parallel web search CLI, environment-only key, fast default, cost notice, one-request bound, and fake-only proof. | reviewed | Confirm readiness and execute. |
| 2026-10-01 19:15:46 UTC | 101-sg-ready | GPT-6.1 Codex | Verified endpoint, request fields, relevance semantics, multilingual mode limits, pricing, and bounded implementation scope against official docs. | ready | Implement client, tests, launcher, installer alias, and mapped docs. |
| 2026-10-01 19:21:59 UTC | 102-sg-start | GPT-6.1 Codex | Added the stdlib API client, one-request/fake-transport tests, no-redirect auth protection, launcher and optional installer alias, plus technical documentation and maps. | implemented | Run focused mocked validation; real provider lookup remains separately authorized. |
| 2026-10-01 19:21:59 UTC | 103-sg-verify | GPT-6.1 Codex | 13 fake-transport tests, metadata lint, Python compilation, Bash syntax, source/launcher help, and scoped diff check passed. Doppler invocation could not run because no project is selected; direct tests need no secrets. | partial | A single live Parallel query is still required to verify account authentication/provider interoperability; operator supplies the key and accepts quota use. |
| 2026-10-04 | sg-development | GPT-6.1 Codex | Added Extract command with excerpt/full-page markdown support, per-URL error preservation, bounds, tests, and mapped docs. | implemented | Run fake-transport validation; live provider lookup remains separately authorized. |
| 2026-10-04 | sg-development | GPT-6.1 Codex | Added Search source filters, Task research run/status/result, and Monitor create/list/get/events/cancel flows with explicit cancellation confirmation. | implemented | Focused local contract proof remains pending; do not create a real monitor during implementation. |

## Current Chantier Flow

| Stage | Status | Note |
|---|---|---|
| 100-sg-spec | completed | One-request read-only contract, cost disclosure, provider boundary, and proof scope are defined. |
| 101-sg-ready | completed | Official endpoint, modes, prices, relevance semantics, and API-key boundary verified. |
| 102-sg-start | completed | Client, launcher, installer alias, and mapped docs are in place. |
| 103-sg-verify | pending | Run focused fake-transport proof across new API contracts; live provider interoperability remains separately authorized. |
| 104-sg-end | pending | Do not claim full closure while provider proof remains open. |
| 005-sg-ship | not authorized | No commit, push, system install, provider call, or account change was requested. |

## Validation Evidence

- `python -m unittest tools.test_shipglows_parallel`: 13 tests passed; injected fake transport only.
- Python compilation, source and launcher `--help`, and `bash -n cli/shipglows-parallel.sh cli/install.sh`: passed.
- Targeted metadata lint: spec and technical guide passed.
- Scoped tracked-file `git diff --check`: passed; only line-ending notices were emitted.
- `doppler run -- python -m unittest tools.test_shipglows_parallel` could not run: Doppler reported no selected project and no fallback file. No secrets were requested or read; direct fake-only tests passed.
- No actual Parallel request, API key, system installer run, account change, commit, or push.
