---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-06-27"
updated: "2026-06-27"
status: active
source_skill: 900-shipglows-core
scope: operator-last-resort-evidence
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/operator-partnership-contract.md
  - skills/references/runtime-diagnostics-surface.md
  - skills/references/playwright-mcp-runtime.md
  - skills/102-sg-start/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
depends_on:
  - artifact: "skills/references/operator-partnership-contract.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/runtime-diagnostics-surface.md"
    artifact_version: "1.0.0"
    required_status: "active"
supersedes: []
evidence:
  - "2026-06-27 hardening sweep: several execution and proof skills repeated the same local warning about not asking the operator for logs or repro while safe evidence was still agent-runnable."
  - "Operator directive 2026-06-26: improve the system, not just individual misses; repeated patterns should be extracted instead of recopied."
next_review: "2026-07-04"
next_step: "/103-sg-verify operator-last-resort-evidence adoption"
---

# Operator-Last-Resort Evidence

Apply this doctrine before asking the operator for logs, screenshots, callback traces, reproduction details, validation status, or similar evidence.

## Rule

Exhaust safe local evidence first.

That includes, when relevant:

- safe project files and current diffs
- existing bug/spec/task memory
- local checks and bounded runtime logs
- browser-visible evidence
- runtime diagnostics surfaces and copy-log/copy-diagnostics actions
- auth-safe Playwright/browser proof

Ask the operator only for:

- real decisions
- secrets or privileged access
- unavailable environments
- manual-only or device-only proof
- unsafe or external side effects

## Runtime Diagnostics

When a runtime app exposes a diagnostics, support, debug, settings, or callback-error surface, use `runtime-diagnostics-surface.md` before asking the operator for logs.

When copied diagnostics are available, confirm the build identity header:

```text
commit/build: <sha or build id>
build_at_paris: YYYY-MM-DD HH:mm Europe/Paris
build_at_utc: YYYY-MM-DD HH:mm UTC
```

If the diagnostics surface is missing, unsafe, blocked by permissions, or does not expose usable text, report that limitation explicitly instead of silently bouncing the evidence request to the operator.

## Local Anchor Rule

Keep a compact local anchor in skills where operator-last-resort behavior is a first-screen execution risk, but keep the detailed doctrine here instead of repeating it verbatim across skills.
