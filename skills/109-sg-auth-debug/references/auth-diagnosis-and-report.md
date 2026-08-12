---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 109-sg-auth-debug
scope: auth-diagnosis-and-report
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [skills/109-sg-auth-debug/SKILL.md]
depends_on: []
supersedes: []
evidence: ["Extracted from the auth-debug workflow during Wave 16 compaction."]
next_review: "2026-09-12"
next_step: "/103-sg-verify auth diagnosis report"
---

# Auth Diagnosis And Report

Classify one primary failure family: UI trigger; OAuth redirect/state/environment; provider configuration; Supabase SSR/token refresh; session/cookies; middleware/protection loop; auth-to-database/RLS/identity propagation; or app post-login consumption. Support each hypothesis with at least one redacted observable: URL/state, visible message, network status, DOM result, relevant code/config location, or environment-matched Sentry event pointer.

Keep symptom, observation, hypothesis, and recommended correction separate. Never claim the provider "doesn't work" or that a fix is verified without identifying the exact failing transition and proof authority.

Report:

- user story and target environment;
- development mode and validation authority;
- flow/start URL and action tested;
- observed versus expected result;
- exact failure point and primary diagnosis;
- redacted evidence, including deploy/Sentry/runtime status when relevant;
- automation status: `full`, `partial`, or `blocked by human/authority/runtime step`;
- concrete next step and owner.

Route a narrow implementation correction to `106-sg-fix` or owned implementation to `102-sg-start`; changed product/auth contract to `100-sg-spec`; hosted deployment truth to `405-sg-prod`; generic non-auth browser proof to `108-sg-browser`; durable manual QA to `107-sg-test`; closure proof to `103-sg-verify`. Findings that reveal non-trivial unowned future work apply the chantier-potential gate.

Reports must redact secrets, tokens, cookies, OTPs, OAuth codes/state, private environment values, PII, sensitive breadcrumbs, and raw payloads. Missing proof stays explicit and cannot be converted into a success verdict.
