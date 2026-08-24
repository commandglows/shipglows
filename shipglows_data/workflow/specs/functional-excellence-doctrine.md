---
artifact: spec
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-24"
created_at: "2026-08-24 17:55:34 UTC"
updated: "2026-08-24"
updated_at: "2026-08-24 17:56:56 UTC"
status: ready
source_skill: 900-shipglows-core
source_model: gpt-5
scope: functional-excellence-doctrine
owner: Diane
user_story: "As a ShipGlows operator, I want every product, content, experience, and system decision judged by a shared functional-excellence standard, so outputs are useful, understandable, honest, durable, and minimal without becoming incomplete."
confidence: high
risk_level: high
security_impact: none
docs_impact: yes
linked_systems:
  - skills/references/decision-quality-contract.md
  - skills/references/functional-excellence-contract.md
  - skills/references/intent-to-outcome-autonomy.md
  - skills/references/design-system-token-contract.md
  - skills/references/content-quality-rubric.md
depends_on:
  - artifact: skills/references/decision-quality-contract.md
    artifact_version: "2.2.0"
    required_status: active
  - artifact: skills/references/intent-to-outcome-autonomy.md
    artifact_version: "1.5.0"
    required_status: active
supersedes: []
evidence:
  - "Operator decision 2026-08-24: functional excellence applies across products, content, design, experiences, and ShipGlows mechanisms, before implementation excellence."
  - "Dieter Rams's principles supplied the inspiration; ShipGlows owns an adapted functional contract rather than importing a visual style or external authority."
next_step: /102-sg-start functional-excellence-doctrine
---

# Functional Excellence Doctrine

## Title

Functional Excellence Doctrine

## Status

ready

## User Story

As a ShipGlows operator, I want every product, content, experience, and system decision judged by a shared functional-excellence standard, so outputs are useful, understandable, honest, durable, and minimal without becoming incomplete.

## Minimal Behavior Contract

When ShipGlows selects or evaluates a material outcome or durable artifact, it applies one shared functional standard before implementation detail: the result must serve an evidenced purpose, make its use and limits understandable, state capabilities and proof honestly, remain coherent for the accepted horizon, cover consequential details, and contain no element without a responsibility. If one dimension fails, the work is revised, narrowed, or reported partial; the smallest acceptable form is always minimal but complete, including the easily missed case where apparent simplicity removes necessary safety, recovery, nuance, or proof.

## Success Behavior

- Preconditions: a material product, content, experience, workflow, rule, or durable-artifact decision has a resolved outcome and audience or operator.
- Trigger: ShipGlows selects, specifies, reviews, or verifies the proposed form.
- User/operator result: the result is useful, understandable without hidden mediation, honest about its promise and state, durable for its horizon, complete in consequential detail, and no more elaborate than necessary.
- System effect: functional fitness is decided before implementation excellence and specialized design/editorial execution.
- Success proof: focused pressure scenarios cover product, content, design, and ShipGlows-system decisions plus dependency and metadata checks.
- Silent success: not allowed; the decision path or downstream acceptance criteria must expose enough evidence to justify the claimed functional fit.

## Error Behavior

- Expected failures: decorative novelty without utility, technically valid output without user value, unclear use, inflated claims, fashion-led fragility, missing consequential states, or ceremony without responsibility.
- User/operator response: revise or narrow the form, or report the material functional gap as partial with a concrete next outcome.
- System effect: implementation and completion claims stop at the narrowest owner boundary that can repair the failed dimension.
- Must never happen: use Rams-inspired aesthetics as proof of functional quality; interpret minimalism as removing safety, accessibility, recovery, context, nuance, or proportional proof; duplicate the full doctrine across métier skills.
- Silent failure: not allowed because an unreported functional gap can make correct implementation solve the wrong problem.

## Problem

ShipGlows has strong decision-quality and implementation-excellence rules, but it does not yet name the intervening functional test that asks whether the chosen form deserves to exist and fully serves its purpose across non-code as well as code outputs.

## Solution

Add one shared functional-excellence contract, activate its compact core from decision quality, and expose direct design and content adaptations without copying the doctrine into owner skills. Keep Dieter Rams and Drams as provenance only; ShipGlows owns the normative formulation.

## Scope In

- Define useful, understandable, unobtrusive, honest, durable, thorough, and minimal-but-complete as functional dimensions.
- Define the order `outcome -> functional excellence -> conception -> implementation excellence -> proportional proof`.
- Apply the shared standard to products, content, experiences, durable artifacts, workflows, reports, and ShipGlows mechanisms.
- Add direct specialized adaptations for design and content where those existing authorities can consume the shared dimensions.
- Add focused mechanical pressure scenarios and metadata/dependency validation.

## Scope Out

- No visual redesign, Framer component import, or Drams asset adoption.
- No verbatim reproduction of Dieter Rams's ten principles and no external source as runtime authority.
- No new public skill, command, mode, dependency, provider, or product promise.
- No broad rewrite of existing quality, design, content, or implementation contracts.

## Constraints

- The new layer must replace a named gap rather than add ceremonial structure.
- The decision-quality baseline remains compact and directly followable.
- Specialized authorities adapt only dimensions they can operationalize and do not chain through sibling references.
- Functional minimalism never weakens security, privacy, accessibility, recovery, correctness, nuance, or proof.

## Dependencies

- Runtime: none; documentation and focused contract tests only.
- Document contracts: decision-quality-contract 2.2.0 and intent-to-outcome-autonomy 1.5.0.
- Metadata gaps: none identified before authoring.

## Invariants

- Business and user value precede internal elegance.
- Minimal means no element without responsibility; complete means no consequential responsibility omitted.
- Functional excellence precedes and constrains design and implementation excellence but does not replace either.
- Honest claims distinguish fact, inference, state, limitation, and missing proof.
- External inspiration may inform the doctrine but never becomes hidden runtime authority.

## Links & Consequences

- Upstream systems: intent-to-outcome autonomy and decision quality resolve the outcome and activate the functional gate.
- Downstream systems: product decisions, design systems, content quality, lifecycle specifications, verification, and ShipGlows contract maintenance consume the result.
- Cross-cutting checks: accessibility, security, privacy, durability, editorial claims, proof proportionality, and activation-budget followability.

## Documentation Coherence

- Update the shared functional and decision-quality contracts, the existing design and content authorities, and this chantier spec.
- Public help and invocation documentation are not impacted because no public command or promise changes.

## Edge Cases

- A visually minimal interface hides recovery or accessibility controls.
- A concise article removes the qualification needed to keep a claim honest.
- A useful feature accumulates configuration that makes first use incomprehensible.
- A thorough workflow exposes internal machinery and becomes obtrusive to the operator.
- A durable abstraction solves hypothetical futures but delays current value.
- A simple ShipGlows rule cannot be followed by a fresh agent without hidden context.

## Implementation Tasks

- [ ] Task 1: Add the shared functional-excellence contract.
  - File: `skills/references/functional-excellence-contract.md`
  - Action: define the functional dimensions, sequence, failure semantics, adaptations, and pressure scenarios.
  - User story link: establishes one shared standard across artifact types.
  - Depends on: approved doctrine and this ready spec.
  - Validate with: `python3 tools/test_functional_excellence_contract.py`
  - Notes: source inspiration is attribution evidence, not normative dependency.
- [ ] Task 2: Activate the compact functional gate from decision quality.
  - File: `skills/references/decision-quality-contract.md`
  - Action: add the minimum baseline and direct loading rule without duplicating detailed criteria.
  - User story link: ensures the standard precedes implementation decisions.
  - Depends on: Task 1.
  - Validate with: `python3 tools/test_functional_excellence_contract.py`
  - Notes: preserve first-screen decision clarity and activation budget.
- [ ] Task 3: Add targeted design and content adaptations.
  - File: `skills/references/design-system-token-contract.md`, `skills/references/content-quality-rubric.md`
  - Action: reference and operationalize the applicable functional dimensions in each existing authority.
  - User story link: makes the doctrine actionable outside generic system decisions.
  - Depends on: Task 1.
  - Validate with: `python3 tools/test_functional_excellence_contract.py`
  - Notes: do not copy the complete doctrine or add new skill modes.
- [ ] Task 4: Add focused scenario-first proof and metadata validation.
  - File: `tools/test_functional_excellence_contract.py`, changed frontmatter artifacts, this spec.
  - Action: assert placement, ordering, minimum completeness, anti-aesthetic and anti-simplism guards, and targeted adaptations.
  - User story link: prevents the doctrine from becoming decorative prose.
  - Depends on: Tasks 1-3.
  - Validate with: `python3 tools/test_functional_excellence_contract.py && python3 tools/shipglows_metadata_lint.py skills/references/functional-excellence-contract.md skills/references/decision-quality-contract.md skills/references/design-system-token-contract.md skills/references/content-quality-rubric.md shipglows_data/workflow/specs/functional-excellence-doctrine.md`
  - Notes: run only proportional skill/runtime checks required by the changed dependency surface.

## Acceptance Criteria

- [ ] AC 1: Given any material ShipGlows outcome, when its form is selected, then functional excellence is evaluated before specialized conception or implementation excellence.
- [ ] AC 2: Given a product, content, design, or system artifact, when a functional dimension fails, then the work is revised, narrowed, or reported partial rather than called complete.
- [ ] AC 3: Given a proposal described as minimal, when it omits a consequential responsibility, then the contract rejects it as simplism rather than excellence.
- [ ] AC 4: Given Rams or Drams inspiration, when the doctrine is applied, then no visual resemblance or external authority substitutes for functional proof.
- [ ] AC 5: Given a fresh agent, when it follows decision quality, design, or content authority, then it can find the applicable functional gate and next action without conversation history.
- [ ] AC 6: Given the changed artifacts, when focused scenario and metadata checks run, then they pass without requiring app builds or external mutation.

## Test Strategy

- Unit: focused Python contract test for invariant wording, direct activation, adaptations, and anti-patterns.
- Integration: metadata lint plus affected dependency-graph and context-budget checks.
- Manual: inspect the final diff for duplicated doctrine, activation bloat, and accurate Rams/Drams attribution.

## Test Contract

### Surface

- Stack/surface: ShipGlows shared skill doctrine and documentation.
- Primary proof mode: contract_only.
- Proof order (if applicable): focused scenario test, metadata lint, affected graph/budget checks, diff review.

### Manual checklist

- Needed: no.
- Checklist path: not applicable; no user-visible runtime behavior.
- Required scenario coverage: product utility, content honesty, design understandability, system unobtrusiveness, minimal-but-incomplete failure.
- Exception with proof: browser, provider, auth, and device proof are not applicable because this change has no corresponding runtime surface.

### Required evidence stack

- Automated / unit / integration checks: focused contract test, metadata lint, affected dependency graph, and skill budget audit.
- Agent-run browser proof: none because no browser surface changes.
- Auth/session proof (`sg-auth-debug`): none because no auth/session behavior changes.
- Contract/integration proof: direct-link and required-invariant assertions.
- Provider evidence: none because no provider state changes.
- Device-native proof: none because no device behavior changes.

## Risks

- Security impact: none directly; the doctrine explicitly forbids minimalism from weakening existing safety boundaries.
- Product/data/performance risk: doctrine sprawl or ambiguous overlap could slow decisions; mitigate with one shared direct reference, compact activation, and focused failure scenarios.

## Execution Notes

- Read first: `skills/references/decision-quality-contract.md`, `skills/references/intent-to-outcome-autonomy.md`, `skills/references/design-system-token-contract.md`, `skills/references/content-quality-rubric.md`, `skills/references/implementation-excellence-preflight.md`, and `skills/references/skill-instruction-layering.md`.
- Validate with: `python3 tools/test_functional_excellence_contract.py`, metadata lint, affected dependency graph, skill budget audit, and focused `rg`/diff review.
- Stop conditions: the new contract duplicates existing doctrine without a distinct first decision; adaptations require broad métier rewrites; activation becomes cyclic; or minimalism weakens a safety/proof invariant.

## Open Questions

None

## ZOMBIES Coverage

- Zero: an artifact with no evidenced function fails rather than receiving stylistic polish.
- One: one clear function receives the smallest complete form and proportional proof.
- Many: multiple functions retain explicit hierarchy and do not become an undifferentiated feature, content, or process dump.
- Boundaries: accepted horizon, audience, consequential states, safety, accessibility, recovery, and proof define the minimum complete boundary.
- Interfaces: outcome resolution hands a functional decision to specialized conception and implementation owners without hidden context.
- Exceptions: legitimate complexity is retained when removing it would lose a required responsibility.
- Simple scenarios: the focused test uses one representative product, content, design, system, and simplism-failure case.

## Skill Run History

| Date UTC | Skill | Model | Action | Result | Next step |
|----------|-------|-------|--------|--------|-----------|
| 2026-08-24 17:55:34 UTC | 100-sg-spec | gpt-5 | Created the functional-excellence doctrine contract | draft | 101-sg-ready |
| 2026-08-24 17:56:56 UTC | 101-sg-ready | gpt-5 | Reviewed scope, failure semantics, dependencies, consequences, and proof contract | ready | 102-sg-start |

## Current Chantier Flow

- `100-sg-spec`: done, draft spec created.
- `101-sg-ready`: ready; the contract is autonomous and implementation-safe.
- `102-sg-start`: not launched.
- `103-sg-verify`: not launched.
- `104-sg-end`: not launched.
- `005-sg-ship`: not launched.

Next step: `/102-sg-start functional-excellence-doctrine`
