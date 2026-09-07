---
artifact: skill_reference
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-07"
updated: "2026-09-07"
status: active
source_skill: 108-sg-browser
scope: browser-extension-evidence
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/108-sg-browser/SKILL.md
depends_on: []
supersedes: []
evidence:
  - "2026-09-07: extract extension lifecycle clauses verbatim after recent-loading audit; ordinary browser proof no longer loads them."
next_step: none
---

## Extension Lifecycle Evidence

For extension errors, separate isolated console/page/worker evidence, the isolated
`chrome://extensions` Errors journal, and the personal-profile journal. Zero
`pageerror` events never proves an empty extension journal. Verify journal
collection is active; unavailable or inactive is `partial`, not clean.

For synchronization teardown, prove background receipt with a response still
pending before navigation, tab reload/closure, and extension reload with the host
tab surviving; then prove recovery. Capture isolated-world and worker exceptions
without filtering to a few known messages. The reusable source tool is
`tools/extension_lab.mjs`; its `--help` is executable discovery, not evidence that
the installed CLI exposes `extension-lab` or `extension-inspect`.

An explicitly authorized targeted personal-journal read needs no duplicate
permission question. Use the exposed browser UI, resolve the extension/profile,
and read only its errors. Never clear errors, reload/install the personal
extension, change settings, copy the profile or enable remote debugging under
read authority. If inaccessible, report `personal journal: not-read` separately;
an isolated pass cannot close that proof gap.
