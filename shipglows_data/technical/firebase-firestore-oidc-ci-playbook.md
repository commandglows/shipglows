---
artifact: technical_runbook
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-05-10"
updated: "2026-05-10"
status: reviewed
source_skill: sg-docs
scope: firebase-firestore-oidc-ci-playbook
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - GitHub Actions
  - Google Cloud IAM
  - Workload Identity Federation
  - Firebase CLI
  - Cloud Firestore
depends_on: []
supersedes: []
evidence:
  - "Runbook records a concrete GitHub OIDC / Firebase Firestore CI setup path and known failure signatures."
next_step: "Reuse in every new project before first Firestore CI deploy."
---

# Firebase Firestore OIDC CI Playbook

Use this runbook when wiring Firestore deploy from GitHub Actions without
service-account JSON keys.

## Goal

- OIDC/WIF authentication from GitHub Actions to GCP.
- Firestore deploy in CI with short-lived credentials.
- No interactive `firebase login` in CI.

## GitHub Secrets

- `FIREBASE_PROJECT_ID`
- `GCP_WIF_PROVIDER`
- `GCP_WIF_SERVICE_ACCOUNT`

`GCP_WIF_PROVIDER` must be:

`projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER`

Do not add `https://` or `//iam.googleapis.com/`.

## Workflow Skeleton

1. Job permissions:
   - `id-token: write`
   - `contents: read`
2. `google-github-actions/auth@v3` with:
   - `workload_identity_provider`
   - `service_account`
   - `token_format: access_token`
3. Deploy step:
   - set `FIREBASE_TOKEN: ${{ steps.<auth-id>.outputs.access_token }}`
   - run `firebase deploy --only firestore --project "$FIREBASE_PROJECT_ID" --non-interactive`

## GCP Setup

1. Enable:
   - `iam.googleapis.com`
   - `iamcredentials.googleapis.com`
   - `sts.googleapis.com`
   - `firebase.googleapis.com`
   - `firestore.googleapis.com`
2. Create deploy service account.
3. Create WIF pool and OIDC provider (`https://token.actions.githubusercontent.com`).
4. Grant project deploy role to service account (start with `roles/firebase.admin`).
5. Grant service-account IAM bindings to federated principal:
   - `roles/iam.workloadIdentityUser`
   - `roles/iam.serviceAccountTokenCreator`

## Common Failure Signatures

1. `invalid_target`:
   provider secret format invalid.
2. `unauthorized_client` / attribute condition:
   repo condition mismatch (`OWNER/REPO` changed).
3. `iam.serviceAccounts.getAccessToken denied`:
   missing `roles/iam.serviceAccountTokenCreator`.
4. `Failed to authenticate, have you run firebase login?`:
   token not passed to Firebase CLI in CI.
5. `Permissions denied enabling firestore.googleapis.com`:
   API not enabled by project admin.
6. Firestore index HTTP 400 `index is not necessary`:
   remove redundant index from `firestore.indexes.json`.

## Hardening After First Green Run

1. Restrict bindings to exact repository principal.
2. Restrict provider condition by repository and branch.
3. Replace broad admin role with least privilege custom role.
