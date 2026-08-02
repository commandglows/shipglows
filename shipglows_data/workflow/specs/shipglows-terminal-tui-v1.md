---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-05-17"
created_at: "2026-05-17 21:45:03 UTC"
updated: "2026-05-23"
updated_at: "2026-05-23 19:48:18 UTC"
status: ready
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: "terminal-tui-v1"
owner: "Diane"
confidence: high
user_story: "En tant qu'opératrice ShipGlows dans un terminal, je veux ouvrir une TUI locale depuis /home/claude/shipglows/tui pour naviguer projets, chantiers, audits, tâches et logs sans lancer l'app Flutter, afin de piloter ShipGlows plus vite tout en gardant les fichiers Markdown et ledgers comme source de vérité."
risk_level: "high"
security_impact: "yes"
docs_impact: "yes"
linked_systems:
  - "ShipGlows CLI"
  - "/home/claude/shipglows/tui"
  - "OpenTUI"
  - "Gum"
  - "Bun"
  - "ShipGlows Markdown sources"
  - "shipglows_data/"
  - "ShipGlows ledgers"
depends_on:
  - artifact: "README.md"
    artifact_version: "unknown"
    required_status: "reviewed"
  - artifact: "CLAUDE.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "AGENT.md"
    artifact_version: "0.2.0"
    required_status: "draft"
  - artifact: "shipglows_data/workflow/specs/shipglows-dashboard-readonly-projection.md"
    artifact_version: "0.1.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/markdown-source-of-truth.md"
    artifact_version: "unknown"
    required_status: "draft"
  - artifact: "shipglows_data/technical/runtime-boundary.md"
    artifact_version: "unknown"
    required_status: "draft"
supersedes: []
evidence:
  - "User decision 2026-05-17: put the TUI inside shipglows_app, not in a separate GitHub repository."
  - "User decision 2026-05-23: move the TUI into /home/claude/shipglows/tui next to the terminal skills, not in ShipGlows App."
  - "User decision 2026-05-17: formalize the TUI application with a ShipGlows spec."
  - "Prior exploration 2026-05-17: Gum fits immediate shell prompts; OpenTUI fits a future persistent terminal dashboard."
  - "README.md and tui/README.md define the Terminal TUI as a local-first read-only dashboard over ShipGlows Markdown and ledgers."
  - "CLAUDE.md requires active ShipGlows work to preserve Markdown/repository files as source of truth and avoid client-side privileged secrets."
  - "OpenTUI official docs accessed 2026-05-17: native terminal UI core with TypeScript bindings; currently Bun-exclusive while Node/Deno support is in progress."
  - "Gum GitHub README accessed 2026-05-17: command-line utilities for shell scripts including choose, confirm, filter, input, pager, spin, style, table, and write."
next_step: "/sg-start ShipGlows Terminal TUI V1"
---

# Title

ShipGlows Terminal TUI V1

# Status

Ready for implementation. This spec formalizes a new optional terminal UI surface inside `/home/claude/shipglows/tui` and has passed `/sg-ready` for scope, dependencies, security boundaries, and validation gates.

# User Story

En tant qu'opératrice ShipGlows dans un terminal, je veux ouvrir une TUI locale dans `/home/claude/shipglows/tui` pour naviguer projets, chantiers, audits, tâches et logs sans lancer l'app Flutter, afin de piloter ShipGlows plus vite tout en gardant les fichiers Markdown et ledgers comme source de vérité.

# Minimal Behavior Contract

The TUI accepts a local terminal session on the operator machine, reads only allowlisted ShipGlows Markdown and ledger sources, renders a persistent dashboard for projects, specs/chantiers, tasks/audits, checks/logs, and skills, and exits cleanly without requiring Flutter, web deployment, cloud auth, database projection, or a new repository. If OpenTUI/Bun is unavailable, the existing ShipGlows CLI and Flutter app remain functional, and command-line flows can fall back to plain shell or Gum-enhanced prompts where Gum is installed. The easy edge case to miss is accidentally turning the TUI into an execution or write-back surface before read-only navigation and source safety are proven.

# Success Behavior

- Given the operator runs the future TUI entrypoint from `/home/claude/shipglows/tui`, the TUI opens a local terminal dashboard without launching Flutter.
- Given ShipGlows source files exist, the TUI shows a read-only overview of projects, chantiers/specs, tasks/audits, ledgers, and recent operational signals.
- Given multiple projects exist, the TUI lets the operator filter and select a project, then inspect related specs, tasks, audit notes, logs, and docs.
- Given a spec exists under `shipglows_data/workflow/specs/`, the TUI displays its title, status, user story, next step, run history summary, and current chantier flow.
- Given a source file is missing, too large, malformed, outside the allowlist, or unreadable, the TUI shows a clear diagnostic and keeps the rest of the dashboard usable.
- Given OpenTUI exits through `Ctrl+C`, escape, or a quit action, terminal state is restored and no background process is left running.
- Given Gum is installed, existing shell commands may use it for one-shot prompts and selectors; the persistent TUI does not depend on Gum.
- Given Bun or OpenTUI is not installed, ShipGlows core CLI, Flutter app, and existing validation flows remain unaffected.
- Given a future write action is considered, the TUI shows it as out of scope until a separate ready spec defines permissions, confirmations, audit logging, rollback, and tests.

# Error Behavior

- If `tui/package.json` dependencies are not installed, the TUI command reports the missing setup and points to the local TUI README instead of failing obscurely.
- If Bun is missing, the TUI reports that OpenTUI V1 requires Bun and exits non-zero without modifying files.
- If OpenTUI fails to initialize the terminal renderer, the command restores terminal state and prints a compact error.
- If a source path resolves outside the allowlisted roots, the reader rejects it and redacts the attempted path in user-facing diagnostics when sensitive.
- If a source file exceeds configured size limits, the TUI shows a truncated/unavailable state and does not block the whole dashboard.
- If a Markdown spec has incomplete frontmatter or missing sections, the TUI marks it as incomplete rather than inventing metadata.
- If a ledger row is malformed, the TUI skips or isolates the row and shows a parse diagnostic.
- If terminal dimensions are too small, the TUI falls back to a compact single-column layout or a clear minimum-size message.
- If the operator interrupts the process, cleanup runs before exit.

# Problem

`shipglows_app` pursues a Flutter dashboard for graphical operational visibility. That remains useful for a product surface, but the immediate ShipGlows operator workflow lives in the terminal. Keeping the TUI beside the ShipGlows skills is more coherent than hosting it in the Flutter app repository.

The product need is a fast local cockpit that lives next to the existing ShipGlows skills, reuses the same governance corpus, avoids a new GitHub repository, and does not disturb the Flutter runtime or future graphical product path.

# Solution

Add an optional terminal UI package under `/home/claude/shipglows/tui` as a separate subproject. V1 uses OpenTUI for a persistent interactive dashboard if Bun/OpenTUI are available, while keeping Gum as a separate shell-enhancement tool for one-shot prompts in `shipglows.sh` or helper scripts. The TUI reads ShipGlows Markdown and ledgers through a local allowlisted source layer and exposes read-only navigation first: projects, specs/chantiers, tasks/audits, checks/logs, and skills.

Flutter remains separate and continues to serve the graphical/dashboard path. The TUI is not a replacement for all of Flutter; it is the priority V1 operator cockpit.

# Scope In

- Create a new optional TUI subproject inside `/home/claude/shipglows/tui`.
- Define TUI project scaffolding for Bun, TypeScript, OpenTUI, lint/typecheck/test scripts, and local README.
- Define a read-only source layer for ShipGlows Markdown and ledgers using allowlisted roots and size limits.
- Implement initial views for project overview, spec/chantier browser, tasks/audits, operations/dependency logs, and skills/help.
- Implement keyboard navigation, filtering, detail panes, diagnostics, and clean terminal shutdown.
- Preserve the existing Flutter app as a separate runtime.
- Document the role split between ShipGlows CLI, Gum-enhanced shell prompts, TUI, and Flutter app.
- Add tests or deterministic fixtures for parsing, path policy, view model mapping, and error states.
- Add validation commands that can run without requiring Flutter or Vercel.

# Scope Out

- No new GitHub repository.
- No deletion or replacement of the Flutter app.
- No migration of Flutter source code into TypeScript.
- No web UI, browser app, Electron app, or Tauri app.
- No cloud auth, Firebase, Firestore, GitHub App, clone runner, database projection, or remote sync.
- No terminal-based write-back to ShipGlows trackers, specs, repositories, Git, PM2, Caddy, Flox, or deployment systems.
- No agent execution, model calls, BYOK, OpenRouter, shell command runner, or destructive operations from the TUI.
- No production packaging promise beyond a local optional developer/operator tool.

# Constraints

- ShipGlows Markdown and repository files remain canonical.
- The TUI is optional; missing Bun/OpenTUI cannot break `shipglows.sh`, existing Flutter checks, or Vercel validation.
- V1 is read-only. Any write/action feature requires a separate ready spec.
- Terminal capability must stay local; no privileged service credentials, BYOK secrets, tokens, cookies, private keys, or service-role keys may be stored in the TUI.
- TUI source readers must enforce allowlisted roots, path normalization, symlink escape protection, and file size limits comparable to the Flutter source policy.
- Diagnostics must redact sensitive path segments and never dump raw secrets or large logs.
- OpenTUI is allowed only inside the optional `tui` package; it must not become a root dependency for the Flutter app.
- Gum is not the persistent TUI framework; it is only a possible enhancement for shell scripts and command prompts.
- The TUI must degrade clearly on unsupported terminals, missing dependencies, small terminal sizes, and parse failures.

# Dependencies

- Local project context:
  - `README.md` defines the current local-first, read-only ShipGlows dashboard direction.
  - `CLAUDE.md` defines the active ShipGlows runtime, Flutter boundaries, local source-of-truth rule, and security constraints.
  - `AGENT.md` requires active work to target ShipGlows modules and classify legacy reuse before changes.
  - `shipglows_data/workflow/specs/shipglows-dashboard-readonly-projection.md` defines the existing dashboard read-only projection posture.
  - `shipglows_data/technical/markdown-source-of-truth.md` and `runtime-boundary.md` govern source authority and active/legacy boundaries.
- External docs, fresh-docs checked:
  - OpenTUI official docs, `https://opentui.com/docs/getting-started/`, accessed 2026-05-17. Relevant contract: OpenTUI is a native terminal UI core written in Zig with TypeScript bindings; installation is currently Bun-exclusive, with Node and Deno support in progress.
  - Charmbracelet Gum GitHub README, `https://github.com/charmbracelet/gum`, accessed 2026-05-17. Relevant contract: Gum provides ready-to-use shell utilities such as `choose`, `confirm`, `filter`, `input`, `pager`, `spin`, `style`, `table`, and `write`; it is appropriate for shell prompts, not for a persistent dashboard application.

# Invariants

- `/home/claude/shipglows/tui` is an optional subproject and cannot be required to run Flutter.
- The Flutter app remains buildable and conceptually separate from the TUI.
- The TUI must not write project state in V1.
- Every displayed source item traces back to a path and source type, but sensitive paths are redacted in diagnostics.
- All file reads go through one source policy module, not ad hoc `fs` calls scattered through components.
- Missing or malformed data produces a visible diagnostic, not silent disappearance.
- TUI state such as selected project, filter, and focused panel can be local ephemeral state; persisted preferences are out of V1 unless they are local-only and separately reviewed.
- External process execution is out of V1 except for the Bun runtime starting the TUI itself.
- OpenTUI components render data that has already been sanitized by the source/view-model layer.

# Links & Consequences

- ShipGlows CLI: remains the stable core entrypoint. Future CLI integration may expose `shipglows tui`, but the first implementation can run from `/home/claude/shipglows/tui`.
- Gum: should be evaluated separately for improving existing shell prompts. It does not replace OpenTUI for the persistent dashboard.
- Flutter dashboard: can pause as the primary V1 operator surface, but remains the future graphical product surface and should not be deleted.
- ShipGlows data model: TUI reads local Markdown and ledgers directly; it does not depend on Firestore projection.
- Security: terminal UI introduces local file visibility risks; path allowlisting and redaction must be implemented before rich views.
- Documentation: README, CLAUDE/AGENT guidance, and technical maps need to reflect the new surface after implementation exists.
- Testing: TUI package needs its own validation loop because Flutter tests do not cover TypeScript/OpenTUI code.
- Packaging: Bun/OpenTUI dependency must be isolated to avoid making ShipGlows installation heavier by default.

# Documentation Coherence

- Update `README.md` after implementation to describe the optional TUI and keep Flutter instructions intact.
- Update `CLAUDE.md` after implementation to add the TUI as an active optional surface and document its read-only boundary.
- Update `AGENT.md` after implementation to require TUI work to preserve source policy, no-write V1, and optional dependency isolation.
- Add `shipglows_data/technical/terminal-tui.md` during implementation to document architecture, source policy, views, commands, and validation.
- Update `shipglows_data/technical/code-docs-map.md` to include `tui/**` once files exist.
- Do not make public claims that the TUI can execute agents, deploy, edit specs, or replace Flutter until separate specs implement those capabilities.

# Edge Cases

- Bun installed globally but incompatible with the OpenTUI package version.
- `bun install` not run in `/home/claude/shipglows/tui`.
- TUI launched from a different working directory.
- `/home/claude/shipglows_data` exists but expected files are missing.
- Project-local `shipglows_data/` exists for some projects and not others.
- Specs contain legacy or incomplete frontmatter.
- A spec is very large and exceeds the size limit.
- A symlink points from an allowlisted directory to a sensitive location.
- Terminal width is too narrow for multi-pane layout.
- Terminal does not support the expected color or input capabilities.
- `Ctrl+C` happens during file read, render update, or view transition.
- A ledger file contains malformed rows or partial writes.
- A future implementation accidentally imports OpenTUI dependencies from Flutter-facing code.
- A future implementation adds command execution before a write/action spec exists.

# Implementation Tasks

- [ ] Task 1: Create the optional TUI package boundary.
  - File: `tui/package.json`
  - Action: Add Bun/TypeScript package metadata, scripts for `dev`, `typecheck`, `test`, and `lint` if lint tooling is selected, and OpenTUI dependency isolated from Flutter.
  - User story link: Gives the operator a terminal app without creating a new repo or changing Flutter dependencies.
  - Depends on: This spec passing `/sg-ready`.
  - Validate with: `cd tui && bun install && bun run typecheck`
  - Notes: If lint/test tooling is not added in the first implementation batch, scripts must fail clearly or be omitted rather than pretending coverage exists.

- [ ] Task 2: Add TUI runtime entrypoint.
  - File: `tui/src/main.ts`
  - Action: Initialize OpenTUI renderer, create the root dashboard shell, register keyboard quit handling, and guarantee cleanup on normal exit or interrupt.
  - User story link: Opens the persistent local terminal cockpit.
  - Depends on: Task 1.
  - Validate with: `cd tui && bun run dev`
  - Notes: V1 must support a smoke path that can be manually exited without corrupting the terminal.

- [ ] Task 3: Define TUI source policy.
  - File: `tui/src/sources/sourcePolicy.ts`
  - Action: Define allowlisted roots, path normalization, symlink escape handling, file size limits, and redacted diagnostics.
  - User story link: Lets the TUI read local ShipGlows sources safely.
  - Depends on: Task 1.
  - Validate with: Unit tests for allowed file, denied outside path, symlink escape, missing file, and oversized file.
  - Notes: Mirror the intent of Flutter `source_path_policy.dart`; do not copy Dart code mechanically.

- [ ] Task 4: Add source readers and parsers.
  - File: `tui/src/sources/readers.ts`
  - Action: Read master ShipGlows files, project-local governance docs, specs, tasks/audits, operations log, dependency log, and skill metadata through the source policy.
  - User story link: Provides data for projects, chantiers, audits, tasks, logs, and skills.
  - Depends on: Task 3.
  - Validate with: Fixture tests for present, missing, malformed, and partial files.
  - Notes: Use summaries for list views; avoid loading large full bodies by default.

- [ ] Task 5: Create view models for dashboard panels.
  - File: `tui/src/viewModels/dashboard.ts`
  - Action: Map parsed sources into project summaries, spec summaries, task/audit summaries, log summaries, skill summaries, and diagnostics.
  - User story link: Separates unsafe raw source content from renderable UI state.
  - Depends on: Task 4.
  - Validate with: Unit tests for empty workspace, normal workspace, malformed spec, missing ledgers, and diagnostics.
  - Notes: Do not let render components parse files directly.

- [ ] Task 6: Implement initial TUI views.
  - File: `tui/src/views/dashboardView.ts`
  - Action: Render project list, spec/chantier list, selected detail pane, tasks/audits/logs panel, and diagnostics panel with keyboard navigation.
  - User story link: Delivers the first useful operator cockpit.
  - Depends on: Task 5.
  - Validate with: Manual smoke run plus component/view-model tests where practical.
  - Notes: Keep V1 intentionally narrow: navigation and inspection only.

- [ ] Task 7: Add command wrapper documentation.
  - File: `tui/README.md`
  - Action: Document install, run, validation, dependency requirements, read-only status, known limitations, and relation to Flutter/Gum.
  - User story link: Makes the optional TUI usable without guessing setup.
  - Depends on: Tasks 1-6.
  - Validate with: `rg -n "Bun|OpenTUI|read-only|Flutter|Gum|shipglows_data" tui/README.md`
  - Notes: README must state that OpenTUI is Bun-only for this V1 unless official support changes before implementation.

- [ ] Task 8: Add technical governance doc.
  - File: `shipglows_data/technical/terminal-tui.md`
  - Action: Document architecture, source policy, no-write boundary, dependency isolation, view list, validation commands, and future write/action gates.
  - User story link: Keeps the TUI maintainable inside the ShipGlows governance corpus.
  - Depends on: Tasks 1-7.
  - Validate with: `rg -n "source policy|read-only|OpenTUI|Gum|Flutter|write action" shipglows_data/technical/terminal-tui.md`
  - Notes: This doc is implementation governance, not marketing copy.

- [ ] Task 9: Update contributor and project docs after implementation exists.
  - File: `README.md`, `CLAUDE.md`, `AGENT.md`, `shipglows_data/technical/code-docs-map.md`
  - Action: Add the TUI as an optional active surface, keep Flutter instructions intact, and document validation responsibilities.
  - User story link: Prevents future contributors from treating the TUI as a replacement repo or unbounded terminal runner.
  - Depends on: Tasks 1-8.
  - Validate with: `rg -n "tui|OpenTUI|Bun|read-only|Flutter" README.md CLAUDE.md AGENT.md shipglows_data/technical/code-docs-map.md`
  - Notes: Do not update public/user-facing claims before the TUI works.

# Acceptance Criteria

- The TUI spec is stored under `/home/claude/shipglows/shipglows_data/workflow/specs/` and does not create a new repository.
- The implementation plan creates `/home/claude/shipglows/tui` as an optional subproject.
- The TUI has a clear read-only V1 boundary.
- The TUI does not require Flutter, Firebase, Firestore, GitHub auth, Vercel, or a backend service.
- The Flutter app remains present and conceptually separate.
- The TUI source policy rejects non-allowlisted paths and symlink escapes.
- The TUI source policy enforces file size limits and redacted diagnostics.
- Initial views cover projects, specs/chantiers, tasks/audits, logs/checks, and skills/help.
- Missing or malformed data produces visible diagnostics without crashing the full dashboard.
- OpenTUI/Bun dependency is isolated to `tui`.
- Gum is documented as shell prompt enhancement, not as the persistent TUI framework.
- `Ctrl+C` or quit restores terminal state.
- Future write/action behavior is explicitly out of scope and gated by a separate spec.

# Test Strategy

- Static validation:
  - `cd /home/claude/shipglows/tui && bun run typecheck`
  - `cd /home/claude/shipglows/tui && bun test` if Bun tests are implemented.
  - `rg -n "OpenTUI|Bun|read-only|source policy|Flutter|Gum" README.md CLAUDE.md AGENT.md shipglows_data/technical/terminal-tui.md`
- Unit tests:
  - Source policy: allowed roots, denied outside path, symlink escape, missing file, oversized file, redaction.
  - Parsers/readers: normal spec, incomplete spec, malformed ledger, missing master file, empty project list.
  - View models: dashboard summaries, diagnostics, selected detail state, filter behavior.
- Manual smoke tests:
  - Launch TUI from `/home/claude/shipglows/tui`.
  - Navigate between project, spec, tasks/audit, logs, and skills panels.
  - Resize terminal and verify compact behavior.
  - Quit with keyboard and verify terminal state is restored.
- Regression checks:
  - `cd /home/claude/shipglows_app/app && flutter analyze` remains valid for Flutter work when touched.
  - `cd /home/claude/shipglows_app/app && flutter test` remains the Flutter validation loop when Flutter files are touched.

# Risks

- Dependency risk: OpenTUI is currently Bun-exclusive, so making it required would add friction. Mitigation: isolate under `tui` and keep optional.
- Scope creep risk: a TUI can easily become a command runner. Mitigation: V1 is read-only; writes/actions need a separate spec.
- Security risk: terminal app can expose local files. Mitigation: central source policy, allowlisted roots, symlink checks, size limits, redaction.
- Product drift risk: Flutter and TUI could diverge in vocabulary. Mitigation: document role split and share source concepts where practical.
- Maintenance risk: adding TypeScript/Bun introduces a second stack in `shipglows_app`. Mitigation: keep package small, with explicit validation commands.
- UX risk: terminal layouts can become dense. Mitigation: start with a narrow dashboard, searchable lists, detail pane, diagnostics, and keyboard help.

# Execution Notes

- The implementation should start with `/home/claude/shipglows/tui`, not root repo changes.
- Use OpenTUI for persistent screens only after confirming Bun works locally.
- Consider Gum separately for `shipglows.sh` prompts; do not force Gum into the OpenTUI package.
- Avoid importing Flutter data models into TypeScript. Reuse concepts and constraints, not source code.
- Treat current Flutter `source_path_policy.dart` behavior as a policy benchmark for the TUI source layer.
- Keep the first implementation local and read-only even if OpenTUI makes command execution easy.
- Fresh-docs verdict: `fresh-docs checked` for OpenTUI and Gum on 2026-05-17 using official docs/GitHub README.

# Open Questions

None.

# Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-05-17 21:45:03 UTC | sg-spec | GPT-5 Codex | Created the ShipGlows Terminal TUI V1 spec from user decision to place the TUI inside shipglows_app instead of a separate repo. | Draft spec created. | /sg-ready ShipGlows Terminal TUI V1 |
| 2026-05-17 21:51:33 UTC | sg-ready | GPT-5 Codex | Validated structure, metadata, user-story fit, source safety, external docs, language doctrine, adversarial review, and security scope. | ready | /sg-start ShipGlows Terminal TUI V1 |
| 2026-05-17 22:08:35 UTC | sg-build | GPT-5.3 Codex | Implemented optional `/home/claude/shipglows/tui` Bun/TypeScript OpenTUI V1 with read-only source policy, readers, view model, dashboard view, entrypoint, deterministic tests, documentation updates, and integration corrections for project-root allowlisting and current OpenTUI package version. | partial: Bun validation unavailable locally. | Install Bun, run `bun install`, `bun run typecheck`, `bun test`, then /sg-verify ShipGlows Terminal TUI V1 |
| 2026-05-17 22:44:21 UTC | sg-verify | GPT-5 Codex | Verified the TUI implementation against the spec, corrected the spec-title parser smoke failure, checked source-policy smoke behavior, static TypeScript syntax, docs coherence, dependency freshness, and Bun availability. | not verified: Bun/OpenTUI runtime checks cannot run locally and interactive navigation/filtering/selected-detail acceptance remains incomplete. | /sg-start complete TUI interaction gaps, install Bun, run `bun install`, `bun run typecheck`, `bun test`, and manual OpenTUI smoke. |
| 2026-05-18 05:21:58 UTC | sg-build | GPT-5 Codex | Completed the TUI interaction gaps: added dashboard navigation state, project/spec filters, selected detail rendering, run-history and chantier-flow spec summaries, Bun installation, current OpenTUI dependency, Bun lockfile, tests, docs updates, and OpenTUI TTY smoke. | implemented | /sg-verify ShipGlows Terminal TUI V1 |
| 2026-05-18 15:13:22 UTC | sg-verify | GPT-5 Codex | Verified user-story outcome, completeness, correctness, documentation coherence, dependency freshness, read-only/security boundary, bug gate, Bun/OpenTUI runtime smoke, typecheck, tests, source policy, and dependency audit. | verified | /sg-end ShipGlows Terminal TUI V1 |
| 2026-05-19 15:40:31 UTC | sg-design | GPT-5 Codex | Refined the TUI for phone-sized terminals: active-panel-only rendering, shorter header/status line, tighter project grid, shorter spec/activity lists, and compact docs/tests. | implemented | /sg-verify compact mobile terminal rendering before closure. |
| 2026-05-19 15:47:58 UTC | sg-fix | GPT-5 Codex | Fixed BUG-2026-05-19-001: project filtering now scopes specs by parsed spec `project:` metadata, selected project aliases, or the typed project scope; restored compact multi-section rendering with projects, specs, and recent tasks/audits. | fixed-pending-verify | /sg-test --retest BUG-2026-05-19-001 |
| 2026-05-19 16:03:54 UTC | sg-fix | GPT-5 Codex | Repaired BUG-2026-05-19-001 false-positive scope leak from generic path aliases (`home`, `claude`) using user evidence `p:"gocharb"` with `gocharbon_quiz` selected. | fixed-pending-verify | /sg-test --retest BUG-2026-05-19-001 |
| 2026-05-19 17:07:27 UTC | sg-design | GPT-5 Codex | Reduced phone-screen density: default view now renders only Projects and Specs; Recent tasks/audits render only from the activity panel. | implemented | /sg-test --retest BUG-2026-05-19-001 on phone. |
| 2026-05-19 17:33:05 UTC | sg-design | GPT-5 Codex | Moved Diagnostics out of the regular Tab cycle; Tab now cycles Projects, Specs, and Activity, while `d` opens Diagnostics as a rare action. | superseded | Use `!!!` instead of `d` to avoid filter collisions. |
| 2026-05-19 17:43:53 UTC | sg-design | GPT-5 Codex | Replaced the diagnostics shortcut `d` with the reserved `!!!` chord so normal letters remain available for project/spec filtering. | implemented | /sg-test TUI keyboard smoke on phone. |
| 2026-05-20 09:16:36 UTC | sg-fix | GPT-5 Codex | Fixed BUG-2026-05-20-001: Activity now parses task/audit Markdown tables instead of rendering file headings; local project rows are prioritized and legacy task sections are ignored. | fixed-pending-verify | /sg-test --retest BUG-2026-05-20-001 |
| 2026-05-23 10:35:35 UTC | sg-design | GPT-5 Codex | Added a global left margin and hanging continuation indentation across Projects, Specs, Activity, Audits, and Diagnostics; tightened the 3-column project grid to avoid terminal hard-wrap on phone width. | implemented | /sg-test TUI phone wrap smoke. |
| 2026-05-23 10:37:03 UTC | sg-design | GPT-5 Codex | Removed duplicated section labels from Activity/Audits rendering: Activity panel title is now `Tasks`, and Audits no longer repeats `Audits:` inside the list. | implemented | /sg-test TUI activity/audits label smoke. |
| 2026-05-23 11:08:19 UTC | sg-design | GPT-5 Codex | Increased the global TUI left gutter from two to four spaces so status traffic lights no longer sit against the screen edge; updated wrap regression coverage. | implemented | /sg-test TUI phone gutter smoke. |
| 2026-05-23 11:12:08 UTC | sg-design | GPT-5 Codex | Homogenized arrow navigation across panels: `Up`/`Down` now selects specs, tasks, and audits in their active panels, with the same `>` marker semantics. | implemented | /sg-test TUI active-panel navigation smoke. |
| 2026-05-23 11:21:45 UTC | sg-design | GPT-5 Codex | Added auto-scrolling visible windows for projects, specs, tasks, and audits so arrow navigation reveals results beyond the initially displayed rows without separate pagination keys. | implemented | /sg-test TUI list scrolling smoke. |
| 2026-05-23 11:25:57 UTC | sg-design | GPT-5 Codex | Added blank spacing between visible result rows across project rows, specs, tasks, and audits to improve phone readability without changing wrapped continuation indentation. | implemented | /sg-test TUI row spacing smoke. |
| 2026-05-23 16:48:22 UTC | sg-build | GPT-5 Codex | Moved the Terminal TUI ownership from `shipglows_app` into `/home/claude/shipglows/tui`, moved TUI spec/bug/technical docs into ShipGlows workflow data, updated installer aliases, and repointed app docs to the ShipGlows-owned location. | implemented | /sg-test TUI relocated install smoke. |
| 2026-05-23 19:44:11 UTC | continue | GPT-5 Codex | Integrated the ShipGlows root installer with the TUI installer, added the short `tui` command, ensured `~/.local/bin` is exported by ShipGlows user setup, and documented the new install path. | implemented | /sg-verify ShipGlows install TUI bootstrap. |
| 2026-05-23 19:49:02 UTC | sg-content | GPT-5 Codex | Documented the Terminal TUI internally and publicly across README, TUI operator guide, technical contract, editorial maps, public surface map, and the public docs page. | implemented | /sg-verify ShipGlows TUI documentation surfaces. |

# Current Chantier Flow

| Phase | Status | Evidence | Next step |
|-------|--------|----------|-----------|
| sg-spec | done | `shipglows_data/workflow/specs/shipglows-terminal-tui-v1.md` | /sg-ready ShipGlows Terminal TUI V1 |
| sg-ready | ready | Readiness gate passed on 2026-05-17 21:51:33 UTC. | /sg-start ShipGlows Terminal TUI V1 |
| sg-start | done | `/home/claude/shipglows/tui` implemented with read-only V1 scope, keyboard navigation, filtering, selected detail rendering, docs, tests, and Bun/OpenTUI smoke. | /sg-verify ShipGlows Terminal TUI V1 |
| sg-verify | verified | Bun 1.3.14, OpenTUI 0.2.14, `bun run typecheck`, `bun test`, `bun audit`, source-policy smoke, reader/view-model smoke, docs checks, and OpenTUI TTY smoke passed. | /sg-end ShipGlows Terminal TUI V1 |
| sg-design | implemented | Phone-sized terminal refinement: active-panel-only rendering, compact header, reduced list heights, docs, and regression tests. | /sg-verify compact mobile terminal rendering before closure. |
| sg-fix | fixed-pending-verify | BUG-2026-05-19-001 fixed with project-scoped specs, no generic path alias leaks, compact multi-section layout, typecheck, tests, diff check, and real-data smoke for `contentflow_app` and `gocharb`. | /sg-test --retest BUG-2026-05-19-001 |
| sg-design | implemented | Default phone view reduced to Projects + Specs; Recent tasks/audits moved behind the activity panel. | /sg-test --retest BUG-2026-05-19-001 on phone. |
| sg-design | implemented | Diagnostics removed from regular Tab cycle and moved to dedicated `!!!` chord, leaving normal letters available for filtering. | /sg-test TUI keyboard smoke on phone. |
| sg-fix | fixed-pending-verify | BUG-2026-05-20-001 fixed with table-aware activity summaries, local-first task/audit rows, legacy task exclusion, tests, typecheck, diff check, and real-data Activity smoke. | /sg-test --retest BUG-2026-05-20-001 |
| sg-design | implemented | Global TUI left margin and hanging wrap applied to all panels; 54-column smoke covers Projects, Specs, Activity, Audits, and Diagnostics. | /sg-test TUI phone wrap smoke. |
| sg-design | implemented | Activity/Audits title duplication removed; smoke shows `* Tasks` and `* Audits` without repeated inner labels. | /sg-test TUI activity/audits label smoke. |
| sg-design | implemented | Left gutter increased to four spaces before panel titles, project rows, and status traffic lights; 54-column smoke confirms indentation and hanging wraps. | /sg-test TUI phone gutter smoke. |
| sg-design | implemented | Active-panel navigation homogenized: task and audit rows now keep their own selection state and render `>` like specs. | /sg-test TUI active-panel navigation smoke. |
| sg-design | implemented | Visible lists now auto-scroll when the active selection moves past the displayed rows; no separate next-page command is required. | /sg-test TUI list scrolling smoke. |
| sg-design | implemented | Blank spacing inserted between displayed result rows while preserving hanging wrap alignment inside each result. | /sg-test TUI row spacing smoke. |
| sg-build | implemented | Terminal TUI moved to `/home/claude/shipglows/tui`; installer, aliases, spec, bugs, and technical docs now resolve from ShipGlows instead of ShipGlows App. | /sg-test TUI relocated install smoke. |
| continue | implemented | Root ShipGlows `install.sh` now provisions the TUI for configured users, exports `~/.local/bin`, and the TUI installer creates `tui`, `sftui`, `sg-tui`, and `shipglows-tui`. | /sg-verify ShipGlows install TUI bootstrap. |
| sg-content | implemented | Internal and public documentation now cover TUI purpose, install, aliases, read-only boundary, source-policy positioning, and Gum/Flutter relationship. | /sg-verify ShipGlows TUI documentation surfaces. |
| sg-end | pending | Not started. | Run closure. |
| sg-ship | pending | Not started. | Run after closure. |
