---
artifact: audit_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-29"
updated: "2026-06-29"
status: reviewed
source_skill: "400-sg-audit"
scope: "ShipGlows/dotfiles install coherence"
owner: "claude"
confidence: high
security_impact: medium
risk_level: medium
docs_impact: yes
linked_systems:
  - "/home/claude/shipglows/cli/install.sh"
  - "/home/claude/shipglows/README.md"
  - "/home/claude/dotfiles/install.sh"
  - "/home/claude/dotfiles/lib.sh"
  - "/home/claude/dotfiles/README.md"
  - "/home/claude/.codex/config.toml"
  - "/home/claude/.claude/settings.json"
depends_on: []
domains:
  - docs
  - install
  - security
issue_counts:
  high: 0
  medium: 0
  low: 0
supersedes: []
evidence:
  - "Dotfiles declares ShipGlows owns Claude/Codex skills and config, but dotfiles still contains direct Claude install and MCP writes."
  - "ShipGlows installer claims ownership of Claude/Codex settings, MCP registrations, and aliases."
  - "Live machine state has codex, npm, and pnpm available but no claude binary in PATH."
  - "Live machine state has ShipGlows-linked Claude skills and ShipGlows-backed CLAUDE.md symlink."
  - "Live machine state shows Codex config deviates from the README defaults."
next_step: "Align installer ownership boundaries, then rerun root ShipGlows install and a non-root dotfiles pass."
---

# ShipGlows + dotfiles install coherence audit

## Scope

Audit of installation responsibility boundaries between `/home/claude/shipglows` and
`/home/claude/dotfiles`, with focus on:

- AI agent installation (`claude`, `codex`)
- ownership of `~/.claude` and `~/.codex`
- MCP configuration ownership
- shell/bootstrap responsibility
- live machine state versus declared docs

## Executive summary

The ownership model is conceptually clear in the current docs:

- `dotfiles` should handle generic user tooling, shell, editor, and config symlinks.
- `ShipGlows` should own the AI/code workflow layer: skills, aliases, `Claude/Codex`
  config, MCP registrations, and user-local agent CLIs.

The implementation is not fully coherent yet.

The main operational issue on this machine is concrete:

- `codex` is installed and available
- `pnpm` is installed and available
- `npm` is installed and available
- `claude` is not available in `PATH`

That means the current install chain does not reliably produce a working dual-agent
setup even though both repos document that ShipGlows owns this layer.

## Findings

### 1. Ownership docs are aligned, but code still overlaps

`dotfiles` README says ShipGlows owns Claude/Codex workflow files and that dotfiles
must not silently run the ShipGlows installer from a non-root run:

- [`/home/claude/dotfiles/README.md:100`](/home/claude/dotfiles/README.md:100)
- [`/home/claude/dotfiles/README.md:202`](/home/claude/dotfiles/README.md:202)

`dotfiles/install.sh` repeats the same intent:

- [`/home/claude/dotfiles/install.sh:1106`](/home/claude/dotfiles/install.sh:1106)
- [`/home/claude/dotfiles/install.sh:1136`](/home/claude/dotfiles/install.sh:1136)

`ShipGlows` README also states that ShipGlows owns skills, Claude/Codex settings,
MCP registrations, aliases, and project-local `shipglows_data`:

- [`/home/claude/shipglows/README.md:229`](/home/claude/shipglows/README.md:229)

But `dotfiles/lib.sh` still overlaps with that ownership in two ways:

- direct Claude installation remains in dotfiles:
  [`/home/claude/dotfiles/lib.sh:2484`](/home/claude/dotfiles/lib.sh:2484)
- dotfiles still writes Claude MCP linkage:
  [`/home/claude/dotfiles/lib.sh:2571`](/home/claude/dotfiles/lib.sh:2571)

Conclusion: the doctrine is cleaner than the implementation.

### 2. ShipGlows now owns AI CLI install, but live state is partial

ShipGlows installs user agent CLIs through `pnpm`:

- [`/home/claude/shipglows/cli/install.sh:1617`](/home/claude/shipglows/cli/install.sh:1617)
- [`/home/claude/shipglows/cli/install.sh:1624`](/home/claude/shipglows/cli/install.sh:1624)
- [`/home/claude/shipglows/cli/install.sh:1625`](/home/claude/shipglows/cli/install.sh:1625)

Live machine state:

- `codex` present at `/home/claude/.npm-global/bin/codex`
- `pnpm` present at `/home/claude/.npm-global/bin/pnpm`
- `npm` present at `/home/claude/.npm-global/bin/npm`
- `claude` absent from `PATH`

This is the strongest evidence that the end-to-end install path is still fragile.

Possible causes consistent with the current code and state:

- ShipGlows root install did not complete the per-user `pnpm add -g @anthropic-ai/claude-code`
- install was run before the pnpm migration and only Codex was later repaired
- PATH/bootstrap for pnpm and npm globals is mixed between historical dotfiles state and
  newer ShipGlows state
- `claude` install failed silently during the root-run per-user setup

### 3. Current live Codex config does not match ShipGlows README defaults

ShipGlows README says standard mode should write:

- `approval_policy = "on-request"`
- `sandbox_mode = "workspace-write"`

See:

- [`/home/claude/shipglows/README.md:262`](/home/claude/shipglows/README.md:262)

Live Codex config is:

- `approval_policy = "on-request"`
- `sandbox_mode = "danger-full-access"`

See:

- [`/home/claude/.codex/config.toml:2`](/home/claude/.codex/config.toml:2)
- [`/home/claude/.codex/config.toml:3`](/home/claude/.codex/config.toml:3)

This is a real coherence mismatch between docs and machine state. Either:

- the machine is intentionally in a permissive sandbox mix and the README is stale, or
- the live config was manually changed or merged into a state outside the intended standard mode.

### 4. Current live Codex TUI config also differs from README examples

README example:

- [`/home/claude/shipglows/README.md:255`](/home/claude/shipglows/README.md:255)

Live config:

- [`/home/claude/.codex/config.toml:130`](/home/claude/.codex/config.toml:130)

The difference is not necessarily wrong, but it confirms the docs are not an exact
reflection of current live output.

### 5. ShipGlows skill ownership is working in the live state

This part is coherent.

Observed state:

- `~/CLAUDE.md` points to ShipGlows:
  [`/home/claude/shipglows/CLAUDE.md:1`](/home/claude/shipglows/CLAUDE.md:1)
- `~/.claude/skills/*` are symlinked into `/home/claude/shipglows/skills/*`
- `~/.tmux.conf` points to dotfiles, which is the expected split

So the high-level boundary is already visible in practice:

- shell/editor config -> dotfiles
- skill corpus -> ShipGlows

### 6. MCP ownership is still blurred in code, even if live files look ShipGlows-managed

ShipGlows declares ownership of MCP registrations:

- [`/home/claude/shipglows/README.md:229`](/home/claude/shipglows/README.md:229)

ShipGlows also writes multiple MCP sections into `~/.claude/settings.json` and
`~/.codex/config.toml`:

- [`/home/claude/shipglows/cli/install.sh:624`](/home/claude/shipglows/cli/install.sh:624)
- [`/home/claude/shipglows/cli/install.sh:843`](/home/claude/shipglows/cli/install.sh:843)
- [`/home/claude/shipglows/cli/install.sh:1133`](/home/claude/shipglows/cli/install.sh:1133)

But dotfiles still has an MCP component that links:

- `~/.config/mcp/servers.json`
- `~/.claude/mcp-servers.json`

See:

- [`/home/claude/dotfiles/lib.sh:2571`](/home/claude/dotfiles/lib.sh:2571)

This overlap is a maintenance trap. It allows drift between:

- ShipGlows JSON/TOML-managed runtime configs
- dotfiles-linked static MCP JSON

## Live state snapshot

### Present

- `~/CLAUDE.md -> /home/claude/shipglows/CLAUDE.md`
- `~/.tmux.conf -> /home/claude/dotfiles/.tmux.conf`
- `~/.claude/skills/* -> /home/claude/shipglows/skills/*`
- `codex` in `PATH`
- `npm` in `PATH`
- `pnpm` in `PATH`
- `~/.claude/settings.json` exists
- `~/.codex/config.toml` exists

### Missing or suspect

- `claude` not in `PATH`
- Codex sandbox mode does not match ShipGlows README standard-mode claim
- dotfiles code still contains ShipGlows-owned responsibilities

## Recommended corrections

### Priority 1

- Make `ShipGlows` the single owner of `claude`, `codex`, `~/.claude/*`, `~/.codex/*`,
  and runtime MCP registration.
- Remove or retire the `claude-code` install path in `dotfiles/lib.sh`.
- Remove or retire the `dotfiles` write/link path to `~/.claude/mcp-servers.json`.

### Priority 2

- Add explicit post-install verification in ShipGlows for both agent binaries:
  `command -v claude` and `command -v codex`.
- Fail loudly or emit a warning summary when one agent installs and the other does not.
- Include the resolved user-local binary path in the install report.

### Priority 3

- Reconcile ShipGlows README with actual current generated Codex config defaults.
- If `danger-full-access` is now intentional in standard mode on this machine, document why.
- Otherwise fix the generator or rerun the install in a clean expected mode.

## Recommended operator sequence on this machine

1. Patch ownership overlap so `dotfiles` stops touching ShipGlows-owned AI runtime config.
2. Rerun `sudo /home/claude/shipglows/cli/install.sh`.
3. Verify:
   - `command -v claude`
   - `command -v codex`
   - `pnpm -v`
   - `test -L ~/.claude/skills/000-shipglows`
   - inspect `~/.claude/settings.json`
   - inspect `~/.codex/config.toml`
4. Rerun non-root `dotfiles/install.sh` only for generic user config if needed.

## Bottom line

The architecture is mostly right now, but the install boundary is not fully enforced.

The biggest practical issue is not theoretical ownership drift. It is that the current
machine appears to have a half-working AI agent layer: Codex is installed, Claude is not.
