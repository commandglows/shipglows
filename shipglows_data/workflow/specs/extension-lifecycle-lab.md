---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: ready
source_skill: 900-shipglows-core
scope: extension-lifecycle-lab
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
user_story: "As an extension developer, I want lifecycle diagnostics that distinguish observed errors from missing journal coverage."
linked_systems:
  - tools/extension_lab.mjs
  - tools/test_extension_lab.mjs
  - shipglows_data/technical/extension-lifecycle-lab.md
depends_on: []
supersedes: []
evidence:
  - "Operator approved the lifecycle lab and targeted personal Chrome journal reading with v on 2026-09-05."
next_step: "Read the targeted personal journal when the operator identifies the extension and profile and that Chrome UI is accessible."
---

# Extension lifecycle lab

## Approved outcome and readiness

Detect asynchronous extension failures around navigation, page reload, tab closure
and extension invalidation. Report isolated runtime evidence separately from the
retained Errors journal of a personal Chrome profile. Approval covers this scoped
tooling and targeted read-only journal access, never changing personal settings or
clearing errors. No product repository changes are needed.

## Observed problem and cause

The existing product reload smoke observes page console/pageerror and selects a
short list of message substrings. That is neither an extension-wide collector nor
proof that a background synchronization was pending at teardown. The Windows
DevServer opens the unpacked directory and extension manager; it has no lab or
journal collection implementation. Personal browser automation probes time out.

## Implementation contract and impact map

- Runtime owner: reusable Node/Playwright tool in `tools/extension_lab.mjs`, with
  its CLI and importable runner. Use an explicitly selected unpacked MV3 artifact,
  the existing Playwright runtime, and a fresh temporary Chromium profile.
- Collect all error families, isolated-world exceptions and worker diagnostics;
  attach before exercising scenarios. Collector gaps produce partial results.
- Provide reload/navigation/close and extension-reload scenarios. A scenario hook
  supplies product-specific readiness and in-flight synchronization evidence;
  generic navigation alone cannot certify the reported synchronization race.
- Keep personal journal coverage separate and never infer it from the lab.
  Only a connected browser UI and a uniquely identified extension permit reading.
- Fail on observed errors, partial on missing proof, pass only scoped completed
  scenarios with functioning collectors. Bound time, event volume and cleanup.
- Consumer: browser proof playbook gains one narrowly triggered extension rule.
  Technical/operator documentation explains invocation and evidence limits.
- Distribution: no installer, active runtime, capability schema or `s` command
  changes. A source tool must not pretend `s extension-lab` exists.
- Products: existing test code is evidence only; no application fixes or injected
  product instrumentation in this Core change.

## Proof ladder

Regression-first: a synthetic MV3 extension with actual pending runtime messaging
must fail on an unhandled teardown/context-invalidation error; its guarded version
must pass the same completed scenarios. Add unit checks for missing readiness,
collector failure, unknown error families, output bounds, and personal-coverage
separation. Real Chromium replay is required, not only mocked event emission.
No external services are necessary for fixtures. Each owned Chromium process is
closed before its exact temporary directory is removed.

Scenario-first rule: zero pageerror events and no personal journal access must
never become complete Chrome coverage. An unreadable journal remains not-read.

## Execution and boundaries

Parent owns writes, integration and evidence. One independent read-only reviewer
checks the collection design and later the exact diff; no parallel writes.
Preserve unrelated skill-sync changes. Ordinary scoped Git delivery is authorized
by the existing stewardship contract; installer replay is not part of this change.

## Progress

- Readiness: approved and ready.
- Implementation: complete as a source tool; no installed CLI or installer changes.
- Verification: 6 Node tests passed, including 5 real Chromium fixture variants;
  guarded pass, broken invalidation fail, worker/content exceptions and journal
  positive controls fail, no readiness proof partial. Eight browser rule tests
  passed. Every owned browser PID was checked stopped before profile cleanup.
- Personal Chrome journal: not read. Browser/native probes initially timed out;
  after recovery the native inventory contained no Chrome window and usual Chrome
  executable locations were absent. Extension/profile identity requested; pending.
- Documentation: updated usage, technical map and browser evidence rule.
- Editorial: no public installer/website promise changes; source-tool availability
  is explicit. Changelog event stays internal; product bug not claimed fixed.
- Loading: existing browser pack grows from 1554 to 1863 estimated tokens (+309),
  with no new loader edges. This approved extension-evidence rule supplies the
  previously missing profile/in-flight boundary in the already loaded proof pack.
  The unrelated core-help declared scenario reports 11197 tokens/over-budget;
  it reads no changed file, so that existing debt was not modified or waived.
- Delivery: source checkpoint pending Git persistence; overall journal task remains
  partial until the personal observation is available.
