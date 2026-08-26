---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-26"
status: reviewed
source_skill: sg-docs
scope: platform-usage-hetzner
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/technical/architecture.md
  - shipglows_data/technical/README.md
  - Hetzner Cloud
depends_on: []
supersedes: []
evidence:
  - "2026-08-26 read-only Hetzner Cloud API inventory verified both server types, locations, images, labels, firewall attachment, and protection state."
  - "2026-08-26 SSH proof verified the managed-workspace host CPU, memory, disk, architecture, operating system, and healthy systemd state."
  - "2026-08-26 operator decision retains both VMs and assigns the larger host to managed-workspace execution."
next_review: "2026-09-26"
next_step: "/sg-engineering architecture managed workspaces"
---

# Hetzner Project Usage

## Purpose

This is the canonical internal record for ShipGlows-owned Hetzner Cloud compute. It separates verified infrastructure from the managed-workspace architecture that is still planned, and it deliberately excludes IP addresses, API tokens, project identifiers, private key material, and raw provider output.

## Current Topology

| Host | Verified capacity | Location | Current responsibility | State |
| --- | --- | --- | --- | --- |
| `shipglows-cx23` | CX23, shared x86, 2 vCPU, 4 GB RAM, 40 GB disk, Ubuntu 24.04 | Falkenstein (`fsn1`) | Existing ShipGlows test/runtime host; retain its current workloads until they are inventoried and intentionally migrated | `verified — retained` |
| `shipglows-workspaces-pilot` | CX43, shared x86, 8 vCPU, 16 GB RAM, 160 GB disk, Ubuntu 24.04 | Nuremberg (`nbg1`) | Dedicated execution host for ShipGlows-managed project workspaces | `verified — provisioned; workspace runtime not yet implemented` |

The two hosts form separate operational planes. The smaller CX23 preserves existing runtime continuity. The CX43 is the bounded workspace execution plane and must not silently absorb CX23 workloads or public production hosting.

## Hosting Boundaries

- A project can be continuously supervised without keeping every build, development server, or coding-agent process running concurrently.
- Public production deployments remain on the provider selected for each product, such as Vercel, unless a later approved architecture decision moves a specific workload.
- The CX43 owns project checkouts, development tooling, controlled background maintenance, and isolated interactive Codex/terminal/Neovim sessions once that runtime is implemented.
- The CX23 remains a compatibility and existing-workload host during the transition. Its workloads must be inventoried before its role is narrowed, migrated, or retired.
- Neither host is a backup for the other until backup and recovery behavior is explicitly implemented and verified.

## Managed-Workspace Execution Model

Status: `planned — not yet implemented`.

The accepted direction is process-level isolation with one Unix identity and bounded systemd/cgroup resources per project, shared machine-level toolchains and pnpm content storage, and a queue that limits concurrent builds or heavy agent jobs. Rootless containers remain an escalation path for untrusted or unusually risky commands rather than the default unit for every project.

Project activity and process concurrency are intentionally different concepts: all managed products may remain active business concerns and receive recurring checks, while resource-heavy execution is scheduled according to measured CPU, memory, and disk pressure. No fixed concurrency limit is considered verified until representative workloads have been measured on the CX43.

## Access And Protection

- Routine infrastructure inspection uses a local read-only Hetzner CLI context.
- Read/write API tokens are temporary provisioning credentials. Enter them only through an interactive local prompt, remove their local context after the operation, and revoke them in Hetzner after remote changes are complete.
- The CX43 has one attached Hetzner Cloud Firewall rule allowing inbound TCP port 22 for SSH. No application ports are approved at this stage.
- SSH access was verified with the registered public key; private key material stays on the operator machine.
- Delete and rebuild protection are enabled on the CX43.
- The 2026-08-26 inventory found no attached Cloud Firewall on the CX23. Treat CX23 network hardening as a follow-up audit, not as a proven equivalent of the CX43 posture.

## Cost Envelope

Pricing snapshot verified on 2026-08-26 through the Hetzner Cloud API, assuming two billed primary IPv4 addresses and 20% VAT:

| Resource | Monthly net snapshot | Estimated monthly gross |
| --- | ---: | ---: |
| CX23 plus IPv4 | EUR 5.99 | EUR 7.19 |
| CX43 plus IPv4 | EUR 16.49 | EUR 19.79 |
| Combined | EUR 22.48 | approximately EUR 26.98 |

This is a planning envelope, not an invoice guarantee. Recheck current provider pricing, VAT, backups, volumes, snapshots, traffic, and other billable resources before resizing or forecasting.

## Evidence Route

- Resource inventory: `hcloud` with the local read-only context; report names, types, states, and protection posture without printing addresses or private provider data.
- Guest proof: SSH with the registered key, followed by bounded OS, CPU, memory, disk, and service-state checks.
- Billing truth: Hetzner Console invoice/project billing plus current server-type and primary-IP pricing.
- Production truth: each project's own hosting-provider documentation and deployment evidence; Hetzner workspace state does not prove a product is deployed.

## Official Provider Sources

- [Cloud servers overview](https://docs.hetzner.com/cloud/servers/overview/)
- [Cloud Firewalls overview](https://docs.hetzner.com/cloud/firewalls/overview/)
- [Generating an API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)
- [Infrastructure price adjustments](https://docs.hetzner.com/general/infrastructure-and-availability/price-adjustment/)

Freshness verdict: `fresh-docs checked` on 2026-08-26. The official pages were reachable, and live project/resource claims were verified through the Hetzner Cloud API and SSH rather than inferred from vendor marketing.

## Failure Modes

- Treating all projects as simultaneous heavy processes -> memory pressure and unstable builds; preserve queued execution and measure before raising concurrency.
- Treating the CX43 as public production by default -> mixed blast radius and unclear recovery ownership; keep production provider-specific.
- Reusing a provisioning token -> unnecessary project-wide write exposure; revoke temporary credentials after the bounded operation.
- Recording an IP address or token in governance -> sensitive infrastructure leakage; keep identifiers and secrets out of tracked docs.
- Assuming the CX23 and CX43 share the same firewall posture -> false security claim; audit and harden each host independently.
- Treating shared vCPU capacity as dedicated performance -> unreliable capacity promise; use observed saturation and queue latency for scaling decisions.

## Reader Checklist

- Hetzner server, location, size, firewall, protection, backup, volume, or billing state changed -> update this note from redacted provider evidence.
- CX23 workload ownership changed -> update its responsibility and the architecture overview in the same workstream.
- Managed-workspace isolation became implemented -> replace planned language with focused implementation and security proof.
- A project moves production onto Hetzner -> create or update the project-specific deployment and recovery contract; do not broaden this workspace note implicitly.
- Cost or capacity assumptions drive a decision -> refresh live pricing and measured host utilization first.

## Maintenance Rule

Update this document whenever the Hetzner inventory, host responsibilities, workspace execution model, access policy, security posture, cost envelope, evidence route, or provider-source freshness changes.
