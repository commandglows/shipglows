---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-15"
updated: "2026-09-15"
status: active
source_skill: 001-sg-build
owner: Diane
scope: benchmark-harness
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - tools/benchmark_harness.py
  - tools/benchmark-result.schema.json
depends_on: []
supersedes: []
evidence:
  - "2026-09-15: focused unit tests and example suite smoke run passed."
next_review: "2026-12-15"
next_step: none
---

# Language-agnostic benchmark harness

`tools/benchmark_harness.py` measures arbitrary subprocess commands without requiring a language-specific adapter. A JSON suite declares commands as argument arrays; the harness writes newline-delimited JSON records conforming to `tools/benchmark-result.schema.json`.

## Run a suite

```powershell
python tools/benchmark_harness.py run tools/benchmark-suite.example.json --output .benchmarks/results.jsonl
```

Each benchmark supports `id`, `command`, optional `cwd`, `env`, `warmup`, `iterations`, `timeout_seconds`, and free-form `tags`. Paths in `cwd` are relative to the suite file. Commands are arrays and are never passed through a shell, so quoting is portable and shell interpolation is avoided.

Every execution receives a UUID. Sample records include timing in integer nanoseconds, phase, iteration, status, exit code, timeout state, command, working directory, tags, timestamp, and basic host identity. Warmups are recorded but excluded from summaries.

## Aggregate results

Each `run` appends a summary for its own measured samples. To recompute summaries from a JSONL stream:

```powershell
python tools/benchmark_harness.py summarize .benchmarks/results.jsonl --output .benchmarks/summaries.jsonl
```

Summaries are grouped by suite, benchmark, and execution. They contain sample and success counts, success rate, and duration minimum, maximum, mean, median, p95, and population standard deviation. Use `--append` on `run` to retain multiple executions in one stream for later comparison.

The process exits non-zero when a measured command fails or times out. Command stdout and stderr are intentionally not persisted: result files remain compact and avoid accidentally collecting secrets or large logs.
