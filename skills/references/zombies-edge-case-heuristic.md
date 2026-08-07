---
artifact: technical_guidelines
metadata_schema_version: "1.0"
artifact_version: "1.0.0"
project: ShipGlows
created: "2026-08-07"
updated: "2026-08-07"
status: active
source_skill: 100-sg-spec
scope: zombies-edge-case-heuristic
owner: Diane
confidence: high
risk_level: low
security_impact: none
docs_impact: yes
linked_systems:
  - skills/100-sg-spec/SKILL.md
  - skills/102-sg-start/SKILL.md
  - skills/103-sg-verify/SKILL.md
  - skills/106-sg-fix/SKILL.md
  - skills/107-sg-test/SKILL.md
  - skills/references/spec-driven-development-discipline.md
depends_on: []
supersedes: []
evidence:
  - "User decision 2026-08-07: use ZOMBIES proportionally to identify edge cases across specification, implementation, fixes, testing, and verification."
  - "James Grenning's ZOMBIES heuristic: https://blog.wingman-sw.com/tdd-guided-by-zombies"
next_review: "2027-02-07"
next_step: "/103-sg-verify zombies-edge-case-contract"
---

# ZOMBIES Edge-Case Heuristic

Use ZOMBIES to challenge non-trivial behavioral contracts and proof plans without turning every letter into a mandatory separate test.

## Heuristic

- **Z — Zero:** absent, empty, null, initial, or no-result state.
- **O — One:** smallest valid item, actor, event, attempt, or transition.
- **M — Many:** multiple items, repeated actions, ordering, concurrency, scale, or a more complex case.
- **B — Boundary Behaviors:** values just below, at, and just above meaningful limits.
- **I — Interface definition:** inputs, outputs, contracts, ownership, and behavior across component, API, storage, provider, or human boundaries.
- **E — Exercise Exceptional behavior:** invalid input, denial, timeout, partial failure, retry, duplication, cancellation, and recovery.
- **S — Simple Scenarios, Simple Solutions:** begin with the smallest representative scenario and preserve the simplest complete professional behavior.

Treat `Z → O → M` as a progression from simple to complex. Apply `B`, `I`, and `E` wherever they can alter that progression. Let `S` constrain scenario and solution complexity; it never excuses missing correctness, security, recovery, or proof.

## Applicability Gate

Apply the heuristic when behavior includes collections, state transitions, validation/parsing, interfaces, permissions, data, money, retries, queues, synchronization, capacity, migration, or failure recovery.

For copy-only, formatting-only, exact-value configuration, or similarly branch-free micro-edits, record `ZOMBIES: not applicable — <reason>` instead of inventing artificial cases.

## Expected Evidence

In a spec, bug contract, test plan, or verification note, retain a compact `ZOMBIES coverage` record. Name the meaningful cases and mark genuinely irrelevant categories `not applicable` with a reason. Several letters may be proven by one scenario; coverage matters more than test count.

Stop and repair the contract when a meaningful category exposes undefined expected behavior, an unsafe boundary, an unowned interface, or an unproven exceptional path.
