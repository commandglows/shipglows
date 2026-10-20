---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-20"
updated: "2026-10-20"
status: active
source_skill: 900-shipglows-core
scope: web-research-fallback
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - tools/shipglows_search.py
  - cli/shipglows-search.sh
  - cli/windows/ShipGlows.AgentInstructions.psm1
  - AGENT.md
depends_on: []
supersedes: []
evidence:
  - "Operator decision 2026-10-20: a provider out of credits must never stop research; fall through Firecrawl, Parallel, then native search."
next_review: "2027-01-20"
next_step: "Add further providers to shipglows-search only with an operator decision."
---

# Web Research Fallback

Load before any external web search or page read made by a skill or agent.

## Cascade

1. `doppler run --project dotfiles --config dev -- shipglows-search "<query>"`
   tries Firecrawl, then Parallel, and reports each attempt in `attempts`.
2. Exit 3 means every CLI provider failed or was skipped: use a discovered
   Firecrawl or Parallel connector that was not already tried.
3. Then use the agent's native web search and fetch tools.

Switch without asking the operator. Exhausted credits (HTTP 402), rate limits,
missing keys, network errors and unsupported filters are reasons to move on,
never a final answer. Report the provider that served the results only when it
matters to the answer.

## Limits

- Never print, pass or persist provider keys; keys come only from the Doppler
  `dotfiles/dev` scope.
- `shipglows-parallel` stays the tool for Extract, Task research and Monitor;
  `shipglows-search` covers search only.
- Relevance order from any provider is not a Google SERP position.
