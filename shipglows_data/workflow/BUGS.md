# Bugs

| Bug ID | Status | Severity | Title | Last tested | Next step |
|--------|--------|----------|-------|-------------|-----------|
| [BUG-2026-09-02-005](shipglows_data/workflow/bugs/BUG-2026-09-02-005.md) | closed | high | Windows runtime transaction requires launchers before they are generated | 2026-09-02 | none |
| [BUG-2026-09-02-004](shipglows_data/workflow/bugs/BUG-2026-09-02-004.md) | closed | high | Flutter Windows intermittently loses its debug connection before app.started | 2026-09-02 | Monitor future Flutter Windows cold starts |
| [BUG-2026-09-02-003](shipglows_data/workflow/bugs/BUG-2026-09-02-003.md) | closed | high | Native Windows launcher bypasses Gum menus and project pickers | 2026-09-02 | none |
| [BUG-2026-09-02-002](shipglows_data/workflow/bugs/BUG-2026-09-02-002.md) | closed | high | Windows CLI startup still takes seconds because s launches PowerShell | 2026-09-02 | none |
| [BUG-2026-08-26-001](shipglows_data/workflow/bugs/BUG-2026-08-26-001.md) | fix-attempted | medium | Windows clone reports success when project preparation fails | 2026-08-26 | Independently verify the clone registration failure contract |
| [BUG-2026-08-25-001](shipglows_data/workflow/bugs/BUG-2026-08-25-001.md) | closed | medium | OWASP contract test reads UTF-8 files with the Windows CP-1252 default | 2026-08-25 | none |
| [BUG-2026-08-24-001](shipglows_data/workflow/bugs/BUG-2026-08-24-001.md) | closed | medium | Capture tool ignores the linked ShipGlows developer root on Windows | 2026-08-24 | none |
| [BUG-2026-08-23-003](shipglows_data/workflow/bugs/BUG-2026-08-23-003.md) | fixed-pending-verify | high | Flutter Web ignores the Chromium already managed by ShipGlows | 2026-08-23 | Verify one managed Flutter Web launch in a separate project scope |
| [BUG-2026-08-23-002](shipglows_data/workflow/bugs/BUG-2026-08-23-002.md) | fixed-pending-verify | high | Managed Flutter reruns preserve a stale detached SDK | 2026-08-23 | Decide the app lockfile update, then verify analyze, tests, and Windows build |
| [BUG-2026-08-23-001](shipglows_data/workflow/bugs/BUG-2026-08-23-001.md) | fixed-pending-verify | high | Validated Flutter SDK skips PATH activation and overstates Windows readiness | 2026-08-23 | Decide the app lockfile update, then verify analyze, tests, and Windows build |
| [BUG-2026-08-19-001](shipglows_data/workflow/bugs/BUG-2026-08-19-001.md) | closed | medium | CLI always reports low RAM on VMs smaller than its absolute threshold | 2026-08-20 | none |
| [BUG-2026-08-03-002](shipglows_data/workflow/bugs/BUG-2026-08-03-002.md) | closed | high | env_remove leaves manual project devservers running | 2026-08-03 | none |
| [BUG-2026-08-03-001](shipglows_data/workflow/bugs/BUG-2026-08-03-001.md) | closed | medium | Global contract suite fails after repository and skill-name migrations | 2026-08-03 | none |
| [BUG-2026-06-26-001](shipglows_data/workflow/bugs/BUG-2026-06-26-001.md) | closed | high | ShipGlows installer configures every eligible user by default | 2026-06-26 | none |
| [BUG-2026-05-20-001](shipglows_data/workflow/bugs/BUG-2026-05-20-001.md) | fixed-pending-verify | medium | Terminal TUI activity panel shows headings instead of task and audit entries | 2026-05-20 | /sg-test --retest BUG-2026-05-20-001 |
| [BUG-2026-05-19-001](shipglows_data/workflow/bugs/BUG-2026-05-19-001.md) | fixed-pending-verify | medium | Terminal TUI project filter does not scope specs | 2026-05-19 | /sg-test --retest BUG-2026-05-19-001 |
| [BUG-2026-05-10-005](shipglows_data/workflow/bugs/BUG-2026-05-10-005.md) | fix-attempted | medium | Menu navigation ignores typed environment/folder name | 2026-05-10 | /sg-test --retest BUG-2026-05-10-005 |
| [BUG-2026-05-08-002](shipglows_data/workflow/bugs/BUG-2026-05-08-002.md) | closed | high | Health Check can auto-enter aggressive cleanup after pressing H | 2026-05-08 | none |
| [BUG-2026-05-08-001](shipglows_data/workflow/bugs/BUG-2026-05-08-001.md) | closed | high | ShipGlows top-level menu takes several seconds to render with Gum | 2026-05-08 | none |
| [BUG-2026-05-06-001](shipglows_data/workflow/bugs/BUG-2026-05-06-001.md) | closed | high | Stop Environment leaves orphaned PM2 apps and allows crash loops | 2026-05-08 | none |
| [BUG-2026-05-05-002](shipglows_data/workflow/bugs/BUG-2026-05-05-002.md) | fix-attempted | medium | Local tunnel restart reports no active tunnel when SSH target follows -L | 2026-05-05 | /sg-test --retest BUG-2026-05-05-002 |
| [BUG-2026-05-05-001](shipglows_data/workflow/bugs/BUG-2026-05-05-001.md) | fix-attempted | medium | ShipGlows tracking init should not create project TASKS.md symlinks | 2026-05-05 | /sg-test --retest BUG-2026-05-05-001 |
| [BUG-2026-05-04-004](shipglows_data/workflow/bugs/BUG-2026-05-04-004.md) | fixed-pending-verify | medium | Convex-only package.json blocks Flutter dev command detection | 2026-05-05 | /sg-verify BUG-2026-05-04-004 |
| [BUG-2026-05-04-003](shipglows_data/workflow/bugs/BUG-2026-05-04-003.md) | fix-attempted | medium | Blacksmith remote auth callback fails without SSH tunnel | 2026-05-04 | /sg-test --retest BUG-2026-05-04-003 |
| [BUG-2026-05-04-002](shipglows_data/workflow/bugs/BUG-2026-05-04-002.md) | closed | medium | ShipGlows menu Back/cancel navigation has inconsistent feedback | 2026-05-04 | none |
| [BUG-2026-05-04-001](shipglows_data/workflow/bugs/BUG-2026-05-04-001.md) | closed | high | Disk cleanup under-warns critical root disk pressure | 2026-05-04 | none |
| [BUG-2026-05-03-001](shipglows_data/workflow/bugs/BUG-2026-05-03-001.md) | closed | medium | New ShipGlows skill is not visible in Codex because runtime symlinks are missing | 2026-05-03 | none |
| [BUG-2026-05-02-001](shipglows_data/workflow/bugs/BUG-2026-05-02-001.md) | closed | medium | Playwright MCP points to missing Google Chrome on Linux ARM64 | 2026-05-04 | none |
| [BUG-2026-05-02-002](shipglows_data/workflow/bugs/BUG-2026-05-02-002.md) | closed | medium | Local SSH server prompt accepts invalid hosts and glues menu output in Termux | 2026-05-04 | none |
| [BUG-2026-05-02-003](shipglows_data/workflow/bugs/BUG-2026-05-02-003.md) | closed | medium | Local SSH setup rejects bare relative identity file names | 2026-05-02 | none |
| [BUG-2026-05-02-004](shipglows_data/workflow/bugs/BUG-2026-05-02-004.md) | closed | high | Operator IP appeared in ShipGlows SSH examples and recent GitHub history | 2026-05-04 | none |
