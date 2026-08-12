---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: shipglows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 001-sg-build
scope: build-greenfield-route
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
  - "BUILD-GREENFIELD preserves platform, stack, blueprint, and technology decisions."
next_step: none
---

# Build Greenfield Route

Apply the Greenfield Platform Footprint Rule before architecture: distinguish browser/PWA, iOS/Android, desktop, launch phase, and roadmap targets whenever they change credible options. Do not infer responsive web excludes native mobile.

Load `$SHIPGLOWS_ROOT/skills/references/preferred-stacks.md` before `$SHIPGLOWS_ROOT/skills/references/app-blueprints.md`. Match blueprints first by required-platform compatibility, then product archetype and keywords. Resolve a candidate from its canonical registry/cache or declared source; a domain mismatch may guide conventions but cannot silently supply product models/routes. Ask on ties or contradiction. Preserve the selected blueprint/version/source for spec, scaffold, and reporting; no match is valid.

`BUILD-GREENFIELD`: before freezing architecture, hosting, data, payments, or a material provider choice not covered by an accepted preset/blueprint, present one researched recommendation at the product-consequence level and ask one bundled decision. Stop rather than assuming a direction that materially changes ongoing cost, control, maintenance, portability, lock-in, or supported platforms.

The blueprint is a starting skeleton, never a substitute for the ready spec.
