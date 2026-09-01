---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-08-30"
updated: "2026-09-01"
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
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "The 2026-09-01 closure regression proves that graph and capsule output remain advisory: documentation classification revalidates exact Git paths against the canonical code-docs map and falls back canonically when context is stale or incomplete."
  - "Twelve deterministic unit tests cover graph construction, incremental updates, bounded explained queries, freshness diagnostics, migration, locking and path isolation."
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
python tools/code_context_graph.py --project-root C:\path\to\project update --graph graph.json
python tools/code_context_graph.py --project-root C:\path\to\project query --graph graph.json --seed table:content_assets --max-depth 1 --max-nodes 80
python tools/code_context_graph.py --project-root C:\path\to\project stale --graph graph.json
python tools/code_context_graph.py --project-root C:\path\to\project status --graph graph.json
python tools/code_context_graph.py --project-root C:\path\to\project explain --graph graph.json --seed table:content_assets
python tools/context_capsule.py --graph graph.json --task "content assets status" --accepted-outcome "Find owning surfaces" --seed table:content_assets
```

Schema 2 records per-file observations so `update` reparses only new or changed
supported files, removes deleted observations and reports deterministic
same-content renames. Atomic replacement prevents partial graph writes. `query`
and `explain` attach a reason to every selected node; `status` reports only
aggregate freshness and identity state. Older schemas rebuild explicitly.

`context_capsule.py` ranks explicit seeds, bounded task terms and graph edges.
It emits authority, certainty, freshness, reason codes, gaps and truncation,
without automatically persisting task text. Optional evaluation files contain
aggregate counts only: recall, misses, noise, selection, fallback and bounds.

## Safety And Privacy

- The index stores identifiers, paths, line pointers and hashes, never source
  bodies, secrets, signed URLs or runtime payloads.
- Generated, dependency, VCS and local-cache directories are excluded.
- Query results are advisory. They never authorize a mutation, prove ownership
  or replace server-side access checks, Git changed-path evidence, or the
  canonical code-to-documentation map.
- Persisted graph output belongs in an ignored local cache unless a governed
  proof artifact explicitly requires a bounded redacted sample.
- Cache identity includes branch, HEAD and a one-way worktree identifier; it
  never stores an absolute root path.

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
- TypeScript, Vue and dynamic runtime relationships remain unsupported. Status,
  capsule gaps and targeted canonical fallback expose that limitation rather
  than claiming completeness.
- Closure consumers refresh the bounded capsule after branch, HEAD, staged or
  dirty state changes. If that view is stale, absent, truncated, unsupported,
  or misses a changed path, they inspect the exact canonical source and
  `code-docs-map.md` before classifying documentation impact.

## 2026-08-30 Industrialization Baseline

The ShipGlows read-only runs indexed 1,238 files, 4,288 nodes and 6,423 edges in
about 2.5–3.6 seconds; a no-change incremental refresh took about 1.9 seconds.
The three expected native context owners reached 1.0 recall (3/3), with 8
additional selected paths and explicit truncation. The CommunityGlows
contrast run indexed 132 supported governed files, 422 nodes and 527 edges;
the manifest owner reached 1.0 recall through `targeted_filename_fallback`,
with 17 additional selected paths and explicit truncation/unsupported-language
gaps. TypeScript/Vue relationships remained unsupported. ContentGlows retained
its accepted 983-file / 9,947-node / 13,100-edge baseline and was not rebuilt.
Both external repositories had identical Git status before and after the run.
