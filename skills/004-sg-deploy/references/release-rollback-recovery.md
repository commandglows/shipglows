---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-20"
updated: "2026-10-20"
status: active
source_skill: 004-sg-deploy
scope: 004-sg-deploy-release-rollback-recovery
owner: unknown
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/405-sg-prod/SKILL.md
  - skills/405-sg-prod/references/prod-verdict-and-routing.md
  - skills/005-sg-ship/SKILL.md
  - skills/references/deploy-target-matrix.md
depends_on:
  - artifact: "skills/references/deploy-target-matrix.md"
    artifact_version: "1.1.0"
    required_status: active
supersedes: []
evidence:
  - "Fills the guided-recovery gap left when the sg-deploy master release spec scoped rollback out."
next_review: "2027-01-20"
next_step: none
---

# Release Rollback Recovery

## Purpose

Guide recovery after a release that broke a deployed surface. This pack restores the last known-good state; it does not diagnose or fix the defect (route that to `003`/`106` afterwards).

## Entry

Load only when `405-sg-prod` reports `failed` or `partial` on a surface that was healthy before this release, or when the operator asks for `rollback`. Never enter it automatically from a red check before ship.

## Steps

1. **Confirm truth.** Through `405`, record the broken deployment (id/URL, commit) and identify the last known-good deployment for the same target and branch. No known-good candidate → `blocked`.
2. **Assess irreversibility.** Check whether the release ran schema/data migrations, sent emails/webhooks, or changed external config. Rolling back code never undoes those; flag them and stop for an explicit decision when the previous code is incompatible with the new data.
3. **Propose one recovery path** in plain language, with impact and what stays broken:
   - **Vercel**: instant rollback to the known-good deployment (`vercel rollback <url>` or the Vercel MCP rollback request). It disables automatic production promotion: the next fixed deploy needs `vercel promote <url>`; say so in the report.
   - **Other hosted providers**: the provider's own redeploy-previous-deployment feature when it exists.
   - **Git-driven or PM2/self-hosted**: `git revert <bad-commit>` (never reset or force push) shipped through `005-sg-ship`, then redeploy through the normal route.
   - **Stores/mobile**: no rollback; halt the staged rollout when possible and route a hotfix release.
4. **Ask for approval.** Every production mutation in this pack requires an explicit operator yes for that exact action. Database restores and data repairs are separate irreversible actions with their own approval.
5. **Re-verify.** After the recovery action, rerun `405` on the same target and the smallest objective-matched proof that failed. Recovery is `ready` only when the known-good state is proved live again.
6. **Close.** Report the bad and restored deployments, recovery action, remaining risk, and the follow-up owner for the real fix. Evaluate `Chantier potentiel` when the cause needs non-trivial work.

## Stop Conditions

Stop when the known-good target is uncertain, approval is missing, the rollback would need a force push or history rewrite, data compatibility is unknown, or provider access is unavailable. Never print secrets, tokens, or private logs while gathering rollback evidence.
