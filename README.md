---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "0.17.1"
project: "ShipGlowz"
created: "2026-04-25"
updated: "2026-07-17"
status: draft
source_skill: 300-sg-docs
scope: readme
owner: "unknown"
confidence: medium
security_impact: unknown
risk_level: low
docs_impact: yes
linked_systems:
  - cli/shipglowz.sh
  - cli/lib.sh
  - cli/config.sh
  - cli/install.sh
  - skills
  - skills/004-sg-deploy/SKILL.md
  - skills/002-sg-maintain/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/006-sg-design/SKILL.md
  - skills/008-sg-customer/SKILL.md
  - skills/600-sg-local-cloud-sync/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/003-sg-bug/SKILL.md
  - skills/000-shipglowz/SKILL.md
  - skills/references/decision-quality-contract.md
  - skills/references/question-contract.md
  - skills/references/app-blueprints.md
  - skills/references/design-inspiration-library.md
  - shipglowz-site/src/content/skills/shipflow.md
  - shipglowz_data/technical
  - shipglowz_data/editorial
  - shipglowz_data/technical/codex-plugin-packaging.md
  - shipglowz-site
  - /home/claude/plugins/shipglowz/
depends_on: []
supersedes: []
evidence:
  - "2026-07-17 atomic routing update: deterministic micro-edits execute directly with focused validation instead of loading a lifecycle skill."
  - "Added 108-sg-browser as the generic non-auth browser verification path."
  - "Added 004-sg-deploy as the release confidence orchestrator."
  - "Added 002-sg-maintain as the recurring project maintenance orchestrator."
  - "Clarified 001-sg-build business-context decision questions."
  - "Added a public and repo-level skill launch cheatsheet for master skill modes."
  - "Added shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md as the standalone Markdown reference."
  - "Clarified that 900-shipglowz-core build routes fuzzy skill-maintenance ideas through 700-sg-explore before 100-sg-spec."
  - "Added 007-sg-content as the master content lifecycle entrypoint."
  - "Clarified 001-sg-build delegated sequential subagent consent and separated subagents from parallelism."
  - "Added skills/references/master-delegation-semantics.md as the shared master/orchestrator delegation doctrine."
  - "Added skills/references/master-workflow-lifecycle.md as the shared lifecycle skeleton and clarified bug files as source of truth."
  - "Documented 000-shipglowz <instruction> as the recommended non-technical router before direct sf-* expert entrypoints."
  - "Documented the shared question/default contract for numbered questions and context-safe defaults."
  - "Added 006-sg-design as the master design lifecycle entrypoint."
  - "Renamed 008-sg-customer as the customer activation lifecycle for first-success paths, setup guidance, recoverable states, and proof routing."
  - "Added 600-sg-local-cloud-sync as the local-first data promotion, merge, sync UX, and security contract skill."
  - "Clarified 003-sg-bug as a bug lifecycle executor that continues through owner skills and bounded subagents when safe."
  - "Added project competitors/inspirations and affiliate program registries to the business documentation frame."
  - "Added Codex plugin packaging and sparse source bootstrap documentation."
  - "Updated README to reflect the live public site and lightweight plugin distribution path."
  - "Added App Blueprints system: blueprint gate in 001-sg-build, blueprint consumption in 100-sg-spec and 306-sg-scaffold, flutter-crud-content blueprint from ContentGlowz."
  - "Clarified public/docs runtime handoffs: help explains, 000-shipglowz routes, owner skills execute, and OpenCode/KiloCode internal calls are not manual operator commands."
  - "Added dedicated repo-visible runtime pages for OpenCode and KiloCode and linked them from the core docs section."
  - "Added Tariq as an invokable named profile for acquisition-channel arbitration and traffic measurement discipline."
  - "Added a private rights-aware design/copy inspiration corpus contract, capture tool, and bounded Inspiration Gate."
next_step: "/300-sg-docs audit README.md"
---

# ShipGlowz

ShipGlowz is a unified framework for server delivery and AI-assisted execution discipline.
It also includes OpenCode-compatible skill shims under `.opencode/skills/shipglowz/` and `.agents/skills/shipglowz/` so the same top-level workflow entrypoint can be discovered outside Codex.

It has four active layers:
- a CLI for managing project environments on a server
- an optional read-only terminal TUI for operational visibility
- a skill system for structured coding workflows, audits, documentation, and shipping
- a lightweight Codex plugin and public site for distribution, onboarding, and pack discovery

It is built for solo founders and autonomous technical builders who want to launch, publish, and maintain software simply without losing context in agent handoffs.

ShipGlowz also carries product and claim governance for declared products. The framework does not only route code and docs work; it keeps product inventories, public surfaces, and evidence-backed claims coherent across the package.

## What ShipGlowz Does

ShipGlowz is designed to solve one problem first: lost context and weak handoffs in AI-assisted product work.

It helps operators run apps on servers, but its deeper job is to reduce ambiguity and give AI agents a better execution frame. That is why ShipGlowz should not be read as only a PM2-oriented server script, and not as only a methodology or prompt system for agents. It is the combination of both.

### Server environment management

- deploy and run projects under isolated Flox environments
- manage long-running processes with PM2
- assign and persist project ports
- expose apps through Caddy and DuckDNS
- support local access through SSH tunnel tooling, including password-first pairing promoted safely to a per-device SSH key
- run Flutter Web preview sessions in `tmux` with ShipGlowz-triggered hot reload

### Structured AI workflows

- task tracking and session lifecycle
- fast current-thread recap when a session becomes hard to follow
- spec-driven implementation flow
- verification and remediation loops
- proof-first testing with durable manual checklist artifacts under `shipglowz_data/workflow/test-checklists/`
- professional bug management with compact `shipglowz_data/workflow/TEST_LOG.md`, one durable Markdown bug file per bug under `shipglowz_data/workflow/bugs/`, optional/generated `shipglowz_data/workflow/BUGS.md` triage views, and redacted `test-evidence/BUG-ID/` evidence
- audits across code, design, copy, SEO, GTM, deps, perf, and translation
- documentation and research workflows
- product registry and claim-coherence checks for declared products, sales surfaces, and proof-backed public copy

## Core Docs

- Note: the canonical governance corpus lives under `shipglowz_data/`. Root-level docs outside `AGENT.md`, `AGENTS.md`, `CLAUDE.md`, `README.md`, `CHANGELOG.md`, compatibility shell wrappers, and bootstrap entrypoints should be treated as migration debt or explicit compatibility facades, not as the durable source of truth.

- [AGENT.md](./AGENT.md) — agent entrypoint: where to look first depending on the task
- [shipglowz_data/technical/context.md](./shipglowz_data/technical/context.md) — compact operational map of the project, hotspots, invariants, and edit routing
- [shipglowz_data/technical/context-function-tree.md](./shipglowz_data/technical/context-function-tree.md) — grouped function tree for the main shell scripts
- [shipglowz_data/editorial/content-map.md](./shipglowz_data/editorial/content-map.md) — editorial map for blog, docs, landing pages, semantic clusters, and repurposing destinations
- [shipglowz_data/editorial/README.md](./shipglowz_data/editorial/README.md) — content governance layer for public content, claims, page intent, and Astro content schema boundaries
- [shipglowz_data/technical/README.md](./shipglowz_data/technical/README.md) — internal technical documentation layer for code-proximate subsystem docs
- [shipglowz_data/technical/code-docs-map.md](./shipglowz_data/technical/code-docs-map.md) — map from code paths to primary docs, validations, and documentation update triggers
- [shipglowz_data/technical/codex-plugin-packaging.md](./shipglowz_data/technical/codex-plugin-packaging.md) — internal contract for the lightweight Codex plugin, sparse bootstrap, marketplace entry, and docs links
- [.opencode/skills/shipglowz/SKILL.md](./.opencode/skills/shipglowz/SKILL.md) — OpenCode-compatible repository skill shim
- [.agents/skills/shipglowz/SKILL.md](./.agents/skills/shipglowz/SKILL.md) — fallback OpenCode-compatible skill shim
- [shipglowz_data/technical/operator-guides/opencode-shipglowz.md](./shipglowz_data/technical/operator-guides/opencode-shipglowz.md) — repo-visible OpenCode usage, discovery, and configuration page
- [shipglowz_data/technical/operator-guides/kilocode-shipglowz.md](./shipglowz_data/technical/operator-guides/kilocode-shipglowz.md) — repo-visible KiloCode usage and compatibility-boundary page
- [shipglowz_data/technical/public-site-and-content-runtime.md](./shipglowz_data/technical/public-site-and-content-runtime.md) — internal contract for the Astro public site and public/private documentation boundary
- [shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md](./shipglowz_data/technical/operator-guides/skill-launch-cheatsheet.md) — Markdown cheatsheet for master skills, supporting skills, and argument modes
- [shipglowz_data/technical/operator-guides/focus-tags-cheatsheet.md](./shipglowz_data/technical/operator-guides/focus-tags-cheatsheet.md) — public cheatsheet for lightweight recentering tags across business, content, governance, execution, and system focus such as `#partner`, `#offer`, `#growth`, `#clarity`, `#pitch`, `#portfolio`, `#rules`, `#docs`, `#canon`, `#ship`, `#vfbf`, and `#shipglow`
- [skills/references/decision-quality-contract.md](./skills/references/decision-quality-contract.md) — shared doctrine for high-quality decisions, code, model routing, and fallback choices
- [skills/references/shipglowz-terms.md](./skills/references/shipglowz-terms.md) — shared terminology and lightweight focus tags such as `#partner`, `#offer`, `#quality`, `#vfbf`, `#growth`, `#clarity`, `#pitch`, `#portfolio`, `#rules`, `#docs`, `#canon`, `#shipglow`, `#routing`, and `#proof`
- [skills/references/operator-partnership-contract.md](./skills/references/operator-partnership-contract.md) — shared doctrine for agent autonomy, business-partner behavior, and business-aware initiative
  - [skills/references/master-delegation-semantics.md](./skills/references/master-delegation-semantics.md) — shared execution-topology doctrine for master/orchestrator skills
- [skills/references/master-workflow-lifecycle.md](./skills/references/master-workflow-lifecycle.md) — shared lifecycle skeleton and work item model for master/orchestrator skills
- [skills/references/operator-roles/](./skills/references/operator-roles/) — shared operator-role contracts such as `growth-operations-lead`, `product-architecture-planner`, `risk-and-coherence-guardian`, `end-user-adhesion-reviewer`, and `seo-specialist`
- [shipglowz_data/business/business.md](./shipglowz_data/business/business.md) — target audience, value proposition, business assumptions, and market framing
- [shipglowz_data/business/product.md](./shipglowz_data/business/product.md) — product scope, workflows, outcomes, and non-goals
- [shipglowz_data/branding/branding.md](./shipglowz_data/branding/branding.md) — tone, trust posture, vocabulary, and claims boundaries
- [shipglowz_data/business/gtm.md](./shipglowz_data/business/gtm.md) — public promise, acquisition path, proof points, objections, and funnel assumptions
- [shipglowz_data/technical/architecture.md](./shipglowz_data/technical/architecture.md) — system structure, boundaries, flows, and technical invariants
- [shipglowz_data/technical/guidelines.md](./shipglowz_data/technical/guidelines.md) — technical rules, preferred patterns, anti-patterns, and validation expectations
- [shipglowz_data/technical/terminal-tui.md](./shipglowz_data/technical/terminal-tui.md) — internal contract for the optional read-only terminal dashboard
- [CLAUDE.md](./CLAUDE.md) — repository constraints and coding guidance
- [Workflow doctrine](./shipglowz_data/workflow/playbooks/spec-driven-workflow.md) — ShipGlowz V3 workflow for `700-sg-explore`, `100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, and `104-sg-end`
- [Metadata migration guide](./shipglowz_data/technical/metadata-migration-guide.md) — how to adopt ShipGlowz metadata and versioning in an existing project
- [skills/references/canonical-paths.md](./skills/references/canonical-paths.md) — path resolution rules for ShipGlowz-owned tools, references, templates, and project-local artifacts
- [skills/references/private-data-repo-contract.md](./skills/references/private-data-repo-contract.md) — contract for the separate private data repository used for durable operator-managed data under `~/.shipglowz/private/data/`
- [skills/references/design-inspiration-library.md](./skills/references/design-inspiration-library.md) — private rights-aware sales-page/design reference corpus, capture bundle, and bounded operator-selection gate
- Runtime port and PM2 behavior is documented in [shipglowz_data/technical/runtime-cli.md](./shipglowz_data/technical/runtime-cli.md); the historical root note is preserved under [repository history](./shipglowz_data/workflow/archives/repository-history/root-documentation/ECOSYSTEM-AND-PORTS.md).
- [local/README.md](./local/README.md) — local tunnel setup
- [tools/codebase-mcp/README.md](./tools/codebase-mcp/README.md) — local MCP server for codebase context management
- [repository-history/README.md](./shipglowz_data/workflow/archives/repository-history/README.md) — classified historical docs, migration records, and preservation ledger

## Private Data Repo

ShipGlowz separates public code from durable private operator data.

- Public code, skills, tools, and governance stay in the ShipGlowz repository.
- Durable private operational data lives in `~/.shipglowz/private/data/`.
- That path is intended to be a separate Git repository so operators can version and back up private data without mixing it into public repos.
- The repository remote must be resolved from configuration such as `SHIPGLOWZ_PRIVATE_DATA_REPO`; it must not be hardcoded in shared doctrine.

This private repository is for durable operator-managed data such as project fiches and declarative mail-management registries. It may also hold short-retention operational state when versioning improves recovery.

It is not for secrets, OAuth tokens, cookies, SSH keys, or raw email bodies.

Use `~/.shipglowz/private/data/mail-intake/` for a short-retention private mail review queue when versioning improves recovery.

The separate design/copy inspiration corpus defaults to `${SHIPGLOWZ_INSPIRATION_LIBRARY_DIR:-${SHIPGLOWZ_PRIVATE_DIR:-$HOME/.shipglowz/private}/design-inspiration-library}` because durable cross-project marketing examples do not belong in `~/.shipglowz/private/data/`. Capture one synthetic fixture with `python3 tools/capture_design_inspiration.py --fixture tools/fixtures/design-inspiration/sample-sales-page.html --output "$TMPDIR/shipglowz-inspiration-test" --id sample-sales-page --no-network`. Source-derived text and images remain private; public files contain only contracts, code, schemas, and synthetic fixtures.

## Distribution and Installation

The current public website is deployed at:

```text
https://shipglowz.com
```

It is the public explanation, docs, pricing hypothesis, FAQ, and skill-discovery surface. The GitHub repository remains the source of truth for the full ShipGlowz skill and reference corpus.

### Local or server install

```bash
# Detect Termux/root automatically, otherwise ask local or full
curl -fsSL https://www.winflowz.com/shipglowz-script | sh
```

The repository is private, so GitHub access must already be configured for the
current account. Termux selects `local` without `sudo`; an existing root shell
selects `full`. In a non-interactive environment, put the mode on the consuming
shell:

```bash
curl -fsSL https://www.winflowz.com/shipglowz-script | SHIPGLOWZ_INSTALL_MODE=local sh
curl -fsSL https://www.winflowz.com/shipglowz-script | sudo env SHIPGLOWZ_INSTALL_MODE=full sh
```

Manual equivalents:

```bash
cd ~/shipglowz
./local/install.sh
sudo ./cli/install.sh
```

### Codex plugin alpha

ShipGlowz's Codex plugin path is intentionally lightweight. Users should not need to install many separate ShipGlowz plugins to start. The main plugin exposes one `shipglowz` entrypoint and can route to bundled or optional packs.

The repository now carries a repo-backed marketplace source at [`.agents/plugins/marketplace.json`](./.agents/plugins/marketplace.json) and the public plugin source at [`plugins/shipglowz`](./plugins/shipglowz). Its behavior is documented in [`shipglowz_data/technical/codex-plugin-packaging.md`](./shipglowz_data/technical/codex-plugin-packaging.md).

Public install path:

```bash
codex plugin marketplace add dianedef/ShipGlowz --ref main --sparse .agents/plugins --sparse plugins/shipglowz
```

Then restart Codex, open the plugin directory, choose the `ShipGlowz` marketplace, install `shipglowz`, and start with:

```text
$shipglowz help me choose the right workflow
```

In the current development workspace, the same plugin is also maintained locally at `/home/claude/plugins/shipglowz/` for packaging and validation work.

When the complete local ShipGlowz corpus is needed, the plugin uses an explicit sparse Git checkout instead of packaging the whole repository:

```bash
/home/claude/plugins/shipglowz/scripts/bootstrap_shipglowz_repo.sh
```

The bootstrap target defaults to `${SHIPGLOWZ_ROOT:-$HOME/.shipglowz/source}`. The legacy `SHIPFLOW_ROOT` fallback is still accepted. It includes `skills/`, `templates/`, `tools/`, `shipglowz_data/`, and `local/`, and excludes public-site assets, terminal UI assets, generated builds, and dependency directories. It must not run silently; cloning or updating source requires explicit operator approval.

### Install Privilege Model

ShipGlowz's complete server installer is intentionally root-level. The public
bootstrap itself starts without `sudo` so it can route Termux and workstations
to the user-local installer. Full mode delegates to `sudo ./cli/install.sh`
because it manages machine-wide dependencies and service configuration:

- system packages and tools such as Node.js, PM2, Flox, Caddy, GitHub CLI, `jq`, `fuser`, and `ss`
- global CLI binaries under `/usr/local`
- PM2 binary installation only; ShipGlowz does not configure PM2 boot autostart by default
- Caddy binary installation only; ShipGlowz disables the default system service
  and starts a user-mode Caddy proxy only while PM2 apps are online
- `/etc/dokploy/compose`
- ShipGlowz user configuration for root and detected regular users
- ShipGlowz Terminal TUI dependencies and commands: `tui`, `shipglowz-tui`, `sg-tui`, plus legacy aliases `sftui`, `sf-tui`, and `shipflow-tui`

If `./cli/install.sh` is launched without root, it stops before making partial system changes. The log explains that the root-only scope was skipped and tells the operator to rerun with `sudo`.

When the install runs interactively, ShipGlowz asks once whether to enable the permissive AI defaults. Non-interactive runs can set `SHIPGLOWZ_AUTONOMY_MODE=permissive` or `SHIPGLOWZ_AUTONOMY_MODE=standard`; the legacy `SHIPFLOW_AUTONOMY_MODE` name is still accepted. Root permissive mode still requires `SHIPGLOWZ_AI_ALLOW_ROOT_AUTONOMOUS=1` or an explicit confirmation at the prompt; the legacy `SHIPFLOW_AI_ALLOW_ROOT_AUTONOMOUS` fallback remains accepted too.

The recommended server shape is:

- use `root` or `sudo` for first-time system setup
- use a regular non-root account such as `ubuntu`, `opc`, `debian`, `ec2-user`, or a manually created user for daily work
- keep user-level config, credentials, project files, Claude/Codex settings, and ShipGlowz data scoped to the operational user
- start ShipGlowz environments explicitly when needed instead of relying on PM2 resurrection at boot
- let ShipGlowz manage the local Caddy proxy with the environment lifecycle
  instead of keeping a global root Caddy service running

`dotfiles` may prepare generic user tooling in `~/.local/bin`, `~/.local/share/pnpm`, and `~/.config`. ShipGlowz owns the AI/code workflow layer: skills, Claude/Codex settings, MCP registrations, ShipGlowz aliases, optional user-space AI CLIs, and each project's local `shipglowz_data`. `pnpm` is the default package manager for ShipGlowz-managed projects; `npm` remains only a compatibility fallback when a third-party tool still hard-requires it.

`cli/install.sh` now keeps the machine-level scope automatic but lets the operator choose the user-space agent/runtime layer interactively. The install can enable any combination of:

- `claude`
- `codex`
- `opencode`
- `kilocode`
- ShipGlowz runtime config for Claude/Codex (`~/.claude`, `~/.codex`, MCP registration, skills, aliases)
- ShipGlowz TUI

The current agent installs use `pnpm add -g` at install time, so ShipGlowz pulls the then-current npm package release rather than shipping pinned local binaries. For non-interactive runs, `SHIPGLOWZ_INSTALL_COMPONENTS` accepts values such as `claude,ai-runtime`, `claude,kilocode,tui`, `codex`, `ai-agents`, `all`, or `none`; the legacy `SHIPFLOW_INSTALL_COMPONENTS` name is still accepted.

Before the first install on a machine, restore project-local tracking data from your
existing project repositories or workspace artifacts. Legacy `~/shipglowz_data`
(historical control-plane content) should be treated as an archive only and migrated
project by project.

The same install also provisions the optional terminal cockpit in
`~/shipglowz/tui` / `$SHIPGLOWZ_ROOT/tui`. After opening a fresh shell, launch it
with:

```bash
tui
```

The TUI is intentionally read-only in V1. It gives a compact terminal view of
projects, specs, tasks, audits, and diagnostics while keeping skills and
Markdown files as the source of truth. See
[tui/README.md](./tui/README.md) for keys and
[shipglowz_data/technical/terminal-tui.md](./shipglowz_data/technical/terminal-tui.md)
for the internal architecture contract.

## Repository Shape

The current repository is split by ownership, not only by technology:

- `cli/` is the canonical server/runtime CLI layer. Root shell files such as `shipglowz.sh`, `lib.sh`, `config.sh`, and `install.sh` are compatibility launchers that forward to it.
- `tui/` is the optional terminal cockpit. It is a visibility layer, not a second workflow engine.
- `skills/` contains the ShipGlowz execution system and shared references.
- `shipglowz_data/` is the canonical internal governance corpus for technical, editorial, business, and workflow artifacts.
- `shipglowz-site/` is the public site runtime.
- `shipglowz_data/technical/operator-guides/` holds repo-visible public or operator-facing Markdown references.

If a root document duplicates a `shipglowz_data/` artifact, the `shipglowz_data/` artifact wins and the root file should be reduced to a compatibility facade or removed after preservation.

## Codex TUI Defaults

`cli/install.sh` configures Codex for selected eligible users (plus root baseline setup) by writing `~/.codex/config.toml` with either the permissive or standard mode selected during install, when the ShipGlowz runtime layer is selected:

```toml
tui.status_line = ["model-with-reasoning", "current-dir", "context-remaining", "five-hour-limit", "weekly-limit"]
tui.terminal_title = ["spinner", "thread", "project"]
```

It also sets `[beta] rmcp = true` in `~/.codex/config.toml`.

In permissive mode, the installer writes `approval_policy = "never"` and `sandbox_mode = "danger-full-access"`. In standard mode, it writes `approval_policy = "on-request"` and `sandbox_mode = "workspace-write"`.

The install is idempotent, preserves existing user custom settings, and keeps
ShipGlowz-managed config wrapped in its own markers so user edits outside those
blocks remain unchanged.

It also registers the default MCP set used by ShipGlowz. For Codex, these MCP
entries are written with `enabled = false` by default so a plain `codex`
launch stays lightweight:

- `context7` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `vercel` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `convex` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `clerk` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `supabase` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `playwright` in `~/.claude/settings.json` and `~/.codex/config.toml`
- `dataforseo` in `~/.claude/settings.json` and `~/.codex/config.toml`

Use the ShipGlowz Codex launcher when a session needs MCPs:

```bash
sf codex
```

Or open the interactive menu and choose
`MCP / Codex - Auth and launcher` -> `Launch Codex with selected MCPs`.
ShipGlowz asks for the workspace and MCP preset, then launches Codex directly in
the current terminal with session-only overrides such as
`mcp_servers.supabase.enabled=true`. It does not persistently enable MCPs and
does not close existing Codex conversations.

For remote Codex usage, ShipGlowz local tooling also supports OAuth login flows for hosted MCP providers through an ephemeral local SSH callback tunnel:

```bash
shipglowz-mcp-login vercel
shipglowz-mcp-login supabase
shipglowz-mcp-login all
shipglowz-clerk-login
shipglowz-blacksmith-login
shipglowz-turso-login
shipglowz-turso-ssh contentflow-prod2
```

The reason is specific to remote agent work: Codex or the provider CLI runs on
the server, but the OAuth provider redirects the browser to
`127.0.0.1:<port>/callback` on the local machine. ShipGlowz opens a temporary
SSH `-L` tunnel for the fresh callback port so the local browser can reach the
remote login process. This applies to hosted MCP provider logins, Clerk CLI
auth, and Blacksmith CLI auth.

The local menu stores the remote host, SSH user, and SSH auth mode used by
`urls`, `tunnel`, `shipglowz-mcp-login`, `shipglowz-clerk-login`, and
`shipglowz-blacksmith-login`. Legacy `shipflow-*` aliases remain available for
compatibility. You can leave the key path blank to use the normal
SSH config or agent, or switch to password mode for servers that do not use a
key. ShipGlowz does not store OAuth tokens; Codex, Clerk, Blacksmith, and the
provider own the token exchange. See
[local/README.md](./local/README.md) for the guided setup and troubleshooting
flow.

For Turso Cloud CLI auth on a remote ShipGlowz server, use
`shipglowz-turso-login` or the local `urls` menu's Turso entry. The remote
ShipGlowz `Agents` menu also includes a guided Turso screen with status,
login instructions, ContentFlow checks, and security notes. The local helper
uses Turso's headless login flow by default because Turso does not always match
the localhost callback behavior used by Blacksmith or hosted MCP OAuth. If the
Turso browser page displays a JWT/token, paste it back into the ShipGlowz prompt;
ShipGlowz sends it to the remote official CLI with `turso config set token` and
then verifies `turso auth whoami`.
`shipglowz-turso-ssh` remains the canonical fallback, and the legacy
`shipflow-turso-ssh` alias remains available, copying the
local official Turso CLI config directory to the configured server over
SSH/SCP, verifies `turso auth whoami`, and can run the ContentFlow table/column
checks when a database name is provided. ShipGlowz does not read or print Turso
tokens.

The server-side `sf` menu also includes `Blacksmith - CI runners and Testbox
setup`. This is a guided official-first helper for Blacksmith: it checks whether
the `blacksmith` CLI is installed, detects a local credentials file without
reading its contents, shows `T'inquiète, c'est bon, t'es connecté.` when the
local setup is ready, and prints the exact official command to run only when an
interactive install or Testbox init step is still required. It also has an SSH
Access guide for debugging live Blacksmith runners after a failed build. For
auth on a remote server, it routes the operator to the local `urls` menu's
Blacksmith login tunnel instead of suggesting `blacksmith auth login` directly
over SSH. ShipGlowz does not install the unofficial Blacksmith MCP by default and
does not patch project workflows automatically from this menu.

Notes:
- `shipglowz-gsc` is the ShipGlowz-owned, read-only Google Search Console CLI. It uses an operator-supplied Google OAuth desktop-client JSON and stores its refresh token only in `~/.config/shipglowz/gsc/` with owner-only permissions. It never enables the third-party GSC MCP or submits sitemaps. Run `shipglowz-gsc --help` after installation; see `shipglowz_data/technical/google-search-console-cli.md` for setup and commands.
- `dataforseo` is configured but disabled by default in Codex unless
  `SHIPFLOW_ENABLE_DATAFORSEO_MCP=1` and credentials are available.
- `playwright` MCP points to the local Playwright Chromium/Headless Shell
  executable when available, especially on Linux ARM64 where Google Chrome
  stable is not a valid fallback.

ShipGlowz also installs the terminal tooling commonly needed to operate those integrations:
- `node` / Node.js 24 LTS from NodeSource when needed
- `pm2`
- `vercel`
- `convex`
- `clerk`
- `supabase` via the standalone CLI binary, because Supabase does not support a supported global package-manager install path
- `gh` (GitHub CLI)
- `flox`
- `caddy`
- Playwright Chromium runtime libraries for the default browser MCP
- `python3` and `PyYAML`
- core tools: `git`, `curl`, `jq`, `fuser`, `ss` (`iproute2`), `python3-pip` (if needed)

For Dart/Flutter projects, ShipGlowz provisions runtime packages inside each
project Flox environment (not as a required global SDK). Defaults are
`SHIPGLOWZ_FLOX_DART_PACKAGES=dart` and
`SHIPGLOWZ_FLOX_FLUTTER_PACKAGES=flutter@3.41.5-sdk-links`, with strict token
validation on overrides. The `Tools & Web > Install SDK` menu stays available as
an optional global convenience.

Flutter Web can also be launched from `sf` through `Flutter Web - tmux hot
reload`. This starts `flutter run -d web-server` in a server-side `tmux`
session, records the port in `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE`, and lets
ShipGlowz send Flutter's `r` or `R` controls for hot reload or hot restart. This
is a web preview path for browser testing through SSH tunnels, not native
Android/iOS rendering.

Per-user configuration includes:
- `~/.claude/skills/*` and `~/.codex/skills/*` symlinks for every ShipGlowz skill
- aliases in `~/.bashrc` for `000-shipglowz`, `sf`, mode-selected `c`/`co`, safe escape hatches `cask`/`coask`, shell reload (`re`/`reload`), and tmux pane cleanup (`ch` = `clear; tmux clear-history`)
- `shipglowz_data/workflow/TASKS.md`, `shipglowz_data/workflow/AUDIT_LOG.md`

Skill runtime visibility can also be checked or repaired without rerunning the full installer:

```bash
tools/shipglowz_sync_skills.sh --check --all
tools/shipglowz_sync_skills.sh --repair --skill sg-example
```

The helper links current-user `~/.claude/skills/<name>` and `~/.codex/skills/<name>` entries to `$SHIPGLOWZ_ROOT/skills/<name>`. It reports missing or stale links, blocks non-symlink collisions by default, and notes that an already-running Claude or Codex session may need a reload before the repaired skill appears in the runtime list.

If your Codex version does not expose one of these items (for example `thread`), adjust interactively in Codex:

```text
/statusline
/title
```

Unlike Claude Code, Codex does not expose a custom shell-command status line renderer.

## Usage

```bash
sf
shipflow
sf t   # open Tools
sf codex   # open the Codex MCP launcher
```

Passing a visible root menu key as the only argument runs that menu action once.
Group keys open their submenu. Action-level confirmations still apply,
including before package upgrades. Inside menus, `x`, `Esc`, and `Backspace`
go back when a Back option exists.

Typical CLI actions:
- dashboard and PM2 status
- deploy, restart, stop, remove environments
- Flutter Web tmux sessions with hot reload/hot restart
- launch Codex with selected MCPs for this session only
- inspect local MCP process groups and stop a selected group after confirmation
- publish apps with public HTTPS URLs
- guided Blacksmith runner/Testbox setup for project CI
- health checks and crash loop detection

## Skill Workflow

Recommended non-technical entrypoint in a skill-aware agent session:

```text
000-shipglowz <instruction>
```

Use `000-shipglowz <instruction>` when you want ShipGlowz to choose the route. It answers pure conversational requests directly, executes deterministic micro-edits directly with focused validation, hands non-trivial feature/code/docs work to `001-sg-build`, upkeep to `002-sg-maintain`, bugs to `003-sg-bug`, release/deploy/prod proof to `004-sg-deploy`, content to `007-sg-content`, onboarding and activation work to `008-sg-customer`, local-to-cloud sync contract work to `600-sg-local-cloud-sync`, product-entitlement work to `601-sg-product-entitlements`, internal skill maintenance to `900-shipglowz-core build`, and obvious specialist audits to `400-sg-audit-*`. If the route is ambiguous, it asks one numbered question with why, the recommended answer, and practical options. When it routes, it hands the current thread directly to the selected skill; selected masters own their own delegated sequential execution.

You can also activate a named operator profile through the same router. Example:

```text
%Victoire #SEO Faut-il faire le playbook, la checklist, ou l'audit SEO d'abord ?
```

Compatibility form:

```text
000-shipglowz profile=victoire Faut-il faire le playbook, la checklist, ou l'audit SEO d'abord ?
```

Here, `Victoire` is not a separate skill. She is a named growth-operations profile that biases the answer toward prioritization, leverage, and explicit `not now`.

Other named profiles can coexist when they carry a distinct decision posture, for example `Prudence` for risk/coherence challenge, `Ariane` for structuring a fuzzy initiative into an executable plan, `Adhesion` for simulated end-user reaction, trust, and friction review, and `Tariq` for acquisition-channel arbitration and traffic measurement discipline.

`SEO Specialist` is another example profile when the question is about search intent, discoverability, and page/surface coherence.

Canonical syntax split:

- `%<Profile>` for named operator profiles
- `#<Tag>` for focus tags

Runtime invocation note:

- `302-sg-help` explains which skill to use or how a runtime behaves; it does not continue the work itself.
- `000-shipglowz` is the preferred router when you want ShipGlowz to choose the owner.
- In Codex or Claude-style runtimes, type the visible skill name such as `000-shipglowz` or `001-sg-build`.
- In OpenCode or KiloCode-style runtimes, ask for the ShipGlowz skill in natural language or use the runtime skill picker.
- Internal calls such as `skill({ name: "shipglowz" })` are runtime implementation details, not manual commands to type.

Decision-quality rule: ShipGlowz optimizes first for correctness, security, performance where relevant, maintainability, durability, professional best practices, and proof quality. Speed, cost, token economy, local convenience, or the shortest path are tie-breakers only after that quality bar is already satisfied. "Smallest safe path" means the smallest complete professional implementation, never the fastest patch that merely works.

Question/default rule: ShipGlowz skills should not ask just because several choices exist. They proceed by default only when the answer is clear from the request and project context, low-risk, reversible, inside the accepted scope, compatible with the current technical/product/editorial context, aligned with current best practices, quality-equivalent under the decision-quality rule, and verifiable in the current run. Otherwise they ask a numbered decision question with why, a responsible recommendation when one exists, and practical options.

ShipGlowz is now optimized for **one-pass execution**.

That means:
- the framing skill must carry the missing context before coding starts
- a `ready` spec must be executable by a fresh agent without reading the chat history
- agent prompts should already include linked systems, downstream consequences, and explicit validation targets
- if a fresh context is needed and cannot be created automatically, the skill must ask the user to open a new thread
- “prompt and correct” is a fallback for bounded drift, not the normal operating mode

Skill launch cheatsheet:

| Need | Launch | Useful modes |
| --- | --- | --- |
| Non-technical first command | `000-shipglowz <instruction>` | Answers pure conversation directly, executes deterministic micro-edits directly with focused validation, routes substantive work to the right skill, and asks one numbered decision question only when ambiguity changes route, risk, scope, or proof. |
| Named operator profile | `%Victoire <instruction>`, `%SEO-specialist <instruction>`, or `%Tariq <instruction>` | Canonical profile syntax for a named operator profile. Use `#Tag` separately for focus tags such as `#SEO`, `#traffic`, or `#acquisition`. |
| Non-technical first command with named profile | `000-shipglowz profile=victoire <instruction>`, `000-shipglowz profile=seo-specialist <instruction>`, or `000-shipglowz profile=tariq <instruction>` | Same router, with the selected profile active for the turn. |
| Non-trivial product, code, site, or docs work | `001-sg-build [spark|codex|mini|agents|sous-agent|no-agents] <story, bug, or goal>` | Plain task text is the story; `spark`, `codex`, `mini`, `agents`, and `sous-agent` strictly validate model-specific delegated sequential execution; for user-facing features, `001-sg-build` evaluates whether to suggest or route `/008-sg-customer` after implementation; use detailed report modes only for handoff evidence. |
| Recurring project upkeep | `002-sg-maintain [mode]` | `full`/no argument, `quick`, `security`, `deps`, `docs`, `audits`, `no-ship`, `global`. |
| Release confidence after implementation | `004-sg-deploy [target or mode]` | no argument, `skip-check`, `--preview`, `--prod`, `no-changelog`. |
| Bug-loop lifecycle | `003-sg-bug [BUG-ID, summary, or mode]` | no argument, `BUG-ID`, `--fix`, `--retest`, `--verify`, `--ship`, `--close`. |
| Content management | `007-sg-content [goal, source, file, or mode]` | `plan`, `repurpose`, `draft`, `enrich`, `audit`, `seo`, `editorial`, `apply`, `ship`. |
| Customer experience | `008-sg-customer <audit|flow|onboarding|recovery> <target>` | One customer owner with exact modes for existing-journey audits, first-success flow contracts, onboarding, recovery, docs impact, and proof routing. |
| Local-to-cloud data sync | `600-sg-local-cloud-sync <project, feature, or data domains>` | Local data promotion, cloud hydration, merge/conflict policy, sync/save UX states, sensitive-data exclusions, and proof routing. |
| Product entitlements and access gates | `601-sg-product-entitlements <project or feature>` | Entitlement ownership, provider events, activation codes, product-local mirrors, backend authorization gates, support flows, and sync handoffs. |
| Platform parity | `602-sg-platform-parity <project, feature, or platform set>` | Audit declared web, mobile, desktop, and native platform behavior; classify parity, adaptation, degradation, unsupported scope, and proof gaps before routing follow-up. |
| Conversation quality audit | `705-sg-conversation-audit [latest|path <file-or-dir>|export shipflow|report=agent]` | Audit ShipGlowz conversation transcripts and route repeatable findings to owner skills or specs. |
| Internal skill creation or maintenance | `900-shipglowz-core build <idea or path>` | new skill idea, existing skill path, optional `700-sg-explore` for fuzzy placement, runtime/docs validation gates. |
| Design lifecycle | `006-sg-design <design question or goal>` | Master design entrypoint for UI/UX, tokens, playgrounds, component/a11y audits, implementation, browser proof, verification, and ship routing. |
| Design system creation | `006-sg-design system [target]` | Build a complete professional token system from an existing UI; use `playground` or `audit tokens` as explicit follow-ups. |
| Manual expert lifecycle | `100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end` | Use when you intentionally want to drive each gate instead of using `001-sg-build`. |
| Commit and push ready work | `005-sg-ship [mode]` | no special argument, `skip-check`, `end la tache`/`end`/`fin`/`close task`, `all-dirty`/`ship-all`/`tout-dirty`. |
| Browser, auth, manual QA, or live deployment proof | `108-sg-browser`, `109-sg-auth-debug`, `107-sg-test`, `405-sg-prod` | Pick by proof type: non-auth browser evidence, auth/session diagnosis, durable manual QA, or deployment truth. |
| Git/GitHub hygiene | `310-sg-github-hygiene [mode]` | `audit`, `branches`, `dependabot`, `fix`, plus current-repo or workspace scope. |

Bug loop entrypoint:

```text
003-sg-bug -> 107-sg-test -> bug file -> 106-sg-fix -> 107-sg-test --retest -> 103-sg-verify -> 005-sg-ship
```

Use `003-sg-bug` when you want the professional bug loop executed from a `BUG-ID`, a fresh bug report, a retest request, or a ship-risk question. It continues through narrower owner skills and bounded subagents when safe, without bypassing the bug file, retest, verification, or ship-risk gates.

Bug-first repair entrypoint:

```text
106-sg-fix -> (fix directly or spec-first path)
```

Auth/browser diagnostic path:

```text
109-sg-auth-debug -> 106-sg-fix or 102-sg-start -> 103-sg-verify
```

Use `109-sg-auth-debug` before guessing from static code when the bug involves Clerk, OAuth, Google login, YouTube OAuth, Convex auth propagation, cookies, callbacks, protected routes, or Flutter web auth bridges. It can use Playwright where a real browser flow is accessible, and it carries local reference docs for the auth stacks ShipGlowz projects use most often.

General browser verification path:

```text
108-sg-browser -> 106-sg-fix, 107-sg-test, 405-sg-prod, 109-sg-auth-debug, or 103-sg-verify
```

Use `108-sg-browser` when you need browser evidence for a non-auth URL, route, preview, or production page: visible assertions, quick visual inspection, console/network summaries, screenshots, and page-level checks. It keeps deployment truth in `405-sg-prod`, auth/session diagnosis in `109-sg-auth-debug`, and durable manual QA logs in `107-sg-test`.

Fast thread recap:

```text
303-sg-resume -> 3-5 bullets, task statuses, close/keep-open verdict
```

Optional model-selection step:

```text
704-sg-model -> choose model / reasoning / fallbacks before execution
```

`704-sg-model` is advisory for the active conversation and prescriptive for delegated missions when the runtime supports model overrides. Model choice follows the decision-quality contract first: faster or cheaper fallbacks are allowed only when quality-equivalent for the risk. In Codex/OpenAI, `gpt-5.4-mini` fits small bounded low-risk missions; `gpt-5.3-codex-spark` fits Spark-eligible summaries, text-only handoffs, micro-code, or targeted UI/local edits when it does not replace needed reasoning and credits/availability permit; the `codex` implementation profile fits long implementation, multi-file coding, refactors, hard debugging, and terminal-heavy agentic execution; `gpt-5.5` is the premium choice for ambiguous, cross-project, governance-heavy, transverse audit, task-prioritization, prompt/docs migration, and business-risk synthesis work, with `low`, `medium`, `high`, or `xhigh` reasoning calibrated to the task. The active main thread must not claim it can always switch its own model mid-run: it can recommend a next-run model, route through `704-sg-model`, or pass a selected model to a subagent when that override is actually supported.

Direct build entrypoint for non-trivial feature/code/docs work:

```text
001-sg-build -> existing chantier check -> 100-sg-spec/101-sg-ready loop -> 102-sg-start -> 103-sg-verify -> 104-sg-end -> 005-sg-ship
```

`001-sg-build` has a **Blueprint Gate** between `existing chantier check` and the `spec/readiness loop`: it matches the user request against available app blueprints in `skills/app-blueprints/` to pre-fill architecture, stack, models, and routes before spec writing. Blueprints are global spec skeletons for recurring app archetypes (Flutter CRUD, etc.). When a blueprint is loaded, it flows through `100-sg-spec` (pre-filled sections) and `306-sg-scaffold` (conventions). When no blueprint matches, the normal spec-first workflow runs unchanged.

`001-sg-build` follows the shared master delegation doctrine in `skills/references/master-delegation-semantics.md`: invoking a master skill authorizes bounded delegated sequential execution for the current chantier, and `001-sg-build agents <story>` makes that a strict validation gate for file work, validation, closure preparation, and ship preparation. `spark`, `codex`, `sous-agent`/`subagent`/`agents`, and `mini` request model-specific subagent delegation; they never mean parallel execution. If a strict subagent request is made but no bounded subagent runs, `001-sg-build` must stop or report degraded execution with the reason. Short natural-language confirmations continue the bounded sequential path after diagnosis by intent rather than exact keyword. Parallel agent execution is not an argument mode; it requires ready non-overlapping `Execution Batches` in the spec. `001-sg-build` keeps user interaction focused on decisions and progress; material questions are framed as business decision briefs with the root problem, business stakes, options, and a recommended best-practice answer. It skips the question only when the best default is safe, reversible, compatible with the current project context, aligned with best practices, and verifiable. After user-facing feature work, `001-sg-build` also evaluates whether a `/008-sg-customer` pass should be handled or suggested so beginner adoption, setup, and first-success guidance are not forgotten after the code works.

Recommended release entrypoint after implementation:

```text
004-sg-deploy -> 105-sg-check -> 005-sg-ship -> 405-sg-prod -> 108-sg-browser/109-sg-auth-debug/107-sg-test -> 103-sg-verify -> 304-sg-changelog
```

`004-sg-deploy` is for release confidence, not just pushing code. It keeps technical checks, bounded shipping, deployment truth, post-deploy evidence, final verification, and optional release notes in one visible flow.

For hosting advice, ShipGlowz keeps the canonical rule in `skills/references/deploy-target-matrix.md`. Websites and Vercel-compatible web applications default to `Vercel`. Only projects that genuinely require a dedicated server runtime enter the server matrix: `Railway` by default, `Render` for preview-heavy server workflows, `Fly.io` for deeper infra/topology control, and `Codesphere` for sovereignty/private-cloud cases. A split architecture is evaluated per surface: Vercel for the compatible web frontend, and the matrix only for the dedicated backend. This is advice only; final choices remain project-contextual.

Recommended maintenance entrypoint for existing projects:

```text
002-sg-maintain -> triage -> 100-sg-spec/101-sg-ready when needed -> delegated maintenance lanes -> 103-sg-verify -> 004-sg-deploy/005-sg-ship
```

`002-sg-maintain` is the master maintenance lifecycle. It reviews bug risk, dependency posture, docs/governance drift, check coverage, audit freshness, migration candidates, and security posture, then carries needed work through spec/readiness, bounded delegated execution, verification, and ship/deploy routing. Use `/002-sg-maintain quick` for the old read-only triage behavior.

For ShipGlowz skill maintenance, use the dedicated entrypoint:

```text
900-shipglowz-core build -> 700-sg-explore when needed -> 100-sg-spec -> skill contract edit/create -> runtime skill sync -> 900-shipglowz-core refresh -> skill budget audit -> 103-sg-verify -> 300-sg-docs/help update -> 005-sg-ship
```

`900-shipglowz-core build` is scoped to creating or modifying `skills/*/SKILL.md` with explicit ambiguity-reduction, internal/public-surface, documentation, and validation gates. If the skill idea or placement is too fuzzy for one targeted question to settle, it routes to `700-sg-explore` before creating the durable `100-sg-spec` contract.

For content management, use the dedicated lifecycle entrypoint:

```text
007-sg-content -> CONTENT_MAP + editorial corpus -> owner content skills -> audits/docs -> validation -> 103-sg-verify -> 005-sg-ship
```

`007-sg-content repurpose <source>` creates the reusable source-faithful pack, its versioned storage under `shipglowz_data/workflow/repurpose-packs/`, and repurposing handoffs. The same lifecycle routes long-form drafting to `200-sg-redact`, existing-content upgrades to `201-sg-enrich`, marketing review or studies to `009-sg-marketing copy|copywriting|gtm|market`, search review to `406-sg-seo`, and docs/editorial governance to `300-sg-docs`. It uses the declared Astro blog surface (`site/src/content/articles/`, `/blog`, `/fr/blog`) for indexed articles and still blocks undeclared parallel article systems with `surface missing: blog`.

When a workflow or spec asks whether content is good enough for a specific project, content owner skills use the shared `skills/references/content-quality-rubric.md` contract. The rubric loads project rules from `shipglowz_data/business/*` and `shipglowz_data/editorial/*`, then returns a global score, criterion scores, evidence, recommendations, confidence, and one of `ready`, `needs revision`, `blocked`, or `publishable with caveats`. Blocking claims, missing project context, stale score signatures, and undeclared surfaces override the numeric score.

For end-user experience, feature activation, and onboarding, use the dedicated end-user entrypoint:

```text
008-sg-customer -> first-success path -> setup order -> states/recovery -> docs impact -> proof or 001-sg-build
```

`008-sg-customer` helps turn shipped features into usable customer journeys. Use it after or alongside feature work when users need UX/UI clarity, trust, friction reduction, setup guidance, permission or integration sequencing, skipped/blocked/recoverable states, and a proof path that shows they can reach value.

For local-first data promotion and cloud sync trust, use the dedicated sync entrypoint:

```text
600-sg-local-cloud-sync -> data inventory -> account association -> promotion/hydration -> merge/conflict/tombstones -> sync UX/security -> proof or 001-sg-build
```

`600-sg-local-cloud-sync` helps prevent data loss when local app usage becomes account-backed cloud usage. Use it before promising backup, reinstall recovery, multi-device sync, or account creation preserving local data.

For product access, paid plans, premium gates, provider events, activation codes, refunds, revokes, support access flows, and entitlement-backed backend authorization, use the dedicated entitlement entrypoint:

```text
601-sg-product-entitlements -> identity/provider/access separation -> ledger ownership -> backend gates/support -> sync/auth handoff or 001-sg-build
```

`601-sg-product-entitlements` keeps identity, provider events, durable entitlements, product-local mirrors, and data sync responsibilities separate. Use it before adding product gates or entitlement-backed data access, especially in suite products where duplicate local ledgers and stale mirrors can create security or support risk.

If the bug is local and clear, `106-sg-fix` fixes it directly, then verifies.
That fast path should still attach the bug to durable project memory with a `shipglowz_data/workflow/bugs/BUG-ID.md` bug file, unless the issue is an explicitly justified minor exception such as a copy-only or purely cosmetic fix. `shipglowz_data/workflow/BUGS.md`, when present, is only a compact optional/generated triage view.
If the bug is ambiguous or non-trivial, `106-sg-fix` routes to `100-sg-spec -> 101-sg-ready -> 102-sg-start`.

ShipGlowz keeps bug records split on purpose:

- `shipglowz_data/workflow/TEST_LOG.md` stays compact and records what was tested and how it went.
- `shipglowz_data/workflow/test-checklists/<scope>.md` stores operator-fillable manual scenarios when proof cannot be fully automated.
- `shipglowz_data/workflow/bugs/BUG-ID.md` holds the detailed source of truth for one bug work item.
- `shipglowz_data/workflow/BUGS.md`, when present, stays compact as an optional/generated triage index that points to bug files.
- `test-evidence/BUG-ID/` holds redacted evidence when screenshots, logs, or traces are too large or sensitive to inline.

Technical documentation layer:

```text
shipglowz_data/technical/code-docs-map.md -> primary subsystem doc -> Documentation Update Plan
```

Use this layer for code-changing work. It keeps technical details close to the code without bloating `AGENT.md`, `shipglowz_data/technical/context.md`, or public docs. `shipglowz_data/technical/` is internal-only in v1.

Governance corpus lifecycle:

```text
305-sg-init -> 300-sg-docs -> 001-sg-build
```

`305-sg-init` bootstraps `shipglowz_data/technical/`, `shipglowz_data/technical/code-docs-map.md`, `shipglowz_data/editorial/content-map.md`, and applicable `shipglowz_data/editorial/` files, or reports why a layer is skipped or blocked. `300-sg-docs` owns first-run bootstrap, adoption, update, and audit through `/300-sg-docs technical`, `/300-sg-docs editorial`, and `/300-sg-docs update`. `001-sg-build` consumes those project-local corpora as gates before implementation, closure, and ship; missing governance routes back to `300-sg-docs` instead of requiring the operator to rerun ShipGlowz's shipped governance specs per project.

For expert manual control, the default non-trivial workflow is:

```text
700-sg-explore -> exploration_report -> 100-sg-spec -> 101-sg-ready -> 102-sg-start -> 103-sg-verify -> 104-sg-end
```

For spec-first work, the spec is also the chantier registry. It keeps a
`Skill Run History` and a `Current Chantier Flow`, so you can open the spec and
see which lifecycle skills have run, which model was used, what result they
recorded, and what the next ShipGlowz command is. `shipglowz_data/workflow/TASKS.md`
and `shipglowz_data/workflow/AUDIT_LOG.md` stay
operational trackers; they do not become the per-chantier history. `PROJECTS.md`
is not an active doctrine location in this phase (legacy/migration-only context).

Fast path for a small, explicit fix:

```text
102-sg-start -> 103-sg-verify -> 104-sg-end
```

Bug fast path (recommended mental model):

```text
106-sg-fix -> 103-sg-verify -> 104-sg-end
```

The key rule is simple:
- reduce ambiguity before coding
- verify against the contract before closing

## Context Layer

ShipGlowz now uses a dedicated context layer for fast agent onboarding.

- `AGENT.md` is the routing file: it tells an agent where to look first.
- `shipglowz_data/technical/context.md` is the operational map: entry points, core flows, hotspots, invariants, and where to edit what.
- `shipglowz_data/technical/context-function-tree.md` is a specialized companion for large procedural files such as `lib.sh`.
- `shipglowz_data/editorial/content-map.md` is the editorial map: content surfaces, page roles, semantic clusters, pillar pages, and cross-surface update rules.
- `shipglowz_data/editorial/` is the editorial coherence layer: public content surfaces, claims, page intent, update gates, and Astro content schema policy.

This split is intentional. `CLAUDE.md` should hold constraints and critical rules, not the full project map. The context files exist to reduce repetitive discovery work at the start of a fresh thread without pretending to replace the code.

ShipGlowz also separates decision contracts by role:

- `shipglowz_data/business/business.md` for who the product is for and why it matters
- `shipglowz_data/business/product.md` for what the product should do and not do
- `shipglowz_data/branding/branding.md` for how the product should sound
- `shipglowz_data/business/gtm.md` for how the product should be presented and distributed
- `shipglowz_data/business/project-competitors-and-inspirations.md` for competitors, alternatives, inspirations, anti-patterns, and differentiation notes by project
- `shipglowz_data/business/affiliate-programs.md` for affiliate, referral, partner, sponsorship, disclosure, and non-secret credential pointers by project
- `shipglowz_data/editorial/content-map.md` for where content lives and how ideas should move between blog, docs, landing pages, FAQ, and semantic clusters
- `shipglowz_data/editorial/` for content governance: public content impact, public claims, page intent, and runtime content schema boundaries
- `shipglowz_data/technical/architecture.md` for how the system is organized
- `shipglowz_data/technical/guidelines.md` for how contributors should work inside it

Legacy root files such as `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `TASKS.md`, and `AUDIT_LOG.md` are migration sources only. They are not compliant final locations once a project adopts ShipGlowz.

## Documentation Frame

The current documentation structure is already solid on four axes:

- technical: `CLAUDE.md`, `shipglowz_data/technical/context.md`, `shipglowz_data/technical/context-function-tree.md`, `shipglowz_data/editorial/content-map.md`, `shipglowz_data/technical/guidelines.md`, and `shipglowz_data/workflow/specs/`
- workflow: `100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `300-sg-docs`, and versioned metadata
- product/business: `shipglowz_data/business/business.md`, `shipglowz_data/branding/branding.md`, versioned docs, and `depends_on` relationships
- editorial coherence: `shipglowz_data/editorial/content-map.md`, `shipglowz_data/editorial/`, public content, claims, page intent, and Astro content schema boundaries

The recent step forward is structural clarity:

- a dedicated context layer with `shipglowz_data/technical/context.md` and specialized context companions
- a stronger metadata and lint doctrine with artifact versioning plus `tools/shipglowz_metadata_lint.py`
- a public-content governance layer that keeps README, docs overview, FAQ, public skill pages, pricing copy, and claims aligned with product truth
- a cleaner separation between active docs, trackers, and runtime content

This means the framework is no longer just documented. It is organized so a fresh agent can enter, locate the right contract, and distinguish decision artifacts from operational tracking or app-rendered content.

## ShipGlowz as a Professional Work Framework

ShipGlowz is not just a collection of prompts or isolated skills. It is a work framework built around explicit decision contracts.

The core idea is that serious product work depends on more than code. A feature is shaped by user stories, business positioning, brand promises, security assumptions, documentation, pricing, onboarding, support, and operational constraints. ShipGlowz treats these as first-class project artifacts rather than informal chat context.

### Decision contracts

ShipGlowz artifacts are contracts that later skills can verify against:

- A spec is an implementation contract and chantier registry: it defines scope, invariants, linked systems, risks, acceptance criteria, documentation impact, and the skill-run history for that workstream.
- A business document is a product-decision contract: it defines the audience, value proposition, market, promise, pricing assumptions, and proof level.
- A brand document is a communication contract: it defines tone, trust posture, vocabulary, visual consistency, and claims that must not drift.
- An audit report is an evidence contract: it records what was checked, what remains uncertain, and what should happen next.
- A review or verification report is a closure contract: it distinguishes implemented, verified, assumed, partial, and unsafe-to-close work.

This is what makes ShipGlowz different from ad hoc AI assistance: every stage produces or consumes structured artifacts that can be reviewed, updated, and challenged.

### Metadata and traceability

ShipGlowz internal artifacts use YAML frontmatter metadata. The goal is not bureaucracy; the goal is traceability.

Common metadata fields include:

```yaml
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: "[project name]"
created: "2026-04-25"
created_at: "2026-04-25 10:30:00 UTC"
updated: "2026-04-25"
updated_at: "2026-04-25 10:30:00 UTC"
status: draft
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: "[user/team]"
user_story: "En tant que..., je veux..., afin de..."
confidence: medium
risk_level: medium
security_impact: unknown
docs_impact: yes
linked_systems: []
depends_on:
  - artifact: shipglowz_data/business/business.md
    artifact_version: "1.0.0"
    required_status: reviewed
evidence: []
next_step: "/101-sg-ready [title]"
```

Specs also include a markdown `Skill Run History` table and a `Current Chantier Flow`.
Lifecycle skills (`100-sg-spec`, `101-sg-ready`, `102-sg-start`, `103-sg-verify`, `104-sg-end`,
`005-sg-ship`) write to that history when a unique spec-first chantier is in scope.
Cross-cutting skills write only when the run is attached to one clear chantier;
helper skills such as `302-sg-help`, `704-sg-model`, `308-sg-status`, and `303-sg-resume` do not
write spec history.

ShipGlowz provides skill-aligned artifact templates in `templates/` and a dependency-free linter:

- `business_context.md`
- `brand_context.md`
- `product_context.md`
- `competitive_intelligence.md`
- `affiliate_program_registry.md`
- `architecture_context.md`
- `gtm_context.md`
- `content_map.md`
- `technical_guidelines.md`

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipglowz}"
"$SHIPFLOW_ROOT/tools/shipglowz_metadata_lint.py"
```

This layer is wired into the documentation workflow, agent routing, project context, migration guidance, and lint validation. It is not passive reference material; it is part of how ShipGlowz frames, executes, verifies, and documents work.

ShipGlowz-owned files are resolved from `${SHIPFLOW_ROOT:-$HOME/shipglowz}` even when a skill is running inside another repository. Project artifacts and source files are the only paths resolved from the current project root.

For legacy projects, use the migration playbook in [`shipglowz_data/technical/metadata-migration-guide.md`](./shipglowz_data/technical/metadata-migration-guide.md) before normalizing old docs.

By default it checks canonical `shipglowz_data/` artifact families, `AGENT.md`, and legacy-root guards. Legacy root artifacts and workflow surfaces such as `BUSINESS.md`, `TASKS.md`, `BUGS.md`, `TEST_LOG.md`, `docs/`, or `bugs/` fail layout compliance and must be moved to their canonical `shipglowz_data/` location. Pass explicit files or folders to validate a narrower scope.

For internal ShipGlowz files, this schema is mandatory for the active official artifact set. That set now includes `AGENT.md`, `shipglowz_data/technical/context.md`, `shipglowz_data/technical/context-function-tree.md`, `shipglowz_data/editorial/content-map.md`, and the decision contracts under `shipglowz_data/business/`, `shipglowz_data/technical/architecture.md`, `shipglowz_data/technical/guidelines.md`, and `shipglowz_data/business/gtm.md`, including the project competitors/inspirations and affiliate program registries when present. `CLAUDE.md` is supported as an optional active artifact when a project explicitly adopts it as the canonical repository guidance for Claude or multi-agent contributors. In that case, add ShipGlowz frontmatter and include it explicitly in metadata checks. For legacy project adoption, the default migration scope is intentionally narrower: active context docs when they exist, active decision contracts when they exist, and `shipglowz_data/workflow/specs/*.md`. Historical ad hoc docs can stay out of scope until they are promoted into the active ShipGlowz workflow.

Operational tracking files are intentionally excluded from the mandatory artifact schema: `shipglowz_data/workflow/TASKS.md` and `shipglowz_data/workflow/AUDIT_LOG.md` are trackers, not decision contracts. Keep them fast to edit. If a task entry contains a durable decision, spec, or business rule, extract that durable content into a dedicated artifact with metadata instead of adding frontmatter to the tracker itself.

Location rule:
- Project roots should keep only `README.md`, `AGENT.md`, `AGENTS.md` as a symlink to `AGENT.md`, optional `CLAUDE.md`, and project/tool-native docs that are not ShipGlowz governance artifacts.
- Canonical ShipGlowz artifacts are stored under project-local `shipglowz_data/` in `technical/`, `business/`, `editorial/`, `workflow/`, and `archives/`.
- Legacy references to `${SHIPFLOW_DATA_DIR:-$HOME/shipglowz_data}` should be treated as
  historical/read-only when encountered; it is no longer the active cross-project
  project-truth control plane.
- For adopted project repos, keep the same canonical shape by policy; root `BUSINESS.md`, `PRODUCT.md`, `BRANDING.md`, `GTM.md`, `ARCHITECTURE.md`, `CONTENT_MAP.md`, `CONTEXT.md`, `CONTEXT-FUNCTION-TREE.md`, `GUIDELINES.md`, `TASKS.md`, and `AUDIT_LOG.md` are migration sources, not compliant final locations.

Application runtime content keeps the schema required by the application. Blog posts, Astro content collections, MDX pages, and app-rendered docs must keep their framework-compatible frontmatter. ShipGlowz can enrich compatible fields, but it must not break the app parser.

### Business documentation is technical documentation

ShipGlowz treats `shipglowz_data/business/business.md`, `shipglowz_data/branding/branding.md`, `shipglowz_data/technical/guidelines.md`, `shipglowz_data/editorial/content-map.md`, personas, pricing notes, positioning, and GTM documents as technical artifacts because they drive technical, product, and content-routing decisions.

If `shipglowz_data/business/business.md` says the product serves solo founders, then copy, onboarding, pricing, feature scope, support, and prioritization should be evaluated against that audience. If `shipglowz_data/branding/branding.md` says trust and clarity are core values, then UI copy, error messages, claims, screenshots, and documentation must preserve that trust. If a pricing or positioning document is stale, a technically correct feature can still be strategically wrong.

Business documentation therefore needs the same discipline as code documentation:

- clear status: `draft`, `reviewed`, `stale`, `active`
- confidence level: `high`, `medium`, `low`
- evidence: interviews, user statements, analytics, market research, source URLs, or explicit assumptions
- review date and next review date
- linked artifacts: specs, audits, pages, onboarding, pricing, support docs
- artifact version and dependency references, so a spec can say which version of the business contract it was built against
- risk level when the document influences public promises, pricing, security, compliance, or user expectations

The practical rule is simple: if a document influences what the agent will build, audit, ship, or claim publicly, it must be traceable.

ShipGlowz uses two version fields:

- `metadata_schema_version` tracks the shape of the ShipGlowz metadata itself.
- `artifact_version` tracks the decision content of the document.

This matters when business or technical documentation changes. If a spec was written against `shipglowz_data/business/business.md` version `1.0.0`, and the business document later moves to `1.1.0` because the target persona or pricing changed, the spec should be rechecked before implementation. Versioning makes drift visible instead of relying on memory.

### Proof over optimism

ShipGlowz avoids treating green checks, commits, pushes, or polished copy as proof that work is done.

Skills should distinguish:

- `implemented`: code or content was changed
- `verified`: the intended outcome was checked
- `assumed`: the outcome is plausible but not proven
- `partial`: part of the promise is delivered
- `stale`: an artifact no longer matches the product

This matters for public and expensive products. Security, pricing, data handling, onboarding, docs, and support expectations can fail even when the code builds. ShipGlowz makes those gaps visible before they become production risk.

### Documentation coherence

When a feature changes, ShipGlowz treats documentation as part of the feature surface.

Relevant docs may include:

- README
- product docs
- API docs
- guides and examples
- FAQ
- onboarding
- pricing
- changelog
- support copy
- screenshots
- public marketing pages

Stale documentation is a product bug when it causes users or operators to misunderstand setup, security, pricing, permissions, API behavior, migration steps, destructive actions, or support expectations.

For medium and large changes, the contract is explicit:
- `100-sg-spec` defines scope, dependencies, invariants, links, consequences, and execution notes
- `101-sg-ready` rejects a spec that still depends on hidden assumptions
- `102-sg-start` executes from that contract instead of rediscovering intent
- `102-sg-start` now also selects a primary execution model and chooses execution topology before coding; master/orchestrator topology follows `skills/references/master-delegation-semantics.md`
- `103-sg-verify` checks the implementation and the linked systems that could regress around it

Success criterion:
- a fresh agent should be able to pick up the task in one pass

Operational rule:
- for non-trivial work, `101-sg-ready` and `102-sg-start` are the places where a fresh context may be enforced
- if multiple agents are used, write ownership and final integration responsibility must be explicit

## TASKS vs BACKLOG

Use both files on purpose:

- `shipglowz_data/workflow/TASKS.md` = active, prioritized, executable work
- `BACKLOG.md` = deferred ideas, parking lot, non-committed items

Promotion rule:
- move an item from `BACKLOG.md` to `shipglowz_data/workflow/TASKS.md` only when it is ready to be worked on now (clear enough, prioritized enough, and scoped enough)

## Repository Layout

```text
shipglowz/
├── shipglowz.sh                 # Compatibility launcher
├── lib.sh                      # Compatibility launcher
├── config.sh                   # Compatibility launcher
├── install.sh                  # Compatibility launcher
├── install-shipglowz.sh
├── README.md
├── CLAUDE.md
├── CHANGELOG.md
├── shipglowz_data/workflow/playbooks/spec-driven-workflow.md
├── shipglowz-site/
├── tui/
├── shipglowz_data/
│   ├── business/
│   ├── editorial/
│   ├── workflow/
│   ├── technical/
│   └── workflow/archives/
├── skills/
├── local/
├── tools/
├── templates/
└── injectors/
```

## Main Components

- `cli/shipglowz.sh` — interactive CLI entry point
- `cli/lib.sh` — shared shell library for ports, PM2, Flox, Caddy, validation, and tracking
- `cli/config.sh` — central configuration
- `cli/install.sh` — installation and machine setup
- `install-shipglowz.sh` — remote/bootstrap install helper
- `shipglowz-site/` — Astro public website deployed to `https://shipglowz.com`
- `shipglowz_data/technical/operator-guides/` — public or semi-public Markdown references such as the skill launch cheatsheet
- `tui/` — optional read-only terminal dashboard for ShipGlowz operators
- `skills/` — ShipGlowz skill library
- `local/` — local machine tunnel scripts and setup docs
- `tools/codebase-mcp/` — optional MCP server for token-efficient codebase work
- `templates/` — ShipGlowz artifact templates
- `shipglowz_data/workflow/research/` — research notes and evaluations
- `shipglowz_data/workflow/archives/` — classified inactive history retained inside the canonical governance corpus

The current Codex plugin alpha is outside the repository at `/home/claude/plugins/shipglowz/`. It should stay small and use the public GitHub repo plus sparse checkout when full local skill/reference access is needed.

## Key Features

- isolated per-project environments with Flox
- PM2-managed app lifecycle
- Flutter Web interactive `tmux` preview with hot reload
- persistent `ecosystem.config.cjs` generation
- automatic port allocation and collision avoidance
- user-mode Caddy proxy lifecycle tied to PM2 apps
- public HTTPS publishing through Caddy and DuckDNS
- local tunnel workflows
- spec-driven AI-assisted development workflows
- lightweight Codex plugin distribution with optional sparse source bootstrap
- public Astro site for onboarding, docs, FAQ, pricing hypothesis, and skill discovery

## Tech Stack

- Flox
- PM2
- Caddy
- DuckDNS
- Bash
- SSH / autossh

## Status

The canonical internal governance corpus lives under `shipglowz_data/`. The repository root keeps runtime/bootstrap entrypoints and explicitly documented compatibility files only.

Useful older plans, implementation summaries, and one-off reports live under [`shipglowz_data/workflow/archives/`](./shipglowz_data/workflow/archives/repository-history/) as inactive history, not current doctrine. Classified duplicate, generated, empty-facade, and unreferenced scratch material is deleted instead of archived indefinitely.
