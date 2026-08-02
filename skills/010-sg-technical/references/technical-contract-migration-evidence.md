---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-17"
updated: "2026-07-17"
status: active
source_skill: 010-sg-technical
scope: technical-contract-migration-maintenance-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/010-sg-technical/SKILL.md
  - tools/test_010_sg_technical_contract.py
  - shipglows_data/workflow/specs/consolidate-technical-skills-under-sg-technical.md
depends_on: []
supersedes: []
evidence:
  - "2026-07-17 source-completeness transfer from all four predecessor contracts and the 401 audit workflow."
next_step: "/103-sg-verify consolidate technical skills under sg-technical"
---

# Technical Contract Migration Evidence

This is a maintenance and verification reference. The normal dispatcher must not load it for operator modes.

## Completeness Matrix

| Retired source contract | Canonical mode | Exact selected playbook | Required source contract retained |
| --- | --- | --- | --- |
| `401-sg-audit-code` | `audit` | `references/technical-audit-playbook.md` | GLOBAL, FILE, and PROJECT routes; user-story and metadata-version context; linked systems; scoring/severity; correctness; workflow integrity and abuse resistance; trust boundaries, authn/authz, tenant isolation, data/secrets, repository hygiene; architecture, reuse/duplication, reliability, runtime diagnostics/Sentry, tests; findings-first reporting; traffic-first tracking; read-only default; explicit fix scope; proof gaps and stop conditions. |
| `402-sg-deps` | `deps` | `references/dependency-audit-playbook.md` | Project/global scope and no FILE MODE; vulnerabilities and exploitability limits; runtime/product exposure; supply-chain integrity, provenance, registry/token/install-script trust; outdated/abandoned packages; unused, misplaced, duplicate dependencies; licenses; types; lockfiles; runtime/package-manager pins; automation/config; traffic-first tracking; category-level mutation approval; no major auto-upgrade; no audit-tool install without authority; partial scans never become security sign-off. |
| `403-sg-perf` | `performance` | `references/performance-audit-playbook.md` | File/project/global routes; bundle/loading, splitting, assets, scripts; rendering/hydration/virtualization; CWV readiness and stack applicability; fetching/caching/optimistic updates; databases/backends, bounded queries, indexes, resources; Sentry overhead; severity/reporting/tracking; read-only default; measured-versus-inferred evidence; `405` live-truth and `406` SEO boundaries. |
| `404-sg-migrate` | `migrate` | `references/migration-playbook.md` | Target discovery; one package/major at a time; current official migration guide and release notes; full breaking-change and codebase impact matrix; peer/dependent compatibility; distinct apply approval; complete dirty-state review; no auto-stash/discard/overwrite; recoverable rollback; bounded installs/codemods/network; ordered changes; proportional typecheck/lint/build; failed-build stop and recoverable report. |

All source modes retain conditional `source-de-chantier` tracing, reporting modes, canonical paths, operational-record safety, decision quality, redaction, missing-evidence limits, and no unrelated durable mutation through the compact dispatcher and shared references.

## Retired-Name Policy And Historical Allowlist

`010-sg-technical` is the only active public technical identity. The four names in the matrix are source provenance only, never aliases, examples, runtime entries, public pages, redirects, wrappers, fallbacks, or source directories.

The narrow allowlist is limited to this maintenance-only transfer reference, the owning consolidation spec, historical specs/audits/bugs/archives/changelog/run ledgers that factually record provenance, and immutable Git history. Every current routing, operator guide, help/catalog, runtime, public page, test expectation, or active maintenance instruction must use `010-sg-technical` with an exact mode.

Deletion is valid only after the deterministic contract test proves source markers, mode/playbook selection, owner boundaries, safety/mutation stops, active-name absence, public/catalog/runtime migration, and source-directory retirement.
