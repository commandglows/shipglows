---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-09-05"
updated: "2026-09-05"
status: ready
source_skill: 100-sg-spec
scope: windows-linked-skills-status
user_story: "A Windows maintainer can verify current linked skills without a dirty checkout triggering a runtime update."
owner: Diane
confidence: high
risk_level: medium
security_impact: yes
docs_impact: yes
linked_systems:
  - cli/shipglows_skills.py
  - cli/windows/shipglows.ps1
  - tools/shipglows_sync_skills.ps1
depends_on: []
supersedes: []
evidence:
  - "Operator approved the Windows inconsistency repair: oui vazy. Preserve existing work."
next_step: "Review branch integration; Windows branch installation is verified."
---

# Windows Linked Skills Status

Ready scope: fix native Windows junction recognition in read-only Python status;
honor validated development-channel state; add focused Windows skills status and
update-skills entry routes using the existing native link helper. No new update
system, dirty-check bypass, runtime install, stash, reset, commit or push.

Main owns Windows launcher, native command fixtures and mapped documentation.
Delegate owns Python status and its tests only. Preserve all previous dirty edits.
Runtime files remain generated output; no direct patching of installed copies.

Regression-first proof: actual junctions; unrelated links/local directories;
invalid/mismatching state; linked dirty repository; read-only status; missing-link
repair; refusal of collisions; ordinary runtime update still requires a clean
source. Launch fixtures with a DevServer stub that fails if called by skills routes.
Parse modified PowerShell. Test source commands separately from installed commands.

No server, application, credentials or global environment reconfiguration required.
Fresh-docs not needed: existing repository-owned helper and platform filesystem
semantics verified locally. ZOMBIES: absent/invalid/relative state, one/two host
catalogs, missing/colliding links, failure exit propagation and idempotent status.

Documentation: update runtime CLI and installer/user-scope contracts. Publication
and active Windows bootstrap remain separate from source validation. A new agent
session may read the linked source; no claim that a running agent reloaded it.

## Validation evidence

Delivery authority expanded on 2026-09-05: the operator approved publishing a
dedicated branch and installing it with the full Windows bootstrap, explicitly
including the local progressive-loading work. This supersedes the initial
local-only delivery boundary above; no direct installed-runtime patch is allowed.

- Seven Python Windows status tests pass, including real temporary junctions.
- Native linked-skills command fixtures pass: read-only check, missing-link repair,
  local-directory collision preservation, invalid root rejection and no runtime call.
- Existing Windows update command tests pass with the runtime dirty-source guard.
- Source launcher run on the operator's Windows account reports checked=30,
  ok=30, repaired=0, blocked=0. No live repair was needed or performed.
- Source Python status reports linked, both routers managed, and the intended
  checkout root. Installed launcher activation remains pending; no runtime files,
  commits or pushes were changed by this repair.

## Published branch and installed proof, 2026-09-05

The operator-approved combined delivery is commit
`8d4d89422fc2216db0a8541dfec7fbd391a8dbfb` on
`codex/progressive-skills-windows-launcher`, pushed to origin. It includes all
three local progressive-loading passes and the Windows launcher correction.

Current verification: 190 Python tests passed (178 affected tests and 12 profile
compatibility tests), ten scenario budgets within bounds, 26 governed Markdown
files valid, staged whitespace check passed, and both focused native command
suites passed. The full Bash Windows contract was attempted but is not green:
registry reconciliation exceeded its 800 ms threshold (944-1005 ms). The same
test passed in isolation on baseline and current source; every source input of
that performance test is unchanged. No threshold was weakened. Later checks
after this Bash stop were not certified by that run.

The official full bootstrap from the published branch completed with exit 0,
using InstallSurface runtime to retain the existing linked development channel.
Its installation receipt records the exact commit above. Both staged and active
Windows launcher contents match source after line-ending normalization.
Installed `shipglows.cmd skills status` and `shipglows.cmd update skills` both
passed: checked=30, ok=30, repaired=0, blocked=0. The development-channel root is
unchanged. No running agent context reload is claimed.

Bootstrap side effects include Playwright convergence and normal environment,
shortcut and project-registry synchronization. Optional WSL/Turso diagnosis and
Tauri Android preparation remain pending; no Android device is connected.
This is a branch installation, not integration into main or a public release.
Documentation is updated; existing public plugin promises are unaffected.
Changelog classification: internal-only maintainer workflow and loading change.
