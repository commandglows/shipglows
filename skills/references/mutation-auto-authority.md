---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: active
source_skill: 900-shipglows-core
scope: mutation-auto-authority
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems: []
depends_on: []
supersedes: []
evidence:
  - "Verbatim conditional sections extracted from mutation-plan-approval 1.17.0."
next_review: "2026-10-05"
next_step: none
---

## Auto-session authority

An explicit `shipglows auto` invocation is authority for one bounded autonomous
session of safe, reversible, current-project local file creation and editing.
This is a narrow first-message exception so the credit-window mode can continue
without a plan/approval round trip for every selected candidate. Quoted text,
discussion about the mode, any execution posture tag alone, an implicit inference, or an
invocation aimed at an unresolved project does not activate it.

At activation, freeze the current Git top-level when available, otherwise the
already resolved managed project root. This authority covers only project edits
and ignored auto-coordination claims below that root. Reading canonical
ShipGlows contracts or current official sources outside it does not authorize
outside-project edits. Switching repositories, cloning, creating or entering a
different worktree, or following a roadmap item into another project is outside
the authority.

The authority applies only while every selected candidate:

- is grounded in existing roadmap, planning, spec, backlog, architecture,
  code-risk, security, or compliance evidence;
- has resolved current-project ownership and no collision with unrelated dirty
  work;
- is limited to non-destructive, readily reviewable local file edits;
- loads and obeys `skills/references/no-local-execution-policy.md`;
- remains inside the supplied scope or current project and preserves governed
  product, architecture, data, and security decisions;
- records its result as `implemented — unverified` with deferred proof.

The same invocation authorizes bounded subagents dispatched by `708-sg-auto`
when their mission is independently useful and explicitly carries the frozen
root, mandatory nolocal policy, owned paths, forbidden paths, reasoning choice,
and stop conditions. It does not authorize agents created merely to consume
credits. Parallel writes still require ready non-overlapping Execution Batches;
cross-conversation claims make ownership visible but never widen it.

This authority never permits destructive or irreversible changes; deletion;
credential, secret, permission, auth-policy, billing, payment, production,
tenant, or private-data mutation; dependency installation or upgrade; builds,
tests, lint, typechecks, servers, browsers, containers, migrations, or runtime
workloads; commits, branches, worktrees, tags, pushes, pull requests, releases,
deployments, publication, messages, or any external write. It also never permits
the auto run to modify its own authority, no-local policy, agent permissions, or
equivalent safety guardrails.

When one candidate reaches an excluded boundary, skip it and continue another
safe candidate. Stop the whole session when the project is unresolved, no safe
candidate remains, the platform/horizon ends, or continuing would require a
material product/security/data decision absent from governed truth. Never widen
the authority merely to keep the session busy.

`#local`, `#nolocal`, and `#ci` remain subject to the ordinary approval path and
grant no mutation authority. The legacy `shipglows nolocal <objective>` alias
does the same. `shipglows auto #nolocal` and legacy `shipglows auto nolocal` are
redundant spellings of the same bounded Auto-session authority; no `#local` or
legacy `local` override exists. `#ci` never authorizes push, dispatch, remote
execution, deployment, or another external write.

