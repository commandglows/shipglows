---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-10-01"
created_at: "2026-10-01 13:39:14 UTC"
updated: "2026-10-01"
updated_at: "2026-10-01 13:54:11 UTC"
status: reviewed
source_skill: 100-sg-spec
source_model: GPT-6.1 Codex
scope: serpapi-google-serp-cli
owner: Diane
user_story: "As a ShipGlows SEO operator, I want to query Google SERPs for a chosen keyword and locale from a small CLI so that I can inspect Claiire's current organic result positions separately from Search Console performance data."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - SerpApi Google Search API
  - tools/shipglows_serp.py
  - cli/shipglows-serp.sh
  - cli/install.sh
  - tools/test_shipglows_serp.py
  - shipglows_data/technical/serpapi-google-serp-cli.md
  - shipglows_data/technical/README.md
  - shipglows_data/technical/code-docs-map.md
  - shipglows_data/technical/google-search-console-cli.md
depends_on: []
supersedes: []
evidence:
  - "SerpApi official Google Search API documentation checked 2026-10-01: GET https://serpapi.com/search with engine=google, q and api_key; location/gl/hl/device can shape a localized result set."
  - "SerpApi official pricing and API docs checked 2026-10-01: a free tier currently advertises 250 searches per month; successful uncached searches count toward usage while cached searches are free. The CLI leaves provider caching enabled. No paid plan, account change, or live query is authorized by this spec."
  - "Operator approved 2026-10-01: formalize and implement a separate shipglows-serp command, docs, and simulated tests without a billed API call."
next_step: "For live-provider proof, run one intentional query after the operator supplies SERPAPI_API_KEY through an approved local secret environment."
next_review: "2026-11-01"
---

# Spec: SerpApi Google SERP CLI

## Status

Implemented contract for one read-only, one-request-per-invocation SERP query. It complements but does not merge with the existing Google Search Console CLI. Local fake-transport validation passed; a live authenticated provider query remains unverified.

## User Story

As a ShipGlows SEO operator, I want to query Google SERPs for a chosen keyword and locale from a small CLI so that I can inspect Claiire's current organic result positions separately from Search Console performance data.

## Minimal Behavior Contract

Given an explicit search term and a locally supplied `SERPAPI_API_KEY`, `shipglows-serp search` makes exactly one HTTPS Google Search request to SerpApi using validated locale, device, optional location, and optional domain parameters; it returns normalized organic results as JSON and optional matching-domain positions. Without valid inputs, a key, a usable network/API response, it exits non-zero with an actionable diagnostic that does not expose the key. It never stores credentials, retries, loops through keyword lists, or mutates an account or website.

## Success Behavior

- One explicit command produces one SerpApi Google Search API request.
- Country/language/device defaults are France/French/desktop and can be overridden; an optional city-level location and target domain are supported. SerpApi's default result count is retained.
- JSON output includes the query, requested locale/device, organic result positions, titles, links, snippets, and optional exact-or-subdomain matches for the normalized target domain.
- The result is a time/location/device-specific SERP observation, not Search Console impressions, durable average position, or a guarantee of what every user sees.
- Each invocation is visible to the operator; no background schedule, keyword batch, hidden pagination, or account mutation occurs.

## Error Behavior

- Missing API key, empty query, invalid country/language/device/domain input, timeout, network failure, HTTP error, malformed JSON, and SerpApi application error all produce a non-zero status and safe diagnostic.
- The API key is never printed, included in normalized output, stored on disk, or copied into docs/tests. Any occurrence reflected by a provider error is redacted.
- No automatic retry is issued, so failures cannot silently multiply quota usage.

## Problem

Search Console reports actual query impressions/clicks/average positions for a verified property; it does not provide an arbitrary keyword-to-current-SERP lookup. SerpApi's API can provide that separate observation. A new operator needs a small discoverable CLI interface without coupling SERP snapshots to OAuth-backed GSC workflows.

## Solution

Add a standard-library Python command `shipglows-serp` and repository wrapper `cli/shipglows-serp.sh`. The command reads `SERPAPI_API_KEY` from the process environment and makes one GET request to the documented SerpApi endpoint. Keep the GSC implementation and auth/profile store untouched.

## Scope In

- One `search` command with query, country, language, device, optional location, and optional target domain.
- Normalized JSON response with organic results and target-domain rank matches.
- Environment-only API key handling, safe error handling, and explicit one-request semantics.
- Installer wrapper/alias registration and internal technical docs/map updates.
- Focused tests with injected fake HTTP openers; no network call or SerpApi credit used in automated proof.

## Scope Out

- ChatGPT/Codex MCP setup, hosted MCP server, or custom MCP adapter.
- API-key signup, account login, paid subscription, Doppler secret creation, or secret persistence.
- Search Console OAuth, impressions, traffic metrics, sitemap/URL inspection, or changes to `shipglows-gsc` behavior.
- Scheduled tracking, keyword batches, pagination, result history/database, competitor dashboards, search-volume estimates, or automated SEO conclusions.
- A claim that one localized query is a universal or stable ranking measurement.

## Constraints

- Python standard library only; no new package dependency.
- Official endpoint is HTTPS `https://serpapi.com/search`; `engine=google`, query `q`, and SerpApi `api_key` are required. Use `location`, `gl`, `hl`, and `device` only as documented. Retain SerpApi's default result count; its current Google Search API docs do not document a `num` parameter.
- API keys arrive only via `SERPAPI_API_KEY`; do not add an environment file or a Doppler project mapping as part of this change.
- Preserve provider default caching. One process invocation sends no more than one request; cached searches may be free under current provider rules.
- Keep output to the fields needed for operator SERP inspection; do not dump request URLs or raw error bodies.
- The command does not ask for or trigger a paid plan; the operator remains responsible for their account limits and costs. Current SerpApi docs state that cached searches are free and successful uncached searches count toward monthly usage.

## Test Contract

- Surface/profile: local Python CLI on the available Windows development environment; standard-library unit tests with an injected fake opener.
- Automated proof: argument validation, URL encoding/localization, one request, domain/subdomain matching, missing-key behavior, timeout/HTTP/provider errors, secret redaction, CLI JSON and exit codes, Bash wrapper syntax, installer syntax, metadata lint, and diff hygiene.
- Live/provider proof: explicitly excluded; no API key or external request is needed to verify this code contract.
- Manual proof: `--help` and missing-key behavior can run without credentials. A real keyword lookup remains operator-run after separately setting their API key and accepting provider quota use.
- No browser, auth, hosted, site mutation, build, or deployment proof applies.

## Dependencies

- Python standard library (`argparse`, `json`, `os`, `sys`, `urllib`).
- SerpApi's HTTPS Google Search API and an operator-provisioned account key at invocation time.
- Bash for the POSIX repository wrapper and existing installer command-link setup.

## Invariants

- GSC remains the source for Search Console performance data; SerpApi is a separate SERP snapshot source.
- No key is committed, persisted, echoed, included in returned JSON, or placed in an example.
- A command invocation performs at most one request, never retries or paginates, and remains read-only.
- Target-domain matching uses hostname equality or a dot-delimited subdomain suffix, preventing lookalike suffix matches.
- `shipglows-serp` on PATH resolves through the existing repository installer to this repo's launcher.
- Errors remain actionable without leaking a credential, full request URL, or unbounded provider body.

## Links & Consequences

- Upstream: SerpApi Google Search API request/response contract and the operator's external account/quota.
- Adjacent: `shipglows-gsc` and its guide stay independent; documentation must explain which question each tool answers.
- Downstream: SEO operators can inspect one localized SERP and compare its organic results to site content and Search Console evidence.
- No data write or cross-system synchronization exists; retesting needs only local unit tests unless endpoint parameters change.

## Documentation Coherence

Update `shipglows_data/technical/serpapi-google-serp-cli.md`, the technical-docs index, and `code-docs-map.md`. Cross-link the existing GSC guide to explain the distinction without changing its OAuth contract. Do not add SerpApi secrets or public product claims.

## Edge Cases

- Missing/blank key and blank/whitespace-only query.
- URL-encoded Unicode query/location.
- Apex domain, valid subdomain, and deceptive suffix hostname.
- Missing or malformed `organic_results` yields a valid empty result list, not a crash.
- HTTP 401/429/5xx, provider error in HTTP 200, timeout, unreadable JSON, and an error body containing the exact API key.

## Implementation Tasks

1. [x] Add scenario-first tests for one-request behavior, parameter encoding, rank matching, safe output, bounded responses, and failure classes.
2. [x] Implement the standard-library SerpApi adapter/CLI with strict input handling, bounded response parsing, secret redaction, and stable exit codes.
3. [x] Add the repository wrapper and register a `shipglows-serp` installer alias without changing existing GSC aliases.
4. [x] Write the internal setup/usage/security/evidence guide and update technical index, code-doc map, root README entry, and GSC cross-link.
5. [x] Run the focused mocked tests, metadata lint, shell syntax, CLI help/missing-key behavior, and scoped diff checks. No project/config is selected in Doppler for this repository; tests use a dummy key and fake HTTP opener only, so no secret injection or provider request was needed.

## Acceptance Criteria

- [x] Missing key and invalid parameters fail before network I/O with no credential disclosure.
- [x] Valid invocation issues exactly one HTTPS request with correctly encoded documented parameters.
- [x] `--domain claiire.fr` matches `claiire.fr` and its subdomains but not `fakeclaiire.fr`.
- [x] Only normalized organic result data is returned; provider error text is bounded and key-redacted.
- [x] HTTP, timeout, provider-status, oversized-response, and malformed-response failures exit non-zero and trigger no retry.
- [x] Installer source exposes `shipglows-serp` from the repository launcher and preserves current GSC aliases; system-wide installation was not run.
- [x] Documentation distinguishes a current SERP snapshot from Search Console query/impression/average-position metrics.
- [x] All automated tests use a fake opener and make no provider request.

## ZOMBIES Coverage

- Zero: absent credentials and empty/malformed provider results.
- One: a normal localized search produces one normalized response.
- Many: organic items retain distinct positions and matching pages.
- Boundaries: domain apex/subdomain/lookalike and URL-encoded Unicode.
- Interfaces: CLI -> wrapper -> Python parser -> HTTPS SerpApi -> normalized JSON; installer PATH registration.
- Exceptions: network/timeout/HTTP/application/JSON failures return safe non-zero diagnostics.
- Security: malicious shell-like input remains data in URL encoding; provider output cannot reflect the API key; oversized bodies are bounded.

## OWASP Security Gate

- Categories considered: A02 Security Misconfiguration (secret/environment boundary), A03 Software Supply Chain Failures (no package changes), A05 Injection (URL parameter encoding), A06 Insecure Design (request/quota bounds), A09 Security Logging and Alerting Failures (diagnostic redaction), A10 Mishandling of Exceptional Conditions (timeouts and deterministic failures); other categories are not applicable to this local read-only CLI without identity, tenant, server-side access control, or persistence.
- Trust boundaries: local CLI process/environment, outbound TLS request, SerpApi, third-party search response, and operator terminal/log capture.
- Authorization: possession of an operator-supplied API key authorizes only the vendor's configured account; the CLI makes no account changes. The operator chooses whether to execute a real query.
- Selected ASVS: not applicable as an application-server conformance claim; tests directly prove the local outbound client's bounded parameters, no-persistence behavior, and redaction.
- Residual risk: SerpApi receives the query; successful uncached requests may count toward quota while cached searches are free under current provider docs. The API key is required in the query string, so the client must avoid logging full URLs and never emit request objects.

## Test Strategy

Test-first using the injected opener seam; run `python -m unittest tools.test_shipglows_serp` under a confirmed development/staging Doppler project/config if one is declared for this repository. Also run `bash -n cli/shipglows-serp.sh cli/install.sh`, source and launcher `--help`, the missing-key path, targeted metadata lint, and scoped `git diff --check`. Never run a real provider request during automated validation.

## Validation Evidence

- `python -m unittest tools.test_shipglows_serp`: 10 tests passed using a fake HTTP opener.
- Targeted metadata lint: this spec and five impacted technical guides/maps passed (6 files).
- `bash -n cli/shipglows-serp.sh cli/install.sh`: passed.
- Source and repository launcher `--help` rendered; the launcher missing-key path exited non-zero with a clear message before network I/O.
- Scoped `git diff --check`: passed. The repository-wide check also found a trailing-space line in unrelated `shipglows_data/business/project-competitors-and-inspirations.md:40`; it was preserved.
- Doppler has no selected project/config in this repository. Mocked tests needed no secrets; no live provider request or installer system mutation was performed.

## Risks

- Search results vary by time, geo, language, device, and provider processing. Mitigate by echoing requested dimensions and describing output as a snapshot, never as universal ranking truth.
- Credential query parameters can leak if URLs are logged. Mitigate with one central request function, generic network errors, bounded provider messages, and a regression test for key redaction.
- Repeated uncached invocations consume account quota. Mitigate with exactly one visible request per command and no retries, pagination, background scheduling, or hidden keyword batches; preserve provider caching.
- A local API-key environment variable can be inherited by child processes. Mitigate by reading it only inside the CLI process and not printing or persisting it; safe provider-environment setup remains operator-owned.

## Execution Notes

- First-read: `tools/shipglows_gsc.py`, `tools/test_shipglows_gsc.py`, `cli/shipglows-gsc.sh`, `cli/install.sh`, `shipglows_data/technical/google-search-console-cli.md`, and `shipglows_data/technical/code-docs-map.md`.
- Approach: stdlib-only standalone sibling command, scenario-first fake transport, then docs and registration.
- Stop if implementation requires a new dependency, stored credential/account operation, a live provider call, a paid plan, scheduled/batch tracking, or a change to GSC OAuth behavior.

## Open Questions

None within the approved one-query read-only CLI. A real API key and account/quota choice are intentionally operator-owned and are not needed for implementation proof.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
| --- | --- | --- | --- | --- | --- |
| 2026-10-01 13:39:14 UTC | 100-sg-spec | GPT-6.1 Codex | Defined the approved SerpApi sibling CLI, one-request/quota boundary, environment-only key handling, normalized results, documentation, and mocked proof. | reviewed | Run readiness review. |
| 2026-10-01 13:43:34 UTC | 101-sg-ready | GPT-6.1 Codex | Confirmed the documented HTTPS endpoint/parameters, cache and quota semantics, key redaction constraints, bounded scope, and mocked validation path. | ready | Implement tests, CLI, wrapper, installer exposure, and docs. |
| 2026-10-01 13:54:11 UTC | 102-sg-start | GPT-6.1 Codex | Implemented the standard-library client, fake-transport tests, wrapper/installer alias, and mapped docs without a key or provider call. | implemented | Verify code/docs; real-provider proof remains operator-controlled. |
| 2026-10-01 13:54:11 UTC | 103-sg-verify | GPT-6.1 Codex | Passed 10 mocked tests, metadata lint, shell syntax, CLI help/missing-key, and scoped diff checks; no live-provider key was available or used. | partial | One real localized lookup is needed to prove current account authentication and provider interoperability. |

## Current Chantier Flow

| Stage | Status | Note |
| --- | --- | --- |
| 100-sg-spec | completed | Contract is bounded to one read-only query and no live key/provider call. |
| 101-sg-ready | completed | Official provider behavior and security/proof boundaries support implementation. |
| 102-sg-start | completed | Implementation, tests, wrapper, installer alias, and mapped docs are in place. |
| 103-sg-verify | partial | Local contract proof passed; real provider authentication/results remain unverified. |
| 104-sg-end | pending | Reflect docs, security and outstanding live-provider limit. |
| 005-sg-ship | not authorized | No commit, push, billing, or deployment authorized. |
