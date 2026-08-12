---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 109-sg-auth-debug
scope: auth-intake-and-authority
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
next_step: "/103-sg-verify auth intake authority"
---

# Auth Intake And Authority

Consume sources in order: existing spec, bug report/user request, current diff/recent files, then bounded code exploration. Reformulate a mini user story with actor, trigger, exact rupture, and expected outcome. Record target environment, ShipGlows development mode, URL/flow, provider, observation, and expectation; ask one short question only when a missing fact materially changes the safe diagnostic route.

If a local or technical master auth playbook exists, use it for auth-family classification, the `login -> session restore -> protected backend operation -> logout` invariant, environment/redirect checks, and redaction stops. If absent, report `Master auth playbook: missing` and continue with the selected stack references.

Apply `project-development-mode.md`:

- `local`: local browser evidence may be authoritative when localhost auth is configured.
- `vercel-preview-push`: changed behavior must route through bounded `005-sg-ship -> 405-sg-prod`; resume on the URL confirmed by `405-sg-prod`.
- `hybrid`: local evidence covers only local/static behavior. Hosted OAuth, callback, domain, secure/SameSite cookie, deployed env, edge, or serverless behavior requires confirmed hosted proof.
- `unknown-vercel`: document the gap and do not promote local success to hosted proof.

Automation may cover a public login trigger, form auth, partial OAuth redirect, an existing safe session, or a user-assisted flow. Never promise full automation through strong MFA, CAPTCHA, device approval, inaccessible magic links, WebAuthn/passkeys, or external anti-bot controls. Stop before unsafe account, provider, or production mutation; report the precise human or authority boundary.

`TASKS.md`, `AUDIT_LOG.md`, and `PROJECTS.md` are read-only context for this specialist.
