---
artifact: playbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-22"
updated: "2026-08-22"
status: active
source_skill: 006-sg-design
scope: brand-identity-creation-and-evolution
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/006-sg-design/SKILL.md
  - skills/006-sg-design/references/design-lifecycle-routing.md
  - skills/009-sg-marketing/SKILL.md
  - skills/007-sg-content/SKILL.md
  - skills/references/business-context-mesh.md
depends_on:
  - artifact: skills/references/design-system-token-contract.md
    artifact_version: "1.1.0"
    required_status: active
  - artifact: skills/references/operator-partnership-contract.md
    artifact_version: "1.7.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-22: ShipGlows creates distinctive identities and impactful businesses beyond software."
  - "Operator decision 2026-08-22: Git is the canonical memory for every representable artifact; provider-native sources keep links and proportionate exports."
next_review: "2026-09-22"
next_step: none
---

# Brand Identity Playbook

## Purpose

Create or evolve a distinctive visual identity that expresses governed business, audience, positioning, promise, and brand truth across relevant surfaces. An identity is a business system, not decoration and not necessarily a software interface.

## Ownership Boundaries

- Marketing owns market, offer, positioning, message strategy, and verbal foundations.
- Design owns art direction, logo system, color, typography, imagery, composition, motion language, and the coherent visual identity system.
- Content owns editorial expression and publication across audience surfaces.
- Technical owners implement the accepted identity where code or infrastructure is required.

`sg-design identity` retains public outcome ownership and coordinates these contributions internally. Missing positioning or audience truth routes to the relevant owner; it does not authorize design to invent a business promise.

## Identity Contract

Before creation, establish the business or initiative, audience, desired and avoided perceptions, positioning, existing equity to preserve, target surfaces, constraints, acceptance criteria, and proof plan. Broad creation or a material identity shift is spec-first.

Produce the smallest coherent identity system that can work across the declared horizon. Depending on scope, this may include:

- identity rationale and governing principles;
- logo and mark rules, including minimum-size and misuse guidance;
- semantic color and typography roles;
- imagery, illustration, iconography, composition, and motion direction;
- representative applications across declared physical, editorial, service, or digital surfaces;
- accessible and production-ready exports appropriate to those surfaces.

Do not require a website, application, or software product for the identity work to be valid.

## Git Memory And External Sources

Persist every repository-representable artifact through the approved commit and push path: identity contract, decisions, tokens, textual specifications, manifests, export inventory, generated assets, and validation evidence. Commit/push proves durable memory and collaboration, not real-world application.

For provider-native sources such as Figma or Canva, record the canonical source link, tool and owner, export date or version, editable-source availability, and proportionate review exports. Never describe an export as the native editable source. External publication, account changes, or provider writes retain their own authorization gates.

## Human And Agent Usability

The identity contract must let a capable human understand the intent, choose the correct assets, apply the system, recognize misuse, and verify the result without agent mediation. Machine-readable tokens and manifests complement that explanation; they do not replace it.

## Proof

Verify distinctiveness against the governed direction, coherence across representative surfaces, legibility, contrast, scalability, accessible alternatives, export integrity, and the declared acceptance criteria. Code-only proof never establishes identity quality. When implemented digitally, add browser, responsive, accessibility, and performance proof; when applied elsewhere, use evidence appropriate to that destination.

## Stop Conditions

Stop when positioning, audience, promise, existing equity, material legal/licensing rights, target surfaces, or acceptance authority is unresolved; when the work would copy a reference rather than derive transferable principles; when provider-native truth cannot be linked or exported proportionately; or when requested application exceeds approved mutation or publication authority.

## Pressure Scenarios

- `IDENTITY-NONSOFTWARE-01`: a new media, service, physical, or community business receives a complete identity route without being converted into an application project.
- `IDENTITY-OWNERSHIP-02`: positioning stays with marketing, the visual system stays with design, editorial expression stays with content, and one public owner coordinates the outcome.
- `IDENTITY-GIT-03`: representable identity artifacts are committed and pushed; an external native source also records its canonical link and review exports.
- `IDENTITY-HUMAN-04`: a capable human can apply and verify the identity from the durable contract without an agent.
- `IDENTITY-TECH-05`: digital implementation retains token, browser, accessibility, performance, and regression proof rather than weakening technical standards.
