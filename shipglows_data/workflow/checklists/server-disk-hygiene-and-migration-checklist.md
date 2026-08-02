---
artifact: checklist
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-07-13"
updated: "2026-07-13"
status: draft
source_skill: 300-sg-docs
scope: server-disk-hygiene-and-migration-checklist
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/workflow/playbooks/server-disk-hygiene-and-migration-playbook.md
  - cli/lib.sh
  - shipglows_data/technical/runtime-cli.md
depends_on:
  - artifact: "shipglows_data/workflow/playbooks/server-disk-hygiene-and-migration-playbook.md"
    artifact_version: "1.1.0"
    required_status: draft
supersedes: []
evidence:
  - "Checklist created from the 2026-07-13 disk-pressure diagnosis and targeted cleanup."
  - "ACP process-ownership checks added after the Avante npm wrapper left native children under PID 1."
next_review: "2026-07-20"
next_step: "Complete this checklist during new-server provisioning."
---

# Server Disk Hygiene And Migration Checklist

## Purpose

Provide the new-server agent with a reusable control surface for disk capacity, retention, protected data, stale processes, and post-migration verification.

## Applicability

Use during server provisioning, migration cutover, monthly maintenance, or recovery from disk pressure.

## Required Before Start

- [ ] Maintenance window and operator contact are known
- [ ] Current and new server hostnames are recorded
- [ ] Required incident-log retention is known
- [ ] Administrator access is confirmed or explicitly unavailable
- [ ] Active builds, previews, browser tests, agents, MCPs, and tmux sessions are inventoried
- [ ] Backup/rollback expectations are known

## Checklist

### Baseline

- [ ] Record `df -h /`
- [ ] Record home and `/tmp` sizes
- [ ] Record the largest home-directory entries
- [ ] Record `journalctl --disk-usage`
- [ ] Record deleted-but-open files with `lsof +L1`
- [ ] Record PM2 application restart counts
- [ ] Record current free-space state: healthy, warning, high, or critical

### Protected Data

- [ ] Record `PNPM_HOME`
- [ ] Record `pnpm store path`
- [ ] Protect `~/.local/share/pnpm`, `~/.pnpm-store`, and documented custom stores
- [ ] Protect source repositories and `.git`
- [ ] Protect credentials, auth state, skills, memories, and private data repositories
- [ ] Confirm no protected path appears in a deletion list

### Operating-System Retention

- [ ] Confirm `systemd-tmpfiles-clean.timer` status
- [ ] Confirm the `/tmp` retention policy
- [ ] Confirm system journal retention and size cap
- [ ] Keep 7–14 days of journals unless incident policy requires more
- [ ] Keep persistent journal usage within the approved 500 MB–1 GB range

### Process Hygiene

- [ ] List agent, ACP, MCP, editor, browser, language-server, and build processes
- [ ] Inspect any candidate's PID, PPID, elapsed time, session, children, and open files
- [ ] Exclude the current shell, agent, tmux session, preview, and browser test
- [ ] Terminate confirmed stale trees child-first with `SIGTERM`
- [ ] Recheck before using `SIGKILL`
- [ ] Verify global tool upgrades left no old deleted binaries open
- [ ] Verify editor ACP adapters launch a process they can terminate directly
- [ ] Run one ACP launch-and-stop lifecycle test and confirm the spawned PID exits
- [ ] Confirm clean editor exit leaves no new ACP process under PPID 1
- [ ] Schedule a reboot when deleted system/global binaries cannot be released safely in-session

### Cache And Temporary Hygiene

- [ ] Prefer official cache prune commands where available
- [ ] Review user-owned `/tmp` entries older than 14 days
- [ ] Remove only reviewed and inactive temporary entries
- [ ] Review obsolete browser automation versions before removal
- [ ] Do not prune PNPM stores as a generic cleanup action
- [ ] Review virtual environments with the project owner before removal

### Capacity And Alerts

- [ ] New volume is at least 100 GB
- [ ] Prefer 150 GB+ for Flutter/Rust/Android/browser-heavy usage
- [ ] At least 20% remains free after provisioning
- [ ] Warning is configured at 75% used or below 20 GB free
- [ ] High alert is configured at 85% used or below 12 GB free
- [ ] Critical alert is configured at 90% used or below 6 GB free
- [ ] Large builds require at least 15 GB free

### Verification

- [ ] Record final `df -h /`
- [ ] Record final home and `/tmp` sizes
- [ ] Record final journal usage
- [ ] Re-run `lsof +L1`
- [ ] Confirm PNPM homes and stores still exist
- [ ] Confirm active agents, projects, and services still work
- [ ] Confirm no uncontrolled high-growth producer remains
- [ ] Record reclaimed space and unresolved risks

### Handoff

- [ ] Attach before/after measurements
- [ ] Attach the classified large-path list
- [ ] Record actions requiring administrator approval
- [ ] Record processes intentionally left running and why
- [ ] Record the next weekly review date
- [ ] Give the next agent the prompt from the linked playbook

## Completion Rule

This checklist is complete only when protected data is verified, before/after measurements exist, retention policies are explicit, unresolved process or capacity risks have an owner, and the server is below the warning threshold or has an approved expansion plan.

## Linked Playbook

- [server-disk-hygiene-and-migration-playbook.md](../playbooks/server-disk-hygiene-and-migration-playbook.md)

## Exceptions

- Administrator-only journal or tmpfiles changes may remain pending when sudo is unavailable; record the exact command and owner.
- A server may remain above the warning threshold only with a documented volume-expansion or decommission plan.
- Active agent or browser processes must remain untouched until their session owner confirms closure.
