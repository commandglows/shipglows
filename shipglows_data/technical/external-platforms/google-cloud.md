---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-google-cloud
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/documentation-freshness-gate.md
  - shipglows_data/technical/firebase-firestore-oidc-ci-playbook.md
  - templates/project_platform_usage.md
depends_on:
  - artifact: "shipglows_data/technical/external-platforms/README.md"
    artifact_version: "0.1.0"
    required_status: "draft"
supersedes: []
evidence:
  - "Fresh external docs checked on 2026-05-24 against Google Cloud IAM, workload identities, Workload Identity Federation, service account, Cloud Run service identity, ADC, and deployment-pipeline docs."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Google Cloud Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Google Cloud-related freshness checks. Use it before relying on assumptions about IAM, service accounts, service account keys, Application Default Credentials, Workload Identity Federation, GitHub Actions auth, Cloud Run service identity, Firebase CI, or Google Cloud client library credentials.

It does not replace Google Cloud documentation. It records the source map and ShipGlows rules agents should use before changing cloud auth, CI deploy credentials, service account permissions, Cloud Run identity, Firebase/GCP integration, or project-local Google Cloud usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Google Cloud authentication overview and ADC | https://cloud.google.com/docs/authentication |
| Workload identities overview | https://cloud.google.com/iam/docs/workload-identities |
| Workload Identity Federation overview | https://cloud.google.com/iam/docs/workload-identity-federation |
| Workload Identity Federation best practices | https://cloud.google.com/iam/docs/best-practices-for-using-workload-identity-federation |
| Deployment pipelines with WIF | https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines |
| Service accounts overview | https://cloud.google.com/iam/docs/service-account-overview |
| Service account security best practices | https://cloud.google.com/iam/docs/best-practices-service-accounts |
| Service account key management best practices | https://cloud.google.com/iam/docs/best-practices-for-managing-service-account-keys |
| Migrate from service account keys | https://cloud.google.com/iam/docs/migrate-from-service-account-keys |
| Cloud Run service identity | https://cloud.google.com/run/docs/securing/service-identity |
| Cloud Run service identity configuration | https://cloud.google.com/run/docs/configuring/services/service-identity |

Freshness evidence on 2026-05-24:

- Google Cloud authentication docs describe Application Default Credentials as the strategy used by auth libraries to find credentials from the application environment.
- Workload identities docs describe Workload Identity Federation as the preferred way to configure identities for external workloads, with service account keys as a fallback that carries private-key responsibility.
- Workload Identity Federation docs describe granting access directly to resources or using service account impersonation, and support deployment services such as GitHub and GitLab.
- WIF best-practices docs call out security threats such as spoofing, privilege escalation, non-repudiation, and malicious credential configurations.
- Service account key best-practices docs recommend attached service accounts, Workload Identity Federation for GKE, or Workload Identity Federation before service account keys.
- Cloud Run service identity docs recommend user-managed service accounts with the minimum permissions required for the service.

## Freshness Gate Use

Use `fresh-docs checked` for Google Cloud decisions only after checking relevant Google Cloud docs and local project IAM/CI/deploy evidence.

Use `fresh-docs gap` when:

- Code or CI uses Google Cloud credentials but the auth path is unclear: ADC, service account key, Workload Identity Federation, attached service account, or impersonation.
- A service account has broad roles without a documented least-privilege reason.
- CI/deploy docs mention Google Cloud but do not identify workload identity provider, service account, project ID, and target resources.
- A project uses Google Cloud but lacks `shipglows_data/technical/platforms/google-cloud.md`.

Use `fresh-docs conflict` when current Google Cloud docs contradict local docs, IAM assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Prefer keyless auth: attached service accounts on Google Cloud workloads, Workload Identity Federation for external CI/workloads, and service account impersonation where appropriate.
- Treat service account JSON keys as exceptional. If unavoidable, document why, storage location by secret name only, rotation plan, and blast radius.
- Never commit `GOOGLE_APPLICATION_CREDENTIALS` JSON, service account private keys, credential config files containing sensitive values, or raw access tokens.
- Cloud Run services should use a user-managed service account with minimal roles when accessing other Google Cloud services.
- CI/CD should avoid long-lived keys. For GitHub Actions, prefer Workload Identity Federation with repository/branch/environment conditions.
- IAM changes must identify actor, principal, resource, role, environment, and reason. Avoid Owner/Editor unless explicitly justified and temporary.
- For Firebase/Firestore work, check both Firebase and Google Cloud notes because server libraries and Admin SDKs rely on IAM/ADC boundaries.

## Common Project-Local Fields

A project using Google Cloud should maintain `<governance-root>/shipglows_data/technical/platforms/google-cloud.md` with:

- project ID(s), environments, and resource families used
- auth path: ADC, attached service account, WIF, impersonation, or key fallback
- CI provider and workload identity provider details, excluding secrets
- service accounts and intended roles at a high level
- Cloud Run/Functions/Firebase/Firestore/Storage integration notes
- secret-manager and credential storage policy
- validation commands and audit/log evidence route

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store service account JSON, private keys, OAuth refresh tokens, access tokens, raw audit logs with PII, or credential config files containing secrets in ShipGlows docs.
- Treat IAM role grants as security-sensitive code changes.
- Prefer short-lived credentials and identity federation over downloadable keys.
- Summarize audit evidence with redaction and do not paste raw policy dumps if they expose account structure unnecessarily.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/google-cloud.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/google-cloud.md
```

## Reader Checklist

- `GOOGLE_APPLICATION_CREDENTIALS`, `gcloud`, `service_account`, `workload_identity`, `google-github-actions/auth`, Cloud Run, Firebase CI, or GCP project IDs found -> check for project-local Google Cloud usage note.
- Service account key usage found -> ask whether WIF/attached service account/impersonation can replace it.
- IAM/deploy config changed -> verify least privilege and target environment.
- Firebase server/Admin SDK code changed -> check Firebase note and Google Cloud IAM note together.

## Maintenance Rule

Update this note when Google Cloud IAM, ADC, service accounts, Workload Identity Federation, deployment pipeline auth, Cloud Run identity, Firebase/GCP integration, or service account key guidance changes.
