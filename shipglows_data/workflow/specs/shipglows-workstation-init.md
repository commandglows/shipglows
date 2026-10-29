---
artifact: specification
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
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
next_step: Validate installed-session discovery and real init persistence on explicitly authorized devices.
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
- Only detected agents' native global files use their existing managed updater;
  root discovery uses the local context pointer, with no second managed doctrine block.
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

## Approved extension, 2026-10-29

Operator approved the read-only audit's scope: reuse existing mechanisms, propagate
init to lightweight plugin/OpenCode entrypoints, select local/remote/consult/test
roles, guide browser/mobile and disposable hosts, and retain resumable progress.

Impact map: agent behavior remains owned by the router/reference; distribution
uses its existing plugin and repository entrypoints; Windows global instructions
retain `ShipGlows.AgentInstructions.psm1` as their sole writer; governance/help
documents those consumers. No new installer, shell command, authentication flow,
runtime readiness store or private-data transport is introduced.

Acceptance for this slice:
- `init resume` and optional role/lifetime choices preserve ordinary scopes.
- Existing environment diagnosis, root/channel state, native instruction updater,
  auth/tunnel tools and private-data restore remain canonical owners.
- The cache's versioned progress records workflow checkpoints only; existing live
  environment/registry evidence is re-read on resume, never inferred from a flag.
- Existing schema v1 hints migrate only after validation; stale/conflicting roots,
  foreign files, managed-marker conflicts and linked files block dependent writes.
- Browser-only hosts can finish consult guidance without local runtime/files;
  remote work identifies the execution host separately from the user device.
- iOS/iPadOS and other capability-limited devices receive guidance, not claims
  of a new native runtime. VM/container detection never implies disposability.
- The public lightweight entry remains usable without the complete corpus and
  does not fetch or execute an installer automatically.
- Source-only delivery; actual installs, session reloads and machine/user data
  remain untouched. No tests/lint/build without a further explicit request.

One coherent integration milestone: orchestration/reference and managed pointer,
distribution, role journeys and help/docs, independent source review and exact-scope commit.
Proof scenarios extend the prior list with v1 cache migration, legacy duplicate
blocks, unavailable Unix updater, pure-browser tablet, Android remote client,
persistent VM, explicitly disposable VM, and resume after an interrupted step.
Loading: device details remain in the init leaf, lightweight entry loads only its
portable reference, ordinary context/router paths gain no new required reads.

### Extension delivery evidence

Implemented in source: existing Windows writer owns the one development-environment
block and its optional cache pointer; canonical init reuses environment diagnosis,
root/channel resolution, remote/auth and explicitly selected restore owners. The
plugin has a bounded portable leaf; the repository OpenCode entry hands off to the
same canonical workflow. Role/lifetime choices, browser-only guidance, resumable
checkpoints and v1-to-v2 pointer migration are specified in the init leaf.

Independent read-only review found an arbitrary checkpoint-source dereference risk.
Corrected with strict shapes, fixed ID/owner map, no duplicates and independent
pointer resolution. Final source re-review found no remaining material issue.
Actual updater execution, cache migration, resume interruption, new-device journeys,
installed plugin discovery and memory persistence are not operationally verified.
No builds/lint/tests, installer, app launch, authentication or workstation init ran.
AGENT.md remains applicable; no managed app ENVIRONMENT.md, URL or backend changed.
README, help, installer/runtime/plugin technical docs and code-doc map are aligned.
