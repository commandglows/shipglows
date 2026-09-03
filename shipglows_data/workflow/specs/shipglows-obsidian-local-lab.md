---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.5"
project: ShipGlows
created: "2026-09-02"
created_at: "2026-09-01 22:39:16 UTC"
updated: "2026-09-02"
updated_at: "2026-09-01 23:09:28 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5.6 Codex
scope: feature
owner: Diane
user_story: "As a developer of an approved Obsidian plugin, I want to load it in disposable local profile and vault environments so that I can distinguish a successful build from actual loading and interaction without modifying my personal Obsidian data."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/
  - tests/windows/
  - shipglows_data/technical/
  - DreamGlows
  - Obsidian 1.12.7+
depends_on:
  - artifact: shipglows_data/workflow/specs/shipglows-browser-extension-lab.md
    artifact_version: "1.2.1"
    required_status: reviewed
supersedes: []
evidence:
  - "2026-09-03: the shared browser-extension Lab dependency now targets its current reviewed contract."
  - "Operator approved a local-only Obsidian Lab on 2026-09-02 and excluded Sandbox, VM, personal vault mutation, and publication."
  - "A real Windows spike loaded DreamGlows in Obsidian 1.13.7 with a separate --user-data-dir, temporary vault, CDP endpoint, registered commands, dashboard interaction, screenshot, and unchanged personal Obsidian hashes."
  - "The spike surfaced a DreamGlows runtime note-view error that build and artifact synchronization did not reveal."
next_step: none
---

# Spec: ShipGlows Obsidian Local Lab

## Title

ShipGlows Obsidian Local Lab

## Status

ready

## User Story

As a developer of an approved Obsidian plugin, I want to load it in disposable local profile and vault environments so that I can distinguish a successful build from actual loading and interaction without modifying my personal Obsidian data.

## Minimal Behavior Contract

`s obsidian-lab -ProjectPath <plugin>` inspects an already-built Obsidian artifact, creates temporary local Obsidian profile and vault environments, copies only the declared artifacts, launches a separate Obsidian instance, approves the plugin in that test vault, then reports discovery, loading, the requested interaction, and diagnostics separately. A missing, stale, ambiguous, or incompatible artifact does not execute any repository script. Failure to isolate the instance, a host error, or a plugin error fails with actionable recovery. The Lab does not promise system isolation from a malicious plugin.

## Success Behavior

- Preconditions: specialized plugin detected, fresh `main.js` and `manifest.json`, Obsidian 1.12.7+ installed, managed Node/Playwright available.
- Trigger: explicit `obsidian-lab` command; this command constitutes approval to execute the targeted local artifact in the Lab.
- User result: plugin loaded in a temporary vault, with identity/version, commands, interaction, and diagnostics visible in human-readable and JSON output.
- System effect: per-run profile/vault, reserved local CDP port, processes bounded to the temporary profile, optional screenshot under the run, exact shutdown and cleanup.
- Proof: `vaultName`, `pluginLoaded`, version, registered commands, requested interaction, and captured errors are tied to the artifact hashes.

## Error Behavior

- Expected failures: build required, invalid manifest, Obsidian/Playwright missing, unavailable port, instance redirected to the personal profile, unexpected modal, timeout, crash, loading error, or interaction error.
- User result: `failed` or `unavailable` state, cause, step, artifact, and next safe action.
- System effect: no personal vault targeted; exact shutdown of Lab processes; evidence retained only if cleanup cannot be proven.
- Must never happen: execute `npm`/`pnpm` or a repository script, use `SHIPGLOWS_OBSIDIAN_VAULT`, close personal Obsidian, claim `load-passed` from the build alone.

## Problem

Current Obsidian support proves a fresh build and hashed copying to a declared vault, but honestly leaves `validation-unavailable`. It therefore cannot distinguish a truly loaded plugin from an artifact that was only synchronized.

## Solution

Add a local Lab independent from the `s start` workflow. It reuses the Obsidian descriptor, materializes disposable profile and vault environments, launches Obsidian with `--user-data-dir` and CDP, controls only the instance matching the exact profile, accepts the test vault, observes the plugin, performs an optional interaction, and cleans up. Add a local BRAT check without publication.

## Scope In

- Windows and local Obsidian Desktop 1.12.7+.
- `obsidian-lab` command, visible mode and agent-friendly `-Headless` mode if the host supports it without hiding the required application.
- Human-readable/JSON output and `artifact`, `hostLoad`, `interaction`, `diagnostics` states.
- Bounded temporary profile, vault, port, processes, and evidence.
- Local BRAT check: required files, `styles.css` name, manifest/version consistency, and SHA-256 inventory.
- DreamGlows as a real pilot; synthetic fixtures for errors.

## Scope Out

- Windows Sandbox, VM, container, or protection against a hostile plugin.
- Personal vault, personal Obsidian profile, or permanent activation.
- Implicit build/install, Obsidian download, GitHub release, tag, BRAT publication, or community catalog.
- Exhaustive business validation of every plugin; the Lab exposes commands and diagnostics and can perform a declared interaction.

## Constraints

- Electron `--user-data-dir` behavior is capability-checked on every run and is not presented as an official Obsidian guarantee.
- CDP binding remains on loopback and ShipGlows reserves the port.
- A run rejects symlinks/reparse points at sensitive boundaries and follows no artifact outside the project.
- Personal processes are never targeted by name alone; identity includes the exact temporary profile.
- Logs have bounded volume and do not serialize note data, secrets, or plugin keys.

## Test Contract

- Surface: PowerShell, Node/Playwright, Obsidian Desktop, documentation.
- Automated proof: PowerShell tests for paths, states, processes, payload, cleanup, and BRAT checks; Node tests for the runner with simulated CDP.
- Integration proof: real DreamGlows in local Obsidian, temporary profile/vault, personal hashes before/after.
- Interaction proof: command `dreamglows:open-dreamglows`, title/view, and bounded screenshot; view error reported separately.
- Browser/auth/provider proof: not applicable; no authentication or publication.
- Manual checklist: `shipglows_data/workflow/test-checklists/obsidian-local-lab.md` covers loading, interaction, diagnostics, shutdown, and absence of personal mutation.

## Dependencies

- `Get-SgObsidianPluginDescriptor` and existing Obsidian artifacts.
- Locally installed Obsidian Desktop 1.12.7+; `Obsidian.com` is informative, but the runner uses CDP to target the exact instance.
- Node and Playwright managed by ShipGlows.
- Browser Extension Lab as precedent for temporary profiles, JSON output, and cleanup; no forced sharing of a host-specific runner.

## Invariants

- `s start` and `s obsidian-lab` remain independent.
- `load-passed` requires the plugin instance to be actually present; `interaction-passed` requires the observed action; errors remain visible even after loading.
- The explicit command approves only the exact local artifact and inspected hashes.
- `Awesome`, `%APPDATA%\obsidian`, and every other vault remain outside the Lab's write paths.
- The local Lab is for approved code; the system-isolation limitation is always visible.

## Links & Consequences

- Upstream: Obsidian classification, build/watch, and artifact freshness.
- Downstream: Windows CLI, capability snapshot, operator documentation, agents, and BRAT preparation.
- Revalidation: Browser Extension Lab, Vite/Astro/Flutter, Windows runtime packaging, and DevServer tests.

## Documentation Coherence

- Extend `runtime-cli.md` with the Lab contract and states.
- Add a local Obsidian Lab operator guide and its security limitation.
- Update CLI help and the Windows capability map.
- Document that BRAT consumes distribution artifacts after validation and is neither a Lab nor implicit publication.

## Edge Cases

- Multiple Obsidian windows, personal instance already open, reused CDP port.
- Plugin without CSS, `style.css` instead of `styles.css`, stale main.js, manifest change during the run.
- Localized trust modal, plugin that loads and then logs an error, command missing or returning before rendering.
- Interrupted process, locked profile, partial cleanup, reparse artifact, or path with spaces.

## ZOMBIES Coverage

- Z: missing artifact, zero commands, and zero CDP pages produce failure without personal mutation.
- O: one plugin, one profile, one vault, and one page prove the nominal path.
- M: multiple pages/windows allow targeting only the one whose profile and vault match.
- B: timeout, minimum Obsidian version, log/screenshot sizes, and artifact freshness.
- I: PowerShell ↔ Node runner ↔ CDP ↔ Obsidian ↔ payload; every output is structured and tied to the hashes.
- E: crash, instance redirection, plugin error, missing interaction, and partial cleanup fail closed.
- S: one approved plugin and one representative interaction; no VM or publication generalization.

## OWASP Security Gate

- A03/A05/A08/A09/A10: artifact integrity, structured arguments, separate profile, redacted logs, timeout, and fail-closed cleanup.
- Trust boundary: the approved plugin runs with the Windows account's permissions; the Lab protects Obsidian data through path separation, not the system from hostile code.
- ASVS: not applicable as a web attestation; targeted proof through anti-traversal, anti-reparse, hashes, loopback port, and process identity.
- Residual gap: `--user-data-dir` and observed internal APIs may change with Obsidian; the capability check returns `unavailable` rather than targeting the personal profile.

## Implementation Tasks

1. Add the payload/process contract and primitives to `ShipGlows.DevServer.psm1`; validate with path, hash, and process fixtures.
2. Add `ShipGlows.ObsidianLab.js`; launch Obsidian, connect CDP, target the exact vault, approve the trust modal, observe loading/commands/interaction/diagnostics, and clean up.
3. Expose `obsidian-lab` in `shipglows-devserver.ps1`, help, the capability snapshot, and Windows packaging.
4. Add the local BRAT check without remote mutation and without requiring a vault.
5. Add PowerShell/Node tests, manual checklist, and real DreamGlows proof.
6. Update technical/operator documentation and run non-regression tests.

## Acceptance Criteria

- [x] `s obsidian-lab -ProjectPath <plugin> -Json` returns identity, hashes, temporary profile/vault, loading, commands, interaction, and diagnostics.
- [x] The Lab rejects a required build or changed artifact without executing a repository script.
- [x] An already-open personal instance remains active and its profile/vault files remain unchanged.
- [x] The Lab proves and stops only processes associated with the exact temporary profile.
- [x] A plugin error after loading produces `hostLoad=passed` with failed diagnostics, never a false overall success.
- [x] The local BRAT check requires `main.js`, `manifest.json`, the correct `styles.css` if produced, and a consistent version, without publication.
- [x] Chrome Extension Lab, web projects, Flutter, and Obsidian `s start` do not regress.
- [x] Documentation and packaging reflect exactly the delivered capability and its security limitation.

## Test Strategy

- Unit: manifest/payload, BRAT, paths, reparse points, states, and serialization.
- Integration: simulated CDP runner, then real Obsidian with DreamGlows.
- Regression: Chrome Extension Lab, monorepo detection, start-state, runtime installation, and capability snapshot.
- Manual: open the screenshot, confirm the dashboard, functional error, and absence of personal changes.

## Risks

- The approved plugin can access the host system: explicit product limitation, outside the promise of system isolation.
- Internal Obsidian/CDP surfaces may evolve: versioned capability check and `unavailable` failure.
- Naive shutdown could target the personal instance: exclusive selection by temporary profile and process identity.
- DreamGlows logs are very large: bounding and separate error classification.

## Execution Notes

- Read first: DevServer module, CLI, Extension Lab runner/tests, Obsidian support, and Windows packaging.
- Execution batches: spec/readiness; runner and module integrated sequentially; CLI/tests; docs/packaging; real proof; delivery.
- Stop conditions: need to touch a personal vault/profile, download Obsidian, execute an implicit build, publish, or hide the local-isolation limitation.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-01 22:39:16 UTC | 100-sg-spec | GPT-5.6 Codex | Formalized the approved local-only Obsidian Lab from the successful Windows spike. | reviewed | Run readiness review. |
| 2026-09-01 22:44:00 UTC | 101-sg-ready | GPT-5.6 Codex | Verified scope, dependencies, invariants, error behavior, security boundary, and executable proof path. | ready | Implement the local Lab. |
| 2026-09-01 23:02:35 UTC | 102-sg-start | GPT-5.6 Codex | Implemented the local runner, PowerShell orchestration, BRAT inspection, CLI command, packaging, focused tests, and mapped documentation. | implemented | Run standard verification. |
| 2026-09-01 23:02:35 UTC | 103-sg-verify | GPT-5.6 Codex | Verified focused contracts, packaging, capability snapshot, existing Obsidian/Extension Lab regressions, real DreamGlows load and command interaction, rendered screenshot, exact cleanup, and unchanged personal profile hashes. | verified | Close the verified chantier. |
| 2026-09-01 23:02:35 UTC | 104-sg-end | GPT-5.6 Codex | Reconciled the unique spec, mapped technical/operator documentation, public-safe changelog, local-only security limitation, and absence of a matching open bug or tracker row. | closed | Ship the bounded branch through pull request checks. |
| 2026-09-01 23:09:28 UTC | 005-sg-ship | GPT-5.6 Codex | Delivered commit `cccfd14` through PR #81 after both required gates passed, merged it into `dev` as `3cab570`, and removed the temporary branch. | shipped | None. |

## Current Chantier Flow

- `sg-spec`: done, reviewed contract created.
- `sg-ready`: passed.
- `sg-start`: complete.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: shipped via PR #81 to `dev`.

Next step: none. Sandbox, VM, personal-vault mutation, and publication remain intentionally out of scope.
