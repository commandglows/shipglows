---
artifact: research
project: "shipglows portfolio"
created: "2026-06-12"
updated: "2026-06-12"
status: reviewed
source_skill: 203-sg-research
scope: "Bunny Database libSQL usefulness for ShipGlows projects"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
source_count: 7
evidence:
  - "https://docs.bunny.net/database"
  - "https://docs.bunny.net/database/limits"
  - "https://docs.bunny.net/database/replication"
  - "https://docs.bunny.net/database/durability-and-consistency"
  - "https://docs.bunny.net/database/connect/authorization"
  - "https://docs.bunny.net/database/connect/sql-api"
  - "https://github.com/tursodatabase/libsql"
next_step: "Run a bounded pilot for low-risk SQLite-shaped data before considering production adoption."
---

# Research: Bunny Database libSQL usefulness for ShipGlows projects

> Generated 2026-06-12 - Sources: 7

## Executive Summary

Bunny Database is a plausible fit for small, globally read-heavy relational datasets where SQLite semantics are enough and operational simplicity matters more than mature enterprise database features. It should not be treated yet as a default production replacement for Postgres, Supabase, Firebase, or Turso-backed critical state because Bunny marks the service as Public Preview, limits preview databases to 1 GB, and says APIs/features may evolve.

Recommendation: keep it on the shortlist for pilots and non-critical tools, especially edge-adjacent apps, content metadata, small registries, public-read dashboards, or low-write internal utilities. Do not use it yet for auth/session state, billing, entitlements, audit logs, irreversible user data, or anything that needs mature backup/import/export guarantees.

## Background

ShipGlows projects often favor pragmatic managed services, small operational surface area, and clear contracts over broad platform complexity. Bunny Database is attractive because it offers a familiar SQLite/libSQL model, HTTP and SDK access, global read replicas, and usage-based idle economics. That maps well to prototypes and small production surfaces that do not justify a full Postgres setup.

The risk is lifecycle maturity. Bunny launched the product as a public preview on 2026-02-03 and its own docs still state that features and APIs may evolve. Public preview is acceptable for experiments and low-blast-radius data; it is not a strong fit for core product state without a rollback/export plan.

## Current State

Bunny Database is documented as a globally distributed SQLite-compatible database built on libSQL. It supports HTTP SQL access via the libSQL remote protocol, client access through libSQL SDKs for TypeScript/JavaScript, Go, Rust, and Bunny's .NET client, plus integration with Bunny Edge Scripting and Magic Containers.

The pricing page advertises reads at $0.30 per billion rows, writes at $0.30 per million rows, and storage at $0.10 per GB per active region monthly. Bunny also says idle databases only incur storage costs, with one primary region charged continuously and read replicas adding storage costs only while serving traffic.

Preview limits matter: current docs list 50 databases per account and 1 GB max size per database. Bunny's launch article says automatic backups, database file import/export, and an auto-generated schema-aware API were roadmap items, not current stable guarantees in the cited source.

## Technical Fit

### Good Fits

- Small relational datasets where SQLite is already enough.
- Read-heavy global data, especially public or semi-public data that benefits from nearby replicas.
- Internal tools, dashboards, project registries, feature flag-ish metadata, light CMS/catalog metadata, and prototype apps.
- Edge-hosted experiments using Bunny Edge Scripting or Magic Containers where using the same provider reduces deployment friction.
- Projects where usage is bursty and idle cost matters.

### Poor Fits

- High-write workloads. libSQL inherits SQLite's single-writer limitation according to the upstream libSQL repository.
- Large datasets. Bunny's preview limit is 1 GB per database.
- Critical systems needing mature backup, point-in-time restore, import/export, or compliance posture.
- Workloads requiring strong multi-writer semantics, complex tenant isolation, row-level security comparable to Postgres ecosystems, or deep SQL extensions.
- Auth, payments, entitlements, audit logs, or authoritative business records.

## Security And Operations Notes

Bunny uses database URLs plus access tokens. Docs show full-access and read-only token types, and token regeneration invalidates existing tokens. This is simple, but it is not a full role/permission model; applications still need careful server-side access boundaries and secret handling.

The HTTP API supports parameter binding, which is important for SQL injection prevention. Any pilot should require parameterized queries and should keep full-access tokens only in server/runtime secrets, never in browser/client code.

Replication uses a primary-replica architecture. Replication regions act as read replicas and proxy writes to the primary. Bunny docs say the active primary can change when an idle database is reactivated, so latency and write path behavior should be measured in the actual hosting topology before relying on it.

## Options

### Option 1: Pilot Bunny Database

- Pros: very simple start, SQLite-shaped mental model, low idle cost, global read replicas, HTTP access, useful Bunny platform integration.
- Cons: public preview, small current database limit, roadmap gaps around backups/import/export, single-writer inherited limitation, provider-specific managed fork behavior.
- Best for: low-risk prototypes and small global-read utilities.

### Option 2: Keep Current Managed Stores

- Pros: less migration risk, known operational behavior, better fit for mature auth/data workflows when using established providers.
- Cons: may be heavier or more expensive for tiny idle projects; global latency may require extra caching or architecture.
- Best for: production-critical app data and systems already stable on Supabase/Firebase/Postgres/Turso.

### Option 3: Self-Hosted SQLite/libSQL

- Pros: maximum control, easier local-first workflows, no preview-provider dependency.
- Cons: operational work returns to us; global replication and failover become our problem.
- Best for: developer tools or local-first data where cloud global distribution is not required.

## Recommendation For Our Projects

Adopt a "pilot only" stance:

1. Use Bunny Database for one bounded, low-risk experiment where data is reconstructable.
2. Require an export/backup story before storing durable product data.
3. Avoid core identity, billing, entitlement, or audit data.
4. Prefer read-heavy global surfaces over write-heavy collaboration.
5. Add a provider note only after a real pilot confirms SDK behavior, migrations, token rotation, cold-start/idle behavior, and latency.

Good first pilot candidates:

- A small public-read metadata registry.
- A lightweight internal dashboard store.
- A feature/demo app with non-critical user-generated data.
- A regional read-latency comparison against the current provider for a tiny API.

## Concrete Use Cases For Our Portfolio

### 1. ShipGlows public/project registry mirror

Use Bunny Database as a read-optimized mirror of project metadata: project name, stack, public URL, status, last verification date, latest changelog pointer, and health badges.

- Why it fits: small relational dataset, mostly reads, globally useful, reconstructable from Markdown/project artifacts.
- Why it matters: a future ShipGlows dashboard or public status page could query structured metadata without parsing Markdown on every request.
- Risk: low if Bunny is only a cache/mirror and Markdown remains source of truth.
- Verdict: best first pilot.

### 2. Cross-project research and veille index

Store normalized research items from `shipglows_data/workflow/research/` and veille notes: tool name, project relevance, score, category, source URL, decision, revisit date.

- Why it fits: small records, high read value, low write pressure, easy to regenerate from Markdown.
- Why it matters: search/filtering across GoCharbon, TubeFlow, ContentGlowz, ShipGlows, WinFlowz, etc. becomes much easier.
- Risk: low if report Markdown stays canonical.
- Verdict: strong pilot candidate.

### 3. Content opportunity tracker for GoCharbon / content-heavy sites

Store article opportunities, keywords, status, publication URL, internal-link targets, affiliate/source metadata, and evidence links.

- Why it fits: relational content planning works well in SQLite; reads dominate; data is useful from multiple locations.
- Why it matters: GoCharbon-style editorial operations need a clean table view more than a heavyweight app database.
- Risk: medium if it becomes the only canonical editorial tracker.
- Verdict: useful if treated as operational tracker, not legal/business source of truth.

### 4. TubeFlow / ReplayGlowz demo metadata

Store non-critical demo metadata: sample videos, generated summaries, transcript status, playlist examples, benchmark runs, public demo fixtures.

- Why it fits: simple relational model and read-heavy demo surfaces.
- Why it matters: lets a public demo or benchmark page stay fast without touching core production user data.
- Risk: medium because transcript data can contain sensitive content; only use public/sample data.
- Verdict: good for demos, not for private user transcripts.

### 5. Lightweight experiment analytics

Store coarse events for internal/product experiments: CTA clicks, onboarding step completion, feature usage counters, source campaign, anonymous session id.

- Why it fits: simple writes, cheap idle economics, easy dashboarding.
- Why it matters: useful for small launches before setting up a bigger analytics stack.
- Risk: medium because analytics can become privacy-sensitive and write volume can grow.
- Verdict: acceptable for minimal anonymous metrics, not for detailed behavioral tracking.

### 6. Skill/run outcome index for ShipGlows

Store normalized results of skill runs: project, skill, date, status, changed files count, check result, report path, follow-up command.

- Why it fits: structured index over Markdown artifacts; small rows; useful for dashboards and audits.
- Why it matters: helps answer "what changed, what failed, what needs follow-up" across many projects.
- Risk: low if it mirrors reports and specs, not replaces them.
- Verdict: high product fit for ShipGlows itself.

### 7. Public-read affiliate/tool directory

Store a curated directory of tools, competitors, affiliate programs, and project fit scores.

- Why it fits: global-read relational catalog, low write frequency, simple schema.
- Why it matters: can power public pages, internal comparison tables, and content planning from one source.
- Risk: medium if claims/prices are not freshness-checked before publishing.
- Verdict: useful, but must route public claims through editorial/claim-review workflow.

### 8. Feature flag and remote config for non-critical features

Store simple config flags for labs or demos: feature enabled, rollout percentage, copy variant, experiment label.

- Why it fits: tiny dataset, globally readable, simple key/value plus relational metadata.
- Why it matters: lets small apps avoid shipping just to toggle lab behavior.
- Risk: medium-high if used for entitlements, security, or paid gates.
- Verdict: only for non-critical UX/config flags; never for paid access.

## Use Cases To Avoid

- Suite identity/auth/session state.
- Paid entitlements or billing source of truth.
- Private transcripts, raw user content, or irreversible uploads.
- High-write collaboration, chat, or event streams.
- Anything requiring strong backup, import/export, restore, or compliance guarantees today.

## Freshness Verdict

fresh-docs checked: Bunny official docs and current launch material were consulted on 2026-06-12. The recommendation is intentionally conservative because the service is still documented as Public Preview and has preview-stage limits.

## Chantier potentiel

Chantier potentiel: incertain
Titre propose: "Pilot Bunny Database for low-risk project metadata"
Raison: The research suggests a potentially useful architecture/provider decision, but no concrete target project or dataset has been selected.
Severite: P3
Scope: Portfolio provider evaluation; possible future prototype or internal tool.
Evidence:
- Bunny Database is in Public Preview.
- Preview limits include 1 GB per database.
- Pricing and global read replication could be useful for small idle/global-read workloads.
- Missing selected project, data model, backup requirement, and migration target.
Spec recommandee: /100-sg-spec Pilot Bunny Database for low-risk project metadata
Prochaine etape: Select one non-critical dataset and define acceptance criteria before implementation.

## Sources

- [Bunny Database documentation](https://docs.bunny.net/database) - product overview, public preview status, core features, integration paths.
- [Bunny Database limits](https://docs.bunny.net/database/limits) - public preview quotas, including 50 databases per account and 1 GB database size.
- [Bunny Database replication](https://docs.bunny.net/database/replication) - storage/compute separation, read replicas, primary-region behavior.
- [Bunny Database durability and consistency](https://docs.bunny.net/database/durability-and-consistency) - primary-replica architecture and write/read model.
- [Bunny Database Auth & Access](https://docs.bunny.net/database/connect/authorization) - database URL, token types, token generation and regeneration behavior.
- [Bunny Database SQL API](https://docs.bunny.net/database/connect/sql-api) - HTTP access, beta API note, parameter binding, interactive sessions.
- [libSQL GitHub repository](https://github.com/tursodatabase/libsql) - upstream libSQL positioning and single-writer limitation.
