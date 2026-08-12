---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-12"
updated: "2026-08-12"
status: active
source_skill: 900-shipglows-core
scope: canonical-runtime-and-private-roots
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/canonical-paths.md
  - tools/
depends_on:
  - artifact: "skills/references/canonical-paths.md"
    artifact_version: "2.1.0"
    required_status: active
supersedes: []
evidence:
  - "The 2026-08-11 runtime decision separates installed runtime, mutable state, private data, and inspiration repositories."
  - "Private corpora must remain outside public repositories and plugin caches."
next_review: "2026-09-03"
next_step: "/103-sg-verify runtime and private root isolation"
---

# Canonical Runtime And Private Roots

Load this leaf only when work needs a local runtime, private corpus, inspiration library, or legacy compatibility input.

## Root Map

- Mutable local service state: `$SHIPGLOWS_RUNTIME_DIR`, defaulting to the current user's `.shipglows/state` directory.
- Durable private data: `$SHIPGLOWS_PRIVATE_DATA_DIR`, defaulting to `.shipglows/data` under the current user directory. A supported parent override such as `$SHIPGLOWS_PRIVATE_DIR` may supply the `.shipglows` parent where the owning private-data contract allows it.
- Private design inspiration: `$SHIPGLOWS_INSPIRATION_LIBRARY_DIR`, defaulting to `.shipglows/design-inspiration-library` under the current user directory.
- Legacy compatibility input: `$SHIPGLOWS_DATA_DIR`, defaulting to `shipglows_data` under the current user directory. It is read-only historical input, never active project truth.

## Isolation And Portability

- Keep mutable state, private data, and inspiration outside public project repositories, runtime installation files, and plugin caches.
- Treat overrides as data, never executable shell code. Normalize an absolute path, preserve spaces, and reject traversal outside the selected root.
- Use platform-native path APIs. `${VAR:-default}` is contract notation, not a requirement to invoke a POSIX shell on Windows.
- Do not copy secrets, raw private sources, credentials, or proprietary inspiration assets into public evidence or governance artifacts.
- A missing private root is a visible configuration or availability gap. Do not silently fall back to the project repository or another sibling directory.
