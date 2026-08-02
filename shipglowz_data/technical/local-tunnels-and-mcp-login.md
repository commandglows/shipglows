---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.1.2"
project: ShipGlowz
created: "2026-05-01"
updated: "2026-08-01"
status: reviewed
source_skill: sg-start
scope: local-tunnels-and-mcp-login
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - local/
  - local/README.md
  - README.md
depends_on:
  - artifact: "GUIDELINES.md"
    artifact_version: "1.2.0"
    required_status: reviewed
supersedes: []
evidence:
  - "local/README.md and function inventory for local scripts."
  - "Blacksmith OAuth callback tunnel added for remote CLI auth."
  - "Blacksmith SSH Access distinction documented as separate from OAuth callback tunneling."
  - "Managed tunnel detection accepts SSH targets before or after -L in process args."
  - "Local menu headers refreshed to match server ShipGlowz DevServer treatment."
  - "Turso SSH auth transfer helper added for remote CLI schema proof."
  - "Turso remote login helper accepts browser-provided headless JWT/token."
  - "Clerk CLI OAuth callback tunnel added for remote clerk auth login."
  - "Local auth flows grouped under a single tunnel menu entry."
  - "Password-authenticated saved connections can be promoted to independently verified per-device SSH keys without transferring private material."
  - "Android Termux is an explicit local tunnel surface with pkg-based dependency guidance."
  - "Native Windows PowerShell bootstrap and one-port OpenSSH tunnel proved on a Shadow PC on 2026-08-01."
next_review: "2026-06-01"
next_step: "Define the native Windows urls-menu parity contract before implementation."
---

# Local Tunnels And MCP Login

## Purpose

This doc covers the local tools that connect a workstation to a remote ShipGlowz server: app tunnels, saved SSH connection state, password-to-key promotion, remote PM2 and Flutter Web `tmux` port discovery, `shipflow-mcp-login` for remote Codex MCP OAuth callbacks, `shipflow-clerk-login` for remote Clerk CLI OAuth callbacks, `shipflow-blacksmith-login` for remote Blacksmith CLI OAuth callbacks, `shipflow-turso-login` for remote Turso CLI login, and `shipflow-turso-ssh` for Turso CLI auth transfer and schema proof.

Blacksmith SSH Access is intentionally separate from these OAuth callback tunnels. It connects a local terminal directly to an ephemeral Blacksmith runner for a live GitHub Actions job; it does not use `shipflow-blacksmith-login` and does not require a ShipGlowz server install.

## Owned Files

| Path | Role | Edit notes |
| --- | --- | --- |
| `local/local.sh` | Interactive local menu for tunnel lifecycle, status, server config, and MCP login | Preserve shared connection file semantics |
| `local/dev-tunnel.sh` | Non-interactive managed tunnel helper | Keep managed PID selection narrow |
| `local/mcp-login.sh` | Remote Codex MCP OAuth login tunnel flow | Do not store OAuth tokens |
| `local/clerk-login.sh` | Remote Clerk CLI OAuth login tunnel flow | Verify with `clerk whoami`; do not read or store Clerk token contents |
| `local/blacksmith-login.sh` | Remote Blacksmith OAuth login tunnel flow | Do not read or store Blacksmith token contents |
| `local/turso-login.sh` | Remote Turso CLI login flow, headless-first with optional callback tunnel mode | Do not read or store Turso token contents |
| `local/turso-ssh.sh` | Remote Turso CLI auth transfer and optional schema checks | Copy official CLI config only; never print token contents |
| `local/remote-helpers.sh` | SSH target, identity, public-key installation, key-only verification, and remote port helpers | Validate inputs before building SSH args; private keys never reach remote stdin |
| `local/install.sh`, `local/install_local.ps1`, `install-shipglowz.ps1` | Local installer scripts | Keep Termux, Linux, macOS, WSL, and Windows assumptions explicit |
| `local/README.md` | Operator-facing setup and troubleshooting | Update when commands or flow change |

## Entrypoints

- Unix, macOS, WSL, and Termux: `urls` and `tunnel` are shell aliases to `local/local.sh`.
- Native Windows PowerShell: `tunnel -Port <port>` launches the generated one-port OpenSSH tunnel. `$PROFILE` is the PowerShell startup script that registers this helper; `. $PROFILE` reloads it in the current terminal.
- `shipflow-mcp-login <provider|all>`: launches remote Codex MCP login and opens a temporary callback tunnel.
- `shipflow-clerk-login`: launches remote `clerk auth login`, opens a temporary callback tunnel, and verifies with `clerk whoami`.
- `shipflow-blacksmith-login`: launches remote `blacksmith auth login` and opens a temporary callback tunnel.
- `shipflow-turso-login`: launches remote `turso auth login --headless` by default, opens/prints the auth URL, accepts the browser-provided JWT/token when Turso shows one, stores it through the official remote CLI, then verifies `turso auth whoami`.
- Local `urls` menu entry `Authentifications distantes`: grouped wrapper for MCP Codex, Clerk CLI, Blacksmith, Turso login, ContentFlow checks, and fallback session copy.
- Local `urls` menu entry `Installer une clé SSH sur ce serveur`: selects or generates a per-device local identity, installs only its public record, verifies a fresh publickey-only connection, and promotes saved auth state.
- `shipflow-turso-ssh [db-name]`: copies local Turso CLI config to the remote server, verifies `turso auth whoami`, and optionally checks ContentFlow tables.
- `local/dev-tunnel.sh`: direct tunnel helper for scripted or simplified flows.

## Native Windows Status

As of 2026-08-01, the native Windows bootstrap is verified on Windows PowerShell 5.1 with WSL detected but unusable: it refreshes the PowerShell installer selectively, validates its syntax, configures Windows OpenSSH, writes the SSH target, creates `start-tunnel.ps1`, and proves an SSH connection. It requires neither WSL, Bash, Git, sudo, nor a preinstalled SSH client.

The Windows path is intentionally **not yet equivalent** to the Unix/Termux `urls` menu. It currently supplies only a manually selected one-port tunnel; it does not provide the Unix menu actions `t`, `u`, `a`, `s`, `r`, `c`, `k`, `o`, and `l`, nor the related password-session reuse, saved connections, key promotion, or OAuth helpers.

Gum has an official Windows distribution, but it is UI glue for shell scripts, not a Bash compatibility layer. Adding it would not run `local/local.sh` under PowerShell and must not be made a mandatory bootstrap dependency before a native menu contract exists. The immediate no-install alternative is the Hetzner browser console for the Unix server CLI. That console does not forward a server `localhost` port into the Windows browser; use existing public HTTPS URLs for browser previews, or the native tunnel helper for a selected private port.

Freshness: `fresh-docs checked` on 2026-08-01 against the official Gum installation documentation and the Hetzner Cloud console documentation.

## Control Flow

```text
local/local.sh
  -> load current connection
  -> fetch remote session identity with animated TTY scan feedback
  -> fetch remote PM2 ports and active Flutter Web tmux ports
  -> route remote auth flows through Authentifications distantes submenu
  -> validate local port availability
  -> start autossh tunnels
  -> show localhost URLs
```

```text
password-to-key promotion
  -> select an existing local identity or generate dedicated Ed25519
  -> derive and validate exactly one public-key record
  -> send public data through existing SSH stdin
  -> append by public blob without replacing authorized_keys
  -> verify with ControlPath=none and password fallbacks disabled
  -> update saved auth state only after proof
```

```text
shipflow-mcp-login
  -> run remote codex mcp login
  -> extract OAuth callback port
  -> open temporary ssh -L tunnel
  -> open or print provider URL
  -> wait for remote login completion
  -> clean up tunnel
```

```text
shipflow-clerk-login
  -> run remote clerk auth login with BROWSER=echo
  -> extract OAuth callback port
  -> open temporary ssh -L tunnel
  -> open or print Clerk URL
  -> wait for remote login completion
  -> verify clerk whoami without reading token files
  -> clean up tunnel
```

```text
shipflow-blacksmith-login
  -> run remote blacksmith auth login with BROWSER=echo
  -> extract OAuth callback port
  -> open temporary ssh -L tunnel
  -> open or print Blacksmith URL
  -> wait for remote login completion
  -> verify ~/.blacksmith/credentials exists without reading it
  -> clean up tunnel
```

```text
shipflow-turso-login
  -> run remote turso auth login --headless by default
  -> extract auth URL
  -> open or print Turso auth URL locally
  -> accept optional Turso JWT/token from the browser page
  -> run remote turso config set token without printing token contents
  -> verify turso auth whoami without reading token files
```

```text
shipflow-turso-ssh
  -> load saved ShipGlowz SSH target and optional identity
  -> copy ~/.config/turso contents to remote ~/.config/turso via scp
  -> chmod remote Turso config without reading token files
  -> run turso auth whoami directly or through project Flox
  -> optionally run ContentFlow jobs/CustomerPersona SQL schema checks
```

## Invariants

- SSH target and identity path are validated before use; accepted targets are valid IPv4 addresses, dotted DNS names, exact aliases from `~/.ssh/config`, or `user@host` forms using those host rules.
- Bare SSH identity filenames resolve from the menu launch directory, then `~/.ssh/`, then the user's home directory; the saved identity path should be absolute.
- Local port occupancy is checked before opening a tunnel.
- Managed tunnel stop logic should select ShipGlowz-owned tunnels, not broad process patterns.
- SSH tunnel forwards use `127.0.0.1` as the remote bind target instead of `localhost`, because `localhost` may resolve to `::1` or `127.0.0.1` depending on the server's network stack, which can mismatch the app's listening family and make the tunnel appear created but unreachable.
- Raw SSH process listing is debug-only operator output via `SHIPFLOW_DEBUG=1`.
- Active Flutter Web `tmux` ports are discovered from the server-side
  `SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE` registry and included only when the
  recorded `tmux` session still exists.
- OAuth tokens remain owned by Codex and the provider; ShipGlowz only routes the callback.
- Clerk auth tokens remain owned by Clerk CLI on the remote server; ShipGlowz
  only verifies auth through `clerk whoami`.
- Blacksmith auth tokens remain owned by Blacksmith CLI on the remote server;
  ShipGlowz only checks credentials-file presence.
- Turso tokens remain owned by the Turso CLI config. `shipflow-turso-ssh`
  copies the config only on explicit invocation and never logs token contents.
  `shipflow-turso-login` verifies auth with `turso auth whoami` only.
- Blacksmith SSH Access is not an OAuth tunnel. It is an organization-level
  Blacksmith feature that relies on the triggering user's GitHub SSH keys and a
  per-job SSH command from the `Setup runner` step.
- Saved connection state is shared by app tunnels, MCP login, and Blacksmith login.
- Each local device owns a distinct private key. ShipGlowz may authorize multiple device public keys on the same remote account but never synchronizes private keys.
- Password-to-key promotion sends only a validated single-line public record over SSH stdin. Public records with `authorized_keys` options, multiple lines, unsupported types, or a mismatch with the selected private identity are rejected before remote mutation.
- Remote key installation preserves all existing `authorized_keys` entries, deduplicates by the base64 public blob, and enforces mode `700` on `~/.ssh` and `600` on `authorized_keys`.
- The final key proof disables connection sharing with `ControlPath=none`, disables password and keyboard-interactive authentication, and forces the selected identity. Saved auth state remains unchanged when this proof fails.
- Dedicated generated keys are Ed25519 and unencrypted only after an explicit operator warning because background tunnels cannot answer passphrase prompts. Existing protected keys require `ssh-agent` for batch use.
- Key/agent SSH calls run in batch mode so menu scans fail visibly instead of
  blocking on hidden prompts. Password SSH opens a local OpenSSH master session
  first, then all commands and background tunnels reuse it through a protected
  control socket for eight hours; the password is never saved by ShipGlowz.
- The startup session scan is operator feedback only; set `SHIPFLOW_NO_ANIMATION=1` to disable the animated TTY loader.
- Local menu screens should use the shared local header treatment:
  `ShipGlowz DevServer` in yellow, padded boxed header, then the screen title.
- Android Termux must be detected before generic Linux. Missing dependencies
  must be reported with `pkg install openssh autossh`, never `sudo apt`.

## Failure Modes

- Callback connection refused usually means the fresh OAuth port was not tunneled.
- Clerk CLI `localhost` callback failures have the same root cause as MCP and
  Blacksmith OAuth callback failures when the CLI runs remotely and the browser
  is local.
- Blacksmith `localhost` callback failures have the same root cause as MCP
  OAuth callback failures when the CLI runs remotely and the browser is local.
- Turso CLI auth checks can fail if `turso` is absent from remote PATH; use a
  project Flox env with `--project-dir` when Turso is project-local.
- Turso does not consistently match the Blacksmith/MCP localhost callback
  model; use headless as the default remote flow and keep callback tunneling as
  an explicit advanced option.
- Reusing an old OAuth URL can fail because provider URLs and callback ports are per attempt.
- Password-mode tunnel creation fails when the local OpenSSH master session
  cannot be opened; display the SSH detail (timeout, refused connection, bad
  credentials, or host-key error) rather than treating it as an empty PM2 list.
- A malformed SSH identity path or target can become an SSH option if validation regresses.
- A mismatched `.pub` file, passphrase-protected key absent from `ssh-agent`, nonstandard remote authorized-key policy, or unwritable remote home blocks promotion and leaves the previous saved auth mode active.
- An active password ControlMaster can create a false positive unless key verification explicitly disables `ControlPath`; this is a blocking security invariant.
- Duplicate local ports should block before creating partial tunnels.
- A stale Flutter Web registry entry should be ignored by local tunnel tools
  when its `tmux` session is no longer active.

## Security Notes

- Never document or log private hosts, private keys, tokens, callback payloads, cookies, or provider secrets.
- Never transfer a private key to the server or between devices. Only the validated public record may reach the remote install command.
- Never replace `authorized_keys`, edit `known_hosts`, change `sshd_config`, or disable password authentication as an implicit pairing side effect.
- Treat saved connection files as local operator state, not public documentation.
- Provider names must be validated before they are passed to remote commands.

## Validation

```bash
bash -n local/local.sh local/dev-tunnel.sh local/mcp-login.sh local/clerk-login.sh local/blacksmith-login.sh local/turso-login.sh local/turso-ssh.sh local/remote-helpers.sh local/install.sh
bash tests/local/ssh-key-promotion.sh
bash tests/local/install-termux.sh
rg -n "validate_connection_target|validate_identity_file|check_local_port_free|parse_mcp_oauth_port_from_text|parse_clerk_oauth_port_from_text|shipflow-clerk-login|shipflow-turso-login|shipflow-turso-ssh" local/
```

PowerShell changes require a separate syntax/manual review on a PowerShell-capable host.

## Reader Checklist

- `local/` changed -> review this doc and `local/README.md`.
- MCP, Clerk, or Blacksmith OAuth flow changed -> review `README.md`, `local/README.md`,
  and the public remote MCP guide if user-visible.
- SSH parsing or key promotion changed -> run `tests/local/ssh-key-promotion.sh` plus an adversarial pass for option injection, malformed paths, private/public mismatch, ControlMaster reuse, and state rollback.
- Local installation changed -> run `tests/local/install-termux.sh` and retain a real Termux device check for Android tunnel behavior.

## Maintenance Rule

Update this doc when saved connection semantics, tunnel lifecycle, remote helper validation, MCP OAuth provider flow, or local operator commands change.
