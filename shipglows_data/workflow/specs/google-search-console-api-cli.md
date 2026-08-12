---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-07-14"
created_at: "2026-07-14 18:55:00 UTC"
updated: "2026-08-04"
updated_at: "2026-08-12 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: "official Google Search Console API command-line client"
owner: Diane
user_story: "As a ShipGlows operator, I want a local CLI that reads my verified Google Search Console data so SEO agents can turn real query and page performance into a prioritized improvement backlog."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - Google Search Console API
  - tools/
  - cli/shipglows-gsc.sh
  - cli/install.sh
  - skills/406-sg-seo/SKILL.md
  - skills/references/operator-roles/seo-specialist.md
  - README.md
  - shipglows_data/technical/runtime-cli.md
depends_on:
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Wave 20 reclassifies Google Search Console API as an external linked system; documentation-freshness-gate remains the local executable dependency governing current official-source verification."
  - "Local Codex configuration contains a disabled third-party GSC MCP; ShipGlows has no canonical first-party GSC CLI."
  - "Google official docs expose OAuth-protected Search Analytics, Sites, Sitemaps, and URL Inspection endpoints."
  - "Research report: shipglows_data/workflow/research/google-search-console-mcp-api-cli-audit.md"
next_step: "/102-sg-start google-search-console-api-cli"
---

# Google Search Console API CLI

## Title

Google Search Console API CLI

## Status

Ready for implementation.

## User Story

As a ShipGlows operator, I want a local CLI that reads my verified Google Search Console data so SEO agents can turn real query and page performance into a prioritized improvement backlog.

## Minimal Behavior Contract

`shipglows-gsc` accepts a locally supplied Google OAuth desktop-client configuration, obtains explicit operator consent for a verified Search Console property, and stores the resulting refresh token outside the repository with owner-only permissions. It can list properties, query performance metrics, list sitemaps, and inspect a URL in read-only mode, returning JSON suitable for an agent or a human. Invalid inputs, missing permission, expired or revoked consent, and Google API failures must return an actionable error without printing credentials or making any write request; a missing local callback must never leave a partial credential file behind.

## Success Behavior

- `auth login` opens a local browser-consent flow using a desktop OAuth client secret file supplied by the operator.
- An authorized operator can list GSC properties and query clicks, impressions, CTR, and average position by page/query/date/device/country.
- Outputs are valid JSON on stdout; diagnostics go to stderr.
- Tokens live only in the user configuration directory with mode `0600` and are never added to Git, logs, or report artifacts.
- All default operations use `webmasters.readonly`; no sitemap submission or mutation command is included in v1.

## Error Behavior

- A non-desktop client secret, malformed JSON, missing callback code, invalid property, missing scope, or non-2xx Google response exits non-zero with a redacted, actionable message.
- `auth login` removes its temporary local callback server and does not overwrite an existing token until token exchange succeeds.
- Commands requiring authentication refuse to run without an authorized profile; they instruct the operator to run `shipglows-gsc auth login`.
- The CLI must never echo authorization codes, access tokens, refresh tokens, client secrets, or request authorization headers.

## Problem

The current SEO role can audit local content but cannot obtain the GSC evidence that distinguishes a promising page update from a generic recommendation. A third-party MCP is configured but disabled; it is not a governed, official integration path.

## Solution

Add a ShipGlows-owned Python standard-library CLI wrapping the official Search Console REST API. Keep v1 read-only, OAuth-scoped minimally, and explicit about the profile and property used.

## Scope In

- `shipglows-gsc` executable wrapper and Python implementation.
- OAuth installed-app login, logout, and status using an operator-provided client-secret file.
- Read-only `sites`, `performance`, `sitemaps`, and `inspect` commands.
- Strict secret redaction, file-permission handling, validation, tests, README/operator guidance, and installer wrapper registration.
- A JSON evidence format that `406-sg-seo` can consume in a later follow-up.

## Scope Out

- Enabling or replacing the existing third-party GSC MCP.
- Google Cloud project/client creation, consent-screen publication, or operator account setup.
- Sitemap submission, URL indexing requests, deletion, or any other GSC write action.
- GA4, DataForSEO, scheduling, database storage, dashboards, or automatic changes to site content.
- Automatic use by `406-sg-seo` until an explicit evidence-ingestion contract is added.

## Constraints

- Python 3 standard library only; no global package installation.
- Official endpoints only: `www.googleapis.com/webmasters/v3` and `searchconsole.googleapis.com/v1`.
- Default scope: `https://www.googleapis.com/auth/webmasters.readonly`.
- Token directory: `${XDG_CONFIG_HOME:-$HOME/.config}/shipglows/gsc/`, never a repository path.
- OAuth requires an operator-owned Google OAuth desktop-client JSON file and property access; this is a documented precondition, not a secret ShipGlows can fabricate.

## Test Contract

- Proof discipline: test-first for request construction, credential handling, validation, and response parsing.
- Surface: Python local CLI plus root/install shell wrappers.
- Proof profile: automated unit tests -> wrapper syntax/help -> operator-owned OAuth and read-only API smoke proof.
- Proof order: `python3 -m unittest` -> `bash -n` -> `shipglows-gsc --help` -> authorized `auth login` -> `sites` -> bounded `performance` query.
- Checklist path: no durable manual test checklist in v1; the live proof is operator-owned and must be recorded in the consuming project or change run.
- Required scenario IDs: `GSC-001` login, `GSC-002` sites, `GSC-003` performance, `GSC-004` revoked/missing authorization, `GSC-005` malformed input.
- Required results: `GSC-001` through `GSC-003` demonstrate read-only success; `GSC-004` and `GSC-005` demonstrate redacted, actionable failure without state mutation.
- Automated proof: focused Python unit tests with a mocked HTTP opener; shell syntax checks for wrappers/installer.
- Manual proof: an operator-authorized `auth login`, `sites`, and a read-only `performance` invocation against a non-production test property or selected production property.
- Exception with proof: live OAuth cannot run in CI because it requires an operator Google account; tests must cover the local state machine without tokens.

## Dependencies

- Google Search Console API, official current docs: `https://developers.google.com/webmaster-tools/v1/api_reference_index` and `https://developers.google.com/webmaster-tools/v1/how-tos/authorizing`.
- Fresh-docs verdict: `fresh-docs checked` on 2026-07-14; OAuth 2.0 is required for GSC user data and the selected endpoints support the read-only scope.

## Invariants

- No write HTTP method or write OAuth scope in v1.
- Credentials, headers, tokens, authorization codes, and client secret values never reach stdout, stderr, test fixtures, Git, or Markdown reports.
- JSON success output remains machine-readable and has no progress chatter.
- An operator must name the property for performance/sitemap/inspection reads; no implicit property selection.
- `gcloud` is not used as a credential store or hidden dependency.

## Links & Consequences

- `tools/shipglows_gsc.py` becomes the implementation source of truth.
- `cli/shipglows-gsc.sh` is the repository wrapper; installer creates `/usr/local/bin/shipglows-gsc` and `gsc` aliases when present.
- `README.md` and `shipglows_data/technical/runtime-cli.md` must document the client’s local-only credential model.
- `406-sg-seo` remains unchanged in v1 except for a documented future handoff path; it must not claim live data access until an explicit ingestion invocation exists.

## Documentation Coherence

- Update `README.md` with prerequisites, read-only scope, commands, and security boundary.
- Update `shipglows_data/technical/runtime-cli.md` and `shipglows_data/technical/code-docs-map.md` for new CLI ownership and validation.
- Create a focused technical guide for OAuth setup and command examples.

## Edge Cases

- Domain property uses `sc-domain:example.com`; URL-prefix property requires exact encoded origin.
- Recent GSC data may be incomplete; output exposes Google’s `metadata` object unchanged.
- Empty performance result is a valid JSON success, not an error.
- OAuth callback state mismatch, port bind failure, revoked refresh token, and malformed Google error payload must fail safely.
- URL inspection requires a fully qualified URL and a property owned by the authorized account.

## Implementation Tasks

- [x] Task 1: Add the standard-library GSC client and tests.
  - Files: `tools/shipglows_gsc.py`, `tools/test_shipglows_gsc.py`
  - Action: Implement OAuth, secure local credential persistence, REST requests, input validation, JSON output, and mocked tests.
  - User story link: obtain reliable GSC evidence without third-party MCP coupling.
  - Depends on: none.
  - Validate with: `python3 -m unittest tools.test_shipglows_gsc`.
- [x] Task 2: Add a stable executable wrapper and installer registration.
  - Files: `cli/shipglows-gsc.sh`, `cli/install.sh`
  - Action: Route to the canonical Python client and install aliases only when the source exists.
  - User story link: make the capability available to operators after standard install.
  - Depends on: Task 1.
  - Validate with: `bash -n cli/shipglows-gsc.sh cli/install.sh` and wrapper `--help`.
- [x] Task 3: Document runtime ownership and secure usage.
  - Files: `README.md`, `shipglows_data/technical/runtime-cli.md`, `shipglows_data/technical/code-docs-map.md`, `shipglows_data/technical/google-search-console-cli.md`
  - Action: Add the OAuth precondition, read-only boundary, commands, validation route, and mapped technical ownership.
  - User story link: prevent unsafe or misleading use by agents and operators.
  - Depends on: Tasks 1-2.
  - Validate with: metadata lint and targeted path/link checks.
- [x] Task 4: Connect read-only GSC acquisition to the SEO monitoring skill.
  - Files: `skills/406-sg-seo/SKILL.md`, `skills/406-sg-seo/references/gsc-evidence-workflow.md`, `skills/406-sg-seo/README.md`
  - Action: Load live GSC evidence when already authorized, use the repository wrapper without a PATH dependency, and retain supplied exports as the safe fallback.
  - User story link: let SEO agents improve current content from actual Search Console feedback without claiming unavailable access.
  - Depends on: Tasks 1-3.
  - Validate with: metadata lint, skill budget audit, sync check, and focused routing assertions.

## Acceptance Criteria

- [ ] Given a valid desktop OAuth client-secret file, when an operator runs `auth login`, then consent is requested with only `webmasters.readonly` and a mode-`0600` credential profile is created outside the repository.
- [ ] Given a valid authorized profile, when an operator runs `sites`, then the CLI emits valid JSON containing only API response data and no secrets.
- [ ] Given a property and date range, when an operator runs `performance`, then the request uses `searchAnalytics/query` and returns clicks, impressions, CTR, position, keys, and Google metadata where present.
- [ ] Given a URL-prefix or domain property, when an operator requests `sitemaps` or `inspect`, then the property identifier is URL encoded correctly and read-only API endpoints are used.
- [ ] Given missing/revoked authorization or an invalid input, when any protected command runs, then it exits non-zero, explains the remediation, and creates no partial state.
- [x] Given a repository checkout, when unit tests and wrapper syntax checks run, then all pass without network access or OAuth credentials.

## Test Strategy

- Unit-test OAuth config parsing, token path permissions, URL encoding, request body construction, API error redaction, and each parser path with mocked HTTP responses.
- Run `python3 -m unittest tools.test_shipglows_gsc` and `bash -n` against changed shell files.
- Run metadata lint for changed governance artifacts and a focused `rg` check for credential/token logging regressions.
- Document, but do not automate, operator-owned live OAuth proof.

## Risks

- OAuth client configuration and property permissions are external/operator-owned; implementation must provide explicit setup failure guidance.
- Refresh tokens are sensitive; local file mode and redaction are mandatory, but host compromise remains outside this CLI’s control.
- GSC data is sampled/bounded and recent data can change; the CLI must not report rankings or causality as certain.
- Installer changes affect global command exposure; preserve all existing aliases and do not install packages.

## Execution Notes

- Read first: `cli/install.sh`, `README.md`, `shipglows_data/technical/runtime-cli.md`, `tools/shipglows_metadata_lint.py`.
- Keep HTTP transport in an injectable function for offline tests.
- Use `argparse`, `urllib`, `http.server`, `json`, `secrets`, and `pathlib`; do not add a dependency manager or package registry change.
- Do not automatically mutate Codex MCP configuration or enable `mcp_servers.gsc`.
- Stop implementation if the official OAuth documentation conflicts with the installed-app callback design.

## Open Questions

None for v1: an operator-provided desktop OAuth client is an explicit prerequisite, not an implementation decision.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-14 18:55:00 UTC | 100-sg-spec | GPT-5 Codex | Created the read-only official GSC API CLI contract from the prior MCP/API audit. | implemented | /101-sg-ready shipglows_data/workflow/specs/google-search-console-api-cli.md |
| 2026-07-14 19:02:00 UTC | 101-sg-ready | GPT-5 Codex | Reviewed security, OAuth preconditions, scope boundaries, automated/manual proof, and implementation ordering. | ready | /102-sg-start google-search-console-api-cli |
| 2026-07-14 19:15:00 UTC | 102-sg-start | GPT-5 Codex | Implemented the read-only GSC CLI, offline tests, wrapper, installer aliases, and technical documentation. | implemented | /103-sg-verify google-search-console-api-cli |
| 2026-08-10 05:15:00 UTC | 001-sg-build | GPT-5 Codex | Confirmed no official Google/OpenAI GSC CLI, MCP, or Codex plugin and connected the API-backed CLI to SEO monitoring with a safe evidence fallback. | implemented | /103-sg-verify google-search-console-api-cli |

## Current Chantier Flow

`100-sg-spec` complete -> `101-sg-ready` complete -> `102-sg-start` complete -> `103-sg-verify` pending -> `104-sg-end` pending -> `005-sg-ship` pending
