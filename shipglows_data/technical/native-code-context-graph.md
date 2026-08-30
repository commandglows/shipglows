---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-30"
updated: "2026-08-30"
status: active
source_skill: 102-sg-start
scope: native-code-context-graph
owner: Diane
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - tools/code_context_graph.py
  - tools/test_code_context_graph.py
  - skills/references/context-quality-contract.md
depends_on:
  - artifact: skills/references/context-quality-contract.md
    artifact_version: "1.3.0"
    required_status: active
supersedes: []
evidence:
  - "Four deterministic unit tests cover graph construction, bounded queries, file invalidation and repeatable JSON output."
  - "The ContentGlows trash pilot indexed 983 files and resolved exact content-assets, video-timelines and status-API seeds without truncation."
next_review: "2026-09-30"
next_step: Measure the ContentGlows trash pilot and add only evidenced relationship types.
---

# Native Code Context Graph

ShipGlows can build a deterministic, repository-local graph of Python, Dart,
SQL and governed Markdown surfaces. The graph is a disposable discovery index:
Git, source code, specs and governed project documents remain authoritative.

## Commands

```powershell
python tools/code_context_graph.py --project-root C:\path\to\project build --output graph.json
python tools/code_context_graph.py --project-root C:\path\to\project query --graph graph.json --seed table:content_assets --max-depth 1 --max-nodes 80
python tools/code_context_graph.py --project-root C:\path\to\project stale --graph graph.json
```

`build` records content hashes, file/symbol/route/table/API-path nodes and
reproducible relationships. `query` returns a bounded neighborhood and reports
missing seeds or truncation. `stale` returns a failure status when a previously
indexed file changed or disappeared.

## Safety And Privacy

- The index stores identifiers, paths, line pointers and hashes, never source
  bodies, secrets, signed URLs or runtime payloads.
- Generated, dependency, VCS and local-cache directories are excluded.
- Query results are advisory. They never authorize a mutation, prove ownership
  or replace server-side access checks.
- Persisted graph output belongs in an ignored local cache unless a governed
  proof artifact explicitly requires a bounded redacted sample.

## ContentGlows Pilot Baseline

The 2026-08-30 trash pilot indexed 983 supported files into 9,947 nodes and
13,100 edges. Exact depth-one seeds found three owning files for
`content_assets`, five for `video_timelines`, and the Flutter API client for
`/api/status/content`, without truncation. Broad queries remain intentionally
bounded and expose `truncated: true` when their neighborhood exceeds the cap.

## Known Limits

- Python is parsed with the standard AST; Dart and embedded SQL use conservative
  deterministic patterns.
- Dynamic dispatch, generated routes and runtime dependency injection may be
  missed. Pilot verification must record those misses rather than treating the
  graph as complete.
- A changed or deleted indexed file invalidates its observations. New unindexed
  files require a rebuild and are not inferred by `stale`.
