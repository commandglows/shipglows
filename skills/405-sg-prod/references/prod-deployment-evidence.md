---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 405-sg-prod
scope: prod-deployment-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/405-sg-prod/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from production-verification-workflow.md during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify prod deployment evidence"
---

# Production Deployment Evidence

Resolve an explicit URL/project argument or the current project's remote and provider metadata. If ambiguity remains, ask one targeted project/target question; never select a production target by filename coincidence.

For Vercel or preview-push, use provider deployment APIs/MCP first. Identify the deployment matching the intended SHA and branch, inspect its build state, and wait until `READY`, `ERROR`, `CANCELED`, or equivalent. Use progressive polling within the execution environment and provide progress at least every minute; after roughly eleven minutes, report pending and ask whether to continue. Do not ask for browser/manual proof while the matching deploy is unready.

GitHub commit statuses are fallback or corroboration. Prefer the newest deployment-provider status, surface conflicts, and mark the result partial when SHA/branch matching or provider identity is unproved. No status means no automatic deployment evidence, not success.

Return the matched commit, branch, provider, deployment ID/URL, terminal state, evidence source, dashboard/log pointer, and matching confidence. Never expose access tokens or provider credentials.
