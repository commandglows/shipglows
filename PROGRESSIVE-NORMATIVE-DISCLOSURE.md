# Progressive Normative Disclosure for Agent Skill Systems

> **Status:** Working paper — diagnostic and design input, not a runtime contract.
>
> **Purpose:** Frame a repository-wide problem before any normative migration. This document must not be loaded as agent instruction and must not compete with canonical ShipGlows contracts.

## The question

**How can an agent skill system preserve precise, enforceable requirements without forcing every agent to load, compare, and reconcile every detailed rule on every task?**

In the operator's original terms:

> Comment conserver des doctrines généralistes, neutres et concises dans les skills, tout en gardant une liste de règles précises que l'agent peut consulter lorsqu'une situation lui pose réellement question ?

This is not primarily an editing question. It is an architecture question about where rules live, when they become relevant, how they are resolved, and how their behavior is proven.

## Executive thesis

ShipGlows needs precision without permanent cognitive saturation.

The solution is not to choose between short skills and exact rules. It is to separate five concerns that have gradually become entangled:

1. **Doctrine** — the few general invariants needed for ordinary reasoning.
2. **Detection** — the signals that indicate a specialized rule may apply.
3. **Resolution** — the index that maps a signal to one authoritative rule.
4. **Procedure** — the exact requirements loaded only for that situation.
5. **Proof** — behavioral scenarios that verify the resulting decision without requiring duplicated wording.

The desired system is therefore:

```text
small always-loaded doctrine
        |
        v
ordinary autonomous decision
        |
        +-- material signal or uncertainty --> rule index
                                                |
                                                v
                                      one specialized contract
                                                |
                                                v
                                      proportional proof
```

The central design principle is **progressive normative disclosure**: reveal precision when the decision needs it, not merely because the precision exists.

## Why this problem appears

Agent instruction systems tend to accumulate rather than consolidate. A failure occurs, a corrective sentence is added, and a regression test freezes that sentence. A related failure occurs elsewhere, so the same idea is paraphrased in another skill. Later, the two formulations evolve independently. Each local correction is understandable, but the global result becomes harder to reason about.

This produces normative entropy:

- one intention has several textual owners;
- general doctrine and exceptional procedure are mixed together;
- historical explanations remain active runtime instructions;
- long boundary lists are copied into every surface that touches them;
- tests prove that phrases exist rather than that decisions are correct;
- agents must compare near-duplicates before acting;
- new corrections increase context pressure and contradiction risk;
- compacting one file moves complexity elsewhere without reducing it.

The system can become simultaneously more documented and less intelligible.

## The real cost of instruction bloat

Token count is only the most visible cost. The deeper problem is decision interference.

### Attention dilution

An agent has to allocate attention among the user's outcome, repository evidence, current state, applicable safety boundaries, and proof. Every unrelated normative detail competes with those inputs.

### False equivalence

When several documents state similar rules with different boundaries, the agent may treat them as equally authoritative even when only one was intended to be canonical.

### Defensive over-questioning

Long lists of approval, stop, and exception conditions can bias an agent toward interruption even when a neutral general doctrine would support autonomous continuation.

### Mechanical compliance without semantic fidelity

Exact-string tests can remain green while the combined rules produce the wrong behavior. Conversely, a clearer formulation can fail because it no longer contains the expected literal phrase.

### Expensive maintenance

A small policy change requires searching, updating, versioning, synchronizing, and testing many surfaces. Missing one paraphrase creates drift.

### Reduced evolvability

Once dozens of documents contain a rule, changing its boundary feels dangerous. The organization adds another exception instead of repairing the model.

## Precision, presence, and activation are different

A mature instruction system must distinguish three properties:

- **Precision:** Is the rule exact enough to govern the difficult case?
- **Presence:** Does an authoritative rule exist and remain discoverable?
- **Activation:** Does the current task actually require that rule to be loaded?

More precision does not require more always-loaded text. A highly detailed production-deployment contract can remain precise while being irrelevant to a documentation rename. The architecture fails when existence is treated as a reason for unconditional activation.

The objective is therefore not minimal documentation. It is **minimal active doctrine with maximal resolvable precision**.

## Proposed architecture

### Layer 1 — Doctrine kernel

The kernel contains only cross-cutting principles required for ordinary decisions. It should be small enough to remain mentally coherent as a whole.

A possible shape is:

1. Pursue the requested outcome autonomously using discoverable evidence.
2. Ask the operator only for decisions that materially change outcome, scope, risk, protected state, or acceptance.
3. Preserve unrelated work and established sources of truth.
4. Apply the specialized rule when a material signal activates it.
5. Prove the result proportionately and reconcile owned temporary state before returning control.

These sentences are illustrative, not proposed canonical wording. The final kernel must be derived through repository-wide analysis and behavioral testing.

The kernel should avoid inventories of tools, platforms, providers, actions, file types, and historical incidents. Those belong below it.

### Layer 2 — Signal vocabulary

Progressive disclosure depends on reliable triggers. A rule cannot remain unloaded unless the agent can recognize when it may be needed.

Signals should describe decision properties rather than product names. Examples include:

- destructive or irreversible effect;
- credentials, secrets, private data, or permissions;
- production or publication boundary;
- financial cost or billing mutation;
- external communication or account mutation;
- branch, worktree, history, or integration state;
- ambiguous canonical ownership;
- conflicting or stale evidence;
- framework behavior whose truth may have changed;
- public claim requiring proof;
- material product or experience choice;
- migration or preservation risk;
- unavailable verification.

The vocabulary must remain finite and composable. Adding a new provider should normally map to an existing signal, not create a new top-level doctrine.

### Layer 3 — Normative index

The index maps each signal to one authoritative contract. It is routing infrastructure, not another prose policy.

A useful index entry would answer:

```text
signal: destructive-effect
load: destructive-action-contract
predicate: an action may delete, overwrite, discard, or irreversibly transform state
priority: protected-boundary
fallback: preserve state and request the smallest material decision
```

The index should not restate the full rule. Its job is to make the rule discoverable and establish precedence when signals overlap.

### Layer 4 — Specialized rule contracts

Specialized contracts retain the precision that safety and consistency require. They can contain exact preconditions, exceptions, commands, evidence, cleanup, and failure behavior because they are loaded only when applicable.

Each rule should have one normative owner and a standard anatomy:

- **Trigger:** What observable signal activates the rule?
- **Decision:** What must the agent determine?
- **Required behavior:** What action or constraint follows?
- **Exceptions:** Which bounded exceptions genuinely alter the rule?
- **Stop condition:** What unresolved fact prevents safe continuation?
- **Proof:** What evidence establishes compliance?
- **Terminal disposition:** What happens to temporary or unresolved state?

If a rule cannot express its trigger, it will either be loaded everywhere or missed when needed. Both are architecture defects.

### Layer 5 — Behavioral proof

Tests should validate decisions at boundaries rather than duplicate prose.

Instead of asserting that five files contain a sentence such as “ordinary Git stewardship has standing authority,” a scenario can establish:

```text
Given a clean task branch whose PR is merged and whose commits are integrated,
when the chantier ends,
then the agent removes the small proven-owned temporary branch without asking.
```

A complementary scenario establishes the exception:

```text
Given a branch with unique commits and no proven owner,
when the chantier ends,
then the agent preserves it and reports the unresolved disposition.
```

The canonical contract remains testable, but mirrors and consumers do not need to repeat its full wording.

### Layer 6 — Provenance and history

Decision history is valuable, but it is not automatically runtime doctrine.

Dates, operator corrections, incident narratives, migration notes, and supersession evidence should remain available for maintainers while being excluded from the normal instruction path. A compact current contract should not require the agent to replay every historical reason for its existence.

History answers “why did this rule evolve?” The active contract answers “what applies now?” Those are different retrieval needs.

## Canonical ownership and precedence

Progressive disclosure only works when authority is unambiguous.

For each normative proposition, the repository should be able to answer:

1. Which artifact owns the rule?
2. Which skills may activate it?
3. Which signals cause activation?
4. Which higher-order doctrine constrains it?
5. Which tests prove its behavior?
6. Which documents merely explain or reference it?

References should point to the owner without reproducing its detailed semantics. If a consumer needs a compact reminder, that reminder must be explicitly non-normative or mechanically generated from the owner.

When two rules apply, precedence should be structural rather than inferred from prose length. For example:

```text
protected boundary
    outranks ordinary autonomy
        outranks workflow preference
            outranks convenience
```

The exact hierarchy requires audit. What matters is that it exists once and can be resolved predictably.

## What may remain repeated

Deduplication must not become dogma. Some repetition is useful when it reduces a realistic safety failure.

Repetition may be justified when:

- the instruction must survive an isolated execution surface;
- omission would create a high-severity security or data risk;
- the consumer cannot reliably load the canonical rule;
- a short invariant is necessary to recognize the trigger;
- generated synchronization keeps every copy mechanically identical;
- the repeated text is a deliberate safety interlock, not an independently edited paraphrase.

Every intentional repetition should have a reason, an owner, and a synchronization mechanism. Accidental paraphrase is not redundancy for safety; it is drift.

## Common anti-patterns

### The universal mega-contract

Moving every rule into one enormous canonical document creates a single source but not progressive disclosure. It reduces ownership ambiguity while preserving cognitive overload.

### The tiny skill with an eager dependency tree

A short `SKILL.md` is not actually concise if it unconditionally loads several large references. Effective context, not file length, is the relevant measure.

### Exception accretion

Adding one sentence for every observed failure eventually turns a general rule into an incident log. Repeated exceptions often indicate that the parent abstraction is wrong.

### Synonym-based duplication

Two documents may avoid identical strings while expressing the same normative proposition. Lexical deduplication alone cannot detect semantic duplication.

### Identifier proliferation

Assigning an ID to every sentence can create another maintenance system without improving reasoning. IDs are useful for stable rule ownership and test linkage, not as decoration.

### Tests as shadow policy

If the only exact definition of expected behavior lives in assertions, tests become an undocumented second rulebook. Scenarios must link back to a normative owner.

### Historical metadata in the hot path

Extensive evidence and correction histories can dominate a contract before the current rule appears. Maintainer provenance should remain available without being activated on every task.

### Local compaction without graph analysis

Shortening one skill while moving its text into an always-loaded reference changes file shape but not cognitive cost.

## A method for auditing the current system

The audit should analyze the effective activation graph, not only individual files.

### 1. Inventory normative units

Extract statements that prescribe, prohibit, permit, require proof, define precedence, or establish a stop condition. Group them by meaning rather than exact wording.

### 2. Classify each unit

For every unit, record:

- canonical owner, if known;
- consumers and mirrors;
- trigger or activation predicate;
- severity if omitted;
- always-loaded or conditional state;
- behavioral tests;
- overlapping or contradictory rules;
- historical versus current content.

### 3. Measure effective load

For representative tasks, calculate the full set of instructions reached before action. Useful task classes include:

- a bounded documentation edit;
- a feature implementation;
- a Git reconciliation;
- a production deployment;
- an authentication change;
- a product-direction question;
- a read-only audit;
- a conversation handoff.

The comparison should show which rules are useful, irrelevant, missing, or duplicated for each task.

### 4. Find semantic clusters

Likely clusters include autonomy and authority, questioning, Git stewardship, lifecycle continuity, reporting, proof, documentation reflection, context reliability, protected effects, and public claims.

Each cluster should be classified as:

- merge into doctrine;
- retain as specialized rule;
- reduce to an index trigger;
- move to behavioral scenarios;
- move to provenance/archive;
- keep repeated as a justified safety interlock;
- unresolved collision requiring operator choice.

### 5. Establish a behavioral baseline

Before rewriting, preserve representative scenarios and expected decisions. A successful migration must retain or intentionally change these outcomes with an explicit decision.

### 6. Migrate in waves

Possible waves are:

1. define measurement and ownership;
2. establish the doctrine kernel and precedence model;
3. create the signal vocabulary and index;
4. migrate one high-duplication cluster as a pilot;
5. convert literal tests to behavioral scenarios;
6. migrate remaining clusters;
7. remove superseded mirrors and archive history;
8. validate the effective activation graph and context budget.

Each wave must be independently reviewable and reversible. A repository-wide rewrite without intermediate semantic proof would make regression diagnosis unnecessarily difficult.

## Metrics that matter

No single metric proves success. The migration should use a balanced scorecard.

### Context metrics

- tokens or characters loaded before ordinary action;
- number of unconditional references per public entrypoint;
- maximum and median activation depth;
- number of rules activated without a matching task signal.

### Ownership metrics

- normative propositions with exactly one owner;
- unresolved ownership collisions;
- independently editable paraphrases;
- intentional mirrors with mechanical synchronization.

### Behavioral metrics

- boundary scenarios passing before and after migration;
- incorrect questions or unnecessary approval prompts;
- missed safety stops;
- incorrect continuation or cleanup decisions;
- tasks requiring unrelated rule loading.

### Maintenance metrics

- files changed for a typical policy update;
- exact-string assertions replaced by behavior assertions;
- stale or superseded history remaining in the hot path;
- activation cycles and budget violations.

Targets should be established from the baseline rather than invented in advance. A percentage reduction is meaningful only after the repository's current effective load is measured.

## The PR #88 case study

PR #88, “docs: recover delegated intent authority records,” illustrates the problem well.

Its intention is understandable: when an operator asks for a clear outcome, the agent should not request approval for every discoverable file, command, test, cleanup, or continuation. Current ShipGlows doctrine already covers much of that behavior across autonomy, partnership, mutation, lifecycle, delegation, and Git stewardship contracts.

The PR nevertheless adds a new specification with a slightly different authority boundary. It proposes that a clear imperative can authorize a bounded local chantier, while current doctrine distinguishes a few directly enumerable actions from a broader chantier requiring a plan or established authority.

Merging the document as another active rule would therefore create three risks:

- duplicate ownership of the same general intention;
- a semantic conflict at the boundary between a request and a chantier;
- additional history and test burden for agents to reconcile.

The right question is not “Should these 84 lines be kept?” It is:

> Which behavioral guarantee, if any, is absent from the current canonical model, and at which architectural layer should that guarantee live?

If no behavior is missing, the PR is superseded evidence. If a behavior is missing, it should be incorporated into the single relevant doctrine, specialized rule, or scenario—not preserved as a competing specification.

## Design decisions the chantier must resolve

The repository-wide work should make explicit decisions on these points:

1. What is the smallest sufficient always-loaded doctrine?
2. Which signals can reliably activate detailed rules?
3. Where does the normative index live, and is it prose, structured data, or both?
4. How is precedence resolved when several signals apply?
5. Which safety invariants must remain locally repeated?
6. How are historical operator decisions retained outside the hot path?
7. Which tests should validate wording, and which should validate behavior?
8. How is effective context load measured across heterogeneous agent hosts?
9. How can an agent report an unrecognized rule need without defaulting to broad eager loading?
10. What migration sequence minimizes semantic regression?

These are architectural decisions. They should not be answered independently by a series of local cleanup edits.

## Acceptance criteria for the future architecture

The work is successful when:

- a capable agent can state the always-loaded doctrine from one compact source;
- each detailed requirement has one authoritative owner;
- specialized contracts expose explicit activation predicates;
- ordinary tasks do not load unrelated detailed rules;
- high-risk tasks still activate every required protection;
- overlapping rules have deterministic precedence;
- intentional repetition is documented and synchronized;
- behavioral tests prove material boundaries;
- provenance remains available without dominating runtime context;
- effective instruction load is materially lower on representative tasks;
- the activation graph has no cycles;
- repository skill budgets and metadata contracts remain valid;
- a policy change normally affects its owner, index entry, and behavior tests—not many paraphrased consumers;
- the system remains understandable and actionable by humans as well as agents.

## The proposed operator question

The chantier should ultimately answer this question:

> **Quelles règles un agent ShipGlows doit-il connaître en permanence pour agir correctement, et quelles règles précises peut-il ne charger qu'au moment où un signal concret indique qu'elles deviennent pertinentes ?**

This formulation preserves the operator's original concern. It does not assume that concision means weaker governance, and it does not assume that precision requires permanent exposure.

## Expected outcome

The intended result is not merely shorter files. It is a system in which:

- general reasoning remains simple;
- exceptional behavior remains exact;
- rule discovery is reliable;
- authority is singular;
- tests prove decisions;
- history remains accessible;
- context is spent on the current outcome rather than on unrelated governance.

That is the standard against which every proposed compaction, extraction, registry, index, or migration should be judged.
