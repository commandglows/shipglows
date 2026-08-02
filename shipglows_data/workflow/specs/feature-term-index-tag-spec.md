---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.1.0"
project: "ShipGlows"
created: "2026-07-07"
created_at: "2026-07-07 17:45:00 UTC"
updated: "2026-07-11"
updated_at: "2026-07-11 20:41:00 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "technical-navigation"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows, je veux pouvoir prefixer un terme par `#feature:` pour indiquer explicitement qu'il s'agit d'une entree de navigation technique issue d'un behavior index, afin que l'agent charge le bon contexte sans repartir dans une recherche large."
confidence: high
risk_level: medium
security_impact: no
docs_impact: yes
linked_systems:
  - "skills/references/entrypoint-routing.md"
  - "skills/references/code-navigation-and-function-docs.md"
  - "skills/references/technical-docs-corpus.md"
  - "skills/references/shipglows-terms.md"
  - "shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md"
  - "shipglows_data/technical/context.md"
  - "shipglows_data/technical/context-function-tree.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "skills/302-sg-help/SKILL.md"
  - "skills/300-sg-docs/SKILL.md"
depends_on:
  - artifact: "skills/references/entrypoint-routing.md"
    artifact_version: "1.5.0"
    required_status: "active"
  - artifact: "skills/references/code-navigation-and-function-docs.md"
    artifact_version: "1.0.0"
    required_status: "active"
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.7.0"
    required_status: "active"
  - artifact: "skills/references/shipglows-terms.md"
    artifact_version: "1.2.0"
    required_status: "active"
  - artifact: "shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md"
    artifact_version: "1.3.0"
    required_status: "reviewed"
  - artifact: "shipglows_data/technical/context.md"
    artifact_version: "0.6.0"
    required_status: "draft"
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.5.0"
    required_status: "reviewed"
supersedes: []
evidence:
  - "User proposal 2026-07-05: use `#feature:swipe` to indicate an index term explicitly."
  - "User request 2026-07-07: rename SF to SG and Shipglows to ShipGlows."
  - "Existing navigation doctrine already defines context -> function-tree -> code-docs-map -> behavior-index recovery, but not an explicit inline hint syntax."
next_step: "none"
---

# Spec: Feature Tag For Behavior-Index Navigation

## Title

Feature Tag For Behavior-Index Navigation

## Status

Ready.

## User Story

En tant qu'operatrice ShipGlows, je veux pouvoir prefixer un terme par `#feature:` pour indiquer explicitement qu'il s'agit d'une entree de navigation technique issue d'un behavior index, afin que l'agent charge le bon contexte sans repartir dans une recherche large.

## Minimal Behavior Contract

Quand un message contient `#feature:<term>`, ShipGlows doit traiter `<term>` comme un hint explicite de navigation technique. La recherche doit suivre la couche existante dans cet ordre: `context.md` -> `context-function-tree.md` -> `code-docs-map.md` -> behavior index ou domain-model doc. Le tag ne remplace pas le texte libre du message; il sert a lever l'ambiguite et a donner une priorite de routage, pas a lancer un second langage de commande.

Le parseur doit n'accepter que la forme explicite `#feature:<term>` sans espace entre le `:` et le terme, normaliser le terme pour la recherche d'index, ignorer les variants mal formes, et supporter plusieurs tags distincts dans un meme message. Si le terme est ambigu, l'agent doit exposer les sens nommes. Si le terme n'est pas mappe, l'agent doit remonter un `technical navigation bootstrap gap` ou un `technical navigation drift`, pas repartir silencieusement en exploration brute.

## Success Behavior

- Given a user writes `#feature:swipe`, when the project has a mapped behavior index, then the agent loads the IME gesture behavior doc before broad repo search and resolves the named meanings before opening code.
- Given a user writes `#feature:auth`, when multiple auth behavior docs exist, then the agent presents the candidate meanings or chooses the canonical one only if the mapping is already explicit.
- Given a user writes both free text and `#feature:<term>`, when the request is executed, then the tag acts as a high-priority context hint rather than replacing the rest of the instruction.
- Given no `#feature:` tag is present, when the user writes a known operator term, then the current automatic recovery path still works; the tag is optional, not mandatory.
- Given two valid `#feature:` tags appear in one message, when the terms point to separate behavior families, then the agent keeps both candidates visible instead of flattening them into one meaning.

## Error Behavior

- If `#feature:<term>` points to no mapped behavior artifact, the agent reports `technical navigation bootstrap gap` and routes to `/300-sg-docs technical`.
- If the tag resolves to stale files, stale symbols, or a missing behavior doc, the agent reports `technical navigation drift`.
- If multiple `#feature:` tags conflict materially, the agent asks a narrow clarification or scopes them deterministically instead of blending unrelated surfaces.
- If a message uses malformed syntax such as `#feature:` with no term, the tag is ignored and the agent reports that no usable feature token was provided.
- If the requested term is valid but the project has no behavior index for that family, the agent prefers the bootstrap-gap classification instead of inventing a mapping from conversation history.

## Problem

The current navigation doctrine can already recover from operator terms, but it still relies on inference from ordinary language. In some cases the operator may want to force the interpretation: "this word is an indexed technical feature term, treat it as such first." Without a small explicit syntax, the agent may still spend effort deciding whether a word is vague prose, a product term, or a behavior-index entry, and that rediscovery cost repeats across threads.

## Solution

Add an optional `#feature:<term>` inline hint with a deliberately narrow contract:

1. It is a navigation hint, not a command language.
2. It has priority over broad search.
3. It does not replace existing automatic term recovery.
4. It integrates first into the ShipGlows context and routing stack, then into help text and docs.
5. It stays aligned with the existing behavior-index owner model rather than creating a parallel registry.

## Scope In

- Define the syntax and meaning of `#feature:<term>`.
- Define parsing and precedence rules for the ShipGlows context and routing stack.
- Define fallback behavior for unmapped, stale, ambiguous, or malformed tokens.
- Define interaction with existing context maps and behavior indexes.
- Define whether one message may contain multiple feature tags and how to handle them.

## Scope Out

- No general query language with `#area`, `#module`, `#path`, or other tag families in this first pass.
- No replacement of natural-language term recovery.
- No requirement that every governed project immediately supports feature tags.
- No automatic creation of behavior indexes during normal task execution.
- No change to `%Profile` or other named-profile syntax.

## Constraints

- The syntax must remain optional.
- The feature tag must reduce ambiguity rather than create a second navigation system.
- Existing context maps remain authoritative for their current roles.
- The implementation should be conservative: parse only explicit `#feature:<term>` tokens, not approximate variants.
- The lookup should normalize for routing but preserve the user-facing token text for feedback.
- The tag should bias route selection, not bypass safety, permissions, or proof requirements.

## Security Rationale

- `#feature:<term>` is a routing hint only; it does not execute code, create files, mutate state, or widen permissions.
- Malformed or empty tokens are ignored instead of being interpreted as instructions.
- The tag can only bias which owned docs or behavior indexes are read first; it cannot override authorization, tenant boundaries, or execution safety checks.
- Ambiguous terms resolve to named meanings or a clarification prompt, which is safer than broad blind search.
- `security_impact: no` is appropriate because the change is limited to local parser precedence and documentation routing, with no new external side effects.

## Test Contract

### Surface

- Stack/surface: `ShipGlows context priming and technical navigation`
- Primary proof mode: `scenario-first`
- Proof order: parser/contract checks -> context-loading checks -> ambiguity/unmapped-term checks -> docs-coherence checks

### Required scenarios

- `#feature:swipe` resolves to the ShipGlows IME behavior index.
- `#feature:auth` routes to the canonical auth behavior map when present.
- missing-map case produces `technical navigation bootstrap gap`.
- stale-map case produces `technical navigation drift`.
- ordinary `swipe` without tag still keeps the existing automatic recovery path.
- malformed `#feature:` is ignored and leaves the free-text request intact.
- multiple valid feature tags in one message remain individually recoverable.

### Required results

- The agent loads the behavior index or domain model before broad repo search when the term is mapped.
- The agent names ambiguities instead of flattening multiple meanings.
- The agent reports bootstrap gap or drift instead of inventing a mapping.
- The tag stays optional and does not break ordinary language recovery.
- For the IME/swipe family, the canonical behavior-index source is `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md`.

### Proof exception

- `exception_without_proof`: none. This spec expects scenario evidence and docs-coherence evidence before readiness.

## Dependencies

- `skills/references/entrypoint-routing.md`
- `skills/references/technical-docs-corpus.md`
- `skills/references/code-navigation-and-function-docs.md`
- `skills/references/shipglows-terms.md`
- `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md`
- `shipglows_data/technical/context.md`
- `shipglows_data/technical/context-function-tree.md`
- `shipglows_data/technical/code-docs-map.md`
- `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md` for the IME/swipe pilot family.
- `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md` for the IME/swipe pilot family routing.
- Existing project behavior indexes such as the IME gesture mapping family.
- This spec intentionally spans two corpus roots: ShipGlows routing docs live under `/home/claude/shipglows`, while the IME/swipe pilot corpus lives under `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/`.
- The migrated pilot files are part of the canonical ShipGlows corpus for this spec.
- The original files under `/home/claude/winglowz/shipglows_data/technical/winglowz_app/` are migration evidence only.

## Invariants

- `#feature:<term>` is an optional hint, not a required invocation syntax.
- Behavior indexes remain the canonical term-recovery owner artifacts.
- Broad repo search is not the first step when a valid mapped feature tag exists.
- Existing context layers keep their roles.
- The tag does not replace the operator's plain-language request; it only sharpens its interpretation.
- Exact syntax and exact meaning must stay visible in docs so fresh agents do not infer a broader tag language.

## Links & Consequences

- Upstream:
  - operator prompts that use `#feature:<term>`
  - `skills/references/shipglows-terms.md` for shared terminology
  - `skills/references/entrypoint-routing.md` for the current tag-driven routing posture
- Downstream:
  - `skills/302-sg-help/SKILL.md` for help wording and examples
  - `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md` for the tag catalog
  - `shipglows_data/technical/context.md` for operator-facing navigation guidance
  - `shipglows_data/technical/code-docs-map.md` if a term family gains a mapped docs route or reveals drift
- Cross-validations:
  - behavior index entries for the term family
  - source comments on dense symbols reached from the index
  - tests or proof scenarios that demonstrate ambiguity handling and drift handling

## Documentation Coherence

- Update `skills/references/shipglows-terms.md` to define `#feature:` as a navigation hint tag family.
- Update `skills/references/entrypoint-routing.md` so the tag is read before broad search and remains distinct from `%Profile`.
- Update `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md` so operators can discover the syntax and its canonical source.
- Update `skills/302-sg-help/SKILL.md` with a concise explanation and example.
- Update `shipglows_data/technical/context.md` if the operator-facing navigation summary should mention the new hint.
- `None` for public-content surfaces unless the project later decides to expose the syntax externally.

## Edge Cases

- `#feature:` with no term: ignore the tag and continue on free text.
- `#feature:   swipe`: reject the malformed token, do not silently trim past a missing term.
- `#feature:Swipe`: normalize for lookup, preserve the displayed token in feedback.
- `#feature:swipe #feature:gesture`: keep both candidate families visible until the route is unambiguous.
- `#feature:swipe` in a project with no swipe index: report bootstrap gap.
- `#feature:swipe` when the mapped files are stale: report drift.
- `swipe` without a tag: keep the current natural-language recovery path.
- Mixed free text and tag: the free text remains part of the request; the tag only biases navigation.

## Implementation Tasks

1. `skills/references/entrypoint-routing.md`: add `#feature:` to the focus-tag family and define its precedence relative to broad search, plain-language recovery, and `%Profile`. Validation: `rg -n "#feature:|%Profile|focus-tag" skills/references/entrypoint-routing.md`.
2. `skills/references/shipglows-terms.md`: register `#feature:` as the canonical navigation-hint tag family and point to the routing contract. Validation: `rg -n "#feature:|navigation-hint|routing contract" skills/references/shipglows-terms.md`.
3. `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md`: document the tag in the user-facing tag catalog with one concrete example. Validation: `rg -n "#feature:|feature tag" shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md`.
4. `skills/references/code-navigation-and-function-docs.md`: add explicit guidance that a valid `#feature:<term>` should enter the behavior-index layer before broad repository search. Validation: `rg -n "#feature:|behavior index|broad repo search" skills/references/code-navigation-and-function-docs.md`.
5. `skills/302-sg-help/SKILL.md`: add the short help note that explains when to use `#feature:<term>` and when not to. Validation: `rg -n "#feature:|help|focus tag" skills/302-sg-help/SKILL.md`.
6. `shipglows_data/technical/context.md`: add or adjust the operator-facing navigation summary so the tag is discoverable from the technical context map. Validation: `rg -n "#feature:|behavior index|context" shipglows_data/technical/context.md`.
7. `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md`: confirm the alias table, ambiguity handling, and `swipe` recovery chain for the canonical IME pilot family. Validation: `rg -n "swipe|alias|ambiguity|primary entrypoint|recovery" /home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md`.
8. `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md`: confirm the behavior index is linked from the map and that the docs route is explicit. Validation: `rg -n "ime-gesture-model|swipe" /home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md`.
9. Routing proof: read the `Recovery Path` block from the IME behavior index, then confirm it points to the code-docs map and entrypoints before any broad search. Validation: `sed -n '1,220p' /home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md` and `sed -n '1,220p' /home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md`.
10. Validation pass: run lint and search checks after the edits. Validation: `python3 /home/claude/shipglowz/tools/shipglows_metadata_lint.py /home/claude/shipglowz/AGENT.md /home/claude/shipglowz/shipglows_data` and `rg -n "#feature:" /home/claude/shipglowz/skills /home/claude/shipglowz/docs /home/claude/shipglowz/shipglows_data`.

## Acceptance Criteria

- [ ] AC 1: Given a valid `#feature:<term>`, the agent prioritizes mapped navigation artifacts before broad search.
- [ ] AC 2: Given an ambiguous mapped term, the agent exposes the candidate meanings instead of flattening them.
- [ ] AC 3: Given an unmapped term, the agent reports `technical navigation bootstrap gap`.
- [ ] AC 4: Given stale mappings, the agent reports `technical navigation drift`.
- [ ] AC 5: Given no tag, the current natural-language recovery path still works.
- [ ] AC 6: The first implementation introduces no broader tag language beyond `#feature:<term>`.
- [ ] AC 7: The tag is discoverable in the ShipGlows help or cheatsheet docs, not only in code.
- [ ] AC 8: The tag remains distinguishable from `%Profile` and other router-layer constructs.

## Risks

- Risk: the tag becomes a crutch and weakens normal natural-language recovery.
  - Mitigation: keep it optional and document it as an override, not the primary path.
- Risk: more tags proliferate too early.
  - Mitigation: explicitly limit V1 to `#feature:<term>`.
- Risk: parsing stays underspecified and causes inconsistent routing.
  - Mitigation: keep the parser narrow and deterministic.
- Risk: operators confuse `#feature:` with named profiles or business focus tags.
  - Mitigation: document the difference in `entrypoint-routing` and `302-sg-help`.

## Recommended Implementation Plan

1. Update `skills/references/entrypoint-routing.md` to recognize explicit `#feature:<term>` tokens and explain precedence.
2. Update `skills/references/shipglows-terms.md` and `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md` so the tag is canonical and discoverable.
3. Update `skills/references/code-navigation-and-function-docs.md` and `shipglows_data/technical/context.md` so the tag is integrated into the navigation stack.
4. Update `skills/302-sg-help/SKILL.md` with the short operator-facing explanation and example.
5. Validate normal, ambiguous, malformed, and unmapped behavior with scenario-style proof.

## Test Strategy

- Contract check: confirm the tag grammar is exact, optional, and non-destructive.
- Scenario check: exercise `#feature:swipe`, `#feature:auth`, malformed input, multiple tags, and no-tag fallback.
- Docs-coherence check: verify the tag is discoverable from help, terms, and routing docs.
- Drift check: verify the spec names bootstrap gap and drift separately and does not silently invent a mapping.
- Stop condition: if the implementation would require a second tag family or a public syntax expansion, stop and return to spec update instead of widening V1.

## Execution Notes

- Read order: `skills/references/entrypoint-routing.md` -> `skills/references/code-navigation-and-function-docs.md` -> `skills/references/shipglows-terms.md` -> `shipglows_data/technical/operator-guides/focus-tags-cheatsheet.md` -> `skills/302-sg-help/SKILL.md` -> `shipglows_data/technical/context.md`.
- Keep the change narrow: update the canonical routing docs first, then propagate wording to help and context surfaces.
- Treat `/home/claude/shipglows` as the ShipGlows routing corpus and `/home/claude/shipglowz/shipglows_data/technical/winglowz_app/` as the canonical pilot corpus for `swipe`.
- Treat the ShipGlows corpus as the source of truth for both the routing rule and the migrated pilot artifacts.
- Do not create a new tag language beyond `#feature:<term>` in this pass.
- Do not replace the behavior index with comments or a one-off route table.
- Validation commands:
  - `python3 /home/claude/shipglowz/tools/shipglows_metadata_lint.py /home/claude/shipglowz/AGENT.md /home/claude/shipglowz/shipglows_data`
  - `rg -n "#feature:" /home/claude/shipglowz/skills /home/claude/shipglowz/docs /home/claude/shipglowz/shipglows_data`
  - `rg -n "behavior index|context-function-tree|code-docs-map|technical navigation bootstrap gap|technical navigation drift" /home/claude/shipglowz/skills /home/claude/shipglowz/shipglows_data`
  - `rg -n "swipe|alias|ambiguity|primary entrypoint|recovery" /home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md`
  - `rg -n "ime-gesture-model|swipe" /home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md`
  - `sed -n '1,220p' /home/claude/shipglowz/shipglows_data/technical/winglowz_app/ime-gesture-model.md`
  - `sed -n '1,220p' /home/claude/shipglowz/shipglows_data/technical/winglowz_app/code-docs-map.md`
- Stop if a doc path no longer exists under the ShipGlows corpus and route that mismatch back into canonical-path cleanup before expanding scope.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-07-07 17:45:00 UTC | 100-sg-spec | GPT-5 Codex | Created a standalone spec at the user home root for the optional `#feature:<term>` navigation hint, decoupled from renamed repo paths | draft | /101-sg-ready Feature Tag For Behavior-Index Navigation |
| 2026-07-07 17:52:05 UTC | 100-sg-spec | GPT-5 Codex | Corrected the spec for the ShipGlows / SG naming change and expanded it to satisfy the readiness gate | draft | /101-sg-ready Feature Tag For Behavior-Index Navigation |
| 2026-07-07 17:57:02 UTC | 101-sg-ready | GPT-5 Codex | Readiness review completed against local criteria after naming correction | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-07 18:01:32 UTC | 101-sg-ready | GPT-5 Codex | Re-reviewed after latest fixes; canonical IME/swipe source naming and task-level validation coverage still do not resolve cleanly | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-07 18:05:18 UTC | 101-sg-ready | GPT-5 Codex | Final re-review confirmed the spec still spans two roots: the IME/swipe canonical source path is external to the current workspace and the spec does not fully self-anchor for a fresh agent | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:10:19 UTC | 101-sg-ready | GPT-5 Codex | Final readiness review after path corrections and routing-proof addition; the proof path is concrete, but the spec still depends on an external authoritative corpus that conflicts with canonical path doctrine for a fresh agent | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:13:40 UTC | 101-sg-ready | GPT-5 Codex | Fresh readiness review after the latest corrections; the legacy IME/swipe evidence is now read-only, but the spec remains a migration-root artifact instead of a canonical ShipGlows spec corpus entry, so a fresh agent still lacks a clean handoff path | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:15:46 UTC | 101-sg-ready | GPT-5 Codex | Fresh readiness review on the current spec; the proof path is concrete, but the spec still depends on an external legacy corpus outside the canonical ShipGlows governance root, so a fresh agent does not get a fully canonical handoff path | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:19:05 UTC | 101-sg-ready | GPT-5 Codex | Fresh readiness review after the canonical-pilot migration into the ShipGlows corpus; the spec still points execution notes and validation at legacy `/home/claude/winglowz/...` paths, so a fresh agent does not yet have a fully canonical handoff path | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:22:44 UTC | 101-sg-ready | GPT-5 Codex | Fresh readiness review after the validation-path corrections; canonical paths are now coherent, but the spec still lacks an explicit security rationale for a prompt/routing change, so the handoff is not yet clean for /102-sg-start | not ready | /100-sg-spec Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:24:51 UTC | 101-sg-ready | GPT-5 Codex | Final readiness review after the explicit security rationale and root-copy sync; canonical paths, autonomy, and security rationale are now aligned for /102-sg-start | ready | /102-sg-start Feature Tag For Behavior-Index Navigation |
| 2026-07-11 17:24:51 UTC | 102-sg-start | GPT-5 Codex | Implemented the optional `#feature:<term>` routing hint across the routing docs, terminology docs, help surface, context summary, docs map, and IME behavior index trace | implemented | /103-sg-verify Feature Tag For Behavior-Index Navigation |
| 2026-07-11 19:41:00 UTC | 103-sg-verify | GPT-5 Codex | Verified the `#feature:<term>` navigation-hint implementation with metadata lint, skill sync, diff checks, and targeted rg proof across routing, help, context, and IME recovery surfaces | verified | /104-sg-end Feature Tag For Behavior-Index Navigation |
| 2026-07-11 20:41:00 UTC | 104-sg-end | GPT-5 Codex | Closed the chantier bookkeeping, updated TASKS and CHANGELOG, and prepared the spec for ship | closed | /005-sg-ship Feature Tag For Behavior-Index Navigation |
| 2026-07-11 20:41:00 UTC | 005-sg-ship | GPT-5 Codex | Shipped the full-close bookkeeping for the `#feature:<term>` navigation-hint chantier; commit and push complete | shipped | none |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created and corrected for ShipGlows naming.
- `101-sg-ready`: not ready, the proof path is concrete but still depends on an external authoritative corpus, so the spec is not fully self-anchoring for a fresh agent.
- `101-sg-ready`: not ready, the spec still sits at a migration root instead of the canonical ShipGlows spec corpus, so a fresh agent does not get a clean `/102-sg-start` handoff.
- `101-sg-ready`: not ready, the current proof path is concrete, but it still reaches into an external legacy corpus outside the canonical ShipGlows governance root.
- `101-sg-ready`: not ready, execution notes and validation still reference legacy `/home/claude/winglowz/...` paths instead of only the canonical ShipGlows corpus paths.
- `101-sg-ready`: not ready, the canonical path corrections are in place, but the spec still lacks an explicit security rationale for a prompt/routing change, so autonomous handoff remains incomplete.
- `101-sg-ready`: ready, canonical paths are coherent, the root copy is synced, and the explicit security rationale keeps the prompt/routing change within the autonomous handoff envelope.
- `102-sg-start`: implemented.
- `103-sg-verify`: verified, the implementation was checked with lint, sync, diff, and targeted routing proof.
- `104-sg-end`: closed, TASKS and CHANGELOG bookkeeping are updated.
- `005-sg-ship`: shipped, commit and push are complete.

Next step: `none`
