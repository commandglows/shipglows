---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 108-sg-browser
scope: browser-proof-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/108-sg-browser/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "Wave 7 extracted objective-bounded browser proof collection."
next_step: none
---

# Browser Proof Playbook

1. Record target, environment, development mode, objective, and allowed interaction level.
2. Navigate after runtime preflight.
3. Capture an accessibility snapshot when it proves structure/state.
4. Use a screenshot for visual layout, blank/clipped/overlaid state, snapshot disagreement, or explicit request.
5. Inspect console/network only when relevant or visible proof is incomplete; keep severe error count plus sanitized error family, method/path/status, redirect, timeout, or blocked state.
6. For runtime apps, inspect reversible Settings/Support/Diagnostics/Debug/error-fallback surfaces and safe `Copy diagnostics`/`Copy logs` actions. Confirm redacted commit/build and Paris/UTC build-time headers when available.
7. Decide only the requested objective.

If screenshot and accessibility state disagree, evidence is `partial` or `blocked`. If a diagnostics surface is absent/auth-blocked/unsafe or clipboard extraction fails, name that limit before asking the operator.
