# Audit Log

> Audit freshness uses `skills/references/audit-cadence-matrix.json`. New traffic-first audit records should include `domain: <matrix-id>` and keep `date`, `overall`, `issues`, and `scope`; historical table and alias-based records remain readable by the cadence checker.

| Date | Scope | Design | Copy | SEO | GTM | Translate | Deps | Perf | Code | Issues |
|------|-------|--------|------|-----|-----|-----------|------|------|------|--------|
| 2026-04-28 | project | — | — | — | — | — | — | — | C | 0 critical / 2 high fixed / 2 high open / 2 medium open |
| 2026-04-29 | file: local/dev-tunnel.sh | — | — | — | — | — | — | — | B | 0 critical / 3 high fixed / 3 medium fixed / 1 high open |
| 2026-04-29 | project | — | — | — | — | — | — | B | — | 0 critical / 2 high fixed / 2 medium fixed / 1 high open / 1 medium open |

🟢 [ShipGlows] audit: Translate public site French locale | date: 2026-06-11 | overall: accepted | issues: main routes translated; skill Markdown intentionally remains English for agent contract reliability | scope: site
🟠 [ShipGlows] audit: Site design tokens | date: 2026-06-12 | overall: D | issues: 3 high / 4 medium | scope: site
🟠 [ShipGlows] audit: Dependency health for site | date: 2026-06-20 | overall: C | issues: 2 high / 1 moderate / 1 low / 1 major upgrade | scope: site
🟡 [ShipGlows] audit: Dependency health for tui | date: 2026-06-20 | overall: C | issues: 1 missing lockfile / 1 unpinned toolchain / 1 proof gap | scope: tui
🟠 [ShipGlows] audit: DevServer startup latency | date: 2026-07-17 | overall: D | issues: 2 high / 2 medium | scope: CLI startup and environment shortcuts | id: perf-devserver-startup-2026-07-17
