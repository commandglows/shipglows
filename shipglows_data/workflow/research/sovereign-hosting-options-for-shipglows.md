---
artifact: research
metadata_schema_version: "1.0"
artifact_version: "2.0.0"
project: "ShipGlows"
created: "2026-07-04"
updated: "2026-10-21"
status: reviewed
source_skill: 203-sg-research
scope: "Sovereign hosting options for ShipGlows-managed projects: Clever Cloud, Scaleway, Codesphere"
owner: "Diane"
confidence: medium
risk_level: medium
security_impact: yes
docs_impact: yes
source_count: 16
evidence:
  - "https://www.clever.cloud/sovereign-cloud"
  - "https://www.clever.cloud/key-benefits"
  - "https://www.clever.cloud/clever-cloud-vs-heroku/"
  - "https://www.clever.cloud/developers/doc/account-billing/consumption/"
  - "https://github.com/CleverCloud/clever-cloud-review-app"
  - "https://www.scaleway.com/en/pricing/serverless/"
  - "https://www.scaleway.com/en/docs/serverless-containers/faq/"
  - "https://www.scaleway.com/en/serverless-containers/"
  - "https://www.scaleway.com/en/managed-postgresql-mysql/"
  - "https://www.scaleway.com/en/security-and-compliance/secnumcloud/"
  - "https://www.codesphere.com/"
  - "https://www.codesphere.com/products/developer-platform"
  - "https://docs.codesphere.com/intro"
  - "https://docs.codesphere.com/workspace-toolkit/monitor/log-browser"
  - "https://techcrunch.com/2026/02/17/mistral-ai-buys-koyeb-in-first-acquisition-to-back-its-cloud-ambitions"
  - "https://blog.ovhcloud.com/en/posts/snc-cloud-platform-secnumcloud-qualification/"
depends_on: []
supersedes:
  - "shipglows_data/workflow/research/codesphere-fit-for-shipglows-workflows.md (renamed and extended)"
next_step: "Pilot Clever Cloud on one real managed project that has a dedicated server or a web surface, then record the result in skills/references/deploy-target-matrix.md"
---

# Research: Sovereign hosting options for ShipGlows

> First written 2026-07-04 as a Codesphere fit study; extended 2026-10-21 into a sovereign-hosting comparison after the operator made sovereignty a first-class criterion. Sources re-checked 2026-10-21.

## Executive Summary

"Sovereign" here means: the provider is under European (mostly French) law, is not exposed to the US Cloud Act or FISA, and keeps the data in Europe.

For ShipGlows-managed projects (solo founder, small team, Vercel web, Cloud Run workers, Convex/remote API backends), the three options split cleanly:

| Need | Best sovereign option | Why |
| --- | --- | --- |
| Web app or dedicated server, low ceremony | **Clever Cloud** | French PaaS, `git push` deploy without a Dockerfile, managed PostgreSQL, PR review apps through an official GitHub Action. Closest to the Railway/Heroku experience. |
| Worker or containerized batch (Cloud Run equivalent) | **Scaleway** | Serverless Containers, Functions and Jobs, pay per use with a monthly free tier. Closest to Cloud Run. |
| Own servers, on-premise, air-gapped, institutional | **Codesphere** | Software platform installed on any infrastructure. Too heavy for a solo project. |

Recommendation: pilot **Clever Cloud** first on one real project; keep **Scaleway** for a sovereign worker; keep **Codesphere** only for the self-hosted case.

## Why it matters for ShipGlows

The current defaults (Vercel, Railway, Render, Fly.io, Google Cloud Run) are all US companies. They host in Europe on request, but they stay subject to the Cloud Act. A sovereign alternative per lane lets ShipGlows advise a project that must, or wants to, keep its data under European jurisdiction without changing the governance layer: ShipGlows stays the workflow governor, the provider stays a deploy substrate.

## Clever Cloud

Current shape (2026-10-21):

- French company under French law; states it is not subject to the Cloud Act or FISA.
- Developer PaaS plus managed databases: `git push` triggers a full deployment, no Dockerfile required; runtimes include Node.js, Python, Go, Rust, Java, PHP, Ruby, .NET, Docker and Static.
- Runs, monitors, restarts and updates the app; metrics and consumption visible in Grafana.
- Billing per second of running, on prepaid credit; published unit examples: `nano` 1 vCPU / 512 MB at about EUR 6 per month, `XS` 1 vCPU / 1 GB at about EUR 16 per month.
- PR review apps through the official `CleverCloud/clever-cloud-review-app` GitHub Action (deploy on PR open, redeploy on push, delete on close).
- Certifications: ISO/IEC 27001:2022, HDS (health data, all 6 activities), ISO 9001. SecNumCloud qualification is in progress on its own infrastructure; a SecNumCloud-qualified zone is available on demand through its Cloud Temple partnership.

Fit for ShipGlows:

- **Good**: sovereign replacement for Railway on a dedicated server (FastAPI, Node API), and for Vercel on a web surface that must stay sovereign (static site or Node SSR runtime).
- **Weaker**: no edge network, image optimization or framework-native integration comparable to Vercel; preview environments need the GitHub Action, which needs manual CI triggers under the ShipGlows CI-cost rule.
- **Pilot criteria**: deploy in under one hour from the repo, working review app, logs readable without a support ticket, monthly cost within the Railway range.

## Scaleway

Current shape (2026-10-21):

- French cloud provider (Iliad group), Paris region and others in Europe.
- Serverless Containers: stateless, autoscaled, billed on memory and vCPU duration; memory at EUR 0.10 per 100 000 GB-s after a 400 000 GB-s free tier per account and per month. Private ingress endpoints added in October 2026, so a worker can be reachable only from the private network.
- Serverless Functions and Serverless Jobs (batch) complete the serverless set.
- Managed PostgreSQL 14 to 17 and MySQL 8, stand-alone or high availability, on a private network.
- Certifications: ISO/IEC 27001:2022 and HDS. SecNumCloud is in progress, not yet granted.

Fit for ShipGlows:

- **Good**: sovereign replacement for Google Cloud Run in the worker lane (request-triggered service -> Serverless Containers, bounded batch -> Serverless Jobs).
- **Weaker**: a cloud provider, not a founder PaaS; more configuration than Clever Cloud for a plain web app.

## Codesphere

Current shape (2026-10-21):

- Codesphere SE (Karlsruhe, Munich, Berlin). It "owns no servers": it is a platform installed on any cloud, bare metal or air-gapped network.
- One declarative `ci.yml` "Landscape" per app: runtimes, managed services, networking, deployment strategy. Built-in cloud IDE, local IDE over SSH, Linux and Windows remote desktops, CI/CD, PR preview deployments, self-hosted Git (Gitea / OpenCode).
- Targets regulated industries: finance, public administration, critical infrastructure. The public pricing page now returns 404 (checked 2026-10-21): pricing goes through sales.
- Caveats noted in July 2026 still apply: monitoring is opt-in at team and landscape level with 14-day log retention, API keys inherit the full user permissions, and renaming a managed service in the Landscape config can recreate it and lose data.

Fit for ShipGlows:

- **Good**: a project that must run on its own servers or inside an institution's infrastructure, with one standardized dev/deploy/ops platform.
- **Weak**: any solo or small-team project. It pulls execution into a platform model, adds control-plane weight, and does not cover ShipGlows governance (routing, specs, verification, handoffs).

## Other names to watch

- **Koyeb** (French serverless platform) was acquired by Mistral AI on 2026-02-17 to power its AI cloud. Watch its direction before recommending it for general web hosting.
- **OVHcloud** obtained SecNumCloud qualification for its SNC Cloud Platform in October 2026. It is the option when a SecNumCloud-qualified public-cloud environment is mandatory today, at the cost of IaaS-level operation.

## Regulated data quick rule

- Health data in France -> HDS required: Clever Cloud and Scaleway both hold it.
- SecNumCloud required today -> Clever Cloud on its Cloud Temple zone, or OVHcloud SNC; neither Clever Cloud's own infrastructure nor Scaleway is qualified yet.
- Only "no Cloud Act" required -> Clever Cloud or Scaleway are enough.

## Limits of a sovereign choice

Hosting the app in Europe does not make the whole stack sovereign. Managed backends and services used by ShipGlows projects (Convex, Clerk, Supabase cloud, Sentry, Doppler, GitHub) are mostly US-hosted or US-owned. A project that needs real sovereignty must classify each of them too, and may need EU alternatives or self-hosted versions. State that gap explicitly instead of calling a project sovereign because its server is.

## Recommendation

1. Treat sovereignty as a first-class option in the deploy-target matrix, not only a Codesphere niche.
2. Sovereign defaults per lane: web and dedicated server -> Clever Cloud; worker -> Scaleway Serverless Containers or Jobs; self-hosted or on-premise -> Codesphere.
3. Store, desktop-package and extension lanes are distribution channels and do not change; their backends follow the rules above.
4. Pilot Clever Cloud on one real managed project before promoting it beyond advice.

## Sources

- [Clever Cloud sovereign cloud](https://www.clever.cloud/sovereign-cloud) - certifications, SecNumCloud status, Cloud Temple zone.
- [Clever Cloud key benefits](https://www.clever.cloud/key-benefits) - French law, Cloud Act/FISA statement, certification list.
- [Clever Cloud vs Heroku](https://www.clever.cloud/clever-cloud-vs-heroku/) - `git push` workflow and nano/XS unit prices.
- [Clever Cloud consumption](https://www.clever.cloud/developers/doc/account-billing/consumption/) - per-second billing and Grafana consumption view.
- [Clever Cloud review app action](https://github.com/CleverCloud/clever-cloud-review-app) - PR review apps.
- [Scaleway serverless pricing](https://www.scaleway.com/en/pricing/serverless/) and [Serverless Containers FAQ](https://www.scaleway.com/en/docs/serverless-containers/faq/) - billing and free tier.
- [Scaleway Serverless Containers](https://www.scaleway.com/en/serverless-containers/) - October 2026 private endpoints.
- [Scaleway managed PostgreSQL and MySQL](https://www.scaleway.com/en/managed-postgresql-mysql/) - managed database versions and options.
- [Scaleway SecNumCloud](https://www.scaleway.com/en/security-and-compliance/secnumcloud/) - HDS, ISO 27001, SecNumCloud not yet granted.
- [Codesphere homepage](https://www.codesphere.com/) and [developer platform](https://www.codesphere.com/products/developer-platform) - positioning, self-hosted scope, target industries.
- [Codesphere docs introduction](https://docs.codesphere.com/intro) and [log browser](https://docs.codesphere.com/workspace-toolkit/monitor/log-browser) - Landscape model, monitoring limits.
- [TechCrunch on Mistral buying Koyeb](https://techcrunch.com/2026/02/17/mistral-ai-buys-koyeb-in-first-acquisition-to-back-its-cloud-ambitions) - Koyeb acquisition.
- [OVHcloud SNC Cloud Platform](https://blog.ovhcloud.com/en/posts/snc-cloud-platform-secnumcloud-qualification/) - SecNumCloud qualification.
