---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 102-sg-start
scope: 102-sg-start-implementation-proof
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/102-sg-start/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "START-AUTO-VERIFY-ELIGIBLE and START-AUTO-VERIFY-SKIPPED preserve proof ownership."
next_step: none
---

# Implementation And Proof

Immediately before writing, load only the shared contracts selected by `SKILL.md` and the execution contract. Run any Atlas protection preflight against every intended path before mutation.

Implement one bounded slice at a time. Preserve user changes, the promised outcome, dependency versions, security boundaries, observable success/failure, diagnostics, documentation coherence, and project conventions. Update durable progress only after actual completion. Stop on scope growth, conflicting contracts, new side effects, missing authority, or proof that cannot support the promised result.

At an explicit checkpoint, run focused checks matching the chosen proof path: user outcome, success and error behavior, touched tests/lint/types/syntax, linked consumers, documentation coherence, and applicable security/abuse, UI drift, runtime/Sentry, browser/auth, or checklist evidence. Passing technical checks alone does not prove hosted, auth, production, device, manual, security, or product behavior.

For `local`, run suitable local proof. For preview-push or hosted-only behavior, finish bounded local checks then route through `005-sg-ship -> 405-sg-prod` before browser/manual proof. Hybrid mode keeps hosted/auth/serverless differences on that hosted path.

## Auto-Verify Scenarios

`START-AUTO-VERIFY-ELIGIBLE`: report `auto-verify: run` only when one ready spec owns the work, implementation/local checks passed, and remaining verification is defined, local, tool-backed, non-destructive, and decision-free.

`START-AUTO-VERIFY-SKIPPED`: report `auto-verify: skipped` plus `owner_skill`, `scenario`, and `target_or_environment` for preview/production, browser/auth, Sentry, manual/device, secret, ship, provider, data-mutation, or other external proof. Route non-auth browser to `108-sg-browser`, auth/session/provider to `109-sg-auth-debug`, hosted truth to `405-sg-prod`, durable manual QA to `107-sg-test`, and broader verification to `103-sg-verify`.

Auto-verify never commits, pushes, ships, deploys, mutates external state, prompts for secrets, closes the chantier, or upgrades implementation to verified.

