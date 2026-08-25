---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "shipglows"
created: "2026-04-28"
created_at: "2026-04-28 20:30:00 UTC"
updated: "2026-08-25"
updated_at: "2026-08-25 13:53:00 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "audit-fix"
owner: "unknown"
user_story: "En tant qu'operateur ShipGlows, je veux durcir l'installation, reduire les hotspots de maintenance, planifier l'upgrade Astro de securite et rendre les tests fiables, afin de pouvoir shipper le framework sans dependre d'installations fragiles ni de signaux de validation ambigus."
confidence: medium
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "cli/install.sh"
  - "tests/install/supply-chain-contract.sh"
  - "lib.sh"
  - "shipglows-site/package.json"
  - "shipglows-site/pnpm-lock.yaml"
  - "tests/cli/json-error-handling.sh"
  - "README.md"
  - "CLAUDE.md"
  - "CHANGELOG.md"
depends_on:
supersedes: []
evidence:
  - "Historical migration-source provenance (legacy root documents): ARCHITECTURE.md, BRANDING.md, BUSINESS.md, GUIDELINES.md, PRODUCT.md."
  - "sg-audit-code 2026-04-28 found install.sh uses live remote install scripts/direct downloads and needs pinned, verified install steps and strict failure behavior."
  - "sg-audit-code 2026-04-28 found lib.sh is 5900+ lines and spans lifecycle, publishing, dashboard, inspector, secrets, and metadata behavior."
  - "npm audit --omit=dev in site reported Astro <6.1.6 vulnerable to GHSA-j687-52p2-xcff; forced fix would move to Astro 6."
  - "tests/cli/json-error-handling.sh exits 0 but reports 32/33 because the PM2 jq parsing fixture fails."
  - "Direct audit fixes already applied: DuckDNS input validation, encoded DuckDNS update requests, hardened secret writes, no default ImgBB upload key, Astro docs page build fix, and added validation tests."
next_step: "/sg-start Installer supply-chain hardening and ShipGlows codebase risk reduction"
---

## Title

Installer supply-chain hardening and ShipGlows codebase risk reduction

## Status

in progress — installer milestone (Tasks 1-3) implemented and verified; Tasks 4-9 remain

## User Story

En tant qu'operateur ShipGlows, je veux durcir l'installation, reduire les hotspots de maintenance, planifier l'upgrade Astro de securite et rendre les tests fiables, afin de pouvoir shipper le framework sans dependre d'installations fragiles ni de signaux de validation ambigus.

Story status: supported by `BUSINESS.md`, `PRODUCT.md`, `GUIDELINES.md`, `ARCHITECTURE.md`, and the 2026-04-28 code audit findings.

## Minimal Behavior Contract

When an operator prepares ShipGlows for release after the code audit, the system must replace fragile installer and validation paths with explicit, verifiable behavior: external installer inputs are pinned or checked before privileged execution, the Astro site dependency advisory is resolved through a documented major-version migration path, the JSON and error-handling test suite reports pass/fail consistently with its exit code, and the first `lib.sh` decomposition reduces risk without changing CLI behavior. If any dependency download, migration, test fixture, or extraction step cannot be verified, the implementation must stop with an actionable diagnostic and leave runtime behavior unchanged; the easy-to-miss edge case is a "green" command that still reports a failed subtest or a successful install that skipped a broken remote download.

## Success Behavior

- Preconditions: the repo is in the current mixed Bash + Astro shape, `cli/install.sh`, `cli/lib.sh`, `site/package*.json`, and `tests/cli/json-error-handling.sh` exist, and the direct audit fixes from 2026-04-28 remain present.
- Trigger: an implementer runs `/sg-start Installer supply-chain hardening and ShipGlows codebase risk reduction`.
- Operator-visible result: installer hardening changes are explicit in code and docs; the Astro advisory is resolved or deliberately blocked with evidence; `tests/cli/json-error-handling.sh` produces an exit code matching its displayed result; the first `lib.sh` extraction has no user-visible behavior change.
- System result: package lockfiles, shell scripts, and docs reflect the new contract; validation commands provide reliable pass/fail signals.
- Proof of success: `bash -n`, shell test suites, `pnpm --dir shipglows-site build`, `pnpm --dir shipglows-site audit --prod`, and focused installer dry-run or syntax checks pass with no hidden failed subtests.

## Error Behavior

- Invalid or unverifiable external install source: fail before privileged install or config mutation; print the dependency name, expected verification, and recovery command.
- Astro upgrade incompatibility: stop before shipping the dependency bump; keep the lockfile coherent; document the blocker in the spec or task tracker.
- JSON and error-handling fixture mismatch: the test must exit non-zero if it displays a failed required assertion, or explicitly mark the assertion skipped with a reason and not count it as failure.
- `lib.sh` extraction regression: revert only the new extraction in the implementer's branch or stop before commit; do not rewrite unrelated user changes.
- Never acceptable: logging secrets, silently ignoring failed downloads, broad refactors of `lib.sh`, a forced Astro upgrade without build verification, or a test suite that reports failure while exiting 0.

## Problem

The 2026-04-28 code audit found that ShipGlows is useful and coherent, but not ready for confident release in its current shape. The installer still depends on live remote scripts and direct downloads in privileged flows; `lib.sh` is a high-blast-radius procedural hotspot; the public site depends on an Astro version affected by a recent XSS advisory; and one test suite gives an ambiguous signal by exiting successfully while reporting a failed test.

## Solution

Implement a staged risk-reduction pass. First make installer execution fail closed and document the verification strategy for external sources. Then resolve the Astro advisory using official migration guidance and lockfile verification. Then fix the JSON and error-handling test signal. Finally perform only the first bounded `lib.sh` extraction that reduces future blast radius while preserving the current CLI contract.

## Scope In

- Harden privileged install behavior in `cli/install.sh` around external scripts, direct downloads, archive extraction, package installation, and failure handling.
- Add or update helper functions in `cli/install.sh` only where they reduce repeated unsafe install patterns.
- Upgrade or otherwise remediate `shipglows-site` Astro vulnerability in `shipglows-site/package.json` and `shipglows-site/pnpm-lock.yaml`.
- Update `shipglows-site/src/content.config.ts` only if Astro 6 or Zod 4 requires it.
- Fix `tests/cli/json-error-handling.sh` so displayed results, counted failures, skipped optional checks, and process exit code agree.
- Extract one bounded area from `lib.sh` only if the extraction has a clear source file, caller update, and regression test. Preferred first candidates are validation/security helpers or publish-related helpers already touched by the audit.
- Update README/GUIDELINES/CHANGELOG or related docs when installer, dependency, or validation behavior changes.

## Scope Out

- No full rewrite of `lib.sh`.
- No migration away from Bash.
- No replacement of PM2, Flox, Caddy, DuckDNS, or Astro as product dependencies.
- No broad redesign of the public site.
- No addition of a new package manager.
- No cleanup of unrelated dirty working tree files.
- No new supply-chain framework unless a simpler shell-native verification path is insufficient.

## Constraints

- Preserve current user-facing CLI behavior unless a task explicitly changes an error path.
- Do not revert existing uncommitted user edits.
- Keep installer changes compatible with the supported Ubuntu 24.04 server path unless a newer support contract supersedes it.
- Treat root install steps as high risk: validate before mutation and fail closed on unverifiable steps.
- Prefer shell-native checks, pinned URLs/versions, checksums/signatures where available, and explicit diagnostics.
- Keep `lib.sh` extraction small enough to review in one pass.
- Do not use `npm audit fix --force` blindly; Astro 6 is a major migration and must be validated.

## Dependencies

- Internal contracts:
  - `BUSINESS.md` 1.1.0 reviewed.
  - `BRANDING.md` 1.0.0 reviewed.
  - Legacy `GUIDELINES.md` 1.0.0 and `ARCHITECTURE.md` 1.0.0 were reviewed when the spec was created; both root files have since been retired.
  - Current repository guidance is `CLAUDE.md`.
- Runtime/tooling:
  - Bash shell scripts: `cli/install.sh`, `cli/lib.sh`, `tests/cli/json-error-handling.sh`.
  - Node/npm for `site`.
  - Astro in `shipglows-site/package.json` and `shipglows-site/pnpm-lock.yaml`.
- Fresh external docs:
  - fresh-docs checked: GitHub/OSV advisory for `GHSA-j687-52p2-xcff` / `CVE-2026-41067` identifies Astro versions before `6.1.6` as affected and `6.1.6` as fixed. Source: https://osv.dev/vulnerability/GHSA-j687-52p2-xcff and https://github.com/withastro/astro/security/advisories/GHSA-j687-52p2-xcff
  - fresh-docs checked: Astro v6 upgrade guide says Astro 6 includes breaking changes, drops Node 18/20 support in favor of Node `22.12.0` or higher, upgrades Vite 7 and Zod 4, and may require schema changes. Source: https://v6.docs.astro.build/ko/guides/upgrade-to/v6/
  - fresh-docs checked: NodeSource maintains official DEB/RPM Node.js binary distributions and a public `nodesource/distributions` repository. Source: https://nodesource.com/products/distributions and https://github.com/nodesource/distributions
  - fresh-docs checked: Flox official Debian install docs say to download the matching `flox.deb`, install it with `sudo apt install /path/to/flox.deb`, and verify with `flox --version`; Flox registers an apt source for upgrades. Source: https://flox.dev/docs/install-flox/install/
  - fresh-docs checked: GitHub CLI official Linux install docs name signed Linux package repositories, PGP key fingerprints `2C6106201985B60E6C7AC87323F3D4EA75716059` and `7F38BBB59D064DBCB3D84D725612B36462313325`, and SHA256 for the official keyring file. Source: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
  - fresh-docs checked: Caddy official Debian/Ubuntu install docs use the Cloudsmith stable GPG key, source list, `apt update`, and `apt install caddy`. Source: https://caddyserver.com/docs/install
  - fresh-docs checked: Supabase official docs say global `npm install -g supabase` is not supported; global usage should use Homebrew, Scoop, or standalone binary, and Linux packages are provided in GitHub releases. Source: https://supabase.com/docs/guides/local-development/cli/getting-started?platform=macos&queryGroups=platform and https://github.com/supabase/cli
  - fresh-docs checked: npm official docs define global installs with `npm install -g <package_name>` and warn about permissions issues; this supports keeping PM2/Vercel/Convex/Clerk global installs explicit and checked. Source: https://docs.npmjs.com/downloading-and-installing-packages-globally
  - Installer source policy for `/sg-start`: NodeSource must not remain `curl | bash`; use an explicit apt repository setup with downloaded key/source files checked for non-empty expected content, or switch to Ubuntu/package-manager Node if the support contract allows it. Flox must use the official Debian package path and verify download success plus `flox --version`; if no upstream checksum is available for the chosen `.deb`, the code must state that limitation and rely on HTTPS plus package installation verification. GitHub CLI must use the official apt keyring path and verify the key fingerprint or keyring SHA256 before adding the source. Caddy must keep the official stable repository and fail if key/source download or `apt install caddy` fails. Supabase must use a pinned GitHub release asset plus its release checksum file, or use the official `.deb` package path; it must not use `latest` without recording the resolved version and checksum. PyYAML should use `apt-get install python3-yaml` instead of `pip3 install pyyaml` in the root installer unless a documented reason requires PyPI.

## Invariants

- A failed privileged install step must not be reported as success.
- Test output and exit status must agree for required checks.
- Site dependency remediation must leave `pnpm --dir shipglows-site build` passing.
- `npm audit --omit=dev` must show no remaining production Astro advisory, or the implementation must stop and document why remediation is blocked.
- The first `lib.sh` extraction must preserve public functions and call signatures used by `shipglows.sh`, menu files, and tests.
- Existing audit security fixes remain in place: DuckDNS validation, encoded DuckDNS request, safer secret writes, no default ImgBB key.

## Installer Trust-Point Inventory (2026-08-25)

- `NodeSource`: pinned Node 24 repository path; downloaded key must match the recorded primary fingerprint before the generated apt source is installed.
- `GitHub CLI`: official apt keyring must match its published SHA256 before the generated apt source is installed; apt verifies repository and package signatures.
- `Supabase CLI`: release `2.115.0` tar archives are pinned per architecture and checked against the upstream release checksums before extracting only the expected binary.
- `Flox`: release `1.14.1` Debian packages are pinned per architecture, checked against Flox's published SHA256 list, inspected with `dpkg-deb`, and version-checked after installation.
- `Caddy`: the official stable HTTPS key and source file are downloaded separately; the key must parse, the source may contain only the two expected active lines, and apt must verify the signed repository. The absence of an independently pinned Caddy key fingerprint remains the documented residual trust boundary.
- `PyYAML` and system tools: installed only through configured signed apt repositories; no root PyPI fallback remains.
- `pnpm`, global Node CLIs, agent CLIs, and MCP packages: package-manager integrity paths remain intentionally package-manager managed and may track their declared current channels. They are not direct script or standalone-binary trust paths in this milestone; version-governance changes remain outside Tasks 1-3.
- Privileged writes owned by this milestone use verified temporary inputs and same-directory atomic replacement for apt keyrings, apt sources, and `/usr/local/bin/supabase`. Existing local-repository wrapper and user-configuration writes are not new external trust points.

## Links & Consequences

- `cli/install.sh`: privileged external trust boundary. Changes affect first-time setup, user-local config, MCP setup, CLI availability, and support docs.
- `lib.sh`: central runtime behavior. Extraction can break environment start/stop, publish, dashboard, inspector, and metadata menus if call boundaries are wrong.
- `site/package*.json`: public docs/site build and dependency security posture.
- `tests/cli/json-error-handling.sh`: validation reliability for jq parsing, error handling, race fixes, and function docs.
- `README.md`, `CLAUDE.md`, `CHANGELOG.md`: may need updates if install commands, Node requirements, validation commands, or architectural routing change.
- Master/local trackers: implementation may close the audit rows created by `sg-audit-code`, but this spec itself does not edit trackers.

## Documentation Coherence

- Update `README.md` if install prerequisites, Node version expectations, or supported install behavior changes.
- Update `README.md` for the stable installer supply-chain rule; the retired root `GUIDELINES.md` is not recreated.
- Update the current canonical architecture/context surface only if `lib.sh` extraction creates a new official module boundary; do not recreate retired root documents.
- Update `CLAUDE.md` if common commands or critical rules change.
- Update `CHANGELOG.md` after implementation with security/reliability entries.
- No pricing, FAQ, or GTM copy change is required unless the public site dependency migration changes public behavior.

## Edge Cases

- A remote install script download returns an HTML error page with HTTP 200.
- A checksum or signature source is unavailable.
- `npm audit fix --force` upgrades Astro but breaks content collection schema validation.
- Astro 6 requires Node 22.12.0 while current installer or docs imply a lower Node runtime.
- `tests/cli/json-error-handling.sh` has optional dependency checks that should skip rather than fail.
- `lib.sh` extraction changes source order or global variables, breaking sourced functions.
- Working tree contains unrelated user edits in the same files.
- A successful command still contains failed subtest text in its output.

## Implementation Tasks

- [x] Task 1: Map current installer external trust points and failure modes.
  - File: `cli/install.sh`
  - Action: List every external script, package repo, archive, direct download, `curl`, `npm install -g`, `pip3 install`, and privileged write; classify each as pinned, verified, unchecked, or package-manager verified.
  - User story link: defines where installation is fragile before changing behavior.
  - Depends on: none.
  - Validate with: review diff plus `rg -n "curl|wget|npm install -g|pip3 install|dpkg -i|gpg|tee /etc|/usr/local/bin" cli/install.sh`.
  - Notes: do not change behavior in this task except comments or temporary notes if needed.

- [x] Task 2: Add strict installer failure helpers and use them for high-risk steps.
  - File: `cli/install.sh`
  - Action: Add shell helpers for checked download, required command, archive extraction, and status reporting; ensure high-risk install steps fail closed with actionable diagnostics.
  - User story link: prevents silent partial installation.
  - Depends on: Task 1.
  - Validate with: `bash -n cli/install.sh`; `tests/install/supply-chain-contract.sh` uses temporary fixtures and command stubs for download and command failures.
  - Notes: avoid global `set -e` unless all existing control-flow assumptions are audited.

- [x] Task 3: Pin and verify external installer sources according to the source policy.
  - File: `cli/install.sh`
  - Action: Replace unchecked live installer/download paths with the exact source policy from `Dependencies`: no `curl | bash` for NodeSource; official apt keyring/fingerprint or SHA256 verification for GitHub CLI; official Caddy stable key/source with fail-closed checks; pinned Supabase release plus checksum file or official `.deb`; official Flox Debian package with explicit version/download verification; `python3-yaml` via apt instead of root `pip3 install pyyaml`.
  - User story link: reduces supply-chain ambiguity for privileged setup.
  - Depends on: Task 2.
  - Validate with: official source URLs recorded in code/docs; `bash -n cli/install.sh`; the focused fixture contract proves empty downloads, curl errors, checksum/fingerprint mismatches, unexpected repository lines, required-command failures, and unsupported architectures fail closed.
  - Notes: Supabase `2.115.0` and Flox `1.14.1` use upstream SHA256 values; GitHub CLI uses the published keyring SHA256; NodeSource uses the published primary-key fingerprint. Caddy's residual boundary is its official HTTPS key endpoint plus exact source validation, followed by apt repository signature verification and post-install binary verification.

- [ ] Task 4: Resolve the Astro production advisory through a planned migration.
  - File: `shipglows-site/package.json`
  - Action: Upgrade Astro to a version including the `GHSA-j687-52p2-xcff` fix, preferring the lowest safe path if available; if the only viable path is Astro 6, perform the major migration intentionally.
  - User story link: removes known public-site XSS dependency risk.
  - Depends on: none.
  - Validate with: `pnpm --dir shipglows-site audit --prod` and `pnpm --dir shipglows-site build`.
  - Notes: official advisory fixed version is `6.1.6`; verify whether a compatible patch exists for the current major before committing a major upgrade.

- [ ] Task 5: Update Astro lockfile and schema code if required.
  - File: `shipglows-site/pnpm-lock.yaml`
  - Action: Regenerate lockfile with the selected Astro version; update `shipglows-site/src/content.config.ts` only if Zod/Astro migration requires API changes.
  - User story link: keeps dependency remediation reproducible.
  - Depends on: Task 4.
  - Validate with: `pnpm --dir shipglows-site install --frozen-lockfile`, `pnpm --dir shipglows-site build`, and `pnpm --dir shipglows-site audit --prod`.
  - Notes: Astro v6 upgrade docs call out Node 22.12.0+, Vite 7, and Zod 4; check local CI/runtime compatibility before finalizing.

- [ ] Task 6: Fix JSON and error-handling test result semantics.
  - File: `tests/cli/json-error-handling.sh`
  - Action: Make required PM2 jq fixture checks pass, or mark unavailable prerequisites as skipped without counting them as failed; ensure any displayed failure exits non-zero.
  - User story link: gives operators trustworthy validation signals.
  - Depends on: none.
  - Validate with: `./tests/cli/json-error-handling.sh`; intentionally failing a required assertion in a temporary local copy should exit non-zero.
  - Notes: preserve existing optional-dependency behavior where a skip is legitimate.

- [ ] Task 7: Extract validation helpers from `lib.sh` into a dedicated module.
  - File: `lib.sh`, `lib/validation.sh`
  - Action: Create `lib/validation.sh` and move exactly these functions from `lib.sh`: `validate_project_path`, `validate_env_name`, `validate_duckdns_subdomain`, `validate_duckdns_token`, and `validate_public_ipv4`. Source `lib/validation.sh` from `lib.sh` after configuration is loaded and before any caller can invoke the validators. Keep function names and return semantics unchanged.
  - User story link: reduces blast radius without rewriting the CLI.
  - Depends on: Tasks 2 and 6 if extracting install/test-related shared helpers; otherwise independent.
  - Validate with: `bash -n lib.sh shipglows.sh`; `./tests/cli/input-validation.sh`; `./tests/cli/config-logging-cache.sh`; `./tests/cli/json-error-handling.sh`.
  - Notes: do not extract publish, dashboard, PM2, inspector, or metadata behavior in this chantier. If sourcing order breaks because validators call `error` before it is defined, keep the helpers in `lib.sh` and record the blocker instead of broadening the refactor.

- [ ] Task 8: Update docs and release notes for changed contracts.
  - File: `README.md`, `CLAUDE.md`, `CHANGELOG.md`, plus the current canonical architecture/context surface only if Task 7 creates a module boundary
  - Action: Document new installer verification expectations, Astro/Node requirement changes if any, validation command behavior, and any new `lib.sh` module boundary.
  - User story link: keeps operator guidance aligned with code.
  - Depends on: Tasks 2-7.
  - Validate with: docs mention only implemented behavior; no stale install command remains.
  - Notes: keep business/product positioning unchanged.

- [ ] Task 9: Run final regression and update the audit tracking rows.
  - File: `TASKS.md`, `AUDIT_LOG.md`, `/home/ubuntu/shipglows_data/TASKS.md`, `/home/ubuntu/shipglows_data/AUDIT_LOG.md`
  - Action: Run all validation commands. If they pass, mark the corresponding `### Audit: Code` rows for this chantier done in local and master task trackers, and append or update the code audit result in local and master audit logs.
  - User story link: proves the chantier is actually ready to ship.
  - Depends on: Tasks 1-8.
  - Validate with: `bash -n ...`, `./tests/cli/input-validation.sh`, `./tests/cli/config-logging-cache.sh`, `./tests/cli/json-error-handling.sh`, `cd shipglows-site && pnpm install --frozen-lockfile && pnpm build && pnpm audit --prod`.
  - Notes: if a command cannot run in the environment, document the exact blocker.

## Acceptance Criteria

- [x] AC 1: Given the installer contains external downloads or privileged writes, when an external source is unavailable, malformed, or unverifiable, then `cli/install.sh` fails with a clear diagnostic before reporting success for that component.
- [x] AC 2: Given a supported install path, when `bash -n cli/install.sh` runs, then the script has no syntax errors.
- [ ] AC 3: Given the Astro site dependencies are installed, when `npm audit --omit=dev` runs in `site/`, then it no longer reports `GHSA-j687-52p2-xcff` for Astro.
- [ ] AC 4: Given the Astro dependency remediation is applied, when `pnpm build` runs in `shipglows-site/`, then all static routes build successfully.
- [ ] AC 5: Given `tests/cli/json-error-handling.sh` prints any required test as failed, when the script exits, then the process exit code is non-zero.
- [ ] AC 6: Given an optional JSON/error-handling prerequisite is unavailable, when `tests/cli/json-error-handling.sh` runs, then the output marks it skipped or informational without counting it as a failed required test.
- [ ] AC 7: Given the first `lib.sh` extraction is complete, when `shipglows.sh` sources `lib.sh`, then existing public functions used by menus and tests remain callable.
- [ ] AC 8: Given the audit fixes already applied, when regression tests run, then DuckDNS validation tests still pass and the inspector still has no default public ImgBB key.
- [ ] AC 9: Given install behavior, dependency requirements, or module boundaries changed, when docs are read, then README/GUIDELINES/CLAUDE/CHANGELOG reflect implemented behavior and do not describe stale commands.
- [ ] AC 10: Given the final validation suite is run, when any required command fails, then the chantier is not marked done or shipped.

## Test Strategy

- Static shell checks:
  - `bash -n cli/lib.sh cli/config.sh cli/shipglows.sh cli/install.sh local/local.sh local/dev-tunnel.sh tests/cli/input-validation.sh tests/cli/config-logging-cache.sh tests/cli/json-error-handling.sh`
- Existing shell tests:
  - `./tests/cli/input-validation.sh`
  - `./tests/cli/config-logging-cache.sh`
  - `./tests/cli/json-error-handling.sh`
- Site checks:
  - `cd shipglows-site && pnpm install --frozen-lockfile`
  - `cd shipglows-site && pnpm build`
  - `cd site && npm audit --omit=dev`
- Focused installer checks:
  - Use temporary local copies or controlled invalid URLs to prove checked-download helpers fail closed.
  - Do not run destructive privileged install flows on the shared workspace unless explicitly approved.
- Regression review:
  - Confirm direct audit fixes remain present in `lib.sh`, `config.sh`, `injectors/web-inspector.js`, and `tests/cli/input-validation.sh`.

## Risks

- High: supply-chain hardening can break installation if upstream URLs, keys, or checksums are modeled incorrectly.
- High: Astro 6 may require Node 22.12.0+ and Zod 4 adjustments, affecting local and deployment environments.
- Medium: `lib.sh` extraction can break sourced global variables or function ordering.
- Medium: test semantics changes can hide a real failure if skip logic is too broad.
- Medium: docs can overstate hardening if unavoidable trust boundaries are not clearly named.

## Execution Notes

- Read first:
  - `CLAUDE.md`
  - `cli/install.sh`
  - `cli/lib.sh`
  - `tests/cli/json-error-handling.sh`
  - `shipglows-site/package.json`
  - `shipglows-site/src/content.config.ts`
- Implementation order:
  1. Installer map and failure model.
  2. Astro advisory remediation.
  3. JSON and error-handling test semantics.
  4. Exact validator extraction from `lib.sh` to `lib/validation.sh`.
  5. Docs and final validation.
- Packages to avoid:
  - Avoid adding new installer frameworks or package managers unless a shell-native solution cannot meet the verification requirement.
  - Avoid `npm audit fix --force` without reviewing the resulting Astro major migration diff.
- Stop conditions:
  - A privileged installer source cannot satisfy the source policy above and no residual trust boundary is documented.
  - Astro remediation requires a Node version unsupported by the intended ShipGlows install target and no support-contract update is included.
  - `lib.sh` extraction expands beyond the five named validation functions.
  - Required validation command fails and cannot be explained as environment-only.

## Open Questions

None. Conservative decisions are sufficient: fail closed for installer verification, remediate Astro using official advisory guidance, fix test exit semantics, and limit `lib.sh` extraction to one bounded helper group.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-04-28 20:30:00 UTC | sg-spec | GPT-5 Codex | Created spec from sg-audit-code chantier potential for installer, dependency, test, and architecture risk reduction | draft saved | /sg-ready Installer supply-chain hardening and ShipGlows codebase risk reduction |
| 2026-04-28 20:45:00 UTC | sg-ready | GPT-5 Codex | Evaluated readiness and found gaps in metadata, fresh docs, task specificity, tracking target, and open questions | not ready | /sg-spec Installer supply-chain hardening and ShipGlows codebase risk reduction |
| 2026-04-28 20:50:00 UTC | sg-spec | GPT-5 Codex | Revised spec with PRODUCT dependency, per-source installer policy, exact validator extraction target, and exact tracking files | draft updated | /sg-ready Installer supply-chain hardening and ShipGlows codebase risk reduction |
| 2026-04-28 22:59:16 UTC | sg-ready | GPT-5 Codex | Re-evaluated corrected spec against readiness gate, chantier tracking, and documentation freshness requirements | ready | /sg-start Installer supply-chain hardening and ShipGlows codebase risk reduction |
| 2026-08-25 13:53:00 UTC | sg-maintenance | GPT-5 Codex | Implemented Tasks 1-3 on the migrated `cli/install.sh` surface with pinned sources, fail-closed helpers, focused fixtures, and directly mapped docs | installer milestone verified | Continue with Task 4 after this milestone is delivered |

## Current Chantier Flow

- sg-spec: done
- sg-ready: done, ready
- sg-start: in progress; installer milestone verified
- sg-verify: not launched
- sg-end: not launched
- sg-ship: not launched

Reste a faire:
- Tasks 4-9: Astro remediation, JSON test semantics, bounded validator extraction, remaining documentation reflection, and final full-spec validation.

Prochaine etape:
- Remediate the Astro production advisory (`GHSA-j687-52p2-xcff`) as Task 4 without reopening the completed installer milestone.
