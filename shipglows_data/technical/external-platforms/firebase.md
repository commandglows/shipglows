---
artifact: technical_module_context
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-05-24"
updated: "2026-05-24"
status: draft
source_skill: sg-docs
scope: external-platform-firebase
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
  - "Fresh external docs checked on 2026-05-24 against Firebase Auth token verification, Firestore Security Rules, Firestore client libraries, Firebase CLI, and Firebase Hosting docs."
next_review: "2026-06-24"
next_step: "/sg-docs technical audit"
---

# Firebase Platform Note

## Purpose

This note is the global ShipGlows/Chiclou cheat sheet for Firebase-related freshness checks. Use it before relying on assumptions about Firebase Authentication, ID tokens, Admin SDK, Firestore Security Rules, Firestore server/client libraries, Firebase Hosting, Firebase CLI deploys, or Firebase/GCP security boundaries.

It does not replace Firebase documentation. It records the source map and ShipGlows rules agents should use before changing Firebase auth, Firestore access, rules, hosting, CI deploys, or project-local Firebase usage docs.

## Source Map

Primary sources for Freshness Gate:

| Need | Source |
| --- | --- |
| Firebase Auth ID token verification | https://firebase.google.com/docs/auth/admin/verify-id-tokens |
| Firebase custom claims | https://firebase.google.com/docs/auth/admin/custom-claims |
| Firestore Security Rules conditions | https://firebase.google.com/docs/firestore/security/rules-conditions |
| Firestore Security Rules queries | https://firebase.google.com/docs/firestore/security/rules-query |
| Firestore Security Rules fields | https://firebase.google.com/docs/firestore/security/rules-fields |
| Firestore SDKs and client libraries | https://firebase.google.com/docs/firestore/client/libraries |
| Firebase CLI reference | https://firebase.google.com/docs/cli |
| Firebase Hosting quickstart | https://firebase.google.com/docs/hosting/quickstart |
| Firebase Auth service-worker sessions | https://firebase.google.com/docs/auth/web/service-worker-sessions |

Freshness evidence on 2026-05-24:

- Firebase Auth docs say custom backends should receive client ID tokens over HTTPS and verify them with the Firebase Admin SDK or a JWT library when needed.
- Firebase token verification docs warn that Admin SDK ID-token verification methods are for ID tokens from client SDKs, not custom tokens created by the Admin SDK.
- Firestore Security Rules docs state that server client libraries bypass Firestore Security Rules and authenticate through Google Application Default Credentials.
- Firestore rules docs use `request.auth` for client requests authenticated with Firebase Authentication or Google Cloud Identity Platform.
- Firebase CLI docs warn that deploying rules from the CLI overwrites existing rules in the Firebase console.
- Firebase Hosting docs position Firebase CLI as the deployment tool for hosting assets and dynamic content/microservices integrations.

## Freshness Gate Use

Use `fresh-docs checked` for Firebase decisions only after checking the relevant Firebase docs and local project Firebase config/rules/deploy evidence.

Use `fresh-docs gap` when:

- Firestore access changes but the client/server SDK path and Security Rules/IAM boundary were not identified.
- Backend auth changes but ID token verification, token revocation expectations, and project ID handling were not checked.
- Firebase CLI deploys rules/hosting without confirming overwrite behavior and target project.
- A project uses Firebase but lacks `shipglows_data/technical/platforms/firebase.md`.

Use `fresh-docs conflict` when current Firebase docs contradict local docs, rules assumptions, or a planned implementation.

## ShipGlows Decision Rules

- Firestore Security Rules protect untrusted client SDK access. Server Admin SDK/client-library access bypasses rules and must be protected by IAM and backend authorization logic.
- Do not rely on client-provided UID/email/claims without verifying Firebase ID tokens on the backend.
- For custom backends, receive ID tokens over HTTPS, verify them, and authorize the requested resource/action after verification.
- Security Rules and application code must agree on data shape. Rules can reject malformed client writes, but server writes can still create drift.
- Deploying rules through Firebase CLI can overwrite console rules. Treat rules deploys as security-sensitive changes.
- Firebase project aliases, target project IDs, hosting sites, rules files, and emulator/cloud modes must be explicit before verification.
- Prefer keyless Google Cloud auth/CI patterns where possible. If Firebase deploy uses Google Cloud credentials, check the Google Cloud provider note too.

## Common Project-Local Fields

A project using Firebase should maintain `<governance-root>/shipglows_data/technical/platforms/firebase.md` with:

- Firebase project ID or safe alias
- services used: Auth, Firestore, Hosting, Functions, Storage, App Hosting, Analytics, Messaging
- client SDK vs Admin SDK/server library boundaries
- rules files and deploy targets
- auth provider list and token verification strategy
- custom claims and role mapping
- CI/deploy auth route
- emulator usage and production proof route
- validation commands and security-rule smoke scenarios

Use `templates/project_platform_usage.md` as the starter structure.

## Security Notes

- Never store service account JSON, refresh tokens, Firebase Admin credentials, ID tokens, cookies, raw user records, or raw Firestore documents in ShipGlows docs.
- Treat Firebase Web API keys as project-identifying configuration, not authorization secrets.
- For Firestore, distinguish client-read/write permission from server-side administrative access.
- For rules changes, require explicit review of denied/allowed cases, not only syntax deploy success.

## Validation

```bash
python3 tools/shipglows_metadata_lint.py shipglows_data/technical/external-platforms/firebase.md
rg -n "Freshness Gate|Source Map|ShipGlows Decision Rules|Maintenance Rule" shipglows_data/technical/external-platforms/firebase.md
```

## Reader Checklist

- `firebase`, `firestore`, `firebase-admin`, `rules_version`, `firebase.json`, or `FIREBASE_` found -> check for project-local Firebase usage note.
- Firestore server code changed -> verify Admin/IAM/backend authorization, not Security Rules only.
- Firestore rules changed -> verify expected allow/deny scenarios and deploy target.
- Auth backend changed -> verify ID token path, revocation expectations, custom claims, and HTTPS boundary.

## Maintenance Rule

Update this note when Firebase Auth, Firestore rules, Admin SDK, client SDK, Hosting, CLI deploy, emulator, App Hosting, or Firebase/GCP IAM behavior changes.
