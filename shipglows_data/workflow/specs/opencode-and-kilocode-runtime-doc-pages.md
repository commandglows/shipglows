---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.3"
project: "shipglows"
created: "2026-06-28"
created_at: "2026-06-28 00:00:00 UTC"
updated: "2026-06-28"
updated_at: "2026-06-28 00:00:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "opencode-and-kilocode-runtime-doc-pages"
owner: "Diane"
user_story: "As the ShipGlows operator, I want one OpenCode page and one KiloCode page that explain discovery, invocation, and configuration boundaries, so fresh agents and humans know what the repo proves for each runtime and what remains runtime-specific."
confidence: high
risk_level: medium
security_impact: none
docs_impact: yes
linked_systems:
  - "README.md"
  - "shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md"
  - "docs/opencode-shipglows.md"
  - "docs/kilocode-shipglows.md"
  - ".opencode/skills/shipglows/SKILL.md"
  - ".agents/skills/shipglows/SKILL.md"
  - "shipglows_data/workflow/TASKS.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/agent-clarity-public-docs-handoffs-phase-2.md"
    artifact_version: "1.0.2"
    required_status: "reviewed"
  - artifact: "README.md"
    artifact_version: "0.13.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/skill-runtime-and-lifecycle.md"
    artifact_version: "1.21.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "The shipped public/docs handoff-clarity phase explicitly left a runtime-pages follow-up for OpenCode and KiloCode."
  - "The repository currently proves an OpenCode shim at `.opencode/skills/shipglows/SKILL.md` and a generic OpenCode-compatible shim at `.agents/skills/shipglows/SKILL.md`."
  - "Current README/help/runtime docs explain invocation boundaries generically, but there is no dedicated repo-visible page per runtime."
next_step: "/005-sg-ship opencode-and-kilocode-runtime-doc-pages"
---

# Title

OpenCode And KiloCode Runtime Doc Pages

## Status

ready

## User Story

As the ShipGlows operator, I want one OpenCode page and one KiloCode page that explain discovery, invocation, and configuration boundaries, so fresh agents and humans know what the repo proves for each runtime and what remains runtime-specific.

## Minimal Behavior Contract

ShipGlows must publish one repo-visible page for OpenCode and one for KiloCode. Each page must explain what the operator types, what the runtime may call internally, how ShipGlows is discovered from this repository, which shim or compatibility path is actually present in the repo, and which runtime-specific setup details are not claimed. The pages must stay aligned with README and the launch cheatsheet.

## Success Behavior

- `docs/opencode-shipglows.md` explains the proven OpenCode shim path and the operator-vs-runtime boundary.
- `docs/kilocode-shipglows.md` explains the operator-vs-runtime boundary and documents KiloCode through the generic compatible path without inventing an unproven repo contract.
- `README.md` and `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md` link to the new runtime pages for discovery.
- The backlog item in `shipglows_data/workflow/TASKS.md` can be closed once the pages exist and are linked.

## Error Behavior

- If the OpenCode page claims a config path not present in the repo, reject it.
- If the KiloCode page implies a dedicated repo shim that does not exist, reject it.
- If either page presents `skill({ name: "shipglows" })` as a manual operator command, reject it.
- If either page blurs helper routing with execution ownership, reject it.

## Problem

The repo now states the handoff vocabulary correctly, but it still lacks dedicated runtime pages that a fresh operator can open directly when asking "how do I use ShipGlows in OpenCode?" or "how do I use ShipGlows in KiloCode?".

## Solution

Create two focused Markdown pages under `docs/`, one per runtime, and link them from the main repo-visible discovery surfaces. Keep the wording evidence-based: OpenCode gets the documented shim path that exists in the repo; KiloCode gets the compatible invocation/configuration guidance plus an explicit limit where the repo does not prove more.

## Scope In

- new `docs/opencode-shipglows.md`
- new `docs/kilocode-shipglows.md`
- README and cheatsheet links to those pages
- runtime-discovery wording only as needed for link coherence

## Scope Out

- no plugin packaging code changes
- no new runtime shim directories
- no hosted site changes outside this repo checkout
- no broad rewrite of help/runtime doctrine already shipped

## Constraints

- Keep internal contracts in English; user-facing explanatory text may stay in English on repo docs when it matches existing docs.
- Do not claim KiloCode-specific repo configuration that the repository cannot prove.
- Keep OpenCode/KiloCode pages aligned with the shipped handoff doctrine.

## Test Contract

- `python3 tools/shipglows_metadata_lint.py docs/opencode-shipglows.md docs/kilocode-shipglows.md README.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md shipglows_data/workflow/specs/opencode-and-kilocode-runtime-doc-pages.md`
- `rg -n "OpenCode|KiloCode|skill\\(\\{ name: \\\"shipglows\\\" \\}\\)|\\.opencode/skills/shipglows|\\.agents/skills/shipglows|runtime skill picker" README.md docs/opencode-shipglows.md docs/kilocode-shipglows.md shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`

## Dependencies

- Existing OpenCode shim docs at `.opencode/skills/shipglows/SKILL.md`
- Existing generic OpenCode-compatible shim docs at `.agents/skills/shipglows/SKILL.md`
- Shipped public/docs handoff doctrine from `agent-clarity-public-docs-handoffs-phase-2`

## Invariants

- `302-sg-help` explains/routes; owner skills execute after handoff.
- Internal runtime calls are not manual operator commands.
- OpenCode documentation may point to repo shim paths that exist; KiloCode documentation must be explicit when the repo only proves a generic compatibility path.

## Links & Consequences

- README and cheatsheet remain the first discovery surfaces.
- The new pages become the detailed runtime-specific references those summary surfaces can link to.

## Documentation Coherence

- Update `README.md` and `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`.
- Keep `shipglows_data/technical/skill-runtime-and-lifecycle.md` unchanged unless link drift appears during implementation.

## Edge Cases

- A runtime may have a skill picker and also allow manual repo skill import; docs should treat those as additive, not contradictory.
- A runtime may log internal calls that the operator should never type manually.
- KiloCode setups may vary; the page must keep a clear `repo proves / repo does not prove` boundary.

## Implementation Tasks

- [x] Write the bounded spec for the runtime-pages follow-up.
- [x] Create `docs/opencode-shipglows.md` with discovery, invocation, configuration, and limits.
- [x] Create `docs/kilocode-shipglows.md` with discovery, invocation, configuration, and limits.
- [x] Link the new runtime pages from `README.md` and `shipglows_data/technical/operator-guides/skill-launch-cheatsheet.md`.
- [x] Validate metadata and drift checks.

## Acceptance Criteria

- A fresh operator can open one dedicated page per runtime from the repo.
- The OpenCode page points only to repo-proven shim/config surfaces.
- The KiloCode page is useful without overstating repo-native support.
- README and cheatsheet link to the pages.

## Test Strategy

- Metadata lint on the new docs and updated discovery surfaces.
- Targeted grep for invocation-boundary phrases and repo shim paths.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-28 | 100-sg-spec | GPT-5 Codex | Create a dedicated follow-up spec for the OpenCode and KiloCode runtime documentation pages left out of the shipped public/docs handoff-clarity slice | implemented | Run `/300-sg-docs shipglows runtime pages for OpenCode and KiloCode` |
| 2026-06-28 | 300-sg-docs | GPT-5 Codex | Create dedicated OpenCode and KiloCode runtime pages, then link them from README and the launch cheatsheet without overstating repo-native runtime support | implemented | Run `/103-sg-verify opencode-and-kilocode-runtime-doc-pages` |
| 2026-06-28 | 103-sg-verify | GPT-5 Codex | Verify that the new OpenCode and KiloCode pages match repo-proven shim paths, preserve invocation boundaries, and stay linked from the repo discovery surfaces | verified | Run `/104-sg-end opencode-and-kilocode-runtime-doc-pages` |
| 2026-06-28 | 104-sg-end | GPT-5 Codex | Close the runtime-pages slice, mark the runtime-docs tracker item done, and prepare the dedicated spec for git shipping | closed | Run `/005-sg-ship opencode-and-kilocode-runtime-doc-pages` |
| 2026-06-28 | 103-sg-verify | GPT-5 Codex | Verify whether the runtime-pages slice was actually shipped after closure bookkeeping; implementation remains verified but git ship proof is still missing | partial | Run `/005-sg-ship opencode-and-kilocode-runtime-doc-pages` |

## Current Chantier Flow

- `100-sg-spec` ✅ follow-up runtime-pages spec created
- `101-sg-ready` ✅ bounded runtime-pages scope is ready from the spec contract
- `102-sg-start` ✅ runtime pages and repo discovery links implemented
- `103-sg-verify` ✅ metadata, shim-path, and invocation-boundary checks passed
- `104-sg-end` ✅ tracker and changelog closure completed
- `005-sg-ship` ⏳ pending
