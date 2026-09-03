---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: "ShipGlows"
created: "2026-09-04"
created_at: "2026-09-03 22:54:32 UTC"
updated: "2026-09-04"
updated_at: "2026-09-03 22:54:32 UTC"
status: closed
source_skill: sg-spec
source_model: "GPT-5 Codex"
scope: feature
owner: Diane
user_story: "En tant qu'operatrice de ShipGlows, je veux exploiter les capacites utiles de Vercel Pro avec des depenses mesurees, controlees, observees et prevues, sans degrader les parcours Hobby."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/references/vercel-cost-conscious-operations.md"
  - "skills/references/project-development-mode.md"
  - "skills/002-sg-maintain/references/maintenance-playbooks.md"
  - "skills/004-sg-deploy/references/release-confidence-workflow.md"
  - "skills/405-sg-prod/references/production-verification-workflow.md"
  - "skills/305-sg-init/references/bootstrap-entrypoint-and-dev-mode.md"
  - "shipglows_data/technical/external-platforms/vercel.md"
depends_on:
  - artifact: "skills/references/project-development-mode.md"
    artifact_version: "1.3.0"
    required_status: active
  - artifact: "skills/references/decision-quality-contract.md"
    artifact_version: "2.3.1"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-09-04: Vercel Pro is primarily required for private organization repository deployments."
  - "Operator decision 2026-09-04: Turbo speed has no intrinsic value; credits must be spent only through measured, deliberate, controlled, observed, and planned choices."
  - "Official Vercel documentation checked 2026-09-04 for Pro credits, Spend Management, builds, deployment protection, WAF, observability, analytics, and MCP."
next_step: "Apply the new project Vercel profile to the first private-organization repository after inspecting its actual provider settings."
---

# Spec: Vercel Pro cost-conscious governance

## Status

closed

## User Story

En tant qu'operatrice de ShipGlows, je veux exploiter les capacites utiles de Vercel Pro avec des depenses mesurees, controlees, observees et prevues, sans degrader les parcours Hobby.

## Minimal Behavior Contract

When a project uses Vercel, ShipGlows identifies its plan and validation needs without assuming Pro. Hobby-compatible behavior remains the baseline. A Pro capability that can create metered usage, paid add-ons, broader access, production mutation, or global pausing is used only after evidence, an explicit project policy, and the applicable authority gate. Private organization repository deployment is a legitimate reason to retain Pro even when every discretionary resource remains economical.

## Scope In

- Shared Vercel economy, build, spend, WAF, observability, preview-protection, MCP, and Hobby-compatibility doctrine.
- Project bootstrap/development-mode fields that expose deliberate Vercel choices.
- Maintenance, release, and provider-proof consumers.
- Current official Vercel source refresh and focused contract tests.

## Scope Out

- Changing any Vercel team, project, billing, domain, environment, firewall, deployment, or add-on setting.
- Installing an agent plugin or adding a dependency.
- Assuming every project uses Vercel or Pro.
- Optimizing for deployment speed without measured need.

## Invariants

- Hobby is the portable baseline; Pro is a declared project/account capability, never an implicit requirement.
- Standard build machines and one active build per branch are the economical default.
- Turbo, enhanced machines, unrestricted on-demand concurrency, and paid add-ons require measured justification and explicit policy.
- Spend is observed and attributed before optimization; a threshold never silently authorizes pausing all production projects.
- WAF enforcement follows log, review, enforce, and verify; it never substitutes for application authorization.
- Vercel MCP provides provider evidence when callable, CLI is fallback, and ShipGlows retains workflow and authority ownership.

## Implementation Tasks

- [x] Add the canonical cost-conscious Vercel operations contract.
- [x] Extend project bootstrap and development-mode truth without storing secrets or mutable usage snapshots.
- [x] Make maintenance surface usage drift and make release/prod proof honor cost and protection policy.
- [x] Refresh the Vercel platform note against current official documentation.
- [x] Add focused pressure-scenario tests and run mapped metadata, graph, budget, and runtime-sync checks.

## Acceptance Criteria

- [x] AC 1: A Vercel Hobby project remains fully supported and is not told to enable Pro-only or paid features.
- [x] AC 2: A Pro project defaults to Standard builds and one build per branch unless measured evidence documents another choice.
- [x] AC 3: Spend management distinguishes notification, webhook, and global pause authority.
- [x] AC 4: Release proof matches commit, branch, deployment, protection, and the required user flow without equating Ready with product proof.
- [x] AC 5: WAF guidance uses staged enforcement and preserves application-layer security ownership.
- [x] AC 6: Observability separates provider/build/cost evidence from application error evidence and makes add-ons evidence-driven.
- [x] AC 7: Provider operations remain unavailable when the relevant MCP/CLI is not callable, rather than being inferred from configuration.

## Test Strategy

- Unit: focused static contract scenarios for Hobby portability, economical defaults, spend authority, WAF staging, and MCP/CLI roles.
- Integration: activation/resource graph plus mapped skill audit and runtime visibility checks.
- Manual: review against current official Vercel documentation; no account mutation.

## Risks

- Security impact: yes; preview access, automation bypasses, WAF, logs, and provider permissions require least privilege and redaction.
- Cost risk: high; Pro defaults can consume credits without improving the operator's outcome.
- Compatibility risk: medium; Pro-specific policy must not become a prerequisite for Hobby users.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-09-03 22:54:32 UTC | sg-spec | GPT-5 Codex | Formalized the approved economical Vercel Pro direction. | draft | readiness review |
| 2026-09-03 22:54:32 UTC | sg-ready | GPT-5 Codex | Resolved official-source freshness, scope, invariants, proof, and authority boundaries. | ready | implementation |
| 2026-09-03 22:54:32 UTC | sg-start | GPT-5 Codex | Started the cross-surface doctrine implementation. | in progress | focused implementation and proof |
| 2026-09-03 23:02:11 UTC | sg-verify | GPT-5 Codex | Verified six focused scenarios, metadata, activation/resource graphs, activation and discovery budgets, skill audit, runtime links, changed-path documentation mapping, and diff hygiene. | verified | commit and push the validated milestone |
| 2026-09-03 23:03:52 UTC | sg-end | GPT-5 Codex | Closed the implemented and verified doctrine scope; technical documentation and refresh records are aligned, with no public editorial promise changed. | closed | protected Git delivery |
| 2026-09-03 23:03:52 UTC | sg-ship | GPT-5 Codex | Delivered the implementation through protected pull request 126 after both required gates passed. | shipped | persist final closure state |

## Current Chantier Flow

- `sg-spec`: done.
- `sg-ready`: ready.
- `sg-start`: implemented.
- `sg-verify`: verified.
- `sg-end`: closed.
- `sg-ship`: shipped through protected pull request 126.

Next step: apply the new project Vercel profile to the first private-organization repository after inspecting its actual provider settings.
