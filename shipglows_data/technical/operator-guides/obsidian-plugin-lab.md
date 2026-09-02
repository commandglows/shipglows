---
artifact: operator_guide
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: ShipGlows
created: "2026-09-02"
updated: "2026-09-02"
status: active
source_skill: 102-sg-start
scope: obsidian-local-lab
owner: Diane
confidence: high
risk_level: high
security_impact: yes
docs_impact: no
linked_systems:
  - cli/windows/ShipGlows.ObsidianLab.js
  - cli/windows/ShipGlows.DevServer.psm1
depends_on: []
supersedes: []
evidence:
  - "Local Lab command and automated contracts implemented together."
next_step: none
---

# Obsidian Plugin Lab

Build the plugin with its reviewed project command, then run:

```powershell
s obsidian-lab -ProjectPath "C:\path\to\plugin" -Headless -Json
```

Add `-InteractionCommand plugin-id:command-id` to exercise one registered command and `-Screenshot` to retain visual evidence. ShipGlows reports artifact conformity, actual host loading, the interaction, and runtime diagnostics separately. A loaded plugin can therefore still have failed diagnostics.

Add `-ClickSelector '<css>'` to click exactly one rendered element, then
`-VisualSelector '<css>'` to capture exactly one element's visible text,
bounding box, visibility, and a bounded set of computed CSS values. With
`-Json`, these observations and the screenshot status/path/viewport are returned
under `visual`; ambiguous selectors fail their individual proof instead of
silently choosing the first match.

The Lab copies only `main.js`, `manifest.json`, and optional `styles.css` into a disposable vault. It does not use `SHIPGLOWS_OBSIDIAN_VAULT`, discover a personal vault, publish a GitHub release, or run npm/pnpm scripts. BRAT is a later distribution channel; the Lab only checks that local distribution artifacts are coherent.

The profile/vault separation protects personal Obsidian data from accidental Lab writes. It is not an OS sandbox: run only plugins whose local code you approve.
