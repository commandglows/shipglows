---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-07-12"
updated: "2026-07-12"
status: reviewed
source_skill: 203-sg-research
scope: technology-reference-priorities-turso-crewai-and-future-stack
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
source_count: 12
linked_systems:
  - shipglows_data/technical/external-platforms/
  - skills/references/operator-roles/
  - local/turso-login.sh
  - local/turso-ssh.sh
depends_on:
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "https://supabase.com/docs"
  - "https://docs.turso.tech/introduction"
  - "https://docs.turso.tech/cli/introduction"
  - "https://docs.crewai.com/en/introduction"
  - "https://ai.pydantic.dev/"
  - "https://docs.langchain.com/oss/python/langgraph/overview"
  - "https://developers.cloudflare.com/workers/"
  - "https://hono.dev/docs/"
  - "https://orm.drizzle.team/docs/overview"
  - "https://tanstack.com/start/latest/docs/framework/react/overview"
next_review: "2026-08-12"
next_step: "/100-sg-spec Turso and CrewAI specialist references"
---

# Technology Reference Priorities: Turso, CrewAI, And Future Stack

## Executive Summary

Supabase and CrewAI already have canonical platform notes. Turso is the clear documentation gap because ShipGlows already owns Turso login/SSH helpers and has prior research, but no canonical `external-platforms/turso.md`. CrewAI merits a specialist role because it drives real backend orchestration; Supabase should keep its reference but remain without a specialist role per operator decision.

## Current Local State

| Technology | Canonical platform note | Specialist role | Real ShipGlows usage | Recommendation |
| --- | --- | --- | --- | --- |
| Supabase | yes | intentionally no | auth/database/storage references | refresh existing note only |
| Turso | no | no | login/SSH helpers and ContentFlow evidence | add note, then role if recurring |
| CrewAI | yes | no | core ContentGlowz backend orchestration | add specialist role |

## Turso

Create `shipglows_data/technical/external-platforms/turso.md` now. It should distinguish:

- Turso Cloud CLI and hosted database proof
- embedded/local Turso database usage
- authentication and token-handling boundaries
- project-local Flox provisioning versus global installation
- MCP use versus authoritative hosted schema verification

A Turso specialist role is justified if agents repeatedly touch schema, replicas, libSQL compatibility, auth, live database proof, or migration behavior across projects. The role must load the platform note and must not expose tokens or silently mutate hosted data.

## CrewAI

Keep the existing platform note and add `crewai-specialist`. The role should focus on:

- deciding between Crew, Flow, and ordinary deterministic Python
- typed/structured outputs and regression proof
- tool permission boundaries
- provider and dependency compatibility
- memory, tracing, retention, and privacy
- avoiding unnecessary multi-agent architecture

CrewAI should not be the universal ShipGlows orchestration layer merely because it supports agents. Use it where tool selection, role separation, stateful flows, or human review materially improve the product.

## Future Technology Watchlist

### High-value watchlist

- **PydanticAI** — strong fit for typed Python agent applications and structured outputs; evaluate as a simpler alternative for bounded agent flows.
- **LangGraph** — relevant for durable, stateful, resumable agent workflows; evaluate only when workflow persistence and explicit graphs are needed.
- **Cloudflare Workers** — relevant for edge APIs, queues, scheduled work, and globally distributed lightweight services.
- **Hono** — compact web framework suited to Workers and other JavaScript runtimes; useful if ShipGlows adopts a multi-runtime edge layer.
- **Drizzle ORM** — relevant for TypeScript-first SQL projects that need explicit schemas and migrations.

### Watch, do not standardize yet

- **TanStack Start** — promising full-stack React option, but adopting another application framework should wait for a concrete project and migration rationale.

## Recommendation

Priority order:

1. Add the missing Turso platform note.
2. Add CrewAI specialist role/profile using the existing CrewAI note.
3. Add Turso specialist role/profile if the note confirms repeated cross-project use.
4. Keep Supabase as reference-only.
5. Keep PydanticAI, LangGraph, Cloudflare Workers, Hono, and Drizzle as a watchlist until a real project creates an adoption decision.

## Final Classification

| Technology | ShipGlows treatment | Reason |
| --- | --- | --- |
| Turso | platform reference + specialist role | already integrated into ShipGlows operational tooling and live database proof |
| CrewAI | existing platform reference + specialist role | active orchestration dependency with recurring architectural decisions |
| Supabase | existing references only | mature coverage already exists; operator explicitly excluded a specialist role |
| PydanticAI | reference only | promising typed-agent option, not yet a recurring project owner surface |
| LangGraph | reference only | useful durable workflow option, but overlaps orchestration choices and is not adopted |
| Cloudflare Workers | reference only | future edge/runtime option without current standardization |
| Hono | reference only | JavaScript/TypeScript framework whose rules belong under the existing language specialists until adopted |
| Drizzle ORM | reference only | future TypeScript SQL option, not a current cross-project standard |
| TanStack Start | reference only | promising framework whose maturity and adoption fit must be rechecked per project |

## Freshness Verdict

`fresh-docs checked` — official documentation entrypoints were consulted on 2026-07-12. No version-specific adoption claim is made without a project-local dependency and lockfile check.

## Sources

- [Supabase documentation](https://supabase.com/docs)
- [Turso introduction](https://docs.turso.tech/introduction)
- [Turso CLI](https://docs.turso.tech/cli/introduction)
- [CrewAI documentation](https://docs.crewai.com/en/introduction)
- [PydanticAI documentation](https://ai.pydantic.dev/)
- [LangGraph overview](https://docs.langchain.com/oss/python/langgraph/overview)
- [Cloudflare Workers documentation](https://developers.cloudflare.com/workers/)
- [Hono documentation](https://hono.dev/docs/)
- [Drizzle ORM documentation](https://orm.drizzle.team/docs/overview)
- [TanStack Start documentation](https://tanstack.com/start/latest/docs/framework/react/overview)
