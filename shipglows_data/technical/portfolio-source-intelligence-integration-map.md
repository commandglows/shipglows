---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-09-02"
updated: "2026-09-02"
status: draft
source_skill: sg-planning
scope: "portfolio source intelligence integration"
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - shipglows_data/business/portfolio-project-pitch-links.md
  - shipglows_data/workflow/specs/shared-source-analysis-contract-and-email-adapters.md
  - skills/references/private-memory-store.md
  - ../shipglows_app/shipglows_data/business/product.md
  - ../shipglows_app/shipglows_data/technical/architecture.md
  - ../contentglows/lab/agents/newsletter/tools/imap_tools.py
  - ../contentglows/lab/agents/sources/newsletter_extractor.py
depends_on:
  - artifact: "shipglows_data/business/portfolio-project-pitch-links.md"
    artifact_version: "0.4.0"
    required_status: draft
  - artifact: "shipglows_data/workflow/specs/shared-source-analysis-contract-and-email-adapters.md"
    artifact_version: "0.4.0"
    required_status: ready
supersedes: []
evidence:
  - "The ShipGlows App business corpus defines one managed multi-project SaaS with a Cockpit, project-scoped conversations, and runner-owned operational projections on 2026-09-02."
  - "ContentGlows contains a shipped per-user IMAP ingestion flow plus concrete newsletter fetch, extraction, scheduling, project scoping, Idea Pool persistence, and archive surfaces."
  - "The shared source-analysis spec is ready, but its declared canonical schema, semantic reference, validator, and checklist are absent from the current ShipGlows checkout."
  - "The current ShipGlows App newsletter screen generates newsletters; no runner-owned competitor-newsletter intake and portfolio review integration was found."
next_review: "2026-09-16"
next_step: "Validate the portfolio source-intelligence product boundary, then specify the first integration slice"
---

# Portfolio Source Intelligence Integration Map

## Purpose

Relier le corpus portfolio, les adaptateurs de newsletters concurrentes, l'analyse de sources et le SaaS `shipglows_app` sans créer une seconde source de vérité ni permettre à une source externe de déclencher silencieusement une mutation.

Cette cartographie décrit l'architecture produit cible et l'écart avec l'état observé. Elle ne prouve pas qu'un service SaaS d'ingestion est déployé et n'autorise ni migration de données, ni accès à une boîte mail, ni publication automatique.

## Product Outcome

Un opérateur doit pouvoir connecter une source autorisée, voir les newsletters concurrentes transformées en analyses traçables, comprendre à quels projets elles peuvent être utiles, puis accepter ou refuser chaque suite proposée depuis le Cockpit. Le système doit préserver la provenance, la confidentialité, le jugement humain et la vérité propre à chaque projet.

## System Boundary

```text
ShipGlows public framework
  owns: shared semantics, schemas, validation rules, métier/action vocabulary
            |
            v
ShipGlows managed runner
  owns: tenant/project authorization, adapter orchestration, private persistence,
        project-context projection, review state, audit evidence
            |
            v
shipglows_app Flutter client
  owns: connection status, portfolio inbox, analysis review, accepted handoffs

Host adapters
  own: source access, credentials, provider cursors, bounded extraction, retries

Project repositories
  own: business/product/brand/GTM truth and durable project decisions
```

The reusable contract belongs in the public ShipGlows framework. Credentials, raw messages, tenant state, private portfolio context, and customer operational records belong in the managed plane and must never enter the public repository.

## Current-State Map

| Capability | Observed source | State | Integration consequence |
| --- | --- | --- | --- |
| Portfolio identity and short pitches | ShipGlows portfolio pitch index plus project-local business corpora | Existing, manually curated | Useful for routing, but not yet a runtime project-context API |
| Managed project catalog and context | `shipglows_app` runner and Flutter managed-project projections | Implemented foundation | Natural authorization and context boundary for portfolio intelligence |
| Competitor newsletter retrieval | ContentGlows per-user IMAP reader and scheduled ingestion | Implemented and historically shipped | Reusable behavior exists, but it is owned by a fixed ContentGlows project flow |
| Newsletter extraction | ContentGlows newsletter extractor with persona/project context | Implemented | Output currently targets ContentGlows ideas rather than a provider-neutral portfolio analysis |
| Shared source-analysis semantics | Ready ShipGlows cross-project specification | Specified only | Declared schema, reference, validator, fixtures, and checklist are absent and must be implemented before parity can be claimed |
| SaaS newsletter surface | `shipglows_app` Flutter newsletter screen and API client | Implemented for generation | It does not currently provide competitor-source intake or portfolio analysis review |
| Portfolio review queue | Proposed by the shared source-analysis specification | Gap | Runner-owned persistence and review endpoints are required |
| Controlled downstream handoff | Existing ShipGlows métier and approval model | Semantically available | A typed handoff contract is still needed; no source may directly publish or mutate a project |

## Canonical Data Flow

```text
1. Authorized source connection
   -> adapter stores provider credentials outside Git

2. Adapter fetch
   -> raw provider message + adapter-owned opaque source identifier

3. Normalization
   -> SourceEnvelope (bounded readable content, provenance, tenant, source policy)

4. Analysis
   -> SourceAnalysis (facts, inferences, themes, risks, possible projects,
      possible actions, confidence, model/provider provenance)

5. Portfolio context resolution
   -> runner compares candidates only with tenant-authorized project catalog entries
      and bounded projections of project business truth

6. Review persistence
   -> pending / needs_review / accepted / rejected / retryable_failure

7. Flutter review
   -> operator sees source, reasoning, project candidates, confidence and risks

8. Controlled handoff
   -> accepted proposal creates a typed request for the relevant project and métier;
      it does not directly edit, publish, send, deploy, or archive unrelated state
```

## Authority And Source Of Truth

| Information | Canonical authority | SaaS representation |
| --- | --- | --- |
| Project identity | Authorized project catalog bound to a repository | Redacted runner projection |
| Project ambition and positioning | Project-local business, product, brand, and GTM corpus | Bounded context snapshot with revision/digest and freshness |
| Portfolio summary | Derived from authorized project entries; the pitch index is a navigation aid | Searchable portfolio view, never an independent master truth |
| Raw newsletter | Source provider/private managed storage | Minimal preview through an authorized endpoint |
| Normalized source and analysis | Versioned ShipGlows contract; managed tenant-scoped record | Review item with provenance and status |
| Decision to act | Human approval plus normal project authority gates | Audited accepted handoff |
| Durable product/content decision | Target project repository | Status/evidence projection back into the Cockpit |

## Minimum Contract

The first stable contract should define at least:

- `source_key`: opaque, stable, adapter-derived, and tenant-scoped;
- `source_type` and `adapter_id`: provider-neutral semantics plus concrete origin;
- `tenant_id`, authorized `project_scope`, and `routing_mode`;
- bounded content and provenance without secrets or provider credentials;
- observed facts separated from inferred themes and recommendations;
- zero or more project candidates with confidence and evidence;
- zero or more proposed actions with a stable identifier and explicit human-review requirement;
- schema, prompt, adapter, provider/model, and context revision metadata;
- idempotency, retry, partial-failure, retention, redaction, and deletion semantics;
- review state and an immutable audit trail for accepted or rejected handoffs.

## Security And Trust Invariants

- A newsletter is untrusted input and can contain prompt-injection instructions.
- The analysis runtime receives only the bounded source payload and bounded project context required for the job.
- The model never selects tenant authority, credentials, raw filesystem paths, mutation policy, or final project ownership.
- Cross-tenant and unauthorized cross-project comparison fail closed.
- Raw message bodies, addresses, provider locators, credentials, and private context never enter public/versioned artifacts or ordinary logs.
- Archiving the provider message is source-specific and occurs only after durable success under the adapter's declared policy.
- Partial batch success is recorded per source; one successful item never hides or archives another failed item.
- Analysis can propose an action but cannot publish, send, edit a repository, create a release, or deploy automatically.
- Every accepted handoff retains the source analysis identifier, project-context revision, actor, time, and decision evidence.

## Product Surfaces In `shipglows_app`

### Portfolio intelligence inbox

A cross-project queue showing new, ambiguous, accepted, rejected, failed, and stale analyses. Filters should include project candidate, source, theme, status, confidence, and freshness.

### Project intelligence view

A project-scoped view of sources matched to one project, why they matter, which business truth was used, and which actions remain proposals.

### Source detail and review

The operator sees factual summary, separated inferences, provenance, confidence, risks, candidate projects, proposed actions, and retry/history state before deciding.

### Connection and policy settings

The managed runner exposes adapter status, permitted folders/senders, retention and archive policy, validation state, and last successful observation. Flutter never receives reusable provider credentials.

## Integration Gaps

1. The historical `PITCH.md` and portfolio row still describe `shipglows_app` as a read-only local desktop dashboard; the current product corpus defines a broader managed SaaS.
2. The ContentGlows adapter is coupled to its user/project settings, scheduler, persona context, Idea Pool, and archive behavior.
3. The provider-neutral source-analysis artifacts declared by the ready ShipGlows spec do not yet exist in this checkout.
4. The managed runner has project authorization and projection foundations but no observed source-intelligence intake, analysis persistence, or review API.
5. The Flutter newsletter route is a generation workflow, not the portfolio intelligence inbox described here.
6. No proven end-to-end path currently binds adapter source, analysis, authorized project context, human review, and durable target-project handoff.

## Recommended Delivery Sequence

### Slice 1 — Canonical contract and fixtures

Implement and verify the provider-neutral envelope/analysis schema, semantic reference, synthetic fixtures, validator, idempotency rules, and redaction expectations in the public ShipGlows framework.

### Slice 2 — Managed runner intake

Add one runner-owned adapter port and tenant/project-scoped persistence using synthetic inputs first. Keep the existing ContentGlows flow unchanged until parity is proven.

### Slice 3 — Portfolio context resolver

Resolve candidates only from the authenticated project catalog, using revision-bound bounded business context. Ambiguous matches remain `needs_review`.

### Slice 4 — Read-only review experience

Add the portfolio inbox, project intelligence list, and source detail to Flutter. This slice accepts or rejects review decisions but launches no downstream mutation.

### Slice 5 — Controlled project handoffs

Translate an accepted proposal into one typed, auditable ShipGlows request that re-enters the target project's normal authority and proof lifecycle.

### Slice 6 — Adapter migration and operational proof

Wrap or migrate the proven ContentGlows IMAP behavior behind the runner adapter port; verify source-specific retries, archive policy, tenant isolation, redacted observability, and recovery before enabling real accounts.

## Explicit Non-Goals

- Copying ContentGlows persistence or Idea Pool tables directly into the managed runner.
- Making the portfolio pitch index a transactional database.
- Sending or generating newsletters automatically from competitor messages.
- Automatically choosing a project when evidence is ambiguous.
- Giving Flutter direct IMAP, Gmail, filesystem, repository, or secret-store access.
- Treating a local fake, existing screen, ready spec, or shipped historical adapter as end-to-end SaaS proof.

## Validation

- Confirm every current-state claim against the cited repository source.
- Confirm the declared shared schema/reference/validator/checklist existence before claiming contract implementation.
- Validate future schema fixtures and both adapter representations against the same semantics.
- Test idempotent reruns, prompt injection, ambiguous project routing, unauthorized tenant/project access, partial batch failure, source-specific archive, redacted diagnostics, and accepted-handoff audit evidence.
- Require authenticated runner API and Flutter widget/integration proof for the read-only review experience.
- Require an explicit later chantier before connecting a real mailbox, migrating data, enabling downstream mutation, or deploying.

## Maintenance Rule

Update this map when portfolio authority, source adapters, source-analysis schema, runner persistence/API, Flutter review surfaces, archive/retention policy, or downstream handoff behavior changes. Keep observed implementation, specified behavior, and target architecture visibly distinct.
