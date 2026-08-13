---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.3.0"
project: ShipGlows
created: "2026-06-29"
updated: "2026-08-12"
status: active
source_skill: 006-sg-design
scope: design-proof-and-reporting
owner: unknown
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/108-sg-browser/SKILL.md
  - skills/109-sg-auth-debug/SKILL.md
  - skills/405-sg-prod/SKILL.md
  - skills/references/reporting-contract.md
depends_on:
  - artifact: skills/references/reporting-contract.md
    artifact_version: "1.11.0"
    required_status: active
  - artifact: skills/references/spec-driven-development-discipline.md
    artifact_version: "1.6.0"
    required_status: active
supersedes: []
evidence:
  - "2026-07-15 consolidation rewrote design proof routes to use canonical 006-sg-design modes."
  - "Operator correction 2026-07-18: design user reports keep proof consequences visible while hiding internal routes and lifecycle controls."
  - "2026-08-04 added motion-specific browser, reduced-motion, lifecycle, and performance proof obligations."
next_review: "2026-08-15"
next_step: "/104-sg-end consolidate design skill surface into modes and playbooks"
---

# Design Proof And Reporting

## Purpose

Define design proof and report details for `006-sg-design`.

Use this reference before claiming design completion, reporting blocked proof, or preparing handoff evidence.

## Proof Rule

Use project scripts and specialist checks instead of inventing proof.

Proof must match the claim:

- token or design-system claim: `006-sg-design audit tokens` and drift scan evidence
- visible UI claim: `108-sg-browser` or equivalent screenshot/browser proof for non-auth surfaces
- auth/protected UI claim: `109-sg-auth-debug`
- accessibility claim: `006-sg-design audit a11y` plus visible proof when the change is UI-facing
- hosted truth claim: `405-sg-prod` or `004-sg-deploy` before browser/auth proof when the target is unknown

Do not claim visual non-regression without browser proof. Do not claim accessibility safety from screenshots alone.

## Reference-Fidelity Proof

When screenshots, mockups, appshots, or visual references define the target, load `$SHIPGLOWS_ROOT/skills/006-sg-design/references/reference-driven-frontend-playbook.md`. Collect rendered evidence for each representative viewport and applicable product state, compare it back to the target, classify material mismatches and acceptable project-system adaptations, correct material mismatches through canonical components or design tokens, and rerender the affected pairs. A successful build or one final screenshot does not prove reference fidelity.

## Motion-Specific Proof

For `animation implement` and `animation tune`, implementation claims also
require browser proof for reduced-motion, responsive behavior, content access
when animation initialization fails where applicable, and cleanup and remount
behavior. For scroll-driven or layout/paint-heavy motion, include appropriate
performance evidence and the measured justification for retaining it.

An animation audit or design report remains read-only and must distinguish
observed behavior, proposed contract, unproven lifecycle assumptions, and the
next proof required before implementation can be called verified.

## Blocked Proof

Every blocked report must include the exact next recovery route.

For hosted/prod/deployed/provider/browser/manual proof gaps, report:

- proof type
- proof owner or lifecycle skill
- scenario
- target or environment
- reason the agent could not collect the proof

If deployment target is unknown, route first to `405-sg-prod` instead of asking the operator to inspect manually.

## User-Mode Report

Use this shape only when a design-specific report is needed in addition to the shared reporting contract:

```text
🧱 CHANTIER (local|spec) : [nom]
🎯 VERDICT (HH:mm) : [résultat]

[Résultat de conception et preuve observable]
[Limite de preuve ou de cohérence des tokens, seulement si elle compte]

[Si le chantier reste ouvert, terminer par les choix numérotés en langage
simple du contrat partagé. Ne jamais exposer un mode interne, un propriétaire
de preuve, un skill, une commande, un chemin de spec ou un flux.]
```

Agent/handoff mode may add the routing matrix decision, owned surfaces, forbidden files, validation commands, browser proof obligations, docs/editorial plan, and unresolved decisions.
