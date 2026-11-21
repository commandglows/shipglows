---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: shipglows
created: "2026-08-12"
updated: "2026-11-21"
status: active
source_skill: 001-sg-build
scope: build-readiness-route
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/001-sg-build/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "BUILD-READY-SPEC preserves bounded readiness and governance gates."
next_step: none
---

# Build Readiness Route

`BUILD-READY-SPEC`: run `100-sg-spec`, then `101-sg-ready`; when unready, apply one correction pass and recheck. Stop boundedly when readiness still fails. Complete every artifact required by the selected workflow schema before implementation.

Before `102-sg-start`, ensure the technical and editorial governance corpus is present and current. Route missing/stale governance to `300-sg-docs update`, then continue the same run. Preserve a technical reader/docs-map pass and editorial updates when behavior, claims, README, FAQ, pricing, onboarding, or support surfaces change.

Before a material question, load `$SHIPGLOWS_ROOT/skills/references/question-contract.md` and `$SHIPGLOWS_ROOT/skills/references/operator-partnership-contract.md`. Ask only when the answer changes behavior, security, permissions, money, side effects, public claims, proof, closure, or ship risk; present consequences and one recommendation.

Resolve model/topology only after readiness, loading `$SHIPGLOWS_ROOT/skills/704-sg-model/references/model-routing.md` and the canonical delegation contract. Prepared parallel writes require the ready spec's non-overlapping batches and integration owner.

Product loaders, each only for matching work:

- Before defining user-facing interface copy and interactions for implementation, load `$SHIPGLOWS_ROOT/skills/references/interface-voice-and-care.md` and carry its criteria into implementation and review; infrastructure-only work does not activate it. Load `$SHIPGLOWS_ROOT/skills/references/interface-voice-examples.md` only when drafting or revising interface wording.
- For cookie-consent banners, preference panels, or their copy and interactions, load `$SHIPGLOWS_ROOT/skills/references/consent-experience.md` before defining copy, UI, and implementation behavior.
- For Flutter application code, load `$SHIPGLOWS_ROOT/skills/references/flutter-engineering-playbook.md`; for Flutter UI, tests, accessibility, localization, or release, load `$SHIPGLOWS_ROOT/skills/references/flutter-quality-playbook.md`; for app-wide Flutter web or desktop zoom, load `$SHIPGLOWS_ROOT/skills/references/flutter-app-zoom.md`.
- For Astro site work, load `$SHIPGLOWS_ROOT/skills/references/astro-site-playbook.md`; for a new or materially changed publishing system, load `$SHIPGLOWS_ROOT/skills/references/blog-and-cms-experience-contract.md`; for account or signed-in UI, load `$SHIPGLOWS_ROOT/skills/references/authenticated-experience-ui-contract.md`.
- When recommendations use named heuristics or pattern libraries, load `$SHIPGLOWS_ROOT/skills/references/human-centered-interaction-heuristics.md`.
