---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: "ShipGlows"
created: "2026-06-30"
created_at: "2026-06-30 13:47:10 UTC"
updated: "2026-06-30"
updated_at: "2026-06-30 14:02:30 UTC"
status: ready
source_skill: 100-sg-spec
source_model: "GPT-5 Codex"
scope: "documentation-governance"
owner: "Diane"
user_story: "En tant qu'operatrice ShipGlows qui pilote un portefeuille d'au moins 20 sites et apps avec des agents, je veux un systeme global de navigation et de documentation du code, afin qu'un agent puisse partir d'un terme fonctionnel comme swipe, sync, checkout ou auth et retrouver rapidement les comportements, fonctions, decisions, tests et docs associes sans refaire une enquete a chaque fois."
confidence: high
risk_level: high
security_impact: yes
docs_impact: yes
linked_systems:
  - "skills/300-sg-docs/SKILL.md"
  - "skills/301-sg-context/SKILL.md"
  - "skills/references/technical-docs-corpus.md"
  - "skills/references/documentation-governance-rules.md"
  - "skills/references/project-governance-rules.md"
  - "shipglows_data/technical/code-docs-map.md"
  - "shipglows_data/technical/README.md"
  - "templates/technical_module_context.md"
  - "templates/decision_record.md"
  - "tools/shipglows_metadata_lint.py"
  - "WinFlowz"
depends_on:
  - artifact: "shipglows_data/workflow/specs/shipglows-technical-documentation-layer-for-ai-agents.md"
    artifact_version: "1.0.2"
    required_status: ready
  - artifact: "skills/references/technical-docs-corpus.md"
    artifact_version: "1.7.0"
    required_status: active
  - artifact: "skills/references/documentation-governance-rules.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "skills/references/project-governance-rules.md"
    artifact_version: "1.0.0"
    required_status: active
  - artifact: "shipglows_data/technical/code-docs-map.md"
    artifact_version: "1.5.0"
    required_status: reviewed
  - artifact: "skills/references/documentation-freshness-gate.md"
    artifact_version: "1.2.0"
    required_status: active
supersedes: []
evidence:
  - "Operator request 2026-06-30: a portfolio-scale system is needed because the operator has at least 20 sites and this is full-time work, so a smallest local WinFlowz file is insufficient."
  - "WinFlowz investigation 2026-06-29: the IME long-press swipe dispatch behavior required manual search across WinFlowzKeyboardView.kt, KeyboardLongPressSwipePolicy.kt, docs, specs, and bugs."
  - "Existing ShipGlows technical layer already provides path -> doc mapping, but it does not define a portfolio-wide term -> behavior -> function navigation contract."
  - "Fresh-docs checked 2026-06-30: Diataxis official docs for documentation type separation; C4 Model official docs for maps of code; arc42 official docs for structured architecture documentation; Kotlin Dokka/KDoc official docs for generated API/comment documentation."
  - "Operator clarification 2026-07-01: existing context maps already exist and must be integrated into the future system rather than removed or replaced."
next_step: "/102-sg-start ShipGlows Code Navigation And Function Documentation System"
---

# Spec: ShipGlows Code Navigation And Function Documentation System

## Title

ShipGlows Code Navigation And Function Documentation System

## Status

Ready.

This chantier extends the existing ShipGlows technical documentation layer. It does not replace `shipglows_data/technical/code-docs-map.md`; it adds the missing navigation contract that starts from operator language or product behavior and lands on the right code, comments, decisions, tests, and docs.

## User Story

En tant qu'operatrice ShipGlows qui pilote un portefeuille d'au moins 20 sites et apps avec des agents, je veux un systeme global de navigation et de documentation du code, afin qu'un agent puisse partir d'un terme fonctionnel comme swipe, sync, checkout ou auth et retrouver rapidement les comportements, fonctions, decisions, tests et docs associes sans refaire une enquete a chaque fois.

## Minimal Behavior Contract

ShipGlows must provide a portfolio-scale code navigation standard where every governed code project maps operator terms and product behaviors to canonical technical docs, behavior references, code entrypoints, key functions/classes, tests, specs, bugs, and decisions. The existing `context.md`, `context-function-tree.md`, and `code-docs-map.md` layers remain in place and receive clearer roles inside that system: system overview, structural overview, and path-to-doc routing. When an agent receives a term such as `swipe`, it first checks the project's technical navigation artifacts, resolves ambiguous meanings into named behaviors, opens the mapped code and docs, and reports any missing coverage as a governance gap. If a term is unmapped, the system must guide the agent to create or route a bounded documentation update instead of silently rediscovering the same code later; the easy-to-miss edge case is that one word can represent several different behaviors across one project or across the portfolio.

## Success Behavior

- Given an operator says "regarde la fonction swipe" in a governed project, when the agent loads the technical navigation layer, then it can distinguish `swipe-corner`, `long-press swipe dispatch`, `space slider`, and `row scroll` instead of treating `swipe` as a single function.
- Given a codebase contains a high-complexity module, when `300-sg-docs technical audit` runs, then it verifies that the module has path mapping, behavior mapping, source-comment coverage for high-cognitive-load functions, linked tests, and decision records for durable design choices.
- Given a fresh agent starts a code task, when it opens `shipglows_data/technical/code-docs-map.md`, then the map points not only to the primary subsystem doc but also to behavior indexes or domain-model docs when the subsystem needs concept-level recovery.
- Given a function has non-obvious arbitration, side effects, state ownership, security constraints, or dispatch behavior, when the agent opens the code, then KDoc/JSDoc/Python docstring or equivalent comments identify the contract, invariants, and related symbols without duplicating the implementation.
- Given a behavior exists because of an architectural/product decision, when the agent inspects the behavior reference, then it can open the relevant ADR/decision record rather than reconstructing rationale from old specs and bug files.
- Given the system is piloted on WinFlowz, when an agent investigates IME gestures, then `ime-gesture-model.md` or the equivalent behavior reference links directly to `WinFlowzKeyboardView.kt`, `KeyboardLongPressSwipePolicy.kt`, gesture tests, bugs, and specs.

## Error Behavior

- If a user term is ambiguous and no behavior map exists, the agent must say which meanings were found and classify the gap as `technical navigation bootstrap gap`.
- If a mapped behavior points to missing files, renamed functions, deleted tests, stale specs, or obsolete decisions, `300-sg-docs technical audit` reports drift and blocks a clean documentation verdict.
- If an implementation changes behavior but leaves the behavior index, code-docs map, comments, tests, or decision references stale, verification reports a documentation coherence gap.
- If comments contradict code or canonical docs, code wins temporarily and the canonical docs/comments must be corrected in the same workstream or with an explicit no-impact justification.
- If a generated documentation tool such as Dokka is not installed or not appropriate for a stack, the system must not invent a tooling dependency; it records the stack-specific comment convention and uses generated docs only where they replace real navigation friction.
- If a documentation artifact would expose secrets, private logs, tokens, private URLs, raw user data, or sensitive screenshots, the run must stop or redact before writing.

## Problem

ShipGlows already has a strong technical documentation layer: `code-docs-map.md` maps paths to primary docs, subsystem docs describe durable behavior, and documentation governance rules define placement and update discipline. That layer is necessary but not sufficient for portfolio-scale agent work.

The current gap appears when the operator uses product language rather than file paths. In the WinFlowz IME example, the word `swipe` required searching code, tests, docs, specs, and bugs before the behavior could be understood. That is acceptable once, but not as a repeated operating model across 20+ projects. The system needs an explicit recovery path:

```text
operator term -> project glossary / behavior index -> subsystem doc -> code entrypoints -> key functions -> tests/specs/shipglows_data/workflow/bugs/decisions
```

The current documentation also does not define when to use comments, generated API docs, behavior references, ADRs, or code-docs-map rows. Without a standard, agents will either over-document every function or keep producing local one-off notes that do not compound across the portfolio.

## Solution

Create a ShipGlows-wide code navigation standard with four layers:

1. `context.md` remains the operational/system overview.
2. `context-function-tree.md` remains the structural and functional tree view.
3. `code-docs-map.md` remains the path-to-doc routing map.
4. A new behavior/concept navigation layer maps operator terms and product behaviors to code, docs, tests, and decisions.
5. Stack-specific source comments document high-cognitive-load symbols only, using KDoc/JSDoc/TSDoc/Python docstrings or the local equivalent.
6. ADR/decision records capture durable rationale that should not live in comments or chantier specs.

Implement this as a reusable ShipGlows governance capability through references, templates, `300-sg-docs` audit/bootstrap behavior, and one concrete WinFlowz pilot for IME gestures.

The external documentation model informs the split:

- Diataxis supports separating reference, explanation, how-to, and tutorials.
- C4 supports maps that help readers move from system context toward code.
- arc42 supports structured architecture documentation without inventing an ad hoc template.
- Kotlin Dokka/KDoc supports extracting API/reference documentation from code comments when the stack supports it.

## Scope In

- Define a ShipGlows code navigation doctrine in a new shared reference, for example `skills/references/code-navigation-and-function-docs.md`.
- Define the canonical roles and interactions of `context.md`, `context-function-tree.md`, and `code-docs-map.md` inside the new navigation system.
- Extend `technical-docs-corpus.md` so agents know how to resolve `operator term -> behavior -> code` before falling back to broad search.
- Extend `documentation-governance-rules.md` and `project-governance-rules.md` with behavior-index and function-comment coverage rules.
- Add one or more templates under `templates/` for behavior/domain navigation, such as `technical_behavior_index.md` or `technical_domain_model.md`.
- Update `tools/shipglows_metadata_lint.py` if the new artifact type needs first-class metadata validation.
- Update `300-sg-docs` technical mode so it can bootstrap and audit behavior indexes, not only path maps.
- Update `301-sg-context` or its references if needed so context priming reads behavior navigation artifacts for term-based requests.
- Define a targeted source-comment convention for high-cognitive-load functions/classes across Kotlin, TypeScript/JavaScript, Python, Bash, and Dart/Flutter.
- Define when to create ADR/decision records versus comments versus behavior docs.
- Pilot the system on WinFlowz IME gestures by creating or specifying `shipglows_data/technical/winflowz_app/ime-gesture-model.md` and connecting it from the WinFlowz `code-docs-map.md`.
- Add validation and readiness checks so unmapped terms and stale behavior references are visible governance gaps.

## Scope Out

- No one-doc-per-function mandate.
- No mandatory generated API site for every project.
- No broad rewrite of all existing project docs in one pass.
- No attempt to index every local variable, private helper, or historical code path.
- No replacement of specs, bugs, test logs, ADRs, or source comments with one mega-document.
- No public documentation publication for internal technical navigation artifacts unless a separate public-docs chantier approves it.
- No requirement that all 20+ projects be fully remediated in the first implementation wave.
- No automatic code parsing tool adoption before a specific tool proves it reduces recovery friction without weakening maintainability.
- No removal of existing `context.md`, `context-function-tree.md`, or `code-docs-map.md` layers in the first implementation wave.

## Constraints

- The system must scale across heterogeneous stacks: Astro, Flutter/Dart, Kotlin Android, Python, Bash, TypeScript/JavaScript, and future project stacks.
- The standard must reduce repeated agent rediscovery, not create busywork.
- Existing context-map artifacts must be preserved and repositioned, not deleted.
- Comments are required only on high-cognitive-load symbols: arbitration, dispatch, security boundaries, lifecycle state, concurrency, persistence, external side effects, error recovery, or non-obvious product behavior.
- Generated docs are optional and stack-specific; they must support navigation rather than become another stale artifact.
- Every behavior index must have one canonical owner artifact.
- Behavior docs must link to tests/specs/shipglows_data/workflow/bugs/decisions but not duplicate their full content.
- Source comments must not contain secrets, private payloads, raw logs, or stale implementation walkthroughs.
- In monorepos, behavior docs live under the root `shipglows_data/technical/`, scoped by surface when needed.
- Shared ShipGlows references and templates are sequential integration files.
- WinFlowz remains the pilot; portfolio rollout must be staged after the standard is proven.

## Test Contract

### Surface

- Stack/surface: `ShipGlows governance`, `documentation`, `skills`, `templates`, `WinFlowz pilot`
- Primary proof mode: `contract_only`
- Proof order: metadata lint -> targeted reference/template checks -> skill contract checks -> WinFlowz pilot audit -> optional generated-doc feasibility notes

### Manual checklist

- Needed: yes
- Checklist path: `shipglows_data/workflow/test-checklists/code-navigation-and-function-documentation-system.md`
- Required scenario coverage: term-based recovery for `swipe`, mapped path recovery, unmapped term recovery, stale function reference recovery, comment-vs-doc-vs-ADR decision.
- Exception with proof: device/runtime behavior is not required for the ShipGlows standard itself; WinFlowz IME runtime proof remains owned by its IME chantiers.

### Required evidence stack

- Automated / unit / integration checks:
  - `python3 tools/shipglows_metadata_lint.py <changed-governance-artifacts>`
  - `python3 tools/skill_budget_audit.py --skills-root skills --format markdown` when skill contracts change
  - `tools/shipglows_sync_skills.sh --check --all` when skill runtime visibility changes
  - targeted `rg` checks for required doctrine terms
- Agent-run browser proof: none, because this is internal governance documentation.
- Contract/integration proof: run `300-sg-docs technical audit` or targeted equivalent on ShipGlows and WinFlowz after implementation.
- Provider evidence: official documentation sources for Diataxis, C4, arc42, and Dokka/KDoc are already consulted for the spec; no provider integration is added.
- Device-native proof: none for the standard; WinFlowz device QA remains separate.

## Dependencies

- Local ShipGlows contracts:
  - `skills/references/technical-docs-corpus.md`
  - `skills/references/documentation-governance-rules.md`
  - `skills/references/project-governance-rules.md`
  - `skills/300-sg-docs/SKILL.md`
  - `skills/301-sg-context/SKILL.md`
  - `shipglows_data/technical/code-docs-map.md`
  - `templates/technical_module_context.md`
  - `templates/decision_record.md`
- WinFlowz pilot contracts:
  - `/home/claude/winflowz/shipglows_data/technical/winflowz_app/code-docs-map.md`
  - `/home/claude/winflowz/winflowz_app/docs/technical/android-native.md`
  - `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt`
  - `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardLongPressSwipePolicy.kt`
- Fresh external docs:
  - Diataxis official docs: documentation framework and documentation type separation.
  - C4 Model official docs: code/architecture maps and diagram levels.
  - arc42 official docs: architecture documentation template.
  - Kotlin Dokka/KDoc official docs: generated documentation and code-comment conventions for Kotlin.
- Freshness verdict: `fresh-docs checked`.

## Invariants

- `context.md` remains the operational/system map.
- `context-function-tree.md` remains the structural/function-tree map.
- `shipglows_data/technical/code-docs-map.md` remains the first path-based map.
- Behavior indexes complement code-docs maps; they do not replace subsystem docs.
- Source comments explain contracts and invariants, not line-by-line implementation.
- ADRs/decision records own durable rationale.
- Specs own implementation contracts and run history.
- Bug files own defect evidence and retest history.
- The operator should not need to know filenames to ask about a behavior.
- A fresh agent should not need to rediscover the same behavior with raw `rg` if the behavior was already investigated and should be durable.

## Links & Consequences

- Upstream systems: `000-shipglows`, `100-sg-spec`, `300-sg-docs`, `301-sg-context`, `102-sg-start`, `103-sg-verify`, project governance references.
- Downstream systems: every ShipGlows-governed code project, beginning with WinFlowz as the pilot.
- Cross-cutting checks: documentation governance, metadata lint, skill budget, skill runtime sync, no-secret documentation review.
- Operator workflow consequence: term-based prompts become actionable navigation requests instead of recurring investigations.
- Agent workflow consequence: context priming can load small, relevant navigation artifacts before opening broad code, using context maps as stable entry surfaces rather than replacing them.

## Documentation Coherence

Documentation impact is required.

Expected updates include:

- Clarified roles for `context.md`, `context-function-tree.md`, and `code-docs-map.md` where relevant.
- New shared reference for code navigation and function documentation.
- Updated `technical-docs-corpus.md`.
- Updated `documentation-governance-rules.md`.
- Updated `project-governance-rules.md`.
- Updated `300-sg-docs` technical mode and possibly mode playbooks.
- New artifact template for behavior/domain navigation.
- WinFlowz pilot behavior reference and code-docs-map update.
- Optional README/help mention only if the standard changes operator-facing commands.

## Edge Cases

- One term can map to multiple behaviors inside the same project, such as WinFlowz `swipe`.
- One term can map differently across projects, such as `sync` in local-first apps versus static-site deploy workflows.
- A behavior can live across native code, Flutter bridge code, tests, docs, specs, and bugs.
- Generated docs can exist but still fail the navigation need if they list symbols without product-language mapping.
- Comments can become stale if they narrate implementation details instead of stable contracts.
- Old specs may contain valuable history but must not become the primary navigation artifact.
- A public doc might use the same term as internal code but with different audience constraints.

## Implementation Tasks

- [ ] Task 1: Define the ShipGlows code navigation doctrine.
  - File: `skills/references/code-navigation-and-function-docs.md`
  - Action: Create the shared reference that defines the layer model, term resolution flow, context-map roles, behavior index rules, comment rules, ADR boundaries, stale-map handling, and security constraints.
  - User story link: Establishes the global standard that works across the portfolio.
  - Depends on: None.
  - Validate with: `python3 tools/shipglows_metadata_lint.py skills/references/code-navigation-and-function-docs.md`
  - Notes: Keep this compact enough for skill loading; put bulky examples in templates or project docs.

- [ ] Task 2: Add behavior navigation artifact templates.
  - File: `templates/technical_behavior_index.md`, optionally `templates/technical_domain_model.md`
  - Action: Add reusable templates for term aliases, behavior summaries, entrypoints, key symbols, tests, specs, bugs, decisions, docs, ambiguity notes, and maintenance rules.
  - User story link: Lets every project create the same navigable structure instead of ad hoc notes.
  - Depends on: Task 1.
  - Validate with: `python3 tools/shipglows_metadata_lint.py templates/technical_behavior_index.md templates/technical_domain_model.md`
  - Notes: Use one template if two artifacts would create unnecessary overlap.

- [ ] Task 3: Make new artifact types lintable if needed.
  - File: `tools/shipglows_metadata_lint.py`
  - Action: Add artifact type recognition for the new behavior/domain navigation templates only if the existing `technical_module_context` type is not sufficient.
  - User story link: Keeps the new standard enforceable.
  - Depends on: Task 2.
  - Validate with: `python3 tools/shipglows_metadata_lint.py --help`; metadata lint for changed templates and sample artifacts.
  - Notes: Prefer reusing `technical_module_context` if it can cover behavior indexes without weakening clarity.

- [ ] Task 4: Wire the standard into technical corpus loading.
  - File: `skills/references/technical-docs-corpus.md`
  - Action: Add term-based recovery: preserve `context.md` and `context-function-tree.md` as early orientation layers, load `code-docs-map.md` for path routing, then load behavior index/domain model when operator wording names a behavior rather than a path.
  - User story link: Ensures agents use the new system before broad search.
  - Depends on: Task 1.
  - Validate with: `rg -n "behavior index|operator term|function documentation|code navigation|code-docs-map" skills/references/technical-docs-corpus.md`
  - Notes: Preserve current path-first rule for code-changing tasks.

- [ ] Task 5: Update documentation and project governance rules.
  - File: `skills/references/documentation-governance-rules.md`, `skills/references/project-governance-rules.md`
  - Action: Add behavior-index ownership, source-comment coverage, and stale-navigation classification rules.
  - User story link: Makes missing navigation coverage a first-class governance gap.
  - Depends on: Tasks 1-2.
  - Validate with: `rg -n "behavior index|function documentation|source comment|navigation bootstrap|stale-navigation" skills/references/documentation-governance-rules.md skills/references/project-governance-rules.md`
  - Notes: Avoid making generated docs mandatory.

- [ ] Task 6: Update `300-sg-docs` technical mode.
  - File: `skills/300-sg-docs/SKILL.md`, `skills/300-sg-docs/references/mode-playbooks.md`
  - Action: Add bootstrap/audit behavior for behavior indexes, comment coverage, mapped key functions, and ADR links.
  - User story link: Gives the standard an executable owner.
  - Depends on: Tasks 1-5.
  - Validate with: `rg -n "behavior index|function documentation|source comment|technical_behavior_index|code navigation" skills/300-sg-docs`
  - Notes: Route non-trivial skill contract changes through `009-sg-skill-build` if readiness identifies that as required.

- [ ] Task 7: Update context priming if needed.
  - File: `skills/301-sg-context/SKILL.md` or its references
  - Action: Teach context priming to load behavior navigation artifacts for term-based code questions when present.
  - User story link: Makes future agent sessions faster without user-supplied file paths.
  - Depends on: Task 4.
  - Validate with: `rg -n "behavior index|operator term|code navigation|technical-docs-corpus" skills/301-sg-context`
  - Notes: Keep context loading bounded.

- [ ] Task 8: Pilot the system on WinFlowz IME gestures.
  - File: `/home/claude/winflowz/shipglows_data/technical/winflowz_app/ime-gesture-model.md`
  - Action: Create the behavior reference for IME gestures, including aliases, ambiguity table, long-press swipe dispatch chain, key files/functions, tests, specs, bugs, and maintenance rule.
  - User story link: Proves that "swipe" can be recovered without repeating the original investigation.
  - Depends on: Tasks 1-2.
  - Validate with: `python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/winflowz/shipglows_data/technical/winflowz_app/ime-gesture-model.md`
  - Notes: Do not change IME behavior in this task.

- [ ] Task 9: Connect the WinFlowz pilot to its code-docs map.
  - File: `/home/claude/winflowz/shipglows_data/technical/winflowz_app/code-docs-map.md`
  - Action: Add fine-grained rows or references for Android IME gestures, including `WinFlowzKeyboardView.kt`, `KeyboardLongPressSwipePolicy.kt`, gesture tests, and the new behavior doc.
  - User story link: Connects path-based and term-based recovery.
  - Depends on: Task 8.
  - Validate with: `rg -n "ime-gesture-model|long-press swipe|WinFlowzKeyboardView|KeyboardLongPressSwipePolicy" /home/claude/winflowz/shipglows_data/technical/winflowz_app/code-docs-map.md`
  - Notes: Preserve monorepo root governance rules.

- [ ] Task 10: Add targeted source comments for the WinFlowz pilot functions.
  - File: `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt`, `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardLongPressSwipePolicy.kt`
  - Action: Add concise KDoc/comments to high-cognitive-load functions such as `tryActivateLongPressSwipeFromExit`, `updateLongPressSwipeHoveredTarget`, `tryDispatchAfterLongPressSwipe`, and `KeyboardLongPressSwipePolicy.chooseTargetSelection`.
  - User story link: Makes the key symbols self-orienting once reached from the behavior map.
  - Depends on: Task 8.
  - Validate with: `rg -n "long-press swipe|Contract:|See also|tryDispatchAfterLongPressSwipe|tryActivateLongPressSwipeFromExit" /home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime`
  - Notes: Comments must state contract/invariants only; no line-by-line narration.

- [ ] Task 11: Add a manual proof checklist for the standard.
  - File: `shipglows_data/workflow/test-checklists/code-navigation-and-function-documentation-system.md`
  - Action: Create checklist scenarios for mapped term recovery, unmapped term recovery, stale function reference, comment coverage, and ADR boundary.
  - User story link: Makes verification repeatable.
  - Depends on: Tasks 1-10.
  - Validate with: `python3 tools/shipglows_metadata_lint.py shipglows_data/workflow/test-checklists/code-navigation-and-function-documentation-system.md`
  - Notes: Checklist proves documentation navigation, not runtime IME behavior.

- [ ] Task 12: Validate the ShipGlows and WinFlowz standard.
  - File: changed artifacts
  - Action: Run metadata lint, skill budget/sync checks when needed, targeted rg checks, and a manual term-recovery walk-through for `swipe`.
  - User story link: Proves the standard reduces recovery work.
  - Depends on: Tasks 1-11.
  - Validate with: commands in Test Strategy.
  - Notes: Do not commit or push in this chantier unless a later ship skill is invoked.

## Acceptance Criteria

- [ ] AC 1: Given a governed project has a behavior index, when an agent receives an operator term, then it can resolve that term to named behavior(s), files, key symbols, tests, docs, specs, bugs, and decisions.
- [ ] AC 2: Given a term is ambiguous, when the behavior index is present, then the agent reports the available meanings instead of assuming one.
- [ ] AC 3: Given a term is unmapped, when an agent investigates it, then the system classifies the gap as a navigation bootstrap or drift issue and routes a bounded docs update.
- [ ] AC 4: Given a high-cognitive-load function is part of a mapped behavior, when an agent opens the source, then a concise source comment explains the function contract, invariants, and related symbols.
- [ ] AC 5: Given a behavior exists because of a durable decision, when the behavior reference is opened, then it links to the ADR/decision record or states why no durable decision record is needed.
- [ ] AC 6: Given `300-sg-docs technical audit` runs on a project with behavior indexes, when references are stale or missing, then the audit reports the exact missing or stale coverage.
- [ ] AC 7: Given WinFlowz IME gestures are the pilot, when the operator says `swipe`, then the new `ime-gesture-model.md` distinguishes all known IME swipe meanings and links to long-press swipe dispatch functions.
- [ ] AC 8: Given implementation changes a mapped behavior, when verification runs, then docs coherence includes behavior index, code-docs-map, source comments, tests, and decisions.
- [ ] AC 9: Given a stack does not benefit from generated docs, when the standard is applied, then generated docs are not forced and the reason is explicit.
- [ ] AC 10: Given a behavior doc or comment would expose sensitive data, when writing or verifying, then the content is redacted or blocked.

## Test Strategy

Proof path: `contract-first`.

Validation commands for ShipGlows implementation:

```bash
python3 tools/shipglows_metadata_lint.py skills/references/code-navigation-and-function-docs.md templates/technical_behavior_index.md shipglows_data/workflow/specs/shipglows-code-navigation-and-function-documentation-system.md
python3 tools/skill_budget_audit.py --skills-root skills --format markdown
tools/shipglows_sync_skills.sh --check --all
rg -n "behavior index|operator term|function documentation|source comment|code navigation" skills/references skills/300-sg-docs templates shipglows_data/technical
```

Validation commands for WinFlowz pilot:

```bash
python3 /home/claude/shipglows/tools/shipglows_metadata_lint.py /home/claude/winflowz/shipglows_data/technical/winflowz_app/ime-gesture-model.md /home/claude/winflowz/shipglows_data/technical/winflowz_app/code-docs-map.md
rg -n "ime-gesture-model|long-press swipe|WinFlowzKeyboardView|KeyboardLongPressSwipePolicy|tryDispatchAfterLongPressSwipe|tryActivateLongPressSwipeFromExit" /home/claude/winflowz/shipglows_data/technical /home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime
```

Manual proof:

- Start from the word `swipe` only.
- Resolve meanings from the behavior index without raw `rg` as the first step.
- Open the mapped behavior doc.
- Open the mapped source functions.
- Confirm the mapped tests/specs/shipglows_data/workflow/bugs/decisions are linked.
- Confirm unmapped terms produce a governance gap rather than silent broad search.

## Risks

- Risk: over-documentation slows implementation. Mitigation: require behavior indexes only for complex/high-recovery-cost domains and comments only for high-cognitive-load symbols.
- Risk: generated docs become stale or low-value. Mitigation: generated docs are optional and must prove navigation value.
- Risk: behavior docs duplicate specs or bugs. Mitigation: behavior docs link to specs/bugs and summarize only stable recovery context.
- Risk: portfolio rollout becomes too broad. Mitigation: pilot on WinFlowz, then roll out through `300-sg-docs technical audit` project by project.
- Risk: comments rot faster than code. Mitigation: comments describe contracts/invariants and are verified when mapped behavior changes.
- Security risk: docs or comments could capture sensitive logs or private examples. Mitigation: redaction rule and metadata/docs audit gate.

## Execution Notes

Read first:

- `skills/references/technical-docs-corpus.md`
- `skills/references/documentation-governance-rules.md`
- `skills/references/project-governance-rules.md`
- `skills/300-sg-docs/SKILL.md`
- `skills/300-sg-docs/references/mode-playbooks.md`
- `shipglows_data/technical/code-docs-map.md`
- `templates/technical_module_context.md`
- `/home/claude/winflowz/shipglows_data/technical/winflowz_app/code-docs-map.md`
- `/home/claude/winflowz/winflowz_app/docs/technical/android-native.md`
- `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/WinFlowzKeyboardView.kt`
- `/home/claude/winflowz/winflowz_app/android/app/src/main/kotlin/com/winflowz_app/winflowz_app/ime/KeyboardLongPressSwipePolicy.kt`

Implementation approach:

1. Define the shared doctrine and template.
2. Integrate the doctrine into `300-sg-docs` and technical corpus loading.
3. Apply the WinFlowz IME pilot.
4. Validate with term-recovery proof.
5. Use the pilot evidence before rolling out to other projects.

Stop conditions:

- A new artifact type cannot be linted or reasonably covered by an existing type.
- The standard would require broad portfolio edits before the pilot proves value.
- A generated documentation tool is proposed as mandatory without project-specific value proof.
- WinFlowz IME comments would require behavior changes rather than contract documentation.
- Sensitive evidence would need to be persisted.

## Open Questions

None.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-06-30 13:47:10 UTC | 100-sg-spec | GPT-5 Codex | Created spec for portfolio-scale code navigation and function documentation system with WinFlowz IME pilot | draft | /101-sg-ready ShipGlows Code Navigation And Function Documentation System |
| 2026-06-30 14:02:30 UTC | 101-sg-ready | GPT-5 Codex | Reviewed readiness, scope integrity, proof contract, documentation coherence, and security posture | ready | /102-sg-start ShipGlows Code Navigation And Function Documentation System |
| 2026-07-04 07:30:42 UTC | 102-sg-start | GPT-5 Codex | Implemented the shared code-navigation doctrine, behavior-index template, 300-sg-docs integration, WinFlowz IME gesture pilot, and targeted Kotlin contract comments | implemented | /103-sg-verify ShipGlows Code Navigation And Function Documentation System |
| 2026-07-04 10:48:20 UTC | 103-sg-verify | GPT-5 Codex | Verified the shared doctrine, checklist evidence, WinFlowz pilot routing, Kotlin contract comments, metadata lint, skill sync, design drift, and Flutter analyze proof | verified | /104-sg-end ShipGlows Code Navigation And Function Documentation System |
| 2026-07-04 13:07:51 UTC | 104-sg-end | GPT-5 Codex | Closed the chantier bookkeeping by syncing the ShipGlows task tracker, changelog, and verified spec state without claiming git ship status | closed | /005-sg-ship ShipGlows Code Navigation And Function Documentation System |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready.
- `102-sg-start`: implemented.
- `103-sg-verify`: verified.
- `104-sg-end`: closed.
- `005-sg-ship`: not launched.

Next step: `/005-sg-ship ShipGlows Code Navigation And Function Documentation System`
