---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.2.0"
project: ShipGlows
created: "2026-09-04"
updated: "2026-10-06"
status: draft
source_skill: 900-shipglows-core
scope: webextension-api-design-and-proof
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/sg-development/SKILL.md
  - skills/103-sg-verify/references/verification-security-ui-runtime.md
  - shipglows_data/technical/extension-lifecycle-lab.md
depends_on: []
supersedes: []
evidence:
  - "2026-10-06: selectively adapted from dev commits c202fc1 and 563feb5 to main's source lifecycle lab; execution validation remains deferred."
next_review: "2026-12-04"
next_step: "Validate the adapted contract in a separate development environment."
---

# WebExtension API Contract

Use for browser-extension API selection and behavioral proof. This contract
does not select a new framework or expand the product's supported browsers.

## Compatibility Before Implementation

Record the accepted browser set and minimum versions. Check current MDN
compatibility data and official vendor documentation for each API, permission,
manifest key, namespace and return shape that controls implementation.
Shared source and type definitions do not prove runtime parity. Keep browser
differences in a bounded adapter and capability-check optional APIs at use.

Classify choices against that evidence: adopt supported foundations that fit
the product; use optional capabilities only with a justified outcome and a
reduced-capability path; keep preview or rollout-dependent capabilities behind
explicit acceptance and capability detection. No experimental capability may
silently become a launch dependency or authorize a cloud fallback.

## Context, Lifecycle And Trust

Treat the Manifest V3 service worker as ephemeral. Reconstruct listeners at
module evaluation and persist required state rather than relying on surviving
globals, timers or connections. Keep popup, content script, page world and
worker lifetimes distinct; account for absent receivers and closed tabs.

Validate message schemas and sender/context before privileged actions. Make
retried mutations idempotent. Handle storage failure, quotas, concurrent writes
and migrations without exposing sensitive data in diagnostics.

## Permissions And Injection

Request the least access needed for the accepted outcome. Prefer access granted
at the moment of use when supported; handle denial and revocation. Broad host
access, identity, cookies, debugger or native messaging need an explicit trust
justification. Validate target URL, frame and document lifecycle before
injection; crossing into the page world needs a bounded interoperability reason
and data validation. Never introduce remote executable code as a workaround.

## Proof And Existing Lab

Review manifest, permissions and the browser matrix statically; exercise
adapters, message validation, denial/revocation, unavailable APIs, restart and
storage failure where relevant. Build only through the reviewed project command
in an environment where execution is authorized.

For Chromium MV3 lifecycle diagnostics, use the source lab described in
`shipglows_data/technical/extension-lifecycle-lab.md`. It requires an already
loadable artifact, installed prerequisites and a trusted product-owned scenario.
It is not an installed `s extension-lab` command. Do not import dev's WXT,
Obsidian or Windows-lab presets merely to activate this contract.

The lab's Chromium evidence does not prove Firefox or other browser support,
every API outcome, permission behavior, or natural worker suspension. Preserve
its documented observation limits. Use a separately authorized suitable proof
surface for other declared engines or capabilities; missing proof stays partial.
Build, load, popup or worker success alone does not prove the actual API outcome.

## Stop Conditions

Resolve material changes to browser support, permission scope, authenticated
targets, remote services, native hosts and distribution before implementation.
Recheck official documentation when compatibility or policy controls a decision.
This contract grants no installation, execution, publication or deployment
authority; the current environment's operating boundary remains authoritative.
