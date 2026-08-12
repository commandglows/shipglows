---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 003-sg-bug
scope: bug-evidence-routing
owner: Diane
confidence: high
risk_level: high
security_impact: none
docs_impact: no
linked_systems:
  - skills/003-sg-bug/SKILL.md
  - skills/references/project-development-mode.md
depends_on:
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.4.0"
    required_status: active
supersedes: []
evidence:
  - "Wave-2 compaction extracted evidence-owner and development-mode procedures from the activation contract."
next_step: "/103-sg-verify progressive-skill-activation-compaction-wave-2"
---

# Bug Evidence Routing

Load this playbook only when evidence, reproduction, proof path, runtime diagnostics, or development mode determines the next action. Do not load another local `003-sg-bug` playbook before the first evidence action.

## Choose The Evidence Owner

- Auth, OAuth, cookies, sessions, callbacks, tenants, or protected routes -> `109-sg-auth-debug`.
- Non-auth visible state, console, network, screenshot, or page assertion -> `108-sg-browser`.
- Full flow, human confirmation, durable manual record, or retest -> `107-sg-test`.
- Runtime crash, error boundary, 5xx, Sentry/support event, or copyable diagnostics -> load the shared Sentry and runtime-diagnostics references, then attach only a redacted pointer or short summary.
- Unclear expected behavior, permission rule, data contract, or product rule -> `100-sg-spec`.

Never invent reproduction, screenshots, roles, console logs, diagnostics, or user confirmation. Apply the Operator Autonomy Standard from the shared decision-quality contract before asking for information.

## Set The Proof Path

Load `$SHIPGLOWS_ROOT/skills/references/spec-driven-development-discipline.md`, then record exactly one path before dispatch:

- `regression-first`: reproduction exists and a failing automated regression is practical before repair.
- `evidence-first`: browser, manual, runtime, redacted diagnostics, screenshot, or retest is authoritative.
- `exception-with-proof`: regression automation is impractical; record why and name the alternate proof.

Visual work retains the stricter gate in the activation contract. A build, HTTP response, file signature, deployment, or code diff cannot substitute for rendered validation.

## Apply Development Mode

Load `$SHIPGLOWS_ROOT/skills/references/project-development-mode.md` before deciding where proof is authoritative.

- `local`: local retest/browser proof may be authoritative for a local bug.
- `vercel-preview-push`: load the shared preview-proof route; use deployed preview retest after ship and deployment confirmation.
- `hybrid`: use the preview route for auth callbacks, webhooks, deployment environment, edge/serverless behavior, Vercel routing/data, or remotely reproducible bugs.
- Missing mode plus Vercel signals: classify `unknown-vercel`; do not claim preview authority.

Do not ask the operator to perform proof that the available agent tools can obtain safely.

## Evidence Pressure Cases

- Auth-like symptom on a public route: choose by the actual session/protection dependency, not by visual appearance.
- A crash has a raw payload: redact before attaching; never persist bulk observability data.
- Hosted-only bug passes locally: keep it unresolved until the matching preview route produces evidence.
- A third repair is proposed without cause evidence: return to diagnosis.
