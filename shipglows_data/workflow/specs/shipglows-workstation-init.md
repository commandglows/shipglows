---
artifact: specification
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-10-29"
updated: "2026-10-29"
status: implemented
source_skill: 900-shipglows-core
scope: workstation-init-skill
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems: [skills/000-shipglows/SKILL.md, skills/references/workstation-initialization.md]
depends_on: []
supersedes: []
evidence: ["Operator approved workstation initialization, persistent root pointers, agent instructions and context refresh on 2026-10-29."]
next_step: Execute init on an authorized workstation to obtain runtime and host-memory evidence.
---

# Workstation initialization

## Outcome and scope

`$shipglows init` prepares an arriving agent on a new or existing computer:
resolve the canonical installation, persist verified non-secret pointers in local
agent context and permitted memory, inspect tooling and summarize actionable gaps.
This change defines an agent-executed skill mode, not a new shell command or installer.
Reuse the existing installer, global agent files and read-only context refresh.
No installer, application runtime, credentials or this machine's configuration is
changed while implementing this mode.

## Acceptance and authority

- Init is discoverable in the public router, registry, help and README.
- One conditional reference owns the procedure; unrelated modes do not load it.
- Process/user environment and validated channel remain authoritative. Cached paths
  accelerate exact-file reads and never override changed authoritative roots.
- Root, platform, channel and context pointers are recorded locally without secrets,
  project inventories, transient runtime state or personal machine paths in Git.
- Only detected agents' native global files receive a delimited root-pointer block;
  unrelated text survives and reruns update rather than duplicate the block.
- Host memory writes obey the current host's supported mechanism and policy;
  unavailable memory is reported separately from durable local context.
- Missing installation, malformed/conflicting pointers and unsupported tools have
  explicit outcomes. Missing installation never prompts a full-disk search.
- Installation and account actions retain the existing installer/user gates.
- Init refreshes context after its permitted changes, with evidence tiers intact.

## Proof and loading

Scenario-first source review: new machine without runtime; healthy linked checkout;
stale cached root; conflicting roots; existing custom global instructions; repeated
init; unavailable memory writer; missing SDK/auth; project without selected surface.
Review registration and all conditional links. No lint, tests or builds under the
operator's standing restriction. Independent source review covers routing/authority;
new-machine execution and host-specific memory persistence remain separate proof.

Loading delta: the router gains one init-only reference. No additional reference is
loaded for context or ordinary work. The public wrapper stays within its existing
root/engine loader; missing-root guidance is an early explicit-init branch.

## Delivery evidence

Implemented 2026-10-29: public init route/registry, one conditional procedure,
README, help catalogues, technical runtime documentation and code-docs mapping.
Independent read-only source review found three issues: help ambiguity, agents-scope
cache contract and native-file symlink preservation. All three corrected in source.
No tests, lint or builds run. No workstation initialization executed during feature
implementation. New-session discovery, real file/memory persistence and new-machine
installer execution remain unverified operational evidence, not completion claims.
AGENT.md and ENVIRONMENT guidance remain applicable without edits: no launcher,
toolchain, managed URL or local runtime configuration changed.
