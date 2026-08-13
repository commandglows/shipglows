---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "3.1.0"
project: ShipGlows
created: "2026-08-13"
updated: "2026-08-13"
status: active
source_skill: 900-shipglows-core
scope: agent-runtime-awareness-and-mutation-approval
owner: Diane
confidence: high
user_story: "As an operator, I can invoke $shipglows context to establish exact global and project runtime facts, and every intentional mutation waits for my approval of a visible plan."
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/ShipGlows.DevServer.psm1
  - cli/windows/install-devserver.ps1
  - skills/references/agent-runtime-awareness.md
  - skills/references/mutation-plan-approval.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved one global environment document, one visible project ENVIRONMENT.md, registry-owned live state, and a retained read-only $shipglows context mode."
  - "Operator approved a universal explicit post-plan mutation gate."
next_step: "/103-sg-verify runtime awareness and mutation approval"
---

# Agent Runtime Awareness And Mutation Approval

## Runtime contract

- The full Windows installer writes `%USERPROFILE%\.shipglows\environment.md` idempotently with Windows, PowerShell, Codex CLI, Playwright, DevServer, and tool-surface facts.
- Every registered project has a visible, versioned `<project-root>\ENVIRONMENT.md` with a bounded ShipGlows block. Existing user content is preserved.
- The project document stores the durable server manager, assigned port, and canonical loopback URL. It is updated only when registration or a real port assignment changes those facts.
- The Windows DevServer registry remains the sole live-status authority. Start and stop do not rewrite project documentation merely to change status.
- The native Windows backend ignores Flox completely and resolves direct or nested launch targets only from supported application manifests.
- `$shipglows context` resolves the project from the current directory, reads both documents and the registry, distinguishes configured from callable tools, and never starts a replacement server or substitutes framework defaults.
- `open` uses the active registry entry and its persisted port.
- The installer migrates all registered projects and removes only the legacy `.shipglows/server.env` artifacts and exact Git exclude entries that ShipGlows managed.

## Mutation-approval contract

- Before every intentional state mutation, the agent displays `🧭 PLAN À VALIDER` with Objective, Scope, Actions, and Proofs.
- Only explicit approval given after that plan authorizes implementation. The initial imperative request is not approval.
- No spec or other persistent planning artifact is written before approval.
- Read-only discovery may precede approval.
- A material scope, behavior, risk, permission, data, destructive-effect, external-state, or proof change invalidates approval and requires a replacement plan.
- Micro-edits and server/process actions remain subject to the gate; their plan may be compact.

## Out of scope

- Dynamic capability snapshots, session hashes, TTLs, JSON schemas, Codex wrappers, inferred MCP/process discovery, and Linux runtime projection.

## Verification

- PowerShell parser checks for module, launcher, installer, and focused migration test.
- Project document preservation, idempotence, durable `3002` URL, live-status separation, and legacy cleanup scenarios.
- Scenario checks for initial imperative, explicit post-plan approval, material-plan change, micro-edit, and server-process mutation.
- Skill budget, metadata, runtime sync, focused contract tests, and `git diff --check`.
