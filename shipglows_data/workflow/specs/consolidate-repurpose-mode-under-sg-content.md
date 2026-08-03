---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.2"
project: ShipGlows
created: "2026-07-17"
created_at: "2026-07-17 08:45:22 UTC"
updated: "2026-07-17"
updated_at: "2026-07-17 10:30:20 UTC"
status: ready
source_skill: 100-sg-spec
source_model: GPT-5 Codex
scope: content-repurpose-skill-surface-consolidation
owner: Diane
user_story: "As the ShipGlows operator, I invoke one content lifecycle entrypoint, `007-sg-content repurpose <source>`, to obtain a source-faithful repurpose pack and its governed follow-through without discovering or maintaining a separate `202-sg-repurpose` skill."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - skills/007-sg-content/SKILL.md
  - skills/007-sg-content/references/content-router.md
  - skills/202-sg-repurpose/SKILL.md
  - skills/202-sg-repurpose/references/repurpose-workflow.md
  - skills/202-sg-repurpose/references/output-pack.md
  - skills/references/content-owner-handoffs.md
  - skills/references/repurpose-pack-storage.md
  - skills/references/skill-code-index.md
  - plugins/shipglows/assets/pack-catalog.json
  - shipglows_data/technical/skill-runtime-and-lifecycle.md
  - shipglows-site/src/content/skills/
depends_on:
  - artifact: "skills/references/skill-instruction-layering.md"
    artifact_version: "1.1.0"
    required_status: active
  - artifact: "skills/references/source-faithful-pack-contract.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/source-intake-classification.md"
    artifact_version: "1.4.0"
    required_status: active
  - artifact: "skills/references/content-quality-rubric.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/content-owner-handoffs.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/public-first-content-default.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/repurpose-pack-storage.md"
    artifact_version: "1.0.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-07-17: `sg-repurpose` should become the `repurpose` mode of `sg-content` rather than remain a separate public skill."
  - "`007-sg-content` already exposes `repurpose` in its argument hint and public modes, but currently routes every source-faithful pack to `202-sg-repurpose`."
  - "`202-sg-repurpose` contains the source-faithful, verbatim-preservation, durable-pack, diffusion, safety, and owner-handoff rules that must survive the consolidation."
  - "Active runtime, catalog, site, routing, shared-reference, operator-guide, template, and adjacent-skill surfaces currently expose `202-sg-repurpose` or `sg-repurpose`."
next_step: "none"
---

# Spec: Consolidate `repurpose` Mode Under `007-sg-content`

🟢 [ShipGlows] spec: Consolidate repurpose mode under sg-content | status: shipped | path: shipglows_data/workflow/specs/consolidate-repurpose-mode-under-sg-content.md | next: none

## Title

Consolidate `202-sg-repurpose` as `007-sg-content repurpose`

## Status

Implementation, independent verification, closure bookkeeping, and bounded git shipping are complete. The skill/runtime/public-documentation migration is verified; this does not claim a production content outcome.

## User Story

As the ShipGlows operator, I want `007-sg-content repurpose <source>` to be the single public entrypoint for turning a source into governed reusable content material, so that source-faithful extraction, durable project memory, downstream handoffs, and content-lifecycle routing stay coherent without selecting a second repurposing skill.

## Minimal Behavior Contract

`007-sg-content repurpose <source>` accepts a source, optional declared target, and an optional explicit archival request, validates whether the source is safe to inspect and persist, loads the repurpose playbook and the shared source-faithful contracts, then produces the same governed source-faithful pack, durable-storage decision, existing-content opportunities, diffusion map when justified, evidence ledger, and owner handoffs previously produced by `202-sg-repurpose`. A `verbatim`, `mot pour mot`, or `copie exacte` request remains an archival submode of `repurpose`: it preserves the requested available conversation window exactly under the existing storage rules and does not infer a pack or content strategy. Private, secret, or otherwise non-persistable material is neither written to the governed repository nor exposed in reports, logs, public surfaces, examples, or diagnostics. A missing, unsafe, or too-thin source, undeclared public surface, unsupported claim, absent required playbook, or unavailable governed destination returns the existing visible limit or blocked state without fabricating source truth, public claims, paths, durable files, or a fallback persistence location. `202-sg-repurpose` is then absent as a public/runtime identity and directory, with no permanent alias or compatibility wrapper.

## Success Behavior

- `007-sg-content repurpose <source>` selects one bounded local repurpose playbook, not a retired owner skill and not every content playbook.
- The mode preserves source reconstruction, source-faithful pack ordering, existing-content placement analysis, justified output selection, diffusion-map conditions, safety pass, and owner-handoff payloads from `202`.
- The mode preserves `verbatim`, `mot pour mot`, and `copie exacte` behavior as explicit archival submodes, including exact ordering, speaker boundaries, no editorial inference, and the safe contiguous-window limit.
- When the governed project and source are safe, the mode writes or refreshes the durable pack in `shipglows_data/workflow/repurpose-packs/`; ephemeral, unsafe, wrong-repository, or weak-signal cases retain their present visible outcome and do not silently persist data.
- Source safety is checked before any durable write: private/secret material stays out of repository artifacts, generated public output, logs, diagnostics, fixtures, and migration evidence.
- `007` remains the content lifecycle master: after the pack it routes writing to `200`, enrichment to `201`, docs/governance to `300`, marketing review to exact `009` modes, SEO to `406`, research/veille to `203`/`205`, verification to `103`, and shipping to `005` when applicable.
- Public discovery exposes `sg-content` and its `repurpose` mode as the sole current identity. The site has one canonical `sg-content` page; the former `sg-repurpose` public page is removed and follows the site’s ordinary not-found behavior unless an already-established documented redirect policy says otherwise.
- Active operator instructions, current-user runtimes, pack catalog, code index, help, route maps, templates, and adjacent skills use explicit `007-sg-content repurpose` syntax wherever the command is actionable.

## Error Behavior

- A bare `007-sg-content repurpose` requests a source or prints the bounded repurpose usage; it does not reuse an unrelated previous source, invent an output, or silently switch to drafting.
- A source whose project, downstream surface, angle, or owner route is unsettled triggers the existing source-intake classification before source reconstruction.
- A request for a public article, newsletter, social surface, or other undeclared destination stops at the existing `surface missing` / governed-surface gate rather than inventing a path.
- A source with secrets, private material, copyright constraints, unsupported product claims, missing proof, or insufficient signal is not persisted, logged, exposed, or converted into stronger public claims; the result states only the safe reason and recovery path.
- An unavailable or non-governed destination blocks durable persistence rather than falling back to a home directory, temporary shared location, public artifact, or inferred repository.
- If a request asks to write, apply, audit, enrich, publish, or ship, the repurpose mode produces its bounded pack and explicit owner handoff; it does not claim that downstream files changed before the owner/lifecycle work runs.
- Missing playbook, missing migration-evidence matrix, stale active `202` reference, remaining runtime link, invalid catalog, unresolved public inbound link, or missing public build proof blocks retirement of `202`.
- Historical specs, audits, refresh logs, changelog entries, verbatim packs, research records, archives, source snapshots, and completed evidence are not rewritten merely because they truthfully cite `202-sg-repurpose` or `sg-repurpose`.

## Problem

The content lifecycle exposes a `repurpose` mode but delegates its core source-reuse lane to a separate public support skill, `202-sg-repurpose`. Operators therefore face two public names for one coherent content operation, while active routing, runtime/index, catalog, public pages, shared contracts, guides, templates, and adjacent skills duplicate that boundary. The separate source also owns detailed safeguards that cannot be lost in a cosmetic rename: exact verbatim preservation, source-faithfulness, durable governed memory, public-surface/claim gates, and owner handoffs.

## Solution

Make `007-sg-content` the sole public owner of repurposing through an explicit `repurpose <source>` mode. Move `202`’s local playbooks into `007` as separately loaded repurpose references; keep shared doctrine in its existing canonical references; migrate every active route and discovery surface to the explicit mode; prove source-rule completeness; then retire the `202` directory, public page, code-index/runtime/catalog identity, and current-user links without aliases.

## Scope In

- Compact `007-sg-content` activation contract with exact public grammar: `repurpose <source>` and `help`, preserving its existing lifecycle modes and explicit `repurpose` routing.
- One or more bounded `007`-local repurpose playbooks migrated from `202`’s `repurpose-workflow.md` and `output-pack.md`, with a clear main-playbook selection and no duplicate public invocation key.
- Source-to-destination completeness matrix mapping every `202`-specific rule to the `007` dispatcher, a local playbook, or its canonical shared reference; this includes verbatim behavior, source intake, source-faithful structure, public-first defaults, score gate, durable storage, diffusion, safety, existing-content placement, and owner handoffs.
- Active migrations across `007` routing, shared references, `000`/help discovery where applicable, code index, current-user runtime state, plugin catalog, public site navigation/content, README, canonical technical/editorial/operator docs, templates, active workflow guidance, and adjacent owner handoffs discovered by the inventory.
- Replacement of the public `sg-repurpose` page with an expanded canonical `sg-content` page and updates to related-skill metadata, examples, and mode pages.
- Deletion of `skills/202-sg-repurpose/`, its current-user symlinks/runtime visibility, its public page, and its code-index/catalog rows only after active migration and proof succeed.
- A focused executable contract test, preferably `tools/test_007_sg_content_repurpose_contract.py`, plus maintenance-only migration evidence sufficient to prove grammar, rule transfer, active-name policy, and retired-source absence.
- A reviewed active-versus-historical reference policy: active operator/runtime/public instructions migrate; historical factual records remain readable under a narrow named allowlist.

## Scope Out

- Merging `200-sg-redact` or `201-sg-enrich` into `007` in this change.
- Absorbing `203-sg-research`, `205-sg-veille`, `009-sg-marketing`, `406-sg-seo`, `300-sg-docs`, `emailing`, `103-sg-verify`, or `005-sg-ship`.
- Changing the meaning of content lifecycle modes other than the former `202` ownership boundary.
- Removing verbatim preservation, source-faithfulness, copyright/claim protections, durable-pack storage, public-surface gates, rubric behavior, or owner handoffs to make the new contract shorter.
- Adding permanent wrappers, duplicate picker entries, redirects that act as command aliases, silent fallbacks, or compatibility directories for `202-sg-repurpose`.
- Rewriting historical records, completed specs, audit evidence, refresh-log entries, research, archives, or durable verbatim packs merely to erase old factual names.
- Changing product, editorial, claim-register, source-intake, quality-rubric, storage, lifecycle, or public-route policy beyond the references necessary to make the ownership migration coherent.

## Constraints

- The only canonical public command for this lane is `007-sg-content repurpose <source>`; active instructions must use the full mode syntax rather than an ambiguous bare `007`.
- `007` remains a lifecycle master, not a mega-writing skill. Its `repurpose` mode must select bounded instructions and hand downstream authoring/application to existing owners.
- The new activation body must remain compact. Detailed procedure, transformation catalog, templates, examples, and edge cases live in `007` local playbooks; reusable doctrine stays in shared references.
- `verbatim` is an explicit archival branch inside the repurpose mode, not a public `202` compatibility command and not a source-analysis shortcut.
- Security impact is `yes`: the mode accepts transcripts, notes, URLs, and other potentially private source material and may persist a derived pack. Before source reconstruction, durable write, report generation, test-fixture creation, or diagnostic output, implementation must validate source safety; private/secrets must not be persisted, logged, exposed, or copied into public/runtime/documentation surfaces.
- The migration does not add external APIs, credentials, network collection, auth/authorization, telemetry, or data sharing. It must not introduce a fallback storage location when the governed destination is unavailable; that state is blocked and reported safely.
- Former public URLs must use normal site not-found behavior after removal unless an established, documented site redirect policy applies. A redirect policy, if discovered, must be recorded and validated without restoring an old runtime command.
- Source-directory retirement is the final implementation act. A missing rule or migration proof is repaired in `007` before deletion; it is never solved with a wrapper.
- Existing dirty worktree files are out of scope. Later staging must be hunk-aware and limited to this chantier.

## Test Contract

Proof path: scenario-first, source-completeness, active-surface migration, runtime/catalog, metadata, and public-site evidence.

1. Invocation scenarios: valid `007-sg-content repurpose <source>`; bare `repurpose`; `help`; a normal existing content mode; and malformed mode/source input.
2. Repurpose scenarios: source-faithful pack, existing-content opportunities, justified diffusion map, explicit owner handoff, durable safe pack, ephemeral-only result, unsafe-to-store result, wrong-repository result, and weak-signal result.
3. Verbatim scenarios: `verbatim`, `mot pour mot`, and `copie exacte`; numbered capture; insufficient available context; exact preservation/no analysis; and canonical archival storage naming.
4. Boundary scenarios: a source that needs drafting, enrichment, docs/governance, marketing review, SEO, research, veille, email sequence work, verification, or ship routes to the existing precise owner after or instead of the bounded pack as appropriate.
5. Safety scenarios: missing source, unsettled source classification, undeclared public surface, unsupported claim, secret/private source, copyright constraint, unavailable governed destination, missing required reference, and missing playbook produce the defined visible limit/blocked state without an invented artifact, fallback persistence, source-value logging, or public exposure.
6. Source-completeness proof: every operative rule in `202`’s activation contract and both local references is represented in the `007` dispatcher/playbook/shared reference matrix, with no dropped verbatim, storage, quality, source, claim, handoff, or stop-condition guardrail.
7. Active-surface proof: a focused scan distinguishes active execution/public references from an explicit historical allowlist. No active `202-sg-repurpose`, `sg-repurpose`, `/sg-repurpose`, or old runtime command remains after migration.
8. Retirement proof: `skills/202-sg-repurpose/` and its user-runtime links are absent; `007` and its repurpose mode are present exactly once in the current runtime, code index, catalog, help, and public discovery.
9. Public proof: the canonical `sg-content` page and mode/navigation pages build and link successfully; the former dedicated page is absent from the collection/navigation and has no accidental compatibility route.
10. Mechanical proof: targeted contract test, changed-artifact metadata lint, `audit_shipglows_skills.py`, `skill_budget_audit.py`, `skill_code_index_lint.py`, full runtime sync check, JSON catalog validation, active-name scan, retirement scan, and direct Astro build pass or explicitly block retirement/shipment.

## Dependencies

- `skills/references/skill-instruction-layering.md` — activation/playbook split and compaction discipline.
- `skills/references/source-faithful-pack-contract.md` — canonical pack sections and compression doctrine.
- `skills/references/source-intake-classification.md` — source classification before an unresolved source is interpreted.
- `skills/references/content-quality-rubric.md` — preserved final repurpose quality/status semantics.
- `skills/references/content-owner-handoffs.md` — authoritative post-pack owner matrix and payload.
- `skills/references/public-first-content-default.md` — Diane’s declared-public-surface default.
- `skills/references/repurpose-pack-storage.md` — governed durable-pack path, safe persistence conditions, and ownership transfer.
- `skills/007-sg-content/references/content-router.md`, `skills/200-sg-redact/SKILL.md`, `skills/201-sg-enrich/SKILL.md`, `skills/203-sg-research/SKILL.md`, `skills/205-sg-veille/SKILL.md`, `skills/300-sg-docs/SKILL.md`, `skills/406-sg-seo/SKILL.md`, and `skills/emailing/SKILL.md` — owner boundaries and active handoffs.
- Fresh external docs: `fresh-docs not needed`; this is a local skill-contract, documentation, runtime-index, and public-discovery migration. Repurpose executions retain their existing freshness gates when a source or claim requires them.

## Invariants

- One public repurpose entrypoint: `007-sg-content repurpose <source>`.
- `007-sg-content` remains the content lifecycle master and does not become a replacement for the downstream writing, docs, research, SEO, marketing, verification, or ship owners.
- Every source-faithful, verbatim, storage, safety, claim, quality, and handoff guardrail from `202` survives in an explicit authoritative location.
- No permanent `202` directory, alias, wrapper, hidden runtime link, duplicate picker item, or public compatibility command remains.
- Active references use explicit `007-sg-content repurpose` syntax; historical evidence remains factual and readable.
- Durable packs remain project-governed, versioned, and safe to persist only under their existing storage contract.
- Potentially private source material is safety-classified before processing and never appears in persistence, logs, diagnostics, fixtures, migration evidence, or public content unless the existing governed contract explicitly permits the exact artifact.
- A fresh agent can run the repurpose mode and select its local playbook without reading the retired source directory.

## Links & Consequences

- Runtime and packaging: update `skills/references/skill-code-index.md`, `plugins/shipglows/assets/pack-catalog.json`, `plugins/shipglows/skills/shipglows/references/pack-catalog.md`, and current-user skill symlinks through the canonical sync tool.
- Primary routing: update `skills/007-sg-content/SKILL.md`, `skills/007-sg-content/references/content-router.md`, `skills/references/content-owner-handoffs.md`, `skills/302-sg-help/references/help-catalog.md`, and applicable `000` route/help surfaces so the owner is the exact `007 repurpose` mode.
- Shared doctrine: transfer `202` ownership references in source-intake, public-first, source-faithful, pack-storage, quality-rubric, editorial-corpus, email-storage, and related references to the `007` mode without duplicating their substantive doctrine.
- Adjacent active owners: inventory and migrate handoffs in `200`, `201`, `203`, `205`, `300`, `406`, `emailing`, `800`, `801`, and other current routes that name the retired command.
- Canonical documentation: update active README, `AGENT.md`, business/product context, editorial content map/gates/readme, technical context/runtime documentation, operator cheatsheets, active templates/playbooks/checklists, and task/review guidance where they make an actionable claim about the current command.
- Public discovery: expand `shipglows-site/src/content/skills/sg-content.md`; remove `shipglows-site/src/content/skills/sg-repurpose.md`; update `shipglows-site/src/pages/skills/index.astro`, `shipglows-site/src/pages/skill-modes.astro`, and all active related-skill metadata or examples that expose the retired page.
- Historical handling: existing `shipglows_data/workflow/specs/sg-repurpose-*.md`, repurpose packs, archives, completed audits, refresh-log records, changelog/history, and evidence snapshots are historical by default. The implementation must write a narrow allowlist rather than applying a broad path exclusion that could hide active workflow instructions.

## Documentation Coherence

Public and operator documentation changes are required because this changes a public command and page. The implementation must preserve source-faithful pack language, storage location, public-surface limitations, and downstream-owner boundaries while replacing live command examples with `007-sg-content repurpose <source>`. It must remove the standalone public page rather than documenting two equal entrypoints. Historical documents remain unchanged unless they are currently consumed as active instructions; active-versus-historical classification is proof, not an excuse for a blanket rename.

## Edge Cases

- A source starts with a word that also looks like another `007` mode: explicit `repurpose` takes precedence and the rest is treated as source payload, not a second implicit mode.
- A user requests both exact archival capture and editorial transformation: create the verbatim archive first only when persistence is safe, then require a separate explicit repurpose analysis request or clearly bounded second step; do not contaminate exact preservation with inferred commentary.
- A source is private or secret-bearing, or the governed repository cannot be confirmed: do not copy it into a pack, fixture, log, diagnostic, public output, or fallback location; stop at the safe blocked/ephemeral outcome.
- The runtime sync discovers an old non-symlink file or a conflicting `202` entry: do not overwrite it; classify and resolve it before declaring retirement complete.
- A stale README/spec-like file lives under workflow paths: classify semantic activity rather than assuming all workflow files are historical.
- An old public URL is linked externally: normal site 404 is acceptable only under the recorded public-route policy; no client-side or runtime alias is introduced silently.
- A pack or source contains a factual historical reference to `202`: retain it as provenance; only change the current `source_skill` or active command when the artifact is being legitimately refreshed under the new owner.

## Implementation Tasks

- [ ] Task 1: Freeze the source contract and active-reference inventory.
  - File: `skills/202-sg-repurpose/SKILL.md`, `skills/202-sg-repurpose/references/*.md`, and a new maintenance-only migration-evidence reference under `skills/007-sg-content/references/`
  - Action: Map each source rule to its destination and classify each found reference as active migration target or factual history.
  - User story link: Guarantees no capability is lost while one entrypoint replaces two.
  - Depends on: None.
  - Validate with: Reviewed source-to-destination matrix and focused active-name scan.

- [ ] Task 2: Make `repurpose` a self-owned bounded `007` mode.
  - File: `skills/007-sg-content/SKILL.md` and `skills/007-sg-content/references/content-router.md`
  - Action: Replace the delegation to `202` with exact mode selection, compact activation cues, lifecycle boundaries, verbatim branch, and local-playbook loading.
  - User story link: Lets the operator invoke one content entrypoint.
  - Depends on: Task 1.
  - Validate with: Focused grammar/mode/owner-boundary contract assertions.

- [ ] Task 3: Migrate detailed repurpose instructions into `007` playbooks.
  - File: new `skills/007-sg-content/references/repurpose-*.md` playbooks; shared references remain canonical.
  - Action: Move the source-specific workflow and output-pack narrowing without copying shared doctrine or preserving `202` as an activation identity.
  - User story link: Preserves reliable source-faithful output.
  - Depends on: Tasks 1-2.
  - Validate with: Completeness matrix and playbook-link assertions.

- [ ] Task 4: Transfer shared ownership and active route references.
  - File: active shared references, `000`/help routes, adjacent owner skills, current technical/editorial docs, templates, playbooks, checklists, and guides identified by Task 1.
  - Action: Replace actionable references with the explicit `007-sg-content repurpose` mode while preserving cross-owner boundaries.
  - User story link: Prevents a routed task from landing on a retired command.
  - Depends on: Tasks 2-3.
  - Validate with: Active-versus-historical scan and reviewed allowlist.

- [ ] Task 5: Migrate runtime, catalog, and public discovery.
  - File: code index, plugin catalog/pack reference, runtime sync surfaces, README, public skill content, skills index, skill modes, and related-skill metadata.
  - Action: Expose one canonical public identity and remove standalone `sg-repurpose` discovery after validating inbound active links.
  - User story link: Makes the new command discoverable without duplicate choice.
  - Depends on: Tasks 2-4.
  - Validate with: JSON validation, runtime sync, public-link scan, and Astro build.

- [ ] Task 6: Add mechanical regression proof.
  - File: `tools/test_007_sg_content_repurpose_contract.py` or an equally focused existing contract suite.
  - Action: Assert exact command grammar, single local mode mapping, retained source rules, boundaries, active-name policy, public/runtime identity, and absence of the retired source directory.
  - User story link: Protects the consolidation from future accidental re-fragmentation.
  - Depends on: Tasks 1-5.
  - Validate with: Dedicated test suite passes before retirement and independently at verification.

- [ ] Task 7: Retire the old public/source identity only after proof.
  - File: `skills/202-sg-repurpose/`, its runtime links, and `shipglows-site/src/content/skills/sg-repurpose.md`.
  - Action: Remove the old directory/page/identity without aliases, then rerun migration, retirement, runtime, catalog, and public-build proof.
  - User story link: Completes the one-entrypoint promise.
  - Depends on: Tasks 1-6.
  - Validate with: Filesystem and active-reference absence checks.

## Acceptance Criteria

- [ ] CA 1: Given a valid source, when the operator invokes `007-sg-content repurpose <source>`, then `007` loads the bounded repurpose lane and produces a source-faithful result with no `202` dispatch.
- [ ] CA 2: Given a bare, malformed, missing, unsafe, or too-thin source, when repurpose runs, then it asks or reports the defined visible limit without inventing source truth, claims, surfaces, or stored artifacts.
- [ ] CA 2a: Given a private/secret-bearing source or unavailable governed destination, when repurpose runs, then it does not persist, log, expose, fixture, or relocate source material and returns the safe blocked or ephemeral outcome.
- [ ] CA 3: Given `verbatim`, `mot pour mot`, or `copie exacte`, when repurpose runs, then it preserves the requested available messages exactly with no analysis, and handles a too-large requested window honestly.
- [ ] CA 4: Given a safe source and governed repository, when durable memory is justified, then the repurpose mode writes/refreshes the canonical pack path; given an unsafe, ephemeral, wrong-repo, or weak-signal case, it does not persist a pack and states why.
- [ ] CA 5: Given a downstream writing, enrichment, docs, marketing, SEO, research, veille, email, verification, or ship need, when it follows a repurpose pack, then it routes to the established exact owner without `007` claiming downstream work itself.
- [ ] CA 6: Given the migrated dispatcher and playbooks, when compared with the retired `202` contracts, then every source-specific operational safeguard has an explicit authoritative destination.
- [ ] CA 7: Given active routing, runtime, catalog, operator guides, templates, shared references, adjacent skills, and public content, when scanned after migration, then no actionable old invocation remains outside the approved factual-history allowlist.
- [ ] CA 8: Given historical specs, audits, refresh records, verbatim packs, archives, and evidence that cite `202`, when migration runs, then they remain intact unless they are an active instruction classified in the inventory.
- [ ] CA 9: Given public discovery after migration, when operators browse skills, modes, related skills, and canonical examples, then `sg-content` exposes `repurpose` and `sg-repurpose` is no longer a public skill page or navigation option.
- [ ] CA 10: Given the runtime/catalog after migration, when skills synchronize and pack JSON is validated, then `007` is current, `202` is absent, and no alias or duplicate picker identity resolves.
- [ ] CA 11: Given all changed artifacts, when targeted contract, metadata, audit/budget, code-index, runtime, active-name, retirement, catalog, and direct public-build checks run, then they pass or a named gap blocks closure and ship.

## Test Strategy

- Build scenario-first tests for the invocation, bounded repurpose, verbatim, safety, storage, boundary, public-routing, and retirement cases in `Test Contract`.
- Maintain the source-to-destination matrix as executable-test input or adjacent durable evidence so it proves more than a textual assertion.
- Scan active references with a deliberately narrow history allowlist. Do not exclude all `shipglows_data/workflow/`, because active playbooks, checklists, and task guidance can contain live commands.
- Run `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/specs/consolidate-repurpose-mode-under-sg-content.md` now, then lint every changed governed Markdown during implementation.
- Run `python3 tools/audit_shipglows_skills.py`, `python3 tools/skill_budget_audit.py --skills-root skills --format markdown`, `python3 tools/skill_code_index_lint.py`, and `tools/shipglows_sync_skills.sh --check --all` after runtime migration.
- Run `jq empty plugins/shipglows/assets/pack-catalog.json` when catalog data changes.
- Run `pnpm --dir shipglows-site build` when the declared package-manager engine permits; otherwise run the local direct Astro build and record the engine mismatch instead of claiming the package command passed.

## Risks

- Moving `202` too early could drop nuanced source, storage, verbatim, safety, quality, or handoff behavior; mitigate with the rule-completeness matrix and retirement only after passing proof.
- Putting all detail in `007`’s activation body could create a large, hard-to-follow master; mitigate with a compact dispatcher and local mode playbooks following the design precedent.
- Treating `verbatim` as ordinary repurposing could corrupt an archival request; mitigate with explicit mode precedence and exact-preservation scenarios.
- Broad search-and-replace could erase historical provenance or miss active hidden routes; mitigate with semantic inventory classification, narrow allowlist, and active scans.
- A removed public page could leave a stale internal link or accidental redirect/alias; mitigate with inbound-link checks, collection/build evidence, and explicit normal-not-found policy.
- Runtime/user symlink drift could leave a deleted command callable or a new contract unavailable; mitigate with canonical sync and filesystem proof.
- A source-bearing test, report, migration matrix, or fallback path could leak private material while preserving the mode; mitigate with explicit source-safety classification before every artifact/output path and assertions that blocked sources leave no persisted or logged value.
- Concurrent dirty worktree changes could enter the later migration commit; mitigate with hunk-aware staging and a final cached-diff review.

## Execution Notes

- Read first: `202` activation/local references, `007` activation/router, the source-faithful/source-intake/pack-storage/owner-handoff/public-first/rubric references, `006-sg-design` as compact mode/playbook precedent, code index, pack catalog, public content pages, and all current active `202` occurrences.
- Implement in order: freeze inventory and history policy -> create `007` mode contract -> migrate playbooks -> add contract test/evidence -> migrate active routes/docs/runtime/public discovery -> retire `202` -> sync/check -> independent verification -> closure -> bounded ship.
- Keep reusable doctrine canonical. New `007` playbooks may link to shared contracts but must not fork source intake, pack schema, persistence, quality score, editorial claims, or handoff rules.
- Use full `007-sg-content repurpose <source>` in actionable user-facing text. A neutral historical mention may stay unchanged when it is evidence rather than instruction.
- If a broader content-family consolidation, public redirect policy, new storage policy, or owner-boundary change is discovered, stop and route it through a new or amended spec rather than expanding this migration silently.

## Open Questions

None. The operator explicitly approved the ownership decision: `202-sg-repurpose` becomes the `repurpose` mode of `007-sg-content`; playbooks and references retain the specialist detail; `202` has no permanent alias; historical citations remain factual history.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-17 08:45:22 | 100-sg-spec | GPT-5 Codex | Created the durable consolidation contract after inspecting the current `007` and `202` contracts, local/shared references, runtime/catalog, public pages, active routing/docs inventory, and historical predecessor specs without changing active surfaces. | Draft spec saved; no implementation started. | `/101-sg-ready consolidate repurpose mode under sg-content` |
| 2026-07-17 08:49:51 | 100-sg-spec | GPT-5 Codex | Repaired the draft after the `101` security finding: marked source-handling impact as `yes` and made source safety, no-persistence/no-log/no-exposure, and governed-destination blocking explicit in the behavior, constraints, proof, and acceptance contract. | Draft repaired; fresh readiness review required. | `/101-sg-ready consolidate repurpose mode under sg-content` |
| 2026-07-17 08:51:22 | 101-sg-ready | GPT-5 Codex | Re-ran the strict readiness gate against the repaired contract, including source-bearing security controls, no-fallback persistence, user-story traceability, task order, active-surface consequences, acceptance criteria, and proof. | Ready; no implementation performed by the gate. | `/102-sg-start consolidate repurpose mode under sg-content` |
| 2026-07-17 09:01:18 | 102-sg-start | GPT-5 Codex | Consolidated the public repurpose identity into the bounded `007-sg-content repurpose <source>` mode, transferred its local playbook and rule matrix, migrated active routing/runtime/catalog/public discovery, added scenario-first contract proof, and retired the source directory and public page without an alias. | implemented; targeted contract, catalog JSON, active-name, retired-runtime-link, and full sync checks passed. | `/103-sg-verify consolidate repurpose mode under sg-content` |
| 2026-07-17 09:05:39 | 900-shipglows-core | GPT-5 Codex | Conservatively refreshed the migrated `007` repurpose mode against its playbook, transfer matrix, shared source/storage/handoff contracts, and active public surface. | Refreshed; one stale duplicate report template removed, with no repurpose safeguard or mode change. | `/103-sg-verify consolidate repurpose mode under sg-content` |
| 2026-07-17 09:10:30 | 103-sg-verify | GPT-5 Codex | Independently checked the `007` dispatcher/playbook/matrix against the retired `202` contract, source-safety and owner boundaries, runtime/catalog/code-index state, active versus historical references, metadata, audit/budget, sync, public build, and diff hygiene. | not verified: the active public skills index still advertises `sg-repurpose`, and Claude/Codex each retain a dangling `202-sg-repurpose` current-user runtime symlink. The focused test passes but does not scan the `sg-repurpose` alias, so it cannot prove the required active-name retirement. | `/102-sg-start repair active public/runtime retirement evidence, then rerun /103-sg-verify` |
| 2026-07-17 09:13:00 | 102-sg-start | GPT-5 Codex | Repaired post-verify retirement evidence: replaced the public `sg-repurpose` index entry with `sg-content repurpose`, removed the two explicit dangling current-user runtime symlinks, and expanded the focused contract scan to reject `sg-repurpose`. | implemented; focused test and direct retirement proofs rerun. | `/103-sg-verify consolidate repurpose mode under sg-content` |
| 2026-07-17 10:26:10 | 103-sg-verify | GPT-5 Codex | Re-ran independent scenario-first verification after the targeted retirement repair, including the `007` contract/playbook/matrix and source-safety/owner boundaries; public active-name scan; absent source/page/runtime identities; focused test; governed metadata; catalog; audit/budget; runtime sync; code-index baseline review; direct Astro build; and diff hygiene. | verified: `sg-repurpose` is absent from active public surfaces, the two stale runtime symlinks are absent, and the focused regression test now rejects the alias. | `/104-sg-end consolidate repurpose mode under sg-content` |
| 2026-07-17 10:27:59 | 104-sg-end | GPT-5 Codex | Closed the verified skill/runtime/public-documentation migration in the canonical spec, task registry, and changelog without claiming a production content outcome or ship status. | closed: durable closure surfaces now match the verified scope; bounded git shipping remains. | `/005-sg-ship consolidate repurpose mode under sg-content` |
| 2026-07-17 10:30:20 | 005-sg-ship | GPT-5 Codex | Re-ran the focused `007` repurpose contract, runtime sync, and catalog validation; confirmed that the previously committed migration is already on `origin/main`, then staged only its durable closure traces. | shipped: closure traces are committed and pushed without taking unrelated concurrent work into the index. | none |

## Current Chantier Flow

- `100-sg-spec`: ready — durable mode, transfer, retirement, historical-treatment, security, public-route, and proof contract recorded.
- `101-sg-ready`: ready — security controls, no-fallback persistence, scope, task ordering, and proof contract passed.
- `102-sg-start`: implemented — original consolidation plus targeted public/runtime retirement-evidence repair completed.
- `900-shipglows-core refresh`: completed — conservative evidence review passed; reporting contract deduplicated with no mode or safeguard change.
- `103-sg-verify`: verified — contract, retired-identity, public, runtime, metadata, catalog, sync, and direct-build proof passed; unrelated code-index and 205-size baselines classified separately.
- `104-sg-end`: closed — canonical spec, task registry, and changelog record the verified skill/runtime/public-documentation migration without a ship or production-content-outcome claim.
- `005-sg-ship`: shipped — the already-published bounded migration and its closure traces are committed and pushed; unrelated concurrent work remains out of scope.

Next command: none
