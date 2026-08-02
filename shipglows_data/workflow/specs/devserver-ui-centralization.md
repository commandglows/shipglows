---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.4"
project: "ShipGlows"
created: "2026-06-22"
created_at: "2026-06-22 00:00:00 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 11:06:32 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5"
scope: devserver-startup-cache-and-shell-ui
user_story: "As a ShipGlows DevServer operator, I want every shortcut and environment picker to open quickly and behave consistently, so routine server work feels immediate and reliable with or without gum."
owner: unknown
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/shipglows.sh
  - cli/lib.sh
  - cli/shipglows_devserver_gum.sh
  - cli/shipglows_devserver_bash.sh
  - tests/cli/
  - shipglows_data/technical/context.md
  - shipglows_data/technical/context-function-tree.md
  - shipglows_data/technical/design-system-authority.md
depends_on:
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "1.2.0"
    required_status: active
  - artifact: "skills/references/design-system-token-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/technical/guidelines.md"
    artifact_version: "1.5.0"
    required_status: reviewed
supersedes: []
evidence:
  - "2026-07-17 audit: sourcing cli/lib.sh takes 3.27-3.30s and cli/shipglows.sh x takes 3.44-3.47s on the current ARM64 host."
  - "2026-07-17 audit: s m n reaches its picker in 3.59-3.64s and s m r in 6.61-6.74s because the environment discovery path is repeated."
  - "2026-07-17 audit: the current Flox find takes 2.58-2.60s, including about 2.31s below claiire/.flox; adding -prune to a matched .flox reduces the same discovery to 0.05-0.06s."
  - "2026-07-17 cache audit: direct PM2/environment cache hits take 7/8ms, while real command-substitution callers repeat 229-248ms PM2 work and 2.77-2.82s environment scans because cache mutations occur in subshells."
  - "Current code inspection: registry_sync runs unconditionally while cli/lib.sh is sourced, registry writes are not atomic, and registry, list, identifier, and path resolution paths duplicate Flox discovery."
next_review: "2026-07-31"
next_step: "none"
---

# Optimize DevServer startup, caches, and shell UI

## Title

Optimize DevServer startup, caches, and shell UI

## Status

Closed locally after implementation and independent verification. The DevServer startup, cache, registry, and shell UI behavior is proven on the audited host; bounded git shipping remains.

## User Story

As a ShipGlows DevServer operator, I want `s`, lightweight shortcuts, and environment pickers such as `s m n` and `s m r` to open quickly and behave consistently, so routine server work feels immediate, predictable, and pleasant with or without `gum`.

## Minimal Behavior Contract

When the operator starts ShipGlows or invokes a shortcut, the CLI performs only the discovery and process-state work required by that action, reuses a coherent cached environment index when it is safe, and presents the existing centralized shell UI without a multi-second pause. A missing, stale, or failed cache refresh must never truncate the last valid registry or silently return an incomplete list; the easiest edge case to miss is repeated calls through command substitution, where cache state must remain effective in the parent shell rather than being discarded in a subshell.

## Success Behavior

- `s x` and other shortcuts that do not need environment discovery no longer execute `registry_sync`, `pm2 jlist`, or a home-tree Flox scan during `cli/lib.sh` sourcing.
- The first environment-dependent action refreshes one shared environment index only when the persistent registry is missing, explicitly invalidated, or stale according to a configurable policy.
- One environment selection flow performs at most one Flox discovery and one PM2 snapshot; `s m r` does not repeat the same home-tree scan.
- A matched `.flox` directory is emitted and pruned, so discovery never descends into Flox internals.
- PM2, environment-list, and path-resolution cache hits remain hits through real production callers, not only when cache functions are invoked directly.
- The registry is replaced atomically, concurrent readers see either the previous complete snapshot or the new complete snapshot, and a failed rebuild preserves the previous valid file.
- The shell continues to use centralized `ui_*` primitives for letter keys, filtering, centering, traffic status, cancellation, and backend selection; `gum`, `fzf`, and pure Bash paths keep equivalent observable behavior.
- Pending-input protection remains effective without imposing a fixed 120ms quiet wait before every interactive widget when no bytes are pending.

## Error Behavior

- If PM2 is unavailable or `pm2 jlist` fails, environment discovery remains usable from Flox/registry data, affected statuses are reported as `unknown` or last-known state, and the CLI emits a concise diagnostic only on a surface where it helps recovery.
- If Flox discovery fails, a valid existing registry remains untouched; a missing registry produces a recoverable non-zero result and an actionable message rather than an empty successful picker.
- If an atomic registry refresh cannot acquire its bounded lock, the caller uses a still-valid snapshot or reports a recoverable busy state; it must not spin indefinitely.
- Empty lists return 1 without opening a widget. Cancel, `x`, `Esc`, and an empty back action return 1 without side effects or error logging.
- A cache invalidated by `start`, `stop`, `restart`, `remove`, or rename cannot be reused as fresh after the mutation.
- No project path, registry content, PM2 output, or user choice is evaluated as shell code; failures and diagnostics must not expose secrets.

## Problem

The DevServer pays global work before it knows which action the operator requested. `cli/lib.sh` currently calls `registry_sync` while being sourced, and that function always runs PM2 discovery plus a `find` under the projects root. The `find` prints `.flox` directories but does not prune them, so it traverses large Flox internals. Environment listing, identifier listing, and path resolution repeat similar scans. The in-memory PM2, environment, home-folder, and path caches mutate globals, but common callers invoke them with `$(...)` or process substitution, so those mutations disappear with the subshell. The result is a measured 3.45s common startup floor, 3.62s to `s m n`, and 6.68s to `s m r` on the audited host. The UI refactor has already introduced several shared primitives, but the fixed TTY drain and remaining subprocesses still add avoidable interaction latency.

## Solution

Make initialization lazy and action-aware, consolidate Flox discovery behind one bounded scanner that prunes matched `.flox` directories, and use the atomic persistent registry as the shared environment/path index. Refactor cache APIs and production callers so state is populated in the current shell, keep one PM2 snapshot per CLI session until an explicit mutation invalidates it, and preserve compatibility stdout wrappers only for external callers. Complete the shell UI centralization by treating `cli/lib.sh` `ui_*` primitives as the canonical shell design-system layer and by removing fixed quiet waits and trivial subprocesses from hot interaction paths without weakening input safety.

## Scope In

- Startup behavior in `cli/shipglows.sh` and source-time initialization in `cli/lib.sh`.
- `ensure_registry`, `registry_sync`, `registry_update`, and registry invalidation/refresh policy.
- Flox environment discovery used by registry creation, `list_all_environments`, `list_all_environment_identifiers`, and `resolve_project_path`.
- PM2/environment/path/home-folder cache APIs and their production callers, including selectors and status helpers.
- Shell UI hot paths: `ui_choose`, `ui_filter_choose`, `_ui_normalize_choice`, `ui_flush_pending_input`, and the existing `ui_letter_*`, `ui_text_center`, `ui_list_filter`, and `ui_traffic_color` primitives.
- Gum and Bash menu frontends only where required to consume the shared contracts without duplication.
- Focused shell tests, performance harness, manual CLI checklist, and mapped technical documentation.

## Scope Out

- Changes to PM2 lifecycle semantics, Flox environment contents, Caddy, DuckDNS, public deployment, or SSH tunnels.
- TUI `readers.ts` decomposition and cross-runtime status styling; these do not cause the audited DevServer startup latency and require a separate contract if still desired.
- Public site design tokens, branding changes, new terminal dependencies, or a replacement TUI framework.
- Persistent background daemons, filesystem watchers, or a new database solely to accelerate discovery.
- Android, Flutter, or hosted deployment work.

## Constraints

- Preserve Bash 4+ support and do not add a mandatory dependency to the CLI.
- Preserve public stdout/return-code contracts: selected value on stdout; 0 for selection/success; 1 for cancel, empty list, or recoverable absence.
- Use an optional destination-variable/internal API or another parent-shell pattern for cache-populating functions; do not rely on global mutation inside command substitution.
- A canonical Flox scanner must use an expression equivalent to `-type d -name .flox -print -prune` after pruning heavy unrelated directories.
- Registry writes must use a temporary file in the registry directory, restrictive permissions, validation, and atomic `mv`; synchronization must have a bounded concurrency strategy.
- The cache policy must be invalidation-first after known mutations. TTL is a stale-data safety bound, not the primary way to observe local PM2/environment mutations.
- The shell design-system authority is the shared ANSI constants and `ui_*` primitives in `cli/lib.sh`; menu frontends orchestrate them and must not introduce parallel literals or divergent selector behavior.
- Preserve `gum`/`fzf` optionality and pure Bash fallback behavior.
- Performance checks must compare repeated runs on the same host and report medians; one noisy run cannot establish regression or success.

## Test Contract

- surface: Bash DevServer runtime (`cli/shipglows.sh`, `cli/lib.sh`, gum and Bash menu frontends)
- proof_profile: automated + benchmark + manual terminal
- proof_order:
  1. Static: `bash -n cli/lib.sh cli/shipglows.sh cli/shipglows_devserver_gum.sh cli/shipglows_devserver_bash.sh`.
  2. Automated: `tests/cli/config-logging-cache.sh`, `tests/cli/input-validation.sh`, `tests/cli/json-error-handling.sh`, and `tests/cli/menu-navigation.sh`.
  3. Focused: discovery fixture proves `.flox` is emitted once and its descendants are never visited; registry failure/concurrency tests prove last-known-good and atomic replacement.
  4. Benchmark: five warm and five cold same-host runs for source time, `s x`, `s m n`, and `s m r`, with median comparison against the recorded 2026-07-17 baseline.
  5. Manual: real TTY walkthrough of `s`, `s m n`, `s m r`, cancel/back, empty list, gum, and Bash fallback.
- checklist_path: `shipglows_data/workflow/test-checklists/devserver-ui-centralization.md`
- required_scenario_ids: [SC01, SC02, SC03, SC04, SC05, SC06]
- required_results:
  - SC01: a non-environment shortcut performs no registry, PM2, or Flox discovery at source time.
  - SC02: cold environment discovery prunes `.flox`, produces a complete atomic registry, and does not destroy the previous registry on failure.
  - SC03: repeated real callers reuse PM2/environment/path data and perform no duplicate discovery before invalidation.
  - SC04: PM2 and environment mutations invalidate all dependent snapshots before the next read.
  - SC05: `s m n` and `s m r` preserve selection, filtering, cancel, empty-list, gum, and Bash fallback behavior.
  - SC06: benchmark medians meet the performance acceptance criteria without skipped correctness checks.
- exception_with_proof: `gum`-absent behavior may be proven by an isolated PATH/test stub when the audited host has gum installed.
- exception_without_proof: none.

## Dependencies

- Bash 4+ features already used by the project, including arrays, parameter expansion, and `printf -v` if chosen for destination-variable APIs.
- Existing optional tools: `pm2`, `jq` with Python fallback, `gum`, and `fzf`.
- Existing state directory and `envs.reg` format. A format migration is not required unless implementation proves the current delimiter cannot be preserved safely.
- `fresh-docs not needed`: the performance causes and required behavior are fully defined and reproduced in local Bash code; this change does not alter an external PM2 or Flox API contract.

## Invariants

- PM2 remains the runtime source of truth, and every PM2 state mutation invalidates its session snapshot.
- The registry remains the durable environment/path snapshot used by read-heavy menu surfaces, but it is never rebuilt unconditionally during library sourcing.
- Environment discovery produces each project once, uses the existing `derive_pm2_app_name` naming contract, and never descends below a discovered `.flox` directory.
- A reader never observes a partially written registry.
- Absolute project-path validation and the no-`eval` boundary remain intact.
- `x` remains the universal cancel/back shortcut; letter-key order and stdout return values remain compatible across gum, fzf, and Bash.
- The fixed-width `ShipGlows DevServer` header and existing traffic semantics remain stable unless a centralized `ui_*` contract changes them for every frontend.

## Links & Consequences

- `cli/shipglows.sh` sources `cli/lib.sh` before parsing shortcuts, so any source-time command directly affects every invocation.
- `select_environment`, `select_stop_target`, PM2 helpers, dashboard functions, and lifecycle actions consume the cache/registry layer and must migrate together to avoid a split cache model.
- `env_start`, `env_stop`, `env_restart`, `env_remove`, rename, batch actions, and direct PM2 mutations must invalidate the dependent PM2 and environment/path snapshots.
- Compatibility launchers and both menu frontends must retain their call signatures; they should not need independent discovery implementations.
- `CLAUDE.md` currently documents registry synchronization at source time and must be corrected when the runtime changes.
- `shipglows_data/technical/context.md` and `context-function-tree.md` map this runtime area and must describe lazy registry refresh, the shared scanner, and cache ownership after implementation.
- The existing persistent menu-header cache is not replaced; its lock identity should use the actual background process (`$BASHPID`) or an equivalent bounded lock, and update-check cadence must not be coupled accidentally to every 120-second header refresh.

## Documentation Coherence

- Update `shipglows_data/technical/design-system-authority.md` with a DevServer shell entry naming `cli/lib.sh` ANSI constants and `ui_*` primitives as the canonical source, and both menu frontends as consumers.
- Update `CLAUDE.md`, `shipglows_data/technical/context.md`, and `shipglows_data/technical/context-function-tree.md` because their source-time registry and cache descriptions otherwise become false.
- Update the cache/config comments in `cli/config.sh` only if TTL or invalidation variables change.
- Create and execute `shipglows_data/workflow/test-checklists/devserver-ui-centralization.md` for manual TTY evidence.
- No public README/site update is required because command names and user-visible capabilities do not change; the CLI becomes faster and keeps the same interaction contract.

## Edge Cases

- A `.flox` tree contains thousands of internal directories, symlinks, unreadable entries, or nested project-looking content.
- Two project paths derive the same PM2 app name, or a project path contains spaces, glob characters, a pipe, or a newline.
- The registry is missing, empty, stale, malformed, read-only, or refreshed concurrently by two CLI processes.
- PM2 is installed but its daemon is stopped, `pm2 jlist` returns invalid JSON, or the JSON parser is unavailable.
- A cache is populated through a compatibility stdout wrapper, a pipeline, command substitution, or process substitution.
- `s m r` needs both environment and PM2 data and would accidentally trigger separate refreshes through nested helpers.
- A state mutation succeeds but registry refresh fails; invalidation must prevent stale data from being presented as fresh.
- Input bytes remain buffered after a shortcut, while an idle TTY has no bytes to drain.
- More than 26 selector items, labels with spaces/emoji, empty lists, invalid keys, `Esc`, Backspace, and `x` cancellation.

## Implementation Tasks

- [x] Task 1: Consolidate Flox discovery into one bounded scanner
  - File: `cli/lib.sh`
  - Action: Add one internal scanner that returns validated project path/name pairs, prunes heavy directories and each matched `.flox`, deduplicates results, and is reused by registry, list, identifier, and path-resolution code.
  - User story link: removes the 2.6-second traversal and duplicate scans before environment pickers.
  - Depends on: none.
  - Validate with: focused fixture test plus a scan assertion that no path below a matched `.flox` is visited.
  - Notes: preserve `derive_pm2_app_name`; reject or safely handle values that cannot be represented by the current registry delimiter.

- [x] Task 2: Make registry refresh lazy, stale-aware, atomic, and failure-safe
  - File: `cli/lib.sh`
  - Action: Remove unconditional source-time `registry_sync`; make `ensure_registry` refresh only on missing/invalidated/stale state; build and validate a same-directory temporary snapshot, use a bounded lock, atomically replace on success, and preserve last-known-good data on failure.
  - User story link: removes the global startup tax while keeping environment data reliable.
  - Depends on: Task 1.
  - Validate with: `s x` instrumentation shows zero discovery; cold/missing/stale/failing/concurrent registry tests pass.
  - Notes: avoid direct truncation of `envs.reg`; clean owned temporary files on handled exits.

- [x] Task 3: Replace subshell-lost cache mutation with parent-shell cache APIs
  - File: `cli/lib.sh`
  - Action: Introduce parent-shell destination-variable/internal APIs for PM2 and environment/path snapshots, migrate production callers away from `$(cache_mutating_function)`, pipelines, and process substitutions where they discard state, and retain compatibility stdout wrappers when required.
  - User story link: makes cache hits effective in the actual `s m n` and `s m r` flows.
  - Depends on: Tasks 1-2.
  - Validate with: two real same-shell calls show one PM2 fetch and one environment discovery; second reads complete without external discovery work.
  - Notes: prefer the durable registry for environment/name/path lookup rather than maintaining three competing ephemeral caches.

- [x] Task 4: Define coherent invalidation and one-snapshot-per-action behavior
  - File: `cli/lib.sh`
  - Action: Invalidate PM2 and dependent registry/path state after every PM2 or environment mutation, share one PM2 snapshot across an action, and ensure `s m r` cannot trigger nested duplicate refreshes.
  - User story link: combines speed with correct status after start, stop, restart, remove, and rename.
  - Depends on: Task 3.
  - Validate with: extend `tests/cli/config-logging-cache.sh` for mutation, TTL, stale snapshot, and nested-caller cases.
  - Notes: session cache remains valid until explicit mutation or a documented safety bound; do not poll PM2 merely because a short TTL elapsed mid-action.

- [x] Task 5: Complete the shell UI hot-path centralization
  - File: `cli/lib.sh`, `cli/shipglows_devserver_gum.sh`, `cli/shipglows_devserver_bash.sh`
  - Action: Keep selector/filter/centering/status logic behind the existing shared `ui_*` primitives, remove remaining trivial normalization subprocesses, and replace the fixed three-times-40ms quiet drain with an adaptive bounded strategy that still consumes pending bytes safely.
  - User story link: preserves a consistent interface and removes avoidable interaction delay after startup work is fixed.
  - Depends on: Task 4.
  - Validate with: `tests/cli/input-validation.sh`, `tests/cli/menu-navigation.sh`, plus manual gum/Bash cancellation and buffered-input scenarios.
  - Notes: no raw frontend-specific color, spacing, letter, or cancellation semantics outside the declared shell authority.

- [x] Task 6: Add regression and benchmark coverage
  - File: `tests/cli/config-logging-cache.sh`, `tests/cli/menu-navigation.sh`, and a focused script under `tests/cli/` if separation improves determinism
  - Action: Cover scanner pruning/deduplication, lazy startup, atomic registry failure/concurrency, parent-shell cache hits, invalidation, single-scan picker flows, and median performance reporting without adding production-only test hooks.
  - User story link: prevents the multi-second startup floor and cache regression from returning.
  - Depends on: Tasks 1-5.
  - Validate with: all commands in Test Contract and `git diff --check`.
  - Notes: functional tests must use isolated temporary state/project roots and must not overwrite the operator's live registry.

- [x] Task 7: Align design-system authority, runtime docs, and manual proof
  - File: `shipglows_data/technical/design-system-authority.md`, `CLAUDE.md`, `shipglows_data/technical/context.md`, `shipglows_data/technical/context-function-tree.md`, `shipglows_data/workflow/test-checklists/devserver-ui-centralization.md`
  - Action: Document the shell UI authority, lazy registry/cache lifecycle, scanner ownership, invalidation rules, and execute the manual checklist.
  - User story link: keeps future changes fast, coherent, and understandable instead of reintroducing parallel hot paths.
  - Depends on: Tasks 1-6.
  - Validate with: metadata lint on changed docs, function-tree path review, completed checklist, and mapped documentation review.
  - Notes: remove the obsolete claim that registry synchronization always runs when `lib.sh` loads.

## Acceptance Criteria

- [x] AC01: Given a shortcut that needs no environment state, when `cli/shipglows.sh x` runs, then library sourcing performs no `registry_sync`, `pm2 jlist`, or Flox `find`, and its five-run median is at most 1.0s on the audited host.
- [x] AC02: Given a project containing `.flox` with a large internal tree, when discovery runs, then the project is returned once and no descendant of that `.flox` is traversed.
- [x] AC03: Given a valid registry and a failed or concurrent refresh, when a reader opens it, then the reader observes the complete old or complete new snapshot, never an empty/partial file, and the refresh terminates within its bounded lock timeout.
- [x] AC04: Given two real PM2/environment/path consumers in one CLI session, when no mutation occurs between them, then instrumentation records at most one PM2 fetch and one Flox discovery; the second consumer reuses the populated snapshot.
- [x] AC05: Given a successful start, stop, restart, remove, rename, or direct PM2 mutation, when the next status/list read occurs, then no pre-mutation PM2 or environment/path snapshot is accepted as fresh.
- [x] AC06: Given the audited host and equivalent state, when five-run medians are measured, then `s m n` reaches its picker in at most 1.25s and `s m r` in at most 1.50s, with at least a 60% improvement from the recorded 3.62s/6.68s baselines.
- [x] AC07: Given gum, fzf, or neither is available, when the operator selects, filters, cancels, or provides an invalid key, then the observable letter order, selected stdout value, cancellation code, and error behavior remain compatible.
- [x] AC08: Given an idle TTY, when an interactive widget opens, then pending-input protection adds no fixed 120ms wait; given buffered bytes, the bounded drain prevents those bytes from auto-selecting the next widget.
- [x] AC09: Given PM2 is unavailable or discovery fails, when an environment action opens, then the operator receives usable last-known or Flox-derived choices plus a recoverable diagnostic, and no valid registry is truncated.
- [x] AC10: Given isolated test roots, when all CLI suites and the manual checklist run, then no test writes the live registry, all required scenarios pass, and no new mandatory dependency is required.
- [x] AC11: Given the implementation is complete, when mapped documentation is reviewed, then the shell design-system authority, lazy registry lifecycle, shared discovery owner, cache invalidation rules, and validation commands match the code.

## Test Strategy

- Unit: scanner expression/pruning, deduplication, destination-variable cache APIs, invalidation, normalization, and adaptive TTY drain with controlled inputs.
- Integration: source `cli/lib.sh` with isolated state roots and instrument PM2/discovery counts through real selector/status callers; exercise missing, stale, failed, and concurrent registry refreshes.
- Regression: run all five existing `tests/cli/*.sh` suites, with the four required suites listed in the Test Contract treated as blocking.
- Performance: record cold and warm medians over five runs for `source cli/lib.sh`, `cli/shipglows.sh x`, picker entry for `s m n`, and picker entry for `s m r`; retain command, host architecture, and raw timings in test evidence.
- Manual: use a real TTY for gum and Bash fallback, long/empty lists, cancel/back, invalid keys, buffered input, and status display after mutation.
- Security/robustness: registry paths and temporary files are isolated, permissions remain restrictive, values are never evaluated, lock waits are bounded, and live operator state is not used as a destructive test fixture.

## Risks

- P1: A cache API migration can leave one legacy command-substitution caller that silently bypasses cache state; exhaustive caller search and instrumentation are required.
- P1: Lazy refresh can present stale status after a mutation if invalidation coverage is incomplete; PM2/environment mutation sites are a blocking review set.
- P1: A faulty atomic-write or lock implementation can lose the registry or deadlock concurrent CLI sessions; failure injection and bounded-lock tests are required.
- P2: Deriving environment lists and paths from one registry may expose duplicate-name or delimiter assumptions currently hidden by independent scans.
- P2: Over-aggressive TTY draining can consume intentional input, while under-draining can leak shortcut bytes into the next widget.
- P2: Strict wall-clock assertions can be flaky under host load; use same-host medians and require both an absolute budget and material baseline improvement.
- P3: Compatibility callers may rely on stdout-only helper APIs; keep wrappers or migrate all known consumers before removing a function contract.

## Execution Notes

- Read first: `cli/shipglows.sh`, `cli/lib.sh` registry/cache/selectors, both menu frontends, then `tests/cli/config-logging-cache.sh` and `tests/cli/menu-navigation.sh`.
- Start from measured root causes. Do not spend the first implementation wave on TUI decomposition or cosmetic rendering: correct discovery, lazy initialization, registry safety, and parent-shell cache ownership first.
- Use one internal Flox discovery representation and one durable registry/path index. Avoid adding another cache layer that must be synchronized independently.
- Prefer explicit destination-variable helpers (`printf -v`) or current-shell population plus read-only emitters. A function that mutates a cache must not be invoked in a subshell by production code.
- Keep compatibility wrappers until global caller search proves they can be removed. Use `rg` across canonical and compatibility scripts before changing signatures.
- Benchmark before and after each performance wave with the same state. Functional correctness, invalidation, and atomicity remain blocking even if timing targets pass.
- Documentation Freshness Gate verdict: `fresh-docs not needed`; reroute only if implementation chooses a new external PM2/Flox API or a new dependency whose current behavior governs the design.
- Stop and reroute to spec repair if implementation requires changing the registry file format, adding a daemon/watcher, weakening path validation, changing user-visible command semantics, or accepting a cache consistency model outside this contract.

## Open Questions

None. The operator explicitly delegated the implementation quality goal, and local code plus audit evidence determine the bounded professional path.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-22 | 100-sg-spec | unknown | create | draft | /101-sg-ready Centraliser le design system du shell DevServer et réduire la latence des sélecteurs |
| 2026-06-22 | 101-sg-ready | unknown | gate | ready | /102-sg-start Centraliser le design system du shell DevServer et réduire la latence des sélecteurs |
| 2026-07-17 | 403-sg-perf | GPT-5 | audit | D: common startup measured via `s x` 3.45s, `s m n` 3.62s, and `s m r` 6.68s; `.flox` descent and duplicate scans confirmed | /100-sg-spec Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 | 403-sg-perf | GPT-5 | cache audit | D: direct PM2/environment hits 7/8ms, but production subshell calls repeat 229-248ms / 2.77-2.82s work; persistent header cache reads in 1ms | /100-sg-spec Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 | 100-sg-spec | GPT-5 | repair | repaired: root-cause performance, cache, atomicity, shell UI, proof, and documentation contracts made autonomous | /101-sg-ready Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 | 101-sg-ready | GPT-5 | gate | ready | /102-sg-start Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 | 102-sg-start | GPT-5 | implemented | lazy startup, pruned Flox scan, atomic registry, parent-shell caches, coherent invalidation, adaptive TTY drain, focused regression suite; automated targets passed | /103-sg-verify Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 | 103-sg-verify | GPT-5 | verify | passed after correcting stale empty-lock recovery, Bash destination-variable scope collisions, and fallback `x` cancellation; automated, performance, and real-TTY proof passed | /104-sg-end Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 11:01:29 UTC | 104-sg-end | GPT-5 Codex | close | closed: synced the three canonical task records and changelog framing without claiming git ship status | /005-sg-ship Optimize DevServer startup, caches, and shell UI |
| 2026-07-17 11:06:32 UTC | 005-sg-ship | GPT-5 Codex | ship | shipped: bounded DevServer performance/cache/UI scope committed and pushed after focused CLI, metadata, and diff checks | none |

## Current Chantier Flow

| Phase | Status |
|-------|--------|
| 100-sg-spec | done |
| 101-sg-ready | ready |
| 102-sg-start | done |
| 103-sg-verify | done |
| 104-sg-end | closed |
| 005-sg-ship | shipped |
