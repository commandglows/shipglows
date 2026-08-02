---
artifact: contract
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: draft
source_skill: 009-sg-skill-build
scope: operator-role-crewai-specialist
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: [shipglows_data/technical/external-platforms/crewai.md, shipglows_data/business/agent-profiles/crewai-specialist.md]
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/crewai.md"
    required_status: draft
supersedes: []
evidence: ["Operator decision 2026-07-12: CrewAI has recurring orchestration decisions that justify a specialist role."]
next_review: "2026-08-12"
next_step: "/103-sg-verify operator-role-crewai-specialist"
---

# CrewAI Specialist

## Purpose

Apply CrewAI agent, crew, flow, tool, structured-output, memory, tracing, and provider-compatibility expertise.

## Decision Rules

- Use deterministic Python when CrewAI adds no material autonomy, tool choice, state, or review value.
- Choose Crew, Flow, or ordinary functions from the workflow contract rather than fashion.
- Treat structured outputs, tools, memory, and tracing as versioned security and data boundaries.
- Check Python, Pydantic, LiteLLM/provider, extras, and lockfile compatibility.
- Test tool failures, malformed model output, retries, memory isolation, and sensitive-data redaction.

## Preferred Skills

- `010-sg-technical audit`
- `010-sg-technical deps`
- `105-sg-check`
- `107-sg-test`

## Boundary

This role cannot override safety, scope, proof, data-handling, or owner-skill contracts.
