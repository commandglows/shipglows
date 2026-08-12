---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 106-sg-fix
scope: bug-proof-retest-and-reporting
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/106-sg-fix/SKILL.md
  - shipglows_data/workflow/bugs/*.md
depends_on:
  - artifact: skills/references/project-development-mode.md
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Wave-3 compaction isolates retest and reporting detail from first-decision activation."
next_step: "/103-sg-verify progressive skill activation compaction wave 3"
---

# Bug Proof And Reporting

Load this reference only after classification, before selecting a retest surface or producing the final bug report.

## Evidence Routes

- For auth, protected routes, OAuth redirects, sessions, callbacks, or behavior that fails only in a browser, gather diagnostic evidence through the auth-debug owner while `106-sg-fix` retains repair ownership.
- For non-auth browser behavior, gather browser evidence before patching when runtime observation controls the proof.
- For crashes, 5xx, error boundaries, deployed exceptions, support event IDs, or copyable diagnostics, use the applicable Sentry/runtime diagnostics surface. Verify that copied diagnostics start with commit/build plus Paris/UTC build time.
- Never persist raw payloads, breadcrumbs, replay contents, headers, cookies, tokens, private URLs, PII, secrets, or customer data.
- Gather safe local, runtime, browser, and app evidence before escalating. Operator input is reserved for decisions, secrets, account/device/manual-only proof, unavailable environments, or unsafe external effects.

## Retest Selection

Apply `project-development-mode.md`:

- `local`: run the narrow regression or evidence path plus relevant project checks.
- `vercel-preview-push`: local proof is insufficient; route push, production/preview confirmation, then preview retest against the matching `BUG-ID`.
- `hybrid`: require deployed proof when the affected behavior depends on hosted auth, callbacks, webhooks, environment variables, edge/serverless routing, or preview data.
- unknown mode: report the uncertainty and do not overstate the result.

For changed UI/design files, run the ShipGlows design-system drift check. Unresolved new drift keeps status at most `fix-attempted`.

For a qualifying visual minor exception, preserve `evidence -> fix-attempted -> retest -> fixed-pending-verify -> verify`. Technical checks may support only `implemented`; a person validates the rendered result before any resolved, fixed, verified, or closed wording. Otherwise record the concrete proof owner, scenario, proof type, and target/environment.

## Result And Report

Report classification and reason, user story, bug reference/file or minor exception, proof path, root-cause hypothesis, product/docs coherence, fresh-docs state, Sentry and diagnostics evidence, operator autonomy, development mode, preview gate, security posture, status transition, retest evidence, action, and bounded scope estimate.

Use the shared reporting contract. In agent/handoff detail, keep exact commands and evidence pointers; in user mode, translate internal routing into the outcome, proof, material gap, and genuinely operator-owned next decision.

Never claim closure from tracker state, a local repro alone, static UI checks, or an uncorrelated error event. A passing retest permits `fixed-pending-verify`; verification is still required before closure.
