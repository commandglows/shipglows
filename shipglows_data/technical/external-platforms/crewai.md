---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-crewai
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - skills/references/technical-docs-corpus.md
  - shipglows_data/technical/external-platforms/README.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.5.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against official CrewAI docs, GitHub releases, PyPI package metadata, and upgrade guide."
  - "Contentglowz Lab uses CrewAI as a core backend orchestration dependency, so CrewAI needs a global Freshness Gate source note."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# CrewAI Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for CrewAI freshness checks. Use it before relying on assumptions about CrewAI agents, crews, tasks, flows, tools, memory, knowledge, MCP integration, LiteLLM/OpenRouter behavior, structured outputs, tracing, CLI behavior, or release-driven migrations.

It does not replace CrewAI documentation. It records the source map and ShipGlows rules agents should use before changing CrewAI code, dependency posture, technical docs, or governance-root CrewAI usage notes.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Official docs entrypoint | https://docs.crewai.com/en/index |
| Concepts: agents, tasks, crews, flows, tools, memory, testing, CLI | https://docs.crewai.com/en/index |
| Docs index for agents | https://docs.crewai.com/llms.txt |
| Upgrade guide | https://docs.crewai.com/en/guides/migration/upgrading-crewai |
| GitHub repository | https://github.com/crewAIInc/crewAI |
| GitHub releases | https://github.com/crewAIInc/crewAI/releases |
| PyPI package metadata | https://pypi.org/project/crewai/ |

Freshness evidence on 2026-05-24:

- The official docs present CrewAI as an agents, crews, and flows framework with tools, memory, knowledge, structured outputs, guardrails, observability, MCP integration, and production architecture docs.
- The docs navigation includes core concepts for Agents, Tasks, Crews, Flows, Processes, Memory, Testing, CLI, Tools, Event Listeners, and Checkpointing.
- GitHub releases list 1.14.5 as latest stable on 2026-05-18 and 1.14.6a1 as a 2026-05-21 pre-release, with changes around agent executors, restore-from-state kickoff, Exa tool naming, status endpoint paths, task output handling, CLI extraction, tracing events, and security dependency bumps.
- PyPI lists `crewai` 1.14.5 released on 2026-05-18, requiring Python `>=3.10,<3.14` and providing extras such as `tools`, `litellm`, `mem0`, `qdrant`, and provider-specific integrations.

## Freshness Gate Use

Use `fresh-docs checked` for CrewAI decisions only after checking the relevant official CrewAI docs, GitHub release notes, PyPI metadata, and local dependency constraints.

Use `fresh-docs gap` when:

- CrewAI code changes but local `crewai` version, Python version, extras, and lockfile state were not checked.
- A task touches `Agent`, `Task`, `Crew`, `Process`, `Flow`, tools, memory, structured outputs, tracing, callbacks, or `crew.kickoff()` behavior without checking current docs.
- A project uses CrewAI as orchestration infrastructure but lacks a governance-root usage note.
- The code depends on LiteLLM, OpenRouter, Mem0, Exa, Firecrawl, MCP, or Composio through CrewAI and the related provider constraints were not checked.

Use `fresh-docs conflict` when current CrewAI docs or releases contradict local dependency pins, local docs, code patterns, or the planned implementation.

## ShipGlows Decision Rules

- Treat CrewAI as orchestration infrastructure, not a reason to wrap every Python function in an agent. Use CrewAI only where autonomy, tool choice, role separation, structured outputs, human review, memory, tracing, or multi-step collaboration are materially useful.
- Prefer explicit request-scoped LLM/provider construction for app-visible flows. Do not rely on ambient global provider secrets unless the project contract explicitly allows it.
- Keep `Agent`, `Task`, `Crew`, `Process`, and `Flow` imports unambiguous when other agent libraries are present.
- Treat `output_pydantic`, structured result parsing, task output restoration, and fallback parsing as version-sensitive behavior. Add regression tests around structured outputs.
- Treat tools as capability boundaries. Web fetch, scraping, filesystem, email, publishing, and MCP tools need input validation, permission boundaries, secret redaction, rate-limit assumptions, and failure envelopes.
- Treat memory and knowledge stores as data-retention surfaces. Do not enable persistent memory without documenting storage location, retention, tenancy, deletion, and privacy assumptions.
- Treat CrewAI releases as migration triggers when they mention executors, kickoff/status behavior, tool naming, output handling, memory, tracing, CLI packaging, security dependency bumps, or Python version support.
- For dependency upgrades, check transitive OpenAI/LiteLLM/Pydantic/Python constraints before changing version ranges.

## Common Project-Local Fields

A project using CrewAI should maintain `<governance-root>/shipglows_data/technical/platforms/crewai.md` when CrewAI drives production behavior, with:

- CrewAI role in the product: SEO agents, newsletter generation, publishing, memory, analysis, short content, social posts, or internal automation
- local `crewai` version range, lockfile state, Python version policy, and extras used
- agent/crew entrypoints and API routes that call them
- LLM/provider routing: OpenRouter, LiteLLM, user-scoped keys, platform keys, or route-specific providers
- tools exposed to agents, especially web fetch, Firecrawl, Exa, IMAP, publishing, storage, or MCP tools
- structured output policy and fallback parsing rules
- memory/knowledge/tracing/observability state
- validation commands and integration smoke tests
- security boundaries for prompts, tools, secrets, user data, and external network access

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store LLM API keys, OpenRouter keys, provider tokens, raw prompts containing secrets, raw customer content, cookies, OAuth tokens, or private provider logs in CrewAI docs.
- Treat agent tools as untrusted action surfaces. Validate inputs before provider clients are created and fail closed on unsafe URLs, unsupported routes, missing credentials, or unauthorized user actions.
- Treat memory, knowledge, traces, and callbacks as possible data-exfiltration surfaces. Redact or summarize sensitive evidence.
- Treat package upgrades as supply-chain sensitive because CrewAI commonly pulls AI, tool, telemetry, and provider dependencies.

## Validation

For global note changes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/crewai.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/crewai.md
```

For governance-root CrewAI usage notes:

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/platforms/crewai.md
rg -n "CrewAI role|LLM/provider|tools|memory|Validation|Maintenance Rule" shipglows_data/technical/platforms/crewai.md
```

## Reader Checklist

- `crewai`, `crewai.tools`, `Agent`, `Task`, `Crew`, `Process`, `Flow`, `kickoff`, `output_pydantic`, or CrewAI CLI/config found -> check for a governance-root CrewAI usage note.
- CrewAI dependency range, lockfiles, Python version, LiteLLM/OpenAI/Pydantic constraints, or extras changed -> route to `010-sg-technical deps` or `010-sg-technical migrate`.
- Agent tools changed -> verify input validation, provider credential scope, secret redaction, and failure envelopes.
- Structured output or fallback parsing changed -> run focused tests proving invalid/raw model output is handled safely.
- CrewAI release notes mention executors, kickoff/status behavior, output handling, CLI extraction, tool naming, memory, tracing, or dependency security -> compare against local code and docs.

## Maintenance Rule

Update this note when CrewAI agent/crew/flow semantics, tool APIs, memory/knowledge behavior, MCP integration, structured outputs, CLI packaging, Python version support, dependency/security posture, or ShipGlows CrewAI proof rules change. Review it at least monthly while CrewAI remains a core backend orchestration dependency.
