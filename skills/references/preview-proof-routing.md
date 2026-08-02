---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: active
source_skill: 900-shipglows-core
scope: preview-proof-routing
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/project-development-mode.md
  - skills/003-sg-bug/SKILL.md
  - skills/004-sg-deploy/SKILL.md
  - skills/005-sg-ship/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/104-sg-end/SKILL.md
  - skills/105-sg-check/SKILL.md
  - skills/107-sg-test/SKILL.md
depends_on:
  - artifact: "skills/references/project-development-mode.md"
    artifact_version: "1.1.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-06-27 transverse hardening audit: the same preview-proof route was repeated across execution, verification, test, closure, and ship skills."
  - "Operator decision 2026-06-27: repeated doctrines must move to shared references instead of being recopied into every skill."
next_review: "2026-07-04"
next_step: "/103-sg-verify preview-proof-routing adoption"
---

# Preview Proof Routing

Apply this doctrine when project development mode is `vercel-preview-push` or when a `hybrid` project needs hosted proof.

## Route

When the changed behavior needs preview, browser, auth, webhook, deployed-runtime, or manual user-flow evidence, the required route is:

`005-sg-ship` -> `405-sg-prod` -> downstream proof owner

Downstream proof owner examples:

- `108-sg-browser` for non-auth browser-visible proof
- `109-sg-auth-debug` for auth/session/callback/protected-route proof
- `107-sg-test --preview` for manual or multi-step preview QA

## Rules

- Do not claim browser, preview, auth, integration, or manual user-flow validation from local evidence alone when project mode requires deployed proof.
- Do not ask the operator to run preview/manual/browser proof before `005-sg-ship` has pushed and `405-sg-prod` has confirmed the matching deployment target.
- After successful ship in preview-required mode, `405-sg-prod` is the immediate next step.
- If preview validation is still missing, keep closure, verification, and changelog framing below `done`/`verified`/`released` strength as the local skill contract requires.

## Local Anchor Rule

Keep a compact local anchor in skills where preview-proof routing is a first-screen execution risk, but keep the detailed doctrine here rather than repeating the route text verbatim across skills.
