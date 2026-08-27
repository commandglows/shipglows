---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-08-26"
updated: "2026-08-27"
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
  - "2026-08-27 operator decision establishes separate runtime and managed-workspace roles while keeping operational inventory in the private operator repository."
  - "Provider and guest evidence verified that both logical roles have active compute, but public documentation intentionally omits provider identifiers, endpoints, location, capacity, protection details, and pricing."
next_review: "2026-09-27"
next_step: "/sg-engineering architecture managed workspaces"
---

# Hetzner Project Usage

## Purpose

This public-safe note records only the durable architecture boundary for ShipGlows-owned Hetzner compute. Machine identifiers, endpoints, location, capacity, cost, access configuration, firewall posture, and recovery details belong to the private operator inventory and must not be copied here.

## Logical Topology

| Logical role | Responsibility | State |
| --- | --- | --- |
| `sg-runtime-01` | Lightweight public and API runtime continuity, including product APIs assigned to ShipGlows-operated compute | Retained; workload health is verified per product rather than inferred here |
| `sg-workspaces-01` | Managed project checkouts, builds, maintenance jobs, controlled background processes, and interactive Codex/terminal/Neovim sessions | Compute is available; the isolation runtime remains planned |

The logical names describe roles, not provider resource names. Public product deployments remain provider-specific and are not implied by a managed workspace.

## Hosting Boundaries

- Heavy builds and interactive coding sessions belong to `sg-workspaces-01`, not the runtime plane.
- Workspace activity is scheduled and resource-bounded; an active project does not require every development process to run continuously.
- Canonical customer data belongs in managed product datastores, not on workspace disks.
- The two roles do not provide backup or failover for one another until recovery behavior is explicitly implemented and verified.
- Rootless containers remain an escalation path for untrusted workloads; the planned default is per-project Unix identity plus systemd/cgroup limits and queued heavy execution.

## Public and Private Documentation Boundary

Public documentation may state logical roles, architectural invariants, implementation status, and product-independent failure modes. The private operator inventory owns:

- provider resource names and exact machine specifications;
- regions, images, endpoints, access aliases, and protection posture;
- current pricing and billing assumptions;
- product-to-host assignments and operational recovery notes.

Neither public nor private Git may contain IP addresses, API tokens, private keys, credentials, or customer data. Live endpoints are resolved through provider tooling or machine-local SSH configuration.

## Evidence Route

- Resource truth comes from authenticated provider inventory without copying sensitive output into Git.
- Guest truth comes from bounded SSH checks of operating-system, resource, and service state.
- Billing truth comes from the provider console and current invoices.
- Production truth comes from each product's deployment and health evidence; workspace presence is never sufficient proof.

## Official Provider Sources

- [Cloud servers overview](https://docs.hetzner.com/cloud/servers/overview/)
- [Cloud Firewalls overview](https://docs.hetzner.com/cloud/firewalls/overview/)
- [Generating an API token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)

## Failure Modes

- Treating all projects as simultaneous heavy processes -> unstable builds; preserve queued execution and scale from measured saturation.
- Treating the workspace plane as public production by default -> mixed blast radius and unclear recovery ownership; keep production provider-specific.
- Persisting endpoints or credentials in Git -> infrastructure exposure; keep discovery and secrets machine-local.
- Assuming equivalent security posture across roles -> false assurance; verify and harden each machine independently in the private inventory.

## Reader Checklist

- A machine or role changes -> update the private inventory first, then update this note only if the public architecture boundary changed.
- Workspace isolation becomes implemented -> replace planned language with focused implementation and security proof.
- A product moves production onto ShipGlows-operated compute -> update that product's deployment and recovery contract separately.
- Capacity or cost drives a decision -> refresh private provider evidence rather than adding exact values here.

## Maintenance Rule

Keep this file limited to public-safe architecture. Operational identifiers, endpoints, specifications, security posture, pricing, and recovery procedures stay in the private operator repository.
