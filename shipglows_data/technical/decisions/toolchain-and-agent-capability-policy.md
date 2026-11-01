---
artifact: decision_record
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-11-01"
updated: "2026-11-01"
status: reviewed
source_skill: sg-docs
scope: "toolchain-and-agent-capability-policy"
owner: "Diane"
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
decision: "ShipGlows owns capability policy, resolution, activation and observed readiness above replaceable tool managers and MCP metadata sources."
rationale: "Native managers already acquire tools; ShipGlows must relate project needs to trusted versions, bounded permissions and actual agent availability while preserving reproducibility and repair."
consequences: "Machine provisioning, project tool selection, MCP activation and authentication remain separate responsibilities. Existing implementations converge incrementally; this decision does not activate another backend or MCP."
linked_systems:
  - cli/environment/
  - cli/windows/install-devserver.ps1
  - cli/windows/ShipGlows.MobileToolchain.psm1
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/installer-and-user-scope.md
  - skills/references/canonical-paths.md
depends_on: []
supersedes: []
evidence:
  - "Operator approval on 2026-11-01 follows a source-based review of the historical WinGet/mise/MCP architecture and the current environment control plane."
  - "cli/environment/mise_backend.py implements the bounded Windows Node 24/pnpm 10 pilot; install-devserver.ps1 owns machine provisioning and project-local agent MCP configuration."
  - "Official mise, WinGet Configure and MCP Registry documentation reviewed through Parallel on 2026-11-01 confirms backend-specific trust and the registry metadata boundary."
next_step: "Use this decision when changing environment adapters, tool inventories or agent capability activation."
---

# Toolchain And Agent Capability Policy

## Decision

ShipGlows owns the policy connecting project needs to tools and agent capabilities. Acquisition remains delegated to existing managers through bounded adapters. WinGet, mise and Dart Pub retain their appropriate roles; their selection is an implementation choice within that policy.

Keep these responsibilities independent:

| Responsibility | ShipGlows contract |
| --- | --- |
| Discovery | Identify project requirements and candidate packages or endpoints; discovery alone grants no execution authority. |
| Trusted resolution | Select official identity, version or endpoint, verification evidence, ownership and permitted scope. |
| Installation | Observe existing tools first, compute the missing state, install or reuse through the selected manager, then verify the result. |
| Activation | Expose only the capabilities selected for the project and supported by the current agent host. |
| Authentication | Track required authorization separately; installation and configuration never establish login or protected access. |
| Observation and repair | Report fresh evidence, identify drift and repair only owned state within authorized scope. |

Desired state, resolved plans and observed state remain distinct. A completed installation, a generated MCP configuration, an authenticated account and a callable tool are different evidence levels.

## Ownership Boundaries

- **Machine bootstrap** provisions shared managers, SDKs and reusable CLI installations. Installing once may retain several versions; each project selects its required version independently.
- **Project environment control** resolves declared requirements and locks, produces a bounded plan, and observes the selected executable. Project needs do not silently change the machine's default tool version.
- **Agent capability activation** selects local or remote MCP definitions per project and host. A shared installation does not imply global activation. Any deliberate global capability requires its own explicit policy.
- **Authentication and permissions** retain provider and resource boundaries independently of the CLI or MCP interface. Prefer the least authority sufficient for the task; recorded read-only intent must be supported by actual endpoint or permission enforcement.

A future shared inventory should express identity, version or endpoint, provenance and verification, installation ownership, project selectors, transport, authentication requirements, effective permissions and update/removal rules. This is a target contract, not a currently implemented unified schema.

## External Managers And MCP Metadata

Use WinGet for suitable Windows software and SDKs, mise for suitable isolated versioned toolchains, and native ecosystems such as Dart Pub where appropriate. Verify each selected backend and artifact; a manager's verification features do not automatically cover every package. Retain supported existing tools without silently taking ownership of them.

The official MCP Registry is an optional discovery and metadata input. ShipGlows retains a small curated set of approved definitions and policies. Registry publication does not approve server code, permissions, authentication or activation; registry data never becomes executable command input without trusted resolution. Metadata availability must not be required to run an already resolved approved configuration.

Prefer a purpose-built, callable MCP when it fits the task. Prefer CLI or API paths when they provide the required coverage, reproducibility or automation. The same resource and mutation authority applies to every interface.

## Installed Runtime And Development Source

Retain the installed runtime for clone-free operation, controlled updates and repair. Keep mutable state outside its managed payload. Resolve the developer source through the canonical root/channel rules; never infer it from a nearby checkout. Updating source does not prove that the installed command executes that revision.

Commands should make their effective runtime path, channel and version/source revision unambiguous. This is an experience requirement; this record does not claim that every current command exposes all four fields.

## Implementation Status At Adoption

- The Windows installer already uses native acquisition routes and a managed mise machine toolbox, and generates agent MCP configurations from project needs. These paths remain separate from the project environment engine.
- The documented executable project environment pilot covers Windows mise with locked Node 24 and pnpm 10. Other capabilities and backends must retain their existing refusal boundaries until implemented and verified.
- MCP definitions are currently curated in `ShipGlows.MobileToolchain.psm1`; there is no general official-registry integration in that path. Google Cloud CLI provisioning does not establish a managed Google Cloud MCP activation.
- The shared inventory, broader backend coverage and consistent runtime provenance display are incremental implementation directions, not delivery claims or an authorized migration in this record.

## References

- [Environment control plane](../architecture.md#reproducible-environment-control-plane)
- [Installer ownership and user scope](../installer-and-user-scope.md)
- [Canonical root resolution](../../../skills/references/canonical-paths.md)
- [mise backend architecture](https://mise.jdx.dev/dev-tools/backend_architecture.html)
- [WinGet Configure](https://learn.microsoft.com/en-us/windows/package-manager/winget/configure)
- [Official MCP Registry scope and trust](https://modelcontextprotocol.io/registry/about)
