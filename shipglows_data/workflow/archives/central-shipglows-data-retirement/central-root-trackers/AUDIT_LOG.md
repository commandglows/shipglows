# Audit Log

> Quick view of all audit runs across all projects. See project-local `AUDIT_LOG.md` for details.

| Date       | Project   | Scope        | Code | Design | Copy | SEO | GTM | Translate | Deps | Perf | Overall | Issues     |
|------------|-----------|--------------|------|--------|------|-----|-----|-----------|------|------|---------|------------|
| 2026-03-21 | quit-coke | full project | B-   | B      | B+   | B   | C-  | —         | C    | C+   | C+      | 10/23/72   |
| 2026-03-26 | quit-coke | SEO tech     | —    | —      | —    | C+  | —   | —         | —    | —    | C+      | 1/4/4      |
| 2026-03-26 | quit-coke | Accessibility | —   | C-     | —    | —   | —   | —         | —    | —    | C-      | 2/3/4      |
| 2026-04-06 | ContentFlowz | SEO          | —    | —      | —    | C→B | —   | —         | —    | —    | C→B     | 4/6/5 (10 fixed) |
| 2026-04-06 | ContentFlowz | Copywriting  | —    | —      | D+   | —   | —   | —         | —    | —    | D+      | 4/4/3      |
| 2026-04-06 | SocialFlowz  | Code         | C    | —      | —    | —   | —   | —         | —    | —    | C       | 2/5/8      |
| 2026-04-07 | ContentFlowz | Code         | C    | —      | —    | —   | —   | —         | —    | —    | C       | 4/6/8      |
| 2026-04-07 | GoCharbon    | SEO          | —    | —      | —    | B→A-| —   | —         | —    | B+   | B+      | 4/4/3 → 2/1/1 (27 fixed, 13 dupes drafted) |
| 2026-04-07 | WinFlowz     | Code         | C+   | —      | —    | —   | —   | —         | —    | —    | C+      | 4/8/14 (12 fixed) |
| 2026-04-07 | ContentFlowz | Design       | —    | C→B    | —    | —   | —   | —         | —    | —    | C→B     | 0/5/5 (10 fixed) |
| 2026-04-07 | TubeFlow App | Code         | C    | —      | —    | —   | —   | —         | —    | —    | C       | 2/3/4 (6 fixed) |
| 2026-04-14 | gocharbon_quiz | full project | —    | C→B-   | —    | —   | —   | —         | —    | —    | C→B-    | 0/2/4 (12 fixed) |
| 2026-04-18 | quit-coke | Design mobile | —    | C→B-   | —    | —   | —   | —         | —    | —    | C→B-    | 0/2/3 (8 fixed) |
| 2026-04-18 | quit-coke | SEO launch | —    | —      | —    | C+→A- | — | —         | —    | —    | B+      | 0/2/2 (21 fixed) |
| 2026-04-19 | quit-coke | SEO metadata | —    | —      | —    | A-  | —   | —         | —    | —    | A-      | 0/3/1 (11 fixed) |
| 2026-04-19 | quit-coke | Homepage conversion | — | —    | B+→A- | — | —   | —         | —    | —    | A-      | Home reroutée vers contenu site + application, hiérarchie CTA clarifiée |
| 2026-04-19 | quit-coke | Pricing + app funnel | — | —    | A-   | — | —   | —         | —    | —    | A-      | Home renforcée par preuve concrète, `/application` et `/pricing` réalignées sur le split site gratuit → application → Premium |
| 2026-04-19 | gocharbon_quiz | Copywriting funnel | — | — | B- | — | — | — | — | — | B- | 3/4/2 |
| 2026-04-26 | gocharbon_quiz | full project | B-→B | — | — | — | — | — | — | — | B | 0/3/3 (4 fixed) |
| 2026-04-21 | ContentFlow App | Feed mobile page | — | C→B | — | — | — | — | — | — | B | 0/1/2 (mobile layout tightened, responsive CTAs/status cards, narrow app bar action) |
| 2026-04-26 | VoiceFlowz | dependencies | — | — | — | — | — | — | B | — | B | 1 critical + 4 high fixed; 10 moderate remain blocked by Expo major/migration path |
| 2026-05-09 | VoiceFlowz | full project | — | C→B- | — | — | — | — | — | — | B- | ContentFlow family tokens adopted in Flutter theme; 0 critical / 2 high / 3 medium remain |
| 2026-05-10 | VoiceFlowz | full project | — | B-→B | — | — | — | — | — | — | B | 0 critical / 1 high / 4 medium remain; brand tokens, theme bootstrap, delete confirmations, onboarding semantics, and themeMode rules fixed |
| 2026-05-15 | WinFlowz | full project | — | B- | — | — | — | — | — | — | B- | 0 critical / 3 high / 4 medium found; clean `flutter analyze`; remaining gaps are sync-state honesty, mixed FR/EN UX copy, control sizing, typography token discipline, reduced-motion support, and design-system proof tooling |
| 2026-04-26 | tubeflow-app | Code | C+ | — | — | — | — | — | — | — | C+ | 0/3/5 (6 fixed) |
| 2026-04-27 | ContentFlow Lab | full project | B | — | — | — | — | — | — | — | — | 0/1/3 |
| 2026-04-27 | ContentFlow App | full project | B- | — | — | — | — | — | — | — | — | 0/1/2 |
| 2026-04-27 | ContentFlow Site | full project | B- | — | — | — | — | — | — | — | — | 0/1/2 |
| 2026-04-27 | ContentFlow Lab | dependencies | — | — | — | — | — | — | D | — | D | 1/2/2 (unpinned Python ranges + 58 ignored Safety findings) |
| 2026-04-27 | ContentFlow App | dependencies | — | — | — | — | — | — | C | — | C | 0/2/3 (major Flutter upgrades + discontinued transitive tooling) |
| 2026-04-27 | ContentFlow Site | dependencies | — | — | — | — | — | — | C- | — | C- | 0/2/2 (10 npm advisories, fix available) |
| 2026-04-27 | ContentFlow Lab | dependencies (fix pass) | — | — | — | — | — | — | B- | — | B- | 0/1/2 (ignored findings 58 -> 1; `pydantic-ai` major migration pending) |
| 2026-04-27 | ContentFlow App | dependencies (fix pass) | — | — | — | — | — | — | C | — | C | 0/1/2 (toolchain pin + automation added; major deps still pending) |
| 2026-04-27 | ContentFlow Site | dependencies (fix pass) | — | — | — | — | — | — | B- | — | B- | 0/1/1 (npm advisories 10 -> 1 moderate) |
| 2026-04-27 | quit-coke-app | dependencies | — | — | — | — | — | — | C+ | — | C+ | 0/0/4 (discontinued unused Flutter dep, unused deps, no update automation) |
| 2026-04-27 | quit-coke-app | dependencies (fix pass) | — | — | — | — | — | — | B | — | B | 0/0/1 (unused deps removed, automation added, Sentry major migration remains) |
| 2026-04-27 | SocialFlowz | dependencies | — | — | — | — | — | — | D | — | D | 0 critical, 40 high, 34 moderate, 7 low; direct `vue-i18n` runtime vuln + build-chain advisories |
| 2026-04-27 | SocialFlowz | dependencies (fix pass) | — | — | — | — | — | — | B- | — | B- | 81 advisories reduced to 8; remaining 2 high + 6 moderate require major/migration decisions |
| 2026-04-27 | gocharbon_quiz | dependencies | — | — | — | — | — | — | C- | — | C- | 0/3/4 (backend direct vulns; Flutter lockfile OK, no pub advisories; no update automation) |
| 2026-04-27 | GoCharbon | dependencies | — | — | — | — | — | — | D | — | D | 1 critical, 19 high, 15 moderate, 5 low; no fixes applied |
| 2026-04-27 | GoCharbon | dependencies (fix pass) | — | — | — | — | — | — | B- | — | B- | critic/high 20 -> 0, package manager normalized, dependabot added; 8 moderate + 3 low remain (Astro 5 line / migration lane) |
| 2026-04-27 | quit-coke | dependencies | — | — | — | — | — | — | D | — | D | 2 critical, 7 high, 12 moderate; Clerk gate bypass directly affects premium access |
| 2026-04-27 | quit-coke | SEO infrastructure + AEO | — | — | — | B+ | — | — | — | — | B+ | 0/2/4 (5 fixed: llms, AI crawler rules, author/person schema, speakable, sitemap lastmod) |
| 2026-04-27 | nantes-gratuit | full project | B- | — | — | — | — | — | — | — | B- | 0/1/3 (3 fixed; Supabase/Deno unverified) |
| 2026-04-28 | SocialFlowz | full project | C+ | — | — | — | — | — | — | — | C+ | 0/2/3 (2 fixed) |
| 2026-04-28 | ContentFlow Lab | monorepo code audit | B- | — | — | — | — | — | — | — | B- | 1/2/3 (1 fixed; publish tenant ownership decision remains) |
| 2026-04-28 | ContentFlow App | monorepo code audit | B | — | — | — | — | — | — | — | B | 1/1/2 (2 fixed; auth diagnostics XSS fixed) |
| 2026-05-10 | ContentFlow App | app entry homepage copywriting | — | — | C+ | — | — | — | — | — | C+ | 0/3/3 (entry page clear for recovery; site handoff and automation/publish claims need alignment) |
| 2026-04-28 | ContentFlow Site | monorepo code audit | B | — | — | — | — | — | — | — | B | 0/1/1 |
| 2026-04-28 | ShipGlows | project | C | — | — | — | — | — | — | — | C | 0 critical / 2 high fixed / 2 high open / 2 medium open |
| 2026-04-28 | TubeFlow App | Deps | — | — | — | — | — | — | C | — | C | 0 critical / 0 high / 5 medium; Astro XSS patch available; Python and Flutter scans partially blocked |
| 2026-04-29 | ShipGlows | file: local/dev-tunnel.sh | B | — | — | — | — | — | — | — | B | 0 critical / 3 high fixed / 3 medium fixed / 1 high open |
| 2026-04-29 | ShipGlows | project | — | — | — | — | — | — | — | B | B | 0 critical / 2 high fixed / 2 medium fixed / 1 high open / 1 medium open |
| 2026-04-30 | socialflow | Deps | — | — | — | — | — | — | B- | — | B- | 0 critical / 0 high / 1 moderate dev-build advisory; 6 medium follow-ups |
| 2026-05-02 | ContentFlow Lab | Deps resolver conflict | — | — | — | — | — | — | B- | — | B- | 0 critical / 1 high / 3 medium; default resolver fixed, `pydantic-ai` CVE + lockfile/optional integrations pending |
| 2026-05-03 | ContentFlow Lab | Deps risk closure | — | — | — | — | — | — | A- | — | A- | 0 critical / 0 high / 1 medium; pip-audit clean, lockfiles + PydanticAI adapter + URL safety added, license inventory pending |
| 2026-05-03 | ContentFlow Lab | Deps license inventory | — | — | — | — | — | — | A | — | A | 0 critical / 0 high / 0 medium; 283 production packages inventoried, 0 AGPL/SSPL/GPL-only blockers, `libsql` source license verified as MIT |
| 2026-05-03 | WinFlowz | Deps | — | — | — | — | — | — | D | — | D | 0 critical / 1 high / 10 moderate / 2 low; public Astro SSR advisories, untracked pnpm lockfile, no runtime/package-manager pin |
| 2026-05-03 | WinFlowz | Deps migration | — | — | — | — | — | — | B | — | B | Astro 5→6 complete; pnpm audit 0 vulnerabilities; lockfile still needs commit |
| 2026-05-03 | ext---toolflowz | Deps | — | — | — | — | — | — | D | — | D | 2 critical / 45 high / 46 moderate / 12 low vulnerability instances; unused `vuefire` pulls critical Firebase/protobufjs path; no runtime/package-manager pin or update automation |
| 2026-05-04 | ext---toolflowz | Code | C | — | — | — | — | — | — | C | C | 0 critical / 3 high / 4 medium; remote CSS, unsafe project HTML writes, Firefox data declaration, and lint blockers fixed; permissions, packaged CDN fallback, icons, bundle size, and tests remain |
| 2026-05-04 | ext---toolflowz | Code hardening | B | — | — | — | — | — | — | C | B- | 0 critical / 0 high / 3 medium; redundant host/API permissions removed, FormKit/marked removed, manifest icons fixed, no CDN strings in built packages; bundle size, vendor lint warnings, and broader tests remain |
| 2026-05-10 | TubeFlow Flutter | Deps | — | — | — | — | — | — | C | — | C | 0 critical / 0 high / 3 moderate security findings; Astro/PostCSS and requests patch lanes plus automation/toolchain gaps |
| 2026-05-11 | tubeflow-app | Deps | — | — | — | — | — | — | B- | — | B- | 0 OSV/Pub advisories; 0 critical / 0 high / 3 medium follow-ups: Clerk beta auth patch, unused codegen deps, Sentry/lints major lanes |
| 2026-05-11 | tubeflow-app | Deps fix | — | — | — | — | — | — | A- | — | A- | Beta Clerk SDKs removed and sign-in disabled; direct deps current; Flutter analyze/build web passed |
| 2026-05-14 | notefinderz | dependencies | — | — | — | — | — | — | D | — | D | 2 critical / 15 high / 10 moderate / 2 low; Clerk auth bypass and Astro/Vercel SSR advisories; no fixes applied |
| 2026-05-14 | notefinderz | dependencies fix pass | — | — | — | — | — | — | C | — | C | 0 critical / 3 high / 6 moderate / 3 low; compatible patches applied, remaining findings require Astro/Vercel major migration |
| 2026-05-14 | notefinderz | Astro/Vercel major migration | — | — | — | — | — | — | B | — | B | 0 critical / 0 high / 5 moderate; Astro 6 and Vercel adapter 10 migrated, residual findings isolated to dev-only `@astrojs/check` YAML language-server chain |
| 2026-05-14 | replayglowz | monorepo performance | — | — | — | — | — | — | — | A- | A- | 0 critical / 0 high open / 2 medium follow-ups; fixed unused 6.0 MB site payload, global Lenis JS, app playlist-sync waterfall, and eager notes subscription |
| 2026-05-18 | replayglowz | Perf | — | — | — | — | — | — | — | B | B | 0 critical / 0 high / 2 medium, 2 fixed |
| 2026-05-24 | gocharbon | Deps | — | — | — | — | — | C- | — | — | C- | 0 critical / 2 high / 8 moderate; 2 high direct, 6 moderate transitive; major/vulnerable lines deferred via /sg-migrate |
| 2026-05-25 | gocharbon | Deps | — | — | — | — | — | — | B- | — | B- | 0 critical / 0 high / 0 moderate / 0 low; non-major update lane resolved advisories (`astro@6.3.7`, `unstorage>h3` override); majors pending (`eslint` 10.x, `satori` 0.26.x) |
| 2026-05-25 | gocharbon | Deps | — | — | — | — | — | B | — | B | 0 critical / 0 high / 0 moderate / 0 low; major lane updates applied (`eslint@10.4.0`, `satori@0.26.0`, `vue@3.5.34`), residual peer mismatch: `eslint-plugin-jsx-a11y@6.10.2` requires eslint ^3–9
