---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 010-sg-technical
scope: owasp-application-security-awareness
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/004-sg-deploy/SKILL.md
  - skills/010-sg-technical/SKILL.md
  - skills/100-sg-spec/SKILL.md
  - skills/101-sg-ready/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/400-sg-audit/SKILL.md
depends_on:
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "OWASP Top 10:2025 official release: https://owasp.org/Top10/"
  - "OWASP ASVS 5.0.0 official project page: https://owasp.org/www-project-application-security-verification-standard/"
  - "User decision 2026-08-07: integrate OWASP awareness and verifiable security gates across ShipGlows skills."
next_review: "2027-02-07"
next_step: "/103-sg-verify owasp-application-security-awareness"
---

# OWASP Application Security Awareness

## Purpose And Limits

Use OWASP Top 10:2025 as the shared awareness taxonomy for web application risk. It is a risk lens, not a claim of compliance, a complete threat model, or proof that a tool scan found every weakness.

Use OWASP ASVS v5.0.0 for selected, verifiable application-security requirements. When a report cites an ASVS requirement, retain its versioned form (`v5.0.0-<chapter>.<section>.<requirement>`). Do not claim that all of OWASP or all of ASVS is covered unless the evidence actually supports that statement.

For AI/LLM-specific application risk, load the appropriate current OWASP AI/LLM verification standard in addition to this reference; the web Top 10 does not replace it.

## Top 10:2025 Risk Lens

Assess only categories relevant to the changed or audited surface:

- **A01 Broken Access Control:** server-side authorization, tenant/resource ownership, least privilege, admin paths, IDOR, and UI-versus-enforcement gaps.
- **A02 Security Misconfiguration:** deployment defaults, headers, CORS/cookies, debug surfaces, cloud/storage exposure, secrets, and unsafe environment configuration.
- **A03 Software Supply Chain Failures:** dependencies, lockfiles, registries, build/release provenance, CI actions, third-party scripts, and abandoned packages.
- **A04 Cryptographic Failures:** transport, secret/key handling, storage, password protection, randomness, and use of proven primitives.
- **A05 Injection:** untrusted input into queries, commands, HTML, URLs, templates, paths, prompts, files, or provider calls; use validation and contextual encoding/parameterization.
- **A06 Insecure Design:** missing abuse cases, unsafe workflows, bypass/replay/duplicate handling, missing rate/cost limits, and unaddressed trust assumptions.
- **A07 Authentication Failures:** identity lifecycle, session/token handling, MFA/recovery, credential handling, brute force, and login/OAuth/callback paths.
- **A08 Software or Data Integrity Failures:** untrusted updates, deserialization, webhooks, CI/CD artifacts, signatures, idempotency, integrity checks, and protected state transitions.
- **A09 Security Logging and Alerting Failures:** security-relevant events, actionable/redacted diagnostics, alert ownership, detection gaps, and incident evidence.
- **A10 Mishandling of Exceptional Conditions:** fail-open paths, swallowed errors, unsafe fallback, timeout/cancellation/retry behavior, partial failure, cleanup, and recovery.

## Applicability And Evidence

Load this reference for code, specifications, fixes, audits, verification, or releases touching an internet-facing or privileged surface: authentication, authorization, sensitive data, APIs, webhooks, files, uploads, HTML/Markdown, payments, admin, secrets, integrations, automations, CI/CD, cloud/deploy configuration, or security-sensitive failures.

For a branch-free local change with no security-relevant surface, record `OWASP: not applicable — <reason>` rather than manufacturing a review.

For every applicable run, retain a compact `OWASP Security Gate`:

`Top 10 categories considered · trust/data boundaries · selected ASVS v5.0.0 requirements or not applicable · proof/evidence · residual gap and owner`

Escalate to a ready spec, security owner, or current official guidance when the risk model, authorization policy, cryptographic choice, external trust boundary, or incident-recovery behavior is unresolved. A green build, lint pass, dependency scan, or static review alone is supporting evidence, not complete security proof.
