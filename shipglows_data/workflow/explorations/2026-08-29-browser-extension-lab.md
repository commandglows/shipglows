---
artifact: exploration_report
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-29"
updated: "2026-08-29"
status: reviewed
source_skill: 700-sg-explore
scope: browser-extension-lab
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/windows/
  - chrome-brat
  - ToolGlows
  - CommunityGlows
depends_on: []
supersedes: []
evidence:
  - "chrome-brat main and origin/main resolve to f0a0bbbaa3a9d709786ff82c32907108d72f960b."
  - "A focused local probe loaded Chrome BRAT through CDP Extensions.loadUnpacked in Playwright Chromium on 2026-08-29."
  - "ShipGlows development code recognizes only the CRXJS dev:chrome convention and dist\\chrome output."
next_step: "Implement the ready browser extension lab specification"
---

# Exploration Report: Browser Extension Lab

## Context

ShipGlows needs to import, run, inspect, and test browser-extension repositories without mutating a developer's personal browser profile. Chrome BRAT is the first static Manifest V3 fixture; ToolGlows and CommunityGlows are built extension pilots.

## Alternatives

- Copy artifacts into personal Chrome profile directories: rejected because profiles are browser-owned, unsafe to mutate, and unsuitable for deterministic automation.
- Make Chrome BRAT orchestrate other extensions: rejected because an extension cannot build arbitrary repositories or install another unpacked extension through the Chrome management API.
- Use a ShipGlows-managed disposable Chromium profile: selected because it supports explicit lifecycle control, CDP loading, isolated diagnostics, and repeatable automation.

## Evidence

- Chrome BRAT remains a static Manifest V3 repository without package scripts or GitHub workflows.
- ShipGlows' current extension path hardcodes `dev:chrome`, `@crxjs/vite-plugin`, and `dist\\chrome`.
- The public ShipGlows `main` branch does not yet expose the specialized extension path present on the development branch.
- `Extensions.loadUnpacked` returned extension id `pdbcaempglndginepbhgbecoedeaoeoj` in a disposable Playwright Chromium context.
- ToolGlows and CommunityGlows have unrelated local changes, so integration requires dedicated worktrees and resolved clean bases.

## Risks and Unknowns

- The CDP Extensions domain is experimental and must be capability-checked with an actionable fallback.
- Arbitrary repositories are untrusted input; ShipGlows must not run package scripts silently.
- Firefox uses a different execution path (`web-ext`) and is not part of the first implementation milestone.
- Public copy must describe only behavior backed by automated or manual evidence.

## Recommendation

Build the orchestration in ShipGlows Core, keep Chrome BRAT as a fixture and optional catalog companion, and expose a deterministic machine-readable contract for agents. Documentation and beginner onboarding are first-class deliverables. This report contains no implementation proof.
