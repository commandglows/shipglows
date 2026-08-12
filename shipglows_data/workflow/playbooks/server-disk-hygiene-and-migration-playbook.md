---
artifact: documentation
metadata_schema_version: "1.0"
artifact_version: "1.1.1"
project: ShipGlows
created: "2026-07-13"
updated: "2026-08-12"
status: draft
source_skill: 300-sg-docs
scope: server-disk-hygiene-and-migration
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/lib.sh
  - shipglows_data/technical/runtime-cli.md
  - shipglows_data/workflow/checklists/server-disk-hygiene-and-migration-checklist.md
  - shipglows_data/technical/blacksmith.md
depends_on: []
supersedes: []
evidence:
  - "2026-07-13 incident: a 75 GB server reached 87% usage with only 9.5 GB free."
  - "The incident inventory found 493,169 Flox upgrade-check logs, PM2 restart storms, stale orphaned codex-acp and Playwright processes, old temporary files, and multiple development caches."
  - "A targeted non-DevServer cleanup increased available space from 9.5 GB to 12 GB without deleting PNPM stores or project sources."
  - "The Avante Codex ACP adapter was changed to launch its native platform binary directly so editor cleanup owns the process it terminates."
  - "Wave 18 clarified that the playbook owns the reusable method; its paired checklist depends on it, while this reverse relation remains provenance through linked_systems only."
next_review: "2026-07-20"
next_step: "/300-sg-docs review server disk hygiene and migration playbook after the new server hand-off"
---

# Server Disk Hygiene And Migration Playbook

## Purpose

Prevent development servers from silently filling their disks, separate ShipGlows DevServer responsibilities from operating-system and tool responsibilities, and provide a safe hand-off for a new server agent.

The objective is controlled retention, observable pressure, and recoverable cleanup. It is not maximum deletion.

## Applicability

Use this playbook when:

- provisioning a new ShipGlows development server
- migrating projects and agent tooling to another server
- disk usage reaches 80% or free space falls below 15 GB
- package managers, browsers, agents, SDKs, or build tools have been upgraded repeatedly
- `df` reports materially more usage than `du`
- stale agent, browser, or MCP processes remain after their parent session ended

## Responsibility Boundary

### ShipGlows DevServer owns

- PM2 application restart limits and restart-storm detection
- PM2 log rotation and bounded retention
- Flox log retention for environments launched by ShipGlows
- cleanup of generated project artifacts selected by the operator
- ShipGlows-owned agent cache/history cleanup options
- explicit protection of PNPM homes, stores, and global binaries

### Server operations owns

- filesystem capacity and alert thresholds
- systemd journal retention
- `/tmp` retention through systemd-tmpfiles or an equivalent OS policy
- package-manager and SDK cache policy outside ShipGlows cleanup
- stale or orphaned editor, agent, MCP, browser, and language-server processes
- reboot or service restart after global binary replacement
- verification that deleted-but-open files have actually been released

### Project owners decide

- whether a virtual environment can be recreated
- whether local browser binaries are still required
- whether generated outputs are disposable
- whether a custom package store can be pruned
- whether a long-running agent or preview session is still active

## Safety Invariants

- Never delete a path only because it is large.
- Never delete project source, `.git`, credentials, auth state, skills, memories, or private data repositories during disk cleanup.
- Preserve `PNPM_HOME`, the path returned by `pnpm store path`, `~/.local/share/pnpm`, `~/.pnpm-store`, and any documented custom store.
- Do not kill a process only because its name matches an agent or browser. Require age, parentage, ownership, and current-session checks.
- Prefer graceful termination before `SIGKILL`.
- Do not vacuum system logs below the retention required for incident investigation.
- Measure before and after every cleanup pass.
- Run destructive commands on an explicit path list; do not use broad home-directory globs.

## Inputs

- server hostname and operating system
- filesystem size and mount layout
- expected project count and largest toolchains
- current user and service accounts
- package-manager homes and stores
- active PM2, tmux, agent, MCP, browser, and preview sessions
- required incident-log retention period
- new-server cutover date and rollback window

## Baseline Capacity

For a server hosting Flutter, Rust, Node.js, Python, browser automation, several repositories, and multiple agent runtimes:

- treat 100 GB as a practical minimum
- prefer 150 GB or more when Android, Flutter, Rust, Playwright, or multiple parallel workspaces are common
- keep at least 20% free after provisioning
- reserve at least 15 GB before large builds, SDK upgrades, or dependency migrations

Use these operating thresholds:

| State | Trigger | Required response |
| --- | --- | --- |
| Healthy | below 75% used and at least 20 GB free | weekly observation |
| Warning | 75–84% used or below 20 GB free | inspect growth and schedule cleanup |
| High | 85–89% used or below 12 GB free | stop large builds and clean the same day |
| Critical | 90%+ used or below 6 GB free | stop heavy workloads, reclaim space, or expand the volume |

## Execution Order

### 1. Capture A Read-Only Baseline

Run as the normal operator user:

```bash
df -h /
du -xsh "$HOME" /tmp 2>/dev/null
du -xhd1 "$HOME" 2>/dev/null | sort -h | tail -30
du -xhd1 /var 2>/dev/null | sort -h | tail -20
journalctl --disk-usage
```

Record:

- total, used, available, and percentage used
- five largest home-directory entries
- `/tmp` size
- journal size
- current date and hostname

### 2. Explain `df` Versus `du`

If `df` reports much more used space than visible `du` totals, inspect deleted files still held open:

```bash
lsof +L1
```

Important: summing every `lsof` row can overcount shared deleted binaries mapped by many processes. Treat the list as a diagnostic, then verify reclaimed space with `df` after processes exit.

### 3. Classify Large Paths

Classify every candidate before cleanup:

- `source-of-truth`: preserve
- `credential-or-private-state`: preserve
- `package-store`: preserve unless the package manager performs its own safe prune
- `reproducible-cache`: prune with the owning tool or an explicit path
- `generated-build-output`: remove when no build is active
- `bounded-log`: rotate or vacuum
- `unbounded-log`: stop the producer, then prune
- `active-runtime`: do not touch
- `stale-runtime`: terminate after validation

### 4. Enforce OS Log Retention

Inspect first:

```bash
journalctl --disk-usage
journalctl --list-boots
```

Recommended policy for a development server:

- retain 7 to 14 days of system logs
- cap persistent journals around 500 MB to 1 GB unless incident requirements demand more
- verify the effective policy after any configuration change

Example one-time remediation, executed with administrator approval:

```bash
sudo journalctl --vacuum-time=14d
sudo journalctl --vacuum-size=750M
journalctl --disk-usage
```

Do not vacuum when the current incident still needs log evidence.

### 5. Enforce Temporary-File Retention

Prefer the operating system's tmpfiles policy:

```bash
systemctl status systemd-tmpfiles-clean.timer
systemd-tmpfiles --clean
```

If a manual fallback is required, inventory before deletion and use a conservative age threshold:

```bash
find /tmp -xdev -mindepth 1 -maxdepth 1 -user "$USER" -mtime +14 -print
```

Delete only reviewed, user-owned entries. Exclude active sockets, browser profiles, build processes, authentication callbacks, and files reported open by `lsof`.

### 6. Detect Stale Agent And Browser Processes

Inventory process ownership, age, parent, session, and command:

```bash
ps -eo pid,ppid,etimes,stat,comm,args --sort=-etimes
pstree -aps <pid>
lsof -p <pid>
```

A process is a stale candidate only when all applicable conditions hold:

- it belongs to the expected operator user
- it is older than the chosen threshold, normally seven days
- its parent is PID 1 or its original editor/agent session no longer exists
- it is not part of the current shell, tmux session, Codex session, browser test, or preview
- its open files and child processes have been inspected

Terminate child-first with `SIGTERM`, wait briefly, recheck, and use `SIGKILL` only for confirmed survivors. Never automate broad `pkill codex`, `pkill node`, or `pkill chrome` commands.

### 7. Handle Global Tool Upgrades Safely

Global npm, Codex, ACP, browser, or language-server upgrades can replace binaries while old processes still map the deleted version.

After global upgrades:

1. finish or checkpoint active agent work
2. close old editor/agent/MCP/browser sessions
3. confirm deleted binaries with `lsof +L1`
4. restart affected user services or reboot during the maintenance window
5. verify that only current binary paths remain open

Do not repeatedly upgrade global tooling without a process-restart step.

For editor ACP integrations, verify process ownership as part of setup:

- prefer launching the platform-native agent binary when a package-manager wrapper spawns a child without forwarding termination signals
- keep a documented wrapper fallback for installations whose package layout cannot be resolved safely
- confirm the editor has both an explicit stop action and a clean-exit hook
- run a launch-and-stop regression that proves the exact spawned PID exits
- after a forced crash, audit PPID 1 agent processes before starting another large batch

On the 2026-07-13 server, Avante launched the npm `codex-acp` JavaScript wrapper. Avante correctly terminated its direct child, but the wrapper's native child survived under PID 1. Launching the installed native binary directly restored one-process ownership and made Avante's existing stop and exit cleanup effective.

### 8. Prune Tool Caches Through Their Owners

Prefer supported commands over raw deletion when available:

```bash
uv cache prune
pip cache purge
```

For browser automation, remove only versions no longer referenced by active Playwright or MCP sessions. Reinstallation cost and offline requirements must be understood first.

PNPM policy:

- preserve stores during general cleanup and migration
- record `PNPM_HOME` and `pnpm store path` in the hand-off
- run `pnpm store prune` only as an explicit package-manager maintenance decision, never as a generic disk cleanup side effect

### 9. Verify The Result

Run:

```bash
df -h /
du -xsh "$HOME" /tmp 2>/dev/null
journalctl --disk-usage
lsof +L1
```

Success requires:

- free space increased by the expected order of magnitude
- no protected store or project path was removed
- no active session was interrupted
- no high-growth producer remains uncontrolled
- the server is below the warning threshold or has an explicit expansion plan

### 10. Establish A Cadence

- daily: automated disk threshold check
- weekly: top-level `du`, `/tmp`, journals, PM2 restart counts, and deleted-open-file check
- after every global tool upgrade: restart/reboot gate and `lsof +L1`
- monthly: cache and SDK review
- before large builds: verify at least 15 GB free
- before server migration: run the linked checklist and attach the measurements to the hand-off

## Decision Gates

### Safe To Clean Automatically

- tool-owned cache with an official prune command
- expired user-owned temporary files under an active retention policy
- bounded journals above the documented cap and outside an incident window

### Human Review Required

- killing agent, browser, MCP, editor, language-server, or build processes
- removing virtual environments or browser binaries
- pruning package stores
- changing filesystem size or mount layout
- reducing incident-log retention

### Blocked

- candidate path ownership is unknown
- an active process still writes to the target
- credentials, private data, source, or the only copy of an artifact may be present
- current incident evidence has not been preserved
- the cleanup would interrupt the current operator session

## Outputs

- before/after disk measurements
- classified list of large paths
- cleanup actions and reclaimed-space estimate
- remaining high-growth risks
- recorded PNPM home and store paths
- new-server retention configuration decisions
- completed linked checklist
- agent hand-off containing next verification date

## New-Server Agent Hand-Off Prompt

Give the following prompt to the agent after ShipGlows and project repositories are available on the new server:

```text
Apply the ShipGlows server disk hygiene and migration playbook at:
/home/claude/shipglows/shipglows_data/workflow/playbooks/server-disk-hygiene-and-migration-playbook.md

Complete the paired checklist at:
/home/claude/shipglows/shipglows_data/workflow/checklists/server-disk-hygiene-and-migration-checklist.md

Start read-only. Record df/du, journal usage, /tmp usage, lsof +L1, PM2 restart counts,
PNPM_HOME, and pnpm store path. Preserve all PNPM stores, credentials, source repositories,
skills, memories, and private data. Configure bounded journal and temporary-file retention only
after confirming administrator access and the desired incident-retention window. Do not kill an
agent/browser/MCP process without proving it is stale and outside the current session. Finish with
before/after measurements, unresolved risks, and the next weekly review date.
```

## Linked Checklists

- [server-disk-hygiene-and-migration-checklist.md](/home/claude/shipglows/shipglows_data/workflow/checklists/server-disk-hygiene-and-migration-checklist.md)

## Common Risks

- confusing shared deleted mappings in `lsof` with reclaimable unique bytes
- cleaning symptoms while leaving a restart storm or log producer active
- deleting PNPM stores to gain short-term space
- allowing global tool upgrades to accumulate deleted-but-open binaries
- using broad process-name kills that interrupt active work
- keeping unlimited journals or temporary files
- provisioning a new server with the same undersized disk and no thresholds
- documenting cleanup commands without human-review gates

## Validation

```bash
python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py \
  /home/claude/shipglows/shipglows_data/workflow/playbooks/server-disk-hygiene-and-migration-playbook.md \
  /home/claude/shipglows/shipglows_data/workflow/checklists/server-disk-hygiene-and-migration-checklist.md
```

## Maintenance Rule

Update this playbook after any disk-pressure incident, change in DevServer cleanup ownership, package-store policy change, server migration, or newly observed stale-process failure mode.
