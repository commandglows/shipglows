---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "0.1.0"
project: ShipGlows
created: "2026-10-07"
updated: "2026-10-07"
status: draft
source_skill: 900-shipglows-core
scope: browser-extension-lab
owner: Diane
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/references/preferred-stacks.md
  - skills/references/webextension-api-contract.md
  - shipglows_data/technical/extension-lifecycle-lab.md
depends_on: []
supersedes: []
evidence:
  - "2026-10-07: adapted origin/dev 4aa0c5a guidance to the existing source Chromium lifecycle lab."
next_review: "2026-11-07"
next_step: "Validate the adapted routing in a separate authorized development environment."
---

# Browser Extension Build And Host Proof

Select this surface from its extension manifest, entrypoints and declared
artifact/build contract. An ordinary project's `manifest.json` alone is not
extension evidence. For greenfield work use `preferred-stacks.md`; retain
accepted architecture for an existing extension.

Inspect artifact path, manifest version, permissions, entrypoints and declared
browser outputs before any repository script. Missing artifacts require the
reviewed project build in an authorized environment. Never silently select one
of several ambiguous artifact directories or broaden supported browsers.

Use `webextension-api-contract.md` for API compatibility, lifecycle, permission,
messaging and behavioral proof. For scoped Chromium MV3 lifecycle diagnostics,
follow `shipglows_data/technical/extension-lifecycle-lab.md` with an already
loadable artifact, installed prerequisites and a trusted product-owned scenario.
This branch provides a source tool, not dev's installed `s extension-inspect`
or `s extension-lab` commands or multi-browser Windows backends.

Keep artifact integrity, load, popup, content-script, worker, API outcome and
cleanup evidence separate. Chromium evidence never proves Firefox, Edge,
Vivaldi or Safari behavior. Resolve a separately authorized proof surface for
each other accepted engine; missing proof remains partial.

Use disposable profiles separate from personal state. Profile separation is
not a network or OS sandbox. Authenticated targets, publication, store submission
and dependency installation retain their own authority. Never infer execution
authority from these instructions, especially on a no-local-workload host.
