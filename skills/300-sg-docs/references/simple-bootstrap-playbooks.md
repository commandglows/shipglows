---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-09-02"
status: active
source_skill: 300-sg-docs
scope: 300-sg-docs-simple-bootstrap-playbooks
owner: Diane
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - skills/300-sg-docs/SKILL.md
  - skills/300-sg-docs/references/bootstrap-starter-templates.md
depends_on: []
supersedes: []
evidence:
  - "Extracted from the former eager mode playbook during wave-3 compaction."
  - "Operator decision 2026-09-02: bootstrap and ordinary documentation maintenance must create or refresh a root PITCH.md identity and navigation card."
next_step: "/103-sg-verify progressive skill activation compaction wave 3"
---

# Simple And Bootstrap Playbooks

Use only the selected mode below. Apply the always-on topology preflight from `SKILL.md` before mutation.

## INIT MODE

Detect project type, stack, source roots, governance root, docs and trackers. For an empty or near-empty repo, use the bootstrap templates selected by the activation gate and create the smallest truthful starter set: `AGENT.md`, a root `PITCH.md`, a bootstrap README, technical README/map, and workflow tasks. Create editorial roadmap only when editorial surfaces apply.

Missing framing is recoverable. Ask one numbered question at a time about project intent, target surface, then primary runtime; continue after each answer. Preserve observed facts, mark unknowns, and never fabricate features or stack.

Build `PITCH.md` from evidenced business/product truth using `templates/PITCH.md`. Keep it concise, include a dated current-state summary and navigation pointers, and never copy `delivery_posture`, runtime liveness, deployment state, or tracker tasks into it as owned truth.

## FILE MODE

Read the target and one import level. Document non-obvious behavior, rationale, edge cases, and public contracts in the local style. Do not narrate obvious code.

## README MODE

Use project evidence for description, features, quick start, structure, stack, environment, scripts, and contribution guidance. If an existing README would be replaced and preference materially affects preservation, ask merge/replace/skip. Empty repos use the bootstrap template rather than a fictional product README.

## API MODE

Document detected method/path, authentication, request/response schemas, status codes, and real examples. Use the project-native docs location.

## COMPONENTS MODE

Document purpose, real props/slots and types, usage, dependencies, and non-obvious behavioral constraints. Use the project-native docs location.

## AUTO MODE

Choose the narrowest evidenced mode. Empty or near-empty repos select INIT and bootstrap before proposing implementation. Existing projects audit root `PITCH.md` presence and freshness before selecting the smallest missing README/API/component/documentation surface. Create or refresh the pitch when evidence resolves it; otherwise report the exact business/product truth gap. Do not broaden AUTO into a governance rewrite without reaching the relevant gate in `SKILL.md`.

## Result

Report outcome, evidence, limits, and next useful result. Do not claim implementation, verification, or current external behavior without matching proof.
