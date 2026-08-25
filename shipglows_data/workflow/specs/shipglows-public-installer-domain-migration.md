---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.2"
project: "ShipGlows"
created: "2026-08-09"
created_at: "2026-08-09 15:50:00 UTC"
updated: "2026-08-25"
updated_at: "2026-08-25 19:54:54 UTC"
status: reviewed
source_skill: sg-development
source_model: "GPT-5 Codex"
scope: "public-installer-domain-migration"
owner: "Diane"
confidence: high
risk_level: high
security_impact: "yes"
docs_impact: "yes"
user_story: "En tant qu'utilisatrice ShipGlows, je veux trouver les pages et scripts d'installation sur shipglows.com afin que le produit possede sa propre distribution canonique sans casser les anciennes commandes CommandGlows."
linked_systems:
  - "/home/claude/shipglows"
  - "/home/claude/shipglows_app/site"
  - "/home/claude/commandglows/commandglows_site"
  - "Vercel"
depends_on:
  - artifact: "shipglows_data/workflow/specs/native-windows-devserver-astro-python-flutter.md"
    artifact_version: "0.2.20"
    required_status: draft
supersedes: []
evidence:
  - "The 2026-08-25 parity repair resynchronized the public PowerShell bootstrap after its extraction manifest drifted behind the canonical Windows runtime payload; site main `942de2f` deployed successfully and the public shell and PowerShell response bytes match the canonical Git blobs."
  - "shipglows.com already serves the canonical ShipGlows site and redirects www to the apex domain."
  - "At the initial 2026-08-09 audit, the ShipGlows site returned 404 for /shipglows-script and /dotfiles-script while CommandGlows served the live pages and scripts."
  - "At migration time, the ShipGlows site used Astro 6 static output without a Vercel adapter; query-driven PowerShell negotiation required one on-demand route."
  - "The canonical installers are /home/claude/shipglows/install-shipglows.sh and install-shipglows.ps1."
  - "Official Astro Vercel adapter documentation confirms static output can retain prerendered pages while prerender=false routes render on demand."
next_step: "Monitor installer traffic and retire compatibility redirects only through a future explicit deprecation decision."
---

# ShipGlows Public Installer Domain Migration

## Outcome

Make `shipglows.com` the canonical owner of the ShipGlows runtime installer and the related dotfiles environment while preserving the separate Codex plugin install journey and maintaining permanent compatibility from old CommandGlows URLs.

## Route Contract

| Canonical ShipGlows route | Purpose |
|---|---|
| `/install`, `/fr/install` | Codex plugin installation; unchanged primary intent |
| `/shipglows`, `/fr/shipglows` | ShipGlows runtime, local/server bootstrap and native Windows DevServer pages |
| `/dotfiles`, `/fr/dotfiles` | Dotfiles environment pages |
| `/shipglows-script` | Shell installer by default; PowerShell for `format=powershell`, `ps1`, or `windows` |
| `/dotfiles-script` | Shell dotfiles bootstrap |

The canonical origin is the apex `https://shipglows.com`. CommandGlows legacy routes redirect permanently and preserve the complete query string. Retired predecessor aliases redirect directly to ShipGlows to avoid chains.

## Success Behavior

- All canonical pages and endpoints are owned by `shipglows_app/site`.
- Ordinary pages remain prerendered; only the negotiated ShipGlows script endpoint renders on demand through the official Vercel adapter.
- Public installer commands use `https://shipglows.com/shipglows-script` or `https://shipglows.com/dotfiles-script`.
- Served ShipGlows shell and PowerShell artifacts are byte-identical to the canonical root installers.
- CommandGlows old page and script routes return permanent redirects directly to the matching ShipGlows destination with query preservation.
- `/install` remains the Codex plugin route and links locally to `/shipglows` as a separate runtime path.
- Active documentation and governance identify ShipGlows as distribution authority; dated historical evidence remains truthful.

## Failure Behavior

- CommandGlows redirects must not be deployed before all ShipGlows destinations return the expected production responses.
- Unknown paths and children are not redirected by broad prefixes.
- Redirect destinations come from a fixed allowlisted route map, never request input.
- Unsupported script formats safely receive the shell installer, preserving the existing endpoint contract.
- A generated installer mismatch fails validation and blocks release.
- Existing unrelated worktree changes are preserved and excluded from scoped commits.

## Scope

### In

- ShipGlows Astro Vercel adapter, install-page model/component, four localized pages, two script endpoints, generated artifacts and focused tests.
- Canonical ShipGlows bootstrap self-reference, sync tool, public docs, technical docs, editorial maps and active Windows spec.
- Exact permanent CommandGlows redirects for ShipGlows, dotfiles and retired compatibility routes, plus redirect tests and removal of obsolete implementation ownership.
- Deployment-order and live HTTP/hash verification preparation.

### Out

- Termux page migration; it remains a CommandGlows surface for now.
- Rewriting dated histories, archived bugs, old verification records or changelog evidence.
- Changing installer behavior beyond domain ownership.
- Modifying unrelated dirty files in `shipglows_app` or CommandGlows.

## Invariants

- `install-shipglows.sh` and `install-shipglows.ps1` remain canonical installer sources.
- The PowerShell endpoint continues to support local/full selection and the documented safe file-download invocation.
- No direct pipe into PowerShell expression evaluation is introduced.
- Redirects are exact, permanent and query-preserving.
- No secret, credential, private URL or internal log is published.
- EN/FR route intent and canonical/hreflang metadata remain paired.

## Execution Batches

### Batch A — ShipGlows site ownership

- Write scope: `/home/claude/shipglows_app/site/package.json`, lockfile, Astro config, new install data/component/pages/endpoints/generated files/tests, and the already-scoped `/install` EN/FR links.
- Action: add the Vercel adapter in hybrid static/on-demand mode; implement pages and endpoints using ShipGlows styling and current CommandGlows copy.
- Proof: tests, Astro check/build, local preview HTTP responses and canonical metadata scan.

### Batch B — Canonical installer and documentation authority

- Write scope: `/home/claude/shipglows/install-shipglows.sh`, sync tool, active public/technical/editorial docs, and active Windows spec.
- Action: replace active CommandGlows URLs with ShipGlows, retarget generated artifact synchronization, and preserve historical evidence.
- Proof: shell syntax, sync parity, metadata lint, static Windows contract, URL allowlist scan and diff check.

### Batch C — CommandGlows compatibility boundary

- Write scope: CommandGlows exact redirect routes/helper/tests, sitemap/public-path configuration, obsolete installer page/data/generated ownership and affected active docs.
- Action: retain Termux content while replacing ShipGlows/dotfiles implementations with direct permanent external redirects.
- Proof: targeted response tests for statuses and `Location`, query preservation, no redirect chains, Astro check/build and stale-ownership scan.

The batches have exclusive write scopes and may run in parallel locally. Production activation remains ordered: deploy and verify A+B first, then deploy C.

## Acceptance Criteria

- [x] AC01: ShipGlows EN/FR runtime and dotfiles pages build with correct canonical and alternate URLs.
- [x] AC02: `/shipglows-script` serves shell by default and PowerShell for all three supported format aliases with `text/plain` and bounded cache headers.
- [x] AC03: `/dotfiles-script` serves the expected safe shell bootstrap.
- [x] AC04: generated ShipGlows installer artifacts match canonical root installers byte-for-byte.
- [x] AC05: `/install` and `/fr/install` remain plugin-first and link to the local runtime pages.
- [x] AC06: all active commands and docs use the apex ShipGlows endpoint; historical occurrences are not rewritten.
- [x] AC07: every old CommandGlows page/script route and retired alias redirects permanently to the direct ShipGlows destination while preserving query strings.
- [x] AC08: exact-route tests reject accidental child-route or open-redirect behavior.
- [x] AC09: both Astro sites pass focused tests, check/build, metadata and diff validation.
- [x] AC10: production ShipGlows destinations are proven before CommandGlows redirects are activated.

## Proof Order

1. Metadata, scope and dirty-worktree inventory.
2. Installer shell syntax and byte parity.
3. Focused unit/contract tests in both sites.
4. Astro check and production build in both sites.
5. Local HTTP smoke for pages, shell, PowerShell, dotfiles and redirects.
6. ShipGlows production deployment and live 200/content/hash proof.
7. CommandGlows redirect deployment and live permanent redirect/query proof.

## Risks And Mitigations

- Cached permanent redirect to a missing target: deploy and prove ShipGlows first.
- Supply-chain drift: copy only from canonical root installers and enforce byte parity.
- Static/dynamic mismatch: use the official Vercel adapter and only one `prerender=false` route.
- Worktree contamination: preserve existing changes, use disjoint files and exact scoped staging only.
- SEO duplication: canonical pages move to ShipGlows; CommandGlows retains redirects only and excludes them from sitemap generation.

## Fresh Docs Gate

`fresh-docs checked`: official Astro Vercel adapter guidance was checked on 2026-08-09 for on-demand routes in an otherwise static site; official Vercel redirect guidance was checked for permanent redirect semantics. Product claims remain grounded in local code and Shadow evidence.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|---|---|---|---|---|---|
| 2026-08-09 15:50:00 UTC | sg-development + sg-content | GPT-5 Codex + 3 read-only agents | Audited both sites, active URLs, hosting mode, installer ownership, compatibility routes and dirty-worktree risks; created the ready migration contract with exclusive batches and ordered production activation. | ready | Implement batches A, B and C locally, then run the proof order. |
| 2026-08-09 16:00:00 UTC | 001-sg-build | GPT-5 Codex | Implemented Batch B in the canonical ShipGlows repository: moved active installer authority to the apex ShipGlows domain, retargeted generated bootstrap synchronization, and aligned active public, technical, editorial and Windows-spec documentation while preserving dated history. | implemented; shell syntax, generated shell/PowerShell parity, Windows static contract, governance topology, metadata, active-URL scan and diff check pass | Integrate the validated Batch B with Batch A, then prove ShipGlows production before activating Batch C redirects. |
| 2026-08-09 16:11:00 UTC | sg-development + sg-content | GPT-5 Codex + 6 agents | Integrated and shipped all three batches in ordered production deployments; verified canonical pages/endpoints, byte parity, direct permanent redirects, legacy aliases and complete query preservation. | complete; ShipGlows `c301f43` + site `9c22d61`, CommandGlows `cbaca5c`, Vercel production deployment `dpl_E2yRb8mCmBUiTu4eG6G8nvp6v5WQ` | Monitor compatibility traffic; no migration work remains. |
| 2026-08-25 UTC | sg-bug + sg-content + sg-docs | Codex + 1 delegated agent | Reproduced the public PowerShell drift, refreshed the generated installers from the canonical core tool, added the 21-file regression and a read-only scheduled parity gate, then aligned mapped internal documentation. | complete; focused test 3/3, local parity, site build, PR 16 byte-parity CI, main deployment `942de2f`, public script bytes and four EN/FR routes pass | Monitor the scheduled parity gate; no repair work remains. |

## Current Chantier Flow

| Stage | Status | Evidence | Next step |
|---|---|---|---|
| 100-sg-spec | complete | Cross-repo route, behavior, security, documentation and deployment-order contract recorded. | 101-sg-ready |
| 101-sg-ready | complete | No open product decision; batches are exclusive, failure behavior is explicit and proof is proportional. | 001-sg-build |
| 001-sg-build | complete | Batches A, B and C are committed in exclusive scopes across the three repositories. | 103-sg-verify |
| 103-sg-verify | complete | Focused tests/builds pass; production pages return 200; script hashes equal canonical sources; nine legacy routes return direct 308 redirects with query preservation. | 104-sg-end |
| 104-sg-end | complete | Acceptance criteria AC01-AC10 are closed and residual unrelated worktree diagnostics are documented. | 005-sg-ship |
| 005-sg-ship | complete | ShipGlows was deployed and proven before CommandGlows compatibility redirects were activated and proven. | Monitor compatibility traffic. |
