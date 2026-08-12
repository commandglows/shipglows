---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-16"
updated: "2026-08-12"
status: active
source_skill: 405-sg-prod
scope: production-verification-workflow
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/405-sg-prod/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 16 replaced the monolith with a compatibility core and direct conditional leaves."
next_review: "2026-09-12"
next_step: "/103-sg-verify 405-sg-prod compaction"
---

# Production Verification Workflow

Compatibility core for deployment and hosted-runtime truth. Activation, canonical paths, chantier/report requirements, and stop conditions remain authoritative in `../SKILL.md`.

## Decision Core

1. Resolve the project, development mode, expected commit/branch, provider, and target environment. Unknown targets are a discovery task, not permission to guess.
2. Match provider deployment evidence to the intended commit and branch, wait for a terminal state, and preserve conflicts or uncertainty. Provider-native evidence is primary when available; commit statuses are corroboration or partial fallback.
3. A ready deployment and responding URL prove deployment reachability only. Never infer auth, permissions, payments, webhooks, jobs, private data, or the main user flow without their owner proof.
4. Collect enough build/runtime evidence to identify the first causal error and meaningful warnings. Keep secrets, credentials, cookies, private payloads, production PII, and environment values redacted.
5. Report `ready`, `failed`, `pending`, `partial`, or `blocked` with commit, target, evidence source, proof limits, and concrete next owner. Never rollback, repair, ship, or mutate production without separate authorization.

## Direct Conditional Routes

- Target discovery, provider matching, terminal-state waiting, and status fallback: load `references/prod-deployment-evidence.md` directly.
- URL/redirect/health checks and proof-boundary decisions: load `references/prod-health-and-proof.md` directly.
- Build/runtime logs, Sentry, PM2/Doppler, and Blacksmith diagnostics: load `references/prod-runtime-diagnostics.md` directly.
- Verdict fields, failure handoff, and remaining-risk reporting: load `references/prod-verdict-and-routing.md` directly.

Load only the branch required by the current decision. These references are siblings and never require or route through one another.

## Completion Gate

Do not declare production verified unless the target is matched to the intended release, the deployment reached a terminal ready state, the relevant health surface was checked, evidence collection is complete enough for the stated verdict, and every uncovered sensitive/user-visible flow is named as a proof gap with owner, scenario, proof type, and target/environment.
