---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: ShipGlows
created: "2026-09-02"
created_at: "2026-09-02 00:21:14 UTC"
updated: "2026-09-02"
updated_at: "2026-09-02 00:33:39 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5.6 Codex
scope: skill-integration
owner: Diane
user_story: "As a ShipGlows agent working on an Obsidian plugin, I want the skill corpus to route me to the specialized build, vault-sync, and disposable Lab workflows so that I do not treat the plugin as a generic web project or put personal vault data at risk."
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/
  - AGENTS.md
  - shipglows_data/technical/operator-guides/
  - cli/windows/
depends_on:
  - artifact: shipglows_data/workflow/specs/shipglows-obsidian-local-lab.md
    artifact_version: "1.0.4"
    required_status: ready
supersedes: []
evidence:
  - "The Windows runtime, packaging, capability declaration, focused tests, and operator guide already implement the specialized Obsidian workflow."
  - "The skill corpus contains no Obsidian reference or owner directive, while the browser Extension Lab has both."
  - "The operator approved completing the skill-corpus integration on 2026-09-02."
next_step: none
---

# Spec: ShipGlows Obsidian Skill Integration

## Title

ShipGlows Obsidian Skill Integration

## Status

ready

## User Story

As a ShipGlows agent working on an Obsidian plugin, I want the skill corpus to route me to the specialized build, vault-sync, and disposable Lab workflows so that I do not treat the plugin as a generic web project or put personal vault data at risk.

## Minimal Behavior Contract

When an agent is asked to develop, diagnose, or verify an Obsidian plugin, the owning skill identifies the specialized surface, loads one shared Obsidian workflow reference, and chooses the correct proof path. Inspection never installs dependencies or runs repository scripts. A `build-required` result requires the reviewed project build command before retrying the Lab. Persistent synchronization uses only an explicitly configured vault; isolated loading uses the disposable Lab and never a personal vault. The corpus never equates build success, artifact copy, host loading, interaction, or BRAT publication.

## Success Behavior

- Development routes use the plugin's reviewed build/watch workflow and keep vault synchronization explicit.
- Diagnosis and verification use the disposable Lab only after valid local artifacts exist.
- Agents report artifact, host-load, interaction, diagnostic, and cleanup states separately.
- The operator guide index exposes the Obsidian Lab alongside the browser Extension Lab.

## Error Behavior

- Missing or stale artifacts produce `build-required` with an actionable reviewed-build step.
- Missing vault configuration never triggers vault discovery or automatic selection.
- Lab isolation failure stops before targeting a personal profile or vault.
- Missing host-load or interaction proof remains partial rather than being reported as ready.

## Problem

The runtime and documentation implement Obsidian support, but the skills that own development, bug diagnosis, and verification do not reference it. A fresh agent can therefore miss the specialized workflow even though the CLI supports it.

## Solution

Add one shared agent reference for Obsidian plugin work, link it from the few public owner skills that need it, align the repository agent instructions, and index the existing operator guide. Keep procedural detail in the shared reference and concise trigger/stop language in owner skills.

## Scope In

- Shared Obsidian plugin workflow reference.
- Conditional directives in development, bug, and verification skills.
- Repository agent instructions for Obsidian plugins.
- The canonical Windows agent-instruction generator and its focused contract test.
- Operator-guide index entry.
- Focused mechanical checks for discovery, safety language, and link integrity.

## Scope Out

- Runtime classifier, Lab runner, packaging, or CLI behavior changes; only the canonical agent-instruction text generator is in scope.
- Obsidian installation or personal vault mutation.
- Automatic builds, dependency installation, GitHub releases, BRAT publication, or community-store submission.
- A new public skill or command.

## Constraints

- Shared doctrine owns repeated workflow semantics; owner skills contain only activation-critical routing.
- Browser-extension behavior remains unchanged.
- Instructions distinguish a configured development vault from a disposable Lab vault.
- Local separation is not described as an OS sandbox.

## Test Contract

- Proof path: scenario-first.
- Mechanical proof: focused searches confirm all intended owners link the shared reference and forbidden claims are absent.
- Structural proof: metadata lint and skill budget checks pass for every changed skill/reference.
- Runtime proof: not required because runtime behavior is unchanged and already covered by its focused Windows tests.
- Manual proof: read the resulting route as a fresh agent for build-required, configured-vault, disposable-Lab, and BRAT-boundary scenarios.

## Dependencies

- Existing Obsidian classifier and Lab capability.
- Existing Obsidian operator guide and runtime documentation.
- Existing browser Extension Lab reference as a placement precedent.

## Invariants

- No personal vault is discovered, selected, written, or opened without an explicit declared target and authorization.
- Inspection and Lab commands never imply dependency installation or repository-script execution.
- Build success is not host-load proof; host load is not interaction proof; the Lab is not BRAT publication.
- `s start` and `s obsidian-lab` remain distinct workflows.

## Links & Consequences

- Upstream: runtime classifier, project descriptor, build/watch workflow, artifact freshness, and Lab capability.
- Downstream: development, bug diagnosis, verification, agent instructions, and operator discovery.
- Revalidation: public skill routing, metadata, context budgets, and browser Extension Lab non-regression by unchanged reference.

## Documentation Coherence

- Add the missing Obsidian entry to the operator-guide index.
- Keep runtime details in the existing runtime documentation and operator guide.
- Add agent-facing workflow semantics only to the shared skill reference and concise owner directives.

## Edge Cases

- Plugin detected but no build artifacts exist.
- Build-only project without a watch script.
- Multiple personal vaults exist, but none is explicitly configured.
- A configured development vault exists while the requested proof should remain isolated.
- Plugin loads but emits diagnostics or lacks the requested command.
- BRAT-ready files exist without any publication authorization.

## ZOMBIES Coverage

- Z: no artifact or no declared vault fails actionably without personal-data access.
- O: one plugin follows one reviewed build and one selected proof workflow.
- M: multiple vaults are never enumerated or guessed.
- B: artifact freshness, minimum host capability, and cleanup boundaries stay explicit.
- I: owner skill to shared reference to CLI command remains discoverable.
- E: build, load, interaction, diagnostics, and cleanup failures remain distinct.
- S: approved local plugin code only; no hostile-code sandbox or publication claim.

## OWASP Security Gate

- A01/A03/A05/A08/A09: explicit target authorization, structured commands, safe configuration, artifact integrity, and bounded diagnostics.
- Trust boundary: approved plugin code runs with the Windows account's permissions; the Lab isolates Obsidian data paths but not the operating system.
- Sensitive data: personal vault content, credentials, and note payloads are never requested or logged by the agent workflow.

## Implementation Tasks

1. Create the shared Obsidian workflow reference with triggers, state model, build/vault/Lab split, BRAT boundary, safety stops, and validation semantics.
2. Add concise conditional routes to development, bug, and verification owners.
3. Align repository agent instructions with the same explicit-build and personal-vault protections.
4. Add the Obsidian guide to the operator-guide index.
5. Add or extend one focused mechanical contract test and run scoped validation.
6. Update the spec history and complete ordinary Git delivery to the canonical integration branch.

## Acceptance Criteria

- [x] A fresh agent can discover the Obsidian workflow from development, bug, and verification intents.
- [x] `build-required` explicitly requires a reviewed project build command before Lab retry.
- [x] Persistent synchronization requires one explicitly configured vault; the Lab always uses disposable data.
- [x] Build, copy, host load, interaction, diagnostics, cleanup, and publication remain distinct states.
- [x] No instruction authorizes dependency installation, personal-vault discovery, implicit publication, or an OS-sandbox claim.
- [x] The operator-guide index includes the existing Obsidian Lab guide.
- [x] Focused contract, metadata, and skill-budget validations pass.

## Test Strategy

- Scenario contract: missing artifact, configured vault, disposable Lab, diagnostic failure, and BRAT boundary.
- Static integration: exact links from intended owners and the repository instruction layer.
- Governance: metadata lint and affected-skill budget checks.
- Regression: browser Extension Lab instructions remain unchanged.

## Risks

- Duplicated instructions may drift: keep detail in one shared reference.
- Over-broad routing may run Obsidian for generic web projects: trigger only on specialized classification/evidence.
- "Isolated" may be misread as secure sandboxing: retain the explicit Windows-account limitation.
- An agent may confuse validation with publication: state the BRAT boundary in the shared reference.

## Execution Notes

- First reads: browser Extension Lab reference, target owner skills, repository agent instructions, Obsidian operator guide, and skill validation tooling.
- Write topology: delegated sequential or main-only because the owner directives and shared reference are semantically coupled.
- Stop if implementation requires runtime behavior, personal vault access, installation, publication, or a new public invocation.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-02 00:21:14 UTC | 100-sg-spec | GPT-5.6 Codex | Formalized the approved skill-corpus integration from the completed audit. | drafted | Run readiness review. |
| 2026-09-02 00:21:14 UTC | 101-sg-ready | GPT-5.6 Codex | Verified autonomous scope, safety boundaries, ordered work, consequences, and scenario-first proof. | ready | Implement the skill integration. |
| 2026-09-02 00:21:14 UTC | 102-sg-start | GPT-5.6 Codex | Added the shared Obsidian workflow, three public-owner routes, managed agent instructions, guide index entry, and focused contract. | implemented | Run standard verification. |
| 2026-09-02 00:21:14 UTC | 103-sg-verify | GPT-5.6 Codex | Verified scenario contracts, Windows instruction generation, public-owner coherence, metadata, budgets, diff integrity, and linked runtime visibility. | verified | Close the verified integration. |
| 2026-09-02 00:21:14 UTC | 104-sg-end | GPT-5.6 Codex | Reconciled skill, agent, operator-guide, and spec documentation; classified public changelog impact as internal-only. | closed | Ship to canonical dev. |
| 2026-09-02 00:33:39 UTC | 005-sg-ship | GPT-5.6 Codex | Delivered commit `81fa02a` through PR #83 after both required gates passed and merged it into `dev` as `541d102`. | shipped | None. |

## Current Chantier Flow

- `sg-spec`: done, reviewed contract created.
- `sg-ready`: passed.
- `sg-start`: complete.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: shipped through PR #83 to `dev`.

Next step: none. The source checkout is linked, so a new agent session loads the updated public skills without reinstalling the corpus.
