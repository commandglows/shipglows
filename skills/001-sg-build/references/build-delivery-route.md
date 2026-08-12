---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 001-sg-build
scope: build-delivery-route
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "BUILD-PROOF-OWNER and BUILD-CONTINUE-THROUGH-SHIP preserve lifecycle continuation."
next_step: none
---

# Build Delivery Route

Run `102-sg-start` only from a ready contract, then judge remaining evidence through `103-sg-verify`. Local `auto-verify: run` satisfies only the named local checks, never full lifecycle verification.

`BUILD-PROOF-OWNER`: route non-auth browser evidence to `108-sg-browser`, auth/session/callback/provider/tenant/protected routes to `109-sg-auth-debug`, hosted runtime/deployment truth to `405-sg-prod`, and durable manual QA/retest to `107-sg-test`, always with scenario and target/environment. Preview-required flows use bounded ship then hosted proof. Failed or partial proof returns to correction or explicit risk decision before closure.

Evaluate `008-sg-customer` when a feature changes setup, first-run/empty state, permissions, integrations, settings, multi-step discovery, public promises, or support expectations. Route onboarding before closure when acceptance requires it; otherwise suggest only material adoption gains.

`BUILD-CONTINUE-THROUGH-SHIP`: after verification passes, orchestrate `104-sg-end`, then `005-sg-ship` with chantier-bounded staging. Never ship unrelated dirty files or use all-dirty authority implicitly. Do not end with closure/ship as a manual operator command unless a named stop condition blocks automatic continuation.

