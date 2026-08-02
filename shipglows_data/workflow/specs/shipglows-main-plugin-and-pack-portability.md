---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "shipglows"
created: "2026-06-11"
created_at: "2026-06-11 00:00:00 UTC"
updated: "2026-06-12"
updated_at: "2026-06-19 01:05:00 UTC"
status: ready
source_skill: plugin-creator
source_model: "GPT-5 Codex"
scope: "plugin-packaging"
owner: "Diane"
user_story: "As a ShipGlows operator preparing public distribution, I want one main ShipGlows Codex plugin that can route to bundled or optional packs, so users get a simple install path without manually choosing many plugins."
confidence: medium
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "/home/claude/plugins/shipglows/"
  - "/home/claude/plugins/shipglows-core/"
  - "/home/claude/.agents/plugins/marketplace.json"
  - "/home/claude/plugins/shipglows/assets/docs-links.json"
  - "/home/claude/plugins/shipglows/skills/shipglows/references/reference-strategy.md"
  - "/home/claude/plugins/shipglows/scripts/bootstrap_shipglows_repo.sh"
  - "shipglows_data/technical/codex-plugin-packaging.md"
  - "skills/*/SKILL.md"
  - "skills/*/references/*.md"
  - "skills/references/*.md"
  - "templates/*.md"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-skill-execution-fidelity-plugin-pilot.md"
    artifact_version: "1.0.0"
    required_status: "ready"
supersedes: []
evidence:
  - "2026-06-11 local plugin /home/claude/plugins/shipglows was scaffolded and installed as shipglows@personal."
  - "2026-06-11 plugin validation passed for source and installed cache."
  - "2026-06-11 packaging audit reports 0 hard findings and 67 review findings across planned packs."
  - "2026-06-11 source skill 405-sg-prod was corrected to reference the shared actionable-failure contract canonically."
  - "2026-06-11 operator approved a hybrid local-reference plus hosted-docs model for public packaging."
  - "2026-06-11 operator preferred a simpler lightweight-plugin plus GitHub repo bootstrap model over broad reference export pipelines."
  - "2026-06-11 300-sg-docs added technical docs coverage for plugin packaging and sparse bootstrap."
  - "2026-06-11 300-sg-docs updated README surfaces for public site, plugin alpha, sparse bootstrap, and shipglows_data canonical layout."
  - "2026-06-11 009-sg-skill-build added a reproducible shipglows-main portability matrix and refreshed the installed local plugin cache to 0.1.0+codex.20260611103500."
  - "2026-06-11 706-continue ported public help into the plugin, then folded it under the single `shipglows` entrypoint to avoid exposing duplicate public skills."
  - "2026-06-11 103-sg-verify validated source/cache plugin manifests, installed cache parity, plugin enablement, metadata lint, and shipglows-main audit."
  - "2026-06-11 new-thread runtime proof captured in shipglows_data/workflow/conversations/conversation-shipglows-shipglows-help-20260611-164357.md confirms the single plugin entrypoint answers help, packs, and shipglows-main."
  - "2026-06-11 009-sg-skill-build added public partial-mode `shipglows-main` intent contracts for spec, ready, start, verify, check, and fix behind the single `shipglows` plugin skill."
  - "2026-06-11 plugin source/cache validation passed after reinstalling `shipglows@personal` as 0.1.0+codex.20260611173309."
  - "2026-06-12 new-thread runtime proof captured in shipglows_data/workflow/conversations/conversation-shipglows-shipglows-spec-20260612-034955.md confirms `$shipglows spec`, `$shipglows ready`, `$shipglows start`, `$shipglows verify`, `$shipglows check`, and `$shipglows fix` route through the bundled `shipglows-main-intents.md` contract."
  - "2026-06-12 009-sg-skill-build added `scripts/stage_shipglows_pack.py`, staged `shipglows-main` into `/tmp/shipglows-pack-stage-20260612-shipglows-main/shipglows-main`, validated the generated plugin candidate, and refreshed `shipglows@personal` to 0.1.0+codex.20260612035839."
  - "2026-06-12 009-sg-skill-build added `scripts/refresh_shipglows_pack.py` and `references/pack-maintenance-playbook.md`, refreshed `shipglows-main` into `/home/claude/.shipglows/staged-packs/shipglows-main`, validated the generated plugin candidate, and refreshed `shipglows@personal` to 0.1.0+codex.20260612043936."
  - "2026-06-12 operator decision recorded in technical docs: keep one public `shipglows` plugin filled as much as possible; treat pack generation as internal infrastructure and not a near-term multi-pack product commitment."
  - "2026-06-19 ShipGlows repository now exposes a repo-backed Codex marketplace source at `.agents/plugins/marketplace.json` and a publishable plugin source mirror at `plugins/shipglows`."
  - "2026-06-19 public install content was added across README, technical packaging docs, the public skill page, FAQ/docs cross-links, and dedicated `/install` and `/fr/install` site routes."
  - "2026-06-19 marketplace install proof passed locally with `codex plugin marketplace add /home/claude/shipglows` followed by `codex plugin add shipglows@shipglows --json`."
next_step: "none"
---

# Spec: ShipGlows Main Plugin and Pack Portability

## Status

ready

## User Story

As a ShipGlows operator preparing public distribution, I want one main ShipGlows Codex plugin that can route to bundled or optional packs, so users get a simple install path without manually choosing many plugins.

## Minimal Behavior Contract

ShipGlows must expose one primary user-facing plugin named `shipglows`. The plugin may internally route to packs, but the default user path must stay `Install ShipGlows` then `$shipglows <instruction>`. Optional packs must not become a manual list of many installs. Any generated pack must be validated for missing references and source-tree assumptions before it is treated as public-ready.

The plugin should remain small. When a user needs the complete ShipGlows skill and reference corpus, ShipGlows should offer an explicit repo bootstrap flow that creates or updates a sparse public GitHub checkout into `${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}`.

## Scope In

- Keep `/home/claude/plugins/shipglows/` as the main public-plugin alpha.
- Keep `/home/claude/plugins/shipglows-core/` as the internal audit and quality pilot.
- Use `shipglows` as the public entrypoint and pack router.
- Maintain a pack catalog that groups current numbered skills into coherent modules.
- Maintain a reference strategy that keeps critical execution references local and hosted docs optional.
- Provide an optional bootstrap helper for cloning/updating the full public ShipGlows repo.
- Audit pack portability before copying broad private skills into a public plugin.
- Generate or port `shipglows-main` first, because it is the smallest useful public route.
- Preserve the operator-last-resort rule: if ShipGlows can safely inspect, validate, or test, it should do so before asking the operator.

## Scope Out

- Publishing to OpenAI curated marketplace.
- Asking users to install many technical plugins manually.
- Copying the full private skill tree into the public plugin before portability issues are resolved.
- Shipping private transcripts, customer context, secrets, local caches, or machine-specific paths.
- Treating `$HOME/shipglows` as available for public plugin users.
- Requiring hosted docs or network access to execute core ShipGlows workflows.
- Silently cloning or updating the full repo without explicit user approval.

## Pack Strategy

- `shipglows`: one public plugin and user-facing entrypoint.
- `shipglows-main`: internal packaging/staging boundary and first useful public-capability cluster, but still routed through the single public `shipglows` plugin.
- `shipglows-proof`: deploy, browser, auth, prod, and QA proof pack.
- `shipglows-build`: implementation lifecycle pack.
- `shipglows-content`, `shipglows-design`, `shipglows-quality`, `shipglows-product`: later domain packs.
- `shipglows-governance`: internal-first pack; public surface requires separate review.

Product rule: do not expose a multi-pack public product by default. The near-term product is one plugin, `shipglows`, with pack generation kept as internal infrastructure unless real runtime constraints later justify separate public install surfaces.

## Bootstrap Strategy

- The plugin stays small and installable.
- The website explains and markets ShipGlows.
- A sparse GitHub checkout is the optional complete local skill/runtime corpus.
- The bootstrap script may clone/update the repo only after explicit operator approval.
- The default target is `${SHIPGLOWS_ROOT:-$HOME/.shipglows/source}`.
- The checkout includes `skills/`, `templates/`, `tools/`, `shipglows_data/`, `docs/`, `local/`, and `shipglows_data/workflow/bugs/`.
- The checkout excludes `site/`, `tui/`, `shipglows_data/workflow/archives/`, generated builds, and dependency directories.

## Reference Strategy

- Execution-critical contracts stay in the plugin: stop conditions, validation, proof obligations, reporting, routing, and operator-last-resort rules.
- Hosted docs carry long examples, tutorials, public explanations, changelogs, screenshots, pack docs, and paid-product upgrade paths.
- Hosted docs must be versioned and optional by default.
- A public pack is not portable until it works without `$SHIPGLOWS_ROOT` and without network access.

## Current Implementation State

- [x] Main plugin scaffolded at `/home/claude/plugins/shipglows/`.
- [x] Personal marketplace entry added in `/home/claude/.agents/plugins/marketplace.json`.
- [x] Entry skill `shipglows` added to the plugin.
- [x] Pack catalog added in Markdown and JSON.
- [x] Hybrid local-reference plus hosted-docs strategy added to the plugin.
- [x] Optional full-repo bootstrap script added to the plugin.
- [x] Packaging audit script added.
- [x] Plugin installed locally as `shipglows@personal`.
- [x] Source and installed-cache plugin validation passed.
- [x] Packaging audit hard findings reduced to 0.
- [x] Technical docs coverage added for plugin packaging and sparse bootstrap.
- [x] README surfaces updated for public site, plugin alpha, sparse bootstrap, and canonical `shipglows_data/` layout.
- [x] `shipglows-main` portability matrix added at `/home/claude/plugins/shipglows/skills/shipglows/references/shipglows-main-portability-matrix.md`.
- [x] Packaging audit script can emit a Markdown portability matrix with `--matrix`.
- [x] Plugin source and installed cache refreshed to `0.1.0+codex.20260611103500`.
- [x] Public help folded into the `shipglows` plugin entrypoint with plugin-local references.
- [x] Packaging audit now prefers bundled plugin skills over internal source skills for portability reports.
- [x] Public partial-mode intent contracts added behind `$shipglows` for `spec`, `ready`, `start`, `verify`, `check`, and `fix`.
- [x] Plugin source and installed cache refreshed to `0.1.0+codex.20260611173309`.
- [x] Pack generation script added at `/home/claude/plugins/shipglows/scripts/stage_shipglows_pack.py`.
- [x] `shipglows-main` staged successfully as a generated plugin candidate with 0 hard findings and 8 review findings.
- [x] Generated `shipglows-main` plugin candidate passed plugin validation.
- [x] Plugin source and installed cache refreshed to `0.1.0+codex.20260612035839`.
- [x] One-command pack refresh helper added at `/home/claude/plugins/shipglows/scripts/refresh_shipglows_pack.py`.
- [x] Pack maintenance playbook added at `/home/claude/plugins/shipglows/skills/shipglows/references/pack-maintenance-playbook.md`.
- [x] Default staged pack output moved outside the plugin source tree to `/home/claude/.shipglows/staged-packs/`.
- [x] Plugin source and installed cache refreshed to `0.1.0+codex.20260612043936`.

## Remaining Work

- [x] Add a pack generation script that can stage one pack from the catalog.
- [x] Decide whether `shipglows-main` should be bundled or delegated to the bootstrapped repo for the next pass.
- [ ] Test sparse bootstrap from a machine/path without an existing ShipGlows checkout.
- [x] Continue porting `shipglows-main` candidates with the `302-sg-help` plugin-local pattern.
- [x] Runtime-test public partial-mode `shipglows-main` intents in a fresh Codex thread.
- [x] Replace placeholder docs base URL with the real public ShipGlows docs domain when available.
- [ ] Publish optional hosted docs for public explanations after the local pack works offline.
- [x] Validate generated plugin candidate after staging `shipglows-main`.
- [x] Open a new Codex thread and test `$shipglows help`, `$shipglows packs`, and `$shipglows shipglows-main`.
- [x] Decide current product posture: single public `shipglows` plugin first; packs remain internal packaging infrastructure unless later constraints justify public distribution splits.
- [x] Add a repo-backed marketplace source so external users can install `shipglows` from Git instead of Diane's local filesystem.
- [x] Mirror the public `shipglows` plugin into the repository under a publishable marketplace path and keep validation green.
- [x] Publish clear user-facing install instructions on the ShipGlows site and align plugin docs links with those public pages.

## Acceptance Criteria

- [x] `shipglows@personal` installs and appears enabled in `codex plugin list`.
- [x] Source plugin validation passes.
- [x] Installed cache plugin validation passes.
- [x] Source/cache diff is clean after install.
- [x] Packaging audit has 0 hard findings.
- [x] Plugin records that hosted docs are optional and execution-critical references remain local.
- [x] Plugin provides an explicit full-repo bootstrap route instead of requiring a huge plugin.
- [x] Sparse bootstrap behavior is documented in technical docs.
- [x] `shipglows-main` has a versioned portability decision matrix before any broad skill copy.
- [x] First public `shipglows-main` capability is bundled through `shipglows` without relying on `/home/claude/shipglows`.
- [x] `shipglows-main` public help/routing can be used in a new Codex thread without relying on `/home/claude/shipglows`.
- [x] `shipglows-main` public intent contracts are bundled through `shipglows` without exposing numbered skills as the public route.
- [x] `shipglows-main` public partial-mode intents route correctly in a new Codex thread.
- [x] A catalog pack can be staged as a structurally valid local plugin candidate with an explicit audit report.
- [x] Public user journey remains one primary install and one plugin skill entrypoint.
- [x] A fresh external user can follow one public install path from repo marketplace source to installed `shipglows` plugin without relying on Diane's local machine paths.
- [x] The public site explains the install flow clearly enough that a new user can add the marketplace source, install the plugin, and start with `$shipglows`.

## Validation Commands

```bash
python3 /home/claude/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py /home/claude/plugins/shipglows
python3 /home/claude/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py /home/claude/.codex/plugins/cache/personal/shipglows/0.1.0+codex.20260612035839
python3 /home/claude/plugins/shipglows/scripts/audit_shipglows_packaging.py
python3 /home/claude/plugins/shipglows/scripts/audit_shipglows_packaging.py --pack shipglows-main --matrix
python3 /home/claude/plugins/shipglows/scripts/refresh_shipglows_pack.py shipglows-main
python3 /home/claude/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py /home/claude/.shipglows/staged-packs/shipglows-main
codex plugin list
python3 /home/claude/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py plugins/shipglows
bash -n plugins/shipglows/scripts/bootstrap_shipglows_repo.sh
pnpm --dir shipglows-site build
codex plugin marketplace add /home/claude/shipglows
codex plugin add shipglows@shipglows --json
```

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-11 09:29:34 UTC | 300-sg-docs | GPT-5 Codex | Updated README and docs surfaces for plugin packaging, public site, sparse bootstrap, and canonical governance layout. | Passed metadata lint and docs coherence checks. | /009-sg-skill-build shipglows-main plugin pack portability |
| 2026-06-11 13:39:01 UTC | 009-sg-skill-build | GPT-5 Codex | Added reproducible `shipglows-main` portability matrix, updated plugin routing/catalog surfaces, refreshed local plugin cache, and validated source/cache plugin manifests. | implemented | /103-sg-verify shipglows-main plugin pack portability |
| 2026-06-11 14:59:00 UTC | 706-continue | GPT-5 Codex | Ported public help into the plugin, updated catalog/matrix/README surfaces, and taught the packaging audit to prefer bundled plugin skills. | implemented | Refresh plugin cache, reinstall, then /103-sg-verify shipglows-main plugin pack portability |
| 2026-06-11 15:05:01 UTC | 103-sg-verify | GPT-5 Codex | Verified plugin source/cache manifests, installed cache parity, local plugin enablement, metadata lint, stale internal-reference scan, and `shipglows-main` packaging audit. | partial | Open a new Codex thread and test `$shipglows help`, `$shipglows packs`, and `$shipglows shipglows-main`. |
| 2026-06-11 16:48:14 UTC | 103-sg-verify | GPT-5 Codex | Accepted new-thread runtime proof from `shipglows_data/workflow/conversations/conversation-shipglows-shipglows-help-20260611-164357.md` for `$shipglows help`, `$shipglows packs`, and `$shipglows shipglows-main`. | verified | Continue porting `shipglows-main` execution candidates behind `$shipglows`. |
| 2026-06-11 17:33:00 UTC | 009-sg-skill-build | GPT-5 Codex + Spark subagents | Added plugin-local public partial-mode intent contracts for `$shipglows spec`, `ready`, `start`, `verify`, `check`, and `fix`; refreshed installed plugin cache. | implemented | Runtime-test the six public intents in a fresh Codex thread. |
| 2026-06-12 03:50:00 UTC | 103-sg-verify | GPT-5 Codex Spark | Accepted new-thread runtime proof from `shipglows_data/workflow/conversations/conversation-shipglows-shipglows-spec-20260612-034955.md` for `$shipglows spec`, `$shipglows ready`, `$shipglows start`, `$shipglows verify`, `$shipglows check`, and `$shipglows fix`. | verified | Add pack generation script or clean-path sparse bootstrap test. |
| 2026-06-12 03:59:00 UTC | 009-sg-skill-build | GPT-5 Codex | Added `stage_shipglows_pack.py`, staged `shipglows-main`, validated the generated plugin candidate, and refreshed the installed `shipglows` plugin cache. | implemented | Test sparse bootstrap from a clean path. |
| 2026-06-12 04:39:00 UTC | 009-sg-skill-build | GPT-5 Codex | Added one-command pack refresh helper and durable maintenance playbook; refreshed and validated `shipglows-main` from source skills into `/home/claude/.shipglows/staged-packs/shipglows-main`. | implemented | Test sparse bootstrap from a clean path. |
| 2026-06-12 08:18:00 UTC | 300-sg-docs | GPT-5 Codex | Recorded the single-plugin-first product decision in technical packaging docs and aligned the active portability spec with that posture. | implemented | Test sparse bootstrap from a clean path, then continue enriching the single public plugin. |
| 2026-06-19 00:25:00 UTC | 001-sg-build | GPT-5 Codex | Reopened the active portability chantier for the next bounded batch: repo-backed marketplace publication path, pack refresh in a public source tree, and public install-content updates. | implemented | Update the spec scope, then run implementation and verification on the repo-backed install path. |
| 2026-06-19 01:05:00 UTC | 103-sg-verify | GPT-5 Codex | Verified the repo-backed plugin mirror, public install pages, plugin docs-link alignment, site build, plugin validation, and actual `codex plugin marketplace add` plus `codex plugin add shipglows@shipglows` install flow. | verified | Close the chantier and ship the repo-backed marketplace/install path. |

## Current Chantier Flow

100-sg-spec ✅ -> 101-sg-ready ✅ -> 300-sg-docs ✅ -> 009-sg-skill-build ✅ -> 706-continue ✅ -> 103-sg-verify ✅ -> 104-sg-end ✅ -> 005-sg-ship ✅
